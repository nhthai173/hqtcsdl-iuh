CREATE DATABASE Sales
ON PRIMARY
(
    NAME = 'Sales_data',
    FILENAME = 'D:\HOC\HK8\TH_CSDL\Tuan1\Sales_data.mdf',
    SIZE = 10MB
)
LOG ON
(
    NAME = 'Sales_log',
    FILENAME = 'D:\HOC\HK8\TH_CSDL\Tuan1\Sales_log.ldf',
    SIZE = 10MB
)

USE Sales

--1 Tạo các kiểu dữliệu người dùng sau
CREATE TYPE dbo.Mota FROM  NVARCHAR(40) NULL;
CREATE TYPE dbo.IDKH FROM  CHAR(10) NOT NULL;
CREATE TYPE dbo.DT FROM CHAR(12) NULL;

--2 Tạo các bảng theo cấu trúc sau
CREATE TABLE SanPham 
(
   Masp char(6) NOT NULL,
   TenSp varchar(6),
   NgayNhap Date,
   DVT char(10),
   SoLuongTon Int,
   DonGiaNhap money
)

CREATE TABLE KhachHang
(
    MaKH IDKH NOT NULL,
    TenKH Nvarchar(30),
    Diachi Nvarchar(40),
    Dienthoai DT,
)

CREATE TABLE HoaDon
(
    MaHD char(10) NOT NULL ,
    NgayLap Date,
    NgayGiao Date,
    MaKH IDKH ,
    DienGiai Mota
)

CREATE TABLE ChiTietHD
(
    MaHD char(10) NOT NULL,
    Masp char(6) NOT NULL,
    SoLuong Int
)


--3.Trong Table HoaDon, sửa cột DienGiai thành nvarchar(100)
ALTER TABLE HoaDon 
ALTER COLUMN DienGiai Nvarchar(100)

--4.Thêm vào bảng SanPham cột TyLeHoaHong float
ALTER TABLE Sanpham ADD TyLeHoaHong FLOAT

--5.Xóa cột NgayNhap trong bảng SanPham
ALTER TABLE SanPham DROP COLUMN NgayNhap

-- 6.Tạo các ràng buộc khóa chính và khóa ngoại cho các bảng trên
ALTER TABLE SanPham 
ADD CONSTRAINT Masp_PK PRIMARY KEY (Masp)

ALTER TABLE KhachHang 
ADD CONSTRAINT MaKH_PK PRIMARY KEY (MaKH)

ALTER TABLE HoaDon 
ADD CONSTRAINT MaHD_PK PRIMARY KEY (MaHD)


ALTER TABLE  HoaDon WITH CHECK
ADD CONSTRAINT Makh_FK FOREIGN KEY(Makh) REFERENCES KhachHang(MaKH)

ALTER TABLE ChiTietHD WITH CHECK 
ADD CONSTRAINT MaHD_FK FOREIGN KEY (MaHD) REFERENCES HoaDon(MaHD)

ALTER TABLE ChiTietHD WITH CHECK
ADD CONSTRAINT Masp_FK FOREIGN KEY (Masp) REFERENCES SanPham(Masp)



-- 7.Thêm vào bảng HoaDon các ràng buộcsau:
-- NgayGiao >=NgayLap
    ALTER TABLE HoaDon 
    ADD CONSTRAINT NgayGiao_NgayLap 
    CHECK (NgayGiao >= NgayLap)

-- MaHD gồm 6 ký tự, 2 ký tự đầu là chữ, các ký tự còn lại là số
    ALTER TABLE HoaDon
    ADD CONSTRAINT MaHD_CHECK 
    CHECK (MaHD LIKE '[A-Z][A-Z][0-9][0-9][0-9][0-9]')

-- Giá trị mặc định ban đầu cho cột NgayLap luôn luôn là ngày hiện hành
    ALTER TABLE HoaDon
    ADD CONSTRAINT NgayLap_DEFAULT
    DEFAULT GETDATE() FOR NgayLap



-- 8.Thêm vào bảng Sản phẩm các ràng buộcsau:
-- SoLuongTonchỉ nhập từ 0 đến 500
    ALTER TABLE SanPham
    ADD CONSTRAINT SoLuongTon_CHECK
    CHECK (SoLuongTon >= 0 AND SoLuongTon <= 500)

-- DonGiaNhap lớn hơn 0
    ALTER TABLE SanPham
    ADD CONSTRAINT DonGiaNhap_CHECK
    CHECK (DonGiaNhap > 0)

-- Giá trị mặc định cho NgayNhap là ngày hiệnhành
    ALTER TABLE SanPham
    ADD CONSTRAINT NgayNhap_DEFAULT
    DEFAULT GETDATE() FOR NgayNhap

-- DVT chỉ nhập vào các giá trị ‘KG’, ‘Thùng’, ‘Hộp’, ‘Cái’
    ALTER TABLE SanPham
    ADD CONSTRAINT DVT_GT
    CHECK(DVT IN ('KG' ,'Thùng', 'Hộp', 'Cái'))




-- 9.Dùng lệnh T-SQL nhập dữ liệu vào 4 table trên, dữ liệu tùy ý, chú ý các ràng buộc của mỗi Table
INSERT INTO SanPham (Masp, TenSp, NgayNhap, DVT, SoLuongTon, DonGiaNhap)
VALUES 
('SP001', 'Đien', '2024-01-01 12:12:00.00', 'Cái', 100, 5000000)

INSERT INTO KhachHang (MaKH, TenKH, Diachi, Dienthoai)
VALUES 
('KH001', 'Nguyen Van A', 'Ha Noi', '0123456789')

INSERT INTO HoaDon (MaHD, NgayLap, NgayGiao, MaKH, DienGiai)
VALUES 
('HD0001', '2024-01-01 12:12:00.00', '2024-01-01 12:12:00.00', 'KH001', 'Mua hang');

INSERT INTO ChiTietHD (MaHD, Masp, SoLuong)
VALUES 
('HD0001', 'SP001', 10)



-- 10.Xóa 1 hóa đơn bất kỳ trong bảng HoaDon. 
-- Có xóa được không? Tại sao? Nếu vẫn muốn xóa thì phải dùng cáchnào?
    DELETE FROM HoaDon
    WHERE MaHD = 'HD0001'
    
    -- Không xóa được vì có ràng buộc khóa ngoại với bảng ChiTietHD
    -- Để xóa thì phải xóa bản ghi trong bảng ChiTietHD trước
    DELETE FROM ChiTietHD
    WHERE MaHD = 'HD0001'
    DELETE FROM HoaDon
    WHERE MaHD = 'HD0001'



-- 11.Nhập 2 bản ghi mới vào bảng ChiTietHD với MaHD = ‘HD999999999’ và MaHD=’1234567890’.
--  Có nhập được không? Tạisao?
    INSERT INTO  ChiTietHD (MaHD, Masp, SoLuong)
    VALUES 
    ('HD999999999', 'SP001', 10),
    ('1234567890', 'SP001', 10)
    -- Không nhập được vì không đúng ràng buộc MaHD_CHECK

-- 12.Đổi tên CSDL Sales thànhBanHang
    ALTER DATABASE Sales MODIFY NAME = BanHang
    sp_helpdb BanHang

-- 13.Tạo thư mục T:\QLBH, chép CSDL BanHang vào thư mục này, 
-- bạn có sao chép được không? Tại sao? 
-- Muốn sao chép được bạn phải làm gì? 
-- Sau khi sao chép,bạn thực hiện Attach CSDL vào lại SQL

    --Không sao chép được vì file CSDL đang được sử dụng
    --Phải detach CSDL trước khi sao chép
    --Sau khi sao chép thì attach lại CSDL
    
  
