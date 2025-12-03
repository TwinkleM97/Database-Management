-- Create Customers Table
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50),
    Email NVARCHAR(100) UNIQUE,
    Phone NVARCHAR(20) NOT NULL
);

-- Create Products Table
CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName NVARCHAR(100),
    Price DECIMAL(10, 2),
    Stock INT );

-- Create Orders Table
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT NOT NULL,
    OrderDate DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);
select * from orderdetails;
select * from orders;
-- Create OrderDetails Table
CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT ,
    Price DECIMAL(10, 2)  ,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Insert Dummy Data into Customers Table 
INSERT INTO Customers (FirstName, LastName, Email, Phone) 
VALUES  
('John', 'Doe', 'john.doe@example.com', '555-0100'), 
('Jane', 'Smith', 'jane.smith@example.com', '555-0101'), 
('Jim', 'Beam', 'jim.beam@example.com', '555-0102'), 
('Jill', 'Valentine', 'jill.valentine@example.com', '555-0103'); 
 
-- Insert Dummy Data into Products Table 
INSERT INTO Products (ProductName, Price, Stock) 
VALUES  
('Laptop', 1200.00, 50), 
('Smartphone', 800.00, 100), 
('Tablet', 300.00, 70), 
('Headphones', 100.00, 200); 

-- Insert Dummy Data into Orders Table 
INSERT INTO Orders (CustomerID, OrderDate) 
VALUES  
(1, '2024-07-20'), 
(2, '2024-07-21'), 
(3, '2024-07-22'), 
(4, '2024-07-23'); 
 
-- Insert Dummy Data into OrderDetails Table 
INSERT INTO OrderDetails (OrderID, ProductID, Quantity, Price) 
VALUES  
(1, 1, 1, 1200.00), 
(1, 2, 2, 800.00), 
(2, 3, 1, 300.00), 
(3, 4, 3, 100.00), 
(4, 2, 1, 800.00), 
(4, 4, 2, 100.00); 

--1.Create a stored procedure AddCustomer that inserts a new customer into the Customers table. Include error handling and transactions. 
CREATE PROCEDURE AddCustomer
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Email NVARCHAR(100),
    @Phone NVARCHAR(20)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        Insert Into Customers (FirstName, LastName, Email, Phone)
        Values (@FirstName, @LastName, @Email, @Phone);
        
        COMMIT TRANSACTION;
        PRINT 'Customer successfully added';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
EXEC AddCustomer @FirstName='Wonder', @LastName='Woman', @Email='wonders@gmail.com', @Phone='555-0104';
Select * from Customers;

--2.Create a stored procedure AddProduct that inserts a new product into the Products table. Include error handling and transactions

CREATE PROCEDURE AddProduct
    @ProductName NVARCHAR(100),
    @Price DECIMAL(10, 2),
    @Stock INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        Insert Into Products (ProductName, Price, Stock)
        Values (@ProductName, @Price, @Stock);
        
        COMMIT TRANSACTION;
        PRINT 'Product successfully added';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
EXEC AddProduct @ProductName='Desktop', @Price=1400, @Stock=90;
Select * from Products;

--3A.Create a stored procedure CreateOrder that inserts a new order and its details into the Orders and OrderDetails tables, respectively.It should also update the product stock.
CREATE PROCEDURE CreateOrder
    @CustomerID INT,
    @ProductID INT,
    @Quantity INT
AS
BEGIN
    DECLARE @OrderID INT;
    DECLARE @Price DECIMAL(10, 2);
    DECLARE @CurrentStock INT;
 BEGIN TRY
 BEGIN TRANSACTION;
    
Select @Price = Price, @CurrentStock = Stock From  Products Where ProductID = @ProductID;
IF @CurrentStock < @Quantity
BEGIN
THROW 50001, 'Insufficient stock', 1;
END
Insert Into Orders (CustomerID, OrderDate)
Values (@CustomerID, GETDATE());
        
SET @OrderID = SCOPE_IDENTITY();

Insert into OrderDetails (OrderID, ProductID, Quantity, Price)
Values (@OrderID, @ProductID, @Quantity, @Price);

Update Products Set Stock = Stock - @Quantity Where ProductID = @ProductID;

COMMIT TRANSACTION;
PRINT 'Order successfully created';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
EXEC CreateOrder @CustomerID=1, @ProductID=1, @Quantity =2; -- earlier stock for Laptop was 50

Select * from products;
select * from OrderDetails;

--3B. Create a stored procedure UpdateCustomer that updates the details of an existing customer. Include error handling and transactions. 

CREATE PROCEDURE UpdateCustomer
    @CustomerID INT,
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Email NVARCHAR(100),
    @Phone NVARCHAR(20)
AS
BEGIN
BEGIN TRY
BEGIN TRANSACTION;
        
Update Customers Set FirstName = @FirstName,LastName = @LastName,Email = @Email,Phone = @Phone
Where CustomerID = @CustomerID;
        
IF @@ROWCOUNT = 0
THROW 50002, 'Customer not found', 1;

        COMMIT TRANSACTION;
        PRINT 'Customer successfully updated';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO     
EXEC UpdateCustomer @CustomerID=5, @FirstName='Logan', @LastName='Wolverine', @Email='wolverine@gmail.com', @Phone='555-0105';
select * from customers;


--4.Create a stored procedure DeleteCustomer that deletes a customer from the Customers table. Include error handling and transactions

CREATE PROCEDURE DeleteCustomer
    @CustomerID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

Delete from OrderDetails where OrderID in (Select OrderID From Orders where CustomerID = @CustomerID);

Delete from Orders where CustomerID = @CustomerID;

Delete from CustomerFeedback where CustomerID = @CustomerID;

Delete From Customers where CustomerID = @CustomerID;

IF @@ROWCOUNT = 0
THROW 50002, 'Customer not found', 1;

        COMMIT TRANSACTION;
        PRINT 'Customer successfully deleted';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
EXEC DeleteCustomer @CustomerID=4;
select * from Customers;


--5. Create a stored procedure UpdateProduct that updates the details of an existing product. Include error handling and transactions. 
CREATE PROCEDURE UpdateProduct
    @ProductID INT,
    @ProductName NVARCHAR(100),
    @Price DECIMAL(10, 2),
    @Stock INT
AS
BEGIN
   BEGIN TRY
       BEGIN TRANSACTION;
        
Update Products Set ProductName = @ProductName,Price = @Price, Stock = @Stock
Where ProductID = @ProductID;
        
        IF @@ROWCOUNT = 0
            THROW 50003, 'Product not found', 1;

        COMMIT TRANSACTION;
        PRINT 'Product  successfully updated';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

EXEC UpdateProduct @ProductID=2, @ProductName='SmartWatch',@Price= 600, @Stock= 150;
select * from products;

--6.Create a stored procedure DeleteProduct that deletes a product from the Products table. Include error handling and transactions.
CREATE PROCEDURE DeleteProduct
    @ProductID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
      
Delete From OrderDetails where ProductID = @ProductID;

Delete From Products where ProductID = @ProductID;
        
        IF @@ROWCOUNT = 0
            THROW 50003, 'Product not found', 1;
        
        COMMIT TRANSACTION;
        PRINT 'Product and its order details successfully deleted';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

EXEC DeleteProduct @ProductID=4;
select * from products;
select * from OrderDetails;

--7.Create a stored procedure ProcessReturn that processes a return of items by updating the OrderDetails and Products tables. Include error handling and transactions.
CREATE PROCEDURE ProcessReturn
    @OrderDetailID INT,
    @ReturnQuantity INT
AS
BEGIN
    DECLARE @ProductID INT;
    DECLARE @InitialQuantity INT;
BEGIN TRY
  BEGIN TRANSACTION;
 Select @ProductID = ProductID, @InitialQuantity = Quantity From OrderDetails where OrderDetailID = @OrderDetailID;

IF @InitialQuantity IS NULL
THROW 50004, 'Order detail not found', 1;
IF @ReturnQuantity > @InitialQuantity
THROW 50005, 'Return quantity exceeds original quantity', 1;

Update OrderDetails Set Quantity = Quantity - @ReturnQuantity
where OrderDetailID = @OrderDetailID;

Update Products Set Stock = Stock + @ReturnQuantity
where ProductID = @ProductID;

COMMIT TRANSACTION;
PRINT 'Return successfully processed';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
EXEC ProcessReturn @OrderDetailID=7, @ReturnQuantity=2; 
select * from OrderDetails;

--8.Create a stored procedure GenerateSalesReport that generates a sales report for a given date range. 
CREATE PROCEDURE GenerateSalesReport
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
Select O.OrderID, O.OrderDate,
        C.FirstName + ' ' + C.LastName as CustomerName,
        P.ProductName,
        OD.Quantity,
        OD.Price as UnitPrice,
        OD.Quantity * OD.Price as TotalPrice
    FROM 
        Orders O
        INNER JOIN Customers C ON O.CustomerID = C.CustomerID
        INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
        INNER JOIN Products P ON OD.ProductID = P.ProductID
    WHERE 
        O.OrderDate BETWEEN @StartDate AND @EndDate
    ORDER BY 
        O.OrderDate, O.OrderID;
END;
GO
EXEC GenerateSalesReport @StartDate='2024-07-10', @EndDate='2024-07-29';

--9.	Create a stored procedure TrackInventory that lists products with low stock (less than 10). 

Update  Products SET Stock=9 where ProductID=3;
CREATE PROCEDURE TrackInventory
AS
BEGIN
Select ProductID,ProductName,Stock From Products
Where Stock < 10
Order By Stock ASC;
END
GO
EXEC TrackInventory;
select * from Products;
--10.	Create a stored procedure AddCustomerFeedback to insert feedback into the CustomerFeedback table. 
--a.Ensure the CustomerFeedback table is created first.
CREATE TABLE CustomerFeedback (
    FeedbackID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT NOT NULL,
    FeedbackDate DATE NOT NULL,
    Rating INT NOT NULL,
    Comment TEXT,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID));
CREATE PROCEDURE AddCustomerFeedback
    @CustomerID INT,
    @Rating INT,
    @Comment TEXT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        Insert Into CustomerFeedback (CustomerID, FeedbackDate, Rating, Comment)
        VALUES (@CustomerID, GETDATE(), @Rating, @Comment);
        
        COMMIT TRANSACTION;
        PRINT 'Customer feedback successfully added';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
EXEC AddCustomerFeedback @CustomerID=1, @Rating=5, @Comment='Amazing customer service!';
select * from CustomerFeedback;

