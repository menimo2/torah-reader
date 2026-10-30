using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.Drawing.Text;
using System.Windows.Forms;

class MakeFeatureGraphic
{
    static void Main()
    {
        var srcPath = @"C:\Users\Menim\.cursor\projects\c-Users-Menim-source-torah-reader\assets\feature-graphic-source.jpg";
        var dest = @"c:\Users\Menim\source\torah-reader\store\play-feature-1024x500.png";
        using (var src = Image.FromFile(srcPath))
        using (var bmp = new Bitmap(1024, 500))
        using (var g = Graphics.FromImage(bmp))
        {
            g.InterpolationMode = InterpolationMode.HighQualityBicubic;
            g.PixelOffsetMode = PixelOffsetMode.HighQuality;
            g.SmoothingMode = SmoothingMode.HighQuality;
            g.TextRenderingHint = TextRenderingHint.AntiAliasGridFit;
            g.Clear(Color.FromArgb(250, 247, 240));
            // 1280x720 scaled to width 1024 is 1024x576; crop 38px top and bottom.
            g.DrawImage(src, new Rectangle(0, -38, 1024, 576));

            var title = new Font("Segoe UI", 42, FontStyle.Bold, GraphicsUnit.Pixel);
            var sub = new Font("Segoe UI", 22, FontStyle.Regular, GraphicsUnit.Pixel);
            var titleColor = Color.FromArgb(92, 58, 30);
            var subColor = Color.FromArgb(122, 90, 58);
            var flags = TextFormatFlags.Right | TextFormatFlags.RightToLeft | TextFormatFlags.NoPadding;
            var titleRect = new Rectangle(620, 175, 360, 70);
            var subRect = new Rectangle(620, 250, 360, 40);
            TextRenderer.DrawText(g, "בעל קורא", title, titleRect, titleColor, flags);
            TextRenderer.DrawText(g, "אימון קריאה בתורה", sub, subRect, subColor, flags);

            bmp.Save(dest, ImageFormat.Png);
        }
        Console.WriteLine(dest);
    }
}
