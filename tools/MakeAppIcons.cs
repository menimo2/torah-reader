using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.IO;

/// Reads assets/icon/app_icon.png when it already exists, otherwise the
/// generated draft, and writes the Android, iOS, and web launcher sizes.
class MakeAppIcons
{
    static int Main(string[] args)
    {
        var root = args.Length > 0
            ? args[0]
            : @"c:\Users\Menim\source\torah-reader";
        var master = Path.Combine(root, "assets", "icon", "app_icon.png");
        var draft = @"C:\Users\Menim\.cursor\projects\c-Users-Menim-source-torah-reader\assets\app-icon.jpg";
        var source = File.Exists(master) ? master : draft;
        if (!File.Exists(source))
        {
            Console.Error.WriteLine("missing " + source);
            return 1;
        }

        Directory.CreateDirectory(Path.GetDirectoryName(master));
        using (var src = Image.FromFile(source))
        {
            if (!File.Exists(master) || source != master)
            {
                Save(src, 1024, master);
            }

            Save(src, 48, Android(root, "mipmap-mdpi"));
            Save(src, 72, Android(root, "mipmap-hdpi"));
            Save(src, 96, Android(root, "mipmap-xhdpi"));
            Save(src, 144, Android(root, "mipmap-xxhdpi"));
            Save(src, 192, Android(root, "mipmap-xxxhdpi"));

            var ios = Path.Combine(root, @"ios\Runner\Assets.xcassets\AppIcon.appiconset");
            Save(src, 20, Path.Combine(ios, "Icon-App-20x20@1x.png"));
            Save(src, 40, Path.Combine(ios, "Icon-App-20x20@2x.png"));
            Save(src, 60, Path.Combine(ios, "Icon-App-20x20@3x.png"));
            Save(src, 29, Path.Combine(ios, "Icon-App-29x29@1x.png"));
            Save(src, 58, Path.Combine(ios, "Icon-App-29x29@2x.png"));
            Save(src, 87, Path.Combine(ios, "Icon-App-29x29@3x.png"));
            Save(src, 40, Path.Combine(ios, "Icon-App-40x40@1x.png"));
            Save(src, 80, Path.Combine(ios, "Icon-App-40x40@2x.png"));
            Save(src, 120, Path.Combine(ios, "Icon-App-40x40@3x.png"));
            Save(src, 120, Path.Combine(ios, "Icon-App-60x60@2x.png"));
            Save(src, 180, Path.Combine(ios, "Icon-App-60x60@3x.png"));
            Save(src, 76, Path.Combine(ios, "Icon-App-76x76@1x.png"));
            Save(src, 152, Path.Combine(ios, "Icon-App-76x76@2x.png"));
            Save(src, 167, Path.Combine(ios, "Icon-App-83.5x83.5@2x.png"));
            Save(src, 1024, Path.Combine(ios, "Icon-App-1024x1024@1x.png"));

            var web = Path.Combine(root, @"web\icons");
            Directory.CreateDirectory(web);
            Save(src, 192, Path.Combine(web, "Icon-192.png"));
            Save(src, 512, Path.Combine(web, "Icon-512.png"));
            Save(src, 192, Path.Combine(web, "Icon-maskable-192.png"));
            Save(src, 512, Path.Combine(web, "Icon-maskable-512.png"));
            Save(src, 32, Path.Combine(root, @"web\favicon.png"));
        }

        Console.WriteLine("wrote launcher icons from " + source);
        return 0;
    }

    static string Android(string root, string density)
    {
        return Path.Combine(root, @"android\app\src\main\res", density, "ic_launcher.png");
    }

    static void Save(Image src, int size, string dest)
    {
        using (var bmp = new Bitmap(size, size))
        using (var g = Graphics.FromImage(bmp))
        {
            g.InterpolationMode = InterpolationMode.HighQualityBicubic;
            g.PixelOffsetMode = PixelOffsetMode.HighQuality;
            g.SmoothingMode = SmoothingMode.HighQuality;
            g.Clear(Color.FromArgb(250, 247, 240));
            g.DrawImage(src, 0, 0, size, size);
            bmp.Save(dest, ImageFormat.Png);
        }
    }
}
