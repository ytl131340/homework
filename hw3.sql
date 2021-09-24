
--1. In SQL Server, assuming you can find the result by using both joins and subqueries, 
-- which one would you prefer to use and why?
        Using joins, Because it is more efficient at most time.

--2. What is CTE and when to use it?
        The Common Table Expressions or CTE’s for short are used within SQL Server to simplify 
        complex joins and subqueries, and to provide a means to query hierarchical data such as 
        an organizational chart. 
        Promote Readability; use CTE’s do create recursive queries; overcome SELECT statement 
        limitations, such as referencing itself (recursion)
      
--3. What are Table Variables? What is their scope and where are they created in SQL Server?
        The table variable is a special type of the local variable that helps to store data 
        temporarily, similar to the temp table in SQL Server. 
        Scope: within the batch that is declared.
        Where: stored in temp database system.
        
--4. What is the difference between DELETE and TRUNCATE? Which one will have better performance and why?
        Difference:
        Delete - 
                Used to delete specified rows(one or more).
                It is a DML(Data Manipulation Language) command.
                There may be WHERE clause in DELETE command in order to filter the records.
        TRUNCATE -
                Used to delete all the rows from a table.
                It is a DDL(Data Definition Language) command.
                There may not be WHERE clause in TRUNCATE command.
                
        Truncate removes all records and does not fire triggers. Truncate is faster compared to delete 
        as it makes less use of the transaction log. 
        
--5. What is Identity column? How does DELETE and TRUNCATE affect it?
        Identity column of a table is a column whose value increases automatically. 
        If the table contains an identity column, the counter for that column is reset to the 
        seed value defined for the column. If no seed was defined, the default value 1 is used. 
        To retain the identity counter, use DELETE instead. A TRUNCATE TABLE operation can be 
        rolled back.
        
--6. What is difference between “delete from table_name” and “truncate table table_name”?
        TRUNCATE always removes all the rows from a table, leaving the table empty and the 
        table structure intact whereas DELETE may remove conditionally if the where clause is used. 

Query:
--1. List all cities that have both Employees and Customers.
        SELECT DISTINCT e.City
        FROM Employees e JOIN Orders o 
        ON e.EmployeeID = o.EmployeeID JOIN Customers c
        ON o.CustomerID = c.CustomerID
        ORDER BY e.City
        
--2. List all cities that have Customers but no Employee.
-- Use sub-query
        SELECT DISTINCT City  
        FROM Customers
        WHERE City NOT IN (SELECT DISTINCT City FROM Employees)
        ORDER BY City
-- Do not use sub-query
        SELECT DISTINCT City
        FROM Customers
        EXCEPT
        SELECT DISTINCT City  
        FROM Employees
        ORDER BY City        
        
--3. List all products and their total order quantities throughout all orders.
        SELECT p.ProductName, COUNT(o.OrderID) AS "totalQuantity"
        FROM Products p JOIN [Order Details] od ON p.ProductID = od.ProductID
        JOIN Orders o ON od.OrderID = o.OrderID
        GROUP BY p.ProductName
        ORDER BY p.ProductName
        
--4. List all Customer Cities and total products ordered by that city.
        SELECT c.City, COUNT(o.OrderID)
        FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID
        GROUP BY c.City
        
--5. List all Customer Cities that have at least two customers.
        SELECT m.City  
        FROM (
            SELECT City, COUNT(CustomerID) AS "total"
            FROM Customers c
            GROUP BY city
        ) m
        WHERE m.total >=2 

--6. List all Customer Cities that have ordered at least two different kinds of products.
        SElECT c.City, COUNT(DISTINCT p.ProductID) AS "typeOfProducts"
        FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID
        JOIN [Order Details] od ON od.OrderID = o.OrderID
        JOIN Products p ON od.ProductID = p.ProductID
        GROUP BY c.City
        HAVING COUNT(DISTINCT p.ProductID)>=2
        ORDER BY c.City
        
--7. List all Customers who have ordered products, but have the ‘ship city’ on the order 
-- different from their own customer cities.
        SELECT DISTINCT c.CustomerID, c.ContactName 
        FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID
        WHERE c.City != o.ShipCity
        ORDER BY c.ContactName

--8. List 5 most popular products, their average price, and the customer city that ordered 
-- most quantity of it.
        SELECT TOP 5 p.ProductID, p.ProductName, AVG(od.UnitPrice*Quantity) AS "averagePrice", o.ShipCity
        FROM Products p JOIN [Order Details] od ON p.ProductID = od.ProductID
        JOIN Orders o ON od.OrderID = o.OrderID
        GROUP BY p.ProductID, p.ProductName, o.ShipCity
        ORDER BY COUNT(od.ProductID) DESC
        
--9. List all cities that have never ordered something but we have employees there.
-- Use sub-query
        SELECT e.City  
        FROM Employees e 
        WHERE e.city IN (
            SELECT c.City
            FROM Customers c FULL OUTER JOIN Orders o ON c.CustomerID = o.CustomerID
            WHERE c.CustomerID is NULL
        )
-- Do not use sub-query
        SELECT e.city  
        FROM Employees e FULL OUTER JOIN Orders o ON e.EmployeeID = o.EmployeeID
        FULL OUTER JOIN Customers c ON c.CustomerID = o.CustomerID
        WHERE c.City is NULL;
        
--10. List one city, if exists, that is the city from where the employee sold most orders 
-- (not the product quantity) is, and also the city of most total quantity of products ordered 
-- from. (tip: join  sub-query)
        SELECT m.City
        FROM(
            SELECT e.City, COUNT(o.OrderID) AS "quantity"
            FROM Employees e JOIN Orders o ON e.EmployeeID = o.EmployeeID
            GROUP BY e.City
        ) m  
        JOIN (
            SELECT c.City, COUNT(o.OrderID) AS "quantity"
            FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID
            GROUP BY c.City
        ) n
        ON m.City = n.City
        
--11. How do you remove the duplicates record of a table?
        WITH SampleTableCTE as(  
           SELECT*, ROW_NUMBER() over (PARTITION BY ID ORDER BY ID) as RowNumber  
           FROM SampleTable  
        )  
        DELETE FROM SampleTableCTE WHERE RowNumber>1       
        SELECT * FROM SampleTable 
        
--12. Sample table to be used for solutions below- Employee (empid integer, mgrid integer, 
-- deptid integer, salary money) Dept (deptid integer, deptname varchar(20)) Find employees who do not 
-- manage anybody.
        WITH empHierachyCTE
        AS(
                SELECT empid, mgrid, 1 AS LVL 
                FROM Employee
                WHERE mgrid is NULL
                UNION ALL
                SELECT e.empid, e.mgrid, ct.LVL+1
                FROM Employee e INNER JOIN empHierachyCTE ct ON e.mgrid = ct.empid
        )
        SELECT empid, MAX(LVL)
        FROM empHierachyCTE
        GROUP BY empid
        
--13. Find departments that have maximum number of employees. (solution should consider scenario 
-- having more than 1 departments that have maximum number of employees). Result should only 
-- have - deptname, count of employees sorted by deptname.
        SELECT d.deptname, COUNT(e.empid) AS "numberOfEmployees" DENSE_RANK() OVER(ORDER BY COUNT(e.empid) DESC) DenseRNK
        FROM FROM Employee e JOIN Dept d ON e.deptid = d.deptid
        WHERE DenseRNK = 1
        ORDER BY d.deptname

--14. Find top 3 employees (salary based) in every department. Result should have deptname, empid, 
-- salary sorted by deptname and then employee with high to low salary.
        SELECT e.empid, d.deptname, RANK() OVER(PARTITION BY d.deptid ORDER BY Count(e.salary)) RNK
        FROM Employee e JOIN Dept d ON e.deptid = d.deptid
        WHERE RNK = 3
        GROUP BY e.empid, d.deptname
        ORDER BY d.deptname, e.salary




