USE AdventureWorks
GO

-- 1. Write a query that retrieves the columns ProductID, Name, 
-- Color and ListPrice from the Production.Product table, with no filter. 
SELECT ProductID, Name, Color, ListPrice
FROM Production.Product;

-- 2. Write a query that retrieves the columns ProductID, Name, Color and ListPrice 
-- from the Production.Product table, excludes the rows that ListPrice is 0.
SELECT ProductID, Name, Color, ListPrice
FROM Production.Product
WHERE ListPrice != 0;

-- 3. Write a query that retrieves the columns ProductID, Name, Color and ListPrice 
-- from the Production.Product table, the rows that are rows that are NULL for the Color column.
SELECT ProductID, Name, Color, ListPrice
FROM Production.Product
WHERE Color is NULL;

-- 4. Write a query that retrieves the columns ProductID, Name, Color and ListPrice 
-- from the Production.Product table, the rows that are not NULL for the Color column.
SELECT ProductID, Name, Color, ListPrice
FROM Production.Product
WHERE Color is NOT NULL;

-- 5. Write a query that retrieves the columns ProductID, Name, Color and ListPrice 
-- from the Production.Product table, the rows that are not NULL for the column Color, 
-- and the column ListPrice has a value greater than zero.
SELECT ProductID, Name, Color, ListPrice
FROM Production.Product
WHERE Color is NOT NULL AND ListPrice >= 0;

-- 6. Write a query that concatenates the columns Name and Color from the Production.Product 
-- table by excluding the rows that are null for color.
SELECT Name, Color, Name + ' ' + Color AS "NewColumn"
FROM Production.Product
WHERE Color is NOT NULL;

-- 7.
SELECT 'NAME: ' + Name + '  --  ' + 'COLOR: '  + Color AS "Name And Color"
FROM Production.Product
WHERE Color is NOT NULL;

-- 8. Write a query to retrieve the to the columns ProductID and Name from the 
-- Production.Product table filtered by ProductID from 400 to 500
SELECT ProductID, Name
FROM Production.Product
WHERE ProductID BETWEEN 400 AND 500;

-- 9. Write a query to retrieve the to the columns  ProductID, Name and color from 
-- the Production.Product table restricted to the colors black and blue
SELECT ProductID, Name, Color
FROM Production.Product
WHERE Color IN ('blue', 'black');

-- 10. Write a query to generate a report on products that begins with the letter S. 
SELECT ProductID, Name, Color, ListPrice
FROM Production.Product
WHERE Name LIKE 'S%';

-- 11. Write a query that retrieves the columns Name and ListPrice from the Production.Product table. 
-- Your result set should look something like the following. Order the result set by the Name column. 
SELECT Name, ListPrice
FROM Production.Product
WHERE Name LIKE 'S%'
ORDER BY Name;

-- 12. Write a query that retrieves the columns Name and ListPrice from the Production.Product table. 
-- Your result set should look something like the following. Order the result set by the Name column. 
-- The products name should start with either 'A' or 'S'
SELECT Name, ListPrice
FROM Production.Product
WHERE Name LIKE '[A,S]%'
ORDER BY Name;

-- 13. Write a query so you retrieve rows that have a Name that begins with the letters SPO, 
-- but is then not followed by the letter K. After this zero or more letters can exists. 
-- Order the result set by the Name column.
SELECT *
FROM Production.Product
WHERE Name LIKE '[S,P,O][^K]%'
ORDER BY Name;

-- 14. Write a query that retrieves unique colors from the table Production.Product. 
-- Order the results  in descending  manner
SELECT DISTINCT Color
FROM Production.Product
ORDER BY Color DESC;

-- 15. Write a query that retrieves the unique combination of columns ProductSubcategoryID and 
-- Color from the Production.Product table. Format and sort so the result set accordingly to the 
-- following. We do not want any rows that are NULL.in any of the two columns in the result.

SELECT DISTINCT ProductSubcategoryID, Color
FROM Production.Product
WHERE ProductSubcategoryID is NOT NULL AND Color is NOT NULL
ORDER BY ProductSubcategoryID, Color;

-- 16.
SELECT ProductSubCategoryID
      , LEFT([Name],35) AS [Name]
      , Color, ListPrice 
FROM Production.Product
WHERE Color IN ('Red','Black') 
      AND ListPrice BETWEEN 1000 AND 2000 
      AND ProductSubCategoryID = 1
ORDER BY ProductID


