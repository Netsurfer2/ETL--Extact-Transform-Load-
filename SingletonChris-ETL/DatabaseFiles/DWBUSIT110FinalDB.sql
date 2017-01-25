
/*
Name:	    Christopher Singleton	                                                                      06/17/2015
Professor:  Randal Root 
Course:     BUSIT 110	
Assignment: Module DWBUSITFINAL
Quarter:    Spring 2015	
*/
--********************DataBase Creation***********************--
--****************** [DWBUSIT110FinalDB] *********************--
-- This file will drop and create the [DWBUSIT110FinalDB]
-- database, with all its objects. 
--************************************************************--

--Notes to Remember:
--========================Set Me As The Only User Working============================
/* Note: Before you set the database to SINGLE_USER, verify that the AUTO_UPDATE_STATISTICS_ASYNC option is set to OFF. 
   When this option is set to ON, the background thread that is used to update statistics takes a connection 
   against the database, and you will be unable to access the database in single-user mode. 
  https://support.microsoft.com/en-us/kb/2754171

  Check to see which databases have UPDATE STATISTICS_ASYNC set to enabled (ON) using the script below:

  SELECT name, is_auto_update_stats_on, is_auto_update_stats_async_on 
  FROM sys.databases

  https://msdn.microsoft.com/en-us/library/ms178534.aspx

  Shows Settings:
  SELECT name, user_access_desc, is_read_only, state_desc, recovery_model_desc
  FROM sys.databases
*/
--http://www.mssqltips.com/sqlservertip/2904/sql-servers-auto-update-statistics-async-option/

--   SET AUTO_UPDATE_STATISTICS_ASYNC OFF --Add this Setting if Needed, before setting to single user mode.
--Remember to check and see if it is Set to ON in the Database First.

USE [master]

If Exists (Select Name from SysDatabases Where Name = 'DWBUSIT110FinalDB')
  Begin
   ALTER DATABASE DWBUSIT110FinalDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE
   DROP DATABASE DWBUSIT110FinalDB
  End
Go
Create Database DWBUSIT110FinalDB;
Go
USE DWBUSIT110FinalDB;
Go

--********************************************************************--
-- Create the Tables
--********************************************************************--
/****** [dbo].[DimStudents] ******/

CREATE TABLE DimStudents
      (StudentKey int PRIMARY KEY Identity(1,1) --Set to row 1    --<----Added for Fact Table.
	  ,StudentID int 
	  ,StudentFullName nVarchar(255) 
	  ,StudentEmail nVarchar(100) 
	  )  
GO	 
/****** [dbo].[DimClasses] ******/

CREATE TABLE DimClasses
     (ClassKey int PRIMARY KEY Identity(1,1) --Set to row 1    --<-----Added
	 ,ClassID int 
	 ,ClassName nVarchar(100) 
	 ,CurrentClassPrice decimal(18,2)   
	 )
GO

/****** [dbo].[DimDates] ******/

CREATE TABLE DimDates(
	[DateKey] [int] PRIMARY KEY Identity(1,1) --Set to row 1    --<-----Added
	,[FullDate] [datetime] NOT NULL
	,[FullDateName] nvarchar(50) NULL
	,[MonthID] [int] NOT NULL
	,[MonthName] nvarchar(50) NOT NULL
	,[YearID] int NOT NULL
	,[YearName] nvarchar (50) NOT NULL
	)
--	PRIMARY KEY ([DateKey] )
--)
Go

/****** [dbo].[FactEnrollments] ******/

CREATE TABLE FactEnrollments
      ([EnrollmentID] int PRIMARY KEY Identity(1,1)  --Used for Enrollment (PK)
	  ,[EnrollmentDateKey] int                       --Used for DimDates (FK)
	  ,[StudentKey] int                              --Needed for DimStudents (FK)
	  ,[ClassKey] int                                --Needed for DimClasses (FK)
	  ,[ActualEnrollmentPrice] decimal (18,2)        --Measure
	  )
GO

--********************************************************************--
-- Create the FOREIGN KEY CONSTRAINTS
--********************************************************************--

ALTER TABLE [dbo].[FactEnrollments]
    ADD CONSTRAINT [FK_FactEnrollments_DimStudents]
    FOREIGN KEY ([StudentKey])
    REFERENCES [dbo].[DimStudents] ([StudentKey])
	ON UPDATE  NO ACTION ON DELETE  NO ACTION
GO

ALTER TABLE [dbo].[FactEnrollments]
    ADD CONSTRAINT [FK_FactEnrollments_DimClasses]
    FOREIGN KEY ([ClassKey])
    REFERENCES [dbo].[DimClasses] ([ClassKey])
	ON UPDATE  NO ACTION ON DELETE  NO ACTION
GO

ALTER TABLE [dbo].[FactEnrollments]
    ADD CONSTRAINT [FK_FactEnrollments_DimDates]
    FOREIGN KEY ([EnrollmentDateKey])
    REFERENCES [dbo].[DimDates] ([DateKey])
	ON UPDATE  NO ACTION ON DELETE  NO ACTION
GO

--********************************************************************--
-- Create Reporting Views
--********************************************************************--

Create View StudentEnrollments
AS
SELECT  
  FactEnrollments.EnrollmentID
, DimDates.FullDate
, DimStudents.StudentFullName
, DimClasses.ClassName
, DimClasses.CurrentClassPrice                      
, FactEnrollments.ActualEnrollmentPrice
FROM DimClasses 
INNER JOIN FactEnrollments 
  ON DimClasses.ClassKey = FactEnrollments.ClassKey 
INNER JOIN DimDates 
  ON FactEnrollments.EnrollmentDateKey = DimDates.DateKey  
INNER JOIN DimStudents 
  ON FactEnrollments.StudentKey = DimStudents.StudentKey
Go

--********************************************************************--
-- Review the results of this script
--********************************************************************--
Select 'Database Created' AS DWBUSIT110FinalDB
Select Name, xType, CrDate from SysObjects 
Where xType in ('u', 'PK', 'F')
Order By xType desc, Name

--=========================Backup Database to Location========================
/* --BackUp if needed:
BACKUP DATABASE DWAdventureWorks_Level01 
TO DISK = N'C:\_BISolutions\PublicationsIndustries\DWBUSIT110FinalDB.bak'
WITH INIT
*/
--=========================Restore Database to Location=======================
--Use to restore the Database if needed. 
/*
RESTORE DATABASE DWAdventureWorks_Level01
FROM DISK = N'C:\_BISolutions\PublicationsIndustries\DWBUSIT110FinalDB.mdf'
GO
*/

--===Set The Database AUTO_UPDATE_STATISTICS_ASYNC ON (If it was originally set to ON)===

	--ALTER DATABASE [DWBUSIT110FinalDB] SET AUTO_UPDATE_STATISTICS_ASYNC ON  --Add this if needed.