using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Text;

namespace imageconv
{
    class Program
    {
        static int Main(string[] args)
        {
            try
            {
                if (args.Length == 0) throw new Exception("缺少命令行参数。");

                string oldPath = args[0];
                if (!File.Exists(oldPath)) throw new Exception($"找不到文件\"{oldPath}\"。");
                string newPath = args.Length > 1 && args[1] != "-" ? args[1] : Path.Combine(Path.GetDirectoryName(oldPath), Path.GetFileNameWithoutExtension(oldPath) + ".png");
                if (string.Equals(newPath, oldPath, StringComparison.OrdinalIgnoreCase))
                {
                    int i = 0;
                    do
                    {
                        i++;
                        newPath = Path.Combine(Path.GetDirectoryName(oldPath), $"{Path.GetFileNameWithoutExtension(oldPath)} ({i}).png");
                    }
                    while (string.Equals(newPath, oldPath, StringComparison.OrdinalIgnoreCase));
                }
                CreateDirectoryX(Path.GetDirectoryName(newPath));

                Bitmap oldBitmap = new Bitmap(oldPath);
                Bitmap newBitmap = GetNewBitmap(oldBitmap, args);

                newBitmap.Save(newPath, ImageFormat.Png);
                return 0;
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
                return -1;
            }
        }

        internal static Bitmap GetNewBitmap(Image oldImage, string[] args)
        {
            int x = args.Length > 2 && args[2] != "-" ? int.Parse(args[2]) : 0;
            int y = args.Length > 3 && args[3] != "-" ? int.Parse(args[3]) : 0;
            int oldWidth = Math.Max(1, args.Length > 4 && args[4] != "-" ? int.Parse(args[4]) : oldImage.Width - x);
            int oldHeight = Math.Max(1, args.Length > 5 && args[5] != "-" ? int.Parse(args[5]) : oldImage.Height - y);
            int newWidth = args.Length > 6 && args[6] != "-" ? Math.Max(1, int.Parse(args[6])) : oldWidth;
            int newHeight = args.Length > 7 && args[7] != "-" ? Math.Max(1, int.Parse(args[7])) : oldHeight;

            int realX = Math.Max(x, 0);
            int realY = Math.Max(y, 0);
            int realOldWidth = Math.Min(x + oldWidth, oldImage.Width) - realX;
            int realOldHeight = Math.Min(y + oldHeight, oldImage.Height) - realY;

            Bitmap newImage = new Bitmap(newWidth, newHeight);

            if (realOldWidth > 0 && realOldHeight > 0)
            {
                Graphics g = Graphics.FromImage(newImage);
                g.InterpolationMode = InterpolationMode.HighQualityBicubic;

                g.DrawImage(oldImage, new Rectangle(
                    Convert.ToInt32((double)(realX - x) / (double)oldWidth * (double)newWidth),
                    Convert.ToInt32((double)(realY - y) / (double)oldHeight * (double)newHeight),
                    Convert.ToInt32((double)realOldWidth / (double)oldWidth * (double)newWidth),
                    Convert.ToInt32((double)realOldHeight / (double)oldHeight * (double)newHeight)
                ), new Rectangle(realX, realY, realOldWidth, realOldHeight), GraphicsUnit.Pixel);
            }

            return newImage;
        }

        static void CreateDirectoryX(string path)
        {
            if (Directory.Exists(path)) return;
            else
            {
                CreateDirectoryX(Path.GetDirectoryName(path));
                Directory.CreateDirectory(path);
            }
        }
    }
}
