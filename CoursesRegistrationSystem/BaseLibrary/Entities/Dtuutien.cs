using System;
using System.Collections.Generic;

namespace BaseLibrary.Entities;

public partial class Dtuutien
{
    public string MaDt { get; set; } = null!;

    public string? TenDt { get; set; }

    public double? TiLeGiam { get; set; }

    public virtual ICollection<Sinhvien> Sinhviens { get; set; } = new List<Sinhvien>();
}
