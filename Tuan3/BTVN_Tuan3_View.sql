USE AdventureWorks2008R2 

--1) Tạo view dbo.vw_Products hiển thị danh sách các sản phẩm từ bảng
--Production.Product và bảng Production.ProductCostHistory. Thông tin bao gồm
--ProductID, Name, Color, Size, Style, StandardCost, EndDate, StartDate
CREATE VIEW dbo.vw_Products AS
SELECT 
	p.ProductID,
	p.Name,
	p.Color,
	p.Size,
	p.Style,
	pch.StandardCost,
	pch.EndDate,
	pch.StartDate
FROM
	Production.Product p
	JOIN Production.ProductCostHistory pch ON p.ProductID = pch.ProductID

SELECT * FROM dbo.vw_Products
	
--2) Tạo view List_Product_View chứa danh sách các sản phẩm có trên 500 đơn đặt
--hàng trong quí 1 năm 2008 và có tổng trị giá >10000, thông tin gồm ProductID,
--Product_Name, CountOfOrderID và SubTotal.

CREATE VIEW List_Product_View AS
SELECT 
	p.ProductID,
	p.Name AS Product_Name,
	COUNT(sod.SalesOrderID) AS CountOfOrderID,
	SUM(soh.SubTotal) AS SubTotal
FROM 
	Production.Product p 
	JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
	JOIN Sales.SalesOrderHeader soh ON soh.SalesOrderID = sod.SalesOrderID
WHERE 
	MONTH(soh.OrderDate) IN (1,2,3)
	AND YEAR(soh.OrderDate) = 2008 
GROUP BY 
	p.ProductID,
	p.Name
HAVING
	SUM(sod.LineTotal) > 1000

SELECT * FROM List_Product_View

--3) Tạo view dbo.vw_CustomerTtals hiển thị tổng tiền bán được (total sales) từ cột
--TotalDue của mỗi khách hàng (customer) theo tháng và theo năm. Thông tin gồm
--CustomerID, YEAR(OrderDate) AS OrderYear, MONTH(OrderDate) AS
--OrderMonth, SUM(TotalDue).

CREATE VIEW dbo.vw_CustomerTotals AS 
SELECT 
	soh.CustomerID,
	YEAR(soh.OrderDate) AS OrderYear,
	MONTH(soh.OrderDate) AS OrderMonth,
	SUM(soh.TotalDue) AS TotalDue
FROM 
	Sales.Customer c
	JOIN Person.Person p ON p.BusinessEntityID = c.PersonID
	JOIN Sales.SalesOrderHeader soh ON soh.CustomerID = c.PersonID
GROUP BY
	soh.CustomerID,
	YEAR(soh.OrderDate),
	MONTH(soh.OrderDate)
GO

SELECT * FROM dbo.vw_CustomerTotals
GO

--4) Tạo view trả về tổng số lượng sản phẩm (Total Quantity) bán được của mỗi nhân
--viên theo từng năm. Thông tin gồm SalesPersonID, OrderYear, sumOfOrderQty
CREATE VIEW  Total_SP AS
SELECT 
	soh.SalesPersonID,
	YEAR(soh.OrderDate) AS OrderYear,
	SUM(sod.OrderQty) AS OrderQty 
FROM
	Sales.SalesOrderHeader soh
	JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID 
GROUP BY
	soh.SalesPersonID,
	YEAR(soh.OrderDate)

SELECT * FROM Total_SP

--5) Tạo view ListCustomer_view chứa danh sách các khách hàng có trên 25 hóa đơn
--đặt hàng từ năm 2007 đến 2008, thông tin gồm mã khách (PersonID) , họ tên
--(FirstName +' '+ LastName as FullName), Số hóa đơn (CountOfOrders).

CREATE VIEW ListCustomer_view AS
SELECT 
	p.BusinessEntityID AS PersonID,
	p.FirstName + ' ' + p.LastName AS FullName,
	COUNT(soh.SalesOrderID) AS CountOfOrder

FROM 
	Person.Person p 
	JOIN Sales.SalesOrderHeader soh ON p.BusinessEntityID = soh.CustomerID
WHERE
	YEAR(OrderDate) IN (2007, 2008)
GROUP BY
	p.BusinessEntityID,
	p.FirstName + ' ' + p.LastName
HAVING
	COUNT(soh.SalesOrderID) > 25
GO

SELECT * FROM ListCustomer_view

--6) Tạo view ListProduct_view chứa danh sách những sản phẩm có tên bắt đầu với
--‘Bike’ và ‘Sport’ có tổng số lượng bán trong mỗi năm trên 50 sản phẩm, thông
--tin gồm ProductID, Name, SumOfOrderQty, Year. 
--(dữ liệu lấy từ các bảng Sales.SalesOrderHeader, Sales.SalesOrderDetail, và Production.Product)
CREATE VIEW ListProduct_view AS
SELECT 
	p.ProductID AS ProductID,
	p.Name AS Name,
	SUM(sod.OrderQty) AS SumOfOrderQty,
	YEAR(OrderDate) AS YEAR
FROM 
	Production.Product p
	JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
	JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID =soh.SalesOrderID
WHERE 
	p.Name LIKE 'Bike%' OR p.Name LIKE 'Sport%'  
GROUP BY
	p.ProductID,
	p.Name,
	YEAR(OrderDate)
HAVING
	SUM(sod.OrderQty) > 50
GO

SELECT * FROM ListProduct_view
	
--7) Tạo view List_department_View chứa danh sách các phòng ban có lương (Rate:
--lương theo giờ) trung bình >30, thông tin gồm Mã phòng ban (DepartmentID),
--tên phòng ban (Name), Lương trung bình (AvgOfRate). Dữ liệu từ các bảng
--[HumanResources].[Department],
--[HumanResources].[EmployeeDepartmentHistory],
--[HumanResources].[EmployeePayHistory].
CREATE VIEW List_department_View AS 
SELECT 
	edh.DepartmentID ,
	p.Name AS Name,
	AVG(eph.Rate) AS AvgOfRate
	
FROM 
	HumanResources.Department p
	JOIN HumanResources.EmployeeDepartmentHistory edh ON p.DepartmentID = edh.DepartmentID
	JOIN HumanResources.EmployeePayHistory eph ON edh.BusinessEntityID = eph.BusinessEntityID

GROUP BY 
	edh.DepartmentID, p.Name
HAVING
	AVG(eph.Rate) > 30
GO

SELECT * FROM List_department_View

--8) Tạo view Sales.vw_OrderSummary với từ khóa WITH ENCRYPTION gồm
--OrderYear (năm của ngày lập), OrderMonth (tháng của ngày lập), OrderTotal
--(tổng tiền). Sau đó xem thông tin và trợ giúp về mã lệnh của view này
CREATE VIEW Sales.vw_OrderSummary 
WITH ENCRYPTION 
AS
SELECT 
	YEAR(sod.OrderDate) AS YEAR,
	MONTH(sod.OrderDate) AS MONTH,
	SUM(sod.TotalDue) AS TotalMoney
FROM
	Sales.SalesOrderHeader sod
GROUP BY 
	YEAR(sod.OrderDate),MONTH(sod.OrderDate)
GO 

SELECT * FROM Sales.vw_OrderSummary

--9) Tạo view Production.vwProducts với từ khóa WITH SCHEMABINDING
--gồm ProductID, Name, StartDate,EndDate,ListPrice của bảng Product và bảng
--ProductCostHistory. Xem thông tin của View. Xóa cột ListPrice của bảng
--Product. Có xóa được không? Vì sao?
CREATE VIEW Production.vwProducts
AS
SELECT 
	p.ProductID,
	p.Name,
	pch.StartDate,
	pch.EndDate,
	p.ListPrice
FROM
	Production.Product p
	JOIN Production.ProductCostHistory pch ON p.ProductID = pch.ProductID
WITH SCHEMABINDING
GO

SELECT * FROM Production.vwProducts
/* không thể xóa cột ListPrice của bảng Product vì view đã được tạo với từ khóa WITH SCHEMABINDING */


--10) Tạo view view_Department với từ khóa WITH CHECK OPTION chỉ chứa các
--phòng thuộc nhóm có tên (GroupName) là “Manufacturing” và “Quality
--Assurance”, thông tin gồm: DepartmentID, Name, GroupName.
CREATE VIEW view_Department
AS
SELECT 
	p.DepartmentID,
	p.Name,
	p.GroupName
FROM 
	HumanResources.Department p
WHERE 
	p.GroupName IN ('Manufacturing','Quality')
WITH CHECK OPTION

--a. Chèn thêm một phòng ban mới thuộc nhóm không thuộc hai nhóm
--“Manufacturing” và “Quality Assurance” thông qua view vừa tạo. Có
--chèn được không? Giải thích.
INSERT INTO view_Department (p.Name, p.GroupName)
VALUES ('HT','a')
/* Không chèn được vì view chỉ chứa các phòng thuộc nhóm có tên (GroupName) là “Manufacturing” và “Quality Assurance” */

--b. Chèn thêm một phòng mới thuộc nhóm “Manufacturing” và một phòng thuộc nhóm “Quality Assurance”.
INSERT INTO view_Department ( p.Name, p.GroupName)
VALUES ('HT','Manufacturing')

--c. Dùng câu lệnh Select xem kết quả trong bảng Department.
SELECT * FROM HumanResources.Department
GO

