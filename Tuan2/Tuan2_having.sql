-- 1) Liệt kê danh sách các hóa đơn (SalesOrderID) lập trong tháng 6 năm 2008 có
-- tổng tiền >70000, thông tin gồm SalesOrderID, Orderdate, SubTotal, trong đó SubTotal =SUM(OrderQty*UnitPrice).

USE AdventureWorks2008R2

SELECT
    soh.SalesOrderID,
    soh.OrderDate,
    SUM(sod.OrderQty * sod.UnitPrice) AS SubTotal
FROM
    [Sales].[SalesOrderHeader] AS soh
    JOIN [Sales].[SalesOrderDetail] sod
        ON soh.SalesOrderID = sod.SalesOrderID
WHERE
    YEAR(soh.OrderDate) = 2008
    AND MONTH(soh.OrderDate) = 6
GROUP BY
    soh.SalesOrderID,
    soh.OrderDate
HAVING
    SUM(sod.OrderQty * sod.UnitPrice) > 70000


-- 2) 
-- Đếm tổng số khách hàng và tổng tiền của những khách hàng thuộc các quốc gia
-- có mã vùng là US (lấy thông tin từ các bảng Sales.SalesTerritory,
-- Sales.Customer, Sales.SalesOrderHeader, Sales.SalesOrderDetail). Thông tin
-- bao gồm TerritoryID, tổng số khách hàng (CountOfCust), tổng tiền
-- (SubTotal) với SubTotal = SUM(OrderQty*UnitPrice)

SELECT
    c.TerritoryID,
    COUNT(DISTINCT c.CustomerID) AS CountOfCust,
    SUM(sod.OrderQty * sod.UnitPrice) AS SubTotal
FROM
    [Sales].[Customer] c
    JOIN [Sales].[SalesTerritory] st ON c.TerritoryID = st.TerritoryID
    JOIN [Sales].[SalesOrderHeader] soh ON soh.CustomerID = c.CustomerID
    JOIN [Sales].[SalesOrderDetail] sod ON sod.SalesOrderID = soh.SalesOrderID
WHERE
    st.CountryRegionCode = 'US'
GROUP BY
    c.TerritoryID


-- 3) Tính tổng trị giá của những hóa đơn với Mã theo dõi giao hàng
-- (CarrierTrackingNumber) có 3 ký tự đầu là 4BD, thông tin bao gồm
-- SalesOrderID, CarrierTrackingNumber, SubTotal=SUM(OrderQty*UnitPrice)

SELECT
    soh.SalesOrderID,
    sod.CarrierTrackingNumber,
    SUM(sod.OrderQty * sod.UnitPrice) AS SubTotal
FROM
    [Sales].[SalesOrderHeader] soh
    JOIN [Sales].[SalesOrderDetail] sod
        ON soh.SalesOrderID = sod.SalesOrderID
WHERE
    sod.CarrierTrackingNumber LIKE '4BD%'
GROUP BY
    soh.SalesOrderID,
    sod.CarrierTrackingNumber



-- 4) Liệt kê các sản phẩm (Product) có đơn giá (UnitPrice)<25 và số lượng bán
-- trung bình >5, thông tin gồm ProductID, Name, AverageOfQty.


SELECT
    p.ProductID,
    p.Name,
    AVG(sod.OrderQty) AS AverageOfQty
FROM
    [Production].[Product] p
    JOIN [Sales].[SalesOrderDetail] sod
        ON p.ProductID = sod.ProductID
WHERE
    sod.UnitPrice < 25
GROUP BY
    p.ProductID,
    p.Name
HAVING
    AVG(sod.OrderQty) > 5


-- 5) Liệt kê các công việc (JobTitle) có tổng số nhân viên >20 người, thông tin gồm
-- JobTitle, C ountOfPerson=Count(*)

SELECT
    e.JobTitle,
    COUNT(*) AS CountOfPerson
FROM
    [HumanResources].[Employee] e
GROUP BY
    e.JobTitle
HAVING
    COUNT(*) > 20


-- 6) Tính tổng số lượng và tổng trị giá của các sản phẩm do các nhà cung cấp có tên
-- kết thúc bằng ‘Bicycles’ và tổng trị giá > 800000, thông tin gồm
-- BusinessEntityID, Vendor_Name, ProductID, SumOfQty, SubTotal
-- (sử dụng các bảng [Purchasing].[Vendor], [Purchasing].[PurchaseOrderHeader] và [Purchasing].[PurchaseOrderDetail])

SELECT
    v.BusinessEntityID,
    v.Name AS Vendor_Name,
    pod.ProductID,
    SUM(pod.OrderQty) AS SumOfQty,
    SUM(pod.LineTotal) AS SubTotal
FROM
    [Purchasing].[PurchaseOrderHeader] poh
    JOIN [Purchasing].[PurchaseOrderDetail] pod
        ON poh.PurchaseOrderID = pod.PurchaseOrderID
    JOIN [Purchasing].[ProductVendor] pv
        ON pod.ProductID = pv.ProductID
    JOIN [Purchasing].[Vendor] v
        ON pv.BusinessEntityID = v.BusinessEntityID
GROUP BY
    pod.ProductID,
    v.BusinessEntityID,
    v.Name
HAVING
    v.Name LIKE '%Bicycles'
    AND SUM(pod.LineTotal) > 800000


-- 7)
-- Liệt kê các sản phẩm có trên 500 đơn đặt hàng trong quí 1 năm 2008 và có tổng
-- trị giá >10000, thông tin gồm ProductID, Product_Name, CountOfOrderID và
-- SubTotal

SELECT
    p.ProductID,
    p.Name AS Product_Name,
    COUNT(pod.PurchaseOrderID) AS CountOfOrderID,
    SUM(pod.LineTotal) AS SubTotal
FROM
    [Production].[Product] p
    JOIN [Purchasing].[PurchaseOrderDetail] pod
        ON p.ProductID = pod.ProductID
    JOIN [Purchasing].[PurchaseOrderHeader] poh
        ON pod.PurchaseOrderID = poh.PurchaseOrderID
WHERE
    YEAR(poh.OrderDate) = 2008
    AND DATEPART(QUARTER, poh.OrderDate) = 1 -- MONTH(poh.OrderDate) IN (1, 2, 3)
GROUP BY
    p.ProductID,
    p.Name
HAVING
    COUNT(pod.PurchaseOrderID) > 500
    AND SUM(pod.LineTotal) > 10000


-- 8) Liệt kê danh sách các khách hàng có trên 25 hóa đơn đặt hàng từ năm 2007 đến
-- 2008, thông tin gồm mã khách (PersonID) , họ tên (FirstName +' '+ LastName
-- as FullName), Số hóa đơn (CountOfOrders).


SELECT
    c.PersonID,
    p.FirstName + ' ' + p.LastName AS FullName,
    COUNT(soh.SalesOrderID) AS CountOfOrders
FROM
    [Person].[Person] p
    JOIN [Sales].[Customer] c
        ON p.BusinessEntityID = c.PersonID
    JOIN [Sales].[SalesOrderHeader] soh
        ON c.CustomerID = soh.CustomerID
WHERE
    YEAR(soh.OrderDate) BETWEEN 2007 AND 2008
GROUP BY
    c.PersonID,
    p.FirstName + ' ' + p.LastName
HAVING
    COUNT(soh.SalesOrderID) > 25


-- 9) Liệt kê những sản phẩm có tên bắt đầu với ‘Bike’ và ‘Sport’ có tổng số lượng
-- bán trong mỗi năm trên 500 sản phẩm, thông tin gồm ProductID, Name,
-- CountOfOrderQty, Year. (Dữ liệu lấy từ các bảng Sales.SalesOrderHeader,
-- Sales.SalesOrderDetail và Production.Product)

SELECT
    p.ProductID,
    p.Name,
    SUM(sod.OrderQty) AS CountOfOrderQty,
    YEAR(soh.OrderDate) AS Year
FROM
    [Production].[Product] p
    JOIN [Sales].[SalesOrderDetail] sod
        ON p.ProductID = sod.ProductID
    JOIN [Sales].[SalesOrderHeader] soh
        ON sod.SalesOrderID = sod.SalesOrderID
GROUP BY
    p.ProductID,
    p.Name,
    YEAR(soh.OrderDate)
HAVING
    p.Name LIKE 'Bike%'
    OR p.Name LIKE 'Sport%'
    AND SUM(sod.OrderQty) > 500
ORDER BY Year



-- 10) Liệt kê những phòng ban có lương (Rate: lương theo giờ) trung bình >30, thông
-- tin gồm Mã phòng ban (DepartmentID), tên phòng ban (Name), Lương trung
-- bình (AvgofRate). Dữ liệu từ các bảng
-- [HumanResources].[Department],
-- [HumanResources].[EmployeeDepartmentHistory],
-- [HumanResources].[EmployeePayHistory].


SELECT
    d.DepartmentID,
    d.Name,
    AVG(eph.Rate) AS AvgofRate
FROM
    [HumanResources].[Department] d
    JOIN [HumanResources].[EmployeeDepartmentHistory] edh
        ON d.DepartmentID = edh.DepartmentID
    JOIN [HumanResources].[EmployeePayHistory] eph
        ON edh.BusinessEntityID = eph.BusinessEntityID
GROUP BY
    d.DepartmentID,
    d.Name
HAVING
    AVG(eph.Rate) > 30