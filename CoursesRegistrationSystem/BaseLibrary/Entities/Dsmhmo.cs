using System;
using System.Collections.Generic;

namespace BaseLibrary.Entities;

public partial class Dsmhmo
{
    public string MaMo { get; set; } = null!;

    public string MaHknh { get; set; } = null!;

    public string MaMh { get; set; } = null!;

    public virtual HockyNamhoc MaHknhNavigation { get; set; } = null!;

    public virtual Monhoc MaMhNavigation { get; set; } = null!;

    public virtual ICollection<Phieudkhp> MaPhieuDkhps { get; set; } = new List<Phieudkhp>();
}
