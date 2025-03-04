USE QLHocVien
GO

-- 1. Năm bắt đầu của một lớp học luôn phải nhỏ hơn năm kết thúc
CREATE TRIGGER tg_LopHoc_Nam ON [dbo].[LOPHOC]
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted WHERE NamBatDau < NamKetThuc)
    BEGIN
        ROLLBACK
        RAISERROR('Năm bắt đầu của một lớp học luôn phải nhỏ hơn năm kết thúc', 16, 1)
    END
END
GO


-- 2. Tuổi của giáo viên phải nằm trong khoảng từ 22 đến 55
CREATE TRIGGER tg_GiaoVien_Tuoi ON [dbo].[GIAOVIEN]
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted WHERE YEAR(GETDATE()) - YEAR(NgaySinh) < 22 OR YEAR(GETDATE()) - YEAR(NgaySinh) > 55)
    BEGIN
        ROLLBACK
        RAISERROR('Tuổi của giáo viên phải nằm trong khoảng từ 22 đến 55', 16, 1)
    END
END
GO

-- 3. Mỗi giáo viên chỉ được quản lý tối đa 3 giáo viên khác
CREATE TRIGGER tg_GiaoVien_QuanLy ON [dbo].[GIAOVIEN]
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted WHERE (SELECT COUNT(*) FROM [dbo].[GIAOVIEN] WHERE MaGV = inserted.MaGV) > 3)
    BEGIN
        ROLLBACK
        RAISERROR('Mỗi giáo viên chỉ được quản lý tối đa 3 giáo viên khác', 16, 1)
    END
END
GO

-- 4. Học viên thuộc về một lớp chỉ được học những môn có mở ra cho lớp đó


-- 5. Giáo viên chỉ được dạy những môn mà họ có khả năng giảng dạy
CREATE TRIGGER tg_GiaoVien_MonHoc ON PHANCONG
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted WHERE NOT EXISTS (SELECT * FROM PHANCONG WHERE PHANCONG.MaMH = inserted.MaMH AND PHANCONG.MaGV = inserted.MaGV))
    BEGIN
        -- kiểm tra trong bảng giaovien_day_monhoc
        IF EXISTS (SELECT * FROM inserted WHERE NOT EXISTS (SELECT * FROM GIAOVIEN_DAY_MONHOC WHERE GIAOVIEN_DAY_MONHOC.MaMH = inserted.MaMH AND GIAOVIEN_DAY_MONHOC.MaGV = inserted.MaGV))
        BEGIN
            ROLLBACK
            RAISERROR('Giáo viên chỉ được dạy những môn mà họ có khả năng giảng dạy', 16, 1)
        END
    END
END