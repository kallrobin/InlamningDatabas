DROP DATABASE IF EXISTS webshop;
CREATE DATABASE webshop;
USE webshop;

-- Setting up tables
CREATE TABLE Customers (
    CustomerID INT AUTO_INCREMENT,
    FirstName  VARCHAR(50),
    LastName   VARCHAR(50),
    City       VARCHAR(50),
    PRIMARY KEY (CustomerID)
);


CREATE TABLE OrderRows (
    OrderID    INT AUTO_INCREMENT,
    CustomerID INT,
    OrderDate DATETIME DEFAULT NOW(),
    PRIMARY KEY (OrderID),
    FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID)
        ON DELETE CASCADE
);

CREATE TABLE ProductCategories (
    ID           INT AUTO_INCREMENT,
    CategoryName VARCHAR(50),
    KEY (CategoryName),
    PRIMARY KEY (ID)
);

CREATE TABLE Categories (
    CategoryName VARCHAR(50),
    PRIMARY KEY (CategoryName),
    FOREIGN KEY (CategoryName) REFERENCES ProductCategories (CategoryName)
);

CREATE TABLE Products (
    ProductID         INT AUTO_INCREMENT,
    ProductCategoryID INT,
    ProductName       VARCHAR(50),
    Brand             VARCHAR(50),
    Size              INT,
    Color             VARCHAR(50),
    Price             DECIMAL(8, 2),
    PRIMARY KEY (ProductID),
    FOREIGN KEY (ProductCategoryID) REFERENCES ProductCategories (ID)
        ON DELETE CASCADE
);

CREATE TABLE ProductOrders (
    OrderID   INT,
    ProductID INT,
    Amount    INT DEFAULT 1,
    PRIMARY KEY (ProductID, OrderID),
    FOREIGN KEY (OrderID) REFERENCES OrderRows (OrderID)
        ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Products (ProductID)
        ON DELETE CASCADE
);

CREATE TABLE InStock (
    ProductID INT,
    Amount    INT,
    PRIMARY KEY (ProductID),
    FOREIGN KEY (ProductID) REFERENCES Products (ProductID)
        ON DELETE CASCADE
);

CREATE TABLE OutOfStock (
    ProductID INT,
    OutDate   DATETIME,
    PRIMARY KEY (ProductID),
    FOREIGN KEY (ProductID) REFERENCES Products (ProductID)
        ON DELETE CASCADE
);

-- Insert Customers
INSERT INTO Customers (FirstName, LastName, City)
VALUES ('Peter', 'Nickolaus', 'Stockholm');

INSERT INTO Customers (FirstName, LastName, City)
VALUES ('Klara', 'Fisk', 'Umeå');

INSERT INTO Customers (FirstName, LastName, City)
VALUES ('Stig', 'Steen', 'Sundsvall');

INSERT INTO Customers (FirstName, LastName, City)
VALUES ('Kaj', 'Steen', 'Timrå');

INSERT INTO Customers (FirstName, LastName, City)
VALUES ('Pierre', 'Poetatis', 'Stockholm');

-- Insert Categories
INSERT INTO ProductCategories (CategoryName)
VALUES ('Pants');

INSERT INTO ProductCategories (CategoryName)
VALUES ('Shoes');

INSERT INTO ProductCategories (CategoryName)
VALUES ('Tops');

INSERT INTO ProductCategories (CategoryName)
VALUES ('Accessories');

INSERT INTO ProductCategories (CategoryName)
VALUES ('Jackets');

-- Insert Products
INSERT INTO Products (ProductCategoryID, ProductName, Brand, Size, Color, Price)
VALUES (1, 'Jeans', 'Nudie', 32, 'Blue', 899.95);

INSERT INTO Products (ProductCategoryID, ProductName, Brand, Size, Color, Price)
VALUES (1, 'Jeans', 'Levi', 40, 'Black', 1249);

INSERT INTO Products (ProductCategoryID, ProductName, Brand, Size, Color, Price)
VALUES (2, 'High-Tops', 'Volcom', 42, 'Orange', 1898.98);

INSERT INTO Products (ProductCategoryID, ProductName, Brand, Size, Color, Price)
VALUES (2, 'Sneaker', 'Nike', 38, 'White', 1299.99);

INSERT INTO Products (ProductCategoryID, ProductName, Brand, Size, Color, Price)
VALUES (3, 'Shirt', 'Adidctus', 30, 'Grey', 799.99);

INSERT INTO Products (ProductCategoryID, ProductName, Brand, Size, Color, Price)
VALUES (4, 'Belt', 'Adidas', 30, 'Blue', 299.99);

INSERT INTO Products (ProductCategoryID, ProductName, Brand, Size, Color, Price)
VALUES (4, 'Bracelet', 'Safira', 4, 'Gold', 5499.50);

INSERT INTO Products (ProductCategoryID, ProductName, Brand, Size, Color, Price)
VALUES (5, 'Bomber', 'SQRTN', 40, 'Black', 999.98);


-- Insert Orders
INSERT INTO OrderRows (CustomerID,OrderDate)
VALUES (1, '2017-01-01 12:00');
INSERT INTO productorders (OrderID, ProductID, Amount)
VALUES (LAST_INSERT_ID(), 6, 2);

INSERT INTO OrderRows (CustomerID,OrderDate)
VALUES (2, '2017-01-05 12:00');
INSERT INTO productorders (OrderID, ProductID, Amount)
VALUES (LAST_INSERT_ID(), 4, 3);

INSERT INTO OrderRows (CustomerID,OrderDate)
VALUES (3, '2016-12-24 11:20');
INSERT INTO productorders (OrderID, ProductID, Amount)
VALUES (LAST_INSERT_ID(), 5, 1);

INSERT INTO OrderRows (CustomerID,OrderDate)
VALUES (4, '2014-06-03 15:33');
INSERT INTO productorders (OrderID, ProductID, Amount)
VALUES (LAST_INSERT_ID(), 1, 1);

INSERT INTO OrderRows (CustomerID,OrderDate)
VALUES (5, NOW());
INSERT INTO productorders (OrderID, ProductID, Amount)
VALUES (LAST_INSERT_ID(), 3, 2);

INSERT INTO OrderRows (CustomerID,OrderDate)
VALUES (1, NOW());
INSERT INTO productorders (OrderID, ProductID, Amount)
VALUES (LAST_INSERT_ID(), 2, 1);



