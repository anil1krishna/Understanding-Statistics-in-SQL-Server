/* 
How to view statistics?

**For this Demo, I am using Adventureworks2016 database.
1. Download the Adventureworks2016 database OLTP Vesion from below location:
https://docs.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver15&tabs=ssms
2. I then added more data to these database tables
3. You can see additional table names Sales. SalesorderHeaderEnlarged and 
SalesOrderDetailEnlarged
4. You can create and add data to these tables by using the Jonathan Kehayias script from below link:
https://www.sqlskills.com/blogs/jonathan/enlarging-the-adventureworks-sample-databases/
*/


USE [adventureworks2016Big]
GO

/*
To check the Indexes and Index keys on the table
*/

EXEC sp_helpindex 'Sales.SalesOrderHeaderEnlarged';
GO

/*
sys.stats- To check all the stats in a table along with the stats_id
*/

SELECT 
	OBJECT_NAME(object_id) AS [Table], 
	name, 
	stats_id, 
	auto_created, 
	user_created
FROM sys.stats
WHERE object_id = OBJECT_ID(N'Sales.SalesOrderHeaderEnlarged');
GO


/*
	sp_helpstats (deprecated)
*/
EXEC sp_helpstats 'Sales.SalesOrderHeaderEnlarged', 'ALL';
GO

/*
	To view Statistics on specific Index
*/
DBCC SHOW_STATISTICS ('Sales.SalesOrderHeaderEnlarged', IX_SalesOrderHeaderEnlarged_CustomerID);
GO


/*
	For the latest versions of sql server 2016 and higher
*/

SELECT *
FROM sys.dm_db_stats_properties(OBJECT_ID('Sales.SalesOrderHeaderEnlarged'), 4);
GO

SELECT *
FROM sys.dm_db_stats_histogram(OBJECT_ID('Sales.SalesOrderHeaderEnlarged'), 4);
GO

/*
	Histogram shows  EQ_ROWS 2156 values for CustomerID 11091
*/
SELECT CustomerID, OrderDate
FROM [Sales].[SalesOrderHeaderEnlarged]
WHERE CustomerID = 11091;
GO


/*
	To view Statistics on specific Index
*/
DBCC SHOW_STATISTICS ('Sales.SalesOrderHeaderEnlarged', IX_SalesOrderHeaderEnlarged_CustomerID);
GO


/*
	Check to see with a value 11225 that is not in the histogram
	Histogram estimates 264 values for CustomerIDs between 11223 and 11276
*/
SELECT CustomerID, OrderDate
FROM [Sales].[SalesOrderHeaderEnlarged]
WHERE CustomerID = 11225;
GO

/*
	Using the local variable uses the (total number of row * density)
*/
DECLARE @CustomerID INT
SET @CustomerID = 11091

SELECT CustomerID, OrderDate
FROM [Sales].[SalesOrderHeaderEnlarged]
WHERE CustomerID = @CustomerID;
GO

--check stats
DBCC SHOW_STATISTICS ('Sales.SalesOrderHeaderEnlarged', IX_SalesOrderHeaderEnlarged_CustomerID);
GO


/*
	SQL Server doesn't know the value for the CustomerID at the optimization time and so
	it will have to go with the density vector
	Estimate here is 126
	Density vector is 5.230399E-05

*/
SELECT 2422805*5.230399E-05




/*
	Local Variables with no equality
*/
DECLARE @CustomerID INT
SET @CustomerID = 11091

SELECT CustomerID, OrderDate
FROM [Sales].[SalesOrderHeaderEnlarged]
WHERE CustomerID < @CustomerID;
GO


/*
	Estimate will be of 30% of the total number of rows 
	Estimate is 726842
*/
SELECT 2422805*0.30


/*
	If the code is converted to a Stored procedure
*/

CREATE OR ALTER PROCEDURE Sales.SalesHeaderData 
	@CustomerID INT
AS
BEGIN
	SELECT CustomerID, OrderDate
	FROM [Sales].[SalesOrderHeaderEnlarged]
	WHERE CustomerID = @CustomerID;
END
GO

SET STATISTICS IO, TIME ON;
GO

EXEC Sales.SalesHeaderData @CustomerID = 12268;
GO

EXEC Sales.SalesHeaderData @CustomerID = 11091;
GO



/*
	If you declare salespersonid as variable and 
	use the customerid variable inside the stored procedure to get the results  
	estimate will check the density vector
*/
CREATE OR ALTER PROCEDURE Sales.SalesHeaderData 
	@PersonID INT
AS
BEGIN

	DECLARE @CustomerID INT

	SELECT @CustomerID = CustomerID
	FROM [Sales].[SalesOrderHeaderEnlarged]
	WHERE SalesPersonID = @PersonID

	SELECT CustomerID, OrderDate
	FROM [Sales].[SalesOrderHeaderEnlarged]
	WHERE CustomerID = @CustomerID
END
GO

EXEC Sales.SalesHeaderData  @PersonID = 274;
GO


/*
	Giving the range of date values
*/
SELECT
	oh.[CustomerID],
	oh.[OrderDate],
	oh.[ShipMethodID],
	od.[OrderQty],
	od.[ProductID]
FROM [Sales].[SalesOrderHeaderEnlarged] oh
JOIN 
[Sales].[SalesOrderDetailEnlarged] od
ON oh.SalesOrderID = od.salesOrderID
WHERE [OrderDate] >= '2012-01-01 00:00:00.000' 
	AND OrderDate <= '2012-01-30 23:59:59.997'
ORDER BY [OrderDate]
OPTION (RECOMPILE);
GO

SELECT
	oh.[CustomerID],
	oh.[OrderDate],
	oh.[ShipMethodID],
	od.[OrderQty],
	od.[ProductID]
FROM [Sales].[SalesOrderHeaderEnlarged] oh
JOIN 
[Sales].[SalesOrderDetailEnlarged] od
ON oh.SalesOrderID = od.salesOrderID
WHERE [OrderDate] >= '2012-01-01 00:00:00.000' 
	AND OrderDate <= '2012-08-30 23:59:59.997'
ORDER BY [OrderDate]
OPTION (RECOMPILE);
GO


/*
	row and page count
*/
SELECT 
	OBJECT_NAME([p].[object_id]) [TableName], 
	[si].[name] [IndexName], 
	[au].[type_desc] [Type], 
	[p].[rows] [RowCount], 
	[au].total_pages [PageCount]
FROM [sys].[partitions] [p]
JOIN [sys].[allocation_units] [au] ON [p].[partition_id] = [au].[container_id]
JOIN [sys].[indexes] [si] 
	ON [p].[object_id] = [si].object_id 
	AND [p].[index_id] = [si].[index_id]
WHERE [p].[object_id] = OBJECT_ID(N'Sales.SalesOrderHeaderEnlarged');
GO

/*
	Decrease row count and see how optimizer will behave
*/

UPDATE STATISTICS  [Sales].[SalesOrderHeaderEnlarged] PK_SalesOrderHeaderEnlarged_SalesOrderID
	with ROWCOUNT=1000000


/*
  run again
*/

SELECT
	oh.[CustomerID],
	oh.[OrderDate],
	oh.[ShipMethodID],
	od.[OrderQty],
	od.[ProductID]
FROM [Sales].[SalesOrderHeaderEnlarged] oh
JOIN 
[Sales].[SalesOrderDetailEnlarged] od
ON oh.SalesOrderID = od.salesOrderID
WHERE [OrderDate] >= '2012-01-01 00:00:00.000' 
	AND OrderDate <= '2012-01-30 23:59:59.997'
ORDER BY [OrderDate]
OPTION (RECOMPILE);
GO

SELECT
	oh.[CustomerID],
	oh.[OrderDate],
	oh.[ShipMethodID],
	od.[OrderQty],
	od.[ProductID]
FROM [Sales].[SalesOrderHeaderEnlarged] oh
JOIN 
[Sales].[SalesOrderDetailEnlarged] od
ON oh.SalesOrderID = od.salesOrderID
WHERE [OrderDate] >= '2012-01-01 00:00:00.000' 
	AND OrderDate <= '2012-12-30 23:59:59.997'
ORDER BY [OrderDate]
OPTION (RECOMPILE);
GO

/*
	cleaning up the stats
*/
DBCC UPDATEUSAGE
    (adventureworks2016Big, 'Sales.SalesOrderHeaderEnlarged', PK_SalesOrderHeaderEnlarged_SalesOrderID)
	  WITH COUNT_ROWS;



