USE QLHV
GO


-- 2. Tuổi của giáo viên phải nằm trong khoảng từ 22 đến 55
CREATE TRIGGER tg_GiaoVien_Tuoi ON [GiaoVien].[CanBo]
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
CREATE TRIGGER tg_GiaoVien_QuanLy ON [GiaoVien].[CanBo]
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted WHERE (SELECT COUNT(*) FROM [GiaoVien].[CanBo] WHERE MaCB = inserted.MaCB) > 3)
    BEGIN
        ROLLBACK
        RAISERROR('Mỗi giáo viên chỉ được quản lý tối đa 3 giáo viên khác', 16, 1)
    END
END
GO