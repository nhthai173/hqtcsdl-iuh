USE AdventureWorks2008R2
GO



-- 1. Tạo một Instead of trigger thực hiện trên view. Thực hiện theo các bước sau:
--  Tạo mới 2 bảng M_Employees và M_Department theo cấu trúc sau:

create table M_Department
(
    DepartmentID int not null primary key,
    Name nvarchar(50),
    GroupName nvarchar(50)
)
create table M_Employees
(
    EmployeeID int not null primary key,
    Firstname nvarchar(50),
    MiddleName nvarchar(50),
    LastName nvarchar(50),
    DepartmentID int foreign key references M_Department(DepartmentID)
)
GO

--  Tạo một view tên EmpDepart_View bao gồm các field: EmployeeID,
-- FirstName, MiddleName, LastName, DepartmentID, Name, GroupName, dựa
-- trên 2 bảng M_Employees và M_Department.

CREATE VIEW EmpDepart_View
AS
    SELECT e.EmployeeID, e.FirstName, e.MiddleName, e.LastName,
        d.DepartmentID, d.Name, d.GroupName
    FROM M_Employees e
        JOIN M_Department d ON e.DepartmentID = d.DepartmentID
GO

SELECT *
FROM EmpDepart_View
GO

--  Tạo một trigger tên InsteadOf_Trigger thực hiện trên view
-- EmpDepart_View, dùng để chèn dữ liệu vào các bảng M_Employees và
-- M_Department khi chèn một record mới thông qua view EmpDepart_View.

DROP TRIGGER IF EXISTS InsteadOf_Trigger
GO
CREATE TRIGGER InsteadOf_Trigger
ON EmpDepart_View
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @EmployeeID int, @FirstName nvarchar(50), @MiddleName nvarchar(50),
            @LastName nvarchar(50), @DepartmentID int, @Name nvarchar(50),
            @GroupName nvarchar(50)

    SELECT @EmployeeID = EmployeeID, @FirstName = FirstName,
        @MiddleName = MiddleName, @LastName = LastName,
        @DepartmentID = DepartmentID, @Name = Name,
        @GroupName = GroupName
    FROM inserted

    INSERT INTO M_Department
        (DepartmentID, Name, GroupName)
    VALUES
        (@DepartmentID, @Name, @GroupName)

    INSERT INTO M_Employees
        (EmployeeID, FirstName, MiddleName, LastName, DepartmentID)
    VALUES
        (@EmployeeID, @FirstName, @MiddleName, @LastName, @DepartmentID)
END
GO

-- Dữ liệu test:
insert EmpDepart_view
values(1, 'Nguyen', 'Hoang', 'Huy', 11, 'Marketing', 'Sales')

SELECT *
FROM M_Department
GO
SELECT *
FROM M_Employees
GO








-- 2. Tạo một trigger thực hiện trên bảng MSalesOrders có chức năng thiết lập độ ưu
-- tiên của khách hàng (CustPriority) khi người dùng thực hiện các thao tác Insert,
-- Update và Delete trên bảng MSalesOrders theo điều kiện như sau:
--  Nếu tổng tiền Sum(SubTotal) của khách hàng dưới 10,000 $ thì độ ưu tiên của
-- khách hàng (CustPriority) là 3
--  Nếu tổng tiền Sum(SubTotal) của khách hàng từ 10,000 $ đến dưới 50000 $
-- thì độ ưu tiên của khách hàng (CustPriority) là 2
--  Nếu tổng tiền Sum(SubTotal) của khách hàng từ 50000 $ trở lên thì độ ưu tiên
-- của khách hàng (CustPriority) là 1

--  Tạo bảng MCustomers và MSalesOrders theo cấu trúc
create table MCustomer
(
    CustomerID int not null primary key,
    CustPriority int
)
create table MSalesOrders
(
    SalesOrderID int not null primary key,
    OrderDate date,
    SubTotal money,
    CustomerID int foreign key references MCustomer(CustomerID)
)

-- Chèn dữ liệu cho bảng MCustomers, lấy dữ liệu từ bảng Sales.Customer,
-- nhưng chỉ lấy CustomerID>30100 và CustomerID<30118, cột CustPriority cho
-- giá trị null.

INSERT INTO MCustomer
SELECT CustomerID, NULL
FROM Sales.Customer
WHERE CustomerID > 30100 and CustomerID < 30118

-- Chèn dữ liệu cho bảng MSalesOrders, lấy dữ liệu từ bảng
-- Sales.SalesOrderHeader, chỉ lấy những hóa đơn của khách hàng có trong bảng
-- khách hàng.

INSERT INTO MSalesOrders
SELECT SalesOrderID, OrderDate, SubTotal, CustomerID
FROM Sales.SalesOrderHeader
WHERE CustomerID IN (SELECT CustomerID
FROM MCustomer)

-- Viết trigger để lấy dữ liệu từ 2 bảng inserted và deleted.

DROP TRIGGER IF EXISTS CustPriority_Trigger
GO
CREATE TRIGGER CustPriority_Trigger
ON MSalesOrders
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @CustomerID int, @SubTotal money
    IF EXISTS (SELECT *
    FROM deleted)
    BEGIN
        SELECT @CustomerID = CustomerID
        FROM deleted
    END
    ELSE IF EXISTS (SELECT *
    FROM inserted)
    BEGIN
        SELECT @CustomerID = CustomerID
        FROM inserted
    END
    IF @CustomerID IS NOT NULL
    BEGIN
        SELECT @SubTotal = SUM(SubTotal)
        FROM MSalesOrders
        WHERE CustomerID = @CustomerID

        UPDATE MCustomer
        SET CustPriority = CASE
            WHEN @SubTotal < 10000 THEN 3
            WHEN @SubTotal >= 10000 AND @SubTotal < 50000 THEN 2
            ELSE 1
        END
        WHERE CustomerID = @CustomerID
    END
END
GO


-- Viết câu lệnh kiểm tra việc thực thi của trigger vừa tạo bằng cách chèn thêm hoặc
-- xóa hoặc update một record trên bảng MSalesOrders

INSERT INTO MSalesOrders
VALUES
    (1001, '2023-10-01', 5000, 30101)
GO
SELECT *
FROM MCustomer
WHERE CustomerID = 30101
GO

UPDATE MSalesOrders SET SubTotal = 20000 WHERE SalesOrderID = 1001
GO
SELECT *
FROM MCustomer
WHERE CustomerID = 30101
GO

DELETE FROM MSalesOrders WHERE SalesOrderID = 1001
GO
SELECT *
FROM MCustomer
WHERE CustomerID = 30101
GO






-- 3. Viết một trigger thực hiện trên bảng MEmployees sao cho khi người dùng thực
-- hiện chèn thêm một nhân viên mới vào bảng MEmployees thì chương trình cập
-- nhật số nhân viên trong cột NumOfEmployee của bảng MDepartment. Nếu tổng
-- số nhân viên của phòng tương ứng <=200 thì cho phép chèn thêm, ngược lại thì
-- hiển thị thông báo “Bộ phận đã đủ nhân viên” và hủy giao tác. Các bước thực hiện:
--  Tạo mới 2 bảng MEmployees và MDepartment theo cấu trúc sau:
create table MDepartment
(
    DepartmentID int not null primary key,
    Name nvarchar(50),
    NumOfEmployee int
)

create table MEmployees
(
    EmployeeID int not null,
    FirstName nvarchar(50),
    MiddleName nvarchar(50),
    LastName nvarchar(50),
    DepartmentID int foreign key references MDepartment(DepartmentID),
    constraint pk_emp_depart primary key(EmployeeID, DepartmentID)
)


--  Chèn dữ liệu cho bảng MDepartment, lấy dữ liệu từ bảng Department, cột
-- NumOfEmployee gán giá trị NULL, bảng MEmployees lấy từ bảng
-- EmployeeDepartmentHistory

INSERT INTO MDepartment
SELECT DepartmentID, Name, NULL
FROM HumanResources.Department
GO

INSERT INTO MEmployees
SELECT edh.BusinessEntityID, p.FirstName, p.MiddleName, p.LastName, edh.DepartmentID
FROM HumanResources.EmployeeDepartmentHistory edh
    JOIN Person.Person p ON p.BusinessEntityID = edh.BusinessEntityID
GO

--  Viết trigger theo yêu cầu trên và viết câu lệnh hiện thực trigger

DROP TRIGGER IF EXISTS NumOfEmployee_Trigger
GO
CREATE TRIGGER NumOfEmployee_Trigger
ON MEmployees
AFTER INSERT
AS
BEGIN
    DECLARE @DepartmentID int, @NumOfEmployee int

    SELECT @DepartmentID = DepartmentID
    FROM inserted

    SELECT @NumOfEmployee = COUNT(*)
    FROM MEmployees
    WHERE DepartmentID = @DepartmentID

    IF @NumOfEmployee > 200
    BEGIN
        RAISERROR(N'Bộ phận đã đủ nhân viên', 16, 1)
        ROLLBACK
    END
    ELSE
    BEGIN
        UPDATE MDepartment
        SET NumOfEmployee = @NumOfEmployee
        WHERE DepartmentID = @DepartmentID
    END
END
GO


-- Kiểm tra
INSERT INTO MEmployees
VALUES
    (1111, 'Nguyen', 'Van', 'A', 7)

SELECT *
FROM MDepartment
GO









-- 4. Bảng [Purchasing].[Vendor], chứa thông tin của nhà cung cấp, thuộc tính
-- CreditRating hiển thị thông tin đánh giá mức tín dụng, có các giá trị:
-- 1 = Superior
-- 2 = Excellent
-- 3 = Above average
-- 4 = Average
-- 5 = Below average
-- Viết một trigger nhằm đảm bảo khi chèn thêm một record mới vào bảng
-- [Purchasing].[PurchaseOrderHeader], nếu Vender có CreditRating=5 thì hiển thị
-- thông báo không cho phép chèn và đồng thời hủy giao tác.

DROP TRIGGER IF EXISTS CreditRating_Trigger
GO
CREATE TRIGGER CreditRating_Trigger
ON Purchasing.PurchaseOrderHeader
AFTER INSERT
AS
BEGIN
    DECLARE @VendorID int, @CreditRating int

    SELECT @VendorID = VendorID
    FROM inserted

    SELECT @CreditRating = CreditRating
    FROM Purchasing.Vendor
    WHERE BusinessEntityID = @VendorID

    IF @CreditRating = 5
    BEGIN
        RAISERROR(N'Không cho phép chèn nhà cung cấp có CreditRating=5', 16, 1)
        ROLLBACK
    END
END
GO

-- Dữ liệu test
INSERT INTO Purchasing.PurchaseOrderHeader
    (RevisionNumber, Status, EmployeeID, VendorID, ShipMethodID, OrderDate, ShipDate, SubTotal, TaxAmt, Freight)
VALUES
    (2, 3, 261, 1652, 4, GETDATE(), GETDATE(), 44594.55, 3567.564, 1114.8638);






-- 5. Viết một trigger thực hiện trên bảng ProductInventory (lưu thông tin số lượng sản
-- phẩm trong kho). Khi chèn thêm một đơn đặt hàng vào bảng SalesOrderDetail với
-- số lượng xác định trong field
-- OrderQty, nếu số lượng trong kho
-- Quantity> OrderQty thì cập nhật
-- lại số lượng trong kho
-- Quantity= Quantity- OrderQty,
-- ngược lại nếu Quantity=0 thì xuất
-- thông báo “Kho hết hàng” và đồng
-- thời hủy giao tác.

DROP TRIGGER IF EXISTS ProductInventory_Trigger
GO

CREATE TRIGGER ProductInventory_Trigger
ON Sales.SalesOrderDetail
AFTER INSERT
AS
BEGIN
    DECLARE @ProductID int, @OrderQty int, @Quantity int

    SELECT @ProductID = ProductID, @OrderQty = OrderQty
    FROM inserted

    SELECT @Quantity = Quantity
    FROM Production.ProductInventory
    WHERE ProductID = @ProductID

    IF @Quantity > @OrderQty
    BEGIN
        UPDATE Production.ProductInventory
        SET Quantity = Quantity - @OrderQty
        WHERE ProductID = @ProductID
    END
    ELSE IF @Quantity = 0
    BEGIN
        RAISERROR(N'Kho hết hàng', 16, 1)
        ROLLBACK
    END
END
GO







-- 6. Tạo trigger cập nhật tiền thưởng (Bonus) cho nhân viên bán hàng SalesPerson, khi
-- người dùng chèn thêm một record mới trên bảng SalesOrderHeader, theo quy định
-- như sau: Nếu tổng tiền bán được của nhân viên có hóa đơn mới nhập vào bảng
-- SalesOrderHeader có giá trị >10000000 thì tăng tiền thưởng lên 10% của mức
-- thưởng hiện tại. Cách thực hiện:
--  Tạo hai bảng mới M_SalesPerson và M_SalesOrderHeader
create table M_SalesPerson
(
    SalePSID int not null primary key,
    TerritoryID int,
    BonusPS money
)
create table M_SalesOrderHeader
(
    SalesOrdID int not null primary key,
    OrderDate date,
    SubTotalOrd money,
    SalePSID int foreign key references M_SalesPerson(SalePSID)
)
--  Chèn dữ liệu cho hai bảng trên lấy từ SalesPerson và SalesOrderHeader chọn
-- những field tương ứng với 2 bảng mới tạo.

INSERT INTO M_SalesPerson
SELECT BusinessEntityID, TerritoryID, Bonus
FROM Sales.SalesPerson

INSERT INTO M_SalesOrderHeader
SELECT SalesOrderID, OrderDate, SubTotal, SalesPersonID
FROM Sales.SalesOrderHeader

--  Viết trigger cho thao tác insert trên bảng M_SalesOrderHeader, khi trigger
-- thực thi thì dữ liệu trong bảng M_SalesPerson được cập nhật.

DROP TRIGGER IF EXISTS Bonus_Trigger
GO
CREATE TRIGGER Bonus_Trigger
ON M_SalesOrderHeader
AFTER INSERT
AS
BEGIN
    DECLARE @SalePSID int, @SubTotalOrd money, @BonusPS money

    SELECT @SalePSID = SalePSID, @SubTotalOrd = SubTotalOrd
    FROM inserted

    SELECT @BonusPS = BonusPS
    FROM M_SalesPerson
    WHERE SalePSID = @SalePSID

    IF @SubTotalOrd > 10000000
    BEGIN
        UPDATE M_SalesPerson
        SET BonusPS = BonusPS * 1.1
        WHERE SalePSID = @SalePSID
    END
END
GO