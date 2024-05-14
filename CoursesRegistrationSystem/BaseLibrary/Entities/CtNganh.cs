using System;
using System.Collections.Generic;

namespace BaseLibrary.Entities;

public partial class CtNganh
{
    public string MaNh { get; set; } = null!;

    public string MaMh { get; set; } = null!;

    public int? HocKy { get; set; }

    public string? GhiChu { get; set; }

    public virtual Monhoc MaMhNavigation { get; set; } = null!;

    public virtual Nganhhoc MaNhNavigation { get; set; } = null!;
}
