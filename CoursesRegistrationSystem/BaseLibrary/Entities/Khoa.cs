using System;
using System.Collections.Generic;

namespace BaseLibrary.Entities;

public partial class Khoa
{
    public string MaKhoa { get; set; } = null!;

    public string? TenKhoa { get; set; }

    public virtual ICollection<Nganhhoc> Nganhhocs { get; set; } = new List<Nganhhoc>();
}
