USE [AdventureWorks2008R2]
GO
--I) Batch
--1) Viết một batch khai báo biến @tongsoHD chứa tổng số hóa đơn của sản phẩm
--có ProductID=’778’; nếu @tongsoHD>500 thì in ra chuỗi “Sản phẩm 778 có
--trên 500 đơn hàng”, ngược lại thì in ra chuỗi “Sản phẩm 778 có ít đơn đặt
--hàng”

DECLARE @tongsoHD INT
SELECT @tongsoHD = COUNT(SalesOrderID) FROM Sales.SalesOrderDetail WHERE ProductID = '778'
IF @tongsoHD > 500
BEGIN
    PRINT N'Sản phẩm 778 có trên 500 đơn hàng'
END
ELSE
BEGIN
    PRINT N'Sản phẩm 778 có ít đơn đặt hàng'
END
GO


--2) Viết một đoạn Batch với tham số @makh và @n chứa số hóa đơn của khách
--hàng @makh, tham số @nam chứa năm lập hóa đơn (ví dụ @nam=2008), nếu
--@n>0 thì in ra chuỗi: “Khách hàng @makh có @n hóa đơn trong năm 2008”
--ngược lại nếu @n=0 thì in ra chuỗi “Khách hàng @makh không có hóa đơn nào
--trong năm 2008”

DECLARE @makh INT, @n INT, @nam INT
SELECT @makh = 24165, @nam = 2008
SELECT @n = COUNT(SalesOrderID) FROM Sales.SalesOrderHeader WHERE CustomerID = @makh AND YEAR(OrderDate) = @nam
IF @n > 0
BEGIN
    PRINT N'Khách hàng ' + CAST(@makh AS NVARCHAR(10)) + N' có ' + CAST(@n AS NVARCHAR(10)) + N' hóa đơn trong năm ' + CAST(@nam AS NVARCHAR(10))
END
ELSE
BEGIN
    PRINT N'Khách hàng ' + CAST(@makh AS NVARCHAR(10)) + N' không có hóa đơn nào trong năm ' + CAST(@nam AS NVARCHAR(10))
END
GO

--3) Viết một batch tính số tiền giảm cho những hóa đơn (SalesOrderID) có tổng
--tiền>100000, thông tin gồm [SalesOrderID], SubTotal=SUM([LineTotal]),
--Discount (tiền giảm), với Discount được tính như sau:
-- Những hóa đơn có SubTotal<100000 thì không giảm,
-- SubTotal từ 100000 đến <120000 thì giảm 5% của SubTotal
-- SubTotal từ 120000 đến <150000 thì giảm 10% của SubTotal
-- SubTotal từ 150000 trở lên thì giảm 15% của SubTotal
--(Gợi ý: Dùng cấu trúc Case… When …Then …)

SELECT
    SalesOrderID,
    SubTotal = SUM(LineTotal),
    CASE
        WHEN SUM(LineTotal) >= 150000 THEN SUM(LineTotal) * 0.15
        WHEN SUM(LineTotal) >= 120000 THEN SUM(LineTotal) * 0.10
        WHEN SUM(LineTotal) >= 100000 THEN SUM(LineTotal) * 0.05
        ELSE 0
    END AS Discount
FROM
    Sales.SalesOrderDetail
GROUP BY
    SalesOrderID
ORDER BY
    Discount DESC
GO

--4) Viết một Batch với 3 tham số: @mancc, @masp, @soluongcc, chứa giá trị của
--các field [ProductID],[BusinessEntityID],[OnOrderQty], với giá trị truyền cho
--các biến @mancc, @masp (vd: @mancc=1650, @masp=4), thì chương trình sẽ
--gán giá trị tương ứng của field [OnOrderQty] cho biến @soluongcc, nếu
--@soluongcc trả về giá trị là null thì in ra chuỗi “Nhà cung cấp 1650 không cung
--cấp sản phẩm 4”, ngược lại (vd: @soluongcc=5) thì in chuỗi “Nhà cung cấp 1650
--cung cấp sản phẩm 4 với số lượng là 5”
--(Gợi ý: Dữ liệu lấy từ [Purchasing].[ProductVendor])

Declare @mancc int, @masp int, @soluongcc int
Select @mancc=1688, @masp=2
Select
	@soluongcc = OnOrderQty
From
	[Purchasing].[ProductVendor]
Where
	ProductID = @masp AND BusinessEntityID = @mancc
IF @soluongcc IS NULL
BEGIN
	PRINT N'Nhà cung cấp ' + CAST(@mancc AS NVARCHAR) + N' không cung cấp sản phẩm ' + CAST(@masp AS NVARCHAR)
END
ELSE
BEGIN
	PRINT N'Nhà cung cấp ' + CAST(@mancc AS NVARCHAR) + N' cung cấp sản phẩm ' + CAST(@masp AS NVARCHAR) + N' với số lượng là ' + CAST(@soluongcc AS NVARCHAR)
END
GO

--5) Viết một batch thực hiện tăng lương giờ (Rate) của nhân viên trong
--[HumanResources].[EmployeePayHistory] theo điều kiện sau: Khi tổng lương
--giờ của tất cả nhân viên Sum(Rate)<6000 thì cập nhật tăng lương giờ lên 10%,
--nếu sau khi cập nhật mà lương giờ cao nhất của nhân viên >150 thì dừng.

WHILE (SELECT SUM(rate) FROM [HumanResources].[EmployeePayHistory]) < 6000
BEGIN
	UPDATE [HumanResources].[EmployeePayHistory] SET rate = rate * 1.1
	IF (SELECT MAX(rate) FROM [HumanResources].[EmployeePayHistory]) > 150
		BREAK
	ELSE
		CONTINUE
END