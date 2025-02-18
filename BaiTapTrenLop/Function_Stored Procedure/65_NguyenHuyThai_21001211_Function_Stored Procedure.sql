USE QLHocVien
GO

--C. BÀI TẠP STORED PROCEDURE

--1. Cho biết danh sách các giáo viên được phân công giảng dạy môn “Khai thác dữ liệu”.

DROP PROCEDURE IF EXISTS sp_danhSachGVDayMonKhaiThacDuLieu
GO

CREATE PROCEDURE sp_danhSachGVDayMonKhaiThacDuLieu
AS
BEGIN
    SELECT
        DISTINCT gv.MaGV,
        gv.TenGV
    FROM
        GIAOVIEN gv
        JOIN PHANCONG pc ON gv.MaGV = pc.MaGV
        JOIN MONHOC mh ON pc.MaMH = mh.MaMonHoc
    WHERE
        mh.TenMonHoc = N'Khai thác dữ liệu'
END
GO

EXEC sp_danhSachGVDayMonKhaiThacDuLieu
GO

--2. Nhận vào họ tên một giáo viên, cho biết danh sách tên các môn học mà giáo viên
--này đã được phân công giảng dạy.

DROP PROCEDURE IF EXISTS sp_danhSachMonHocGVDay
GO

CREATE PROCEDURE sp_danhSachMonHocGVDay
    @TenGV NVARCHAR(50)
AS
BEGIN
    SELECT
        DISTINCT mh.MaMonHoc,
        mh.TenMonHoc
    FROM
        GIAOVIEN gv
        JOIN PHANCONG pc ON gv.MaGV = pc.MaGV
        JOIN MONHOC mh ON pc.MaMH = mh.MaMonHoc
    WHERE
        gv.TenGV = @TenGV
END
GO

EXEC sp_danhSachMonHocGVDay N'Trần Anh Dũng'
GO

--3. Nhận vào họ tên một giáo viên, đếm số môn mà giáo viên này có khả năng giảng
--dạy. Xuất ra dưới dạng tham số output và in ra kết quả.

DROP PROCEDURE IF EXISTS sp_soMonHocGVDay
GO

CREATE PROCEDURE sp_soMonHocGVDay
    @TenGV NVARCHAR(50),
    @SoMon INT OUTPUT
AS
BEGIN
    SELECT
        @SoMon = COUNT(DISTINCT mh.MaMonHoc)
    FROM
        GIAOVIEN gv
        JOIN PHANCONG pc ON gv.MaGV = pc.MaGV
        JOIN MONHOC mh ON pc.MaMH = mh.MaMonHoc
    WHERE
        gv.TenGV = @TenGV
END
GO

DECLARE @SoMon INT
EXEC sp_soMonHocGVDay N'Trần Anh Dũng', @SoMon OUTPUT
PRINT @SoMon
GO

--4. Nhận vào một tên môn học, cho biết có bao nhiêu học viên đã từng thi đậu môn này.
--Xuất ra dưới dạng tham số output và in ra kết quả.

DROP PROCEDURE IF EXISTS sp_soHocVienThiDauMon
GO

CREATE PROCEDURE sp_soHocVienThiDauMon
    @TenMon NVARCHAR(50),
    @SoHocVien INT OUTPUT
AS
BEGIN
    SELECT
        @SoHocVien = COUNT(DISTINCT hv.MaHocVien)
    FROM
        HOCVIEN hv
        JOIN KETQUA kq ON hv.MaHocVien = kq.MaHV
        JOIN MONHOC mh ON kq.MaMonHoc = mh.MaMonHoc
    WHERE
        mh.TenMonHoc = @TenMon
        AND kq.Diem >= 5
END
GO

DECLARE @SoHocVien INT
EXEC sp_soHocVienThiDauMon N'Khai thác dữ liệu', @SoHocVien OUTPUT
PRINT @SoHocVien
GO

--D. BÀI TẬP FUNCTION

--1. Nhập vào tên một học viên cho biết số môn học viên này đã từng thi rớt.

DROP FUNCTION IF EXISTS fn_soMonHocHocVienThiRot
GO

CREATE FUNCTION fn_soMonHocHocVienThiRot
    (@TenHV NVARCHAR(50))
RETURNS INT
AS
BEGIN
    DECLARE @SoMon INT
    SELECT
        @SoMon = COUNT(DISTINCT kq.MaMonHoc)
    FROM
        HOCVIEN hv
        JOIN KETQUA kq ON hv.MaHocVien = kq.MaHV
    WHERE
        hv.TenHocVien = @TenHV
    HAVING
        COUNT(DISTINCT kq.MaMonHoc) > 1
    RETURN @SoMon
END
GO

SELECT dbo.fn_soMonHocHocVienThiRot(N'Nguyễn Thị Kiều Trang')
GO

--2. Nhập vào một mã lớp, một tên giáo viên. Cho biết số môn mà giáo viên từng dạy
--cho lớp này.

DROP FUNCTION IF EXISTS fn_soMonHocGVDay
GO

CREATE FUNCTION fn_soMonHocGVDay
    (@MaLop NVARCHAR(10), @TenGV NVARCHAR(50))
RETURNS INT
AS
BEGIN
    DECLARE @SoMon INT
    SELECT
        @SoMon = COUNT(pc.MaMH)
    FROM
        GIAOVIEN gv
        JOIN PHANCONG pc ON gv.MaGV = pc.MaGV
        JOIN LOPHOC lh ON pc.MaLop = lh.MaLop
    WHERE
        lh.MaLop = @MaLop
        AND gv.TenGV = @TenGV
    RETURN @SoMon
END
GO

SELECT dbo.fn_soMonHocGVDay(N'LH000001', N'Nguyễn Văn An')
GO



--3. Nhập vào một mã học viên, cho biết điểm trung bình của học viên.

DROP FUNCTION IF EXISTS fn_diemTrungBinhHocVien
GO

CREATE FUNCTION fn_diemTrungBinhHocVien
    (@MaHV NVARCHAR(10))
RETURNS FLOAT
AS
BEGIN
    DECLARE @DiemTrungBinh FLOAT
    SELECT
        @DiemTrungBinh = AVG(Diem)
    FROM
        KETQUA
    WHERE
        MaHV = @MaHV
    RETURN @DiemTrungBinh
END
GO

SELECT dbo.fn_diemTrungBinhHocVien(N'HV000001')
GO

--4. Nhập vào một tên môn học, cho biết danh sách các học viên (mã học viên, tên học
--viên, ngày sinh) đã đậu môn này. Học viên đậu khi điểm lần thi sau cùng >= 5.

DROP FUNCTION IF EXISTS fn_danhSachHocVienThiDauMon
GO

CREATE FUNCTION fn_danhSachHocVienThiDauMon
    (@TenMon NVARCHAR(50))
RETURNS @DanhSachHocVien TABLE
(
    MaHV NVARCHAR(10),
    TenHV NVARCHAR(50),
    NgaySinh DATE
)
AS
BEGIN
    INSERT INTO @DanhSachHocVien
    SELECT
        hv.MaHocVien,
        hv.TenHocVien,
        hv.NgaySinh
    FROM
        HOCVIEN hv
        JOIN KETQUA kq ON hv.MaHocVien = kq.MaHV
        JOIN MONHOC mh ON kq.MaMonHoc = mh.MaMonHoc
    WHERE
        mh.TenMonHoc = @TenMon
        AND kq.Diem >= 5
    RETURN
END
GO

SELECT * FROM dbo.fn_danhSachHocVienThiDauMon(N'Khai thác dữ liệu')
GO