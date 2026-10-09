using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;

public static class StylizeGershayim {
  static readonly Color Cream = Color.FromArgb(255, 250, 247, 240);
  static readonly Color PeachLight = Color.FromArgb(255, 236, 192, 160);
  static readonly Color PeachMid = Color.FromArgb(255, 224, 176, 136);
  static readonly Color PeachShadow = Color.FromArgb(255, 200, 136, 96);
  static readonly Color Nail = Color.FromArgb(255, 232, 200, 184);

  static bool IsBg(Color p) {
    if (p.A < 16) return true;
    int mx = Math.Max(p.R, Math.Max(p.G, p.B));
    int mn = Math.Min(p.R, Math.Min(p.G, p.B));
    return (mx - mn) < 40 && p.R > 190 && p.G > 185 && p.B > 175;
  }

  static Color Lerp(Color a, Color b, double t) {
    if (t < 0) t = 0;
    if (t > 1) t = 1;
    return Color.FromArgb(255,
      (int)(a.R + (b.R - a.R) * t),
      (int)(a.G + (b.G - a.G) * t),
      (int)(a.B + (b.B - a.B) * t));
  }

  static Color MapSkin(Color p) {
    double lum = (0.299 * p.R + 0.587 * p.G + 0.114 * p.B) / 255.0;
    if (lum > 0.78 && p.B > p.G - 10) return Nail;
    if (lum > 0.72) return Lerp(PeachMid, PeachLight, (lum - 0.72) / 0.28);
    if (lum > 0.45) return Lerp(PeachShadow, PeachMid, (lum - 0.45) / 0.27);
    return Lerp(Color.FromArgb(255, 160, 100, 70), PeachShadow, lum / 0.45);
  }

  public static int Main(string[] args) {
    Run(args[0], args[1]);
    return 0;
  }

  public static void Run(string srcPath, string dstPath) {
    using (var src = new Bitmap(srcPath)) {
      int w = src.Width, h = src.Height;
      var flat = new Bitmap(w, h, PixelFormat.Format32bppArgb);
      for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
          Color p = src.GetPixel(x, y);
          flat.SetPixel(x, y, IsBg(p) ? Cream : MapSkin(p));
        }
      }

      var smooth = new Bitmap(w, h, PixelFormat.Format32bppArgb);
      for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
          if (IsBg(flat.GetPixel(x, y))) {
            smooth.SetPixel(x, y, Cream);
            continue;
          }
          int rs = 0, gs = 0, bs = 0, n = 0;
          for (int jy = -1; jy <= 1; jy++) {
            for (int jx = -1; jx <= 1; jx++) {
              int xx = x + jx, yy = y + jy;
              if (xx < 0 || yy < 0 || xx >= w || yy >= h) continue;
              Color q = flat.GetPixel(xx, yy);
              if (IsBg(q)) continue;
              rs += q.R; gs += q.G; bs += q.B; n++;
            }
          }
          if (n == 0) smooth.SetPixel(x, y, flat.GetPixel(x, y));
          else smooth.SetPixel(x, y, Color.FromArgb(255, rs / n, gs / n, bs / n));
        }
      }
      flat.Dispose();

      int minX = w, minY = h, maxX = -1, maxY = -1;
      for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
          if (IsBg(smooth.GetPixel(x, y))) continue;
          if (x < minX) minX = x;
          if (y < minY) minY = y;
          if (x > maxX) maxX = x;
          if (y > maxY) maxY = y;
        }
      }
      var crop = smooth.Clone(
        new Rectangle(minX, minY, maxX - minX + 1, maxY - minY + 1),
        PixelFormat.Format32bppArgb);
      smooth.Dispose();

      int size = 1024;
      double pad = 0.06;
      int inner = (int)(size * (1 - 2 * pad));
      double scale = Math.Min(inner / (double)crop.Width, inner / (double)crop.Height);
      int dw = (int)(crop.Width * scale);
      int dh = (int)(crop.Height * scale);
      int placeX = (size - dw) / 2;
      int placeY = (size - dh) / 2;

      using (var canvas = new Bitmap(size, size, PixelFormat.Format32bppArgb))
      using (var g = Graphics.FromImage(canvas)) {
        g.Clear(Cream);
        g.InterpolationMode = InterpolationMode.HighQualityBicubic;
        g.DrawImage(crop, placeX, placeY, dw, dh);
        for (int y = 0; y < size; y++) {
          for (int x = 0; x < size; x++) {
            if (IsBg(canvas.GetPixel(x, y))) canvas.SetPixel(x, y, Cream);
          }
        }
        canvas.Save(dstPath, ImageFormat.Png);
      }
      crop.Dispose();
      Console.WriteLine("stylized ok");
    }
  }
}
