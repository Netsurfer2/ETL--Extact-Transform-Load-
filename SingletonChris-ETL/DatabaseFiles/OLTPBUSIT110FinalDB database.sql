USE [master]
If Exists (Select Name from SysDatabases Where Name = 'BUSIT110FinalDB')
  Begin
   ALTER DATABASE BUSIT110FinalDB SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
   DROP DATABASE BUSIT110FinalDB
  End
Go
Create Database BUSIT110FinalDB;
Go
USE BUSIT110FinalDB;
Go

--( Make the Tables )--
Create Table Students 
  ( StudentID int Identity,StudentFirstName nVarchar(50), StudentLastName nVarchar(50), StudentEmail nVarchar(100) Primary Key(StudentID) );
Go
Create Table Classes 
  ( ClassID int Identity, ClassName nVarchar(100), CurrentClassPrice decimal(18,2) Primary Key(ClassID) );
Go
Create Table Enrollments
  ( EnrollmentID int Identity
  , EnrollmentDate datetime
  , StudentID int
  , ClassID int
  , ActualEnrollmentPrice decimal(18,2)
  , Primary Key(EnrollmentID, EnrollmentDate, StudentId, ClassID )
  );
Go

--( Make the Foreign Key Constraints )--
Alter Table Enrollments Add Constraint fkEnrollmentsToStudents
  Foreign Key([StudentID]) References Students(StudentID)
Alter Table Enrollments Add Constraint fkEnrollmentsToClasses
  Foreign Key([ClassID]) References Classes(ClassID)

--( Add Some Data )--
Insert Into Students (StudentFirstName, StudentLastName, StudentEmail)
  Values ('Bob', 'Smith', 'BSmith@Google.com'), ('Sue', 'Jones','SueJones@Hotmail.com');
Go
Insert Into Classes (ClassName, CurrentClassPrice)
  Values ('CSharp Level 1', 499), ('CSharp Level 2', 499);
Go
Insert Into Enrollments(EnrollmentDate, StudentID, ClassID, ActualEnrollmentPrice )
  Values ('2012-01-01', 1, 1, 499), ('2012-01-01',2,1, 499 ), ('2012-01-02', 2, 2, 399);
Go
Go


--( Review the current data )--
Select * From [dbo].[Classes];
Select * From [dbo].[Students];
Select * From [dbo].[Enrollments];

