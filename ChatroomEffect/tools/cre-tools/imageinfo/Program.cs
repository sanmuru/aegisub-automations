using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text;

namespace imageinfo
{
    class Program
    {
        static void Main(string[] args)
        {
            var paths = args.Where(arg => !string.IsNullOrWhiteSpace(arg))
                .SelectMany(arg =>
                {
                    if (arg.StartsWith("@"))
                    {
                        string path = arg.Substring(1);
                        if (File.Exists(path))
                            return File.ReadLines(path);
                        else
                            return Enumerable.Empty<string>();
                    }
                    else
                    {
                        if (File.Exists(arg))
                            return Enumerable.Repeat(arg, 1);
                        else
                            return Enumerable.Empty<string>();
                    }
                });

            bool flag = true;
            foreach (var path in paths)
            {
                if (!File.Exists(path)) continue;

                if (flag)
                    flag = false;
                else
                    Console.WriteLine();
                
                string md5Str = null;
                using (MD5 md5 = new MD5CryptoServiceProvider())
                using (var fs = File.OpenRead(path))
                {
                    Bitmap bitmap = new Bitmap(fs);

                    var hash = md5.ComputeHash(fs);
                    md5Str = BitConverter.ToString(hash);

                    Console.WriteLine("path: ", Path.GetFullPath(path));
                    Console.WriteLine("width: ", bitmap.Width);
                    Console.WriteLine("height: ", bitmap.Height);
                    Console.WriteLine("md5: ", md5Str);
                }
            }
        }
    }
}
