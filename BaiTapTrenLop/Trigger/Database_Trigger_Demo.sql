--cau 2.a
CREATE DATABASE QLBH_DEMO
ON PRIMARY
(
	NAME = QLBH_data1,
	FILENAME = 'E:\DEMO_TRIGGER\QLBH_data1.mdf',
	SIZE = 10 MB,
	MAXSIZE = 40MB,
	FILEGROWTH = 1MB
)
LOG ON
(
	NAME = QLBH_log1,
	FILENAME = 'E:\DEMO_TRIGGER\QLBH_log1.ldf',
	SIZE = 6MB,
	MAXSIZE = 8MB,
	FILEGROWTH = 1MB
)
-------------
USE QLBH_DEMO
GO
----------
--Bai 1.3
CREATE TABLE NHOMSANPHAM
(
	MaNhom  Int  PRIMARY KEY Not null,
	TenNhom nvarchar(50) ,
	SoLuong int DEFAULT 0
)
GO

CREATE TABLE NHACUNGCAP
(
	MaNCC  Int  PRIMARY KEY Not null,
	TenNCC nvarchar(40) Not null,
	Diachi  Nvarchar(60),
	Phone  NVarchar(24),
	SoFax  NVarchar(24),
	DCMail  NVarchar(50) 
)
GO

CREATE TABLE KHACHHANG
(
	MaKH  Char(5)  PRIMARY KEY Not null,
	TenKH nvarchar(40) Not null,
	LoaiKH  Nvarchar(3) CHECK( LoaiKH IN ('VIP','TV','VL')),
	DiaChi  Nvarchar(60),
	Phone  NVarchar(24),
	DCMail  NVarchar(50),
	DiemTL  Int CHECK (DiemTL >= 0)
)
GO

CREATE TABLE SANPHAM
(
	MaSP  Int  PRIMARY KEY Not null,
	TenSP nvarchar(40) Not null,
	MaNCC Int  REFERENCES NHACUNGCAP(MaNCC) ON DELETE CASCADE ON UPDATE CASCADE,
	MoTa  nvarchar(50),
	MaNhom   Int REFERENCES NHOMSANPHAM(MaNhom) ON DELETE CASCADE ON UPDATE CASCADE,
	Đonvitinh  nvarchar(20),
	GiaGoc  Money CHECK (GiaGoc >0),
	SLTON  Int CHECK (SLTON > 0)
)
GO


CREATE TABLE HOADON
(
	MaHD  Int  PRIMARY KEY Not null,
	NgayLapHD  DateTime DEFAULT GETDATE() CHECK (NgayLapHD <= GETDATE()) ,
	NgayGiao  DateTime ,
	Noichuyen  NVarchar(60)  Not Null, 
	MaKH     Char(5) REFERENCES KHACHHANG(MaKH) ON DELETE CASCADE ON UPDATE CASCADE,
	LoaiHD char(1)
)
GO


CREATE TABLE CT_HOADON
(
	MaHD  Int   Not null  REFERENCES HOADON(MaHD) ON DELETE CASCADE ON UPDATE CASCADE,
	MaSP Int Not null REFERENCES SANPHAM(MaSP) ON DELETE CASCADE ON UPDATE CASCADE,
	Soluong  SmallInt CHECK (Soluong >0),
	Dongia  Money,
	ChietKhau  Money CHECK (ChietKhau >= 0),
	PRIMARY KEY(MaHD,MaSP)	
)
GO

--BAI1.4.b
ALTER TABLE HOADON 
ADD CONSTRAINT NGAY_GIAO CHECK (NgayGiao > NgayLapHD) 
GO
-------------

INSERT INTO NHOMSANPHAM(MaNhom,TenNhom,SoLuong) VALUES(1, N'Điện tử',150)
INSERT INTO NHOMSANPHAM(MaNhom,TenNhom,SoLuong) VALUES(2, N'Gia Dụng',30)
INSERT INTO NHOMSANPHAM(MaNhom,TenNhom,SoLuong) VALUES(3, N'Dụng Cụ Gia Đình',170)
INSERT INTO NHOMSANPHAM(MaNhom,TenNhom,SoLuong)  VALUES(4, N'Các Mặt Hàng Khác',0)

--Table NHACUNGCAP

INSERT INTO NHACUNGCAP VALUES(1, N'Công ty TNHH Nam Phương', N'1 Lê Lợi, Phường 4, Gò Vấp', N'02345', N'32456', N'NamPhuong@yahoo.com')
INSERT INTO NHACUNGCAP VALUES(2, N'Công ty Lan Ngọc', N'12 Cao Bá Quát, quận 1, TP HCM', N'04758', N'32456', N'LanNgoc@yahoo.com')

--Table SANPHAM
INSERT INTO SANPHAM(MaSP,TenSP,Đonvitinh,GiaGoc,SLTON,MaNhom,MaNCC,MoTa) VALUES(1, N'Máy Tính', N'Cái', 700, 100,1,1, N'Máy Sony Ram 2GB')
INSERT INTO SANPHAM(MaSP,TenSP,Đonvitinh,GiaGoc,SLTON,MaNhom,MaNCC,MoTa) VALUES(2, N'Bàn phím', N'Cái', 1000, 50,1,1, N'Bàn phím 101 phím')
INSERT INTO SANPHAM(MaSP,TenSP,Đonvitinh,GiaGoc,SLTON,MaNhom,MaNCC,MoTa) VALUES(3, N'Chuột', N'Cái', 800, 150,3,1, N'Chuột không dây')
INSERT INTO SANPHAM(MaSP,TenSP,Đonvitinh,GiaGoc,SLTON,MaNhom,MaNCC,MoTa) VALUES(4, N'CPU', N'Cái', 3000, 200,2,1, N'CPU')
INSERT INTO SANPHAM(MaSP,TenSP,Đonvitinh,GiaGoc,SLTON,MaNhom,MaNCC,MoTa) VALUES(5, N'USB', N'Cái', 500, 100,2,1, N'8GB')
INSERT INTO SANPHAM(MaSP,TenSP,Đonvitinh,GiaGoc,SLTON,MaNhom,MaNCC,MoTa) VALUES(6, N'Lò Vi Sóng', N'Cái', 1000000, 20,3,2, N' ')
--Table KHACHHANG
INSERT INTO KHACHHANG(MaKH,TenKH,DiaChi,Phone,LoaiKH,DCMail,DiemTL) VALUES('KH1', N'Nguyễn Thu Hằng', N'12 Nguyễn Du', N'',N'VL',N'',N'')
INSERT INTO KHACHHANG(MaKH,TenKH,DiaChi,Phone,LoaiKH,DCMail,DiemTL) VALUES('KH2', N'Lê Minh', N'34 Điện Biên Phủ', N'01234',N'TV',N'LeMinh@yahoo.com', 100)
INSERT INTO KHACHHANG(MaKH,TenKH,DiaChi,Phone,LoaiKH,DCMail,DiemTL) VALUES('KH3', N'NGuyễn Minh Trung', N'3 Lê Lợi Gò Vấp', N'0897',N'VIP',N'Trung@yahoo.com', 800)
-- Table HOADON

INSERT INTO HOADON(MaHD,NgayLapHD,MaKH,NgayGiao,Noichuyen,LoaiHD)      
VALUES (1,'09/30/2015','KH1','10/05/2015',N'Cửa hàng ABC 3 Lý CHính Thắng, Q.3','N')

INSERT INTO HOADON(MaHD,NgayLapHD,MaKH,NgayGiao,Noichuyen,LoaiHD)      
VALUES (2,'07/29/2015','KH2','08/10/2015',N'23 Lê Lợi, Q.Gò Vấp', 'T')

INSERT INTO HOADON(MaHD,NgayLapHD,MaKH,NgayGiao,Noichuyen,LoaiHD)      
VALUES (3,'10/01/2015','KH3','10/02/2015',N'2 Nguyễn Du, Q.Gò Vấp', 'X')
GO

--Table CT_HOADON
INSERT INTO CT_HOADON(MaHD,MaSP,Dongia,Soluong)      
VALUES (1,1,8000,5)

INSERT INTO CT_HOADON(MaHD,MaSP,Dongia,Soluong)      
VALUES (1,2,1200,4)

INSERT INTO CT_HOADON(MaHD,MaSP,Dongia,Soluong)      
VALUES (1,3,1000,15)

INSERT INTO CT_HOADON(MaHD,MaSP,Dongia,Soluong)      
VALUES (2,2,1200,9)

INSERT INTO CT_HOADON(MaHD,MaSP,Dongia,Soluong)      
VALUES (2,4,8000,5)

INSERT INTO CT_HOADON(MaHD,MaSP,Dongia,Soluong)      
VALUES (3,2,3500,20)

INSERT INTO CT_HOADON(MaHD,MaSP,Dongia,Soluong)      
VALUES (3,3,1000,15)