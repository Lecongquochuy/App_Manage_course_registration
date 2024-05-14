using System;
using System.Collections.Generic;

namespace BaseLibrary.Entities;

public partial class Sinhvien
{
    public string Mssv { get; set; } = null!;

    public string? HoTen { get; set; }

    public DateTime? NgaySinh { get; set; }

    public string? GioiTinh { get; set; }

    public string MaHuyen { get; set; } = null!;

    public string MaDt { get; set; } = null!;

    public string MaNh { get; set; } = null!;

    public virtual Dtuutien MaDtNavigation { get; set; } = null!;

    public virtual Huyen MaHuyenNavigation { get; set; } = null!;

    public virtual Nganhhoc MaNhNavigation { get; set; } = null!;

    public virtual ICollection<Phieudkhp> Phieudkhps { get; set; } = new List<Phieudkhp>();

    public virtual ICollection<HockyNamhoc> MaHknhs { get; set; } = new List<HockyNamhoc>();
}
