package com.kallrobin;

import java.sql.*;
import java.sql.Date;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

public class Main {
    public static void main(String[] args) {
        while(true) {
        Connection con = null;
        PreparedStatement stm = null;
        ResultSet rs = null;

        String url = "jdbc:mysql://localhost:3306/webshop?useSSL=false";

            System.out.println("\n\nVälj vilken uppgift du vill se svaret på (1-6)\n" +
                    "\n1. Skriv ut en lista som visar samtliga produkter per kategori." +
                    "\n2. Skriv ut en kundlista med det totala ordervärdet kunden har beställt för." +
                    "\n3. Sök Produkt." +
                    "\n4. Visa en försäljningsrapport." +
                    "\n5. Skapa ett gränssnit för din procedur TopProducts()" +
                    "\n6. Skapa ett gränssnit för din procedur LäggTillKundvagn()" +
                    "\n0. Avsluta programmet\n");
            Scanner sc = new Scanner(System.in);
            int task = Integer.parseInt(sc.nextLine());

            try {
                con = DriverManager.getConnection(url, "Admin", "Bubbas1992");
                switch (task) {
                    case 1:
                        stm = con.prepareStatement("SELECT * FROM ProductsPerCategory;");
                        rs = stm.executeQuery();

                        while (rs.next()) {
                            String category = rs.getString("Category");
                            int ammount = rs.getInt("Count");

                            System.out.println(ammount + " produter av kategorin " + category);
                        }
                        break;
                    case 2:
                        System.out.println("Skriv in kundnummer: ");

                        String in = sc.nextLine();

                        if (in.equals("")) in = "0";


                        int customerNumber = Integer.parseInt(in);
                        if (customerNumber == 0) {
                            stm = con.prepareStatement("SELECT * FROM customerorderlist;");
                        } else {
                            stm = con.prepareStatement("SELECT Customer, TotalAmount " +
                                    "FROM customerorderlist " +
                                    "INNER JOIN customers ON CONCAT_WS(' ', Customers.FirstName, Customers.lastName) = Customer WHERE CustomerID = ?;");
                            stm.setInt(1,customerNumber);
                        }
                        rs = stm.executeQuery();

                        while (rs.next()) {
                            String customer = rs.getString("Customer");
                            double ammount = rs.getDouble("TotalAmount");

                            System.out.println(customer + " har köpt för " + ammount);
                        }
                        break;
                    case 3:
                        System.out.println("Skriv in sökord: ");
                        in = sc.nextLine();

                        stm = con.prepareStatement("SELECT * FROM Products WHERE ProductName LIKE ?;");
                        stm.setString(1, "%"+ in +"%");
                        rs = stm.executeQuery();

                        System.out.println("Sökresultat: ");
                        while (rs.next()) {
                            String productName = rs.getString("ProductName");
                            int productID = rs.getInt("ProductID");

                            System.out.println("id:" + productID + " " + productName);
                        }
                        break;
                    case 4:
                        System.out.println("Skriv in månad i siffror: ");
                        in = sc.nextLine();

                        if (in.equals("")) in = "0";


                        int val= Integer.parseInt(in);
                        if (val == 0) {
                            stm = con.prepareStatement("SELECT " +
                                    "(SELECT date_format(OrderDate,'%c')) AS Month, " +
                                    "(SELECT date_format(OrderDate,'%Y')) AS Year, " +
                                    "(SELECT SUM(products.Price) * productorders.Amount) AS TotalAmount " +
                                    "FROM orderrows " +
                                    "INNER JOIN productorders ON orderrows.OrderID = productorders.OrderID " +
                                    "INNER JOIN products ON productorders.ProductID = products.ProductID " +
                                    "GROUP BY Month " +
                                    "ORDER BY OrderDate;\n");
                        } else {
                            stm = con.prepareStatement("SELECT " +
                                    "(SELECT date_format(OrderDate,'%c')) AS Month, " +
                                    "(SELECT date_format(OrderDate,'%Y')) AS Year, " +
                                    "(SELECT SUM(products.Price) * productorders.Amount) AS TotalAmount " +
                                    "FROM orderrows " +
                                    "INNER JOIN productorders ON orderrows.OrderID = productorders.OrderID " +
                                    "INNER JOIN products ON productorders.ProductID = products.ProductID " +
                                    "GROUP BY Month " +
                                    "HAVING Month= ? " +
                                    "ORDER BY OrderDate;");
                            stm.setInt(1, val);
                        }
                        rs = stm.executeQuery();

                        while (rs.next()) {
                            String month = rs.getString("Month");
                            String year = rs.getString("Year");
                            double ammount = rs.getDouble("TotalAmount");

                            System.out.println(month + "/" + year + " har det sålts för  " + ammount);
                        }
                        break;
                    case 5:
                        SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd");

                        System.out.println("Skriv in Startdatum ÅÅÅÅ-MM-DD");
                        java.util.Date utilStartDate = format.parse(sc.nextLine());
                        java.sql.Date start = new java.sql.Date(utilStartDate.getTime());
                        System.out.println("Skriv in Slutdatum ÅÅÅÅ-MM-DD");
                        java.util.Date utilEndDate = format.parse(sc.nextLine());
                        java.sql.Date end = new java.sql.Date(utilEndDate.getTime());
                        System.out.println("Skriv in Antal att lista");
                        int listLenght = Integer.parseInt(sc.nextLine());

                        stm = con.prepareStatement("CALL TopProducts(?,?,?)");
                        stm.setDate(1, start);
                        stm.setDate(2, end);
                        stm.setInt(3, listLenght);

                        rs = stm.executeQuery();

                        System.out.println("Top Products");
                        while (rs.next()) {
                            String productName = rs.getString("ProductName");
                            int productID = rs.getInt("ProductID");
                            int timesSold = rs.getInt("TimesSold");

                            System.out.println("id:" + productID + " " + productName + " har sålts " + timesSold + " gånger");
                        }
                        break;
                    case 6:
                        int productID = 0;
                        int customerID = 0;
                        int orderID = 0;


                        System.out.println("Välj Produkt med hjälp av siffrorna innan produktnamnet.");
                        stm = con.prepareStatement("SELECT ProductID, ProductName, Brand, Size, Color, Price FROM products ORDER BY Brand");
                        rs = stm.executeQuery();
                        int count = 1;
                        System.out.format("%n%4s%8s%12s%10s%6s%10s%n", "Count", "Namn", "Märke", "Storlek", "Färg", "Pris");
                        while (rs.next()) {
                            String productName = rs.getString("ProductName");
                            String brand = rs.getString("Brand");
                            int size = rs.getInt("Size");
                            String color = rs.getString("Color");
                            double price = rs.getDouble("Price");
                            System.out.format("%2d%12s%10s%6s%10s%10s%n", count, productName, brand, size, color, price);
                            count++;
                        }
                        int choice = Integer.parseInt(sc.nextLine());
                        rs = stm.executeQuery();
                        for (int i = 0; i < choice; i++) {
                            rs.next();
                            productID = rs.getInt("ProductID");
                        }

                        System.out.println("Välj Kund med hjälp av siffrorna innan kundnamnet.");
                        stm = con.prepareStatement("SELECT CustomerID, FirstName, LastName FROM Customers ORDER BY FirstName");
                        rs = stm.executeQuery();
                        count = 1;
                        System.out.format("%n%4s%15s%n", "Val", "Kund");
                        while (rs.next()) {
                            String firstName = rs.getString("FirstName");
                            String lastName = rs.getString("LastName");
                            String name = firstName + " " + lastName;
                            System.out.format("%2d%20s%n", count, name);
                            count++;
                        }
                        choice = Integer.parseInt(sc.nextLine());
                        rs = stm.executeQuery();
                        for (int i = 0; i < choice; i++) {
                            rs.next();
                            customerID = rs.getInt("CustomerID");
                        }

                        System.out.println("Välj Order med hjälp av siffrorna innan Orderraden. För ny order välj 0");
                        stm = con.prepareStatement("SELECT customers.CustomerID, OrderID, FirstName, LastName, OrderDate " +
                                "FROM orderrows " +
                                "INNER JOIN customers ON orderrows.CustomerID = customers.CustomerID " +
                                "HAVING CustomerID = ? " +
                                "ORDER BY FirstName;");
                        stm.setInt(1, customerID);
                        rs = stm.executeQuery();
                        count = 1;
                        System.out.format("%n%4s%15s%10s%n", "Val", "Kund", "Datum");
                        while (rs.next()) {
                            String firstName = rs.getString("FirstName");
                            String lastName = rs.getString("LastName");
                            String name = firstName + " " + lastName;
                            String date = rs.getDate("OrderDate").toString();
                            System.out.format("%2d%20s%12s%n", count, name, date);
                            count++;
                        }
                        choice = Integer.parseInt(sc.nextLine());
                        rs = stm.executeQuery();
                        for (int i = 0; i < choice; i++) {
                            rs.next();
                            customerID = rs.getInt("CustomerID");
                        }
                        if (orderID == 0){
                            stm = con.prepareStatement("CALL AddToCart(?,?,NULL)");
                            stm.setInt(1, customerID);
                            stm.setInt(2, productID);
                        } else {
                            stm = con.prepareStatement("CALL AddToCart(?,?,?)");
                            stm.setInt(1, customerID);
                            stm.setInt(2, productID);
                            stm.setInt(3, orderID);
                        }
                        stm.executeQuery();

                        break;
                    case 0:
                        System.exit(0);
                }
            } catch (SQLException e) {
                e.printStackTrace();
            } catch (ParseException e) {
                e.printStackTrace();
            } finally {
                if (rs != null)
                    try {
                        rs.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                if (stm != null)
                    try {
                        stm.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                if (con != null)
                    try {
                        con.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
            }
        }
    }
}
