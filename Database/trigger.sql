-- Check
ALTER TABLE SINHVIEN
ADD CONSTRAINT GioiTinh CHECK (GioiTinh IN ('Nam', 'Nữ'));

ALTER TABLE HOCKY_NAMHOC
ADD CONSTRAINT HocKy CHECK (HocKy IN ('Học kỳ 1', 'Học kỳ 2', 'Học kỳ hè'));

ALTER TABLE DTUUTIEN
ADD CONSTRAINT TiLeGiam CHECK (TiLeGiam >= 0 AND TiLeGiam <= 1);

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
