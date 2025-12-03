-- Create Employees table 
CREATE TABLE Employees ( 
    EmployeeID INT PRIMARY KEY, 
    FirstName NVARCHAR(50), 
    LastName NVARCHAR(50), 
    HireDate DATE, 
    DepartmentID INT 
); 
GO 
 -- Create Departments table 
CREATE TABLE Departments ( 
    DepartmentID INT PRIMARY KEY, 
    DepartmentName NVARCHAR(100) 
); 
GO 
-- Create Projects table 
CREATE TABLE Projects ( 
    ProjectID INT PRIMARY KEY, 
    ProjectName NVARCHAR(100), 
    StartDate DATE, 
    EndDate DATE 
); 
GO 
 
-- Create Assignments table 
CREATE TABLE Assignments ( 
    AssignmentID INT PRIMARY KEY, 
    EmployeeID INT, 
    ProjectID INT, 
    AssignmentDate DATE, 
    Role NVARCHAR(50), 
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID), 
    FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID) 
); 
GO 
-- Insert data into Departments table 
INSERT INTO Departments (DepartmentID, DepartmentName) 
VALUES 
(1, 'Human Resources'), 
(2, 'Engineering'), 
(3, 'Marketing'); 
GO 
 
-- Insert data into Employees table 
INSERT INTO Employees (EmployeeID, FirstName, LastName, HireDate, DepartmentID) 
VALUES 
(1, 'Alice', 'Johnson', '2020-01-15', 2), 
(2, 'Bob', 'Smith', '2019-02-20', 1), 
(3, 'Charlie', 'Brown', '2021-03-25', 3); 
GO 
 
-- Insert data into Projects table 
INSERT INTO Projects (ProjectID, ProjectName, StartDate, EndDate) 
VALUES 
(101, 'Project Alpha', '2023-01-01', '2023-12-31'), 
(102, 'Project Beta', '2023-02-01', '2023-11-30'); 
GO 
 
-- Insert data into Assignments table 
INSERT INTO Assignments (AssignmentID, EmployeeID, ProjectID, AssignmentDate, Role) 
VALUES 
(1, 1, 101, '2023-01-10', 'Developer'), 
(2, 2, 102, '2023-02-15', 'Manager'), 
(3, 3, 101, '2023-03-20', 'Tester'); 
GO 

--1.Create a stored procedure named GetProjectAssignments that retrieves all assignments for a specific project, including employee details and role. 

CREATE PROCEDURE GetProjectAssignments
@ProjectID INT
AS
BEGIN
    SELECT  a.AssignmentID, a.AssignmentDate, a.ProjectID,e.Firstname , e.Lastname, e.Hiredate , e.DepartmentID, d.DepartmentName, a.Role
    FROM Assignments a Join Employees e on a.EmployeeID= e.EmployeeID
	Join Departments d on e.DepartmentID= d.DepartmentID where ProjectID =@ProjectID ;
END;
GO

EXEC GetProjectAssignments @ProjectID=101;

--2.Create a stored procedure named UpdateProjectEndDate that updates the end date of a project and logs the change in a new table ProjectLog.

create table ProjectLog(
LogID INT Primary key Identity(1,1),
ProjectID INT,
EndDate DATE ,
FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID));

CREATE PROCEDURE UpdateProjectEndDate
    @ProjectID INT,
    @UpdatedEndDate DATE
AS
BEGIN
    UPDATE Projects
    SET EndDate = @UpdatedEndDate
    WHERE ProjectID = @ProjectID;

 Insert into ProjectLog (ProjectID, EndDate)
    values (@ProjectID, @UpdatedEndDate);
END;
GO
select * from projects;
select * from ProjectLog;
EXEC UpdateProjectEndDate @ProjectID = 101, @UpdatedEndDate = '2024-09-21';

--3.Create a stored procedure named GetDepartmentEmployeeCount that retrieves the number of employees in each department. 

CREATE PROCEDURE GetDepartmentEmployeeCount 
@DepartmentID INT
AS
BEGIN
Select count(EmployeeID) as NoOfEmployees, d.DepartmentName from Employees e join Departments d ON e.DepartmentID= d.DepartmentID
where e.DepartmentID= @DepartmentID
group by d.DepartmentName;
END;
GO

EXEC GetDepartmentEmployeeCount @DepartmentID= 2;

--4.Create a stored procedure named InsertNewEmployee that inserts a new employee and their initial assignment within a transaction 
CREATE PROCEDURE InsertNewEmployee
 @EmployeeID INT,@FirstName NVARCHAR(50),@LastName NVARCHAR(50),@HireDate DATE,
 @DepartmentID INT,@AssignmentID INT,@ProjectID INT,@AssignmentDate DATE,@Role NVARCHAR(50)
AS
BEGIN
BEGIN TRANSACTION;
BEGIN TRY
Insert into Employees (EmployeeID ,FirstName, LastName, HireDate, DepartmentID)
Values (@EmployeeID, @FirstName, @LastName, @HireDate, @DepartmentID);
Insert into Assignments (AssignmentID,EmployeeID, ProjectID, AssignmentDate, Role)
Values (@AssignmentID,@EmployeeID, @ProjectID, @AssignmentDate, @Role);
COMMIT TRANSACTION;
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION;
DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
 Select  @ErrorMessage = ERROR_MESSAGE(),@ErrorSeverity = ERROR_SEVERITY(),@ErrorState = ERROR_STATE();
RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH
END;
GO
Select * from Employees;
EXEC InsertNewEmployee @EmployeeID = 4, @FirstName = 'Wonder', @LastName = 'Woman', @HireDate = '2024-08-09', @DepartmentID = 2, @ProjectID = 102, @AssignmentID =4,
 @AssignmentDate = '2024-09-10', @Role = 'Developer';
select * from Assignments;
select * from Employees;

--5.Create a stored procedure named GetEmployeesWithMultipleAssignments that retrieves employees who have more than one assignment. 

update Assignments set EmployeeID= 1 where AssignmentID=4;
CREATE PROCEDURE GetEmployeesWithMultipleAssignments
AS 
BEGIN
Select Count(a.AssignmentID) as CountOfAssignments,e.EmployeeID,e.FirstName, e.LastName from Employees e 
Join Assignments a ON e.EmployeeID= a.EmployeeID 
Group by e.EmployeeID,e.FirstName, e.LastName 
Having Count(a.AssignmentID)>1;
END;
GO 

EXEC GetEmployeesWithMultipleAssignments;

--6.Create a stored procedure named UpdateEmployeeDepartment that updates an employee's department and logs the change in a new table EmployeeLog. 
CREATE TABLE EmployeeLog (
LogID INT Primary Key Identity(1,1),
EmployeeID INT,
OldDeptID INT,
UpdatedDeptID INT,
ChangeDate Date,
FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID));

CREATE PROCEDURE UpdateEmployeeDepartment
@EmployeeID INT,
@UpdatedDeptID INT
AS
BEGIN
DECLARE @OldDeptID INT;
SELECT @OldDeptID = DepartmentID From Employees Where EmployeeID = @EmployeeID;

IF @OldDeptID IS NULL
BEGIN
RAISERROR ('Employee not found.', 16, 1);
RETURN;
END

Update Employees Set DepartmentID = @UpdatedDeptID Where EmployeeID = @EmployeeID;
Insert into EmployeeLog (EmployeeID, OldDeptID, UpdatedDeptID, ChangeDate)
Values (@EmployeeID, @OldDeptID, @UpdatedDeptID, GETDATE());
END;
GO
EXEC UpdateEmployeeDepartment  @EmployeeID = 2, @UpdatedDeptID = 3;
Select * from EmployeeLog;

--7.Create a stored procedure named GetProjectsWithNoCurrentEmployees that retrieves projects with no current employees assigned. 

CREATE PROCEDURE GetProjectsWithNoCurrentEmployees
AS
BEGIN
Select p.ProjectID, p.ProjectName, p.StartDate,p.EndDate From Projects p
    Left Join Assignments a ON P.ProjectID = A.ProjectID
    Where a.EmployeeID IS NULL
END;
EXEC GetProjectsWithNoCurrentEmployees;
update Assignments set EmployeeID=null where AssignmentId=3;

--8.Create a stored procedure named GetEmployeeAssignmentHistory that retrieves the assignment history of a specific employee. 
CREATE PROCEDURE GetEmployeeAssignmentHistory
@EmployeeID INT
AS
BEGIN
Select a.AssignmentID,a.AssignmentDate,a.Role, p.ProjectID,p.ProjectName,p.StartDate,p.EndDate
From  Assignments a Inner Join Projects p ON a.ProjectID = p.ProjectID
Where a.EmployeeID = @EmployeeID
Order By a.AssignmentDate;
END;
GO
EXEC GetEmployeeAssignmentHistory @EmployeeID=1;
select * from Assignments;

--9.Create a stored procedure named GetOverdueProjects that retrieves projects whose end date has passed but are not yet completed. 

Alter Table Projects
Add CompletionStatus CHAR(3);
 
 Update Projects set CompletionStatus='NO';

CREATE PROCEDURE GetOverdueProjects
AS
BEGIN
Select ProjectID,ProjectName,StartDate, EndDate
From Projects where  EndDate < GETDATE() AND CompletionStatus = 'NO';
END;
GO
EXEC GetOverdueProjects;
select * from Projects;

--10.Create a stored procedure named GetEmployeesByRole that retrieves all employees assigned to a specific role. 
CREATE PROCEDURE GetEmployeesByRole
    @Role NVARCHAR(50)
AS
BEGIN
Select e.EmployeeID ,e.FirstName,e.LastName,e.HireDate,e.DepartmentID, a.Role, a.AssignmentDate,a.ProjectID
From Employees e inner join Assignments a 
ON E.EmployeeID = A.EmployeeID Where a.Role = @Role;
END;
GO

EXEC GetEmployeesByRole @Role='Manager';

--11.Create a stored procedure named GetEmployeeCountByRole that retrieves the number of employees for each role. 

CREATE PROCEDURE GetEmployeeCountByRole
@Role Nvarchar(50)
AS
BEGIN
Select Count(e.EmployeeID) AS EmployeeCount,a.Role
From Employees e Join Assignments A On e.EmployeeID = a.EmployeeID
Where a.Role = @Role
Group by a.Role;
END;
GO
EXEC GetEmployeeCountByRole @Role ='Manager';

--12.Create a stored procedure named GetEmployeesWithNoCurrentAssignments that retrieves employees who do not have any current assignments. 

CREATE PROCEDURE GetEmployeesWithNoCurrentAssignments
AS
BEGIN
Select a.AssignmentID,e.EmployeeID,e.FirstName,e.LastName, e.HireDate, e.DepartmentID From 
Employees e Left Join Assignments a 
ON e.EmployeeID = a.EmployeeID
And a.AssignmentDate <= GETDATE() 
Where a.AssignmentID IS NULL; 
END;
GO
EXEC GetEmployeesWithNoCurrentAssignments;

--13.Create a stored procedure named GetProjectAssignmentStatistics that retrieves statistics on the number of assignments per project. 

CREATE PROCEDURE GetProjectAssignmentStatistics
@ProjectID INT
AS
BEGIN
Select P.ProjectID, P.ProjectName,Count(A.AssignmentID) AS NoOfAssignments
From Projects P Left Join Assignments A ON P.ProjectID = A.ProjectID
where P.ProjectID = @ProjectID
Group By P.ProjectID,P.ProjectName;
END;
GO

EXEC GetProjectAssignmentStatistics @ProjectID =101;