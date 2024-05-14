using System;
using System.Collections.Generic;

namespace BaseLibrary.Entities;

public partial class Tinh
{
    public string MaTinh { get; set; } = null!;

    public string? TenTinh { get; set; }

    public virtual ICollection<Huyen> Huyens { get; set; } = new List<Huyen>();
}
