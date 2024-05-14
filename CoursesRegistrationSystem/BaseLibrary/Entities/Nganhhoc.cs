using System;
using System.Collections.Generic;

namespace BaseLibrary.Entities;

public partial class Nganhhoc
{
    public string MaNh { get; set; } = null!;

    public string? TenNh { get; set; }

    public string MaKhoa { get; set; } = null!;

    public virtual ICollection<CtNganh> CtNganhs { get; set; } = new List<CtNganh>();

    public virtual Khoa MaKhoaNavigation { get; set; } = null!;

    public virtual ICollection<Sinhvien> Sinhviens { get; set; } = new List<Sinhvien>();
}
