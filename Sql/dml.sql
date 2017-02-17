USE webshop;

-- 1. Visa antalet produkter per kategori
DROP VIEW IF EXISTS ProductsPerCategory;
CREATE VIEW ProductsPerCategory
AS
    SELECT categories.CategoryName AS Category,
           COUNT(products.ProductID) AS 'Count'
    FROM categories
        INNER JOIN productcategories ON categories.CategoryID = productcategories.CategoryID
        INNER JOIN Products ON ProductCategories.ProductID = Products.ProductID
    GROUP BY CategoryName ORDER BY Count(products.ProductID) DESC;
-- 2.Skapa en kundlista med det totala ordervärdet kunden har beställt för. [Kundens för- och efernamn, samt det totala ordervärdet skall visas]

DROP VIEW IF EXISTS CustomerOrderList;
CREATE VIEW CustomerOrderList
AS
    SELECT
        CONCAT_WS(' ', Customers.FirstName, Customers.lastName) AS Customer,
        (SELECT SUM(products.Price) * productorders.Amount)     AS TotalAmount
    FROM Customers
        INNER JOIN orderrows ON customers.CustomerID = orderrows.CustomerID
        INNER JOIN productorders ON orderrows.OrderID = productorders.OrderID
        INNER JOIN products ON productorders.ProductID = products.ProductID
    GROUP BY Customer
    ORDER BY TotalAmount DESC;


-- 3.Vilka kunder har köpt blåa byxor i storlek 32 av märket Nudie?

DROP VIEW IF EXISTS BlueNudie32;
CREATE VIEW BlueNudie32
AS
    SELECT DISTINCT CONCAT_WS(' ', Customers.FirstName, Customers.lastName) AS Customer
    FROM customers
        INNER JOIN orderrows ON customers.CustomerID = orderrows.CustomerID
        INNER JOIN productorders ON orderrows.OrderID = productorders.OrderID
        INNER JOIN products ON productorders.ProductID = products.ProductID
    WHERE products.Color = 'Blue' AND products.Size = 32;

-- 4.Skriv ut en lista på det totala ordervärdet per ort där ordervärdet är större än 1000 kr

DROP VIEW IF EXISTS OrderAbove1kCity;
CREATE VIEW OrderAbove1kCity
AS
    SELECT
        City,
        (SELECT SUM(products.Price) * productorders.Amount) AS TotalAmount
    FROM Customers
        INNER JOIN orderrows ON customers.CustomerID = orderrows.CustomerID
        INNER JOIN productorders ON orderrows.OrderID = productorders.OrderID
        INNER JOIN products ON productorders.ProductID = products.ProductID
    GROUP BY City
    HAVING TotalAmount > 1000
    ORDER BY TotalAmount DESC;

-- 5.Skapa en top 5 lista av de mest sålda produkterna.
DROP VIEW IF EXISTS Top5;
CREATE VIEW Top5
AS
    SELECT
        ProductID,
        ProductName,
        Brand,
        (SELECT SUM(Amount)
         FROM productorders
         WHERE products.ProductID = productorders.ProductID
         GROUP BY ProductID) AS TimesSold
    FROM products
    ORDER BY TimesSold DESC
    LIMIT 5;

-- 6. Vilken månad hade man den största försäljningen?
DROP VIEW IF EXISTS BestMonth;
CREATE VIEW BestMonth
AS
    SELECT
        (SELECT date_format(OrderDate,'%b %Y'))             AS Month,
        (SELECT SUM(products.Price) * productorders.Amount) AS TotalAmount
    FROM orderrows
        INNER JOIN productorders ON orderrows.OrderID = productorders.OrderID
        INNER JOIN products ON productorders.ProductID = products.ProductID
    GROUP BY Month
    ORDER BY TotalAmount DESC
    LIMIT 1;

-- Procedure1
DROP PROCEDURE IF EXISTS AddToCart;
DELIMITER //
CREATE PROCEDURE AddToCart(IN CustomerNumber INT, ProductNumber INT, OrderNumber INT)
    BEGIN
        IF OrderNumber IS NULL
        THEN
            INSERT INTO OrderRows (CustomerID)
            VALUES (CustomerNumber);
            INSERT INTO productorders (OrderID, ProductID)
            VALUES (LAST_INSERT_ID(), ProductNumber);
        ELSE
            INSERT INTO OrderRows (OrderID, CustomerID)
            VALUES (OrderNumber, CustomerNumber);
            INSERT INTO productorders (OrderID, ProductID)
            VALUES (OrderNumber, ProductNumber);
        END IF;
    END //
DELIMITER ;


-- Procedure 2
DROP PROCEDURE IF EXISTS TopProducts;
DELIMITER //
CREATE PROCEDURE TopProducts(IN StartingDate DATETIME, EndingDate DATETIME, ListAmount INT)
    BEGIN
        SELECT
            products.ProductID,
            products.ProductName,
            SUM(Amount) AS TimesSold
        FROM products
            INNER JOIN productorders ON products.ProductID = productorders.ProductID
            INNER JOIN orderRows ON productorders.OrderID = orderRows.OrderID
        WHERE orderRows.OrderDate BETWEEN StartingDate AND EndingDate
        GROUP BY products.ProductID
        LIMIT ListAmount;
    END //
DELIMITER ;


-- Procedure 3
DROP TRIGGER IF EXISTS StockEmpty;
DELIMITER //
CREATE TRIGGER StockEmpty AFTER UPDATE ON instock
    FOR EACH ROW
    BEGIN
        IF new.Amount = 0 THEN
            INSERT INTO outofstock (ProductID, OutDate)
                VALUES (new.ProductID, NOW());
        END IF;
    END //
    DELIMITER ;