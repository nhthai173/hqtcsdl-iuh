CREATE DATABASE SmallWorks
ON PRIMARY 
(	NAME = 'SmallWorksPrimary',
	FILENAME = 'D:\HOC\HK8\TH_CSDL\Tuan1\SmallWorks.mdf',
	SIZE = 10MB,
	FILEGROWTH = 20%,
	MAXSIZE = 50MB	
),
FILEGROUP SWUserData1
(	NAME = 'SmallWorksData1',
	FILENAME = 'D:\HOC\HK8\TH_CSDL\Tuan1\SmallWorksData1.ndf',
	SIZE = 10MB,
	FILEGROWTH = 20%,
	MAXSIZE = 50MB
),
FILEGROUP SWUserData2
(	NAME = 'SmallWorksData2',
	FILENAME = 'D:\HOC\HK8\TH_CSDL\Tuan1\SmallWorksData2.ndf',
	SIZE = 10MB,
	FILEGROWTH = 20%,
	MAXSIZE = 50MB	
)
LOG ON
(	NAME = 'SmallWorks_	log',
	FILENAME = 'D:\HOC\HK8\TH_CSDL\Tuan1\SmallWorks_log.ldf',
	SIZE = 10MB,
	FILEGROWTH = 10%,
	MAXSIZE = 20MB
)

--3. Dùng SSMS để xem kết quả: Click phải trên tên của CSDL vừa tạo
--a. Chọn filegroups, quan sát kết quả:
-- Có bao nhiêu filegroup, liệt kê tên các filegroup hiện tại
-- Filegroup mặc định là gì?
	--Có 3 Filegroup
	--PRIMARY, SWUserData1, SWUserData2, SmallWorks_log.
	--
--b. Chọn file, quan sát có bao nhiêu database file?
	-- 4 database file : SmallWorksPrimary,	SmallWorksData1, SmallWorksData2, 	



--4. Dùng T-SQL tạo thêm một filegroup tên Test1FG1 trong SmallWorks, sau đó add
--thêm 2 file filedat1.ndf và filedat2.ndf dung lượng 5MB vào filegroup Test1FG1.
--Dùng SSMS xem kết quả.
Use SmallWorks

ALTER DATABASE SmallWorks
ADD FILEGROUP Test1FG1

ALTER DATABASE SmallWorks
ADD FILE
(
	NAME = 'filedat1',
	FILENAME = 'D:\HOC\HK8\TH_CSDL\Tuan1\filedat1.ndf',
	SIZE = 5MB
) TO FILEGROUP Test1FG1 

ALTER DATABASE SmallWorks
ADD FILE 
(	NAME = 'filedat2',
	FILENAME = 'D:\HOC\HK8\TH_CSDL\Tuan1\filedat2.ndf',
	SIZE = 5MB
) TO FILEGROUP Test1FG1 


--5. Dùng T-SQL tạo thêm một một file thứ cấp filedat3.ndf dung lượng 3MB trong
--filegroup Test1FG1. Sau đó sửa kích thước tập tin này lên 5MB. Dùng SSMS xem
--kết quả. Dùng T-SQL xóa file thứ cấp filedat3.ndf. Dùng SSMS xem kết quả
ALTER DATABASE SmallWorks
ADD FILE
(	NAME = 'filedat3',
	FILENAME = 'D:\HOC\HK8\TH_CSDL\Tuan1\filedat3.ndf',
	SIZE = 3MB
) TO FILEGROUP Test1FG1

ALTER DATABASE SmallWorks
MODIFY FILE( NAME = 'filedat3',SIZE = 5MB)

ALTER DATABASE SmallWorks
REMOVE FILE filedat3

--6. Xóa filegroup Test1FG1? Bạn có xóa được không? Nếu không giải thích? Muốn xóa
--được bạn phải làm gì?
ALTER DATABASE SmallWorks
REMOVE FILEGROUP Test1FG1
--Không xoá được vì trong filegroup vẫn còn dữ liệu của file
--Muốn xoá thì phải xoá toàn bộ file bên trong file filegroup


--7. Xem lại thuộc tính (properties) của CSDL SmallWorks bằng cửa sổ thuộc tính
--properties và bằng thủ tục hệ thống sp_helpDb, sp_spaceUsed, sp_helpFile.
--Quan sát và cho biết các trang thể hiện thông tin gì?.
USE SmallWorks

sp_helpDb SmallWorks --Truy vấn thông tin

sp_spaceUsed --Kiểm tra kích thước và dung lượng

sp_helpFIle --xem thông tin về filegroup của database hiện hành


--8. Tại cửa sổ properties của CSDL SmallWorks, chọn thuộc tính ReadOnly, sau đó
--đóng cửa sổ properties. Quan sát màu sắc của CSDL. Dùng lệnh T-SQL gỡ bỏ
--thuộc tính ReadOnly và đặt thuộc tính cho phép nhiều người sử dụng CSDL
--SmallWorks.


ALTER DATABASE SmallWorks
SET READ_WRITE

ALTER DATABASE SmallWorks
SET MULTI_USER

--9. Trong CSDL SmallWorks, tạo 2 bảng mới theo cấu trúc như sau:

CREATE TABLE dbo.Person
(
	PersonID int NOT NULL,
	FirstName varchar(50) NOT NULL,
	MiddleName varchar(50) NULL,
	LastName varchar(50) NOT NULL,
	EmailAddress nvarchar(50) NULL
) ON SWUserData1

CREATE TABLE dbo.Product
(
	ProductID int NOT NULL,
	ProductName varchar(75) NOT NULL,
	ProductNumber nvarchar(25) NOT NULL,
	StandardCost money NOT NULL,
	ListPrice money NOT NULL
) ON SWUserData2

--10. Chèn dữ liệu vào 2 bảng trên, lấy dữ liệu từ bảng Person và bảng Product trong
--AdventureWorks2008 (lưu ý: chỉ rõ tên cơ sở dữ liệu và lược đồ), dùng lệnh
--Insert…Select... Dùng lệnh Select * để xem dữ liệu trong 2 bảng Person và bảng
--Product trong SmallWorks.

INSERT INTO
	SmallWorks.dbo.Person
SELECT
	BusinessEntityID AS PersonID,
	FirstName,
	MiddleName,
	LastName,
	EmailPromotion AS EmailAddress
FROM
	AdventureWorks2008R2.Person.Person

-- Xem Bang Person
SELECT * FROM SmallWorks.dbo.Person


-- Copy bang Product
INSERT INTO
	SmallWorks.dbo.Product
SELECT
	ProductID,
	Name AS ProductName,
	ProductNumber,
	StandardCost,
	ListPrice
FROM
	AdventureWorks2008R2.Production.Product

-- Xem Bang Product
SELECT * FROM SmallWorks.dbo.Product