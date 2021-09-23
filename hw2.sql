
--1. What is a result set?
        An SQL result set is a set of rows from a database, as well as metadata about the query 
        such as the column names, and the types and sizes of each column. 

--2. What is the difference between Union and Union All?
        1) UNION will remove the duplicates, UNION ALL does not.
        2) UNOIN values for first column will be sorted automatically.
        3) UNION cannot be used in recursive cte, UNION ALL can.

--3. What are the other Set Operators SQL Server has?
        INTERSECT(All distinct rows selected by both queries)
        MINUS/EXCEPT(All distinct rows selected by the first query but not the second)

--4. What is the difference between Union and Join?
Union:
        SQL combines the result-set of two or more SELECT statements.
        It combines data into new rows.
        Number of columns selected from each table should be same.
        Datatypes of corresponding columns selected from each table should be same.

JOIN:
        combines data from many tables based on a matched condition between them.
        It combines data into new columns.
        Number of columns selected from each table may not be same.
        Datatypes of corresponding columns selected from each table can be different.

--5. What is the difference between INNER JOIN and FULL JOIN?
INNER JOIN: 
        returns rows when there is a match in both tables. An INNER JOIN will only return 
        matched rows if a row in table A matches many rows in table B the table A row will be 
        repeated with each table B row and vice versa.

FULL JOIN: 
        combines the results of both left and right outer joins. A FULL OUTER JOIN will return 
        everything an inner join does and return all unmatched rows from each table.

--6. What is difference between left join and outer join
LEFT JOIN: 
        is one kind of outer join.
        returns all rows from the left table, even if there are no matches in the right table.
OUTER JOIN:
        other kinds of outer join is right outer join and full outer join.
        right outer join, same as left outer join, only difference is it returns all rows from 
        the right table, even if there are no matches in the left table.
        full outer join return everything from left and right table, no matter there are matches
        on the other side or not.

--7. What is cross join?
        it returns the Cartesian product of the sets of records from the two or more joined tables.

--8. What is the difference between WHERE clause and HAVING clause?
        1) both used as fileters -> having applies only to groups as a whole, but where applied 
           to individual rows
        2) WHERE goes before aggregations, HAVING goes after the aggreagations
        3) WHERE can be used with SELECT and UPDATE; Having only SELECT
        
--9. Can there be multiple group by columns? 
        Yes. Group By X, Y means put all those with the same values for both X and Y in the one group.


-- queries:
--1. How many products can you find in the Production.Product table?
SELECT COUNT(*) AS "numberOfProducts"
FROM Production.Product 

--2. Write a query that retrieves the number of products in the Production.Product table 
-- that are included in a subcategory. The rows that have NULL in column ProductSubcategoryID 
-- are considered to not be a part of any subcategory.
SELECT COUNT(ProductSubcategoryID) AS "numberOfProducts"
FROM Production.Product 

--3. How many Products reside in each SubCategory? Write a query to display the results 
-- with the following titles.
SELECT ProductSubcategoryID, COUNT(ProductSubcategoryID) AS "CountedProducts"
FROM Production.Product 
GROUP BY ProductSubcategoryID
ORDER BY ProductSubcategoryID

--4. How many products that do not have a product subcategory. 
 SELECT COUNT(*)-COUNT(ProductSubcategoryID) AS "noSubcategory"
 FROM Production.Product
 
 --5. Write a query to list the sum of products quantity in the Production.ProductInventory table.
SELECT SUM(Quantity) AS "totalQuantity"
FROM Production.ProductInventory

--6. Write a query to list the sum of products in the Production.ProductInventory table and 
-- LocationID set to 40 and limit the result to include just summarized quantities less than 100.
SELECT ProductID, SUM(Quantity) AS "TheSum"
FROM Production.ProductInventory            
WHERE LocationID = 40 AND Quantity < 100
GROUP BY ProductID
ORDER BY ProductID

-- 7. Write a query to list the sum of products with the shelf information in the 
-- Production.ProductInventory table and LocationID set to 40 and limit the result to include 
-- just summarized quantities less than 100
SELECT Shelf, ProductID, SUM(Quantity) AS "TheSum"
FROM Production.ProductInventory            
WHERE LocationID = 40 AND Quantity < 100
GROUP BY Shelf, ProductID
ORDER BY Shelf, ProductID                      
              
--8. Write the query to list the average quantity for products where column LocationID has 
-- the value of 10 from the table Production.ProductInventory table.                  
SELECT ProductID, AVG(Quantity) AS "TheAvg"
FROM Production.ProductInventory            
WHERE LocationID = 10
GROUP BY ProductID
ORDER BY ProductID 

--9. Write query to see the average quantity of products by shelf from the table Production.ProductInventory
SELECT ProductID, Shelf, AVG(Quantity) AS "TheAvg"
FROM Production.ProductInventory            
GROUP BY Shelf
ORDER BY ProductID, Shelf

--10. Write query  to see the average quantity  of  products by shelf excluding rows that has 
-- the value of N/A in the column Shelf from the table Production.ProductInventory
SELECT ProductID, Shelf, AVG(Quantity) AS "TheAvg"
FROM Production.ProductInventory     
WHERE Shelf != 'N/A'        
GROUP BY Shelf
ORDER BY ProductID, Shelf

--11. List the members (rows) and average list price in the Production.Product table. 
-- This should be grouped independently over the Color and the Class column. 
-- Exclude the rows where Color or Class are null.
SELECT Color, Class, COUNT(*) AS "TheCount", AVG(Unitprice) AS "AvgPrice"
FROM Production.Product
WHERE Color is NOT NULL OR Class is NOT NULL 
GROUP BY Color, Class

--12.  Write a query that lists the country and province names from person. CountryRegion and 
-- person. StateProvince tables. Join them and produce a result set similar to the following. 
SELECT c.Name AS "Country", s.Name AS "Province"
FROM Person.CountryRegion c JOIN Person.StateProvince, s
ON c.CountryRegionCode = s.CountryRegionCode
ORDER BY Country, Province

--13. Write a query that lists the country and province names from person. CountryRegion and 
-- person. StateProvince tables and list the countries filter them by Germany and Canada. Join 
-- them and produce a result set similar to the following.
SELECT c.Name AS "Country", s.Name AS "Province"
FROM Person.CountryRegion c JOIN Person.StateProvince, s
ON c.CountryRegionCode = s.CountryRegionCode
   AND (c.Name = 'Germany' OR c.Name = 'Canada')
ORDER BY Country, Province
                        
--14. List all Products that has been sold at least once in last 25 years.
SELECT ProductID, ProductName
FROM Products p 
WHERE ProductID IN(
        SELECT DISTINCT ProductID 
        FROM [Orders Details] od JOIN Orders o
        ON od.OrderID = o.OrderID AND DATEDIFF(year,o.OrderDate,GETDATE()) <= 25
)

--15. List top 5 locations (Zip Code) where the products sold most.
SELECT TOP 5 o.OrderID, o.ShipPostalCode
FROM (
        SELECT od.ProductID, SUM(od.Quantity)
        FROM Orders o JOIN "Order Details" od 
        ON od.OrderID = o.OrderID
        GROUP BY ProductID
        ORDER BY SUM(od.Quantity), od.OrderID
) t
ORDER BY o.OrderID

--16. List top 5 locations (Zip Code) where the products sold most in last 25 years.
SELECT TOP 5 o.OrderID, o.ShipPostalCode
FROM (
        SELECT od.ProductID, SUM(od.Quantity)
        FROM Orders o JOIN "Order Details" od 
        ON od.OrderID = o.OrderID AND DATEDIFF(year,o.OrderDate,GETDATE()) <= 25
        GROUP BY ProductID
        ORDER BY SUM(od.Quantity), od.OrderID
) t
ORDER BY o.OrderID

--17. List all city names and number of customers in that city.  
SELECT DISTINCT City, COUNT(customerId) AS "numberOfCustomers"
FROM Customers
GROUP BY City
ORDER BY City

--18. List city names which have more than 2 customers, and number of customers in that city 
SELECT DISTINCT City, COUNT(customerId) AS "numberOfCustomers"
FROM Customers
GROUP BY City
HAVING COUNT(customerId) > 2
ORDER BY City

--19. List the names of customers who placed orders after 1/1/98 with order date.
SELECT ContactName
FROM Customers 
WHERE CustomerID IN(
        SELECT DISTINCT o.CustomerID 
        FROM Orders o
        WHERE o.OrderDate > '1/1/98'
)

--20. List the names of all customers with most recent order dates 
SELECT ContactName
FROM Customers 
WHERE CustomerID IN(
        SELECT DISTINCT CustomerID 
        FROM Orders
        ORDER BY OrderDate
)

--21. Display the names of all customers  along with the  count of products they bought 
SELECT c.ContactName, COUNT(o.OrderID) AS "numberOfBuy"
FROM Customers c JOIN Orders o
ON c.CustomerID = o.CustomerID
GROUP BY c.ContactName
ORDER BY c.ContactName, numberOfBuy

--22. Display the customer ids who bought more than 100 Products with count of products.
SELECT c.CustomerID
FROM Customers c JOIN Orders o
ON c.CustomerID = o.CustomerID
GROUP BY c.ContactName
HAVING COUNT(o.OrderID) > 100
ORDER BY c.CustomerID

--23. List all of the possible ways that suppliers can ship their products. Display the results 
-- as below
SELECT DISTINCT su.CompanyName AS "Supplier Company Name", sh.CompanyName AS "Shipping Company Name" 
FROM Suppliers su JOIN Products p ON su.SupplierID = p.SupplierID
     JOIN [Order Details] od ON p.ProductID = od.ProductID
     JOIN Orders o ON o.OrderID = od.OrderID
     JOIN Shippers sh ON o.ShipName = sh.CompanyName
ORDER BY su.CompanyName

--24. Display the products order each day. Show Order date and Product Name.
SELECT p.ProductName, o.OrderDate
FROM Products p 
     JOIN [Order Details] od ON p.ProductID = od.ProductID
     JOIN Orders o ON o.OrderID = od.OrderID
ORDER BY o.OrderDate, p.ProductName

--25. Displays pairs of employees who have the same job title.
SELECT e.EmployeeID, e.FirstName + ' ' + e.LastName AS PersonOneName, 
       ee.EmployeeID, ee.FirstName + ' ' + ee.LastName AS PersonTwoName, ee.Title
FROM Employees e JOIN Employees ee
ON (e.Title = ee.Title AND e.EmployeeID != ee.EmployeeID)
ORDER BY e.EmployeeID

--26. Display all the Managers who have more than 2 employees reporting to them.
SELECT n.FirstName + ' ' + n.LastName AS Manager
FROM(
        SELECT DISTINCT m.EmployeeID, COUNT(e.EmployeeID)
        FROM Employees e INNER JOIN Employees m ON e.ReportsTo = m.EmployeeID
        GROUP BY m.EmployeeID
        HAVING COUNT(e.EmployeeID) > 2
) n
ORDER BY n.EmployeeID

--27. Display the customers and suppliers by city. The results should have the following columns
UPDATE (
        SELECT s.City, s.CompanyName, c.City, c.ContactName, Type
        FROM Suppliers s FULL OUTER JOIN Customer c
) a
SET 
    a.Type = 'Suppliers'

WHERE
    a.CompanyName is NOT NULL;
SET 
    a.Type = 'Customer'
WHERE
    a.ContactName is NOT NULL;

       	












