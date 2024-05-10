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
    HocKy NVARCHAR(10),
    NamHoc NVARCHAR(8),
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
    MaPhieuDK VARCHAR(8) NOT NULL,
    MaMo VARCHAR(8) NOT NULL,
    PRIMARY KEY (MaPhieuDK, MaMo),
    FOREIGN KEY (MaPhieuDK) REFERENCES PHIEUDKHP(MaPhieuDKHP),
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
    MaHKNM VARCHAR(4) NOT NULL,
    MSSV VARCHAR(8) NOT NULL,
    PRIMARY KEY (MaHKNM, MSSV),
    FOREIGN KEY (MaHKNM) REFERENCES HOCKY_NAMHOC(MaHKNH),
    FOREIGN KEY (MSSV) REFERENCES SINHVIEN(MSSV)
);

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
('HUYN01', N'Ba Đình', 'T01', 0),
('HUYN02', N'Hai Bà Trưng', 'T01', 0),
('HUYN03', N'Cầu Giấy', 'T01', 0),
('HUYN04', N'Thanh Trì', 'T01', 0),
('HUYN05', N'Ba Vì', 'T01', 0),

-- Hồ Chí Minh
('HUYN06', N'Quận 1', 'T02', 0),
('HUYN07', N'Quận 5', 'T02', 0),
('HUYN08', N'Quận Bình Thạnh', 'T02', 0),
('HUYN09', N'Quận 8', 'T02', 0),
('HUYN10', N'Tp Thủ Đức', 'T02', 0),

-- Hải Phòng
('HUYN11', N'Kiến An', 'T03', 0),
('HUYN12', N'Lê Chân', 'T03', 0),
('HUYN13', N'Ngô Quyền', 'T03', 0),
('HUYN14', N'An Dương', 'T03', 0),
('HUYN15', N'Hồng Bàng', 'T03', 0),

-- Đà Nẵng
('HUYN16', N'Hải Châu', 'T04', 0),
('HUYN17', N'Liên Chiểu', 'T04', 0),
('HUYN18', N'Ngũ Hành Sơn', 'T04', 0),
('HUYN19', N'Sơn Trà', 'T04', 0),
('HUYN20', N'Cẩm Lệ', 'T04', 0),

-- Thái Bình
('HUYN21', N'Đông Hưng', 'T05', 0),
('HUYN22', N'Hưng Hà', 'T05', 0),
('HUYN23', N'Tiền Hải', 'T05', 0),
('HUYN24', N'Kiến Xương', 'T05', 0),
('HUYN25', N'Vũ Thư', 'T05', 0),

-- Bình Dương
('HUYN26', N'Thuận An', 'T06', 0),
('HUYN27', N'Dĩ An', 'T06', 0),
('HUYN28', N'Tân Uyên', 'T06', 0),
('HUYN29', N'Thủ Dầu Một', 'T06', 0),
('HUYN30', N'Bến Cát', 'T06', 0),

-- Đắk Lắk
('HUYN31', N'Buôn Ma Thuột', 'T07', 0),
('HUYN32', N'Krông Búk', 'T07', 1),
('HUYN33', N'Ea Hleo', 'T07', 1),
('HUYN34', N'Buôn Đôn', 'T07', 1),
('HUYN35', N'Lắk', 'T07', 1),

-- Long An
('HUYN36', N'Cần Giuộc', 'T08', 0),
('HUYN37', N'Châu Thành', 'T08', 0),
('HUYN38', N'Đức Hòa', 'T08', 0),
('HUYN39', N'Cần Đước', 'T08', 0),
('HUYN40', N'Bến Lức', 'T08', 0),

-- Bình Định
('HUYN41', N'Tuy Phước', 'T09', 0),
('HUYN42', N'Hoài Ân', 'T09', 0),
('HUYN43', N'Phù Cát', 'T09', 0),
('HUYN44', N'Tp Quy Nhơn', 'T09', 0),
('HUYN45', N'Vân Canh', 'T09', 0),

-- Quảng Trị
('HUYN46', N'Đông Hà', 'T10', 0),
('HUYN47', N'Hải Lăng', 'T10', 0),
('HUYN48', N'Triệu Phong', 'T10', 0),
('HUYN49', N'Đakrông', 'T10', 0),
('HUYN50', N'Vĩnh Linh', 'T10', 0);

-- Table KHOA
INSERT INTO KHOA (MaKhoa, TenKhoa) VALUES
(, N'Khoa học máy tính'),
(, N'Khoa học và Kỹ thuật thông tin'),
(, N'Kỹ thuật máy tính'),
(, N'Công nghệ phần mềm'),
(, N'Hệ thống thông tin'),
(, N'Mạng máy tính và truyền thông');

--Table NGANHHOC
INSERT INTO NGANHHOC (MaNH, TenNH, MaKhoa) VALUES
(, N'Khoa học Máy tính', ),
(, N'Trí tuệ nhân tạo', ),

(, N'Công nghệ Thông tin', ),
(, N'Khoa học Dữ liệu', ),

(, N'Kỹ thuật Máy tính', ),

(, N'Kỹ thuật Phần mềm', ),

(, N'Hệ thống Thông tin', ),
(, N'Thương mại điện tử', ),

(, N'Mạng máy tính và Truyền thông dữ liệu', ),
(, N'An toàn Thông tin', );

--Table LOAIMON
INSERT INTO LOAIMON (MaLoaiMon, TenLoaiMon, SoTietMotTC, SoTienMotTC) VALUES
(, N'Lý thuyết', 15, 27000),
(, N'Thực hành', 30, 37000);
