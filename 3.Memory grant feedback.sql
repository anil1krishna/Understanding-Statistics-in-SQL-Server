 ---Memory grant feedback
/*
	Disabling memory grant feedback
*/
Use AdventureWorks2016Big
go

ALTER DATABASE SCOPED CONFIGURATION 
	SET ROW_MODE_MEMORY_GRANT_FEEDBACK = OFF;
GO

DROP PROCEDURE IF EXISTS [Sales].[customerdata_OrderDate];
GO

CREATE OR ALTER PROCEDURE [Sales].[customerdata_OrderDate]
	@StartDate DATETIME,
	@EndDate DATETIME
AS
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
WHERE [OrderDate] >= @StartDate 
	AND [OrderDate] <= @EndDate
ORDER BY [OrderDate];
GO

/*
	Check memory grant
*/
DECLARE @StartDate DATETIME = '2012-01-01'
DECLARE @EndDate DATETIME = '2012-01-08'

EXEC [Sales].[customerdata_OrderDate] @StartDate, @EndDate;
GO

DECLARE @StartDate DATETIME = '2012-01-01'
DECLARE @EndDate DATETIME = '2012-12-30'

EXEC [Sales].[customerdata_OrderDate] @StartDate, @EndDate;
GO

DECLARE @StartDate DATETIME = '2012-01-01'
DECLARE @EndDate DATETIME = '2013-03-31'

EXEC [Sales].[customerdata_OrderDate] @StartDate, @EndDate;
GO


/*
	Enabling memory grant feedback
*/
ALTER DATABASE SCOPED CONFIGURATION SET ROW_MODE_MEMORY_GRANT_FEEDBACK = ON;
GO


/*
	Run again
*/
DECLARE @StartDate DATETIME = '2012-01-01'
DECLARE @EndDate DATETIME = '2012-01-08'

EXEC [Sales].[customerdata_OrderDate] @StartDate, @EndDate;
GO

DECLARE @StartDate DATETIME = '2012-01-01'
DECLARE @EndDate DATETIME = '2012-12-30'

EXEC [Sales].[customerdata_OrderDate] @StartDate, @EndDate;
GO

DECLARE @StartDate DATETIME = '2012-01-01'
DECLARE @EndDate DATETIME = '2013-03-31'

EXEC [Sales].[customerdata_OrderDate] @StartDate, @EndDate;
GO
-------------------------------------------------------

DECLARE @StartDate DATETIME = '2012-01-01'
DECLARE @EndDate DATETIME = '2013-03-31'

EXEC [Sales].[customerdata_OrderDate] @StartDate, @EndDate;
GO

DECLARE @StartDate DATETIME = '2012-01-01'
DECLARE @EndDate DATETIME = '2013-03-31'

EXEC [Sales].[customerdata_OrderDate] @StartDate, @EndDate;
GO

DECLARE @StartDate DATETIME = '2012-01-01'
DECLARE @EndDate DATETIME = '2013-03-31'

EXEC [Sales].[customerdata_OrderDate] @StartDate, @EndDate;
GO

DECLARE @StartDate DATETIME = '2012-01-01'
DECLARE @EndDate DATETIME = '2013-03-31'

EXEC [Sales].[customerdata_OrderDate] @StartDate, @EndDate;
GO




