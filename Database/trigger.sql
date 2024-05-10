USE QLDKHP;

-- Check
ALTER TABLE SINHVIEN
ADD CONSTRAINT CEK_SV_GioiTinh CHECK (GioiTinh IN ('Nam', 'Nữ'));

ALTER TABLE HOCKY_NAMHOC
ADD CONSTRAINT CEK_HKNH_HocKy CHECK (HocKy IN ('Học kỳ 1', 'Học kỳ 2', 'Học kỳ hè'));

ALTER TABLE DTUUTIEN
ADD CONSTRAINT CEK_DTUT_TiLeGiam CHECK (TiLeGiam >= 0 AND TiLeGiam <= 1);

ALTER TABLE LOAIMON
ADD CONSTRAINT CEK_LM_TenLoaiMon CHECK (TenLoaiMon IN ('Lý thuyết', 'Thực hành'));

ALTER TABLE CT_NGANH
ADD CONSTRAINT CEK_CTN_HocKy CHECK (HocKy IN ('Học kỳ 1', 'Học kỳ 2', 'Học kỳ 3', 'Học kỳ 4', 'Học kỳ 5', 'Học kỳ 6', 'Học kỳ 7', 'Học kỳ 8'));

-- Trigger - xóa một phiếu DKHP sẽ xóa các thông tin liên quan.
CREATE TRIGGER TRIG_DL_PHIEUDKHP
ON PHIEUDKHP INSTEAD OF DELETE
AS
BEGIN
	DECLARE @MaPhieuDKHP VARCHAR(8)
	SELECT  @MaPhieuDKHP=MaPhieuDKHP FROM DELETED
	DELETE FROM	CT_DKHP WHERE MaPhieuDKHP=@MaPhieuDKHP
	DELETE FROM	PHIEUTHUHP WHERE MaPhieuDKHP=@MaPhieuDKHP
END

-- Trigger - xóa một DS Môn học mở sẽ xóa các thông tin liên quan.
CREATE TRIGGER TRIG_DL_DSMHMO
ON DSMHMO INSTEAD OF DELETE
AS
BEGIN
	DECLARE @MaMo VARCHAR(8)
	SELECT  @MaMo=MaMo FROM DELETED
	DELETE FROM	CT_DKHP WHERE MaMo=@MaMo
END

-- Trigger - xóa một môn học sẽ xóa các thông tin liên quan.
CREATE TRIGGER TRIG_DL_MONHOC
ON MONHOC INSTEAD OF DELETE
AS
BEGIN
	DECLARE @MaMH VARCHAR(8)
	SELECT  @MaMH=MaMH FROM DELETED
	DELETE FROM	CT_NGANH WHERE MaMH=@MaMH
	DELETE FROM	DSMHMO WHERE MaMH=@MaMH
END

-- Trigger - xóa một sinh viên sẽ xóa các thông tin liên quan.
CREATE TRIGGER TRIG_DELETE_SINHVIEN
ON SINHVIEN INSTEAD OF DELETE
AS
BEGIN
	DECLARE @MSSV VARCHAR(8)
	SELECT  @MSSV=MSSV FROM DELETED
	DELETE FROM	BCCHUADONGHP WHERE MSSV=@MSSV
	DELETE FROM	PHIEUDKHP WHERE MSSV=@MSSV
END

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
		FROM CT_DKHP ctdkhp
		JOIN DSMHMO mhmo ON ctdkhp.MaMo = mhmo.MaMo
		JOIN MONHOC mh ON mhmo.MaMH = mh.MaMH
		JOIN LOAIMON lm ON lm.MaLoaiMon = mh.MaLoaiMon
		WHERE ctdkhp.MaPhieuDKHP = @MaPhieuDKHP AND ctdkhp.MaMo = @MaMo

		UPDATE PHIEUDKHP
		SET TongTien = TongTien + @GiaTien
		WHERE MaPhieuDKHP = @MaPhieuDKHP
    END

    IF EXISTS(SELECT * FROM deleted)
    BEGIN
		SELECT @MaPhieuDKHP = MaPhieuDKHP, @MaMo = MaMo FROM deleted

		SELECT @GiaTien = mh.SoTC * lm.SoTienMotTC
		FROM CT_DKHP ctdkhp
		JOIN DSMHMO mhmo ON ctdkhp.MaMo = mhmo.MaMo
		JOIN MONHOC mh ON mhmo.MaMH = mh.MaMH
		JOIN LOAIMON lm ON lm.MaLoaiMon = mh.MaLoaiMon
		WHERE ctdkhp.MaPhieuDKHP = @MaPhieuDKHP AND ctdkhp.MaMo = @MaMo

		UPDATE PHIEUDKHP
		SET TongTien = TongTien - @GiaTien
		WHERE MaPhieuDKHP = @MaPhieuDKHP
    END
END;

-- Trigger - Tự động tính số tiền phải đóng
CREATE TRIGGER TRIG_UD_PHIEUDKHP_TINHSOTIENPHAIDONG
ON PHIEUDKHP FOR UPDATE
AS
BEGIN
	DECLARE @MaPhieuDK VARCHAR(8)
	SELECT @MaPhieuDK = MaPhieuDKHP FROM inserted

	UPDATE PHIEUDKHP
    SET SoTienPhaiDong = (SELECT pdkhp.TongTien * (1 - dtut.TiLeGiam)
                          FROM PHIEUDKHP pdkhp 
						  JOIN SINHVIEN sv ON pdkhp.MSSV = sv.MSSV
						  JOIN DTUUTIEN dtut ON sv.MaDT = dtut.MaDT
                          WHERE pdkhp.MaPhieuDKHP = @MaPhieuDK)
    WHERE MaPhieuDKHP = @MaPhieuDK
END;

CREATE TRIGGER TRIG_UD_DTUUTIEN_TINHSOTIENPHAIDONG 
ON DTUUTIEN FOR UPDATE -- TiLeGiam
AS
BEGIN
	DECLARE @MaDT VARCHAR(8)
	SELECT @MaDT = MaDT FROM inserted

	UPDATE PHIEUDKHP
    SET SoTienPhaiDong = TEMP.NewSoTienPhaiDong
	FROM PHIEUDKHP
    JOIN (SELECT MaPhieuDKHP, pdkhp.TongTien * (1 - dtut.TiLeGiam) AS NewSoTienPhaiDong
			FROM PHIEUDKHP pdkhp 
			JOIN SINHVIEN sv ON pdkhp.MSSV = sv.MSSV
			JOIN DTUUTIEN dtut ON sv.MaDT = dtut.MaDT
			WHERE dtut.MaDT = @MaDT) AS TEMP
	ON PHIEUDKHP.MaPhieuDKHP = TEMP.MaPhieuDKHP
END;

-- Trigger - Tự động cập nhật số tiền đã đóng và số tiền còn lại
CREATE TRIGGER TRIG_ISUDDL_PHIEUTHUHP_CAPNHATSTDADONGVASTCONLAI
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
			SoTienConLai = SoTienPhaiDong - (SoTienDaDong + @SoTienThu)
		WHERE MaPhieuDKHP = @MaPhieuDKHP
    END

    IF EXISTS(SELECT * FROM deleted)
    BEGIN
		SELECT @MaPhieuDKHP = MaPhieuDKHP, @SoTienThu = SoTienThu FROM deleted

		UPDATE PHIEUDKHP
		SET SoTienDaDong = SoTienDaDong - @SoTienThu,
			SoTienConLai = SoTienPhaiDong - (SoTienDaDong - @SoTienThu)
		WHERE MaPhieuDKHP = @MaPhieuDKHP
    END
END;

-- Trigger - Ngày lập phiếu thu phải trước thời hạn đóng học phí trong cùng một học kỳ năm học
CREATE TRIGGER TRIG_ISUD_PHIEUTHUHP_CAPNHATSTDADONGVASTCONLAI
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

-- Trigger - Ngày lập phiếu ĐKHP phải trước thời hạn đóng học phí trong cùng một học kỳ năm học
CREATE TRIGGER TRIG_ISUD_PHIEUDKHP_CAPNHATSTDADONGVASTCONLAI
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


-- Trigger - Số tiền thu không được vượt quá số tiền còn lại
CREATE TRIGGER TRIG_ISUD_PHIEUTHUHP_SOTIENTHU_SOTIENCONLAI
ON PHIEUTHUHP FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted i 
				JOIN PHIEUDKHP pdk ON i.MaPhieuDKHP = pdk.MaPhieuDKHP 
				WHERE i.SoTienThu > pdk.SoTienConLai)
    BEGIN
        RAISERROR ('Số tiền thu không được vượt quá số tiền còn lại trong phiếu DKHP!', 16, 1)
        ROLLBACK TRANSACTION
    END
END;
