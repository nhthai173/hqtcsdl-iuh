use AdventureWorks2008R2
-- I) Batch
-- 1) Viết một batch khai báo biến @tongsoHD chứa tổng số hóa đơn của sản phẩm
-- có ProductID=’778’; nếu @tongsoHD>500 thì in ra chuỗi “Sản phẩm 778 có
-- trên 500 đơn hàng”, ngược lại thì in ra chuỗi “Sản phẩm 778 có ít đơn đặt
-- hàng”

Declare @tongsoHD int 

SELECT
	@tongsoHD = COUNT(sod.SalesOrderID)
FROM 
    Production.Product p
	JOIN Sales.SalesOrderDetail sod on p.ProductID = sod.ProductID
WHERE sod.SalesOrderID = '778'


IF @tongsoHD > 500
	Print 'Sản phẩm 778 có có  trên 500 đơn hàng'
ELSE 
	Print 'Sản phẩm 778 có ít đơn đặt hàng'

GO

-- 2) Viết một đoạn Batch với 
-- tham số @makh và @n chứa số hóa đơn của khách hàng @makh,
-- tham số @nam chứa năm lập hóa đơn (ví dụ @nam=2008), 
-- nếu @n>0 thì in ra chuỗi: “Khách hàng @makh có @n hóa đơn trong năm 2008”
-- ngược lại nếu @n=0 thì in ra chuỗi “Khách hàng @makh không có hóa đơn nào trong năm 2008”



DECLARE @makh int , @n int, @nam int;
SET @makh = 11073
SET @nam = 2008
SELECT @n = count(soh.CustomerID)
FROM Sales.SalesOrderHeader soh
WHERE CustomerID = @makh AND YEAR(OrderDate) = @nam 
IF @n > 0
	Print N'Khách hàng ' + CAST(@makh AS VARCHAR) + N' có ' + CAST(@n AS VARCHAR) + N' hóa đơn trong năm ' + CAST(@nam AS VARCHAR)
ELSE IF @n = 0
	Print N'Khách hàng ' + CAST(@makh AS VARCHAR) + N' không có hóa đơn nào trong năm ' + CAST(@nam AS VARCHAR)
GO



-- 3) Viết một batch tính số tiền giảm cho những hóa đơn (SalesOrderID) có tổng
-- tiền>100000, thông tin gồm [SalesOrderID], SubTotal=SUM([LineTotal]),
-- Discount (tiền giảm), với Discount được tính như sau:
--  Những hóa đơn có SubTotal<100000 thì không giảm,
--  SubTotal từ 100000 đến <120000 thì giảm 5% của SubTotal
--  SubTotal từ 120000 đến <150000 thì giảm 10% của SubTotal
--  SubTotal từ 150000 trở lên thì giảm 15% của SubTotal
--(Gợi ý: Dùng cấu trúc Case… When …Then …)
	SELECT 
		sod.SalesOrderID,
		SubTotal = Sum(sod.LineTotal),
		case
			when Sum(sod.LineTotal) >= 150000 then 0.15 * Sum(sod.LineTotal)
			when Sum(sod.LineTotal) >= 120000 then 0.1 * Sum(sod.LineTotal)
			when Sum(sod.LineTotal) >= 100000 then 0.05 * Sum(sod.LineTotal)
			else 0
		end as Discount
	FROM Sales.SalesOrderDetail sod
	GROUP BY sod.SalesOrderID
	HAVING Sum(sod.LineTotal) > 1000
	ORDER BY Sum(sod.LineTotal) DESC


--4) Viết một Batch với 3 tham số: @mancc, @masp, @soluongcc, 
-- chứa giá trị của các field [ProductID],[BusinessEntityID],[OnOrderQty], 
-- với giá trị truyền cho các biến @mancc, @masp (vd: @mancc=1650, @masp=4), 
-- thì chương trình sẽ gán giá trị tương ứng của field [OnOrderQty] cho biến @soluongcc, 
-- nếu @soluongcc trả về giá trị là null thì in ra chuỗi “Nhà cung cấp 1650 không cungcấp sản phẩm 4”, 
-- ngược lại (vd: @soluongcc=5) thì in chuỗi “Nhà cung cấp 1650
-- cung cấp sản phẩm 4 với số lượng là 5”
--(Gợi ý: Dữ liệu lấy từ [Purchasing].[ProductVendor])
DECLARE @mancc int , @masp int , @soluongcc int
SET @mancc = 1580
SET @masp = 1
SELECT 
	@soluongcc = pv.OnOrderQty
FROM Purchasing.ProductVendor pv
WHERE 	@mancc = pv.BusinessEntityID AND  @masp = pv.ProductID
IF @soluongcc  is NUll
	Print N'Nhà cấp ' + CAST(@mancc AS VARCHAR)+ N' không cung cấp sản phẩm ' +  CAST(@masp AS VARCHAR)
ELSE 
	Print N'Nhà cung cấp '+ CAST(@mancc AS VARCHAR) + N' cung cấp sản phẩm 4 với số lượng là ' +  CAST(@soluongcc AS VARCHAR)

	SELECT * FROM Purchasing.ProductVendor

--5) Viết một batch thực hiện tăng lương giờ (Rate) của nhân viên trong
--[HumanResources].[EmployeePayHistory] theo điều kiện sau: 
--Khi tổng lương giờ của tất cả nhân viên Sum(Rate)<6000 thì cập nhật tăng lương giờ lên 10%,
--nếu sau khi cập nhật mà lương giờ cao nhất của nhân viên >150 thì dừng.


IF (SELECT  SUM(Rate) FROM [HumanResources].[EmployeePayHistory]) < 6000
BEGIN
	IF (SELECT MAX(Rate * 1.1) FROM [HumanResources].[EmployeePayHistory]) <= 150
	BEGIN
		UPDATE [HumanResources].[EmployeePayHistory] SET Rate = Rate * 1.1
	END
	ELSE
	BEGIN
		PRINT 'DMM'
	END
END