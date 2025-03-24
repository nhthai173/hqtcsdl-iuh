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


-- 2) Liệt kê các sản phẩm (ProductID, Name) có số hóa đơn đặt hàng nhiều nhất
-- trong tháng 7/2008

SELECT
    p.ProductID,
    p.Name,
    COUNT(sod.SalesOrderID)
FROM
    Sales.SalesOrderHeader soh
    JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
    JOIN Production.Product p ON p.ProductID = sod.ProductID
WHERE
    MONTH(soh.OrderDate) = 7
    AND YEAR(soh.OrderDate) = 2008
GROUP BY
    p.ProductID,
    p.Name
HAVING
    COUNT(sod.SalesOrderID) >= ALL ( SELECT COUNT(sod.SalesOrderID)
                                    FROM Sales.SalesOrderHeader soh
                                    JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
                                    JOIN Production.Product p ON p.ProductID = sod.ProductID
                                    WHERE MONTH(soh.OrderDate) = 7 AND YEAR(soh.OrderDate) = 2008
                                    GROUP BY p.ProductID, p.Name)


-- 3) Hiển thị thông tin của khách hàng có số đơn đặt hàng nhiều nhất, thông tin gồm:
-- CustomerID, Name, CountOfOrder

SELECT 
	 c.CustomerID,
	 p.FirstName +' '+ p.LastName AS FullName,
	 COUNT(soh.SalesOrderID) AS CountOfOrder
FROM Sales.Customer c
	 JOIN Person.Person p ON p.BusinessEntityID = c.PersonID
	 JOIN Sales.SalesOrderHeader soh ON soh.CustomerID = c.CustomerID
GROUP BY 
	c.CustomerID,
	p.FirstName +' '+ p.LastName
HAVING COUNT(soh.SalesOrderID) >= ALL(  SELECT  COUNT(soh.SalesOrderID)
										FROM Sales.Customer c
                                        JOIN Person.Person p ON p.BusinessEntityID = c.PersonID
                                        JOIN Sales.SalesOrderHeader soh ON soh.CustomerID = c.CustomerID
										GROUP BY c.CustomerID)



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





--5) Tìm các mô hình sản phẩm (ProductModelID) mà giá niêm yết (list price) tối
--đa cao hơn giá trung bình của tất cả các mô hình.

SELECT
	pm.Name,
	MAX(ListPrice) AS MaxListPrice
FROM Production.Product p 
	JOIN Production.ProductModel pm ON pm.ProductModelID = p.ProductModelID
GROUP BY
	pm.Name
HAVING
	MAX(ListPrice) > (SELECT AVG(ListPrice) FROM Production.Product p)




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




-- 7)Liệt kê những sản phẩm (ProductID, UnitPrice) có đơn giá (UnitPrice) cao nhất trong bảng Sales.SalesOrderDetail

SELECT
    DISTINCT pd.ProductID,
    sod.UnitPrice
FROM
    Production.Product pd
    JOIN Sales.SalesOrderDetail sod ON pd.ProductID = sod.ProductID
WHERE
    sod.UnitPrice = (SELECT MAX(sod1.UnitPrice) FROM Sales.SalesOrderDetail sod1)




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
    e.BusinessEntityID AS EmployeeID,
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
