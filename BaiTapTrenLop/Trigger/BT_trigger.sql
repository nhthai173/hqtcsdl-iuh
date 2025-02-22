USE QLBH_DEMO
GO

CREATE TRIGGER tg_sanpham_insert
ON SANPHAM FOR INSERT AS
BEGIN
    IF EXISTS (SELECT * FROM inserted)
    BEGIN
        DECLARE @manhom Int
        DECLARE @slgton Int
        SELECT @manhom = MaNhom, @slgton = SLTON FROM inserted
        
        UPDATE NHOMSANPHAM
        SET SoLuong = SoLuong + @slgton
        WHERE MaNhom = @manhom
    END
END
GO


CREATE TRIGGER tg_sanpham_delete
ON SANPHAM FOR DELETE AS
BEGIN
    IF EXISTS (SELECT * FROM deleted)
    BEGIN
        DECLARE @manhom Int
        DECLARE @slgton Int
        SELECT @manhom = MaNhom, @slgton = SLTON FROM deleted
        
        UPDATE NHOMSANPHAM
        SET SoLuong = SoLuong - @slgton
        WHERE MaNhom = @manhom
    END
END
GO


CREATE TRIGGER tg_sanpham_update
ON SANPHAM FOR UPDATE AS
BEGIN
    IF Update(MaNhom) OR Update(SLTON)
    BEGIN
        DECLARE @manhomCu Int
        DECLARE @manhomMoi Int
        DECLARE @slgtonCu Int
        DECLARE @slgtonMoi Int
        
        SELECT @manhomCu = MaNhom, @slgtonCu = SLTON FROM deleted
        SELECT @manhomMoi = MaNhom, @slgtonMoi = SLTON FROM inserted
        
        IF @manhomCu = @manhomMoi
        BEGIN
            UPDATE NHOMSANPHAM
            SET SoLuong = SoLuong - @slgtonCu + @slgtonMoi
            WHERE MaNhom = @manhomCu
        END
        ELSE
        BEGIN
            UPDATE NHOMSANPHAM
            SET SoLuong = SoLuong - @slgtonCu
            WHERE MaNhom = @manhomCu
            
            UPDATE NHOMSANPHAM
            SET SoLuong = SoLuong + @slgtonMoi
            WHERE MaNhom = @manhomMoi
        END
    END
END
GO


--Câu 4:Tạo trigger thay thế cho thao tác chèn 1 bản ghi vào
--bảng SANPHAM với SLTON < 0 bằng thông báo ' ko chèn được'
-- và rollback transaction

CREATE TRIGGER tg_sanpham_insert_slgton_khong_am
ON SANPHAM INSTEAD OF INSERT AS
BEGIN
    IF EXISTS (SELECT * FROM inserted)
    BEGIN
        DECLARE @slgton Int
        SELECT @slgton = SLTON FROM inserted
        
        IF @slgton < 0
        BEGIN
            RAISERROR('So luong ton phai >= 0', 16, 1)
            ROLLBACK TRANSACTION
        END
    END
END
GO

INSERT INTO SANPHAM(MaSP, TenSP, MaNCC, MaNhom, Đonvitinh, GiaGoc, SLTON)
VALUES(10, N'Điện thoại', 1, 1, N'Chiếc', 1000000, -10)
GO

--Câu 5 Tạo HienThi_View gồm: MaNhom,TenNhom,MaSP,TenSP, MaNCC
--Đonvitinh,GiaGoc,SLTON

CREATE VIEW HienThi_View
AS
SELECT
    nhom.MaNhom,
    nhom.TenNhom,
    sp.MaSP,
    sp.TenSP,
    sp.MaNCC,
    sp.Đonvitinh,
    sp.GiaGoc,
    sp.SLTON
FROM
    NHOMSANPHAM nhom
    JOIN SANPHAM sp ON sp.MaNhom = nhom.MaNhom
GO

SELECT * FROM HienThi_View
GO

--Câu 6: Tạo trigger thay thế cho thao tác chèn 1 bản ghi vào HienThi_View
--thành thao tác cập nhật soluong trong bảng NHOMSANPHAM, và chèn bản ghi mới vào 
--bảng san phẩm

CREATE TRIGGER tg_hienthi_view_insert
ON HienThi_View INSTEAD OF INSERT AS
BEGIN
    IF EXISTS (SELECT * FROM inserted)
    BEGIN
        DECLARE @manhom Int
        DECLARE @slgton Int
        SELECT @manhom = MaNhom, @slgton = SLTON FROM inserted

        UPDATE NHOMSANPHAM
        SET SoLuong = SoLuong + @slgton
        WHERE MaNhom = @manhom

        INSERT INTO SANPHAM SELECT * FROM inserted
    END
END
GO

INSERT INTO HienThi_View
VALUES (10, N'Điện tử', 1, N'Điện thoại', 1, N'Chiếc', 1000000, 10)
GO