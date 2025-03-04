USE AdventureWorks2008R2
GO

-- CREATE FUNCTION  FUNCTION_NAME
-- (@Parameter1 DATATYPE,@Parameter2 
-- DATATYPE,@Parameter3 DATATYPE,....,
-- @ParameterN DATATYPE)
-- RETURNS Return_Datatype
-- AS
-- BEGIN
--   --Function Body
--     RETURN Return_Datatype
-- END

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