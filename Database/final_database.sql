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
    MaNH VARCHAR(6) NOT NULL,
    MaMH VARCHAR(5) NOT NULL,
    HocKy INT,
    GhiChu NVARCHAR(50),
    PRIMARY KEY (MaNH, MaMH),
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
    MaMH VARCHAR(5) NOT NULL,
    FOREIGN KEY (MaHKNH) REFERENCES HOCKY_NAMHOC(MaHKNH),
    FOREIGN KEY (MaMH) REFERENCES MONHOC(MaMH)
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
INSERT INTO CT_NGANH(MaNH, MaMH, HocKy) VALUES
('K01N01','MH001',6),
('K01N01','MH003',4),
('K01N01','MH004',5),
('K01N01','MH005',5),
('K01N01','MH006',1),
('K01N01','MH007',1),
('K01N01','MH008',2),
('K01N01','MH009',2),
('K01N01','MH010',1),
('K01N01','MH011',4),
('K01N01','MH012',6),
('K01N01','MH014',1),
('K01N01','MH022',2),
('K01N01','MH023',2),
('K01N01','MH026',3),
('K01N01','MH025',3),
('K01N01','MH047',7),
('K01N01','MH048',7),
('K01N01','MH049',8),
('K01N01','MH050',8),

('K01N02','MH001',6),
('K01N02','MH003',4),
('K01N02','MH004',5),
('K01N02','MH005',5),
('K01N02','MH006',1),
('K01N02','MH007',1),
('K01N02','MH008',2),
('K01N02','MH009',2),
('K01N02','MH010',1),
('K01N02','MH011',4),
('K01N02','MH012',6),
('K01N02','MH014',1),
('K01N02','MH022',2),
('K01N02','MH023',2),
('K01N02','MH026',3),
('K01N02','MH025',3),
('K01N02','MH045',8),
('K01N02','MH046',8),
('K01N02','MH049',7),
('K01N02','MH050',7);

INSERT INTO CT_NGANH (MaNH, MaMH, HocKy) VALUES 
('K02N02', 'MH007', 1),
('K02N02', 'MH006', 1),
('K02N02', 'MH005', 2),
('K02N02', 'MH008', 2),
('K02N02', 'MH009', 2),
('K02N02', 'MH022', 3),
('K02N02', 'MH023', 3),
('K02N02', 'MH024', 3),
('K02N02', 'MH025', 4),
('K02N02', 'MH031', 4),
('K02N02', 'MH032', 4),
('K02N02', 'MH035', 5),
('K02N02', 'MH036', 5),
('K02N02', 'MH045', 5),
('K02N02', 'MH046', 6),
('K02N02', 'MH047', 6),
('K02N02', 'MH048', 6),
('K02N02', 'MH041', 7),
('K02N02', 'MH042', 7),
('K02N02', 'MH049', 8);

INSERT INTO CT_NGANH (MaNH, MaMH, HocKy) VALUES 
('K03N01', 'MH001', 1),
('K03N01', 'MH002', 1),
('K03N01', 'MH006', 2),
('K03N01', 'MH007', 2),
('K03N01', 'MH010', 2),
('K03N01', 'MH014', 3),
('K03N01', 'MH022', 3),
('K03N01', 'MH023', 3),
('K03N01', 'MH015', 4),
('K03N01', 'MH024', 4),
('K03N01', 'MH026', 5),
('K03N01', 'MH027', 5),
('K03N01', 'MH037', 6),
('K03N01', 'MH038', 6),
('K03N01', 'MH046', 6),
('K03N01', 'MH041', 7),
('K03N01', 'MH042', 7),
('K03N01', 'MH043', 7),
('K03N01', 'MH044', 7),
('K03N01', 'MH049', 8),
('K03N01', 'MH050', 8),
('K04N01', 'MH004', 1),
('K04N01', 'MH005', 1),
('K04N01', 'MH009', 1),
('K04N01', 'MH010', 2),
('K04N01', 'MH011', 3),
('K04N01', 'MH014', 3),
('K04N01', 'MH024', 3),
('K04N01', 'MH026', 4),
('K04N01', 'MH027', 4),
('K04N01', 'MH018', 5),
('K04N01', 'MH037', 5),
('K04N01', 'MH038', 5),
('K04N01', 'MH032', 6),
('K04N01', 'MH047', 6),
('K04N01', 'MH048', 6),
('K04N01', 'MH020', 7),
('K04N01', 'MH035', 7),
('K04N01', 'MH036', 7),
('K04N01', 'MH021', 8);

INSERT INTO CT_NGANH (MaNH, MaMH, HocKy) VALUES
('K05N01', 'MH010', 1),
('K05N01', 'MH006', 1),
('K05N01', 'MH007', 1),
('K05N01', 'MH032', 2),
('K05N01', 'MH028', 2),
('K05N01', 'MH029', 3),
('K05N01', 'MH014', 3),
('K05N01', 'MH022', 4),
('K05N01', 'MH023', 4),
('K05N01', 'MH024', 4),
('K05N01', 'MH008', 5),
('K05N01', 'MH009', 5),
('K05N01', 'MH015', 5),
('K05N01', 'MH025', 6),
('K05N01', 'MH026', 6),
('K05N01', 'MH027', 7),
('K05N01', 'MH002', 7),
('K05N01', 'MH003', 7),
('K05N01', 'MH016', 8),
('K05N01', 'MH012', 8),
('K05N02', 'MH011', 1),
('K05N02', 'MH030', 1),
('K05N02', 'MH031', 2),
('K05N02', 'MH017', 2),
('K05N02', 'MH005', 2),
('K05N02', 'MH018', 3),
('K05N02', 'MH001', 3),
('K05N02', 'MH004', 3),
('K05N02', 'MH013', 4),
('K05N02', 'MH033', 4),
('K05N02', 'MH034', 5),
('K05N02', 'MH037', 5),
('K05N02', 'MH038', 5),
('K05N02', 'MH043', 6),
('K05N02', 'MH044', 6),
('K05N02', 'MH047', 7),
('K05N02', 'MH048', 7),
('K05N02', 'MH035', 8),
('K05N02', 'MH036', 8),
('K05N02', 'MH046', 8);

INSERT INTO CT_NGANH(MaNH, MaMH, HocKy) VALUES
('K06N01', 'MH001', 5),
('K06N01', 'MH002', 5),
('K06N01', 'MH003', 6),
('K06N01', 'MH004', 6),
('K06N01', 'MH005', 6),
('K06N01', 'MH006', 1),
('K06N01', 'MH007', 1),
('K06N01', 'MH008', 2),
('K06N01', 'MH009', 3),
('K06N01', 'MH010', 1),
('K06N01', 'MH011', 7),
('K06N01', 'MH012', 7),
('K06N01', 'MH022', 2),
('K06N01', 'MH023', 2),
('K06N01', 'MH024', 2),
('K06N01', 'MH025', 3),
('K06N01', 'MH026', 3),
('K06N01', 'MH027', 3),
('K06N01', 'MH028', 4),
('K06N01', 'MH029', 4),
('K06N01', 'MH030', 4),
('K06N01', 'MH031', 4),
('K06N01', 'MH037', 5),
('K06N01', 'MH038', 5),
('K06N01', 'MH041', 7),
('K06N01', 'MH042', 7),
('K06N01', 'MH043', 8),
('K06N01', 'MH044', 8),
('K06N01', 'MH045', 8),
('K06N02', 'MH001', 5),
('K06N02', 'MH002', 5),
('K06N02', 'MH003', 6),
('K06N02', 'MH004', 6),
('K06N02', 'MH005', 6),
('K06N02', 'MH006', 1),
('K06N02', 'MH007', 1),
('K06N02', 'MH008', 2),
('K06N02', 'MH009', 3),
('K06N02', 'MH010', 1),
('K06N02', 'MH011', 7),
('K06N02', 'MH012', 7),
('K06N02', 'MH022', 2),
('K06N02', 'MH023', 2),
('K06N02', 'MH024', 2),
('K06N02', 'MH025', 3),
('K06N02', 'MH026', 3),
('K06N02', 'MH027', 3),
('K06N02', 'MH028', 4),
('K06N02', 'MH029', 4),
('K06N02', 'MH030', 4),
('K06N02', 'MH031', 4),
('K06N02', 'MH035', 5),
('K06N02', 'MH036', 5),
('K06N02', 'MH041', 7),
('K06N02', 'MH042', 7),
('K06N02', 'MH046', 8),
('K06N02', 'MH047', 8),
('K06N02', 'MH048', 8);

--Table HOCKY_NAMHOC
SET DATEFORMAT DMY
INSERT INTO HOCKY_NAMHOC (MaHKNH, HocKy, NamHoc, ThoiHanDongHocPhi) VALUES
('2001', 1, 2020, '29-8-2020'),
('2002', 2, 2020, '19-2-2021'),
('2003', 3, 2020, '10-7-2021'),
('2101', 1, 2021, '21-8-2021'),
('2102', 2, 2021, '8-2-2022'),
('2103', 3, 2021, '12-7-2022'),
('2201', 1, 2022, '28-8-2022'),
('2202', 2, 2022, '12-2-2023'),
('2203', 3, 2022, '26-7-2023'),
('2301', 1, 2023, '7-9-2023'),
('2302', 2, 2023, '31-1-2024'),
('2303', 3, 2023, '3-7-2024');

--phieudkhp: 200
SET DATEFORMAT DMY
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000001', '29-7-2020', '21522145', '2001');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000002', '29-7-2020', '21522146', '2001');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000003', '29-7-2020', '21522141', '2001');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000004', '29-7-2020', '21522676', '2001');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000005', '29-7-2020', '21521667', '2001');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000006', '29-7-2020', '21521062', '2001');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000007', '29-7-2020', '21521061', '2001');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000008', '29-7-2020', '21520138', '2001');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000009', '29-7-2020', '21520900', '2001');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000010', '29-7-2020', '21522315', '2001');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000011', '29-7-2020', '21521140', '2001');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000012', '29-7-2020', '21521144', '2001');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000013', '29-7-2020', '21521174', '2001');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000014', '29-7-2020', '21522884', '2001');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000015', '29-7-2020', '21521486', '2001');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000016', '29-7-2020', '21522698', '2001');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000017', '29-7-2020', '21521804', '2001');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000018', '29-7-2020', '21521846', '2001');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000019', '29-7-2020', '21521156', '2001');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000020', '29-7-2020', '21521178', '2001');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000021', '19-1-2021', '21522145', '2002');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000022', '19-1-2021', '21522146', '2002');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000023', '19-1-2021', '21522141', '2002');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000024', '19-1-2021', '21522676', '2002');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000025', '19-1-2021', '21521667', '2002');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000026', '19-1-2021', '21521062', '2002');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000027', '19-1-2021', '21521061', '2002');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000028', '19-1-2021', '21520138', '2002');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000029', '19-1-2021', '21520900', '2002');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000030', '19-1-2021', '21522315', '2002');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000031', '19-1-2021', '21521140', '2002');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000032', '19-1-2021', '21521144', '2002');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000033', '19-1-2021', '21521174', '2002');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000034', '19-1-2021', '21522884', '2002');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000035', '19-1-2021', '21521486', '2002');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000036', '19-1-2021', '21522698', '2002');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000037', '19-1-2021', '21521804', '2002');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000038', '19-1-2021', '21521846', '2002');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000039', '19-1-2021', '21521156', '2002');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000040', '19-1-2021', '21521178', '2002');

INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000041', '28-7-2021', '21522146', '2101');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000042', '28-7-2021', '21522676', '2101');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000043', '28-7-2021', '21521062', '2101');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000044', '28-7-2021', '21520900', '2101');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000045', '28-7-2021', '21522315', '2101');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000046', '29-7-2021', '21521144', '2101');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000047', '29-7-2021', '21522884', '2101');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000048', '29-7-2021', '21522698', '2101');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000049', '30-7-2021', '21521846', '2101');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000050', '30-7-2021', '21521180', '2101');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000051', '30-7-2021', '21522544', '2101');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000052', '30-7-2021', '21521476', '2101');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000053', '30-7-2021', '21522712', '2101');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000054', '31-7-2021', '21522762', '2101');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000055', '31-7-2021', '21522536', '2101');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000056', '31-7-2021', '21522357', '2101');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000057', '1-8-2021', '21522276', '2101');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000058', '1-8-2021', '21522037', '2101');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000059', '1-8-2021', '21521029', '2101');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000060', '1-8-2021', '21522055', '2101');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000061', '9-1-2022', '21522145', '2102');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000062', '9-1-2022', '21522146', '2102');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000063', '9-1-2022', '21522676', '2102');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000064', '9-1-2022', '21521061', '2102');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000065', '10-1-2022', '21521144', '2102');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000066', '10-1-2022', '21521486', '2102');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000067', '10-1-2022', '21521804', '2102');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000068', '10-1-2022', '21521180', '2102');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000069', '10-1-2022', '21521226', '2102');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000070', '10-1-2022', '21521323', '2102');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000071', '11-1-2022', '21522747', '2102');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000072', '11-1-2022', '21522528', '2102');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000073', '11-1-2022', '21521476', '2102');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000074', '11-1-2022', '21522762', '2102');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000075', '11-1-2022', '21522885', '2102');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000076', '11-1-2022', '21521108', '2102');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000077', '11-1-2022', '21522276', '2102');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000078', '11-1-2022', '21522168', '2102');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000079', '12-1-2022', '21522037', '2102');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000080', '12-1-2022', '21521029', '2102');

INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000081', '1-8-2022', '21522146', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000082', '1-8-2022', '21522676', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000083', '1-8-2022', '21521062', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000084', '1-8-2022', '21520900', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000085', '1-8-2022', '21522315', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000086', '2-8-2022', '21521144', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000087', '2-8-2022', '21522884', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000088', '2-8-2022', '21522698', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000089', '3-8-2022', '21521846', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000090', '3-8-2022', '21521180', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000091', '3-8-2022', '21522544', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000092', '3-8-2022', '21521476', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000093', '3-8-2022', '21522712', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000094', '4-8-2022', '21522762', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000095', '4-8-2022', '21522536', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000096', '4-8-2022', '21522357', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000097', '5-8-2022', '21522276', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000098', '5-8-2022', '21522037', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000099', '5-8-2022', '21521029', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000100', '5-8-2022', '21522055', '2201');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000101', '11-1-2023', '21522145', '2202');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000102', '11-1-2023', '21522146', '2202');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000103', '11-1-2023', '21522676', '2202');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000104', '11-1-2023', '21521061', '2202');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000105', '12-1-2023', '21521144', '2202');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000106', '12-1-2023', '21521486', '2202');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000107', '12-1-2023', '21521804', '2202');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000108', '12-1-2023', '21521180', '2202');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000109', '12-1-2023', '21521226', '2202');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000110', '12-1-2023', '21521323', '2202');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000111', '13-1-2023', '21522747', '2202');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000112', '13-1-2023', '21522528', '2202');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000113', '13-1-2023', '21521476', '2202');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000114', '13-1-2023', '21522762', '2202');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000115', '13-1-2023', '21522885', '2202');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000116', '13-1-2023', '21521108', '2202');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000117', '13-1-2023', '21522276', '2202');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000118', '13-1-2023', '21522168', '2202');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000119', '14-1-2023', '21522037', '2202');
INSERT INTO PHIEUDKHP (MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000120', '14-1-2023', '21521029', '2202');

INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000121','2-6-2023', '21521140', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000122','2-6-2023', '21521144', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000123','2-6-2023', '21521174', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000124','2-6-2023', '21522884', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000125','2-6-2023', '21521486', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000126','2-6-2023', '21522698', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000127','2-6-2023', '21521804', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000128','2-6-2023', '21521846', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000129','2-6-2023', '21521156', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000130','2-6-2023', '21521178', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000131','2-6-2023', '21521180', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000132','2-6-2023', '21521183', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000133','2-6-2023', '21521201', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000134','2-6-2023', '21521226', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000135','2-6-2023', '21521268', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000136','2-6-2023', '21521271', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000137','2-6-2023', '21521323', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000138','2-6-2023', '21521595', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000139','2-6-2023', '21522747', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000140','2-6-2023', '21522755', '2203');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000141','23-8-2023', '21520389', '2301');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000142','23-8-2023', '21522496', '2301');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000143','23-8-2023', '21522515', '2301');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000144','23-8-2023', '21522528', '2301');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000145','23-8-2023', '21522544', '2301');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000146','23-8-2023', '21522556', '2301');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000147','23-8-2023', '21521476', '2301');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000148','23-8-2023', '21522681', '2301');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000149','23-8-2023', '21522712', '2301');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000150','23-8-2023', '21522732', '2301');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000151','23-8-2023', '21522762', '2301');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000152','23-8-2023', '21522885', '2301');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000153','23-8-2023', '21522536', '2301');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000154','23-8-2023', '21522357', '2301');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000155','23-8-2023', '21521108', '2301');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000156','23-8-2023', '21522276', '2301');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000157','23-8-2023', '21522168', '2301');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000158','23-8-2023', '21522037', '2301');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000159','23-8-2023', '21521029', '2301');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000160','23-8-2023', '21522055', '2301');

INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000161','1-1-2024', '21520389', '2302');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000162','1-1-2024', '21522496', '2302');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000163','1-1-2024', '21522515', '2302');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000164','1-1-2024', '21522528', '2302');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000165','1-1-2024', '21522544', '2302');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000166','1-1-2024', '21522556', '2302');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000167','1-1-2024', '21521476', '2302');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000168','1-1-2024', '21522681', '2302');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000169','1-1-2024', '21522712', '2302');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000170','1-1-2024', '21522732', '2302');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000171','1-1-2024', '21522762', '2302');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000172','1-1-2024', '21522885', '2302');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000173','1-1-2024', '21522536', '2302');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000174','1-1-2024', '21522357', '2302');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000175','1-1-2024', '21521108', '2302');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000176','1-1-2024', '21522276', '2302');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000177','1-1-2024', '21522168', '2302');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000178','1-1-2024', '21522037', '2302');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000179','1-1-2024', '21521029', '2302');
INSERT INTO PHIEUDKHP(MaPhieuDKHP, NgayLap, MSSV, MaHKNH) VALUES ('DK000180','1-1-2024', '21522055', '2302');

--dsmonhoc_mo: 300
INSERT INTO DSMHMO(MaMo, MaHKNH, MaMH) VALUES
('MM000001', '2001', 'MH001'),
('MM000002', '2001', 'MH002'),
('MM000003', '2001', 'MH003'),
('MM000004', '2001', 'MH004'),
('MM000005', '2001', 'MH005'),
('MM000006', '2001', 'MH006'),
('MM000007', '2001', 'MH007'),
('MM000008', '2001', 'MH008'),
('MM000009', '2001', 'MH009'),
('MM000010', '2001', 'MH010'),
('MM000011', '2001', 'MH011'),
('MM000012', '2001', 'MH012'),
('MM000013', '2001', 'MH013'),
('MM000014', '2001', 'MH014'),
('MM000015', '2001', 'MH015'),
('MM000016', '2001', 'MH016'),
('MM000017', '2001', 'MH017'),
('MM000018', '2001', 'MH018'),
('MM000019', '2001', 'MH022'),
('MM000020', '2001', 'MH023'),
('MM000021', '2001', 'MH024'),
('MM000022', '2001', 'MH026'),
('MM000023', '2001', 'MH027'),
('MM000024', '2001', 'MH028'),
('MM000025', '2001', 'MH029'),
('MM000026', '2001', 'MH030'),
('MM000027', '2001', 'MH031'),
('MM000028', '2001', 'MH032'),
('MM000029', '2001', 'MH033'),
('MM000030', '2001', 'MH034'),
('MM000031', '2002', 'MH001'),
('MM000032', '2002', 'MH002'),
('MM000033', '2002', 'MH003'),
('MM000034', '2002', 'MH004'),
('MM000035', '2002', 'MH005'),
('MM000036', '2002', 'MH006'),
('MM000037', '2002', 'MH007'),
('MM000038', '2002', 'MH008'),
('MM000039', '2002', 'MH009'),
('MM000040', '2002', 'MH010'),
('MM000041', '2002', 'MH011'),
('MM000042', '2002', 'MH012'),
('MM000043', '2002', 'MH013'),
('MM000044', '2002', 'MH014'),
('MM000045', '2002', 'MH015'),
('MM000046', '2002', 'MH016'),
('MM000047', '2002', 'MH017'),
('MM000048', '2002', 'MH018'),
('MM000049', '2002', 'MH033'),
('MM000050', '2002', 'MH034'),
('MM000051', '2002', 'MH035'),
('MM000052', '2002', 'MH036'),
('MM000053', '2002', 'MH037'),
('MM000054', '2002', 'MH038'),
('MM000055', '2002', 'MH039'),
('MM000056', '2002', 'MH040'),
('MM000057', '2002', 'MH041'),
('MM000058', '2002', 'MH042'),
('MM000059', '2002', 'MH045'),
('MM000060', '2002', 'MH046');

INSERT INTO DSMHMO (MaMo, MaHKNH, MaMH) VALUES 
('MM000061', '2101', 'MH002'),
('MM000062', '2101', 'MH006'),
('MM000063', '2101', 'MH007'),
('MM000064', '2101', 'MH010'),
('MM000065', '2101', 'MH011'),
('MM000066', '2101', 'MH013'),
('MM000067', '2101', 'MH015'),
('MM000068', '2101', 'MH022'),
('MM000069', '2101', 'MH023'),
('MM000070', '2101', 'MH025'),
('MM000071', '2101', 'MH026'),
('MM000072', '2101', 'MH027'),
('MM000073', '2101', 'MH032'),
('MM000074', '2101', 'MH033'),
('MM000075', '2101', 'MH034'),
('MM000076', '2101', 'MH035'),
('MM000077', '2101', 'MH036'),
('MM000078', '2101', 'MH037'),
('MM000079', '2101', 'MH038'),
('MM000080', '2101', 'MH039'),
('MM000081', '2101', 'MH040'),
('MM000082', '2101', 'MH041'),
('MM000083', '2101', 'MH042'),
('MM000084', '2101', 'MH043'),
('MM000085', '2101', 'MH044'),
('MM000086', '2101', 'MH045'),
('MM000087', '2101', 'MH046'),
('MM000088', '2101', 'MH047'),
('MM000089', '2101', 'MH048'),
('MM000090', '2101', 'MH049'),
('MM000091', '2101', 'MH050'),
('MM000092', '2102', 'MH004'),
('MM000093', '2102', 'MH005'),
('MM000094', '2102', 'MH008'),
('MM000095', '2102', 'MH009'),
('MM000096', '2102', 'MH010'),
('MM000097', '2102', 'MH011'),
('MM000098', '2102', 'MH012'),
('MM000099', '2102', 'MH013'),
('MM000100', '2102', 'MH016'),
('MM000101', '2102', 'MH018'),
('MM000102', '2102', 'MH022'),
('MM000103', '2102', 'MH023'),
('MM000104', '2102', 'MH024'),
('MM000105', '2102', 'MH025'),
('MM000106', '2102', 'MH026'),
('MM000107', '2102', 'MH027'),
('MM000108', '2102', 'MH028'),
('MM000109', '2102', 'MH029'),
('MM000110', '2102', 'MH030'),
('MM000111', '2102', 'MH031'),
('MM000112', '2102', 'MH032'),
('MM000113', '2102', 'MH033'),
('MM000114', '2102', 'MH034'),
('MM000115', '2102', 'MH035'),
('MM000116', '2102', 'MH036'),
('MM000117', '2102', 'MH037'),
('MM000118', '2102', 'MH038'),
('MM000119', '2102', 'MH039'),
('MM000120', '2102', 'MH040');

INSERT INTO DSMHMO (MaMo, MaHKNH, MaMH) VALUES 
('MM000121', '2201', 'MH001'),
('MM000122', '2201', 'MH017'),
('MM000123', '2201', 'MH013'),
('MM000124', '2201', 'MH039'),
('MM000125', '2201', 'MH040'),
('MM000126', '2201', 'MH022'),
('MM000127', '2201', 'MH023'),
('MM000128', '2201', 'MH032'),
('MM000129', '2201', 'MH033'),
('MM000130', '2201', 'MH004'),
('MM000131', '2201', 'MH016'),
('MM000132', '2201', 'MH024'),
('MM000133', '2201', 'MH028'),
('MM000134', '2201', 'MH029'),
('MM000135', '2201', 'MH011'),
('MM000136', '2201', 'MH035'),
('MM000137', '2201', 'MH036'),
('MM000138', '2201', 'MH046'),
('MM000139', '2201', 'MH047'),
('MM000140', '2201', 'MH048'),
('MM000141', '2201', 'MH002'),
('MM000142', '2201', 'MH006'),
('MM000143', '2201', 'MH012'),
('MM000144', '2201', 'MH026'),
('MM000145', '2201', 'MH027'),
('MM000146', '2201', 'MH049'),
('MM000147', '2201', 'MH050'),
('MM000148', '2201', 'MH041'),
('MM000149', '2201', 'MH042'),
('MM000150', '2201', 'MH037'),
('MM000151', '2201', 'MH038'),
('MM000152', '2202', 'MH002'),
('MM000153', '2202', 'MH003'),
('MM000154', '2202', 'MH005'),
('MM000155', '2202', 'MH006'),
('MM000156', '2202', 'MH008'),
('MM000157', '2202', 'MH009'),
('MM000158', '2202', 'MH011'),
('MM000159', '2202', 'MH013'),
('MM000160', '2202', 'MH015'),
('MM000161', '2202', 'MH016'),
('MM000162', '2202', 'MH017'),
('MM000163', '2202', 'MH018'),
('MM000164', '2202', 'MH020'),
('MM000165', '2202', 'MH021'),
('MM000166', '2202', 'MH024'),
('MM000167', '2202', 'MH025'),
('MM000168', '2202', 'MH028'),
('MM000169', '2202', 'MH029'),
('MM000170', '2202', 'MH030'),
('MM000171', '2202', 'MH031'),
('MM000172', '2202', 'MH033'),
('MM000173', '2202', 'MH034'),
('MM000174', '2202', 'MH037'),
('MM000175', '2202', 'MH038'),
('MM000176', '2202', 'MH039'),
('MM000177', '2202', 'MH040'),
('MM000178', '2202', 'MH045'),
('MM000179', '2202', 'MH047'),
('MM000180', '2202', 'MH048');

INSERT INTO DSMHMO (MaMo, MaHKNH, MaMH) VALUES
('MM000181', '2203', 'MH003'),
('MM000182', '2203', 'MH005'),
('MM000183', '2203', 'MH006'),
('MM000184', '2203', 'MH039'),
('MM000185', '2203', 'MH022'),
('MM000186', '2203', 'MH002'),
('MM000187', '2203', 'MH008'),
('MM000188', '2203', 'MH009'),
('MM000189', '2203', 'MH004'),
('MM000190', '2203', 'MH015'),
('MM000191', '2203', 'MH016'),
('MM000192', '2203', 'MH024'),
('MM000193', '2203', 'MH028'),
('MM000194', '2203', 'MH011'),
('MM000195', '2203', 'MH013'),
('MM000196', '2203', 'MH001'),
('MM000197', '2203', 'MH017'),
('MM000198', '2203', 'MH018'),
('MM000199', '2203', 'MH047'),
('MM000200', '2203', 'MH032'),
('MM000201', '2203', 'MH019'),
('MM000202', '2203', 'MH033'),
('MM000203', '2203', 'MH012'),
('MM000204', '2203', 'MH036'),
('MM000205', '2203', 'MH040'),
('MM000206', '2203', 'MH037'),
('MM000207', '2203', 'MH035'),
('MM000208', '2203', 'MH030'),
('MM000209', '2203', 'MH031'),
('MM000210', '2203', 'MH026'),
('MM000211', '2301', 'MH034'),
('MM000212', '2301', 'MH050'),
('MM000213', '2301', 'MH045'),
('MM000214', '2301', 'MH037'),
('MM000215', '2301', 'MH048'),
('MM000216', '2301', 'MH046'),
('MM000217', '2301', 'MH038'),
('MM000218', '2301', 'MH044'),
('MM000219', '2301', 'MH049'),
('MM000220', '2301', 'MH043'),
('MM000221', '2301', 'MH047'),
('MM000222', '2301', 'MH002'),
('MM000223', '2301', 'MH006'),
('MM000224', '2301', 'MH012'),
('MM000225', '2301', 'MH021'),
('MM000226', '2301', 'MH024'),
('MM000227', '2301', 'MH025'),
('MM000228', '2301', 'MH027'),
('MM000229', '2301', 'MH029'),
('MM000230', '2301', 'MH003'),
('MM000231', '2301', 'MH039'),
('MM000232', '2301', 'MH001'),
('MM000233', '2301', 'MH042'),
('MM000234', '2301', 'MH004'),
('MM000235', '2301', 'MH016'),
('MM000236', '2301', 'MH017'),
('MM000237', '2301', 'MH018'),
('MM000238', '2301', 'MH020'),
('MM000239', '2301', 'MH033'),
('MM000240', '2301', 'MH036');

INSERT INTO DSMHMO(MaMo, MaHKNH, MaMH) VALUES
('MM000241', '2302', 'MH001'),
('MM000242', '2302', 'MH002'),
('MM000243', '2302', 'MH003'),
('MM000244', '2302', 'MH004'),
('MM000245', '2302', 'MH005'),
('MM000246', '2302', 'MH006'),
('MM000247', '2302', 'MH007'),
('MM000248', '2302', 'MH008'),
('MM000249', '2302', 'MH009'),
('MM000250', '2302', 'MH010'),
('MM000251', '2302', 'MH011'),
('MM000252', '2302', 'MH012'),
('MM000253', '2302', 'MH013'),
('MM000254', '2302', 'MH022'),
('MM000255', '2302', 'MH023'),
('MM000256', '2302', 'MH024'),
('MM000257', '2302', 'MH025'),
('MM000258', '2302', 'MH026'),
('MM000259', '2302', 'MH027'),
('MM000260', '2302', 'MH028'),
('MM000261', '2302', 'MH029'),
('MM000262', '2302', 'MH030'),
('MM000263', '2302', 'MH031'),
('MM000264', '2302', 'MH033'),
('MM000265', '2302', 'MH034'),
('MM000266', '2302', 'MH035'),
('MM000267', '2302', 'MH036'),
('MM000268', '2302', 'MH037'),
('MM000269', '2302', 'MH038'),
('MM000270', '2302', 'MH039'),
('MM000271', '2302', 'MH040'),
('MM000272', '2302', 'MH041'),
('MM000273', '2302', 'MH042'),
('MM000274', '2302', 'MH043'),
('MM000275', '2302', 'MH044'),
('MM000276', '2302', 'MH045'),
('MM000277', '2302', 'MH046'),
('MM000278', '2302', 'MH047'),
('MM000279', '2302', 'MH048'),
('MM000280', '2302', 'MH049'),
('MM000281', '2302', 'MH050');


--ct_dkhp: 1000
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000001', 'MM000001');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000001', 'MM000002');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000001', 'MM000003');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000001', 'MM000010');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000001', 'MM000016');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000002', 'MM000022');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000002', 'MM000023');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000002', 'MM000003');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000002', 'MM000010');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000002', 'MM000018');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000003', 'MM000005');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000003', 'MM000011');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000003', 'MM000009');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000003', 'MM000019');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000003', 'MM000020');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000004', 'MM000007');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000004', 'MM000008');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000004', 'MM000002');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000004', 'MM000019');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000004', 'MM000020');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000005', 'MM000001');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000005', 'MM000008');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000005', 'MM000009');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000005', 'MM000022');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000005', 'MM000023');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000006', 'MM000019');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000006', 'MM000020');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000006', 'MM000029');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000006', 'MM000030');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000006', 'MM000003');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000007', 'MM000022');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000007', 'MM000023');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000007', 'MM000024');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000007', 'MM000025');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000007', 'MM000008');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000008', 'MM000012');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000008', 'MM000019');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000008', 'MM000020');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000008', 'MM000026');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000008', 'MM000027');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000009', 'MM000022');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000009', 'MM000023');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000009', 'MM000001');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000009', 'MM000026');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000009', 'MM000027');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000010', 'MM000002');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000010', 'MM000026');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000010', 'MM000027');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000010', 'MM000011');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000010', 'MM000004');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000011', 'MM000002');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000011', 'MM000010');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000011', 'MM000022');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000011', 'MM000023');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000011', 'MM000021');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000012', 'MM000006');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000012', 'MM000008');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000012', 'MM000012');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000012', 'MM000023');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000012', 'MM000022');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000013', 'MM000004');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000013', 'MM000009');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000013', 'MM000018');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000013', 'MM000029');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000013', 'MM000030');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000014', 'MM000005');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000014', 'MM000009');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000014', 'MM000019');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000014', 'MM000020');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000014', 'MM000021');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000015', 'MM000003');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000015', 'MM000010');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000015', 'MM000026');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000015', 'MM000027');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000015', 'MM000002');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000016', 'MM000009');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000016', 'MM000022');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000016', 'MM000023');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000016', 'MM000026');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000016', 'MM000027');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000017', 'MM000001');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000017', 'MM000015');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000017', 'MM000026');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000017', 'MM000027');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000017', 'MM000005');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000018', 'MM000011');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000018', 'MM000012');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000018', 'MM000003');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000018', 'MM000028');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000018', 'MM000029');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000019', 'MM000001');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000019', 'MM000008');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000019', 'MM000014');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000019', 'MM000026');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000019', 'MM000027');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000020', 'MM000009');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000020', 'MM000015');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000020', 'MM000029');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000020', 'MM000030');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000020', 'MM000025');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000021', 'MM000031');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000021', 'MM000038');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000021', 'MM000049');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000021', 'MM000050');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000021', 'MM000059');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000022', 'MM000033');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000022', 'MM000047');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000022', 'MM000055');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000022', 'MM000056');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000022', 'MM000060');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000023', 'MM000034');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000023', 'MM000041');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000023', 'MM000057');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000023', 'MM000058');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000023', 'MM000059');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000024', 'MM000031');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000024', 'MM000039');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000024', 'MM000049');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000024', 'MM000050');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000024', 'MM000060');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000025', 'MM000047');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000025', 'MM000035');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000025', 'MM000037');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000025', 'MM000051');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000025', 'MM000052');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000026', 'MM000038');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000026', 'MM000053');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000026', 'MM000054');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000026', 'MM000057');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000026', 'MM000058');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000027', 'MM000041');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000027', 'MM000043');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000027', 'MM000049');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000027', 'MM000050');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000027', 'MM000031');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000028', 'MM000036');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000028', 'MM000055');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000028', 'MM000056');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000028', 'MM000057');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000028', 'MM000058');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000029', 'MM000042');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000029', 'MM000044');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000029', 'MM000049');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000029', 'MM000050');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000029', 'MM000048');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000030', 'MM000033');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000030', 'MM000049');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000030', 'MM000050');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000030', 'MM000051');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000030', 'MM000052');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000031', 'MM000037');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000031', 'MM000047');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000031', 'MM000048');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000031', 'MM000049');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000031', 'MM000050');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000032', 'MM000039');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000032', 'MM000031');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000032', 'MM000049');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000032', 'MM000050');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000032', 'MM000047');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000033', 'MM000048');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000033', 'MM000049');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000033', 'MM000050');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000033', 'MM000055');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000033', 'MM000056');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000034', 'MM000040');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000034', 'MM000041');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000034', 'MM000042');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000034', 'MM000049');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000034', 'MM000050');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000035', 'MM000038');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000035', 'MM000039');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000035', 'MM000040');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000035', 'MM000055');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000035', 'MM000056');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000036', 'MM000041');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000036', 'MM000042');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000036', 'MM000043');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000036', 'MM000049');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000036', 'MM000050');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000037', 'MM000031');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000037', 'MM000038');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000037', 'MM000042');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000037', 'MM000050');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000037', 'MM000049');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000038', 'MM000031');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000038', 'MM000042');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000038', 'MM000053');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000038', 'MM000054');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000038', 'MM000059');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000039', 'MM000037');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000039', 'MM000042');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000039', 'MM000053');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000039', 'MM000054');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000039', 'MM000059');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000040', 'MM000051');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000040', 'MM000052');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000040', 'MM000053');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000040', 'MM000054');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000040', 'MM000059');

INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000041', 'MM000061');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000041', 'MM000062');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000041', 'MM000065');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000041', 'MM000067');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000042', 'MM000061');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000042', 'MM000063');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000042', 'MM000065');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000042', 'MM000067');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000042', 'MM000068');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000042', 'MM000069');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000043', 'MM000070');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000043', 'MM000071');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000043', 'MM000072');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000043', 'MM000073');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000043', 'MM000074');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000044', 'MM000065');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000044', 'MM000066');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000044', 'MM000067');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000044', 'MM000068');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000044', 'MM000069');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000044', 'MM000070');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000045', 'MM000061');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000045', 'MM000063');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000045', 'MM000074');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000045', 'MM000075');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000046', 'MM000065');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000046', 'MM000066');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000046', 'MM000080');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000046', 'MM000081');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000047', 'MM000066');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000047', 'MM000076');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000047', 'MM000077');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000047', 'MM000087');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000047', 'MM000088');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000047', 'MM000089');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000048', 'MM000066');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000048', 'MM000088');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000048', 'MM000089');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000048', 'MM000090');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000048', 'MM000091');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000049', 'MM000061');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000049', 'MM000062');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000049', 'MM000063');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000049', 'MM000064');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000049', 'MM000067');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000049', 'MM000070');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000050', 'MM000061');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000050', 'MM000062');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000050', 'MM000063');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000050', 'MM000064');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000050', 'MM000067');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000051', 'MM000065');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000051', 'MM000066');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000051', 'MM000080');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000051', 'MM000081');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000052', 'MM000061');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000052', 'MM000063');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000052', 'MM000074');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000052', 'MM000075');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000053', 'MM000082');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000053', 'MM000083');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000053', 'MM000084');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000053', 'MM000085');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000054', 'MM000066');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000054', 'MM000088');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000054', 'MM000089');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000054', 'MM000090');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000054', 'MM000091');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000055', 'MM000070');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000055', 'MM000071');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000055', 'MM000072');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000055', 'MM000073');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000055', 'MM000074');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000056', 'MM000061');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000056', 'MM000062');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000056', 'MM000065');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000056', 'MM000067');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000056', 'MM000070');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000057', 'MM000061');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000057', 'MM000062');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000057', 'MM000063');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000057', 'MM000064');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000057', 'MM000067');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000058', 'MM000082');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000058', 'MM000083');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000058', 'MM000084');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000058', 'MM000085');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000059', 'MM000070');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000059', 'MM000071');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000059', 'MM000072');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000059', 'MM000073');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000059', 'MM000074');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000060', 'MM000066');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000060', 'MM000076');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000060', 'MM000077');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000060', 'MM000087');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000060', 'MM000088');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000060', 'MM000089');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000061', 'MM000092');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000061', 'MM000093');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000061', 'MM000099');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000061', 'MM000110');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000061', 'MM000111');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000061', 'MM000119');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000061', 'MM000120');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000062', 'MM000092');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000062', 'MM000094');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000062', 'MM000095');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000062', 'MM000097');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000062', 'MM000099');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000063', 'MM000097');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000063', 'MM000099');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000063', 'MM000100');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000063', 'MM000102');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000063', 'MM000103');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000064', 'MM000101');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000064', 'MM000104');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000064', 'MM000106');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000064', 'MM000107');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000065', 'MM000097');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000065', 'MM000108');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000065', 'MM000109');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000065', 'MM000110');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000065', 'MM000111');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000066', 'MM000094');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000066', 'MM000095');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000066', 'MM000101');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000066', 'MM000105');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000066', 'MM000115');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000066', 'MM000116');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000067', 'MM000092');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000067', 'MM000094');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000067', 'MM000095');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000067', 'MM000097');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000067', 'MM000099');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000068', 'MM000097');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000068', 'MM000099');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000068', 'MM000100');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000068', 'MM000102');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000068', 'MM000103');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000069', 'MM000101');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000069', 'MM000104');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000069', 'MM000106');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000069', 'MM000107');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000070', 'MM000094');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000070', 'MM000095');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000070', 'MM000101');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000070', 'MM000105');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000070', 'MM000115');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000070', 'MM000116');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000071', 'MM000094');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000071', 'MM000095');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000071', 'MM000097');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000071', 'MM000099');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000072', 'MM000092');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000072', 'MM000101');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000072', 'MM000104');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000072', 'MM000106');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000072', 'MM000107');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000073', 'MM000097');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000073', 'MM000108');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000073', 'MM000109');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000073', 'MM000110');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000073', 'MM000111');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000074', 'MM000094');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000074', 'MM000101');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000074', 'MM000104');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000074', 'MM000106');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000074', 'MM000107');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000075', 'MM000095');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000075', 'MM000108');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000075', 'MM000109');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000075', 'MM000119');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000075', 'MM000120');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000076', 'MM000094');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000076', 'MM000095');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000076', 'MM000110');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000076', 'MM000111');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000076', 'MM000115');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000076', 'MM000116');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000077', 'MM000101');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000077', 'MM000104');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000077', 'MM000106');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000077', 'MM000107');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000078', 'MM000097');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000078', 'MM000099');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000078', 'MM000105');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000078', 'MM000100');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000078', 'MM000115');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000078', 'MM000116');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000079', 'MM000092');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000079', 'MM000094');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000079', 'MM000095');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000079', 'MM000097');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000079', 'MM000099');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000080', 'MM000097');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000080', 'MM000099');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000080', 'MM000100');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000080', 'MM000102');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000080', 'MM000103');

INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000081', 'MM000143');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000081', 'MM000123');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000081', 'MM000126');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000081', 'MM000127');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000082', 'MM000123');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000082', 'MM000133');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000082', 'MM000134');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000082', 'MM000144');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000082', 'MM000145');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000082', 'MM000135');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000083', 'MM000121');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000083', 'MM000143');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000083', 'MM000122');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000083', 'MM000146');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000083', 'MM000147');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000084', 'MM000123');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000084', 'MM000146');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000084', 'MM000147');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000084', 'MM000128');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000084', 'MM000129');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000084', 'MM000131');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000085', 'MM000131');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000085', 'MM000133');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000085', 'MM000134');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000085', 'MM000141');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000086', 'MM000144');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000086', 'MM000145');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000086', 'MM000135');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000086', 'MM000122');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000087', 'MM000126');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000087', 'MM000127');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000087', 'MM000124');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000087', 'MM000125');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000087', 'MM000136');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000087', 'MM000137');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000088', 'MM000122');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000088', 'MM000128');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000088', 'MM000129');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000088', 'MM000123');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000088', 'MM000132');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000089', 'MM000133');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000089', 'MM000134');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000089', 'MM000150');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000089', 'MM000151');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000089', 'MM000124');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000089', 'MM000125');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000090', 'MM000126');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000090', 'MM000127');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000090', 'MM000128');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000090', 'MM000129');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000090', 'MM000136');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000090', 'MM000137');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000091', 'MM000144');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000091', 'MM000145');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000091', 'MM000122');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000092', 'MM000144');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000092', 'MM000145');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000092', 'MM000124');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000092', 'MM000125');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000093', 'MM000126');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000093', 'MM000127');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000093', 'MM000133');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000093', 'MM000134');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000094', 'MM000130');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000094', 'MM000132');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000094', 'MM000136');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000094', 'MM000137');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000094', 'MM000146');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000094', 'MM000147');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000094', 'MM000135');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000095', 'MM000132');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000095', 'MM000148');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000095', 'MM000149');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000095', 'MM000139');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000095', 'MM000140');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000096', 'MM000128');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000096', 'MM000129');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000096', 'MM000123');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000096', 'MM000136');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000096', 'MM000137');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000097', 'MM000122');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000097', 'MM000128');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000097', 'MM000129');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000098', 'MM000150');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000098', 'MM000151');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000098', 'MM000138');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000098', 'MM000139');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000099', 'MM000146');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000099', 'MM000147');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000099', 'MM000135');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000099', 'MM000132');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000099', 'MM000121');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000100', 'MM000146');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000100', 'MM000147');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000100', 'MM000126');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000100', 'MM000127');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000100', 'MM000122');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000100', 'MM000141');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000101', 'MM000160');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000101', 'MM000153');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000101', 'MM000179');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000101', 'MM000180');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000101', 'MM000152');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000101', 'MM000174');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000101', 'MM000175');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000102', 'MM000154');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000102', 'MM000164');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000102', 'MM000165');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000102', 'MM000157');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000103', 'MM000153');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000103', 'MM000164');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000103', 'MM000165');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000103', 'MM000158');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000103', 'MM000159');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000104', 'MM000155');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000104', 'MM000172');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000104', 'MM000173');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000104', 'MM000156');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000105', 'MM000176');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000105', 'MM000177');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000105', 'MM000155');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000105', 'MM000158');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000105', 'MM000163');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000106', 'MM000162');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000106', 'MM000164');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000106', 'MM000165');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000106', 'MM000157');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000106', 'MM000168');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000106', 'MM000169');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000107', 'MM000155');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000107', 'MM000179');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000107', 'MM000180');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000107', 'MM000169');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000107', 'MM000157');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000108', 'MM000155');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000108', 'MM000176');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000108', 'MM000177');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000108', 'MM000152');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000108', 'MM000160');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000109', 'MM000162');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000109', 'MM000165');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000109', 'MM000152');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000109', 'MM000156');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000110', 'MM000158');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000110', 'MM000153');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000110', 'MM000176');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000110', 'MM000177');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000110', 'MM000168');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000110', 'MM000169');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000111', 'MM000156');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000111', 'MM000178');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000111', 'MM000164');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000111', 'MM000158');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000112', 'MM000154');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000112', 'MM000156');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000112', 'MM000166');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000112', 'MM000167');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000112', 'MM000159');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000112', 'MM000158');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000113', 'MM000178');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000113', 'MM000163');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000113', 'MM000179');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000113', 'MM000180');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000113', 'MM000152');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000114', 'MM000163');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000114', 'MM000153');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000114', 'MM000169');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000114', 'MM000170');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000114', 'MM000155');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000115', 'MM000162');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000115', 'MM000174');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000115', 'MM000175');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000116', 'MM000156');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000116', 'MM000166');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000116', 'MM000167');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000116', 'MM000160');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000116', 'MM000179');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000116', 'MM000180');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000116', 'MM000157');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000117', 'MM000157');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000117', 'MM000166');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000117', 'MM000167');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000117', 'MM000178');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000118', 'MM000176');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000118', 'MM000177');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000118', 'MM000157');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000118', 'MM000168');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000118', 'MM000169');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000118', 'MM000165');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000119', 'MM000174');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000119', 'MM000164');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000119', 'MM000153');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000119', 'MM000152');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000119', 'MM000157');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000120', 'MM000179');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000120', 'MM000180');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000120', 'MM000168');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000120', 'MM000169');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000120', 'MM000163');

INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000121', 'MM000186');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000121', 'MM000187');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000121', 'MM000208');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000121', 'MM000209');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000121', 'MM000182');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000122', 'MM000193');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000122', 'MM000194');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000122', 'MM000195');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000122', 'MM000186');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000122', 'MM000207');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000123', 'MM000208');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000123', 'MM000189');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000123', 'MM000192');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000123', 'MM000193');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000123', 'MM000194');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000124', 'MM000195');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000124', 'MM000186');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000124', 'MM000197');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000124', 'MM000198');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000124', 'MM000209');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000125', 'MM000192');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000125', 'MM000193');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000125', 'MM000194');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000125', 'MM000195');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000125', 'MM000186');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000126', 'MM000187');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000126', 'MM000188');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000126', 'MM000209');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000126', 'MM000192');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000126', 'MM000193');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000127', 'MM000194');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000127', 'MM000195');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000127', 'MM000206');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000127', 'MM000187');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000127', 'MM000188');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000128', 'MM000189');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000128', 'MM000192');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000128', 'MM000193');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000128', 'MM000194');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000128', 'MM000195');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000129', 'MM000186');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000129', 'MM000187');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000129', 'MM000208');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000129', 'MM000209');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000129', 'MM000192');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000130', 'MM000193');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000130', 'MM000194');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000130', 'MM000195');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000130', 'MM000186');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000130', 'MM000187');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000131', 'MM000188');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000131', 'MM000189');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000131', 'MM000192');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000131', 'MM000193');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000131', 'MM000194');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000132', 'MM000195');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000132', 'MM000186');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000132', 'MM000187');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000132', 'MM000208');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000132', 'MM000209');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000133', 'MM000192');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000133', 'MM000193');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000133', 'MM000184');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000133', 'MM000185');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000133', 'MM000186');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000134', 'MM000187');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000134', 'MM000188');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000134', 'MM000189');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000134', 'MM000192');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000134', 'MM000193');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000135', 'MM000194');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000135', 'MM000195');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000135', 'MM000186');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000135', 'MM000187');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000135', 'MM000208');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000136', 'MM000189');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000136', 'MM000202');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000136', 'MM000203');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000136', 'MM000204');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000136', 'MM000205');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000137', 'MM000202');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000137', 'MM000203');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000137', 'MM000194');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000137', 'MM000195');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000137', 'MM000198');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000138', 'MM000189');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000138', 'MM000190');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000138', 'MM000191');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000138', 'MM000202');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000138', 'MM000203');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000139', 'MM000204');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000139', 'MM000205');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000139', 'MM000208');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000139', 'MM000189');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000139', 'MM000190');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000140', 'MM000191');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000140', 'MM000182');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000140', 'MM000183');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000140', 'MM000204');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000140', 'MM000205');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000141', 'MM000218');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000141', 'MM000219');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000141', 'MM000230');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000141', 'MM000231');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000141', 'MM000212');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000142', 'MM000213');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000142', 'MM000214');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000142', 'MM000215');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000142', 'MM000218');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000142', 'MM000219');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000143', 'MM000220');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000143', 'MM000221');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000143', 'MM000212');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000143', 'MM000213');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000143', 'MM000214');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000144', 'MM000215');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000144', 'MM000218');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000144', 'MM000219');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000144', 'MM000220');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000144', 'MM000221');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000145', 'MM000212');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000145', 'MM000213');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000145', 'MM000214');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000145', 'MM000225');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000145', 'MM000228');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000146', 'MM000229');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000146', 'MM000230');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000146', 'MM000231');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000146', 'MM000212');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000146', 'MM000213');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000147', 'MM000214');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000147', 'MM000215');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000147', 'MM000218');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000147', 'MM000239');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000147', 'MM000230');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000148', 'MM000231');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000148', 'MM000222');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000148', 'MM000223');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000148', 'MM000214');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000148', 'MM000215');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000149', 'MM000218');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000149', 'MM000219');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000149', 'MM000220');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000149', 'MM000221');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000149', 'MM000232');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000150', 'MM000233');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000150', 'MM000234');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000150', 'MM000225');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000150', 'MM000228');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000150', 'MM000229');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000151', 'MM000220');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000151', 'MM000221');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000151', 'MM000212');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000151', 'MM000213');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000151', 'MM000214');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000152', 'MM000215');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000152', 'MM000218');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000152', 'MM000219');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000152', 'MM000230');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000152', 'MM000231');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000153', 'MM000223');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000153', 'MM000228');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000153', 'MM000222');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000153', 'MM000234');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000153', 'MM000235');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000154', 'MM000212');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000154', 'MM000214');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000154', 'MM000215');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000154', 'MM000237');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000154', 'MM000238');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000155', 'MM000227');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000155', 'MM000238');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000155', 'MM000237');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000155', 'MM000218');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000155', 'MM000217');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000156', 'MM000218');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000156', 'MM000222');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000156', 'MM000223');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000156', 'MM000228');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000156', 'MM000232');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000157', 'MM000233');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000157', 'MM000218');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000157', 'MM000216');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000157', 'MM000236');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000157', 'MM000237');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000158', 'MM000239');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000158', 'MM000211');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000158', 'MM000212');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000158', 'MM000221');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000158', 'MM000222');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000159', 'MM000223');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000159', 'MM000224');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000159', 'MM000233');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000159', 'MM000213');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000159', 'MM000234');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000160', 'MM000233');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000160', 'MM000213');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000160', 'MM000214');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000160', 'MM000232');
INSERT INTO CT_DKHP (MaPhieuDKHP, MaMo) VALUES ('DK000160', 'MM000235');

INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000161', 'MM000266');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000161', 'MM000267');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000161', 'MM000268');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000161', 'MM000269');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000161', 'MM000272');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000161', 'MM000273');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000161', 'MM000274');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000161', 'MM000275');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000162', 'MM000266');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000162', 'MM000267');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000162', 'MM000268');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000162', 'MM000269');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000162', 'MM000272');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000162', 'MM000273');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000162', 'MM000274');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000162', 'MM000275');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000163', 'MM000266');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000163', 'MM000267');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000163', 'MM000268');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000163', 'MM000269');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000163', 'MM000272');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000163', 'MM000273');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000163', 'MM000274');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000163', 'MM000275');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000164', 'MM000266');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000164', 'MM000267');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000164', 'MM000268');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000164', 'MM000269');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000164', 'MM000272');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000164', 'MM000273');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000164', 'MM000274');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000164', 'MM000275');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000165', 'MM000266');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000165', 'MM000267');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000165', 'MM000268');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000165', 'MM000269');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000165', 'MM000272');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000165', 'MM000273');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000165', 'MM000274');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000165', 'MM000275');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000166', 'MM000266');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000166', 'MM000267');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000166', 'MM000268');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000166', 'MM000269');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000166', 'MM000272');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000166', 'MM000273');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000166', 'MM000274');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000166', 'MM000275');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000167', 'MM000266');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000167', 'MM000267');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000167', 'MM000268');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000167', 'MM000269');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000167', 'MM000272');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000167', 'MM000273');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000167', 'MM000274');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000167', 'MM000275');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000168', 'MM000266');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000168', 'MM000267');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000168', 'MM000268');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000168', 'MM000269');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000168', 'MM000272');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000168', 'MM000273');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000168', 'MM000274');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000168', 'MM000275');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000169', 'MM000266');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000169', 'MM000267');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000169', 'MM000268');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000169', 'MM000269');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000169', 'MM000272');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000169', 'MM000273');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000169', 'MM000274');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000169', 'MM000275');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000170', 'MM000266');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000170', 'MM000267');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000170', 'MM000268');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000170', 'MM000269');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000170', 'MM000272');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000170', 'MM000273');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000170', 'MM000274');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000170', 'MM000275');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000171', 'MM000272');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000171', 'MM000273');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000171', 'MM000274');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000171', 'MM000275');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000171', 'MM000278');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000171', 'MM000279');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000171', 'MM000280');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000171', 'MM000281');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000172', 'MM000272');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000172', 'MM000273');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000172', 'MM000274');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000172', 'MM000275');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000172', 'MM000278');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000172', 'MM000279');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000172', 'MM000280');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000172', 'MM000281');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000173', 'MM000272');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000173', 'MM000273');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000173', 'MM000274');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000173', 'MM000275');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000173', 'MM000278');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000173', 'MM000279');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000173', 'MM000280');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000173', 'MM000281');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000174', 'MM000272');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000174', 'MM000273');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000174', 'MM000274');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000174', 'MM000275');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000174', 'MM000278');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000174', 'MM000279');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000174', 'MM000280');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000174', 'MM000281');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000175', 'MM000272');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000175', 'MM000273');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000175', 'MM000274');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000175', 'MM000275');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000175', 'MM000278');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000175', 'MM000279');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000175', 'MM000280');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000175', 'MM000281');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000176', 'MM000272');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000176', 'MM000273');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000176', 'MM000274');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000176', 'MM000275');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000176', 'MM000278');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000176', 'MM000279');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000176', 'MM000280');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000176', 'MM000281');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000177', 'MM000272');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000177', 'MM000273');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000177', 'MM000274');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000177', 'MM000275');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000177', 'MM000278');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000177', 'MM000279');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000177', 'MM000280');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000177', 'MM000281');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000178', 'MM000272');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000178', 'MM000273');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000178', 'MM000274');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000178', 'MM000275');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000178', 'MM000278');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000178', 'MM000279');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000178', 'MM000280');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000178', 'MM000281');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000179', 'MM000272');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000179', 'MM000273');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000179', 'MM000274');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000179', 'MM000275');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000179', 'MM000278');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000179', 'MM000279');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000179', 'MM000280');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000179', 'MM000281');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000180', 'MM000272');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000180', 'MM000273');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000180', 'MM000274');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000180', 'MM000275');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000180', 'MM000278');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000180', 'MM000279');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000180', 'MM000280');
INSERT INTO CT_DKHP(MaPhieuDKHP, MaMo) VALUES ('DK000180', 'MM000281');
go

--phieuthu: 400
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000001', 405000, '12-8-2020', 'DK000001');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000002', 100000, '10-8-2020', 'DK000002');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000003', 200000, '20-8-2020', 'DK000002');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000004', 61000, '25-8-2020', 'DK000002');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000005', 200000, '15-8-2020', 'DK000003');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000006', 107000, '20-8-2020', 'DK000003');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000007', 200000, '11-8-2020', 'DK000004');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000008', 188000, '21-8-2020', 'DK000004');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000009', 361000, '20-8-2020', 'DK000005');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000010', 100000, '5-8-2020', 'DK000006');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000011', 100000, '15-8-2020', 'DK000006');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000012', 90000, '22-8-2020', 'DK000006');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000013', 344000, '28-8-2020', 'DK000007');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000014', 100000, '7-8-2020', 'DK000008');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000015', 190000, '15-8-2020', 'DK000008');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000016', 290000, '28-8-2020', 'DK000009');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000017', 153500, '27-8-2020', 'DK000010');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000018', 388000, '25-8-2020', 'DK000011');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000019', 100000, '1-8-2020', 'DK000012');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000020', 100000, '8-8-2020', 'DK000012');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000021', 100000, '15-8-2020', 'DK000012');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000022', 88000, '22-8-2020', 'DK000012');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000023', 100000, '8-8-2020', 'DK000013');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000024', 67000, '16-8-2020', 'DK000013');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000025', 200000, '13-8-2020', 'DK000014');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000026', 134000, '23-8-2020', 'DK000014');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000027', 100000, '9-8-2020', 'DK000015');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000028', 152700, '24-8-2020', 'DK000015');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000029', 200000, '3-8-2020', 'DK000016');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000030', 117000, '16-8-2020', 'DK000016');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000031', 200000, '3-8-2020', 'DK000017');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000032', 100000, '12-8-2020', 'DK000017');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000033', 100000, '12-8-2020', 'DK000018');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000034', 100000, '20-8-2020', 'DK000018');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000035', 70000, '28-8-2020', 'DK000018');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000036', 200000, '2-8-2020', 'DK000019');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000037', 100000, '15-8-2020', 'DK000019');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000038', 88000, '25-8-2020', 'DK000019');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000039', 50000, '12-8-2020', 'DK000020');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000040', 18800, '25-8-2020', 'DK000020');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000041', 361000, '12-2-2021', 'DK000021');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000042', 200000, '20-1-2021', 'DK000022');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000043', 161000, '15-2-2021', 'DK000022');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000044', 100000, '25-1-2021', 'DK000023');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000045', 100000, '5-2-2021', 'DK000023');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000046', 107000, '15-2-2021', 'DK000023');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000047', 200000, '21-1-2021', 'DK000024');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000048', 134000, '11-2-2021', 'DK000024');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000049', 300000, '18-2-2021', 'DK000025');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000050', 100000, '25-1-2021', 'DK000026');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000051', 100000, '1-2-2021', 'DK000026');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000052', 144000, '12-2-2021', 'DK000026');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000053', 280000, '18-2-2021', 'DK000027');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000054', 100000, '7-2-2021', 'DK000028');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000055', 244000, '15-2-2021', 'DK000028');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000056', 361000, '18-2-2021', 'DK000029');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000057', 145000, '17-2-2021', 'DK000030');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000058', 388000, '15-2-2021', 'DK000031');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000059', 100000, '1-2-2021', 'DK000032');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000060', 100000, '8-2-2021', 'DK000032');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000061', 100000, '15-2-2021', 'DK000032');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000062', 61000, '18-2-2021', 'DK000032');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000063', 100000, '8-2-2021', 'DK000033');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000064', 58500, '16-2-2021', 'DK000033');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000065', 200000, '3-2-2021', 'DK000034');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000066', 134000, '15-2-2021', 'DK000034');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000067', 100000, '29-1-2021', 'DK000035');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000068', 190500, '14-2-2021', 'DK000035');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000069', 200000, '3-2-2021', 'DK000036');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000070', 80000, '16-2-2021', 'DK000036');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000071', 200000, '3-2-2021', 'DK000037');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000072', 134000, '12-2-2021', 'DK000037');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000073', 100000, '22-1-2021', 'DK000038');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000074', 100000, '2-2-2021', 'DK000038');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000075', 107000, '18-2-2021', 'DK000038');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000076', 200000, '22-1-2021', 'DK000039');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000077', 100000, '5-2-2021', 'DK000039');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000078', 34000, '15-2-2021', 'DK000039');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000079', 50000, '2-2-2021', 'DK000040');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000080', 13400, '15-2-2021', 'DK000040');

set dateformat dmy
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000081', 351000, '31-7-2021', 'DK000041');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000082', 100000, '31-7-2021', 'DK000042');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000083', 100000, '2-8-2021', 'DK000042');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000084', 100000, '4-8-2021', 'DK000042');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000085', 142000, '7-8-2021', 'DK000042');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000086', 200000, '2-8-2021', 'DK000043');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000087', 107000, '16-8-2021', 'DK000043');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000088', 300000, '19-8-2021', 'DK000044');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000089', 100000, '1-8-2021', 'DK000045');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000090', 40000, '5-8-2021', 'DK000045');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000091', 100000, '6-8-2021', 'DK000046');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000092', 26000, '11-8-2021', 'DK000046');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000093', 100000, '20-8-2021', 'DK000046');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000094', 271000, '15-8-2021', 'DK000047');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000095', 100000, '20-8-2021', 'DK000047');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000096', 290000, '13-8-2021', 'DK000048');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000097', 567000, '17-8-2021', 'DK000049');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000098', 100000, '6-8-2021', 'DK000050');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000099', 100000, '11-8-2021', 'DK000050');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000100', 150000, '17-8-2021', 'DK000050');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000101', 136000, '21-8-2021', 'DK000050');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000102', 226000, '9-8-2021', 'DK000051');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000103', 100000, '3-8-2021', 'DK000052');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000104', 100000, '6-8-2021', 'DK000052');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000105', 80000, '9-8-2021', 'DK000052');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000106', 136000, '6-8-2021', 'DK000053');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000107', 100000, '20-8-2021', 'DK000053');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000108', 150000, '6-8-2021', 'DK000054');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000109', 140000, '18-8-2021', 'DK000054');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000110', 307000, '7-8-2021', 'DK000055');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000111', 50000, '5-8-2021', 'DK000056');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000112', 100000, '10-8-2021', 'DK000056');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000113', 100000, '15-8-2021', 'DK000056');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000114', 182000, '20-8-2021', 'DK000056');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000115', 200000, '7-8-2021', 'DK000057');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000116', 286000, '17-8-2021', 'DK000057');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000117', 236000, '18-8-2021', 'DK000058');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000118', 200000, '14-8-2021', 'DK000059');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000119', 100000, '5-8-2021', 'DK000060');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000120', 100000, '16-8-2021', 'DK000060');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000121', 150000, '14-1-2022', 'DK000061');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000122', 150000, '21-1-2022', 'DK000061');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000123', 98000, '7-2-2022', 'DK000061');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000124', 351000, '16-1-2022', 'DK000062');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000125', 150000, '11-1-2022', 'DK000063');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000126', 184000, '28-1-2022', 'DK000063');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000127', 100000, '31-1-2022', 'DK000064');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000128', 100000, '6-2-2022', 'DK000064');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000129', 80000, '7-2-2022', 'DK000064');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000130', 90000, '15-1-2022', 'DK000065');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000131', 150000, '12-1-2022', 'DK000066');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000132', 178300, '27-1-2022', 'DK000066');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000133', 351000, '2-2-2022', 'DK000067');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000134', 50000, '24-1-2022', 'DK000068');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000135', 150000, '30-1-2022', 'DK000068');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000136', 134000, '6-2-2022', 'DK000068');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000137', 100000, '22-1-2022', 'DK000069');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000138', 180000, '5-2-2022', 'DK000069');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000139', 100000, '13-1-2022', 'DK000070');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000140', 200000, '28-1-2022', 'DK000070');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000141', 50000, '15-1-2022', 'DK000071');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000142', 50000, '29-1-2022', 'DK000071');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000143', 107900, '7-2-2022', 'DK000071');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000144', 334000, '13-1-2022', 'DK000072');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000145', 100000, '15-1-2022', 'DK000073');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000146', 100000, '24-1-2022', 'DK000073');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000147', 90000, '1-2-2022', 'DK000073');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000148', 100000, '22-1-2022', 'DK000074');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000149', 100000, '23-1-2022', 'DK000074');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000150', 188000, '29-1-2022', 'DK000074');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000151', 150000, '13-1-2022', 'DK000076');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000152', 150000, '2-2-2022', 'DK000076');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000153', 125000, '7-2-2022', 'DK000076');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000154', 280000, '6-2-2022', 'DK000077');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000155', 415000, '31-1-2022', 'DK000078');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000156', 351000, '1-2-2022', 'DK000079');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000157', 100000, '16-1-2022', 'DK000080');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000158', 100000, '24-1-2022', 'DK000080');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000159', 100000, '1-2-2022', 'DK000080');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000160', 34000, '7-2-2022', 'DK000080');

INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000161', 226000, '5-8-2022', 'DK000081');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000162', 100000, '3-8-2022', 'DK000082');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000163', 100000, '10-8-2022', 'DK000082');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000164', 100000, '22-8-2022', 'DK000082');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000165', 44000, '27-8-2022', 'DK000082');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000166', 200000, '2-8-2022', 'DK000083');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000167', 134000, '16-8-2022', 'DK000083');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000168', 100000, '19-8-2022', 'DK000084');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000169', 100000, '1-8-2022', 'DK000085');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000170', 53500, '27-8-2022', 'DK000085');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000171', 100000, '6-8-2022', 'DK000086');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000172', 100000, '11-8-2022', 'DK000086');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000173', 80000, '25-8-2022', 'DK000086');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000174', 100000, '15-8-2022', 'DK000087');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000175', 100000, '20-8-2022', 'DK000087');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000176', 351000, '13-8-2022', 'DK000088');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000177', 354000, '17-8-2022', 'DK000089');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000178', 50000, '6-8-2022', 'DK000090');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000179', 50000, '11-8-2022', 'DK000090');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000180', 50000, '17-8-2022', 'DK000090');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000181', 50000, '22-8-2022', 'DK000090');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000182', 226000, '9-8-2022', 'DK000091');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000183', 100000, '3-8-2022', 'DK000092');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000184', 100000, '6-8-2022', 'DK000092');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000185', 36000, '9-8-2022', 'DK000092');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000186', 50000, '6-8-2022', 'DK000093');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000187', 50000, '25-8-2022', 'DK000093');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000188', 200000, '6-8-2022', 'DK000094');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000189', 225000, '18-8-2022', 'DK000094');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000190', 317000, '7-8-2022', 'DK000095');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000191', 75000, '5-8-2022', 'DK000096');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000192', 75000, '16-8-2022', 'DK000096');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000193', 50000, '21-8-2022', 'DK000096');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000194', 80000, '28-8-2022', 'DK000096');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000195', 100000, '7-8-2022', 'DK000097');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000196', 116000, '17-8-2022', 'DK000097');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000197', 280000, '18-8-2022', 'DK000098');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000198', 307000, '14-8-2022', 'DK000099');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000199', 200000, '5-8-2022', 'DK000100');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000200', 225000, '26-8-2022', 'DK000100');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000201', 150000, '14-1-2023', 'DK000101');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000202', 150000, '21-1-2023', 'DK000101');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000203', 179000, '11-2-2023', 'DK000101');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000204', 297000, '16-1-2023', 'DK000102');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000205', 200000, '11-1-2023', 'DK000103');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000206', 124000, '28-1-2023', 'DK000103');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000207', 100000, '31-1-2023', 'DK000104');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000208', 100000, '6-2-2023', 'DK000104');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000209', 134000, '11-2-2023', 'DK000104');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000210', 361000, '15-1-2023', 'DK000105');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000211', 200000, '12-1-2023', 'DK000106');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000212', 128300, '27-1-2023', 'DK000106');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000213', 344000, '2-2-2023', 'DK000107');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000214', 100000, '24-1-2023', 'DK000108');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000215', 100000, '30-1-2023', 'DK000108');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000216', 215000, '6-2-2023', 'DK000108');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000217', 100000, '22-1-2023', 'DK000109');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000218', 278000, '5-2-2023', 'DK000109');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000219', 200000, '13-1-2023', 'DK000110');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000220', 144000, '28-1-2023', 'DK000110');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000221', 50000, '15-1-2023', 'DK000111');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000222', 50000, '29-1-2023', 'DK000111');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000223', 126800, '9-2-2023', 'DK000111');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000224', 432000, '13-1-2023', 'DK000112');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000225', 100000, '15-1-2023', 'DK000113');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000226', 100000, '24-1-2023', 'DK000113');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000227', 161000, '1-2-2023', 'DK000113');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000228', 100000, '22-1-2023', 'DK000114');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000229', 100000, '23-1-2023', 'DK000114');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000230', 161000, '29-1-2023', 'DK000114');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000231', 200000, '13-1-2023', 'DK000116');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000232', 200000, '2-2-2023', 'DK000116');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000233', 177000, '10-2-2023', 'DK000116');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000234', 324000, '6-2-2023', 'DK000117');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000235', 398000, '31-1-2023', 'DK000118');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000236', 378000, '1-2-2023', 'DK000119');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000237', 100000, '16-1-2023', 'DK000120');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000238', 100000, '24-1-2023', 'DK000120');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000239', 100000, '1-2-2023', 'DK000120');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000240', 17000, '7-2-2023', 'DK000120');
set dateformat dmy
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000241', 200000, '18-6-2023', 'DK000121');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000242', 161000, '28-6-2023', 'DK000121');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000243', 150000, '21-6-2023', 'DK000122');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000244', 201000, '25-6-2023', 'DK000122');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000245', 100000, '5-6-2023', 'DK000123');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000246', 75500, '7-6-2023', 'DK000123');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000247', 150000, '9-6-2023', 'DK000124');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000248', 211000, '15-6-2023', 'DK000124');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000249', 200000, '16-6-2023', 'DK000125');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000250', 45700, '17-6-2023', 'DK000125');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000251', 250000, '15-6-2023', 'DK000126');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000252', 138000, '16-6-2023', 'DK000126');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000253', 330000, '17-6-2023', 'DK000127');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000254', 48000, '21-6-2023', 'DK000127');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000255', 120000, '10-6-2023', 'DK000128');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000256', 204000, '11-6-2023', 'DK000128');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000257', 320000, '12-6-2023', 'DK000129');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000258', 68000, '19-6-2023', 'DK000129');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000259', 50000, '14-6-2023', 'DK000130');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000260', 25600, '17-6-2023', 'DK000130');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000261', 200000, '3-6-2023', 'DK000131');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000262', 100000, '8-6-2023', 'DK000131');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000263', 100000, '5-6-2023', 'DK000132');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000264', 80500, '10-6-2023', 'DK000132');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000265', 200000, '7-6-2023', 'DK000133');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000266', 205000, '9-6-2023', 'DK000133');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000267', 205000, '3-6-2023', 'DK000134');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000268', 200000, '15-6-2023', 'DK000134');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000269', 100000, '20-6-2023', 'DK000135');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000270', 278000, '29-6-2023', 'DK000135');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000271', 63000, '4-7-2023', 'DK000136');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000272', 200000, '5-7-2023', 'DK000136');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000273', 200000, '15-7-2023', 'DK000137');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000274', 100000, '16-7-2023', 'DK000137');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000275', 200000, '22-7-2023', 'DK000138');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000276', 205000, '25-7-2023', 'DK000138');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000277', 200000, '1-7-2023', 'DK000139');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000278', 21900, '20-7-2023', 'DK000139');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000279', 300000, '4-7-2023', 'DK000140');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000280', 44000, '16-7-2023', 'DK000140');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000281', 100000, '31-8-2023', 'DK000141');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000282', 190000, '1-9-2023', 'DK000141');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000283', 100000, '27-8-2023', 'DK000142');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000284', 200000, '1-9-2023', 'DK000142');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000285', 200000, '26-8-2023', 'DK000143');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000286', 52700, '29-8-2023', 'DK000143');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000287', 200000, '25-8-2023', 'DK000144');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000288', 117000, '29-8-2023', 'DK000144');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000289', 150000, '27-8-2023', 'DK000145');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000290', 167000, '31-8-2023', 'DK000145');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000291', 200000, '25-8-2023', 'DK000146');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000292', 90000, '30-8-2023', 'DK000146');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000293', 90000, '25-8-2023', 'DK000147');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000294', 200000, '26-8-2023', 'DK000147');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000295', 100000, '27-8-2023', 'DK000148');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000296', 200000, '29-8-2023', 'DK000148');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000297', 150000, '2-9-2023', 'DK000149');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000298', 184000, '7-9-2023', 'DK000149');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000299', 146000, '25-8-2023', 'DK000150');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000300', 100000, '29-8-2023', 'DK000150');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000301', 200000, '25-8-2023', 'DK000151');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000302', 161000, '29-8-2023', 'DK000151');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000303', 150000, '24-8-2023', 'DK000152');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000304', 53000, '5-9-2023', 'DK000152');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000305', 200000, '25-8-2023', 'DK000153');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000306', 188000, '28-8-2023', 'DK000153');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000307', 100000, '29-8-2023', 'DK000154');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000308', 217000, '6-9-2023', 'DK000154');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000309', 200000, '28-8-2023', 'DK000155');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000310', 117000, '3-9-2023', 'DK000155');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000311', 300000, '24-8-2023', 'DK000156');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000312', 17000, '30-8-2023', 'DK000156');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000313', 300000, '27-8-2023', 'DK000157');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000314', 44000, '5-9-2023', 'DK000157');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000315', 100000, '27-8-2023', 'DK000158');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000316', 217000, '6-9-2023', 'DK000158');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000317', 100000, '24-8-2023', 'DK000159');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000318', 234000, '5-9-2023', 'DK000159');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000319', 150000, '24-8-2023', 'DK000160');
INSERT INTO PHIEUTHUHP (MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000320', 211000, '28-8-2023', 'DK000160');

INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000321', 100000, '20-1-2024', 'DK000161');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000322', 100000, '24-1-2024', 'DK000161');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000323', 200000, '28-1-2024', 'DK000161');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000324', 200000, '21-1-2024', 'DK000162');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000325', 200000, '22-1-2024', 'DK000162');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000326', 72000, '23-1-2024', 'DK000162');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000327', 30400, '10-1-2024', 'DK000163');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000328', 100000, '11-1-2024', 'DK000163');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000329', 200000, '12-1-2024', 'DK000163');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000330', 200000, '20-1-2024', 'DK000164');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000331', 200000, '21-1-2024', 'DK000164');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000332', 72000, '22-1-2024', 'DK000164');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000333', 72000, '20-1-2024', 'DK000165');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000334', 100000, '24-1-2024', 'DK000165');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000335', 300000, '28-1-2024', 'DK000165');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000336', 72000, '12-1-2024', 'DK000166');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000337', 200000, '15-1-2024', 'DK000166');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000338', 200000, '19-1-2024', 'DK000166');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000339', 200000, '20-1-2024', 'DK000167');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000340', 72000, '24-1-2024', 'DK000167');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000341', 200000, '28-1-2024', 'DK000167');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000342', 150000, '18-1-2024', 'DK000168');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000343', 150000, '21-1-2024', 'DK000168');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000344', 172000, '25-1-2024', 'DK000168');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000345', 172000, '5-1-2024', 'DK000169');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000346', 150000, '7-1-2024', 'DK000169');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000347', 150000, '9-1-2024', 'DK000169');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000348', 200000, '15-1-2024', 'DK000170');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000349', 100000, '16-1-2024', 'DK000170');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000350', 100000, '17-1-2024', 'DK000170');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000351', 200000, '15-1-2024', 'DK000171');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000352', 100000, '16-1-2024', 'DK000171');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000353', 330000, '17-1-2024', 'DK000172');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000354', 400, '21-1-2024', 'DK000172');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000355', 270000, '10-1-2024', 'DK000173');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000356', 202000, '11-1-2024', 'DK000173');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000357', 372000, '12-1-2024', 'DK000174');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000358', 100000, '19-1-2024', 'DK000174');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000359', 100000, '14-1-2024', 'DK000175');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000360', 372000, '17-1-2024', 'DK000175');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000361', 200000, '2-1-2024', 'DK000176');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000362', 272000, '8-1-2024', 'DK000176');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000363', 200000, '5-1-2024', 'DK000177');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000364', 200000, '10-1-2024', 'DK000177');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000365', 270000, '7-1-2024', 'DK000178');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000366', 202000, '9-1-2024', 'DK000178');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000367', 272000, '3-1-2024', 'DK000179');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000368', 100000, '15-1-2024', 'DK000179');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000369', 100000, '20-1-2024', 'DK000180');
INSERT INTO PHIEUTHUHP(MaPhieuThu, SoTienThu, NgayLap, MaPhieuDKHP) VALUES ('PT000370', 272000, '29-1-2024', 'DK000180');
go
