USE AdventureWorks2008R2
GO

--1) Viết một thủ tục tính tổng tiền thu (TotalDue) của mỗi khách hàng trong một
--tháng bất kỳ của một năm bất kỳ (tham số tháng và năm) được nhập từ bàn phím,
--thông tin gồm: CustomerID, SumOfTotalDue =Sum(TotalDue)

CREATE PROC sp_totaldueByMonth
@CustomerID int, @Month int, @Year int
AS
SELECT
	CustomerID,
	SumOfTotalDue = Sum(TotalDue)
FROM
	Sales.SalesOrderHeader
WHERE
	CustomerID = @CustomerID AND
	MONTH(OrderDate) = @Month AND
	YEAR(OrderDate) = @Year
GROUP BY
	CustomerID
GO

EXEC sp_totaldueByMonth 29825, 1, 2008
GO

--2) Viết một thủ tục dùng để xem doanh thu từ đầu năm cho đến ngày hiện tại của
--một nhân viên bất kỳ, với một tham số đầu vào và một tham số đầu ra. Tham số
--@SalesPerson nhận giá trị đầu vào theo chỉ định khi gọi thủ tục, tham số
-- @SalesYTD được sử dụng để chứa giá trị trả về của thủ tục. 

CREATE PROC sp_saleytd
@SalesPerson int, @SalesYTD money OUTPUT
AS
SELECT
	@SalesYTD = SalesYTD
FROM
	Sales.SalesPerson
WHERE
	BusinessEntityID = @SalesPerson
GO


DECLARE @SalesYTD money
EXEC sp_saleytd 278, @SalesYTD OUTPUT
PRINT @SalesYTD
GO


-- 3) Viết một thủ tục trả về một danh sách ProductID, ListPrice của các sản phẩm có
--giá bán không vượt quá một giá trị chỉ định (tham số input @MaxPrice).

CREATE PROC sp_listPrice
	@MaxPrice money
AS
SELECT
	ProductID,
	ListPrice
FROM
	Production.Product
WHERE
	ListPrice <= @MaxPrice
GO

EXEC sp_listPrice 1000
GO

--4) Viết thủ tục tên NewBonus cập nhật lại tiền thưởng (Bonus) cho 1 nhân viên bán
--hàng (SalesPerson), dựa trên tổng doanh thu của nhân viên đó. Mức thưởng mới
--bằng mức thưởng hiện tại cộng thêm 1% tổng doanh thu. Thông tin bao gồm
--[SalesPersonID], NewBonus (thưởng mới), SumOfSubTotal. Trong đó:
--SumOfSubTotal =sum(SubTotal)
--NewBonus = Bonus+ sum(SubTotal)*0.01

CREATE PROC sp_NewBonus
@SalesPerson int
AS
BEGIN
	DECLARE @sumSubTotal money, @newBonus money
	SELECT @sumSubTotal = SUM(SubTotal) FROM Sales.SalesOrderHeader WHERE SalesPersonID = @SalesPerson
	SET @newBonus = (SELECT Bonus FROM Sales.SalesPerson WHERE BusinessEntityID = @SalesPerson) + @sumSubTotal * 0.01
	UPDATE Sales.SalesPerson SET Bonus = @newBonus WHERE BusinessEntityID = @SalesPerson
	SELECT
		@SalesPerson AS SalesPersonID,
		@sumSubTotal AS SumOfSubTotal,
		@newBonus AS NewBonus
END
GO

EXEC sp_NewBonus 278
GO
	
--5) Viết một thủ tục dùng để xem thông tin của nhóm sản phẩm (ProductCategory)
--có tổng số lượng (OrderQty) đặt hàng cao nhất trong một năm tùy ý (tham số
--input), thông tin gồm: ProductCategoryID, Name, SumOfQty. Dữ liệu từ bảng
--ProductCategory, ProductSubCategory, Product và SalesOrderDetail.
--(Lưu ý: dùng Sub Query)

CREATE PROC sp_ProductCategory
@year int
AS
SELECT TOP 1
	*
FROM (
	SELECT
		pc.ProductCategoryID,
		pc.Name,
		SUM(sod.OrderQty) as SumOfQty
	FROM
		Production.Product p
		JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
		JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
		JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
		JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
	WHERE
		YEAR(soh.OrderDate) = @year
	GROUP BY
		pc.ProductCategoryID, YEAR(soh.OrderDate), pc.Name
) AS CategorySales
ORDER BY
	SumOfQty DESC
GO

EXEC sp_ProductCategory 2008
GO

--6) Tạo thủ tục đặt tên là TongThu có tham số vào là mã nhân viên, tham số đầu ra
--là tổng trị giá các hóa đơn nhân viên đó bán được. Sử dụng lệnh RETURN để trả
--về trạng thái thành công hay thất bại của thủ tục.

CREATE PROC sp_TongThu
@SalesPerson int, @Total money OUTPUT
AS
BEGIN
	SELECT @Total = SUM(SubTotal) FROM Sales.SalesOrderHeader WHERE SalesPersonID = @SalesPerson
	IF @Total IS NOT NULL
		RETURN 0
	ELSE
		RETURN 1
END
GO

DECLARE @Total money
EXEC sp_TongThu 278, @Total OUTPUT
PRINT @Total
GO


--7) Tạo thủ tục hiển thị tên và số tiền mua của cửa hàng mua nhiều hàng nhất theo
--năm đã cho.

CREATE PROC sp_BestCustomer
@year int
AS
SELECT TOP 1
	s.Name,
	SUM(soh.TotalDue) AS TotalDue
FROM
	Sales.SalesOrderHeader soh
	JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
	JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
WHERE
	YEAR(soh.OrderDate) = @year
GROUP BY
	c.StoreID, s.Name
ORDER BY
	SUM(soh.TotalDue) DESC
GO

EXEC sp_BestCustomer 2008
GO

--8) Viết thủ tục Sp_InsertProduct có tham số dạng input dùng để chèn một mẫu tin
--vào bảng Production.Product. Yêu cầu: chỉ thêm vào các trường có giá trị not
--null và các field là khóa ngoại.



--9) Viết thủ tục XoaHD, dùng để xóa 1 hóa đơn trong bảng Sales.SalesOrderHeader
--khi biết SalesOrderID. Lưu ý : trước khi xóa mẫu tin trong
--Sales.SalesOrderHeader thì phải xóa các mẫu tin của hoá đơn đó trong
--Sales.SalesOrderDetail.

CREATE PROC sp_XoaHD
@SalesOrderID int
AS
BEGIN
	DELETE FROM Sales.SalesOrderDetail WHERE SalesOrderID = @SalesOrderID
	DELETE FROM Sales.SalesOrderHeader WHERE SalesOrderID = @SalesOrderID
END
GO

EXEC sp_XoaHD 43659
GO

--10)Viết thủ tục Sp_Update_Product có tham số ProductId dùng để tăng listprice
--lên 10% nếu sản phẩm này tồn tại, ngược lại hiện thông báo không có sản phẩm
--này.

CREATE PROC sp_Update_Product
@ProductID int
AS
BEGIN
	IF EXISTS (SELECT * FROM Production.Product WHERE ProductID = @ProductID)
		UPDATE Production.Product SET ListPrice = ListPrice * 1.1 WHERE ProductID = @ProductID
	ELSE
		PRINT N'Không có sản phẩm này'
END
GO

EXEC sp_Update_Product 1
GO