USE AdventureWorks2008R2
GO

-- 1)Liệt kê các sản phẩm gồm các thông tin Product Names
-- và Product  ID có trên 100 đơn đặt hàng trong tháng 7 năm 2008

SELECT
    ProductID,
    Name
FROM (
        SELECT
        pd.ProductID,
        pd.Name,
        COUNT(sod.SalesOrderID) AS CountOfOrder
    FROM
        Production.Product pd
        JOIN Sales.SalesOrderDetail sod ON pd.ProductID = sod.ProductID
        JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
    WHERE
        MONTH(soh.OrderDate) = 7
        AND YEAR(soh.OrderDate) = 2008
    GROUP BY
        pd.ProductID,
        pd.Name) AS orders
WHERE
    CountOfOrder > 100


-- 2)Liệt kê các sản phẩm (ProductID,Name) có số hóa đơn đặt hàng nhiều nhất trong tháng 7/2008

SELECT TOP 1
    ProductID,
    Name
FROM (
        SELECT
        pd.ProductID,
        pd.Name,
        COUNT(sod.SalesOrderID) AS CountOfOrder
    FROM
        Production.Product pd
        JOIN Sales.SalesOrderDetail sod ON pd.ProductID = sod.ProductID
        JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
    WHERE
        MONTH(soh.OrderDate) = 7
        AND YEAR(soh.OrderDate) = 2008
    GROUP BY
        pd.ProductID,
        pd.Name) AS orders
ORDER BY
    CountOfOrder DESC

-- 3)Hiển thị thông tin của khách hàng có số đơn đặt hàng nhiều nhất,
-- thông tin gồm: CustomerID, Name, CountOfOrder

SELECT TOP 1
    p.BusinessEntityID AS CustomerID,
    p.FirstName + ' ' + p.LastName AS Name,
    orders.CountOfOrder
FROM
    (
        SELECT
            COUNT(soh.SalesOrderID) AS CountOfOrder,
            soh.CustomerID
        FROM
            Sales.SalesOrderHeader soh
        GROUP BY
            soh.CustomerID
    ) AS orders
    JOIN Person.Person p ON orders.CustomerID = p.BusinessEntityID
ORDER BY
    orders.CountOfOrder DESC


-- 4)Liệt kê các sản phẩm (ProductID,Name)thuộc mô hình sản phẩm áo dài tay với tên bắt đầu với “Long-SleeveLogoJersey”,
-- dùng phép IN và EXISTS,(sử dụng bảng Production.Product và Production.ProductModel)

-- Dùng IN
SELECT
    pd.ProductID,
    pd.Name
FROM
    Production.Product pd
WHERE
    pd.ProductModelID IN
    (
        SELECT
            pm.ProductModelID
        FROM
            Production.ProductModel pm
        WHERE
            pm.Name LIKE 'Long-Sleeve Logo Jersey%'
    )

-- Dùng EXISTS
SELECT
    pd.ProductID,
    pd.Name
FROM
    Production.Product pd
WHERE
    EXISTS
    (
        SELECT
            pm.ProductModelID
        FROM
            Production.ProductModel pm
        WHERE
            pm.ProductModelID = pd.ProductModelID
            AND pm.Name LIKE 'Long-Sleeve Logo Jersey%'
    )

-- 5) Tìm các mô hình sản phẩm (ProductModelID) mà giá niêm yết (listprice)
-- tối đa cao hơn giá trung bình của tất cả các mô hình.

SELECT
    DISTINCT pd.ProductModelID
FROM
    Production.Product pd
    JOIN Production.ProductModel pm ON pd.ProductModelID = pm.ProductModelID
WHERE
    pd.ListPrice >
    (
        SELECT
            AVG(pd.ListPrice) AS AvgListPrice
        FROM
            Production.Product pd
            JOIN Production.ProductModel pm ON pd.ProductModelID = pm.ProductModelID
    )


-- 6)Liệt kê các sản phẩm gồm các thông tin ProductID, Name, có tổng số lượng đặt hàng >5000 (dùng IN, EXISTS)

-- Dùng IN
SELECT
    pd.ProductID,
    pd.Name
FROM
    Production.Product pd
WHERE
    pd.ProductID IN
    (
        SELECT
            sod.ProductID
        FROM
            Sales.SalesOrderDetail sod
            JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
        GROUP BY
            sod.ProductID
        HAVING
            SUM(sod.OrderQty) > 5000
    )

-- Dùng EXISTS
SELECT
    pd.ProductID,
    pd.Name
FROM
    Production.Product pd
WHERE
    EXISTS
    (
        SELECT
            sod.ProductID
        FROM
            Sales.SalesOrderDetail sod
            JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
        WHERE
            pd.ProductID = sod.ProductID
        GROUP BY
            sod.ProductID
        HAVING
            SUM(sod.OrderQty) > 5000
    )

-- 7)Liệt kê những sản phẩm (ProductID, UnitPrice) có đơn giá (UnitPrice) cao nhất trong bảng Sales.SalesOrderDetail


SELECT
    DISTINCT pd.ProductID,
    sod.UnitPrice
FROM
    Production.Product pd
    JOIN Sales.SalesOrderDetail sod ON pd.ProductID = sod.ProductID
WHERE
    sod.UnitPrice =
    (
        SELECT
            MAX(sod.UnitPrice)
        FROM
            Sales.SalesOrderDetail sod
    )

-- 8)Liệt kê các sản phẩm không có đơn đặt hàng nào thông tin gồm ProductID, Name;
-- dùng 3 cách Not in, Not exists và Leftjoin.

-- Cách 1: Not in
SELECT
    pd.ProductID,
    pd.Name
FROM
    Production.Product pd
WHERE
    pd.ProductID NOT IN
    (
        SELECT
            sod.ProductID
        FROM
            Sales.SalesOrderDetail sod
    )

-- Cách 2: Not exists
SELECT
    pd.ProductID,
    pd.Name
FROM
    Production.Product pd
WHERE
    NOT EXISTS
    (
        SELECT
            sod.ProductID
        FROM
            Sales.SalesOrderDetail sod
        WHERE
            pd.ProductID = sod.ProductID
    )

-- Cách 3: Left join
SELECT
    pd.ProductID,
    pd.Name
FROM
    Production.Product pd
    LEFT JOIN Sales.SalesOrderDetail sod ON pd.ProductID = sod.ProductID
WHERE
    sod.ProductID IS NULL

-- 9)Liệt kê các nhân viên không lập hóa đơn từ sau ngày 1/5/2008,
-- thông tin gồm EmployeeID,   FirstName,   LastName   (dữ   liệu từ   2   bảng HumanResources.Employees và Sales.SalesOrdersHeader)

SELECT
    e.BusinessEntityID AS Employee,
    p.FirstName,
    p.LastName
FROM
    HumanResources.Employee e
    JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
WHERE
    e.BusinessEntityID NOT IN
    (
        SELECT
            soh.SalesPersonID
        FROM
            Sales.SalesOrderHeader soh
        WHERE
            soh.OrderDate > '2008-05-01'
    )


-- 10) Liệt kê danh sách các khách hàng (CustomerID,Name) có hóa đơn dặt hàng trong năm 2007
-- nhưng không có hóa đơn đặt hàng trong năm 2008

SELECT
    p.BusinessEntityID AS Customer,
    p.FirstName + ' ' + p.LastName AS Name
FROM
    Person.Person p
WHERE
    p.BusinessEntityID IN
    (
        SELECT
            soh.CustomerID
        FROM
            Sales.SalesOrderHeader soh
        WHERE
            YEAR(soh.OrderDate) = 2007
    )
    AND p.BusinessEntityID NOT IN
    (
        SELECT
            soh.CustomerID
        FROM
            Sales.SalesOrderHeader soh
        WHERE
            YEAR(soh.OrderDate) = 2008
    )
