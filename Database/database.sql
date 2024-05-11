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

--Table DTUUTIEN (0/10)
INSERT INTO DTUUTIEN (MaDT, TenDT, TiLeGiam) VALUES
('DT001', N'Không đối tượng', 0),
('DT002', N'Con liệt sĩ', 0.8),
('DT003', N'Con thương binh', 0.5),
('DT004', N'Vùng sâu vùng xa', 0.3),
('', N'', );

-- Table KHOA (6/5)
INSERT INTO KHOA (MaKhoa, TenKhoa) VALUES
('K01', N'Khoa học máy tính'),
('K02', N'Khoa học và Kỹ thuật thông tin'),
('K03', N'Kỹ thuật máy tính'),
('K04', N'Công nghệ phần mềm'),
('K05', N'Hệ thống thông tin'),
('K06', N'Mạng máy tính và truyền thông');

--Table NGANHHOC (10/10)
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

--Table SINHVIEN (0/50+)
SET DATEFORMAT DMY
INSERT INTO SINHVIEN (MSSV, HoTen, NgaySinh, GioiTinh, MaHuyen, MaDT, MaNH) VALUES
-- Random
-- Ngay 1-31 (T4, 6, 9, 11: 30N; T2: 28, 29N)
-- Thang 1-12
-- MaHuyen T1-10 H1-5
-- MaDT 2-10
-- MaNH K1-6 N1-2 (K3, 4: N1)
('21522145', N'Lê Công Quốc Huy', '4-2-2003', N'Nam', 'T05H01', 'DT001', 'K02N01'),
('21522146', N'Lê Gia Huy', '10-1-2003', N'Nam', 'T06H05', 'DT001', 'K02N01'),
('21522141', N'Hoàng Gia Huy', '7-3-2003', N'Nam', 'T09H05', 'DT001', 'K02N01'),
('21522676', N'Nguyễn Thành Tín', '2-10-2003', N'Nam', 'T08H04', 'DT001', 'K02N01'),
('21521667', N'Phan Vỹ Văn', '7-6-2003', N'Nam', 'T09H03', 'DT001', 'K02N01'),
('20521062', N'Dương Thị Ngọc Anh', '6-4-2002', N'Nữ', 'T01H03', 'DT001', 'K03N01'),
('20521061', N'Đỗ Trần Mai Anh', '31-5-2002', N'Nữ', 'T03H04', 'DT001', 'K03N01'),
('21520138', N'Lê Nguyễn Nhật Anh', '16-8-2003', N'Nữ', 'T10H04', 'DT001', 'K01N01'),
('20520900', N'Nguyễn Ngọc Mai Khanh', '11-11-2002', N'Nữ', 'T01H03', 'DT001', 'K06N02'),
('21522315', N'Nguyễn Thị Cẩm Ly', '14-2-2003', N'Nữ', 'T09H01', 'DT001', 'K02N01'),

('21521140', N'Nguyễn Tuệ Minh', '25-11-2003', N'Nữ', 'T02H03', 'DT001', 'K04N01'),
('21521144', N'Trần Tuyết Minh', '22-5-2003', N'Nữ', 'T03H05', 'DT001', 'K04N01'),
('21521174', N'Nguyễn Thị Kim Ngân', '8-5-2003', N'Nữ', 'T08H05', 'DT001', 'K05N01'),
('21522884', N'Nguyễn Bích Phượng', '10-7-2003', N'Nữ', 'T02H04', 'DT001', 'K06N01'),
('21521486', N'Bùi Thị Anh Thư', '16-10-2003', N'Nữ', 'T07H03', 'DT001', 'K06N01'),
('21522698', N'Phan Huỳnh Thiên Trang', '15-2-2003', N'Nữ', 'T04H02', 'DT001', 'K01N01'),
('21521804', N'Hồ Vũ An', '6-10-2003', N'Nam', 'T03H05', 'DT001', 'K05N01'),
('21521846', N'Huỳnh Hải Băng', '1-7-2003', N'Nam', 'T10H05', 'DT001', 'K01N02'),
('21521156', N'Đoàn Lê Giang Nam', '26-10-2003', N'Nam', 'T04H05', 'DT001', 'K02N02'),
('21521178', N'Trần Thanh Nghị', '29-8-2003', N'Nam', 'T09H05', 'DT001', 'K04N01'),

('21521180', N'Lê Đức Nghĩa', '18-1-2003', N'Nam', 'T04H04', 'DT001', 'K02N02'),
('21521183', N'Nguyễn Thành Nghĩa', '6-8-2003', N'Nam', 'T02H05', 'DT001', 'K04N01'),
('21521201', N'Nguyễn Đỗ Đức Nguyên', '27-3-2003', N'Nam', 'T04H04', 'DT001', 'K05N02'),
('21521226', N'Nguyễn Minh Nhật', '9-4-2003', N'Nam', 'T10H01', 'DT001', 'K02N01'),
('21521268', N'Nguyễn Thành Phi', '21-9-2003', N'Nam', 'T09H05', 'DT001', 'K01N02'),
('21521271', N'Lê Thanh Phong', '11-10-2003', N'Nam', 'T10H03', 'DT001', 'K01N02'),
('21521323', N'Dương Uy Quan', '17-4-2003', N'Nam', 'T05H02', 'DT001', 'K05N02'),
('21521595', N'Nguyễn Thành Trung', '21-11-2003', N'Nam', 'T03H04', 'DT001', 'K06N01'),
('21522747', N'Trịnh Tuấn Tú', '15-6-2003', N'Nam', 'T09H04', 'DT001', 'K03N01'),
('21522755', N'Nguyễn Mạnh Tuấn', '4-3-2003', N'Nam', 'T09H01', 'DT001', 'K04N01'),

('21520389', N'Phan Cả Phát', '23-11-2003', N'Nam', 'T01H01', 'DT001', 'K01N01'),
('21522496', N'Nguyễn Minh Quân', '23-7-2003', N'Nam', 'T09H01', 'DT001', 'K04N01'),
('21522515', N'Nguyễn Việt Quang', '30-10-2003', N'Nam', 'T07H04', 'DT001', 'K05N02'),
('21522528', N'Dương Văn Quy', '10-1-2003', N'Nam', 'T03H05', 'DT001', 'K01N01'),
('21522544', N'Nguyễn Ngọc Thanh Sang', '15-4-2003', N'Nam', 'T08H03', 'DT001', 'K01N01'),
('21522556', N'Phạm Thanh Sơn', '16-11-2003', N'Nam', 'T10H01', 'DT001', 'K01N01'),
('21521476', N'Vũ Ngọc Trường Thịnh', '18-1-2003', N'Nam', 'T02H05', 'DT001', 'K03N01'),
('21522681', N'Phạm Đăng Tỉnh', '7-9-2003', N'Nam', 'T09H01', 'DT001', 'K01N01'),
('21522712', N'Phạm Minh Triết', '3-1-2003', N'Nam', 'T10H05', 'DT001', 'K03N01'),
('21522732', N'Lê Quang Trường', '9-5-2003', N'Nam', 'T03H03', 'DT001', 'K02N02'),

('21522762', N'Trần Anh Tuấn', '14-1-2003', N'Nam', 'T07H01', 'DT001', 'K03N01')
('21522885', N'Phan Thị Cát Tường', '26-6-2003', N'Nữ', 'T07H03', 'DT001', 'K04N01')
('21522536', N'Nguyễn Phan Trúc Quỳnh', '30-5-2003', N'Nữ', 'T06H02', 'DT001', 'K04N01')
('21522357', N'Lê Hải Nam', '22-3-2003', N'Nam', 'T05H05', 'DT001', 'K04N01')
('21521108', N'Nguyễn Minh Lý', '22-7-2003', N'Nam', 'T03H02', 'DT001', 'K02N01')
('21522276', N'Nguyễn Cao Lãm', '17-11-2003', N'Nam', 'T01H04', 'DT001', 'K06N01')
('21522168', N'Trần Minh Huy', '30-7-2003', N'Nam', 'T08H01', 'DT001', 'K04N01')
('21522037', N'Trần Thị Hải', '20-10-2003', N'Nữ', 'T01H01', 'DT001', 'K02N02')
('21521029', N'Tô Quốc Kiện', '11-3-2003', N'Nam', 'T01H03', 'DT001', 'K03N01')
('21522055', N'Phan Công Hậu', '25-7-2003', N'Nam', 'T10H02', 'DT001', 'K06N01');

--Table LOAIMON (2/2)
INSERT INTO LOAIMON (MaLoaiMon, TenLoaiMon, SoTietMotTC, SoTienMotTC) VALUES
('LM1', N'Lý thuyết', 15, 27000),
('LM2', N'Thực hành', 30, 37000);

--Table MONHOC (0/50)
INSERT INTO MONHOC (MaMH, TenMH, SoTiet, MaLoaiMon) VALUES
('MH001', N'Tư tưởng Hồ Chí Minh', 30, 'LM1'),
('MH002', N'Triết học Mác – Lênin', 45, 'LM1'),
('MH003', N'Kinh tế chính trị Mác – Lênin', 30, 'LM1'),
('MH004', N'Chủ nghĩa xã hội khoa học', 30, 'LM1'),
('MH005', N'Lịch sử Đảng Cộng sản Việt Nam', 30, 'LM1'),
('MH006', N'Giải tích', 60, 'LM1'),
('MH007', N'Đại số tuyến tính', 45, 'LM1'),
('MH008', N'Cấu trúc rời rạc', 60, 'LM1'),
('MH009', N'Xác suất thống kê', 45, 'LM1'),
('MH010', N'Nhập môn Lập trình', 60, 'LM1'),
('MH011', N'Kỹ năng nghề nghiệp', 30, 'LM1'),
('MH012', N'Pháp luật đại cương', 30, 'LM1'),
('MH013', N'Văn hóa doanh nghiệp Nhật Bản', 30, 'LM1'),
('MH014', N'Tiếng Nhật 1', 60, 'LM1'),
('MH015', N'Tiếng Nhật 2', 60, 'LM1'),
('MH016', N'Tiếng Nhật 3', 60, 'LM1'),
('MH017', N'Tiếng Nhật 4', 60, 'LM1'),
('MH018', N'Tiếng Nhật 5', 45, 'LM1'),
('MH019', N'Tiếng Nhật 6', 45, 'LM1'),
('MH020', N'Tiếng Nhật 7', 45, 'LM1'),
('MH021', N'Tiếng Nhật 8', 45, 'LM1'),
('MH022', N'Lập trình hướng đối tượng', 45, 'LM1'),
('MH023', N'Lập trình hướng đối tượng', 30, 'LM2'),
('MH024', N'Cấu trúc dữ liệu và giải thuật', 45, 'LM1'),
('MH025', N'Cơ sở dữ liệu', 45, 'LM1'),
('MH026', N'Nhập môn mạng máy tính', 45, 'LM1'),
('MH027', N'Nhập môn mạng máy tính', 30, 'LM2'),
('MH028', N'Tổ chức và cấu trúc máy tính II', 45, 'LM1'),
('MH029', N'Tổ chức và cấu trúc máy tính II', 30, 'LM2'),
('MH030', N'Hệ điều hành', 45, 'LM1'),
('MH031', N'Hệ điều hành', 30, 'LM2'),
('MH032', N'Giới thiệu ngành Công nghệ Thông tin', 15, 'LM1'),
('MH033', N'Cơ sở hạ tầng công nghệ thông tin', 45, 'LM1'),
('MH034', N'Cơ sở hạ tầng công nghệ thông tin', 30, 'LM2'),
('MH035', N'Quản lý thông tin', 45, 'LM1'),
('MH036', N'Quản lý thông tin', 30, 'LM2'),
('MH037', N'Internet và công nghệ Web', 45, 'LM1'),
('MH038', N'Internet và công nghệ Web', 30, 'LM2'),
('MH039', N'Thiết kế giao diện người dùng', 45, 'LM1'),
('MH040', N'Thiết kế giao diện người dùng', 30, 'LM2'),
('MH041', N'Nhập môn đảm bảo và an ninh thông tin', 45, 'LM1'),
('MH042', N'Nhập môn đảm bảo và an ninh thông tin', 30, 'LM2'),
('MH043', N'Nhập môn công nghệ phần mềm', 45, 'LM1'),
('MH044', N'Nhập môn công nghệ phần mềm', 30, 'LM2'),
('MH045', N'Điện toán đám mây', 45, 'LM1'),
('MH046', N'Các chủ đề toán học cho KHDL', 45, 'LM1'),
('MH047', N'Học máy thống kê', 45, 'LM1'),
('MH048', N'Học máy thống kê', 30, 'LM2'),
('MH049', N'Xử lý dữ liệu lớn', 45, 'LM1'),
('MH050', N'Xử lý dữ liệu lớn', 30, 'LM2');


--Table HOCKY_NAMHOC (12/12)
SET DATEFORMAT DMY
INSERT INTO HOCKY_NAMHOC (MaHKNH, HocKy, NamHoc, ThoiHanDongHocPhi) VALUES
('2001', 1, '2020', '29-8-2020'),
('2002', 2, '2020', '19-2-2021'),
('2003', 3, '2020', '10-7-2021'),
('2101', 1, '2021', '21-8-2021'),
('2102', 2, '2021', '8-2-2022'),
('2103', 3, '2021', '12-7-2022'),
('2201', 1, '2022', '28-8-2022'),
('2202', 2, '2022', '12-2-2023'),
('2203', 3, '2022', '26-7-2023'),
('2301', 1, '2023', '7-9-2023'),
('2302', 2, '2023', '31-1-2024'),
('2303', 3, '2023', '3-7-2024');

--Table BCCHUADONGHP (0/60)
INSERT INTO BCCHUADONGHP (MaHKNH, MSSV) VALUES
('', ''),
('', '');
