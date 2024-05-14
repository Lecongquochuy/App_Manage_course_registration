using System;
using System.Collections.Generic;

namespace BaseLibrary.Entities;

public partial class Monhoc
{
    public string MaMh { get; set; } = null!;

    public string? TenMh { get; set; }

    public int? SoTiet { get; set; }

    public int? SoTc { get; set; }

    public string MaLoaiMon { get; set; } = null!;

    public virtual ICollection<CtNganh> CtNganhs { get; set; } = new List<CtNganh>();

    public virtual ICollection<Dsmhmo> Dsmhmos { get; set; } = new List<Dsmhmo>();

    public virtual Loaimon MaLoaiMonNavigation { get; set; } = null!;
}
