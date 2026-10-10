using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.IO;
using System.Runtime.InteropServices;

public static class MakeQuarterArcGif {
  public static int Main(string[] args) {
    if (args.Length > 0 && args[0] == "z") {
      RunZ(args[1], args[2], args.Length > 3 ? args[3] : null);
      return 0;
    }
    Run(args[0], args[1], args.Length > 2 ? args[2] : null);
    return 0;
  }

  static bool IsBg(Color p) {
    if (p.A < 16) return true;
    int maxc = Math.Max(p.R, Math.Max(p.G, p.B));
    int minc = Math.Min(p.R, Math.Min(p.G, p.B));
    return (maxc - minc) < 22 && p.R > 235 && p.G > 235 && p.B > 235;
  }

  static Bitmap CropHand(Bitmap src) {
    int minX = src.Width, minY = src.Height, maxX = -1, maxY = -1;
    for (int y = 0; y < src.Height; y++) {
      for (int x = 0; x < src.Width; x++) {
        if (!IsBg(src.GetPixel(x, y))) {
          if (x < minX) minX = x;
          if (y < minY) minY = y;
          if (x > maxX) maxX = x;
          if (y > maxY) maxY = y;
        }
      }
    }
    var rect = new Rectangle(minX, minY, maxX - minX + 1, maxY - minY + 1);
    var crop = src.Clone(rect, PixelFormat.Format32bppArgb);
    for (int y = 0; y < crop.Height; y++) {
      for (int x = 0; x < crop.Width; x++) {
        if (IsBg(crop.GetPixel(x, y))) {
          crop.SetPixel(x, y, Color.FromArgb(0, 255, 255, 255));
        }
      }
    }
    return crop;
  }

  public static void Run(string handSrc, string outGif, string previewDir) {
    int size = 512;
    int framesN = 12;
    int delayCs = 7; // 70ms * 12 = 840ms < 1s
    if (previewDir != null) Directory.CreateDirectory(previewDir);

    using (var src = new Bitmap(handSrc))
    using (var handFull = CropHand(src)) {
      float handScale = 0.40f;
      int hw = Math.Max(1, (int)(handFull.Width * handScale));
      int hh = Math.Max(1, (int)(handFull.Height * handScale));
      var hand = new Bitmap(hw, hh, PixelFormat.Format32bppArgb);
      using (var g = Graphics.FromImage(hand)) {
        g.Clear(Color.Transparent);
        g.InterpolationMode = InterpolationMode.HighQualityBicubic;
        g.DrawImage(handFull, 0, 0, hw, hh);
      }
      PointF tipOff = new PointF(hw * 0.48f, hh * 0.02f);

      float margin = 28f;
      float R = size * 0.48f;
      float cx = margin + 36f;
      float cy = margin + 36f;
      var tipPath = new List<PointF>();
      for (int i = 0; i < framesN; i++) {
        float t = i / (float)(framesN - 1);
        float ang = t * (float)(Math.PI / 2.0);
        tipPath.Add(new PointF(
          cx + R * (float)Math.Cos(ang),
          cy + R * (float)Math.Sin(ang)));
      }

      var frames = new List<Bitmap>();
      for (int i = 0; i < framesN; i++) {
        var canvas = new Bitmap(size, size, PixelFormat.Format24bppRgb);
        using (var g = Graphics.FromImage(canvas)) {
          g.SmoothingMode = SmoothingMode.AntiAlias;
          g.InterpolationMode = InterpolationMode.HighQualityBicubic;
          g.Clear(Color.White);
          if (i > 0) {
            using (var pen = new Pen(Color.FromArgb(255, 80, 80, 80), 5f)) {
              pen.StartCap = LineCap.Round;
              pen.EndCap = LineCap.Round;
              pen.LineJoin = LineJoin.Round;
              g.DrawLines(pen, tipPath.GetRange(0, i + 1).ToArray());
            }
          } else {
            using (var brush = new SolidBrush(Color.FromArgb(255, 80, 80, 80))) {
              g.FillEllipse(brush, tipPath[0].X - 2.5f, tipPath[0].Y - 2.5f, 5f, 5f);
            }
          }
          float dx = tipPath[i].X - tipOff.X;
          float dy = tipPath[i].Y - tipOff.Y;
          g.DrawImage(hand, dx, dy, hw, hh);
        }
        if (previewDir != null) {
          canvas.Save(Path.Combine(previewDir, "f" + i + ".png"), ImageFormat.Png);
        }
        frames.Add(canvas);
      }

      WriteGif89a(outGif, frames, delayCs, Color.White);
      Console.WriteLine("wrote " + outGif + " frames=" + frames.Count + " totalMs=" + (frames.Count * delayCs * 10));
      foreach (var f in frames) f.Dispose();
      hand.Dispose();
    }
  }

  static readonly Color Cream = Color.FromArgb(255, 250, 247, 240);

  public static void RunZ(string handSrc, string outGif, string previewDir) {
    int size = 1024;
    int framesN = 12;
    int delayCs = 7; // 70ms * 12 = 840ms
    if (previewDir != null) Directory.CreateDirectory(previewDir);

    using (var src = new Bitmap(handSrc))
    using (var cropped = CropHand(src)) {
      cropped.RotateFlip(RotateFlipType.RotateNoneFlipX);
      float handScale = 0.42f;
      int hw = Math.Max(1, (int)(cropped.Width * handScale));
      int hh = Math.Max(1, (int)(cropped.Height * handScale));
      var hand = new Bitmap(hw, hh, PixelFormat.Format32bppArgb);
      using (var g = Graphics.FromImage(hand)) {
        g.Clear(Color.Transparent);
        g.InterpolationMode = InterpolationMode.HighQualityBicubic;
        g.DrawImage(cropped, 0, 0, hw, hh);
      }

      int tipX = hw / 2, tipY = 0;
      for (int y = 0; y < hh; y++) {
        int count = 0, sum = 0;
        for (int x = 0; x < hw; x++) {
          if (hand.GetPixel(x, y).A < 200) continue;
          count++;
          sum += x;
        }
        if (count >= 8) {
          tipY = y;
          tipX = sum / count;
          break;
        }
      }
      PointF tipOff = new PointF(tipX, tipY);

      float left = tipOff.X + 36f;
      float right = size - (hw - tipOff.X) - 36f;
      float top = tipOff.Y + 28f;
      float zTop = top;
      float zBottom = zTop + (right - left) * 0.62f;
      var corners = new PointF[] {
        new PointF(left, zTop),
        new PointF(right, zTop),
        new PointF(left, zBottom),
        new PointF(right, zBottom),
      };
      var tipPath = SamplePolyline(corners, framesN);

      var frames = new List<Bitmap>();
      for (int i = 0; i < framesN; i++) {
        var canvas = new Bitmap(size, size, PixelFormat.Format24bppRgb);
        using (var g = Graphics.FromImage(canvas)) {
          g.SmoothingMode = SmoothingMode.AntiAlias;
          g.InterpolationMode = InterpolationMode.HighQualityBicubic;
          g.Clear(Cream);
          using (var pen = new Pen(Color.FromArgb(255, 70, 70, 70), 10f)) {
            pen.StartCap = LineCap.Round;
            pen.EndCap = LineCap.Round;
            pen.LineJoin = LineJoin.Round;
            if (i == 0) {
              g.FillEllipse(pen.Brush, tipPath[0].X - 5f, tipPath[0].Y - 5f, 10f, 10f);
            } else {
              g.DrawLines(pen, tipPath.GetRange(0, i + 1).ToArray());
            }
          }
          g.DrawImage(hand, tipPath[i].X - tipOff.X, tipPath[i].Y - tipOff.Y, hw, hh);
        }
        if (previewDir != null) {
          canvas.Save(Path.Combine(previewDir, "f" + i + ".png"), ImageFormat.Png);
        }
        frames.Add(canvas);
      }

      WriteGif89a(outGif, frames, delayCs, Cream);
      Console.WriteLine("wrote " + outGif + " frames=" + frames.Count + " totalMs=" + (frames.Count * delayCs * 10));
      foreach (var f in frames) f.Dispose();
      hand.Dispose();
    }
  }

  static List<PointF> SamplePolyline(PointF[] corners, int framesN) {
    var lengths = new List<float>();
    float total = 0f;
    for (int i = 0; i < corners.Length - 1; i++) {
      float dx = corners[i + 1].X - corners[i].X;
      float dy = corners[i + 1].Y - corners[i].Y;
      float len = (float)Math.Sqrt(dx * dx + dy * dy);
      lengths.Add(len);
      total += len;
    }
    var pts = new List<PointF>();
    for (int i = 0; i < framesN; i++) {
      float dist = total * i / (float)(framesN - 1);
      float walked = 0f;
      int seg = 0;
      while (seg < lengths.Count - 1 && walked + lengths[seg] < dist) {
        walked += lengths[seg];
        seg++;
      }
      float t = lengths[seg] <= 0.001f ? 0f : (dist - walked) / lengths[seg];
      if (t < 0f) t = 0f;
      if (t > 1f) t = 1f;
      pts.Add(new PointF(
        corners[seg].X + (corners[seg + 1].X - corners[seg].X) * t,
        corners[seg].Y + (corners[seg + 1].Y - corners[seg].Y) * t));
    }
    return pts;
  }

  static void WriteGif89a(string path, List<Bitmap> frames, int delayCs, Color background) {
    int w = frames[0].Width, h = frames[0].Height;
    List<Color> palette = BuildPalette(frames, 256);
    palette[0] = background;
    using (var fs = new FileStream(path, FileMode.Create, FileAccess.Write))
    using (var bw = new BinaryWriter(fs)) {
      bw.Write(new byte[] { (byte)'G', (byte)'I', (byte)'F', (byte)'8', (byte)'9', (byte)'a' });
      bw.Write((ushort)w);
      bw.Write((ushort)h);
      bw.Write((byte)(0x80 | (7 << 4) | 7));
      bw.Write((byte)0);
      bw.Write((byte)0);
      for (int i = 0; i < 256; i++) {
        Color c = palette[i];
        bw.Write(c.R); bw.Write(c.G); bw.Write(c.B);
      }

      // No NETSCAPE loop block → plays once, then stops.

      foreach (Bitmap frame in frames) {
        bw.Write((byte)0x21);
        bw.Write((byte)0xF9);
        bw.Write((byte)4);
        bw.Write((byte)0x08);
        bw.Write((ushort)delayCs);
        bw.Write((byte)0);
        bw.Write((byte)0);

        bw.Write((byte)0x2C);
        bw.Write((ushort)0);
        bw.Write((ushort)0);
        bw.Write((ushort)w);
        bw.Write((ushort)h);
        bw.Write((byte)0);

        byte[] indexed = IndexFrame(frame, palette);
        byte[] lzw = LzwEncode(indexed, 8);
        bw.Write((byte)8);
        int pos = 0;
        while (pos < lzw.Length) {
          int n = Math.Min(255, lzw.Length - pos);
          bw.Write((byte)n);
          bw.Write(lzw, pos, n);
          pos += n;
        }
        bw.Write((byte)0);
      }
      bw.Write((byte)0x3B);
    }
  }

  static List<Color> BuildPalette(List<Bitmap> frames, int maxColors) {
    var map = new Dictionary<int, int>();
    foreach (Bitmap bmp in frames) {
      for (int y = 0; y < bmp.Height; y += 2) {
        for (int x = 0; x < bmp.Width; x += 2) {
          Color c = bmp.GetPixel(x, y);
          int key = ((c.R & 0xF8) << 16) | ((c.G & 0xF8) << 8) | (c.B & 0xF8);
          if (map.ContainsKey(key)) map[key]++; else map[key] = 1;
        }
      }
    }
    var list = new List<KeyValuePair<int, int>>(map);
    list.Sort(delegate(KeyValuePair<int, int> a, KeyValuePair<int, int> b) {
      return b.Value.CompareTo(a.Value);
    });
    var pal = new List<Color>();
    pal.Add(Color.White);
    for (int i = 0; i < list.Count && pal.Count < maxColors; i++) {
      int key = list[i].Key;
      Color c = Color.FromArgb((key >> 16) & 0xFF, (key >> 8) & 0xFF, key & 0xFF);
      if (c.R > 250 && c.G > 250 && c.B > 250) continue;
      pal.Add(c);
    }
    while (pal.Count < maxColors) pal.Add(Color.Black);
    return pal;
  }

  static byte[] IndexFrame(Bitmap bmp, List<Color> pal) {
    byte[] idx = new byte[bmp.Width * bmp.Height];
    int i = 0;
    for (int y = 0; y < bmp.Height; y++) {
      for (int x = 0; x < bmp.Width; x++) {
        idx[i++] = (byte)Nearest(bmp.GetPixel(x, y), pal);
      }
    }
    return idx;
  }

  static int Nearest(Color c, List<Color> pal) {
    int best = 0, bestD = int.MaxValue;
    for (int i = 0; i < pal.Count; i++) {
      Color p = pal[i];
      int dr = c.R - p.R, dg = c.G - p.G, db = c.B - p.B;
      int d = dr * dr + dg * dg + db * db;
      if (d < bestD) {
        bestD = d;
        best = i;
        if (d == 0) break;
      }
    }
    return best;
  }

  static byte[] LzwEncode(byte[] indexStream, int minCodeSize) {
    int clear = 1 << minCodeSize;
    int end = clear + 1;
    int codeSize = minCodeSize + 1;
    int nextCode = end + 1;
    var dict = new Dictionary<string, int>();

    Action resetDict = delegate {
      dict.Clear();
      for (int i = 0; i < clear; i++) dict[i.ToString()] = i;
      codeSize = minCodeSize + 1;
      nextCode = end + 1;
    };
    resetDict();

    var bits = new List<byte>();
    int cur = 0, curBits = 0;
    Action<int> writeCode = delegate(int code) {
      cur |= (code << curBits);
      curBits += codeSize;
      while (curBits >= 8) {
        bits.Add((byte)(cur & 0xFF));
        cur >>= 8;
        curBits -= 8;
      }
    };

    writeCode(clear);
    string w = indexStream[0].ToString();
    for (int i = 1; i < indexStream.Length; i++) {
      string k = w + "," + indexStream[i];
      if (dict.ContainsKey(k)) {
        w = k;
      } else {
        writeCode(dict[w]);
        if (nextCode < 4096) {
          dict[k] = nextCode++;
          if (nextCode > (1 << codeSize) && codeSize < 12) codeSize++;
        } else {
          writeCode(clear);
          resetDict();
        }
        w = indexStream[i].ToString();
      }
    }
    writeCode(dict[w]);
    writeCode(end);
    if (curBits > 0) bits.Add((byte)(cur & 0xFF));
    return bits.ToArray();
  }
}
