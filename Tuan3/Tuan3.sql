--1) Tạo view dbo.vw_Products hiển thị danh sách các sản phẩm từ bảng
--Production.Product và bảng Production.ProductCostHistory. Thông tin bao gồm
--ProductID, Name, Color, Size, Style, StandardCost, EndDate, StartDate

USE AdventureWorks2008R2
GO

CREATE VIEW vw_Products
AS
	SELECT p.ProductID, p.Name, p.Color, p.Size, p.Style, pch.StandardCost, pch.EndDate, pch.StartDate
	FROM 
		[Production].[Product] p
	JOIN
		[Production].[ProductCostHistory] pch
	ON
		p.ProductID = pch.ProductID
GO


--2) Tạo view List_Product_View chứa danh sách các sản phẩm có trên 500 đơn đặt
--hàng trong quí 1 năm 2008 và có tổng trị giá >10000, thôn	g tin gồm ProductID,
--Product_Name, CountOfOrderID và SubTotal.

-- CREATE VIEW List_Product_View
-- AS	


SELECT 
	p.ProductID,
	p.Name AS 'Product_Name',
	COUNT(pod.PurchaseOrderID) AS 'CountOfOrderID',
	SUM(pod.LineTotal) AS 'SubTotal'
FROM
	[Production].[Product] p
	JOIN [Purchasing].[PurchaseOrderDetail] pod
		ON p.ProductID = pod.ProductID
	JOIN [Purchasing].[PurchaseOrderHeader] poh
		ON pod.PurchaseOrderID = poh.PurchaseOrderID
WHERE
	YEAR(poh.OrderDate) = 2008
	AND MONTH(poh.OrderDate) IN (1,2,3)
GROUP BY
	p.ProductID, p.Name
HAVING
	SUM(pod.LineTotal) > 10000
	--AND COUNT(pod.PurchaseOrderID) > 500



--3) Tạo view dbo.vw_CustomerTotals hiển thị tổng tiền bán được (total sales) từ cột
--TotalDue của mỗi khách hàng (customer) theo tháng và theo năm. Thông tin gồm
--CustomerID, YEAR(OrderDate) AS OrderYear, MONTH(OrderDate) AS
--OrderMonth, SUM(TotalDue).
--4) Tạo view trả về tổng số lượng sản phẩm (Total Quantity) bán được của mỗi nhân
--viên theo từng năm. Thông tin gồm SalesPersonID, OrderYear, sumOfOrderQty
--5) Tạo view ListCustomer_view chứa danh sách các khách hàng có trên 25 hóa đơn
--đặt hàng từ năm 2007 đến 2008, thông tin gồm mã khách (PersonID) , họ tên
--(FirstName +' '+ LastName as FullName), Số hóa đơn (CountOfOrders).
--6) Tạo view ListProduct_view chứa danh sách những sản phẩm có tên bắt đầu với
--‘Bike’ và ‘Sport’ có tổng số lượng bán trong mỗi năm trên 50 sản phẩm, thông tin
--gồm ProductID, Name, SumOfOrderQty, Year. (dữ liệu lấy từ các bảng
--Sales.SalesOrderHeader, Sales.SalesOrderDetail, và
--Production.Product)
--7) Tạo view List_department_View chứa danh sách các phòng ban có lương (Rate:
--lương theo giờ) trung bình >30, thông tin gồm Mã phòng ban (DepartmentID),
--tên phòng ban (Name), Lương trung bình (AvgOfRate). Dữ liệu từ các bảng
--[HumanResources].[Department],[HumanResources].[EmployeeDepartmentHistory],
--[HumanResources].[EmployeePayHistory].
--8) Tạo view Sales.vw_OrderSummary với từ khóa WITH ENCRYPTION gồm
--OrderYear (năm của ngày lập), OrderMonth (tháng của ngày lập), OrderTotal
--(tổng tiền). Sau đó xem thông tin và trợ giúp về mã lệnh của view này
--9) Tạo view Production.vwProducts với từ khóa WITH SCHEMABINDING
--gồm ProductID, Name, StartDate,EndDate,ListPrice của bảng Product và bảng
--ProductCostHistory. Xem thông tin của View. Xóa cột ListPrice của bảng
--Product. Có xóa được không? Vì sao?
--10) Tạo view view_Department với từ khóa WITH CHECK OPTION chỉ chứa các
--phòng thuộc nhóm có tên (GroupName) là “Manufacturing” và “Quality
--Assurance”, thông tin gồm: DepartmentID, Name, GroupName.
--a. Chèn thêm một phòng ban mới thuộc nhóm không thuộc hai nhóm
--“Manufacturing” và “Quality Assurance” thông qua view vừa tạo. Có
--chèn được không? Giải thích.
--b. Chèn thêm một phòng mới thuộc nhóm “Manufacturing” và một
--phòng thuộc nhóm “Quality Assurance”.
--c. Dùng câu lệnh Select xem kết quả trong bảng Department.