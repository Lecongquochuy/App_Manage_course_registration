USE QLDKHP;
GO
-- Check
CREATE TRIGGER CEK_DTUT_TILEGIAM 
ON DTUUTIEN
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @TiLeGiam FLOAT;

    SELECT @TiLeGiam = TiLeGiam
    FROM inserted

    IF @TiLeGiam < 0 OR @TiLeGiam > 1
    BEGIN
        RAISERROR ('Nhập sai tỉ lệ giảm. Tỉ lệ giảm phải nằm trong khoảng từ 0 đến 1.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO
CREATE TRIGGER CEK_SV_GIOITINH  
ON SINHVIEN
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @GioiTinh NVARCHAR(3);

    SELECT @GioiTinh = GioiTinh
    FROM inserted

    IF @GioiTinh NOT IN (N'Nam', N'Nữ')
    BEGIN
        RAISERROR ('Nhập sai giới tính. Giới tính phải là Nam hoặc Nữ.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO
CREATE TRIGGER CEK_HKNH_HOCKY  
ON HOCKY_NAMHOC
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @HocKy int;

    SELECT @HocKy = HocKy
    FROM inserted

    IF @HocKy NOT IN (1, 2, 3)
    BEGIN
        RAISERROR ('Nhập sai học kỳ. Giá trị của học kỳ: [1, 3].', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO
CREATE TRIGGER CEK_LM_TENLOAIMON  
ON LOAIMON
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @TenLoaiMon NVARCHAR(20);

    SELECT @TenLoaiMon = TenLoaiMon
    FROM inserted

    IF @TenLoaiMon NOT IN (N'Lý thuyết', N'Thực hành')
    BEGIN
        RAISERROR ('Nhập sai tên loại môn. Tên loại môn phải là Lý thuyết hoặc Thực hành.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO
CREATE TRIGGER CEK_CTN_HOCKY  
ON CT_NGANH
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @HocKy int;

    SELECT @HocKy = HocKy
    FROM inserted

    IF @HocKy NOT IN (1, 2, 3, 4, 5, 6, 7, 8)
    BEGIN
        RAISERROR ('Nhập sai học kỳ. Giá trị của học kỳ: [1, 8].', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO
-- Unique
CREATE TRIGGER UNQ_DSMM_HKNH_MH
ON DSMHMO
INSTEAD OF INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN DSMHMO d ON i.MaHKNH = d.MaHKNH AND i.MaMH = d.MaMH
    )
    BEGIN
        RAISERROR ('Trong CSDL đã tồn tại DSMHMO có MaHKNH và MaMH này.', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO DSMHMO (MaHKNH, MaMH)
        SELECT MaHKNH, MaMH
        FROM inserted;
    END
END;
GO
CREATE TRIGGER UNQ_PDK_SV_HKNH
ON PHIEUDKHP
INSTEAD OF INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN PHIEUDKHP p ON i.MSSV = p.MSSV AND i.MaHKNH = p.MaHKNH
    )
    BEGIN
        RAISERROR ('Trong CSDL đã tồn tại PHIEUDKHP có MSSV và MaHKNH này.', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO PHIEUDKHP (MSSV, MaHKNH)
        SELECT MSSV, MaHKNH
        FROM inserted;
    END
END;

GO
-- Trigger - xóa một phiếu DKHP sẽ xóa các thông tin liên quan.
CREATE TRIGGER TRIG_DL_PHIEUDKHP
ON PHIEUDKHP INSTEAD OF DELETE
AS
BEGIN
	DECLARE @MaPhieuDKHP VARCHAR(8)
	SELECT  @MaPhieuDKHP=MaPhieuDKHP FROM DELETED
	DELETE FROM	CT_DKHP WHERE MaPhieuDKHP=@MaPhieuDKHP
	DELETE FROM	PHIEUTHUHP WHERE MaPhieuDKHP=@MaPhieuDKHP
	DELETE FROM	PHIEUDKHP WHERE MaPhieuDKHP=@MaPhieuDKHP
END;
GO

-- Trigger - xóa một DS Môn học mở sẽ xóa các thông tin liên quan.
CREATE TRIGGER TRIG_DL_DSMHMO
ON DSMHMO INSTEAD OF DELETE
AS
BEGIN
	DECLARE @MaMo VARCHAR(8)
	SELECT  @MaMo=MaMo FROM DELETED
	DELETE FROM	CT_DKHP WHERE MaMo=@MaMo
	DELETE FROM	DSMHMO WHERE MaMo=@MaMo
END;
GO

-- Trigger - xóa một môn học sẽ xóa các thông tin liên quan.
CREATE TRIGGER TRIG_DL_MONHOC
ON MONHOC INSTEAD OF DELETE
AS
BEGIN
	DECLARE @MaMH VARCHAR(8)
	SELECT  @MaMH=MaMH FROM DELETED
	DELETE FROM	CT_NGANH WHERE MaMH=@MaMH
	DELETE FROM	DSMHMO WHERE MaMH=@MaMH
	DELETE FROM	MONHOC WHERE MaMH=@MaMH
END;
GO
-- Trigger - xóa một sinh viên sẽ xóa các thông tin liên quan.
CREATE TRIGGER TRIG_DL_SINHVIEN
ON SINHVIEN INSTEAD OF DELETE
AS
BEGIN
	DECLARE @MSSV VARCHAR(8)
	SELECT  @MSSV=MSSV FROM DELETED
	DELETE FROM	BCCHUADONGHP WHERE MSSV=@MSSV
	DELETE FROM	PHIEUDKHP WHERE MSSV=@MSSV
	DELETE FROM	SINHVIEN WHERE MSSV=@MSSV
END;
GO
-- Trigger - Tự động tính số tính chỉ
CREATE TRIGGER TRIG_ISUD_MONHOC_TINHSOTC
ON MONHOC FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @MaMH VARCHAR(5)
	DECLARE @SoTC INT

    SELECT @MaMH = MaMH FROM inserted

	SELECT @SoTC = CAST (SoTiet / SoTietMotTC AS INT)
	FROM MONHOC mh JOIN LOAIMON lm ON mh.MaLoaiMon = lm.MaLoaiMon 
	WHERE mh.MaMH = @MaMH

    UPDATE MONHOC
    SET SoTC = @SoTC
	WHERE MaMH = @MaMH
END;
GO

-- Trigger - Khởi tạo giá trị 0 cho Phiếu ĐKHP
CREATE TRIGGER TRIG_IS_PHIEUDKHP_TONGTIEN
ON PHIEUDKHP FOR INSERT
AS
BEGIN
	DECLARE @MaPhieuDKHP VARCHAR(8)
	SELECT @MaPhieuDKHP = MaPhieuDKHP FROM inserted

	UPDATE PHIEUDKHP
    SET TongTien = 0, SoTienPhaiDong = 0, SoTienDaDong = 0, SoTienConLai = 0
	WHERE MaPhieuDKHP = @MaPhieuDKHP
END;
GO
-- Trigger - Tự động tính tổng tiền
CREATE TRIGGER TRIG_ISUDDL_CT_DKHP_TINHTONGTIEN
ON CT_DKHP FOR INSERT, UPDATE, DELETE
AS
BEGIN
	DECLARE @MaPhieuDKHP VARCHAR(8)
	DECLARE @MaMo VARCHAR(8)
	DECLARE @GiaTien MONEY

	IF EXISTS(SELECT * FROM inserted)
    BEGIN
		SELECT @MaPhieuDKHP = MaPhieuDKHP, @MaMo = MaMo FROM inserted

		SELECT @GiaTien = mh.SoTC * lm.SoTienMotTC
		FROM DSMHMO mhmo
		JOIN MONHOC mh ON mhmo.MaMH = mh.MaMH
		JOIN LOAIMON lm ON lm.MaLoaiMon = mh.MaLoaiMon
		WHERE mhmo.MaMo = @MaMo

		UPDATE PHIEUDKHP
		SET TongTien = TongTien + @GiaTien
		WHERE MaPhieuDKHP = @MaPhieuDKHP
    END

    IF EXISTS(SELECT * FROM deleted)
    BEGIN
		SELECT @MaPhieuDKHP = MaPhieuDKHP, @MaMo = MaMo FROM deleted

		SELECT @GiaTien = mh.SoTC * lm.SoTienMotTC
		FROM DSMHMO mhmo
		JOIN MONHOC mh ON mhmo.MaMH = mh.MaMH
		JOIN LOAIMON lm ON lm.MaLoaiMon = mh.MaLoaiMon
		WHERE mhmo.MaMo = @MaMo
		
		UPDATE PHIEUDKHP
		SET TongTien = TongTien - @GiaTien
		WHERE MaPhieuDKHP = @MaPhieuDKHP
    END
END;
GO

-- Trigger - Tự động tính số tiền phải đóng
CREATE TRIGGER TRIG_UD_PHIEUDKHP_TINHSOTIENPHAIDONG
ON PHIEUDKHP FOR UPDATE
AS
BEGIN
	DECLARE @MaPhieuDK VARCHAR(8)
	DECLARE @SoTienPhaiDong MONEY
	DECLARE @TongTien MONEY

	SELECT @MaPhieuDK = MaPhieuDKHP FROM inserted

	SELECT @SoTienPhaiDong = pdkhp.TongTien * (1 - dtut.TiLeGiam)
	FROM PHIEUDKHP pdkhp 
	JOIN SINHVIEN sv ON pdkhp.MSSV = sv.MSSV
	JOIN DTUUTIEN dtut ON sv.MaDT = dtut.MaDT
	WHERE pdkhp.MaPhieuDKHP = @MaPhieuDK

	UPDATE PHIEUDKHP
    SET SoTienPhaiDong = @SoTienPhaiDong,
		SoTienConLai = SoTienConLai - (SoTienPhaiDong - @SoTienPhaiDong)
    WHERE MaPhieuDKHP = @MaPhieuDK
END;
GO

-- Trigger - Tự động cập nhật số tiền đã đóng và số tiền còn lại
CREATE TRIGGER TRIG_ISUDDL_PHIEUTHUHP_TINHSTDADONGVASTCONLAI
ON PHIEUTHUHP FOR INSERT, UPDATE, DELETE
AS
BEGIN
	DECLARE @MaPhieuDKHP VARCHAR(8)
	DECLARE @SoTienThu MONEY

	IF EXISTS(SELECT * FROM inserted)
    BEGIN
		SELECT @MaPhieuDKHP = MaPhieuDKHP, @SoTienThu = SoTienThu FROM inserted

		UPDATE PHIEUDKHP
		SET SoTienDaDong = SoTienDaDong + @SoTienThu,
			SoTienConLai = SoTienConLai - @SoTienThu
		WHERE MaPhieuDKHP = @MaPhieuDKHP
    END

    IF EXISTS(SELECT * FROM deleted)
    BEGIN
		SELECT @MaPhieuDKHP = MaPhieuDKHP, @SoTienThu = SoTienThu FROM deleted

		UPDATE PHIEUDKHP
		SET SoTienDaDong = SoTienDaDong - @SoTienThu,
			SoTienConLai = SoTienConLai + @SoTienThu
		WHERE MaPhieuDKHP = @MaPhieuDKHP
    END
END;
GO
-- Trigger - Ngày lập phiếu thu phải trước thời hạn đóng học phí trong cùng một học kỳ năm học
CREATE TRIGGER TRIG_ISUD_PHIEUTHUHP_THOIHANDONGHOCPHI
ON PHIEUTHUHP FOR INSERT, UPDATE
AS
BEGIN
	IF EXISTS (SELECT 1 FROM inserted i 
				JOIN PHIEUDKHP pdk ON i.MaPhieuDKHP = pdk.MaPhieuDKHP
				JOIN HOCKY_NAMHOC hknm ON hknm.MaHKNH = pdk.MaHKNH
				WHERE i.NgayLap > hknm.ThoiHanDongHocPhi)
    BEGIN
        RAISERROR ('Ngày lập phiếu thu phải trước thời hạn đóng học phí trong cùng một học kỳ năm học!', 16, 1)
        ROLLBACK TRANSACTION
    END
END;
GO
-- Trigger - Ngày lập phiếu ĐKHP phải trước thời hạn đóng học phí trong cùng một học kỳ năm học
CREATE TRIGGER TRIG_ISUD_PHIEUDKHP_THOIHANDONGHOCPHI
ON PHIEUDKHP FOR INSERT, UPDATE
AS
BEGIN
	IF EXISTS (SELECT 1 FROM inserted i 
				JOIN HOCKY_NAMHOC hknm ON hknm.MaHKNH = i.MaHKNH
				WHERE i.NgayLap > hknm.ThoiHanDongHocPhi)
    BEGIN
        RAISERROR ('Ngày lập phiếu ĐKHP phải trước thời hạn đóng học phí trong cùng một học kỳ năm học!', 16, 1)
        ROLLBACK TRANSACTION
    END
END;
GO

-- Trigger - Ngày lập phiếu ĐKHP phải trước ngày lập phiếu thu của phiếu đăng ký đó
CREATE TRIGGER TRIG_ISUD_PHIEUTHU_NGAYLAP
ON PHIEUTHUHP FOR INSERT, UPDATE
AS
BEGIN
	IF EXISTS (SELECT 1 FROM inserted i 
				JOIN PHIEUDKHP pdk ON pdk.MaPhieuDKHP = i.MaPhieuDKHP
				WHERE i.NgayLap < pdk.NgayLap)
    BEGIN
        RAISERROR ('Ngày lập phiếu ĐKHP phải trước ngày lập phiếu thu của phiếu đăng ký đó!', 16, 1)
        ROLLBACK TRANSACTION
    END
END;
GO

-- Trigger - Số tiền thu không được vượt quá số tiền còn lại
CREATE TRIGGER TRIG_ISUD_PHIEUTHUHP_SOTIENTHU_SOTIENCONLAI
ON PHIEUTHUHP FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted i 
				JOIN PHIEUDKHP pdk ON i.MaPhieuDKHP = pdk.MaPhieuDKHP 
				WHERE pdk.SoTienConLai < 0)
    BEGIN
        RAISERROR ('Số tiền thu không được vượt quá số tiền còn lại trong phiếu DKHP!', 16, 1)
        ROLLBACK TRANSACTION
    END
END;
GO
--Trigger - Chỉ được đăng ký các môn học được mở trong cùng học kỳ năm học
CREATE TRIGGER TRIG_ISUD_CT_DKHP_MAHKNH
ON CT_DKHP FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @MaHKNH1 VARCHAR(4)
	DECLARE @MaHKNH2 VARCHAR(4)

	SELECT @MaHKNH1 = MaHKNH
	FROM PHIEUDKHP PDKHP 
	JOIN inserted i ON PDKHP.MaPhieuDKHP = i.MaPhieuDKHP

	SELECT @MaHKNH2 = MaHKNH
	FROM DSMHMO DSMM
	JOIN inserted i ON DSMM.MaMo = i.MaMo

    IF (@MaHKNH1 <> @MaHKNH2)
    BEGIN
        RAISERROR ('Chỉ được đăng ký các môn học được mở trong cùng học kỳ năm học!', 16, 1)
        ROLLBACK TRANSACTION
    END
END;
GO
--Trigger - Tự động cập nhật danh sách chưa đóng học phí
CREATE TRIGGER TRIG_UD_PHIEUDKHP_CAPNHATDSCHUADONGHP
ON PHIEUDKHP FOR UPDATE
AS
BEGIN
	DECLARE @SoTienConLai MONEY
	DECLARE @MSSV VARCHAR(8)
	DECLARE @MaHKNH VARCHAR(4)

	SELECT @SoTienConLai = SoTienConLai, @MSSV = MSSV, @MaHKNH = MaHKNH
	FROM inserted

	IF (@SoTienConLai > 0)
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM BCCHUADONGHP
					WHERE MSSV = @MSSV AND MaHKNH = @MaHKNH)
		BEGIN
			INSERT INTO BCCHUADONGHP (MaHKNH, MSSV) VALUES (@MaHKNH, @MSSV);
		END
    END
	ELSE
	BEGIN
		IF EXISTS (SELECT 1 FROM BCCHUADONGHP
					WHERE MSSV = @MSSV AND MaHKNH = @MaHKNH)
		BEGIN
			DELETE FROM BCCHUADONGHP WHERE MSSV = @MSSV AND MaHKNH = @MaHKNH;
		END
	END
END;
GO
