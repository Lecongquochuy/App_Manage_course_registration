using System;
using System.Collections.Generic;

namespace BaseLibrary.Entities;

public partial class Loaimon
{
    public string MaLoaiMon { get; set; } = null!;

    public string? TenLoaiMon { get; set; }

    public int? SoTietMotTc { get; set; }

    public decimal? SoTienMotTc { get; set; }

    public virtual ICollection<Monhoc> Monhocs { get; set; } = new List<Monhoc>();
}
