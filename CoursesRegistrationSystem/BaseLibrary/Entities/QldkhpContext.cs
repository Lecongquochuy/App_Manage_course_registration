
using Microsoft.EntityFrameworkCore;


namespace BaseLibrary.Data
{

}

public partial class QldkhpContext : DbContext
{
    public QldkhpContext()
    {
    }

    public QldkhpContext(DbContextOptions<QldkhpContext> options)
        : base(options)
    {
    }

    public virtual DbSet<CtNganh> CtNganhs { get; set; }

    public virtual DbSet<Dsmhmo> Dsmhmos { get; set; }

    public virtual DbSet<Dtuutien> Dtuutiens { get; set; }

    public virtual DbSet<HockyNamhoc> HockyNamhocs { get; set; }

    public virtual DbSet<Huyen> Huyens { get; set; }

    public virtual DbSet<Khoa> Khoas { get; set; }

    public virtual DbSet<Loaimon> Loaimons { get; set; }

    public virtual DbSet<Monhoc> Monhocs { get; set; }

    public virtual DbSet<Nganhhoc> Nganhhocs { get; set; }

    public virtual DbSet<Phieudkhp> Phieudkhps { get; set; }

    public virtual DbSet<Phieuthuhp> Phieuthuhps { get; set; }

    public virtual DbSet<Sinhvien> Sinhviens { get; set; }

    public virtual DbSet<Tinh> Tinhs { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see https://go.microsoft.com/fwlink/?LinkId=723263.
        => optionsBuilder.UseSqlServer("Data Source=DESKTOP-KMNTRAE\\SQLEXPRESS;Initial Catalog=QLDKHP;Integrated Security=True;Trust Server Certificate=True");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<CtNganh>(entity =>
        {
            entity.HasKey(e => new { e.MaNh, e.MaMh }).HasName("PK__CT_NGANH__A5578AC5F455C19E");

            entity.ToTable("CT_NGANH");

            entity.Property(e => e.MaNh)
                .HasMaxLength(6)
                .IsUnicode(false)
                .HasColumnName("MaNH");
            entity.Property(e => e.MaMh)
                .HasMaxLength(5)
                .IsUnicode(false)
                .HasColumnName("MaMH");
            entity.Property(e => e.GhiChu).HasMaxLength(50);

            entity.HasOne(d => d.MaMhNavigation).WithMany(p => p.CtNganhs)
                .HasForeignKey(d => d.MaMh)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__CT_NGANH__MaMH__5FB337D6");

            entity.HasOne(d => d.MaNhNavigation).WithMany(p => p.CtNganhs)
                .HasForeignKey(d => d.MaNh)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__CT_NGANH__MaNH__5EBF139D");
        });

        modelBuilder.Entity<Dsmhmo>(entity =>
        {
            entity.HasKey(e => e.MaMo).HasName("PK__DSMHMO__2725DF32AAB984A2");

            entity.ToTable("DSMHMO", tb => tb.HasTrigger("TRIG_DL_DSMHMO"));

            entity.HasIndex(e => new { e.MaHknh, e.MaMh }, "UNQ_DSMM_HKNH_MH").IsUnique();

            entity.Property(e => e.MaMo)
                .HasMaxLength(8)
                .IsUnicode(false);
            entity.Property(e => e.MaHknh)
                .HasMaxLength(4)
                .IsUnicode(false)
                .HasColumnName("MaHKNH");
            entity.Property(e => e.MaMh)
                .HasMaxLength(5)
                .IsUnicode(false)
                .HasColumnName("MaMH");

            entity.HasOne(d => d.MaHknhNavigation).WithMany(p => p.Dsmhmos)
                .HasForeignKey(d => d.MaHknh)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__DSMHMO__MaHKNH__68487DD7");

            entity.HasOne(d => d.MaMhNavigation).WithMany(p => p.Dsmhmos)
                .HasForeignKey(d => d.MaMh)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__DSMHMO__MaMH__693CA210");
        });

        modelBuilder.Entity<Dtuutien>(entity =>
        {
            entity.HasKey(e => e.MaDt).HasName("PK__DTUUTIEN__2725865543C6FBB7");

            entity.ToTable("DTUUTIEN", tb => tb.HasTrigger("TRIG_UD_DTUUTIEN_TINHSOTIENPHAIDONG"));

            entity.Property(e => e.MaDt)
                .HasMaxLength(5)
                .IsUnicode(false)
                .HasColumnName("MaDT");
            entity.Property(e => e.TenDt)
                .HasMaxLength(20)
                .HasColumnName("TenDT");
        });

        modelBuilder.Entity<HockyNamhoc>(entity =>
        {
            entity.HasKey(e => e.MaHknh).HasName("PK__HOCKY_NA__1B2F905092BDF39A");

            entity.ToTable("HOCKY_NAMHOC");

            entity.Property(e => e.MaHknh)
                .HasMaxLength(4)
                .IsUnicode(false)
                .HasColumnName("MaHKNH");
            entity.Property(e => e.ThoiHanDongHocPhi).HasColumnType("smalldatetime");

            entity.HasMany(d => d.Mssvs).WithMany(p => p.MaHknhs)
                .UsingEntity<Dictionary<string, object>>(
                    "Bcchuadonghp",
                    r => r.HasOne<Sinhvien>().WithMany()
                        .HasForeignKey("Mssv")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("FK__BCCHUADONG__MSSV__73BA3083"),
                    l => l.HasOne<HockyNamhoc>().WithMany()
                        .HasForeignKey("MaHknh")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("FK__BCCHUADON__MaHKN__72C60C4A"),
                    j =>
                    {
                        j.HasKey("MaHknh", "Mssv").HasName("PK__BCCHUADO__9DE4AB2F30900623");
                        j.ToTable("BCCHUADONGHP");
                        j.IndexerProperty<string>("MaHknh")
                            .HasMaxLength(4)
                            .IsUnicode(false)
                            .HasColumnName("MaHKNH");
                        j.IndexerProperty<string>("Mssv")
                            .HasMaxLength(8)
                            .IsUnicode(false)
                            .HasColumnName("MSSV");
                    });
        });

        modelBuilder.Entity<Huyen>(entity =>
        {
            entity.HasKey(e => e.MaHuyen).HasName("PK__HUYEN__0384275153E3CF69");

            entity.ToTable("HUYEN");

            entity.Property(e => e.MaHuyen)
                .HasMaxLength(6)
                .IsUnicode(false);
            entity.Property(e => e.MaTinh)
                .HasMaxLength(3)
                .IsUnicode(false);
            entity.Property(e => e.TenHuyen).HasMaxLength(20);

            entity.HasOne(d => d.MaTinhNavigation).WithMany(p => p.Huyens)
                .HasForeignKey(d => d.MaTinh)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__HUYEN__MaTinh__4BAC3F29");
        });

        modelBuilder.Entity<Khoa>(entity =>
        {
            entity.HasKey(e => e.MaKhoa).HasName("PK__KHOA__65390405C1553D37");

            entity.ToTable("KHOA");

            entity.Property(e => e.MaKhoa)
                .HasMaxLength(3)
                .IsUnicode(false);
            entity.Property(e => e.TenKhoa).HasMaxLength(50);
        });

        modelBuilder.Entity<Loaimon>(entity =>
        {
            entity.HasKey(e => e.MaLoaiMon).HasName("PK__LOAIMON__612C5AE49B632A52");

            entity.ToTable("LOAIMON");

            entity.Property(e => e.MaLoaiMon)
                .HasMaxLength(3)
                .IsUnicode(false);
            entity.Property(e => e.SoTienMotTc)
                .HasColumnType("money")
                .HasColumnName("SoTienMotTC");
            entity.Property(e => e.SoTietMotTc).HasColumnName("SoTietMotTC");
            entity.Property(e => e.TenLoaiMon).HasMaxLength(20);
        });

        modelBuilder.Entity<Monhoc>(entity =>
        {
            entity.HasKey(e => e.MaMh).HasName("PK__MONHOC__2725DFD97C8A373C");

            entity.ToTable("MONHOC", tb =>
                {
                    tb.HasTrigger("TRIG_DL_MONHOC");
                    tb.HasTrigger("TRIG_ISUD_MONHOC_TINHSOTC");
                });

            entity.Property(e => e.MaMh)
                .HasMaxLength(5)
                .IsUnicode(false)
                .HasColumnName("MaMH");
            entity.Property(e => e.MaLoaiMon)
                .HasMaxLength(3)
                .IsUnicode(false);
            entity.Property(e => e.SoTc).HasColumnName("SoTC");
            entity.Property(e => e.TenMh)
                .HasMaxLength(50)
                .HasColumnName("TenMH");

            entity.HasOne(d => d.MaLoaiMonNavigation).WithMany(p => p.Monhocs)
                .HasForeignKey(d => d.MaLoaiMon)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__MONHOC__MaLoaiMo__5BE2A6F2");
        });

        modelBuilder.Entity<Nganhhoc>(entity =>
        {
            entity.HasKey(e => e.MaNh).HasName("PK__NGANHHOC__2725D738384D090D");

            entity.ToTable("NGANHHOC");

            entity.Property(e => e.MaNh)
                .HasMaxLength(6)
                .IsUnicode(false)
                .HasColumnName("MaNH");
            entity.Property(e => e.MaKhoa)
                .HasMaxLength(3)
                .IsUnicode(false);
            entity.Property(e => e.TenNh)
                .HasMaxLength(50)
                .HasColumnName("TenNH");

            entity.HasOne(d => d.MaKhoaNavigation).WithMany(p => p.Nganhhocs)
                .HasForeignKey(d => d.MaKhoa)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__NGANHHOC__MaKhoa__52593CB8");
        });

        modelBuilder.Entity<Phieudkhp>(entity =>
        {
            entity.HasKey(e => e.MaPhieuDkhp).HasName("PK__PHIEUDKH__9936BA2E1A8F1335");

            entity.ToTable("PHIEUDKHP", tb =>
                {
                    tb.HasTrigger("TRIG_DL_PHIEUDKHP");
                    tb.HasTrigger("TRIG_ISUD_PHIEUDKHP_THOIHANDONGHOCPHI");
                    tb.HasTrigger("TRIG_IS_PHIEUDKHP_TONGTIEN");
                    tb.HasTrigger("TRIG_UD_PHIEUDKHP_CAPNHATDSCHUADONGHP");
                    tb.HasTrigger("TRIG_UD_PHIEUDKHP_TINHSOTIENPHAIDONG");
                });

            entity.HasIndex(e => new { e.Mssv, e.MaHknh }, "UNQ_PDK_SV_HKNH").IsUnique();

            entity.Property(e => e.MaPhieuDkhp)
                .HasMaxLength(8)
                .IsUnicode(false)
                .HasColumnName("MaPhieuDKHP");
            entity.Property(e => e.MaHknh)
                .HasMaxLength(4)
                .IsUnicode(false)
                .HasColumnName("MaHKNH");
            entity.Property(e => e.Mssv)
                .HasMaxLength(8)
                .IsUnicode(false)
                .HasColumnName("MSSV");
            entity.Property(e => e.NgayLap).HasColumnType("smalldatetime");
            entity.Property(e => e.SoTienConLai).HasColumnType("money");
            entity.Property(e => e.SoTienDaDong).HasColumnType("money");
            entity.Property(e => e.SoTienPhaiDong).HasColumnType("money");
            entity.Property(e => e.TongTien).HasColumnType("money");

            entity.HasOne(d => d.MaHknhNavigation).WithMany(p => p.Phieudkhps)
                .HasForeignKey(d => d.MaHknh)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__PHIEUDKHP__MaHKN__656C112C");

            entity.HasOne(d => d.MssvNavigation).WithMany(p => p.Phieudkhps)
                .HasForeignKey(d => d.Mssv)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__PHIEUDKHP__MSSV__6477ECF3");

            entity.HasMany(d => d.MaMos).WithMany(p => p.MaPhieuDkhps)
                .UsingEntity<Dictionary<string, object>>(
                    "CtDkhp",
                    r => r.HasOne<Dsmhmo>().WithMany()
                        .HasForeignKey("MaMo")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("FK__CT_DKHP__MaMo__6D0D32F4"),
                    l => l.HasOne<Phieudkhp>().WithMany()
                        .HasForeignKey("MaPhieuDkhp")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("FK__CT_DKHP__MaPhieu__6C190EBB"),
                    j =>
                    {
                        j.HasKey("MaPhieuDkhp", "MaMo").HasName("PK__CT_DKHP__AB44E7DD3BD49143");
                        j.ToTable("CT_DKHP", tb =>
                            {
                                tb.HasTrigger("TRIG_ISUDDL_CT_DKHP_TINHTONGTIEN");
                                tb.HasTrigger("TRIG_ISUD_CT_DKHP_MAHKNH");
                            });
                        j.IndexerProperty<string>("MaPhieuDkhp")
                            .HasMaxLength(8)
                            .IsUnicode(false)
                            .HasColumnName("MaPhieuDKHP");
                        j.IndexerProperty<string>("MaMo")
                            .HasMaxLength(8)
                            .IsUnicode(false);
                    });
        });

        modelBuilder.Entity<Phieuthuhp>(entity =>
        {
            entity.HasKey(e => e.MaPhieuThu).HasName("PK__PHIEUTHU__1D8B9C69F43F1140");

            entity.ToTable("PHIEUTHUHP", tb =>
                {
                    tb.HasTrigger("TRIG_ISUDDL_PHIEUTHUHP_TINHSTDADONGVASTCONLAI");
                    tb.HasTrigger("TRIG_ISUD_PHIEUTHUHP_SOTIENTHU_SOTIENCONLAI");
                    tb.HasTrigger("TRIG_ISUD_PHIEUTHUHP_THOIHANDONGHOCPHI");
                    tb.HasTrigger("TRIG_ISUD_PHIEUTHU_NGAYLAP");
                });

            entity.Property(e => e.MaPhieuThu)
                .HasMaxLength(8)
                .IsUnicode(false);
            entity.Property(e => e.MaPhieuDkhp)
                .HasMaxLength(8)
                .IsUnicode(false)
                .HasColumnName("MaPhieuDKHP");
            entity.Property(e => e.NgayLap).HasColumnType("smalldatetime");
            entity.Property(e => e.SoTienThu).HasColumnType("money");

            entity.HasOne(d => d.MaPhieuDkhpNavigation).WithMany(p => p.Phieuthuhps)
                .HasForeignKey(d => d.MaPhieuDkhp)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__PHIEUTHUH__MaPhi__6FE99F9F");
        });

        modelBuilder.Entity<Sinhvien>(entity =>
        {
            entity.HasKey(e => e.Mssv).HasName("PK__SINHVIEN__6CB3B7F93C028D87");

            entity.ToTable("SINHVIEN", tb => tb.HasTrigger("TRIG_DL_SINHVIEN"));

            entity.Property(e => e.Mssv)
                .HasMaxLength(8)
                .IsUnicode(false)
                .HasColumnName("MSSV");
            entity.Property(e => e.GioiTinh).HasMaxLength(3);
            entity.Property(e => e.HoTen).HasMaxLength(30);
            entity.Property(e => e.MaDt)
                .HasMaxLength(5)
                .IsUnicode(false)
                .HasColumnName("MaDT");
            entity.Property(e => e.MaHuyen)
                .HasMaxLength(6)
                .IsUnicode(false);
            entity.Property(e => e.MaNh)
                .HasMaxLength(6)
                .IsUnicode(false)
                .HasColumnName("MaNH");
            entity.Property(e => e.NgaySinh).HasColumnType("smalldatetime");

            entity.HasOne(d => d.MaDtNavigation).WithMany(p => p.Sinhviens)
                .HasForeignKey(d => d.MaDt)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__SINHVIEN__MaDT__5629CD9C");

            entity.HasOne(d => d.MaHuyenNavigation).WithMany(p => p.Sinhviens)
                .HasForeignKey(d => d.MaHuyen)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__SINHVIEN__MaHuye__5535A963");

            entity.HasOne(d => d.MaNhNavigation).WithMany(p => p.Sinhviens)
                .HasForeignKey(d => d.MaNh)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__SINHVIEN__MaNH__571DF1D5");
        });

        modelBuilder.Entity<Tinh>(entity =>
        {
            entity.HasKey(e => e.MaTinh).HasName("PK__TINH__4CC54480A4A7C411");

            entity.ToTable("TINH");

            entity.Property(e => e.MaTinh)
                .HasMaxLength(3)
                .IsUnicode(false);
            entity.Property(e => e.TenTinh).HasMaxLength(20);
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
