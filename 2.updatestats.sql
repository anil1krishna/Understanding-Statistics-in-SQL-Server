--Updating the statistics

USE [adventureworks2016Big];
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
	cleaning up the stats
*/
DBCC UPDATEUSAGE
    (adventureworks2016Big, 'Sales.SalesOrderHeaderEnlarged', PK_SalesOrderHeaderEnlarged_SalesOrderID)
	  WITH COUNT_ROWS;

--update stats of table with default sample

UPDATE STATISTICS  [Sales].[SalesOrderHeaderEnlarged] IX_SalesOrderHeaderEnlarged_CustomerID


/*
	look at statistics of the CustomerID index
*/
DBCC SHOW_STATISTICS ('Sales.SalesOrderHeaderEnlarged',IX_SalesOrderHeaderEnlarged_CustomerID);
GO


SET STATISTICS IO, TIME ON;
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
where [CustomerID]=25250

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
where [CustomerID]=11176



SET STATISTICS IO, TIME OFF;
GO


/*
	Check statistics
*/
DBCC SHOW_STATISTICS ('Sales.SalesOrderHeaderEnlarged',IX_SalesOrderHeaderEnlarged_CustomerID);
GO


/* 
    Turning off AUTO_UPDATE_STATISTICS to OFF
*/

ALTER DATABASE  [adventureworks2016Big]
SET AUTO_UPDATE_STATISTICS OFF

/* 

Row modifications, old threshold and new threshold info

*/
SELECT  
	[sch].[name] + '.' + [so].[name] AS [TableName] ,
	[ss].[name] AS [Statistic] ,
	[sp].[last_updated] AS [StatsLastUpdated] ,
	[sp].[rows] AS [RowsInTable] ,
	[sp].[rows_sampled] AS [RowsSampled] ,
	[sp].[modification_counter] AS [RowModifications] ,
	([sp].[rows]*.20) + 500 [OldThreshold],
	SQRT([sp].[rows]*1000) [NewThreshold]
FROM [sys].[stats] [ss]
JOIN [sys].[objects] [so] 
	ON [ss].[object_id] = [so].[object_id]
JOIN [sys].[schemas] [sch] 
	ON [so].[schema_id] = [sch].[schema_id]
LEFT OUTER JOIN [sys].[indexes] AS [si] 
	ON [so].[object_id] = [si].[object_id]
	AND [ss].[name] = [si].[name]
OUTER APPLY [sys].[dm_db_stats_properties]([so].[object_id], [ss].[stats_id]) sp
WHERE [so].[object_id] = OBJECT_ID(N'Sales.SalesOrderHeaderEnlarged')
ORDER BY [ss].[stats_id];
GO

/*
	UPDATE customerID column data (890967 rows updated)
*/
UPDATE [Sales].[SalesOrderHeaderEnlarged] 
SET CustomerID = 11091
WHERE CustomerID < 16575;
GO

/*
	Looking at the execution plan
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
where [CustomerID]=11091


/*
	Enabling the auto update stats

*/
USE [master]
GO
ALTER DATABASE [adventureworks2016Big] SET AUTO_UPDATE_STATISTICS ON WITH NO_WAIT
GO



/*
	Enabling the actual execution plan
*/
USE [adventureworks2016Big];
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
where [CustomerID]=11091

/*
	Check statistics again
*/
DBCC SHOW_STATISTICS ('Sales.SalesOrderHeaderEnlarged',IX_SalesOrderHeaderEnlarged_CustomerID);
GO


/*
	How the stats updates affect procedures
*/

CREATE or ALTER PROCEDURE Sales.SalesOrderHeaderData
@CustomerID INT
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
WHERE CustomerID = @CustomerID;
GO

EXEC Sales.SalesOrderHeaderData @CustomerID = 16717
GO 10


SELECT 
	qs.execution_count, 
	qs.creation_time,
	qs.last_execution_time,
	qs.plan_generation_num,
	qs.query_hash, 
	qs.query_plan_hash, 
	qp.query_plan,
	s.text
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_query_plan (qs.plan_handle) qp
CROSS APPLY sys.dm_exec_sql_text(qs.plan_handle) s
WHERE s.text LIKE '%SalesOrderHeaderData%';


SELECT  
	[sch].[name] + '.' + [so].[name] AS [TableName] ,
	[ss].[name] AS [Statistic] ,
	[sp].[last_updated] AS [StatsLastUpdated] ,
	[sp].[rows] AS [RowsInTable] ,
	[sp].[rows_sampled] AS [RowsSampled] ,
	[sp].[modification_counter] AS [RowModifications] ,
	([sp].[rows]*.20) + 500 [OldThreshold],
	SQRT([sp].[rows]*1000) [NewThreshold]
FROM [sys].[stats] [ss]
JOIN [sys].[objects] [so] 
	ON [ss].[object_id] = [so].[object_id]
JOIN [sys].[schemas] [sch] 
	ON [so].[schema_id] = [sch].[schema_id]
LEFT OUTER JOIN [sys].[indexes] AS [si] 
	ON [so].[object_id] = [si].[object_id]
	AND [ss].[name] = [si].[name]
OUTER APPLY [sys].[dm_db_stats_properties]([so].[object_id], [ss].[stats_id]) sp
WHERE [so].[object_id] = OBJECT_ID(N'Sales.SalesOrderHeaderEnlarged')
ORDER BY [ss].[stats_id];
GO


/*
	Update > new threshold
*/
UPDATE Sales.SalesOrderHeaderEnlarged
	SET CustomerID = CustomerID + 1
WHERE CustomerID BETWEEN 16717 AND 17190;


/*
	Check the row modification counter
*/
SELECT  
	[sch].[name] + '.' + [so].[name] AS [TableName] ,
	[ss].[name] AS [Statistic] ,
	[sp].[last_updated] AS [StatsLastUpdated] ,
	[sp].[rows] AS [RowsInTable] ,
	[sp].[rows_sampled] AS [RowsSampled] ,
	[sp].[modification_counter] AS [RowModifications] ,
	([sp].[rows]*.20) + 500 [OldThreshold],
	SQRT([sp].[rows]*1000) [NewThreshold]
FROM [sys].[stats] [ss]
JOIN [sys].[objects] [so] 
	ON [ss].[object_id] = [so].[object_id]
JOIN [sys].[schemas] [sch] 
	ON [so].[schema_id] = [sch].[schema_id]
LEFT OUTER JOIN [sys].[indexes] AS [si] 
	ON [so].[object_id] = [si].[object_id]
	AND [ss].[name] = [si].[name]
OUTER APPLY [sys].[dm_db_stats_properties]([so].[object_id], [ss].[stats_id]) sp
WHERE [so].[object_id] = OBJECT_ID(N'Sales.SalesOrderHeaderEnlarged')
ORDER BY [ss].[stats_id];
GO


/*
	Run the SP and then check the execution plan
*/
EXEC Sales.SalesOrderHeaderData @CustomerID = 16717


/*
	Stats gets updated
*/
DBCC SHOW_STATISTICS ('Sales.SalesOrderHeaderEnlarged', IX_SalesOrderHeaderEnlarged_CustomerID);
GO

/*
	Check if Stored procedure gets recompiled
*/
SELECT 
	qs.execution_count, 
	qs.creation_time,
	qs.last_execution_time,
	qs.plan_generation_num,
	qs.query_hash, 
	qs.query_plan_hash, 
	qp.query_plan,
	s.text
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_query_plan (qs.plan_handle) qp
CROSS APPLY sys.dm_exec_sql_text(qs.plan_handle) s
WHERE s.text LIKE '%Sales.SalesOrderHeaderEnlarged%';


--SELECT DB_ID('AdventureWorks2016Big') AS Database_ID;

/*
	How to check if auto stats caused plans to recompile and change execution plan
*/
CREATE EVENT SESSION [Track_AutoStatsUpdates1] 
	ON SERVER 
ADD EVENT sqlserver.auto_stats(
    WHERE (
		[database_id]=(7)) /* database id */
		),
ADD EVENT sqlserver.sql_statement_recompile(
		SET collect_object_name=(1),collect_statement=(1)
    WHERE (
		[recompile_cause]=(2)
		)
	)
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,
TRACK_CAUSALITY=ON,STARTUP_STATE=OFF)
GO

ALTER EVENT SESSION [Track_AutoStatsUpdates1]
	ON SERVER
	STATE = START;
GO


/*
	Open extended event live view
*/

UPDATE Sales.SalesOrderHeaderEnlarged
	SET CustomerID = CustomerID + 1
WHERE CustomerID BETWEEN 17633 AND 17896;

UPDATE Sales.SalesOrderHeaderEnlarged
	SET CustomerID = CustomerID + 1
WHERE CustomerID BETWEEN 16717 AND 17187;



/*
	check for how much data has changed
*/
SELECT  
	[sch].[name] + '.' + [so].[name] AS [TableName] ,
	[ss].[name] AS [Statistic] ,
	[sp].[last_updated] AS [StatsLastUpdated] ,
	[sp].[rows] AS [RowsInTable] ,
	[sp].[rows_sampled] AS [RowsSampled] ,
	[sp].[modification_counter] AS [RowModifications] ,
	[sp].[steps] AS [HistogramSteps],
	[ss].[no_recompute],
	([sp].[rows]*.20) + 500 [OldThreshold],
	SQRT([sp].[rows]*1000) [NewThreshold]
FROM [sys].[stats] [ss]
JOIN [sys].[objects] [so] 
	ON [ss].[object_id] = [so].[object_id]
JOIN [sys].[schemas] [sch] 
	ON [so].[schema_id] = [sch].[schema_id]
LEFT OUTER JOIN [sys].[indexes] AS [si] 
	ON [so].[object_id] = [si].[object_id]
	AND [ss].[name] = [si].[name]
OUTER APPLY [sys].[dm_db_stats_properties]([so].[object_id], [ss].[stats_id]) sp
WHERE [so].[object_id] = OBJECT_ID(N'Sales.SalesOrderHeaderEnlarged')
ORDER BY [ss].[stats_id];
GO

/*
	run the Stored procedure again
*/
EXEC Sales.SalesOrderHeaderData @CustomerID = 23867



/*
	Stop the session
*/
ALTER EVENT SESSION [Track_AutoStatsUpdates1]
	ON SERVER
	STATE = STOP;
GO


