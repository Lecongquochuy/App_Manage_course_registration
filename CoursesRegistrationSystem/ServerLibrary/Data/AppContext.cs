
using BaseLibrary.Entities;
using Microsoft.EntityFrameworkCore;


namespace ServerLibrary.Data
{
    public class AppContext(DbContextOptions<AppContext> options) : DbContext(options)
    {
        public DbSet<CtNganh> CtNganhs { get; set; }

        public DbSet<Dsmhmo> Dsmhmos { get; set; }

        public DbSet<Dtuutien> Dtuutiens { get; set; }

        public DbSet<HockyNamhoc> HockyNamhocs { get; set; }

        public DbSet<Huyen> Huyens { get; set; }

        public DbSet<Khoa> Khoas { get; set; }

        public DbSet<Loaimon> Loaimons { get; set; }

        public DbSet<Monhoc> Monhocs { get; set; }

        public DbSet<Nganhhoc> Nganhhocs { get; set; }

        public DbSet<Phieudkhp> Phieudkhps { get; set; }

        public DbSet<Phieuthuhp> Phieuthuhps { get; set; }

        public DbSet<Sinhvien> Sinhviens { get; set; }

        public DbSet<Tinh> Tinhs { get; set; }
    }
}

