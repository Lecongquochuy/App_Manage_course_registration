using System;
using System.Collections.Generic;

namespace BaseLibrary.Entities;

public partial class Huyen
{
    public string MaHuyen { get; set; } = null!;

    public string? TenHuyen { get; set; }

    public string MaTinh { get; set; } = null!;

    public bool? VungSauVungXa { get; set; }

    public virtual Tinh MaTinhNavigation { get; set; } = null!;

    public virtual ICollection<Sinhvien> Sinhviens { get; set; } = new List<Sinhvien>();
}
