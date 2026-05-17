USE SecurityProjectDB;
GO

CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY IDENTITY(1,1),
    DepartmentName NVARCHAR(50) NOT NULL
);
GO

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    DepartmentID INT NOT NULL,
    Email NVARCHAR(100) NOT NULL,
    CONSTRAINT FK_Employees_Departments
        FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);
GO

CREATE TABLE Payroll (
    PayrollID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeID INT NOT NULL,
    Salary DECIMAL(10,2) NOT NULL,
    Bonus DECIMAL(10,2) NOT NULL DEFAULT 0,
    BankAccount NVARCHAR(50) NOT NULL,
    CONSTRAINT FK_Payroll_Employees
        FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);
GO

INSERT INTO Departments (DepartmentName)
VALUES ('HR'), ('IT'), ('Finance');
GO

INSERT INTO Employees (FirstName, LastName, DepartmentID, Email)
VALUES
('Ali', 'Yılmaz', 1, 'ali.yilmaz@company.com'),
('Ayşe', 'Demir', 2, 'ayse.demir@company.com'),
('Mehmet', 'Kaya', 3, 'mehmet.kaya@company.com');
GO

INSERT INTO Payroll (EmployeeID, Salary, Bonus, BankAccount)
VALUES
(1, 45000, 5000, 'TR000111222333'),
(2, 55000, 3000, 'TR000444555666'),
(3, 65000, 7000, 'TR000777888999');
GO

SELECT * FROM Departments;
SELECT * FROM Employees;
SELECT * FROM Payroll;
GO