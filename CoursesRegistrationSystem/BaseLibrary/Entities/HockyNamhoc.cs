using System;
using System.Collections.Generic;

namespace BaseLibrary.Entities;

public partial class HockyNamhoc
{
    public string MaHknh { get; set; } = null!;

    public int? HocKy { get; set; }

    public int? NamHoc { get; set; }

    public DateTime? ThoiHanDongHocPhi { get; set; }

    public virtual ICollection<Dsmhmo> Dsmhmos { get; set; } = new List<Dsmhmo>();

    public virtual ICollection<Phieudkhp> Phieudkhps { get; set; } = new List<Phieudkhp>();

    public virtual ICollection<Sinhvien> Mssvs { get; set; } = new List<Sinhvien>();
}
