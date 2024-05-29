-- Create database
CREATE DATABASE QLDKHP;
GO

USE QLDKHP;
GO

-- Create tables
CREATE TABLE TINH (
    MaTinh VARCHAR(3) PRIMARY KEY NOT NULL,
    TenTinh NVARCHAR(20)
);

CREATE TABLE HUYEN (
    MaHuyen VARCHAR(6) PRIMARY KEY NOT NULL,
    TenHuyen NVARCHAR(20),
    MaTinh VARCHAR(3) NOT NULL,
    VungSauVungXa BIT,
    FOREIGN KEY (MaTinh) REFERENCES TINH(MaTinh)
);

CREATE TABLE DTUUTIEN (
    MaDT VARCHAR(5) PRIMARY KEY NOT NULL,
    TenDT NVARCHAR(20),
    TiLeGiam FLOAT
);

CREATE TABLE KHOA (
    MaKhoa VARCHAR(3) PRIMARY KEY NOT NULL,
    TenKhoa NVARCHAR(50)
);

CREATE TABLE NGANHHOC (
    MaNH VARCHAR(6) PRIMARY KEY NOT NULL,
    TenNH NVARCHAR(50),
    MaKhoa VARCHAR(3) NOT NULL,
    FOREIGN KEY (MaKhoa) REFERENCES KHOA(MaKhoa)
);

CREATE TABLE SINHVIEN (
    MSSV VARCHAR(8) PRIMARY KEY NOT NULL,
    HoTen NVARCHAR(30),
    NgaySinh SMALLDATETIME,
    GioiTinh NVARCHAR(3),
    MaHuyen VARCHAR(6) NOT NULL,
    MaDT VARCHAR(5) NOT NULL,
    MaNH VARCHAR(6) NOT NULL,
    FOREIGN KEY (MaHuyen) REFERENCES HUYEN(MaHuyen),
    FOREIGN KEY (MaDT) REFERENCES DTUUTIEN(MaDT),
    FOREIGN KEY (MaNH) REFERENCES NGANHHOC(MaNH)
);

CREATE TABLE LOAIMON (
    MaLoaiMon VARCHAR(3) PRIMARY KEY NOT NULL,
    TenLoaiMon NVARCHAR(20),
    SoTietMotTC INT,
    SoTienMotTC MONEY
);

CREATE TABLE MONHOC (
    MaMH VARCHAR(5) PRIMARY KEY NOT NULL,
    TenMH NVARCHAR(50),
    SoTiet INT,
    SoTC INT,
    MaLoaiMon VARCHAR(3) NOT NULL,
    FOREIGN KEY (MaLoaiMon) REFERENCES LOAIMON(MaLoaiMon)
);

CREATE TABLE CT_NGANH (
    MaCT_Nganh VARCHAR(8) NOT NULL,
    MaNH VARCHAR(6) NOT NULL,
    MaMH VARCHAR(5) NOT NULL,
    HocKy INT,
    GhiChu NVARCHAR(50),
    PRIMARY KEY (MaCT_Nganh),
    FOREIGN KEY (MaNH) REFERENCES NGANHHOC(MaNH),
    FOREIGN KEY (MaMH) REFERENCES MONHOC(MaMH)
);

CREATE TABLE HOCKY_NAMHOC (
    MaHKNH VARCHAR(4) PRIMARY KEY NOT NULL,
    HocKy INT,
    NamHoc INT,
    ThoiHanDongHocPhi SMALLDATETIME
);

CREATE TABLE PHIEUDKHP (
    MaPhieuDKHP VARCHAR(8) PRIMARY KEY NOT NULL,
    NgayLap SMALLDATETIME,
    TongTien MONEY,
    SoTienPhaiDong MONEY,
    SoTienDaDong MONEY,
    SoTienConLai MONEY,
    MSSV VARCHAR(8) NOT NULL,
    MaHKNH VARCHAR(4) NOT NULL,
    FOREIGN KEY (MSSV) REFERENCES SINHVIEN(MSSV),
    FOREIGN KEY (MaHKNH) REFERENCES HOCKY_NAMHOC(MaHKNH)
);

CREATE TABLE DSMHMO (
    MaMo VARCHAR(8) PRIMARY KEY NOT NULL,
    MaHKNH VARCHAR(4) NOT NULL,
    MaCT_Nganh VARCHAR(8) NOT NULL,
    FOREIGN KEY (MaHKNH) REFERENCES HOCKY_NAMHOC(MaHKNH),
    FOREIGN KEY (MaCT_Nganh) REFERENCES CT_NGANH(MaCT_Nganh)
);

CREATE TABLE CT_DKHP (
    MaPhieuDKHP VARCHAR(8) NOT NULL,
    MaMo VARCHAR(8) NOT NULL,
    PRIMARY KEY (MaPhieuDKHP, MaMo),
    FOREIGN KEY (MaPhieuDKHP) REFERENCES PHIEUDKHP(MaPhieuDKHP),
    FOREIGN KEY (MaMo) REFERENCES DSMHMO(MaMo)
);

CREATE TABLE PHIEUTHUHP (
    MaPhieuThu VARCHAR(8) PRIMARY KEY NOT NULL,
    SoTienThu MONEY,
    NgayLap SMALLDATETIME,
    MaPhieuDKHP VARCHAR(8) NOT NULL,
    FOREIGN KEY (MaPhieuDKHP) REFERENCES PHIEUDKHP(MaPhieuDKHP)
);

CREATE TABLE BCCHUADONGHP (
    MaHKNH VARCHAR(4) NOT NULL,
    MSSV VARCHAR(8) NOT NULL,
    PRIMARY KEY (MaHKNH, MSSV),
    FOREIGN KEY (MaHKNH) REFERENCES HOCKY_NAMHOC(MaHKNH),
    FOREIGN KEY (MSSV) REFERENCES SINHVIEN(MSSV)
);

CREATE TABLE ACCOUNT
(
	Id INT PRIMARY KEY,
	DisplayName NVARCHAR(50) NOT NULL,
	UserName VARCHAR(50) NOT NULL,
	Email VARCHAR(50) NOT NULL,
	Password VARCHAR(50) NOT NULL,
	Type INT NOT NULL -- 0:Admin, 1:PDT, 2:PTV
);

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
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN DSMHMO d ON i.MaHKNH = d.MaHKNH AND i.MaCT_Nganh = d.MaCT_Nganh
        WHERE i.MaMo <> d.MaMo
    )
    BEGIN
        RAISERROR ('Trong CSDL đã tồn tại DSMHMO có MaHKNH, MaCT_Nganh này.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO
CREATE TRIGGER UNQ_PDK_SV_HKNH
ON PHIEUDKHP
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN PHIEUDKHP p ON i.MSSV = p.MSSV AND i.MaHKNH = p.MaHKNH
	WHERE i.MaPhieuDKHP <> p.MaPhieuDKHP 
    )
    BEGIN
        RAISERROR ('Trong CSDL đã tồn tại PHIEUDKHP có MSSV và MaHKNH này.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO
CREATE TRIGGER UNQ_CTN_NH_MH
ON CT_NGANH
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN CT_NGANH c ON i.MaNH = c.MaNH AND i.MaMH = c.MaMH
	WHERE i.MaCT_Nganh <> c.MaCT_Nganh 
    )
    BEGIN
        RAISERROR ('Trong CSDL đã tồn tại CT_NGANH có MaNH và MaMH này.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO
-- Trigger - xóa một phiếu DKHP sẽ xóa các thông tin liên quan.
CREATE TRIGGER TRIG_DL_PHIEUDKHP
ON PHIEUDKHP INSTEAD OF DELETE
AS
BEGIN
    DELETE CT_DKHP FROM CT_DKHP
    JOIN DELETED ON CT_DKHP.MaPhieuDKHP = DELETED.MaPhieuDKHP;

    DELETE PHIEUTHUHP
    FROM PHIEUTHUHP
    JOIN DELETED ON PHIEUTHUHP.MaPhieuDKHP = DELETED.MaPhieuDKHP;

    DELETE PHIEUDKHP
    FROM PHIEUDKHP
    JOIN DELETED ON PHIEUDKHP.MaPhieuDKHP = DELETED.MaPhieuDKHP;

    DELETE BCCHUADONGHP
    FROM BCCHUADONGHP
    JOIN DELETED ON BCCHUADONGHP.MSSV = DELETED.MSSV AND BCCHUADONGHP.MaHKNH = DELETED.MaHKNH;
END;
GO


-- Trigger - xóa một DS Môn học mở sẽ xóa các thông tin liên quan.
CREATE TRIGGER TRIG_DL_DSMHMO
ON DSMHMO INSTEAD OF DELETE
AS
BEGIN
    DELETE CT_DKHP FROM CT_DKHP
    JOIN DELETED ON CT_DKHP.MaMo = DELETED.MaMo;

	DELETE DSMHMO FROM DSMHMO
    JOIN DELETED ON DSMHMO.MaMo = DELETED.MaMo;
END;
GO
-- Trigger - xóa một ctnganh sẽ xóa các thông tin liên quan.
CREATE TRIGGER TRIG_DL_CTNGANH
ON CT_NGANH INSTEAD OF DELETE
AS
BEGIN
    DELETE DSMHMO FROM DSMHMO
    JOIN DELETED ON DSMHMO.MaCT_Nganh = DELETED.MaCT_Nganh;

    DELETE CT_NGANH FROM CT_NGANH
    JOIN DELETED ON CT_NGANH.MaCT_Nganh = DELETED.MaCT_Nganh;
END;
GO
-- Trigger - xóa một môn học sẽ xóa các thông tin liên quan.
CREATE TRIGGER TRIG_DL_MONHOC
ON MONHOC INSTEAD OF DELETE
AS
BEGIN
    DELETE CT_NGANH FROM CT_NGANH
    JOIN DELETED ON CT_NGANH.MaMH = DELETED.MaMH;

    DELETE MONHOC FROM MONHOC
    JOIN DELETED ON MONHOC.MaMH = DELETED.MaMH;
END;
GO
-- Trigger - xóa một sinh viên sẽ xóa các thông tin liên quan.
CREATE TRIGGER TRIG_DL_SINHVIEN
ON SINHVIEN
INSTEAD OF DELETE
AS
BEGIN
    DELETE BCCHUADONGHP FROM BCCHUADONGHP
    JOIN DELETED ON BCCHUADONGHP.MSSV = DELETED.MSSV;

    DELETE PHIEUDKHP FROM PHIEUDKHP
    JOIN DELETED ON PHIEUDKHP.MSSV = DELETED.MSSV;

    DELETE SINHVIEN FROM SINHVIEN
    JOIN DELETED ON SINHVIEN.MSSV = DELETED.MSSV;
END;
GO
-- Trigger - xóa một tỉnh sẽ xóa các thông tin liên quan.
CREATE TRIGGER TRIG_DL_TINH
ON TINH INSTEAD OF DELETE
AS
BEGIN
    DELETE HUYEN FROM HUYEN
    JOIN DELETED ON HUYEN.MaTinh = DELETED.MaTinh;

	DELETE TINH FROM TINH
    JOIN DELETED ON TINH.MaTinh = DELETED.MaTinh;
END;
GO
-- Trigger - xóa một khoa sẽ xóa các thông tin liên quan.
CREATE TRIGGER TRIG_DL_KHOA
ON KHOA INSTEAD OF DELETE
AS
BEGIN
    DELETE NGANHHOC FROM NGANHHOC
    JOIN DELETED ON NGANHHOC.MaKhoa = DELETED.MaKhoa;

	DELETE KHOA FROM KHOA
    JOIN DELETED ON KHOA.MaKhoa = DELETED.MaKhoa;
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
    DECLARE @Changes TABLE (
        MaPhieuDKHP VARCHAR(8),
        MaMo VARCHAR(8),
        GiaTien MONEY
    );

    IF EXISTS(SELECT * FROM inserted)
    BEGIN
        INSERT INTO @Changes (MaPhieuDKHP, MaMo, GiaTien)
        SELECT i.MaPhieuDKHP, i.MaMo,
            mh.SoTC * lm.SoTienMotTC
        FROM inserted i
        JOIN DSMHMO mhmo ON i.MaMo = mhmo.MaMo
        JOIN CT_NGANH ctn ON mhmo.MaCT_Nganh = ctn.MaCT_Nganh
        JOIN MONHOC mh ON ctn.MaMH = mh.MaMH
        JOIN LOAIMON lm ON mh.MaLoaiMon = lm.MaLoaiMon;
    END

    IF EXISTS(SELECT * FROM deleted)
    BEGIN
        INSERT INTO @Changes (MaPhieuDKHP, MaMo, GiaTien)
        SELECT d.MaPhieuDKHP, d.MaMo,
            -mh.SoTC * lm.SoTienMotTC
        FROM deleted d
        JOIN DSMHMO mhmo ON d.MaMo = mhmo.MaMo
        JOIN CT_NGANH ctn ON mhmo.MaCT_Nganh = ctn.MaCT_Nganh
        JOIN MONHOC mh ON ctn.MaMH = mh.MaMH
        JOIN LOAIMON lm ON mh.MaLoaiMon = lm.MaLoaiMon;
    END

    UPDATE PHIEUDKHP
    SET TongTien = TongTien + (
        SELECT SUM(GiaTien)
        FROM @Changes
        WHERE MaPhieuDKHP = PHIEUDKHP.MaPhieuDKHP
    )
    WHERE EXISTS (
        SELECT 1
        FROM @Changes
        WHERE MaPhieuDKHP = PHIEUDKHP.MaPhieuDKHP
    );
END;
GO
-- Trigger - Tự động tính số tiền phải đóng
CREATE TRIGGER TRIG_UD_PHIEUDKHP_TINHSOTIENPHAIDONG
ON PHIEUDKHP FOR UPDATE
AS
BEGIN
    DECLARE @Changes TABLE (
        MaPhieuDKHP VARCHAR(8),
        SoTienPhaiDong MONEY,
        SoTienConLai MONEY
    );

    INSERT INTO @Changes (MaPhieuDKHP, SoTienPhaiDong, SoTienConLai)
    SELECT i.MaPhieuDKHP,
           pdkhp.TongTien * (1 - dtut.TiLeGiam),
           pdkhp.SoTienConLai - (pdkhp.SoTienPhaiDong - pdkhp.TongTien * (1 - dtut.TiLeGiam))
    FROM inserted i
    JOIN PHIEUDKHP pdkhp ON i.MaPhieuDKHP = pdkhp.MaPhieuDKHP
    JOIN SINHVIEN sv ON pdkhp.MSSV = sv.MSSV
    JOIN DTUUTIEN dtut ON sv.MaDT = dtut.MaDT;

    UPDATE PHIEUDKHP
    SET SoTienPhaiDong = c.SoTienPhaiDong,
        SoTienConLai = c.SoTienConLai
    FROM PHIEUDKHP pdkhp
    JOIN @Changes c ON pdkhp.MaPhieuDKHP = c.MaPhieuDKHP;
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
--Trigger - tự sinh DSMHMO
CREATE TRIGGER TRIG_IS_HKNH_IS_DSMHMO
ON HOCKY_NAMHOC FOR INSERT
AS
BEGIN
    DECLARE @MaHKNH VARCHAR(4)
    DECLARE @HocKy INT
    DECLARE @NextMaMo INT

    SELECT @MaHKNH = i.MaHKNH, @HocKy = i.HocKy
    FROM inserted i

	IF @HocKy NOT IN (1, 2)
    BEGIN
        RETURN;
    END

    SELECT @NextMaMo = ISNULL(MAX(CAST(SUBSTRING(MaMo, 3, 6) AS INT)), 0) + 1
    FROM DSMHMO

    INSERT INTO DSMHMO (MaMo, MaHKNH, MaCT_Nganh)
    SELECT 'MM' + RIGHT('000000' + CAST(ROW_NUMBER() OVER (ORDER BY MaCT_Nganh) + @NextMaMo - 1 AS VARCHAR(6)), 6), @MaHKNH, MaCT_Nganh
    FROM CT_NGANH
    WHERE HocKy % 2 = CASE WHEN @HocKy = 1 THEN 1 ELSE 0 END
END;
GO

CREATE PROC PROC_CEK_ACCOUNT
@userName NVARCHAR(50), @passWord NVARCHAR(50)
AS
BEGIN
	SELECT * FROM ACCOUNT WHERE UserName = @userName AND Password = @passWord
END
GO

INSERT INTO ACCOUNT VALUES 
(1, N'Admin', 'admin', 'admin@uit.edu.vn', 'password', 0),
(2, N'Phòng đào tạo', 'phongdaotao', 'admin@uit.edu.vn', 'password', 1),
(3, N'Phòng tài vụ', 'phongtaivu', 'admin@uit.edu.vn', 'password', 2);


-- Insert data
-- Table TINH
INSERT INTO TINH (MaTinh, TenTinh) VALUES 
('T01', N'Hà Nội'),
('T02', N'Hồ Chí Minh'),
('T03', N'Hải Phòng'),
('T04', N'Đà Nẵng'),
('T05', N'Thái Bình'),
('T06', N'Bình Dương'),
('T07', N'Đắk Lắk'),
('T08', N'Long An'),
('T09', N'Bình Định'),
('T10', N'Quảng Trị');

-- Table HUYEN
INSERT INTO HUYEN (MaHuyen, TenHuyen, MaTinh, VungSauVungXa) VALUES 
-- Hà Nội
('T01H01', N'Ba Đình', 'T01', 0),
('T01H02', N'Hai Bà Trưng', 'T01', 0),
('T01H03', N'Cầu Giấy', 'T01', 0),
('T01H04', N'Thanh Trì', 'T01', 0),
('T01H05', N'Ba Vì', 'T01', 0),

-- Hồ Chí Minh
('T02H01', N'Quận 1', 'T02', 0),
('T02H02', N'Quận 5', 'T02', 0),
('T02H03', N'Quận Bình Thạnh', 'T02', 0),
('T02H04', N'Quận 8', 'T02', 0),
('T02H05', N'Tp Thủ Đức', 'T02', 0),

-- Hải Phòng
('T03H01', N'Kiến An', 'T03', 0),
('T03H02', N'Lê Chân', 'T03', 0),
('T03H03', N'Ngô Quyền', 'T03', 0),
('T03H04', N'An Dương', 'T03', 0),
('T03H05', N'Hồng Bàng', 'T03', 0),

-- Đà Nẵng
('T04H01', N'Hải Châu', 'T04', 0),
('T04H02', N'Liên Chiểu', 'T04', 0),
('T04H03', N'Ngũ Hành Sơn', 'T04', 0),
('T04H04', N'Sơn Trà', 'T04', 0),
('T04H05', N'Cẩm Lệ', 'T04', 0),

-- Thái Bình
('T05H01', N'Đông Hưng', 'T05', 0),
('T05H02', N'Hưng Hà', 'T05', 0),
('T05H03', N'Tiền Hải', 'T05', 0),
('T05H04', N'Kiến Xương', 'T05', 0),
('T05H05', N'Vũ Thư', 'T05', 0),

-- Bình Dương
('T06H01', N'Thuận An', 'T06', 0),
('T06H02', N'Dĩ An', 'T06', 0),
('T06H03', N'Tân Uyên', 'T06', 0),
('T06H04', N'Thủ Dầu Một', 'T06', 0),
('T06H05', N'Bến Cát', 'T06', 0),

-- Đắk Lắk
('T07H01', N'Buôn Ma Thuột', 'T07', 0),
('T07H02', N'Krông Búk', 'T07', 1),
('T07H03', N'Ea Hleo', 'T07', 1),
('T07H04', N'Buôn Đôn', 'T07', 1),
('T07H05', N'Lắk', 'T07', 1),

-- Long An
('T08H01', N'Cần Giuộc', 'T08', 0),
('T08H02', N'Châu Thành', 'T08', 0),
('T08H03', N'Đức Hòa', 'T08', 0),
('T08H04', N'Cần Đước', 'T08', 0),
('T08H05', N'Bến Lức', 'T08', 0),

-- Bình Định
('T09H01', N'Tuy Phước', 'T09', 0),
('T09H02', N'Hoài Ân', 'T09', 0),
('T09H03', N'Phù Cát', 'T09', 0),
('T09H04', N'Tp Quy Nhơn', 'T09', 0),
('T09H05', N'Vân Canh', 'T09', 0),

-- Quảng Trị
('T10H01', N'Đông Hà', 'T10', 0),
('T10H02', N'Hải Lăng', 'T10', 0),
('T10H03', N'Triệu Phong', 'T10', 0),
('T10H04', N'Đakrông', 'T10', 0),
('T10H05', N'Vĩnh Linh', 'T10', 0);

--Table DTUUTIEN
INSERT INTO DTUUTIEN (MaDT, TenDT, TiLeGiam) VALUES
('DT001', N'Không đối tượng', 0),
('DT002', N'Con liệt sĩ', 0.8),
('DT003', N'Con thương binh', 0.5),
('DT004', N'Vùng sâu vùng xa', 0.3),
('DT005', N'Mồ côi', 0.8),
('DT006', N'Khuyết tật', 0.5),
('DT007', N'Hộ nghèo', 0.5),
('DT008', N'Dân tộc thiểu số', 0.3);

-- Table KHOA
INSERT INTO KHOA (MaKhoa, TenKhoa) VALUES
('K01', N'Khoa học máy tính'),
('K02', N'Khoa học và Kỹ thuật thông tin'),
('K03', N'Kỹ thuật máy tính'),
('K04', N'Công nghệ phần mềm'),
('K05', N'Hệ thống thông tin'),
('K06', N'Mạng máy tính và truyền thông');

--Table NGANHHOC
INSERT INTO NGANHHOC (MaNH, TenNH, MaKhoa) VALUES
('K01N01', N'Khoa học Máy tính', 'K01'),
('K01N02', N'Trí tuệ nhân tạo', 'K01'),
('K02N01', N'Công nghệ Thông tin', 'K02'),
('K02N02', N'Khoa học Dữ liệu', 'K02'),
('K03N01', N'Kỹ thuật Máy tính', 'K03'),
('K04N01', N'Kỹ thuật Phần mềm', 'K04'),
('K05N01', N'Hệ thống Thông tin', 'K05'),
('K05N02', N'Thương mại điện tử', 'K05'),
('K06N01', N'Mạng máy tính và Truyền thông dữ liệu', 'K06'),
('K06N02', N'An toàn Thông tin', 'K06');

--Table SINHVIEN
SET DATEFORMAT DMY
INSERT INTO SINHVIEN (MSSV, HoTen, NgaySinh, GioiTinh, MaHuyen, MaDT, MaNH) VALUES
('21522145', N'Lê Công Quốc Huy', '4-2-2003', N'Nam', 'T05H01', 'DT001', 'K02N01'),
('21522146', N'Lê Gia Huy', '10-1-2003', N'Nam', 'T06H05', 'DT001', 'K02N01'),
('21522141', N'Hoàng Gia Huy', '7-3-2003', N'Nam', 'T09H05', 'DT001', 'K02N01'),
('21522676', N'Nguyễn Thành Tín', '2-10-2003', N'Nam', 'T08H04', 'DT001', 'K02N01'),
('21521667', N'Phan Vỹ Văn', '7-6-2003', N'Nam', 'T09H03', 'DT001', 'K02N01'),
('21521062', N'Dương Thị Ngọc Anh', '6-4-2003', N'Nữ', 'T01H03', 'DT001', 'K03N01'),
('21521061', N'Đỗ Trần Mai Anh', '31-5-2003', N'Nữ', 'T03H04', 'DT001', 'K03N01'),
('21520138', N'Lê Nguyễn Nhật Anh', '16-8-2003', N'Nữ', 'T10H04', 'DT001', 'K01N01'),
('21520900', N'Nguyễn Ngọc Mai Khanh', '11-11-2003', N'Nữ', 'T01H03', 'DT001', 'K06N02'),
('21522315', N'Nguyễn Thị Cẩm Ly', '14-2-2003', N'Nữ', 'T09H01', 'DT007', 'K02N01'),
    
('21521140', N'Nguyễn Tuệ Minh', '25-11-2003', N'Nữ', 'T02H03', 'DT001', 'K04N01'),
('21521144', N'Trần Tuyết Minh', '22-5-2003', N'Nữ', 'T03H05', 'DT001', 'K04N01'),
('21521174', N'Nguyễn Thị Kim Ngân', '8-5-2003', N'Nữ', 'T08H05', 'DT007', 'K05N01'),
('21522884', N'Nguyễn Bích Phượng', '10-7-2003', N'Nữ', 'T02H04', 'DT001', 'K06N01'),
('21521486', N'Bùi Thị Anh Thư', '16-10-2003', N'Nữ', 'T07H03', 'DT004', 'K06N01'),
('21522698', N'Phan Huỳnh Thiên Trang', '15-2-2003', N'Nữ', 'T04H02', 'DT001', 'K01N01'),
('21521804', N'Hồ Vũ An', '6-10-2003', N'Nam', 'T03H05', 'DT001', 'K05N01'),
('21521846', N'Huỳnh Hải Băng', '1-7-2003', N'Nam', 'T10H05', 'DT001', 'K01N02'),
('21521156', N'Đoàn Lê Giang Nam', '26-10-2003', N'Nam', 'T04H05', 'DT001', 'K02N02'),
('21521178', N'Trần Thanh Nghị', '29-8-2003', N'Nam', 'T09H05', 'DT002', 'K04N01'),

('21521180', N'Lê Đức Nghĩa', '18-1-2003', N'Nam', 'T04H04', 'DT001', 'K02N02'),
('21521183', N'Nguyễn Thành Nghĩa', '6-8-2003', N'Nam', 'T02H05', 'DT003', 'K04N01'),
('21521201', N'Nguyễn Đỗ Đức Nguyên', '27-3-2003', N'Nam', 'T04H04', 'DT001', 'K05N02'),
('21521226', N'Nguyễn Minh Nhật', '9-4-2003', N'Nam', 'T10H01', 'DT001', 'K02N01'),
('21521268', N'Nguyễn Thành Phi', '21-9-2003', N'Nam', 'T09H05', 'DT001', 'K01N02'),
('21521271', N'Lê Thanh Phong', '11-10-2003', N'Nam', 'T10H03', 'DT001', 'K01N02'),
('21521323', N'Dương Uy Quan', '17-4-2003', N'Nam', 'T05H02', 'DT001', 'K05N02'),
('21521595', N'Nguyễn Thành Trung', '21-11-2003', N'Nam', 'T03H04', 'DT001', 'K06N01'),
('21522747', N'Trịnh Tuấn Tú', '15-6-2003', N'Nam', 'T09H04', 'DT008', 'K03N01'),
('21522755', N'Nguyễn Mạnh Tuấn', '4-3-2003', N'Nam', 'T09H01', 'DT001', 'K04N01'),

('21520389', N'Phan Cả Phát', '23-11-2003', N'Nam', 'T01H01', 'DT001', 'K01N01'),
('21522496', N'Nguyễn Minh Quân', '23-7-2003', N'Nam', 'T09H01', 'DT001', 'K04N01'),
('21522515', N'Nguyễn Việt Quang', '30-10-2003', N'Nam', 'T07H04', 'DT004', 'K05N02'),
('21522528', N'Dương Văn Quy', '10-1-2003', N'Nam', 'T03H05', 'DT001', 'K01N01'),
('21522544', N'Nguyễn Ngọc Thanh Sang', '15-4-2003', N'Nam', 'T08H03', 'DT001', 'K01N01'),
('21522556', N'Phạm Thanh Sơn', '16-11-2003', N'Nam', 'T10H01', 'DT001', 'K01N01'),
('21521476', N'Vũ Ngọc Trường Thịnh', '18-1-2003', N'Nam', 'T02H05', 'DT001', 'K03N01'),
('21522681', N'Phạm Đăng Tỉnh', '7-9-2003', N'Nam', 'T09H01', 'DT001', 'K01N01'),
('21522712', N'Phạm Minh Triết', '3-1-2003', N'Nam', 'T10H05', 'DT001', 'K03N01'),
('21522732', N'Lê Quang Trường', '9-5-2003', N'Nam', 'T03H03', 'DT001', 'K02N02'),

('21522762', N'Trần Anh Tuấn', '14-1-2003', N'Nam', 'T07H01', 'DT001', 'K03N01'),
('21522885', N'Phan Thị Cát Tường', '26-6-2003', N'Nữ', 'T07H03', 'DT004', 'K04N01'),
('21522536', N'Nguyễn Phan Trúc Quỳnh', '30-5-2003', N'Nữ', 'T06H02', 'DT001', 'K04N01'),
('21522357', N'Lê Hải Nam', '22-3-2003', N'Nam', 'T05H05', 'DT001', 'K04N01'),
('21521108', N'Nguyễn Minh Lý', '22-7-2003', N'Nam', 'T03H02', 'DT001', 'K02N01'),
('21522276', N'Nguyễn Cao Lãm', '17-11-2003', N'Nam', 'T01H04', 'DT001', 'K06N01'),
('21522168', N'Trần Minh Huy', '30-7-2003', N'Nam', 'T08H01', 'DT001', 'K04N01'),
('21522037', N'Trần Thị Hải', '20-10-2003', N'Nữ', 'T01H01', 'DT001', 'K02N02'),
('21521029', N'Tô Quốc Kiện', '11-3-2003', N'Nam', 'T01H03', 'DT001', 'K03N01'),
('21522055', N'Phan Công Hậu', '25-7-2003', N'Nam', 'T10H02', 'DT001', 'K06N01');

--Table LOAIMON
INSERT INTO LOAIMON (MaLoaiMon, TenLoaiMon, SoTietMotTC, SoTienMotTC) VALUES
('LM1', N'Lý thuyết', 15, 27000),
('LM2', N'Thực hành', 30, 37000);

--Table MONHOC 
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH001', N'Tư tưởng Hồ Chí Minh', 30, 'LM1');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH002', N'Triết học Mác – Lênin', 45, 'LM1');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH003', N'Kinh tế chính trị Mác – Lênin', 30, 'LM1');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH004', N'Chủ nghĩa xã hội khoa học', 30, 'LM1');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH005', N'Lịch sử Đảng Cộng sản Việt Nam', 30, 'LM1');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH006', N'Giải tích', 60, 'LM1');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH007', N'Đại số tuyến tính', 45, 'LM1');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH008', N'Cấu trúc rời rạc', 60, 'LM1');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH009', N'Xác suất thống kê', 45, 'LM1');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH010', N'Nhập môn Lập trình', 60, 'LM1');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH011', N'Kỹ năng nghề nghiệp', 30, 'LM1');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH012', N'Pháp luật đại cương', 30, 'LM1');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH013', N'Văn hóa doanh nghiệp Nhật Bản', 30, 'LM1');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH014', N'Tiếng Nhật 1', 60, 'LM1');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH015', N'Tiếng Nhật 2', 60, 'LM1');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH016', N'Tiếng Nhật 3', 60, 'LM1');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH017', N'Tiếng Nhật 4', 60, 'LM1');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH018', N'Tiếng Nhật 5', 45, 'LM1');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH019', N'Tiếng Nhật 6', 45, 'LM1');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH020', N'Tiếng Nhật 7', 45, 'LM1');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH021', N'Tiếng Nhật 8', 45, 'LM1');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH022', N'Lập trình hướng đối tượng', 45, 'LM1');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH023', N'Lập trình hướng đối tượng', 30, 'LM2');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH024', N'Cấu trúc dữ liệu và giải thuật', 45, 'LM1');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH025', N'Cơ sở dữ liệu', 45, 'LM1');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH026', N'Nhập môn mạng máy tính', 45, 'LM1');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH027', N'Nhập môn mạng máy tính', 30, 'LM2');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH028', N'Tổ chức và cấu trúc máy tính II', 45, 'LM1');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH029', N'Tổ chức và cấu trúc máy tính II', 30, 'LM2');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH030', N'Hệ điều hành', 45, 'LM1');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH031', N'Hệ điều hành', 30, 'LM2');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH032', N'Giới thiệu ngành Công nghệ Thông tin', 15, 'LM1');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH033', N'Cơ sở hạ tầng công nghệ thông tin', 45, 'LM1');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH034', N'Cơ sở hạ tầng công nghệ thông tin', 30, 'LM2');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH035', N'Quản lý thông tin', 45, 'LM1');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH036', N'Quản lý thông tin', 30, 'LM2');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH037', N'Internet và công nghệ Web', 45, 'LM1');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH038', N'Internet và công nghệ Web', 30, 'LM2');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH039', N'Thiết kế giao diện người dùng', 45, 'LM1');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH040', N'Thiết kế giao diện người dùng', 30, 'LM2');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH041', N'Nhập môn đảm bảo và an ninh thông tin', 45, 'LM1');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH042', N'Nhập môn đảm bảo và an ninh thông tin', 30, 'LM2');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH043', N'Nhập môn công nghệ phần mềm', 45, 'LM1');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH044', N'Nhập môn công nghệ phần mềm', 30, 'LM2');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH045', N'Điện toán đám mây', 45, 'LM1');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH046', N'Các chủ đề toán học cho KHDL', 45, 'LM1');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH047', N'Học máy thống kê', 45, 'LM1');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH048', N'Học máy thống kê', 30, 'LM2');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH049', N'Xử lý dữ liệu lớn', 45, 'LM1');
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES ('MH050', N'Xử lý dữ liệu lớn', 30, 'LM2');

--ct_nganh: 200
INSERT INTO CT_NGANH(MaCT_Nganh, MaNH, MaMH, HocKy) VALUES
('CT000001','K01N01','MH006',1),
('CT000002','K01N01','MH007',1),
('CT000003','K01N01','MH010',1),
('CT000004','K01N01','MH014',1),
('CT000005','K01N01','MH008',2),
('CT000006','K01N01','MH009',2),
('CT000007','K01N01','MH022',2),
('CT000008','K01N01','MH023',2),
('CT000009','K01N01','MH026',3),
('CT000010','K01N01','MH025',3),
('CT000011','K01N01','MH011',4),
('CT000012','K01N01','MH003',4),
('CT000013','K01N01','MH004',5),
('CT000014','K01N01','MH005',5),
('CT000015','K01N01','MH001',6),
('CT000016','K01N01','MH012',6),
('CT000017','K01N01','MH047',7),
('CT000018','K01N01','MH048',7),
('CT000019','K01N01','MH049',8),
('CT000020','K01N01','MH050',8),

('CT000021','K01N02','MH006',1),
('CT000022','K01N02','MH007',1),
('CT000023','K01N02','MH010',1),
('CT000024','K01N02','MH014',1),
('CT000025','K01N02','MH008',2),
('CT000026','K01N02','MH009',2),
('CT000027','K01N02','MH022',2),
('CT000028','K01N02','MH023',2),
('CT000029','K01N02','MH026',3),
('CT000030','K01N02','MH025',3),
('CT000031','K01N02','MH003',4),
('CT000032','K01N02','MH011',4),
('CT000033','K01N02','MH004',5),
('CT000034','K01N02','MH005',5),
('CT000035','K01N02','MH001',6),
('CT000036','K01N02','MH012',6),
('CT000037','K01N02','MH049',7),
('CT000038','K01N02','MH050',7),
('CT000039','K01N02','MH045',8),
('CT000040','K01N02','MH046',8);



INSERT INTO CT_NGANH(MaCT_Nganh, MaNH, MaMH, HocKy) VALUES
('CT000041','K02N01', 'MH032', 1),
('CT000042','K02N01', 'MH006', 1),
('CT000043','K02N01', 'MH002', 2),
('CT000044','K02N01', 'MH007', 2),
('CT000045','K02N01', 'MH010', 2),
('CT000046','K02N01', 'MH022', 3),
('CT000047','K02N01', 'MH023', 3),
('CT000048','K02N01', 'MH024', 3),
('CT000049','K02N01', 'MH030', 4),
('CT000050','K02N01', 'MH031', 4),
('CT000051','K02N01', 'MH025', 4),
('CT000052','K02N01', 'MH033', 5),
('CT000053','K02N01', 'MH034', 5),
('CT000054','K02N01', 'MH045', 5),
('CT000055','K02N01', 'MH041', 6),
('CT000056','K02N01', 'MH042', 6),
('CT000057','K02N01', 'MH046', 6),
('CT000058','K02N01', 'MH049', 7),
('CT000059','K02N01', 'MH050', 7),
('CT000060','K02N01', 'MH047', 8),
('CT000061','K02N02', 'MH007', 1),
('CT000062','K02N02', 'MH006', 1),
('CT000063','K02N02', 'MH005', 2),
('CT000064','K02N02', 'MH008', 2),
('CT000065','K02N02', 'MH009', 2),
('CT000066','K02N02', 'MH022', 3),
('CT000067','K02N02', 'MH023', 3),
('CT000068','K02N02', 'MH024', 3),
('CT000069','K02N02', 'MH025', 4),
('CT000070','K02N02', 'MH031', 4),
('CT000071','K02N02', 'MH032', 4),
('CT000072','K02N02', 'MH035', 5),
('CT000073','K02N02', 'MH036', 5),
('CT000074','K02N02', 'MH045', 5),
('CT000075','K02N02', 'MH046', 6),
('CT000076','K02N02', 'MH047', 6),
('CT000077','K02N02', 'MH048', 6),
('CT000078','K02N02', 'MH041', 7),
('CT000079','K02N02', 'MH042', 7),
('CT000080','K02N02', 'MH049', 8);


INSERT INTO CT_NGANH(MaCT_Nganh, MaNH, MaMH, HocKy) VALUES
('CT000081','K03N01', 'MH001', 1),
('CT000082','K03N01', 'MH002', 1),
('CT000083','K03N01', 'MH006', 2),
('CT000084','K03N01', 'MH007', 2),
('CT000085','K03N01', 'MH010', 2),
('CT000086','K03N01', 'MH014', 3),
('CT000087','K03N01', 'MH022', 3),
('CT000088','K03N01', 'MH023', 3),
('CT000089','K03N01', 'MH015', 4),
('CT000090','K03N01', 'MH024', 4),
('CT000091','K03N01', 'MH026', 5),
('CT000092','K03N01', 'MH027', 5),
('CT000093','K03N01', 'MH037', 6),
('CT000094','K03N01', 'MH038', 6),
('CT000095','K03N01', 'MH046', 6),
('CT000096','K03N01', 'MH041', 7),
('CT000097','K03N01', 'MH042', 7),
('CT000098','K03N01', 'MH043', 7),
('CT000099','K03N01', 'MH044', 7),
('CT000100','K03N01', 'MH049', 8),
('CT000101','K03N01', 'MH050', 8),
('CT000102','K04N01', 'MH004', 1),
('CT000103','K04N01', 'MH005', 1),
('CT000104','K04N01', 'MH009', 1),
('CT000105','K04N01', 'MH010', 2),
('CT000106','K04N01', 'MH011', 3),
('CT000107','K04N01', 'MH014', 3),
('CT000108','K04N01', 'MH024', 3),
('CT000109','K04N01', 'MH026', 4),
('CT000110','K04N01', 'MH027', 4),
('CT000111','K04N01', 'MH018', 5),
('CT000112','K04N01', 'MH037', 5),
('CT000113','K04N01', 'MH038', 5),
('CT000114','K04N01', 'MH032', 6),
('CT000115','K04N01', 'MH047', 6),
('CT000116','K04N01', 'MH048', 6),
('CT000117','K04N01', 'MH020', 7),
('CT000118','K04N01', 'MH035', 7),
('CT000119','K04N01', 'MH036', 7),
('CT000120','K04N01', 'MH021', 8);


INSERT INTO CT_NGANH(MaCT_Nganh, MaNH, MaMH, HocKy) VALUES
('CT000121','K05N01', 'MH010', 1),
('CT000122','K05N01', 'MH006', 1),
('CT000123','K05N01', 'MH007', 1),
('CT000124','K05N01', 'MH032', 2),
('CT000125','K05N01', 'MH028', 2),
('CT000126','K05N01', 'MH029', 3),
('CT000127','K05N01', 'MH014', 3),
('CT000128','K05N01', 'MH022', 4),
('CT000129','K05N01', 'MH023', 4),
('CT000130','K05N01', 'MH024', 4),
('CT000131','K05N01', 'MH008', 5),
('CT000132','K05N01', 'MH009', 5),
('CT000133','K05N01', 'MH015', 5),
('CT000134','K05N01', 'MH025', 6),
('CT000135','K05N01', 'MH026', 6),
('CT000136','K05N01', 'MH027', 7),
('CT000137','K05N01', 'MH002', 7),
('CT000138','K05N01', 'MH003', 7),
('CT000139','K05N01', 'MH016', 8),
('CT000140','K05N01', 'MH012', 8),
('CT000141','K05N02', 'MH011', 1),
('CT000142','K05N02', 'MH030', 1),
('CT000143','K05N02', 'MH031', 2),
('CT000144','K05N02', 'MH017', 2),
('CT000145','K05N02', 'MH005', 2),
('CT000146','K05N02', 'MH018', 3),
('CT000147','K05N02', 'MH001', 3),
('CT000148','K05N02', 'MH004', 3),
('CT000149','K05N02', 'MH013', 4),
('CT000150','K05N02', 'MH033', 4),
('CT000151','K05N02', 'MH034', 5),
('CT000152','K05N02', 'MH037', 5),
('CT000153','K05N02', 'MH038', 5),
('CT000154','K05N02', 'MH043', 6),
('CT000155','K05N02', 'MH044', 6),
('CT000156','K05N02', 'MH047', 7),
('CT000157','K05N02', 'MH048', 7),
('CT000158','K05N02', 'MH035', 8),
('CT000159','K05N02', 'MH036', 8),
('CT000160','K05N02', 'MH046', 8);


INSERT INTO CT_NGANH(MaCT_Nganh, MaNH, MaMH, HocKy) VALUES
('CT000161','K06N01', 'MH006', 1),
('CT000162','K06N01', 'MH007', 1),
('CT000163','K06N01', 'MH010', 1),
('CT000164','K06N01', 'MH008', 2),
('CT000165','K06N01', 'MH022', 2),
('CT000166','K06N01', 'MH023', 2),
('CT000167','K06N01', 'MH024', 2),
('CT000168','K06N01', 'MH009', 3),
('CT000169','K06N01', 'MH025', 3),
('CT000170','K06N01', 'MH026', 3),
('CT000171','K06N01', 'MH027', 3),
('CT000172','K06N01', 'MH028', 4),
('CT000173','K06N01', 'MH029', 4),
('CT000174','K06N01', 'MH030', 4),
('CT000175','K06N01', 'MH031', 4),
('CT000176','K06N01', 'MH001', 5),
('CT000177','K06N01', 'MH002', 5),
('CT000178','K06N01', 'MH037', 5),
('CT000179','K06N01', 'MH038', 5),
('CT000180','K06N01', 'MH003', 6),
('CT000181','K06N01', 'MH004', 6),
('CT000182','K06N01', 'MH005', 6),
('CT000183','K06N01', 'MH011', 7),
('CT000184','K06N01', 'MH012', 7),
('CT000185','K06N01', 'MH041', 7),
('CT000186','K06N01', 'MH042', 7),
('CT000187','K06N01', 'MH043', 8),
('CT000188','K06N01', 'MH044', 8),
('CT000189','K06N01', 'MH045', 8),
('CT000190','K06N02', 'MH006', 1),
('CT000191','K06N02', 'MH007', 1),
('CT000192','K06N02', 'MH010', 1),
('CT000193','K06N02', 'MH008', 2),
('CT000194','K06N02', 'MH022', 2),
('CT000195','K06N02', 'MH023', 2),
('CT000196','K06N02', 'MH024', 2),
('CT000197','K06N02', 'MH009', 3),
('CT000198','K06N02', 'MH025', 3),
('CT000199','K06N02', 'MH026', 3),
('CT000200','K06N02', 'MH027', 3),
('CT000201','K06N02', 'MH028', 4),
('CT000202','K06N02', 'MH029', 4),
('CT000203','K06N02', 'MH030', 4),
('CT000204','K06N02', 'MH031', 4),
('CT000205','K06N02', 'MH001', 5),
('CT000206','K06N02', 'MH002', 5),
('CT000207','K06N02', 'MH035', 5),
('CT000208','K06N02', 'MH036', 5),
('CT000209','K06N02', 'MH003', 6),
('CT000210','K06N02', 'MH004', 6),
('CT000211','K06N02', 'MH005', 6),
('CT000212','K06N02', 'MH011', 7),
('CT000213','K06N02', 'MH012', 7),
('CT000214','K06N02', 'MH041', 7),
('CT000215','K06N02', 'MH042', 7),
('CT000216','K06N02', 'MH046', 8),
('CT000217','K06N02', 'MH047', 8),
('CT000218','K06N02', 'MH048', 8);

--Table HOCKY_NAMHOC
SET DATEFORMAT DMY
INSERT INTO HOCKY_NAMHOC (MaHKNH, HocKy, NamHoc, ThoiHanDongHocPhi) VALUES ('2001', 1, 2020, '29-8-2020');
INSERT INTO HOCKY_NAMHOC (MaHKNH, HocKy, NamHoc, ThoiHanDongHocPhi) VALUES ('2002', 2, 2020, '19-2-2021');
INSERT INTO HOCKY_NAMHOC (MaHKNH, HocKy, NamHoc, ThoiHanDongHocPhi) VALUES ('2003', 3, 2020, '10-7-2021');
INSERT INTO HOCKY_NAMHOC (MaHKNH, HocKy, NamHoc, ThoiHanDongHocPhi) VALUES ('2101', 1, 2021, '21-8-2021');
INSERT INTO HOCKY_NAMHOC (MaHKNH, HocKy, NamHoc, ThoiHanDongHocPhi) VALUES ('2102', 2, 2021, '8-2-2022');
INSERT INTO HOCKY_NAMHOC (MaHKNH, HocKy, NamHoc, ThoiHanDongHocPhi) VALUES ('2103', 3, 2021, '12-7-2022');
INSERT INTO HOCKY_NAMHOC (MaHKNH, HocKy, NamHoc, ThoiHanDongHocPhi) VALUES ('2201', 1, 2022, '28-8-2022');
INSERT INTO HOCKY_NAMHOC (MaHKNH, HocKy, NamHoc, ThoiHanDongHocPhi) VALUES ('2202', 2, 2022, '12-2-2023');
INSERT INTO HOCKY_NAMHOC (MaHKNH, HocKy, NamHoc, ThoiHanDongHocPhi) VALUES ('2203', 3, 2022, '26-7-2023');
INSERT INTO HOCKY_NAMHOC (MaHKNH, HocKy, NamHoc, ThoiHanDongHocPhi) VALUES ('2301', 1, 2023, '7-9-2023');
INSERT INTO HOCKY_NAMHOC (MaHKNH, HocKy, NamHoc, ThoiHanDongHocPhi) VALUES ('2302', 2, 2023, '31-1-2024');
INSERT INTO HOCKY_NAMHOC (MaHKNH, HocKy, NamHoc, ThoiHanDongHocPhi) VALUES ('2303', 3, 2023, '3-7-2024');

--phieudkhp: 200
SET DATEFORMAT DMY
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000001', '1-8-2022', '21522146', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000002', '1-8-2022', '21522676', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000003', '1-8-2022', '21521062', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000004', '1-8-2022', '21520900', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000005', '1-8-2022', '21522315', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000006', '2-8-2022', '21521144', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000007', '2-8-2022', '21522884', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000008', '2-8-2022', '21522698', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000009', '3-8-2022', '21521846', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000010', '3-8-2022', '21521180', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000011', '3-8-2022', '21522544', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000012', '3-8-2022', '21521476', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000013', '3-8-2022', '21522712', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000014', '4-8-2022', '21522762', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000015', '4-8-2022', '21522536', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000016', '4-8-2022', '21522357', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000017', '5-8-2022', '21522276', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000018', '5-8-2022', '21522037', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000019', '5-8-2022', '21521029', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000020', '5-8-2022', '21522055', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000021', '11-1-2023', '21522145', '2202');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000022', '11-1-2023', '21522146', '2202');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000023', '11-1-2023', '21522676', '2202');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000024', '11-1-2023', '21521061', '2202');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000025', '12-1-2023', '21521144', '2202');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000026', '12-1-2023', '21521486', '2202');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000027', '12-1-2023', '21521804', '2202');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000028', '12-1-2023', '21521180', '2202');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000029', '12-1-2023', '21521226', '2202');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000030', '12-1-2023', '21521323', '2202');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000031', '13-1-2023', '21522747', '2202');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000032', '13-1-2023', '21522528', '2202');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000033', '13-1-2023', '21521476', '2202');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000034', '13-1-2023', '21522762', '2202');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000035', '13-1-2023', '21522885', '2202');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000036', '13-1-2023', '21521108', '2202');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000037', '13-1-2023', '21522276', '2202');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000038', '13-1-2023', '21522168', '2202');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000039', '14-1-2023', '21522037', '2202');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000040', '14-1-2023', '21521029', '2202');

INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000041','2-6-2023', '21521140', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000042','2-6-2023', '21521144', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000043','2-6-2023', '21520138', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000044','2-6-2023', '21520389', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000045','2-6-2023', '21521108', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000046','2-6-2023', '21522698', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000047','2-6-2023', '21522885', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000048','2-6-2023', '21521846', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000049','2-6-2023', '21521156', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000050','2-6-2023', '21521178', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000051','2-6-2023', '21521180', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000052','2-6-2023', '21521183', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000053','2-6-2023', '21521201', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000054','2-6-2023', '21521226', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000055','2-6-2023', '21521268', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000056','2-6-2023', '21521271', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000057','2-6-2023', '21521323', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000058','2-6-2023', '21522732', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000059','2-6-2023', '21522681', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000060','2-6-2023', '21522755', '2203');

INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000061','23-8-2023', '21520389', '2301');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000062','23-8-2023', '21522496', '2301');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000063','23-8-2023', '21522515', '2301');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000064','23-8-2023', '21522528', '2301');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000065','23-8-2023', '21522544', '2301');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000066','23-8-2023', '21522556', '2301');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000067','23-8-2023', '21521476', '2301');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000068','23-8-2023', '21522681', '2301');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000069','23-8-2023', '21522712', '2301');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000070','23-8-2023', '21522732', '2301');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000071','23-8-2023', '21522762', '2301');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000072','23-8-2023', '21522885', '2301');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000073','23-8-2023', '21522536', '2301');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000074','23-8-2023', '21522357', '2301');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000075','23-8-2023', '21521108', '2301');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000076','23-8-2023', '21522276', '2301');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000077','23-8-2023', '21522168', '2301');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000078','23-8-2023', '21522037', '2301');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000079','23-8-2023', '21521029', '2301');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000080','23-8-2023', '21522055', '2301');

INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000081','1-1-2024', '21520389', '2302');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000082','1-1-2024', '21522496', '2302');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000083','1-1-2024', '21522515', '2302');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000084','1-1-2024', '21522528', '2302');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000085','1-1-2024', '21522544', '2302');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000086','1-1-2024', '21522556', '2302');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000087','1-1-2024', '21521476', '2302');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000088','1-1-2024', '21522681', '2302');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000089','1-1-2024', '21522712', '2302');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000090','1-1-2024', '21522732', '2302');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000091','1-1-2024', '21522762', '2302');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000092','1-1-2024', '21522885', '2302');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000093','1-1-2024', '21522536', '2302');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000094','1-1-2024', '21522357', '2302');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000095','1-1-2024', '21521108', '2302');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000096','1-1-2024', '21522276', '2302');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000097','1-1-2024', '21522168', '2302');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000098','1-1-2024', '21522037', '2302');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000099','1-1-2024', '21521029', '2302');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000100','1-1-2024', '21522055', '2302');


--dsmonhoc_mo: 300
INSERT INTO DSMHMO (MaMo, MaHKNH, MaCT_Nganh) VALUES 
('MM000655', '2203', 'CT000001'),
('MM000656', '2203', 'CT000021'),
('MM000657', '2203', 'CT000042'),
('MM000658', '2203', 'CT000063'),
('MM000659', '2203', 'CT000102'),
('MM000660', '2203', 'CT000141');

--ct_dkhp: 1000
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000001', 'MM000457');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000001', 'MM000458');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000001', 'MM000459');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000001', 'MM000460');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000002', 'MM000458');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000002', 'MM000459');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000002', 'MM000460');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000002', 'MM000461');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000002', 'MM000462');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000002', 'MM000463');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000003', 'MM000477');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000003', 'MM000478');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000003', 'MM000479');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000003', 'MM000486');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000003', 'MM000487');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000004', 'MM000536');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000004', 'MM000537');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000004', 'MM000538');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000004', 'MM000539');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000004', 'MM000541');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000004', 'MM000542');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000005', 'MM000457');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000005', 'MM000459');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000005', 'MM000460');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000005', 'MM000461');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000006', 'MM000488');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000006', 'MM000490');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000006', 'MM000498');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000006', 'MM000499');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000007', 'MM000521');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000007', 'MM000522');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000007', 'MM000526');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000007', 'MM000527');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000007', 'MM000529');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000007', 'MM000532');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000008', 'MM000437');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000008', 'MM000438');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000008', 'MM000440');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000008', 'MM000443');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000008', 'MM000444');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000009', 'MM000447');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000009', 'MM000448');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000009', 'MM000449');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000009', 'MM000450');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000009', 'MM000453');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000009', 'MM000454');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000010', 'MM000467');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000010', 'MM000468');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000010', 'MM000469');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000010', 'MM000470');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000010', 'MM000472');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000010', 'MM000473');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000011', 'MM000437');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000011', 'MM000438');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000011', 'MM000439');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000012', 'MM000477');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000012', 'MM000479');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000012', 'MM000480');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000012', 'MM000481');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000013', 'MM000482');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000013', 'MM000483');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000013', 'MM000484');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000013', 'MM000485');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000014', 'MM000477');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000014', 'MM000478');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000014', 'MM000479');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000014', 'MM000480');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000014', 'MM000481');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000014', 'MM000486');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000014', 'MM000487');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000015', 'MM000488');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000015', 'MM000490');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000015', 'MM000491');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000015', 'MM000498');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000015', 'MM000499');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000016', 'MM000488');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000016', 'MM000489');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000016', 'MM000491');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000016', 'MM000495');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000016', 'MM000496');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000017', 'MM000521');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000017', 'MM000522');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000017', 'MM000523');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000018', 'MM000467');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000018', 'MM000468');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000018', 'MM000472');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000018', 'MM000473');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000019', 'MM000477');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000019', 'MM000478');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000019', 'MM000479');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000019', 'MM000484');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000019', 'MM000485');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000020', 'MM000521');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000020', 'MM000522');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000020', 'MM000530');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000020', 'MM000531');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000020', 'MM000532');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000020', 'MM000533');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000021', 'MM000574');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000021', 'MM000575');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000021', 'MM000577');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000021', 'MM000578');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000021', 'MM000580');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000021', 'MM000576');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000021', 'MM000573');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000022', 'MM000571');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000022', 'MM000572');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000022', 'MM000573');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000022', 'MM000576');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000023', 'MM000574');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000023', 'MM000575');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000023', 'MM000573');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000023', 'MM000576');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000023', 'MM000572');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000024', 'MM000595');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000024', 'MM000598');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000024', 'MM000599');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000024', 'MM000600');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000025', 'MM000601');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000025', 'MM000602');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000025', 'MM000603');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000025', 'MM000605');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000025', 'MM000606');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000026', 'MM000628');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000026', 'MM000629');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000026', 'MM000631');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000026', 'MM000632');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000026', 'MM000633');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000026', 'MM000634');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000027', 'MM000610');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000027', 'MM000611');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000027', 'MM000612');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000027', 'MM000613');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000027', 'MM000614');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000028', 'MM000584');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000028', 'MM000587');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000028', 'MM000588');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000028', 'MM000589');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000028', 'MM000590');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000029', 'MM000573');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000029', 'MM000574');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000029', 'MM000575');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000029', 'MM000576');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000030', 'MM000617');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000030', 'MM000619');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000030', 'MM000624');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000030', 'MM000625');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000030', 'MM000622');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000030', 'MM000623');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000031', 'MM000591');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000031', 'MM000592');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000031', 'MM000593');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000031', 'MM000595');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000032', 'MM000551');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000032', 'MM000552');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000032', 'MM000555');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000032', 'MM000556');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000032', 'MM000557');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000032', 'MM000558');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000033', 'MM000596');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000033', 'MM000597');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000033', 'MM000598');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000033', 'MM000599');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000033', 'MM000600');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000034', 'MM000591');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000034', 'MM000592');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000034', 'MM000593');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000034', 'MM000595');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000034', 'MM000598');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000035', 'MM000601');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000035', 'MM000602');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000035', 'MM000603');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000036', 'MM000572');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000036', 'MM000573');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000036', 'MM000574');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000036', 'MM000575');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000036', 'MM000576');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000036', 'MM000577');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000036', 'MM000578');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000037', 'MM000628');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000037', 'MM000629');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000037', 'MM000627');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000037', 'MM000630');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000038', 'MM000601');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000038', 'MM000602');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000038', 'MM000603');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000038', 'MM000604');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000038', 'MM000605');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000038', 'MM000606');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000039', 'MM000581');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000039', 'MM000582');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000039', 'MM000583');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000039', 'MM000584');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000039', 'MM000586');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000040', 'MM000591');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000040', 'MM000592');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000040', 'MM000593');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000040', 'MM000595');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000040', 'MM000598');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000041', 'MM000659');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000042', 'MM000659');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000043', 'MM000655');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000044', 'MM000655');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000045', 'MM000657');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000046', 'MM000655');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000047', 'MM000659');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000048', 'MM000656');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000049', 'MM000658');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000050', 'MM000659');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000051', 'MM000658');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000052', 'MM000659');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000053', 'MM000660');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000054', 'MM000657');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000055', 'MM000656');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000056', 'MM000656');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000057', 'MM000660');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000058', 'MM000658');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000059', 'MM000655');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000060', 'MM000659');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000061', 'MM000661');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000061', 'MM000662');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000061', 'MM000663');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000061', 'MM000664');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000061', 'MM000665');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000062', 'MM000713');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000062', 'MM000714');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000062', 'MM000722');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000062', 'MM000723');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000062', 'MM000715');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000063', 'MM000735');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000063', 'MM000736');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000063', 'MM000741');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000063', 'MM000742');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000063', 'MM000739');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000064', 'MM000661');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000064', 'MM000662');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000064', 'MM000663');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000064', 'MM000669');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000064', 'MM000670');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000065', 'MM000661');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000065', 'MM000662');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000065', 'MM000669');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000065', 'MM000670');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000065', 'MM000663');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000066', 'MM000669');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000066', 'MM000670');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000066', 'MM000661');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000066', 'MM000664');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000066', 'MM000665');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000067', 'MM000701');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000067', 'MM000702');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000067', 'MM000704');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000067', 'MM000705');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000067', 'MM000703');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000068', 'MM000662');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000068', 'MM000663');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000068', 'MM000665');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000068', 'MM000669');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000068', 'MM000670');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000069', 'MM000701');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000069', 'MM000704');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000069', 'MM000705');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000069', 'MM000706');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000069', 'MM000707');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000070', 'MM000691');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000070', 'MM000692');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000070', 'MM000695');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000070', 'MM000699');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000070', 'MM000700');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000071', 'MM000701');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000071', 'MM000704');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000071', 'MM000705');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000071', 'MM000710');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000071', 'MM000711');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000072', 'MM000712');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000072', 'MM000713');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000072', 'MM000714');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000072', 'MM000719');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000072', 'MM000720');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000073', 'MM000713');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000073', 'MM000714');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000073', 'MM000715');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000073', 'MM000722');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000073', 'MM000723');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000074', 'MM000713');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000074', 'MM000714');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000074', 'MM000715');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000074', 'MM000719');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000074', 'MM000720');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000075', 'MM000682');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000075', 'MM000683');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000075', 'MM000684');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000075', 'MM000686');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000075', 'MM000687');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000076', 'MM000745');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000076', 'MM000746');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000076', 'MM000747');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000076', 'MM000754');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000076', 'MM000755');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000077', 'MM000712');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000077', 'MM000713');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000077', 'MM000714');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000077', 'MM000722');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000077', 'MM000723');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000078', 'MM000691');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000078', 'MM000692');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000078', 'MM000693');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000078', 'MM000694');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000078', 'MM000698');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000079', 'MM000701');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000079', 'MM000702');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000079', 'MM000703');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000079', 'MM000706');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000079', 'MM000707');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000080', 'MM000745');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000080', 'MM000750');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000080', 'MM000751');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000080', 'MM000754');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000080', 'MM000755');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000081', 'MM000775');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000081', 'MM000776');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000081', 'MM000777');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000081', 'MM000778');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000081', 'MM000780');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000081', 'MM000781');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000081', 'MM000783');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000081', 'MM000784');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000082', 'MM000825');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000082', 'MM000826');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000082', 'MM000827');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000082', 'MM000831');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000083', 'MM000841');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000083', 'MM000843');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000083', 'MM000848');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000083', 'MM000849');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000083', 'MM000850');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000084', 'MM000775);
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000084', 'MM000777');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000084', 'MM000778');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000084', 'MM000781');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000084', 'MM000782');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000085', 'MM000775');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000085', 'MM000779');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000085', 'MM000780');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000085', 'MM000781');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000086', 'MM000777');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000086', 'MM000778');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000086', 'MM000780');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000086', 'MM000783');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000086', 'MM000784');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000087', 'MM000815');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000087', 'MM000817');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000087', 'MM000820');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000087', 'MM000821');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000088', 'MM000777');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000088', 'MM000778');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000088', 'MM000780');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000088', 'MM000782');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000089', 'MM000817');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000089', 'MM000820');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000089', 'MM000821');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000089', 'MM000822');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000090', 'MM000806');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000090', 'MM000807');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000090', 'MM000810');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000090', 'MM000812');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000090', 'MM000813');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000091', 'MM000816');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000091', 'MM000818');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000091', 'MM000819');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000091', 'MM000823');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000091', 'MM000824');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000092', 'MM000826');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000092', 'MM000827');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000092', 'MM000829');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000092', 'MM000830');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000093', 'MM000825');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000093', 'MM000826');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000093', 'MM000827');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000093', 'MM000828');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000094', 'MM000825');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000094', 'MM000826');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000094', 'MM000827');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000094', 'MM000828');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000094', 'MM000831');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000095', 'MM000855');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000095', 'MM000856');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000095', 'MM000857');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000095', 'MM000858');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000095', 'MM000860');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000095', 'MM000861');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000096', 'MM000851');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000096', 'MM000852');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000096', 'MM000853');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000096', 'MM000857');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000096', 'MM000858');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000097', 'MM000825');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000097', 'MM000826');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000097', 'MM000827');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000097', 'MM000829');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000097', 'MM000830');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000098', 'MM000805');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000098', 'MM000806');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000098', 'MM000811');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000098', 'MM000812');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000098', 'MM000813');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000099', 'MM000815');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000099', 'MM000816');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000099', 'MM000820');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000099', 'MM000821');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000099', 'MM000822');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000100', 'MM000857');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000100', 'MM000858');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000100', 'MM000862');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000100', 'MM000863');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000100', 'MM000864');
go

--phieuthu: 400
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000001', 253000, '5-8-2022', 'DK000001');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000002', 225000, '3-8-2022', 'DK000002');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000003', 200000, '10-8-2022', 'DK000002');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000004', 496000, '22-8-2022', 'DK000004');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000005', 113000, '27-8-2022', 'DK000005');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000006', 253000, '2-8-2022', 'DK000006');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000007', 200000, '16-8-2022', 'DK000007');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000008', 242000, '19-8-2022', 'DK000007');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000009', 405000, '5-8-2022', 'DK000008');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000010', 213000, '7-8-2022', 'DK000009');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000011', 300000, '10-8-2022', 'DK000009');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000012', 300000, '11-8-2022', 'DK000010');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000013', 297000, '25-8-2022', 'DK000011');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000014', 280000, '15-8-2022', 'DK000012');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000015', 479000, '20-8-2022', 'DK000014');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000016', 307000, '13-8-2022', 'DK000015');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000017', 280000, '17-8-2022', 'DK000016');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000018', 297000, '6-8-2022', 'DK000017');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000019', 361000, '11-8-2022', 'DK000019');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000020', 415000, '17-8-2022', 'DK000020');

INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000021', 200000, '14-1-2023', 'DK000021');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000022', 200000, '21-1-2023', 'DK000021');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000023', 106000, '11-2-2023', 'DK000021');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000024', 351000, '16-1-2023', 'DK000022');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000025', 200000, '11-1-2023', 'DK000023');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000026', 188000, '28-1-2023', 'DK000023');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000027', 100000, '31-1-2023', 'DK000024');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000028', 100000, '6-2-2023', 'DK000024');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000029', 80000, '11-2-2023', 'DK000024');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000030', 300000, '15-1-2023', 'DK000025');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000031', 100000, '12-1-2023', 'DK000026');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000032', 100000, '27-1-2023', 'DK000026');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000033', 320000, '2-2-2023', 'DK000027');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000034', 200000, '24-1-2023', 'DK000028');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000035', 100000, '30-1-2023', 'DK000028');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000036', 61000, '6-2-2023', 'DK000028');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000037', 200000, '22-1-2023', 'DK000029');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000038', 107000, '5-2-2023', 'DK000029');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000039', 300000, '13-1-2023', 'DK000030');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000040', 27000, '28-1-2023', 'DK000030');

INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000041', 50000, '18-6-2023', 'DK000041');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000042', 4000, '28-6-2023', 'DK000041');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000043', 4000, '21-6-2023', 'DK000042');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000044', 50000, '25-6-2023', 'DK000042');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000045', 100000, '5-6-2023', 'DK000043');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000046', 8000, '7-6-2023', 'DK000043');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000047', 58000, '9-6-2023', 'DK000044');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000048', 50000, '15-6-2023', 'DK000044');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000049', 50000, '16-6-2023', 'DK000045');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000050', 58000, '17-6-2023', 'DK000045');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000051', 48000, '15-6-2023', 'DK000046');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000052', 60000, '16-6-2023', 'DK000046');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000053', 30000, '17-6-2023', 'DK000047');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000054', 7800, '21-6-2023', 'DK000047');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000055', 100000, '10-6-2023', 'DK000048');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000056', 8000, '11-6-2023', 'DK000048');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000057', 30000, '12-6-2023', 'DK000049');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000058', 20000, '19-6-2023', 'DK000049');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000059', 5000, '14-6-2023', 'DK000050');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000060', 5800, '17-6-2023', 'DK000050');

INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000061', 200000, '25-8-2023', 'DK000061');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000062', 286000, '5-9-2023', 'DK000061');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000063', 100000, '27-8-2023', 'DK000062');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000064', 207000, '1-9-2023', 'DK000062');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000065', 214900, '26-8-2023', 'DK000063');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000066', 200000, '25-8-2023', 'DK000066');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000067', 215000, '30-8-2023', 'DK000066');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000068', 200000, '25-8-2023', 'DK000067');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000069', 161000, '26-8-2023', 'DK000067');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000070', 388000, '27-8-2023', 'DK000068');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000071', 150000, '2-9-2023', 'DK000069');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000072', 140000, '7-9-2023', 'DK000069');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000073', 288000, '25-8-2023', 'DK000070');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000074', 200000, '25-8-2023', 'DK000071');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000075', 90000, '29-8-2023', 'DK000071');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000076', 100000, '25-8-2023', 'DK000073');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000077', 100000, '28-8-2023', 'DK000073');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000078', 107000, '3-9-2023', 'DK000073');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000079', 307000, '6-9-2023', 'DK000074');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000080', 100000, '24-8-2023', 'DK000076');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000081', 100000, '30-8-2023', 'DK000076');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000082', 215000, '6-9-2023', 'DK000076');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000083', 307000, '5-9-2023', 'DK000077');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000084', 200000, '27-8-2023', 'DK000078');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000085', 188000, '6-9-2023', 'DK000078');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000086', 301000, '24-8-2023', 'DK000079');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000087', 60000, '5-9-2023', 'DK000079');

INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000088', 300000, '11-1-2024', 'DK000081');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000089', 233000, '20-1-2024', 'DK000081');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000090', 203000, '16-1-2024', 'DK000083');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000091', 334000, '5-1-2024', 'DK000084');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000092', 200000, '2-1-2024', 'DK000086');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000093', 90000, '26-1-2024', 'DK000086');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000094', 334000, '18-1-2024', 'DK000087');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000095', 226000, '5-1-2024', 'DK000088');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000096', 307000, '22-1-2024', 'DK000089');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000097', 334000, '30-1-2024', 'DK000090');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000098', 388000, '24-1-2024', 'DK000091');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000099', 165200, '19-1-2024', 'DK000092');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000100', 253000, '3-1-2024', 'DK000093');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000101', 334000, '4-1-2024', 'DK000094');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000102', 344000, '18-1-2024', 'DK000095');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000103', 100000, '15-1-2024', 'DK000096');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000104', 100000, '21-1-2024', 'DK000096');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000105', 361000, '17-1-2024', 'DK000098');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000106', 200000, '8-1-2024', 'DK000100');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000107', 117000, '13-1-2024', 'DK000100');
go

