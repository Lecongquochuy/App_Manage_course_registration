using System;
using System.Collections.Generic;

namespace BaseLibrary.Entities;

public partial class Phieudkhp
{
    public string MaPhieuDkhp { get; set; } = null!;

    public DateTime? NgayLap { get; set; }

    public decimal? TongTien { get; set; }

    public decimal? SoTienPhaiDong { get; set; }

    public decimal? SoTienDaDong { get; set; }

    public decimal? SoTienConLai { get; set; }

    public string Mssv { get; set; } = null!;

    public string MaHknh { get; set; } = null!;

    public virtual HockyNamhoc MaHknhNavigation { get; set; } = null!;

    public virtual Sinhvien MssvNavigation { get; set; } = null!;

    public virtual ICollection<Phieuthuhp> Phieuthuhps { get; set; } = new List<Phieuthuhp>();

    public virtual ICollection<Dsmhmo> MaMos { get; set; } = new List<Dsmhmo>();
}
