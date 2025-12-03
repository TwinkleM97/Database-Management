Create table Cars(
CarID int Primary key,
ModelName varchar(20),
ModelVariant varchar(20),
Color varchar(15) ,
Year Date,
Price decimal(8,2),
VIN varchar(17) not null    --Candidate Key
);
Create table Customers(
CustomerId int Primary key,
FirstName varchar(20) not null,
LastName varchar(20),
PhoneNumber varchar(15) not null, --Candidate key
Email varchar(20),
Address varchar(20));

Create table Employees(
EmployeeId int Primary key,
EmpFirstName varchar(20) not null,
EmpLastName varchar(20),
EmpEmail varchar(30) not null, --Candidate key
EmpRole varchar(20) not null,
Salary decimal(10, 2),
Bonus decimal(5,2)
);

Create table Sales(
SalesID int Primary key,
SalesDate Date,
SalePrice decimal(8,2),
EmployeeId int,
CustomerId int,
CarID int
 CONSTRAINT FK_EmployeeId FOREIGN KEY (EmployeeId) REFERENCES Employees(EmployeeId),
 CONSTRAINT FK_CustomerId FOREIGN KEY (CustomerId) REFERENCES Customers(CustomerId),
 CONSTRAINT FK_CarID FOREIGN KEY (CarID) REFERENCES Cars(CarID));

Create table Maintenance(
MaintenanceId int Primary key,
MechanicId int,
RepairDate varchar(15),
Cost Decimal(10,2),
Description varchar(100),
CarID int ,
CONSTRAINT FK_MechanicId FOREIGN KEY (MechanicId) REFERENCES Employees(EmployeeId),
CONSTRAINT FK_CarsID FOREIGN KEY (CarID) REFERENCES Cars(CarID));

insert into Cars(CarID,ModelName,ModelVariant,Color,Year,Price,VIN)
values(111,'Maruti Suzuki Swift','LXI','Black','1997',4866.90,'1HGBH41JXMN109186'),
      (112,'BMW','Convertible','Red','1987',93866.73,'1HGBH41JXMN108745'),
      (113,'Audi etron','SUV','Grey','2010',80866.89,'1HGBH41JXMN209576');

insert into Customers(CustomerId,FirstName,LastName,PhoneNumber,Email,Address)
values(1,'Deepak','Patel','6668070973','deepak@gmail.com','289A Albert Street N2L4J6 Waterloo ON'),
      (2,'Phool','Kumari','1418070973','phool@gmail.com','67B Victoria Street N8L4P3 Hamilton'),
	  (3,'Nicole','NG','1418070973','nicoleng@gmail.com','278C Queens Street N2K7J2 Montreal');

insert into Employees(EmployeeId,EmpFirstName,EmpLastName,EmpEmail,EmpRole,Salary,Bonus)
values(1111,'Merrick','Karya','merrick@gmail.com','Store Manager',5000.96,250.45),
      (1112,'Devesh','Mishra','devesh12@gmail.com','Mechanic',2000.66,150.45),
	  (1113,'Vishal','Kumar','vishal13@gmail.com','Mechanic',2100.96,150.45);

insert into Sales(SalesID,SalesDate,SalePrice,EmployeeId,CustomerId,CarID)
 values(11,'2024',4890.34,1111,2,111),
 (12,'2023',80900.34,1113,1,112),
  (13,'2024',94000.34,1111,3,113);

insert into Maintenance(MaintenanceId,MechanicId,RepairDate,Cost,Description,CarID)
values(121,1112,'21-05-2024',100.89,'broken headlight',111),
      (131,1113,'29-05-2024',300.40,'Tire punture',113);





