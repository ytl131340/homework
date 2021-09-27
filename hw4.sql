-- 1. What is View? What are the benefits of using views?
	A virtual table that refernce to data from one or multiple tables
	Views can represent a subset of the data contained in a table; 
	Views can join and simplify multiple tables into a single virtual table; 
	Views can act as aggregated tables, where the database engine aggregates data (sum, average, etc.); 
	Views can hide the complexity of data.	
	
-- 2. Can data be modified through views?
	No, updates for these types of views must be made in the base table.
	
-- 3. What is stored procedure and what are the benefits of using it?
	Stored procedure is a batch of statements grouped as a logical unit and stored in the database.
	Whenever you call a procedure the response is quick; 
	you can group all the required SQL statements in a procedure and execute them at once; 
	you can avoid repetition of code.
 
-- 4. What is the difference between view and stored procedure?
	View is simple showcasing data stored in the database tables whereas a stored procedure is a 
	group of statements that can be executed. A view is faster as it displays data from the tables 
	referenced whereas a store procedure executes sql statements.
	
-- 5. What is the difference between stored procedure and functions?
	usage: SP used for DML; function for calculations
	how to call: SP must be called by its name, Function insisde SELECT/FROM statement
	input: SP may or maynot take input, function must have input
	output: SP may or maynot have output, function must return some values
	SP can call functions, but functions cannot call SP
	
-- 6. Can stored procedure return multiple result sets?
	Yes.
	
-- 7. Can stored procedure be executed as part of SELECT Statement? Why?
	No. Stored procedures are typically executed with an EXEC statement.
	
-- 8. What is Trigger? What types of Triggers are there?
	A trigger is a special type of stored procedure that automatically runs when an event occurs 
	in the database server. DML triggers run when a user tries to modify data through a data manipulation 
	language (DML) event.
	DML (data manipulation language) triggers. These are – INSERT, UPDATE, and DELETE. 
	DDL (data definition language) triggers – As expected, triggers of this type shall 
	react to DDL commands like – CREATE, ALTER, and DROP.
	
-- 9. What are the scenarios to use Triggers?
	Log table modifications. Some tables have sensitive data such as customer email, employee salary, etc., that you want to log all the changes.
	Enforce complex integrity of data.
	
-- 10. What is the difference between Trigger and Stored Procedure?
	Trigger and Procedure both perform a specified task on their execution. The fundamental difference 
	between Trigger and Procedure is that the Trigger executes automatically on occurrences of an event 
	whereas, the Procedure is executed when it is explicitly invoked.
    
    
-- Query: 
USE NORTHWND
GO
--1. Lock tables Region, Territories, EmployeeTerritories and Employees. Insert following information into the database. In case of an error, no changes should be made to DB.
    LOCK TABLES dbo.Region, dbo.Territories, dbo.EmployeeTerritories and dbo.Employees;
    -- a. A new region called “Middle Earth”;
        INSERT INTO dbo.Region
        VALUE(NULL, 'Middle Earth')

    -- b. A new territory called “Gondor”, belongs to region “Middle Earth”;
        INSERT INTO dbo.Territories
        VALUE(NULL, 'Gondor', 4)

    -- c. A new employee “Aragorn King” whos territory is “Gondor”.
        INSERT INTO Employees
        VALUES(NULL, 'King', 'Aragorn', NULL, NULL, NULL, NULL, NULL, NULL, 'Gondor', NULL, NULL, NULL, NULL, NULL, NULL)

--2. Change territory “Gondor” to “Arnor”.
    UPDATE Employees
    SET Region = 'Arnor'
    WHERE Region = 'Gondor';

--3. Delete Region “Middle Earth”. (tip: remove referenced data first) (Caution: do not forget WHERE or you will delete everything.) 
-- In case of an error, no changes should be made to DB. Unlock the tables mentioned in question 1.
    UNLOCK TABLES dbo.Region, dbo.Territories, dbo.EmployeeTerritories and dbo.Employees.
    DELETE FROM dbo.Region
    WHERE RegionDescription = 'Middle Earth'

-- 4. Create a view named “view_product_order_[your_last_name]”, list all products and total ordered quantity for that product.
    CREATE VIEW [view_product_order_liu] AS
    SELECT p.productID AS "productID", p.ProductName AS "ProductName", COUNT(o.OrderID) AS "quantity"
    FROM dbo.Products p JOIN dbo.[Order Details] od ON p.ProductID = od.ProductID 
    JOIN Orders o ON od.OrderID = o.OrderID
    GROUP BY p.productID, p.ProductName

--5. Create a stored procedure “sp_product_order_quantity_[your_last_name]” that accept product id as an input and total quantities of order as output parameter.
    CREATE PROC [sp_product_order_quantity_liu]
    @pid int,
    @tquant int out
    AS
    BEGIN
        SELECT @tquant = m.quantity FROM (
            SELECT p.productID AS "productID", p.ProductName AS "ProductName", COUNT(o.OrderID) AS "quantity"
            FROM dbo.Products p JOIN dbo.[Order Details] od ON p.ProductID = od.ProductID 
            JOIN Orders o ON od.OrderID = o.OrderID
            GROUP BY p.productID, p.ProductName
        ) m
        WHERE m.productID = @pid
        print @tquant
    END
    EXEC sp_product_order_quantity_liu 1, 0

-- 6. Create a stored procedure “sp_product_order_city_[your_last_name]” that accept product name as an input and top 5 cities 
-- that ordered most that product combined with the total quantity of that product ordered from that city as output.

    CREATE PROC [sp_product_order_city_liu]
    @pname varchar
    AS
    BEGIN
            select TOP 5 c.City, COUNT(p.ProductID) AS "quantity"
            from dbo.Customers c JOIN Orders o ON c.CustomerID = o.CustomerID
            JOIN [Order Details] od ON o.OrderID = od.OrderID
            JOIN Products p ON p.ProductID = od.ProductID
            WHERE p.ProductName = @pname
            GROUP BY c.City
            ORDER BY COUNT(p.ProductID) DESC
    END
    EXEC sp_product_order_city_liu 'Chai'

--7. Lock tables Region, Territories, EmployeeTerritories and Employees. Create a stored procedure “sp_move_employees_[your_last_name]” 
-- that automatically find all employees in territory “Tory”; if more than 0 found, insert a new territory “Stevens Point” of region “North” 
-- to the database, and then move those employees to “Stevens Point”.
    LOCK TABLES dbo.Region, dbo.Territories, dbo.EmployeeTerritories and dbo.Employees;
    CREATE PROC [sp_move_employees_liu]
    AS
    BEGIN
        select e.EmployeeID
        from Employees e JOIN EmployeeTerritories et ON e.EmployeeID = et.EmployeeID
        JOIN Territories t ON et.TerritoryID = t.TerritoryID
        WHERE t.TerritoryID =  'Tory'
        IF COUNT(e.EmployeeID) > 0 
        INSERT INTO dbo.Territories
        VALUES(NULL,'Stevens Point',3)
    END

--8. Create a trigger that when there are more than 100 employees in territory “Stevens Point”, move them back to Troy. 
-- (After test your code,) remove the trigger. Move those employees back to “Troy”, if any. Unlock the tables.
    create trigger [moveTrigger] ON dbo.Territories
    DELETE
    AS
    BEGIN
        select COUNT(e.EmployeeID) AS [numberOfEmployee]
        from Employees e JOIN EmployeeTerritories et ON e.EmployeeID = et.EmployeeID
        JOIN Territories t ON et.TerritoryID = t.TerritoryID
        WHERE t.TerritoryID =  'Stevens Point'
        IF numberOfEmployee > 100 
        UPDATE dbo.Territories
        SET TerritoryID =  'Troy'
        WHERE TerritoryID =  'Stevens Point'
    END

--9. Create 2 new tables “people_your_last_name” “city_your_last_name”. City table has two records: 
-- Remove city of Seattle. If there was anyone from Seattle, put them into a new city “Madison”. 
-- Create a view “Packers_your_name” lists all people from Green Bay. 
-- If any error occurred, no changes should be made to DB. (after test) Drop both tables and view.      
    CREATE TABLE People_liu(
        Id int,
        Name varchar(255),
        City varchar(100)
    )
    CREATE TABLE City_liu(
        Id int,
        City varchar(100)
    )
    UPDATE People_liu
    SET City = 'Madison'
    WHERE City = 'Seattle' 

    CREATE VIEW [Packers_liu] AS
    SELECT * 
    FROM People_liu
    WHERE City = 'Green Bay'

    DROP VIEW Packers_liu
    DROP TABLE People_liu, City_liu

--10. Create a stored procedure “sp_birthday_employees_[you_last_name]” that creates a new table “birthday_employees_your_last_name” and fill it 
-- with all employees that have a birthday on Feb. (Make a screen shot) drop the table. Employee table should not be affected.
    CREATE PROC [“sp_birthday_employees__liu]
    AS
    BEGIN
    SELECT EmployeeID, LastName, FirstName, BirthDate
    INTO [birthday_employees_liu]
    FROM Employees
    WHERE DATEPART(mm,BirthDate) = '02'
    DROP TABLE birthday_employees_liu  
    END
 
--11. Create a stored procedure named “sp_your_last_name_1” that returns all cites that have at least 2 customers who have bought no or only 
-- one kind of product. Create a stored procedure named “sp_your_last_name_2” that returns the same but using a different approach. (sub-query and no-sub-query).
    CREATE PROC [“sp_liu_1]
    AS
    BEGIN
        SELECT cc.City, COUNT(m.CustomerID) FROM Customers cc JOIN(
            SELECT c.CustomerID, COUNT(p.ProductID) AS "types"
            FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID
            JOIN [Order Details] od ON od.OrderID = o.OrderID
            JOIN Products p ON p.ProductID = od.ProductID
            GROUP BY c.CustomerID
            HAVING COUNT(p.ProductID) < 2
        ) m ON cc.CustomerID = m.CustomerID
        GROUP BY cc.City
        HAVING COUNT(m.CustomerID) >= 2
    END

    CREATE PROC [“sp_liu_2]
    AS
    BEGIN
    SELECT m.City, COUNT(m.CustomerID)
    FROM(
        SELECT c.CustomerID, c.City, COUNT(p.ProductID) AS "types"
        FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID
        JOIN [Order Details] od ON od.OrderID = o.OrderID
        JOIN Products p ON p.ProductID = od.ProductID
        GROUP BY c.CustomerID, c.City
        HAVING COUNT(p.ProductID) < 2        
    ) m
    GROUP BY m.City
    HAVING COUNT(m.CustomerID) >= 2
    END

--12. How do you make sure two tables have the same data?
    CHECKSUM TABLE table1, table2;

--14. 
    SELECT [First Name]
    CASE 
    WHEN [Middle Name] is not NULL THEN + ‘ ’ + [Middle Name] 
    ELSE + ‘ ’
    +[Last Name] AS [Full Name]
    FROM tableGiven

--15.Find the top marks of Female students. If there are to students have the max score, only output one.
    SELECT TOP(1) *
    FROM tableGiven
    WHERE SEX = 'F'

--16.
SELECT * 
FROM tableGiven
ORDER BY SEX, MARKS DESC

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
