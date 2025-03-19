USE AdventureWorks2008R2
GO

-- 1) Viết hàm tên CountOfEmployees (dạng scalar function) với tham số @mapb,
-- giá trị truyền vào lấy từ field [DepartmentID], hàm trả về số nhân viên trong
-- phòng ban tương ứng. Áp dụng hàm đã viết vào câu truy vấn liệt kê danh sách các
-- phòng ban với số nhân viên của mỗi phòng ban, thông tin gồm: [DepartmentID],
-- Name, countOfEmp với countOfEmp= CountOfEmployees([DepartmentID]).
-- (Dữ liệu lấy từ bảng
-- [HumanResources].[EmployeeDepartmentHistory] và
-- [HumanResources].[Department])

CREATE FUNCTION CountOfEmployees (@mapb SMALLINT) RETURNS INT
AS
BEGIN
    DECLARE @count INT
    SELECT
        @count = COUNT(edh.BusinessEntityID)
    FROM
        HumanResources.Department d
        JOIN HumanResources.EmployeeDepartmentHistory edh ON d.DepartmentID = edh.DepartmentID
    WHERE
        edh.EndDate IS NULL AND
        d.DepartmentID = @mapb
    GROUP BY
        d.DepartmentID
    RETURN @count
END
GO

SELECT
    d.DepartmentID,
    d.Name,
    dbo.CountOfEmployees(d.DepartmentID) AS countOfEmp
FROM
    HumanResources.Department d
GO


-- 2) Viết hàm tên là InventoryProd (dạng scalar function) với tham số vào là
-- @ProductID và @LocationID trả về số lượng tồn kho của sản phẩm trong khu
-- vực tương ứng với giá trị của tham số
-- (Dữ liệu lấy từ bảng[Production].[ProductInventory])

CREATE FUNCTION InventoryProd (@ProductID INT, @LocationID INT) RETURNS INT
AS
BEGIN
DECLARE @Quantity INT
SELECT
    @Quantity = Quantity
FROM
    Production.ProductInventory
WHERE
    ProductID = @ProductID AND
    LocationID = @LocationID
RETURN @Quantity
END
GO

SELECT dbo.InventoryProd(1, 1) AS Quantity
GO


-- 3) Viết hàm tên SubTotalOfEmp (dạng scalar function) trả về tổng doanh thu của
-- một nhân viên trong một tháng tùy ý trong một năm tùy ý, với tham số vào
-- @EmplID, @MonthOrder, @YearOrder
-- (Thông tin lấy từ bảng [Sales].[SalesOrderHeader])

CREATE FUNCTION SubTotalOfEmp (@EmplID INT, @MonthOrder INT, @YearOrder INT) RETURNS MONEY
AS
BEGIN
DECLARE @SubTotal MONEY
SELECT
    @SubTotal = SUM(SubTotal)
FROM
    Sales.SalesOrderHeader
WHERE
    SalesPersonID = @EmplID AND
    MONTH(OrderDate) = @MonthOrder AND
    YEAR(OrderDate) = @YearOrder
GROUP BY
    SalesPersonID
RETURN @SubTotal
END
GO

SELECT dbo.SubTotalOfEmp(278, 7, 2005) AS SubTotal
GO


-- 4) Viết hàm SumOfOrder với hai tham số @thang và @nam trả về danh sách các
-- hóa đơn (SalesOrderID) lập trong tháng và năm được truyền vào từ 2 tham số
-- @thang và @nam, có tổng tiền >70000, thông tin gồm SalesOrderID, OrderDate,
-- SubTotal, trong đó SubTotal =sum(OrderQty*UnitPrice).

DROP FUNCTION IF EXISTS dbo.SumOfOrder
GO

CREATE FUNCTION SumOfOrder (
    @thang INT, @nam INT)
RETURNS TABLE
AS
RETURN
(
    SELECT
        soh.SalesOrderID,
        soh.OrderDate,
        SUM(sod.OrderQty * sod.UnitPrice) AS SubTotal
    FROM
        Sales.SalesOrderDetail sod
        JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
    WHERE
        MONTH(OrderDate) = @thang AND
        YEAR(OrderDate) = @nam
    GROUP BY
        soh.SalesOrderID,
        soh.OrderDate
    HAVING
        SUM(sod.OrderQty * sod.UnitPrice) > 70000
)
GO

SELECT * FROM dbo.SumOfOrder(7, 2007)
GO


-- 5) Viết hàm tên NewBonus tính lại tiền thưởng (Bonus) cho nhân viên bán hàng
-- (SalesPerson), dựa trên tổng doanh thu của mỗi nhân viên, mức thưởng mới bằng
-- mức thưởng hiện tại tăng thêm 1% tổng doanh thu, thông tin bao gồm
-- [SalesPersonID], NewBonus (thưởng mới), SumOfSubTotal. Trong đó:
--  SumOfSubTotal =sum(SubTotal),
--  NewBonus = Bonus+ sum(SubTotal)*0.01

DROP FUNCTION IF EXISTS NewBonus
GO
CREATE FUNCTION NewBonus ()
RETURNS TABLE
AS
RETURN
(
    SELECT
        sp.BusinessEntityID,
        NewBonus = sp.Bonus + SUM(soh.SubTotal) * 0.01,
        SumOfSubTotal = SUM(soh.SubTotal)
    FROM
        Sales.SalesPerson sp
        JOIN Sales.SalesOrderHeader soh ON sp.BusinessEntityID = soh.SalesPersonID
    GROUP BY
        sp.BusinessEntityID,
        sp.Bonus
)
GO

SELECT * FROM dbo.NewBonus()
GO


-- 6) Viết hàm tên SumOfProduct với tham số đầu vào là @MaNCC (VendorID),
-- hàm dùng để tính tổng số lượng (SumOfQty) và tổng trị giá (SumOfSubTotal)
-- của các sản phẩm do nhà cung cấp @MaNCC cung cấp, thông tin gồm
-- ProductID, SumOfProduct, SumOfSubTotal
-- (sử dụng các bảng [Purchasing].[Vendor] [Purchasing].[PurchaseOrderHeader]
-- và [Purchasing].[PurchaseOrderDetail])

DROP FUNCTION IF EXISTS SumOfProduct
GO
CREATE FUNCTION SumOfProduct (@MaNCC INT)
RETURNS TABLE
AS
RETURN
(
    SELECT
        pod.ProductID,
        SumOfQty = SUM(pod.OrderQty),
        SumOfSubTotal = SUM(pod.UnitPrice * pod.OrderQty)
    FROM
        Purchasing.PurchaseOrderDetail pod
        JOIN Purchasing.PurchaseOrderHeader poh ON pod.PurchaseOrderID = poh.PurchaseOrderID
    WHERE
        poh.VendorID = @MaNCC
    GROUP BY
        pod.ProductID
)
GO

SELECT * FROM dbo.SumOfProduct(1494)
GO



-- 7) Viết hàm tên Discount_Func tính số tiền giảm trên các hóa đơn (SalesOrderID),
-- thông tin gồm SalesOrderID, [SubTotal], Discount; trong đó Discount được tính
-- như sau:
-- Nếu [SubTotal]<1000 thì Discount=0
-- Nếu 1000<=[SubTotal]<5000 thì Discount = 5%[SubTotal]
-- Nếu 5000<=[SubTotal]<10000 thì Discount = 10%[SubTotal]
-- Nếu [SubTotal>=10000 thì Discount = 15%[SubTotal]

DROP FUNCTION IF EXISTS Discount_Func
GO

CREATE FUNCTION Discount_Func ()
RETURNS TABLE
AS
RETURN
(
    SELECT
        soh.SalesOrderID,
        soh.SubTotal,
        Discount = CASE
            WHEN soh.SubTotal < 1000 THEN 0
            WHEN soh.SubTotal >= 1000 AND soh.SubTotal < 5000 THEN soh.SubTotal * 0.05
            WHEN soh.SubTotal >= 5000 AND soh.SubTotal < 10000 THEN soh.SubTotal * 0.10
            ELSE soh.SubTotal * 0.15
        END
    FROM
        Sales.SalesOrderHeader soh
)
GO

SELECT * FROM dbo.Discount_Func()
GO





-- 8) Viết hàm TotalOfEmp với tham số @MonthOrder, @YearOrder để tính tổng
-- doanh thu của các nhân viên bán hàng (SalePerson) trong tháng và năm được
-- truyền vào 2 tham số, thông tin gồm [SalesPersonID], Total, với
-- Total=Sum([SubTotal])

DROP FUNCTION IF EXISTS TotalOfEmp
GO

CREATE FUNCTION TotalOfEmp (
    @MonthOrder INT,
    @YearOrder INT)
RETURNS TABLE
AS
RETURN
(
    SELECT
        soh.SalesPersonID,
        Total = SUM(soh.SubTotal)
    FROM
        Sales.SalesOrderHeader soh
    WHERE
        MONTH(OrderDate) = @MonthOrder AND
        YEAR(OrderDate) = @YearOrder
    GROUP BY
        soh.SalesPersonID
)
GO

SELECT * FROM dbo.TotalOfEmp(7, 2007)
GO





-- 9) Viết lại các câu 5,6,7,8 bằng Multi-statement table valued function

-- 5)
CREATE FUNCTION NewBonus_multi ()
RETURNS @result TABLE (
    SalesPersonID INT,
    NewBonus MONEY,
    SumOfSubTotal MONEY
)
AS
BEGIN
    INSERT INTO @result
    SELECT
        sp.BusinessEntityID,
        NewBonus = sp.Bonus + SUM(soh.SubTotal) * 0.01,
        SumOfSubTotal = SUM(soh.SubTotal)
    FROM
        Sales.SalesPerson sp
        JOIN Sales.SalesOrderHeader soh ON sp.BusinessEntityID = soh.SalesPersonID
    GROUP BY
        sp.BusinessEntityID,
        sp.Bonus
    RETURN
END
GO

SELECT * FROM dbo.NewBonus_multi()
GO


-- 6)
CREATE FUNCTION SumOfProduct_multi (@MaNCC INT)
RETURNS @result TABLE (
    ProductID INT,
    SumOfQty INT,
    SumOfSubTotal MONEY
)
AS
BEGIN
    INSERT INTO @result
    SELECT
        pod.ProductID,
        SumOfQty = SUM(pod.OrderQty),
        SumOfSubTotal = SUM(pod.UnitPrice * pod.OrderQty)
    FROM
        Purchasing.PurchaseOrderDetail pod
        JOIN Purchasing.PurchaseOrderHeader poh ON pod.PurchaseOrderID = poh.PurchaseOrderID
    WHERE
        poh.VendorID = @MaNCC
    GROUP BY
        pod.ProductID
    RETURN
END
GO

SELECT * FROM dbo.SumOfProduct(1494)
GO


-- 7)
CREATE FUNCTION Discount_Func_multi ()
RETURNS @result TABLE (
    SalesOrderID INT,
    SubTotal MONEY,
    Discount MONEY
)
AS
BEGIN
    INSERT INTO @result
    SELECT
        soh.SalesOrderID,
        soh.SubTotal,
        Discount = CASE
            WHEN soh.SubTotal < 1000 THEN 0
            WHEN soh.SubTotal >= 1000 AND soh.SubTotal < 5000 THEN soh.SubTotal * 0.05
            WHEN soh.SubTotal >= 5000 AND soh.SubTotal < 10000 THEN soh.SubTotal * 0.10
            ELSE soh.SubTotal * 0.15
        END
    FROM
        Sales.SalesOrderHeader soh
    RETURN
END
GO

SELECT * FROM dbo.Discount_Func()
GO



-- 8)
CREATE FUNCTION TotalOfEmp_multi (
    @MonthOrder INT,
    @YearOrder INT)
RETURNS @result TABLE (
    SalesPersonID INT,
    Total MONEY
)
AS
BEGIN
    INSERT INTO @result
    SELECT
        soh.SalesPersonID,
        Total = SUM(soh.SubTotal)
    FROM
        Sales.SalesOrderHeader soh
    WHERE
        MONTH(OrderDate) = @MonthOrder AND
        YEAR(OrderDate) = @YearOrder
    GROUP BY
        soh.SalesPersonID
    RETURN
END
GO

SELECT * FROM dbo.TotalOfEmp(7, 2007)
GO




-- 10) Viết hàm tên SalaryOfEmp trả về kết quả là bảng lương của nhân viên, với tham
-- số vào là @MaNV (giá trị của [BusinessEntityID]), thông tin gồm
-- BusinessEntityID, FName, LName, Salary (giá trị của cột Rate).
--  Nếu giá trị của tham số truyền vào là Mã nhân viên khác Null thì kết
-- quả là bảng lương của nhân viên đó.
-- Ví dụ thực thi hàm: select * from SalaryOfEmp(288)
--  Nếu giá trị truyền vào là Null thì kết quả là bảng lương của tất cả nhân viên
-- Ví dụ: thực thi hàm select * from SalaryOfEmp(Null)

CREATE FUNCTION SalaryOfEmp (@MaNV INT)
RETURNS @result TABLE (
    BusinessEntityID INT,
    FName NVARCHAR(50),
    LName NVARCHAR(50),
    Salary MONEY
)
AS
BEGIN
    IF @MaNV IS NULL
    BEGIN
        INSERT INTO @result
        SELECT
            p.BusinessEntityID,
            FName = p.FirstName,
            LName = p.LastName,
            Salary = eph.Rate
        FROM
            Person.Person p
            JOIN HumanResources.EmployeePayHistory eph ON eph.BusinessEntityID = p.BusinessEntityID
    END
    ELSE
    BEGIN
        INSERT INTO @result
        SELECT
            p.BusinessEntityID,
            FName = p.FirstName,
            LName = p.LastName,
            Salary = eph.Rate
        FROM
            Person.Person p
            JOIN HumanResources.EmployeePayHistory eph ON eph.BusinessEntityID = p.BusinessEntityID
        WHERE
            p.BusinessEntityID = @MaNV
    END
    RETURN
END
GO

SELECT * FROM dbo.SalaryOfEmp(288)
GO

SELECT * FROM dbo.SalaryOfEmp(NULL)
GO