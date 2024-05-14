using System;
using System.Collections.Generic;

namespace BaseLibrary.Entities;

public partial class Phieuthuhp
{
    public string MaPhieuThu { get; set; } = null!;

    public decimal? SoTienThu { get; set; }

    public DateTime? NgayLap { get; set; }

    public string MaPhieuDkhp { get; set; } = null!;

    public virtual Phieudkhp MaPhieuDkhpNavigation { get; set; } = null!;
}
