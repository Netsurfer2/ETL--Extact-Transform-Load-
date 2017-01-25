/*
Name:	    Christopher Singleton	                                                                      06/17/2015
Professor:  Randal Root 
Course:     BUSIT 110	
Assignment: Module DWBUSITFINAL
Quarter:    Spring 2015	
*/
--******************SQL ETL CODE CREATION*********************--
--****************** [DWBUSIT110FinalDB] *********************--
-- This file contains code used to clear and fill 
-- the [DWBUSIT110FinalDB]database tables.
--********************************************************************--
	 
USE DWBUSIT110FinalDB;
GO

--********************************************************************--
-- Drop Foreign Keys Constraints
--********************************************************************--

ALTER TABLE [dbo].[FactEnrollments] 
        DROP CONSTRAINT [FK_FactEnrollments_DimStudents]
ALTER TABLE [dbo].[FactEnrollments] 
        DROP CONSTRAINT  [FK_FactEnrollments_DimClasses]
ALTER TABLE [dbo].[FactEnrollments] 
        DROP CONSTRAINT  [FK_FactEnrollments_DimDates]
GO

--********************************************************************--
-- Clear all tables and reset their Identity Auto Number 
--********************************************************************--

TRUNCATE TABLE 
      [DWBUSIT110FinalDB].dbo.DimStudents
TRUNCATE TABLE
	  [DWBUSIT110FinalDB].dbo.DimClasses
TRUNCATE TABLE
	  [DWBUSIT110FinalDB].dbo.DimDates
TRUNCATE TABLE
	  [DWBUSIT110FinalDB].dbo.FactEnrollments 
GO

--********************************************************************--
-- Get DimStudents Data
--********************************************************************--

USE [BUSIT110FinalDB];
GO
--=========Put Data Into the OLAP Data Warehouse DimStudents========--

INSERT INTO [DWBUSIT110FinalDB].[dbo].[DimStudents]
      (StudentID 
	  ,StudentFullName 
	  ,StudentEmail 
	  )     

--==========Select Data From the OLTP Database Table Students=========--

SELECT StudentID  = ISNULL(Students.StudentID, -1)
	  ,StudentFirstName + ' ' + StudentLastName AS StudentFullName
	  ,StudentEmail = ISNULL(Students.StudentEmail, 'Student Email Not Given')
FROM [BUSIT110FinalDB].[dbo].[Students] 
   
GO

/*--Testing:
SELECT * FROM [BUSIT110FinalDB].dbo.Students
SELECT * FROM [DWBUSIT110FinalDB].dbo.DimStudents
*/

--********************************************************************--
-- Get DimClasses Data
--********************************************************************--
--=========Put Data Into the OLAP Data Warehouse DimClasses========--

INSERT INTO [DWBUSIT110FinalDB].[dbo].[DimClasses]
     (ClassID 
	 ,ClassName 
	 ,CurrentClassPrice 
	 )

--==========Select Data From the OLTP Database Table Classes=========--

SELECT ClassID = ISNULL(Classes.ClassID, -1)
	  ,ClassName = ISNULL(Classes.ClassName, 'NO Class Name Given')
	  ,CurrentClassPrice = CAST(CurrentClassPrice as decimal(18,2))   	 
FROM [BUSIT110FinalDB].[dbo].[Classes]

GO

/*--Checking:

SELECT * FROM [DWBUSIT110FinalDB].[dbo].DimClasses
SELECT * FROM [BUSIT110FinalDB].[dbo].Classes

*/

--********************************************************************--
-- Get DimDates Data
--********************************************************************--
-- Since the date table has no associated source table we can fill the data
-- using a SQL script 

--==============SET IDENTITY_INSERT to ON============--

SET IDENTITY_INSERT [DWBUSIT110FinalDB].[dbo].DimDates ON

INSERT INTO [DWBUSIT110FinalDB].[dbo].[DimDates] 
( [DateKey], [FullDate], [FullDateName], [MonthID], [MonthName], [YearID], [YearName] )
Values
  ( -1, Cast('01/01/1900' as datetime), 'Unknown Day', -1, 'Unknown Month', -1 , 'Unknown Year' )
, ( -2, Cast('01/02/1900' as datetime), 'Corrupt Day', -2, 'Corrupt Month', -2, 'Corrupt Year' )
--Go
-- Create variables to hold the start and end date
DECLARE @StartDate datetime = '01/01/2012'
DECLARE @EndDate datetime = '12/31/2013' 

-- Use a while loop to add dates to the table
DECLARE @DateInProcess datetime
SET @DateInProcess = @StartDate

WHILE @DateInProcess <= @EndDate
 BEGIN

--==============SET IDENTITY_INSERT to ON============--

SET IDENTITY_INSERT [DWBUSIT110FinalDB].[dbo].DimDates ON

 -- Add a row into the date dimension table for this date
 INSERT INTO [DWBUSIT110FinalDB].[dbo].DimDates 
 ( [DateKey], [FullDate], [FullDateName], [MonthID], [MonthName], [YearID], [YearName] )
 VALUES (
    Cast(Convert(nVarchar(50), @DateInProcess, 112) as int) -- [DateKey] = 20050101 to 20101231
  , @DateInProcess -- [FullDate] = '2005-01-01 00:00:00.000'
  , DateName(weekday, @DateInProcess ) + ', ' + DateName(mm, @DateInProcess ) + ' ' +  Convert(nVarchar(50), @DateInProcess, 110) -- [DateKey] = 20050101 to 20101231
  , Month( @DateInProcess ) + (Year(@DateInProcess ) * 100)  -- [MonthID]   
  , DateName( month, @DateInProcess ) + ' ' + Cast( Year(@DateInProcess ) as nVarchar(50) ) -- [MonthName]
  , Year( @DateInProcess ) -- [YearID] 
  , Cast( Year(@DateInProcess ) as nVarchar(50) ) -- [YearName] 
  )  
  -- Add a day and loop again
 SET @DateInProcess = DateAdd(d, 1, @DateInProcess)
--==============SET IDENTITY_INSERT to OFF============--
 SET IDENTITY_INSERT [DWBUSIT110FinalDB].[dbo].DimDates OFF
 END 
 GO

--Testing:
-- SELECT * FROM DimDates

--********************************************************************--
-- Get FactEnrollment Data
--********************************************************************--

USE [DWBUSIT110FinalDB];
GO

--============Set IDENTITY_INSERT FactEnrollments back ON=============--

SET IDENTITY_INSERT [DWBUSIT110FinalDB].[dbo].[FactEnrollments] ON
GO
--================Insert into FactEnrollments=========================--

INSERT INTO [DWBUSIT110FinalDB].[dbo].[FactEnrollments]
            (EnrollmentID
			,EnrollmentDateKey
			,StudentKey
			,ClassKey
			,ActualEnrollmentPrice					
			)

--==========Select Tables that have the data for FactEnrollments======--

SELECT        
  EnrollmentID = ISNULL(Enrollments.EnrollmentID, -1)
, DimDates.DateKey 
, DimStudents.StudentKey
, DimClasses.ClassKey
, ActualEnrollmentPrice = CAST(Enrollments.ActualEnrollmentPrice AS DECIMAL(18,2))
FROM DimClasses
INNER JOIN [BUSIT110FinalDB].[dbo].[Enrollments] 
  ON DimClasses.ClassID = [BUSIT110FinalDB].[dbo].[Enrollments].[ClassID] 
INNER JOIN DimStudents 
  ON DimStudents.StudentID = [BUSIT110FinalDB].[dbo].[Enrollments].[StudentID]
INNER JOIN DimDates 
  ON [dbo].[DimDates].[FullDate] = [BUSIT110FinalDB].[dbo].[Enrollments].[EnrollmentDate]

GO

--===================Turn IDENTITY_INSERT FactEnrollments to OFF=================--

SET IDENTITY_INSERT [DWBUSIT110FinalDB].[dbo].FactEnrollments OFF
GO

/* Checking All Tables:

SELECT * FROM [DWBUSIT110FinalDB].[dbo].DimStudents
SELECT * FROM [DWBUSIT110FinalDB].[dbo].DimClasses
SELECT * FROM [DWBUSIT110FinalDB].[dbo].DimDates
SELECT * FROM [DWBUSIT110FinalDB].[dbo].FactEnrollments

*/
--********************************************************************--
-- Replace Foreign Keys Constraints
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

--=========================Backup Database to Location========================
/*--BackUp if Needed.

BACKUP DATABASE DWBUSIT110FinalDB 
TO DISK = N'C:\_BISolutions\PublicationsIndustries\DWBUSIT110FinalDB.bak'
WITH INIT
GO
--=========================Restore Database to Location=======================
--Restore if needed. 

RESTORE DATABASE DWBUSIT110FinalDB
FROM DISK = N'C:\_BISolutions\PublicationsIndustries\DWAdventureWorks_Level01.mdf'
GO

*/

--********************************************************************--
-- Review the results of this script
--********************************************************************--

SELECT 'Database Filled' AS DWBUSIT110FinalDB
SELECT [TableName] = '[dbo].[DimClasses]' , [RowCount] = COUNT(*) FROM [dbo].[DimClasses]
SELECT [TableName] = '[dbo].[DimDates]' , [RowCount] = COUNT(*) FROM [dbo].[DimDates]
SELECT [TableName] = '[dbo].[DimStudents]' , [RowCount] = COUNT(*) FROM [dbo].[DimStudents]
SELECT [TableName] = '[dbo].[FactEnrollments]' , [RowCount] = COUNT(*) FROM [dbo].[FactEnrollments]


