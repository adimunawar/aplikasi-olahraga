using System;
using System.IO;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;

namespace MuscleAssetGenerator {
    public class Program {
        const int CanvasWidth = 950;
        const int CanvasHeight = 2540;
        static readonly Color ActiveLime = Color.FromArgb(255, 168, 233, 0); // #A8E900

        public static void Main(string[] args) {
            string baseDir = args.Length > 0 ? args[0] : "assets/muscle";
            string frontDir = Path.Combine(baseDir, "front");
            string backDir = Path.Combine(baseDir, "back");
            string previewDir = Path.Combine(baseDir, "previews");

            Directory.CreateDirectory(frontDir);
            Directory.CreateDirectory(backDir);
            Directory.CreateDirectory(previewDir);

            Console.WriteLine("Generating missing muscle overlays...");

            // 1. FRONT: Forearms
            GenerateFrontForearms(frontDir);

            // 2. FRONT: Obliques
            GenerateFrontObliques(frontDir);

            // 3. FRONT: Calves
            GenerateFrontCalves(frontDir);

            // 4. BACK: Rear Shoulders
            GenerateBackShoulders(backDir);

            // 5. BACK: Forearms
            GenerateBackForearms(backDir);

            // 6. BACK: Lower Back / Erectors
            GenerateBackLowerBack(backDir);

            Console.WriteLine("Generating composite preview images...");
            GeneratePreviews(baseDir);

            Console.WriteLine("Muscle asset generation complete!");
        }

        static Bitmap CreateCanvas() {
            var bmp = new Bitmap(CanvasWidth, CanvasHeight, PixelFormat.Format32bppArgb);
            using (var g = Graphics.FromImage(bmp)) {
                g.Clear(Color.Transparent);
            }
            return bmp;
        }

        // --- FRONT OVERLAYS ---

        static void GenerateFrontForearms(string dir) {
            using (var bmp = CreateCanvas())
            using (var g = Graphics.FromImage(bmp)) {
                ConfigureGraphics(g);

                using (var brush = new SolidBrush(ActiveLime)) {
                    // Left Forearm
                    var leftPath = new GraphicsPath();
                    PointF[] leftPts = new PointF[] {
                        new PointF(108, 930),
                        new PointF(82, 970),
                        new PointF(62, 1030),
                        new PointF(56, 1100),
                        new PointF(60, 1160),
                        new PointF(76, 1205),
                        new PointF(105, 1200),
                        new PointF(135, 1150),
                        new PointF(175, 1080),
                        new PointF(202, 1020),
                        new PointF(190, 960),
                        new PointF(145, 930)
                    };
                    leftPath.AddClosedCurve(leftPts, 0.4f);
                    g.FillPath(brush, leftPath);

                    // Right Forearm (Symmetric)
                    var rightPath = new GraphicsPath();
                    PointF[] rightPts = new PointF[] {
                        new PointF(950 - 108, 930),
                        new PointF(950 - 82, 970),
                        new PointF(950 - 62, 1030),
                        new PointF(950 - 56, 1100),
                        new PointF(950 - 60, 1160),
                        new PointF(950 - 76, 1205),
                        new PointF(950 - 105, 1200),
                        new PointF(950 - 135, 1150),
                        new PointF(950 - 175, 1080),
                        new PointF(950 - 202, 1020),
                        new PointF(950 - 190, 960),
                        new PointF(950 - 145, 930)
                    };
                    rightPath.AddClosedCurve(rightPts, 0.4f);
                    g.FillPath(brush, rightPath);
                }

                MaskWithBase(bmp, Path.Combine(dir, "base_front.png"));
                bmp.Save(Path.Combine(dir, "forearms.png"), ImageFormat.Png);
                Console.WriteLine("Saved: front/forearms.png");
            }
        }

        static void GenerateFrontObliques(string dir) {
            using (var bmp = CreateCanvas())
            using (var g = Graphics.FromImage(bmp)) {
                ConfigureGraphics(g);

                using (var brush = new SolidBrush(ActiveLime)) {
                    // Left Obliques (Flanking Abs)
                    var leftPath = new GraphicsPath();
                    PointF[] leftPts = new PointF[] {
                        new PointF(340, 810),
                        new PointF(320, 860),
                        new PointF(305, 930),
                        new PointF(300, 1000),
                        new PointF(305, 1070),
                        new PointF(330, 1120),
                        new PointF(375, 1110),
                        new PointF(385, 1030),
                        new PointF(382, 950),
                        new PointF(370, 870),
                        new PointF(360, 820)
                    };
                    leftPath.AddClosedCurve(leftPts, 0.35f);
                    g.FillPath(brush, leftPath);

                    // Right Obliques (Symmetric)
                    var rightPath = new GraphicsPath();
                    PointF[] rightPts = new PointF[] {
                        new PointF(950 - 340, 810),
                        new PointF(950 - 320, 860),
                        new PointF(950 - 305, 930),
                        new PointF(950 - 300, 1000),
                        new PointF(950 - 305, 1070),
                        new PointF(950 - 330, 1120),
                        new PointF(950 - 375, 1110),
                        new PointF(950 - 385, 1030),
                        new PointF(950 - 382, 950),
                        new PointF(950 - 370, 870),
                        new PointF(950 - 360, 820)
                    };
                    rightPath.AddClosedCurve(rightPts, 0.35f);
                    g.FillPath(brush, rightPath);
                }

                MaskWithBase(bmp, Path.Combine(dir, "base_front.png"));
                bmp.Save(Path.Combine(dir, "obliques.png"), ImageFormat.Png);
                Console.WriteLine("Saved: front/obliques.png");
            }
        }

        static void GenerateFrontCalves(string dir) {
            using (var bmp = CreateCanvas())
            using (var g = Graphics.FromImage(bmp)) {
                ConfigureGraphics(g);

                using (var brush = new SolidBrush(ActiveLime)) {
                    // Left Calf / Shin (Tibialis Anterior + Gastrocnemius)
                    var leftPath = new GraphicsPath();
                    PointF[] leftPts = new PointF[] {
                        new PointF(300, 1780),
                        new PointF(240, 1830),
                        new PointF(228, 1900),
                        new PointF(238, 1980),
                        new PointF(265, 2070),
                        new PointF(300, 2140),
                        new PointF(340, 2120),
                        new PointF(370, 2040),
                        new PointF(385, 1950),
                        new PointF(380, 1870),
                        new PointF(350, 1800)
                    };
                    leftPath.AddClosedCurve(leftPts, 0.4f);
                    g.FillPath(brush, leftPath);

                    // Right Calf / Shin (Symmetric)
                    var rightPath = new GraphicsPath();
                    PointF[] rightPts = new PointF[] {
                        new PointF(950 - 300, 1780),
                        new PointF(950 - 240, 1830),
                        new PointF(950 - 228, 1900),
                        new PointF(950 - 238, 1980),
                        new PointF(950 - 265, 2070),
                        new PointF(950 - 300, 2140),
                        new PointF(950 - 340, 2120),
                        new PointF(950 - 370, 2040),
                        new PointF(950 - 385, 1950),
                        new PointF(950 - 380, 1870),
                        new PointF(950 - 350, 1800)
                    };
                    rightPath.AddClosedCurve(rightPts, 0.4f);
                    g.FillPath(brush, rightPath);
                }

                MaskWithBase(bmp, Path.Combine(dir, "base_front.png"));
                bmp.Save(Path.Combine(dir, "calves.png"), ImageFormat.Png);
                Console.WriteLine("Saved: front/calves.png");
            }
        }

        // --- BACK OVERLAYS ---

        static void GenerateBackShoulders(string dir) {
            using (var bmp = CreateCanvas())
            using (var g = Graphics.FromImage(bmp)) {
                ConfigureGraphics(g);

                using (var brush = new SolidBrush(ActiveLime)) {
                    // Left Rear Deltoid
                    var leftPath = new GraphicsPath();
                    PointF[] leftPts = new PointF[] {
                        new PointF(230, 520),
                        new PointF(175, 560),
                        new PointF(150, 620),
                        new PointF(160, 680),
                        new PointF(205, 715),
                        new PointF(245, 680),
                        new PointF(255, 610),
                        new PointF(248, 550)
                    };
                    leftPath.AddClosedCurve(leftPts, 0.4f);
                    g.FillPath(brush, leftPath);

                    // Right Rear Deltoid (Symmetric)
                    var rightPath = new GraphicsPath();
                    PointF[] rightPts = new PointF[] {
                        new PointF(950 - 230, 520),
                        new PointF(950 - 175, 560),
                        new PointF(950 - 150, 620),
                        new PointF(950 - 160, 680),
                        new PointF(950 - 205, 715),
                        new PointF(950 - 245, 680),
                        new PointF(950 - 255, 610),
                        new PointF(950 - 248, 550)
                    };
                    rightPath.AddClosedCurve(rightPts, 0.4f);
                    g.FillPath(brush, rightPath);
                }

                MaskWithBase(bmp, Path.Combine(dir, "base_back.png"));
                bmp.Save(Path.Combine(dir, "shoulders.png"), ImageFormat.Png);
                Console.WriteLine("Saved: back/shoulders.png");
            }
        }

        static void GenerateBackForearms(string dir) {
            using (var bmp = CreateCanvas())
            using (var g = Graphics.FromImage(bmp)) {
                ConfigureGraphics(g);

                using (var brush = new SolidBrush(ActiveLime)) {
                    // Left Posterior Forearm
                    var leftPath = new GraphicsPath();
                    PointF[] leftPts = new PointF[] {
                        new PointF(110, 930),
                        new PointF(85, 970),
                        new PointF(65, 1030),
                        new PointF(58, 1100),
                        new PointF(62, 1160),
                        new PointF(78, 1205),
                        new PointF(108, 1200),
                        new PointF(138, 1150),
                        new PointF(175, 1080),
                        new PointF(200, 1020),
                        new PointF(190, 960),
                        new PointF(145, 930)
                    };
                    leftPath.AddClosedCurve(leftPts, 0.4f);
                    g.FillPath(brush, leftPath);

                    // Right Posterior Forearm (Symmetric)
                    var rightPath = new GraphicsPath();
                    PointF[] rightPts = new PointF[] {
                        new PointF(950 - 110, 930),
                        new PointF(950 - 85, 970),
                        new PointF(950 - 65, 1030),
                        new PointF(950 - 58, 1100),
                        new PointF(950 - 62, 1160),
                        new PointF(950 - 78, 1205),
                        new PointF(950 - 108, 1200),
                        new PointF(950 - 138, 1150),
                        new PointF(950 - 175, 1080),
                        new PointF(950 - 200, 1020),
                        new PointF(950 - 190, 960),
                        new PointF(950 - 145, 930)
                    };
                    rightPath.AddClosedCurve(rightPts, 0.4f);
                    g.FillPath(brush, rightPath);
                }

                MaskWithBase(bmp, Path.Combine(dir, "base_back.png"));
                bmp.Save(Path.Combine(dir, "forearms.png"), ImageFormat.Png);
                Console.WriteLine("Saved: back/forearms.png");
            }
        }

        static void GenerateBackLowerBack(string dir) {
            using (var bmp = CreateCanvas())
            using (var g = Graphics.FromImage(bmp)) {
                ConfigureGraphics(g);

                using (var brush = new SolidBrush(ActiveLime)) {
                    // Lower Back (Erector Spinae / Lumbar region)
                    var leftPath = new GraphicsPath();
                    PointF[] leftPts = new PointF[] {
                        new PointF(465, 960),
                        new PointF(430, 980),
                        new PointF(395, 1020),
                        new PointF(390, 1070),
                        new PointF(410, 1115),
                        new PointF(465, 1120)
                    };
                    leftPath.AddClosedCurve(leftPts, 0.35f);
                    g.FillPath(brush, leftPath);

                    var rightPath = new GraphicsPath();
                    PointF[] rightPts = new PointF[] {
                        new PointF(485, 960),
                        new PointF(520, 980),
                        new PointF(555, 1020),
                        new PointF(560, 1070),
                        new PointF(540, 1115),
                        new PointF(485, 1120)
                    };
                    rightPath.AddClosedCurve(rightPts, 0.35f);
                    g.FillPath(brush, rightPath);
                }

                MaskWithBase(bmp, Path.Combine(dir, "base_back.png"));
                bmp.Save(Path.Combine(dir, "lower_back.png"), ImageFormat.Png);
                Console.WriteLine("Saved: back/lower_back.png");
            }
        }

        // --- PREVIEWS ---

        static void GeneratePreviews(string baseDir) {
            string frontDir = Path.Combine(baseDir, "front");
            string backDir = Path.Combine(baseDir, "back");
            string previewDir = Path.Combine(baseDir, "previews");

            // 1. Front Preview (Clean Base)
            CompositeToFile(
                new string[] { Path.Combine(frontDir, "base_front.png") },
                Path.Combine(previewDir, "front_preview.png")
            );

            // 2. Back Preview (Clean Base)
            CompositeToFile(
                new string[] { Path.Combine(backDir, "base_back.png") },
                Path.Combine(previewDir, "back_preview.png")
            );

            // 3. Chest Highlight Preview
            CompositeToFile(
                new string[] {
                    Path.Combine(frontDir, "base_front.png"),
                    Path.Combine(frontDir, "chest.png")
                },
                Path.Combine(previewDir, "chest_highlight_preview.png")
            );

            // 4. Push-up Highlight Preview (Chest + Shoulders + Triceps)
            CompositeToFile(
                new string[] {
                    Path.Combine(frontDir, "base_front.png"),
                    Path.Combine(frontDir, "chest.png"),
                    Path.Combine(frontDir, "shoulders.png")
                },
                Path.Combine(previewDir, "pushup_highlight_preview.png")
            );

            // 5. Full Body Highlight Preview (Chest + Abs + Quads + Biceps + Shoulders)
            CompositeToFile(
                new string[] {
                    Path.Combine(frontDir, "base_front.png"),
                    Path.Combine(frontDir, "chest.png"),
                    Path.Combine(frontDir, "abs.png"),
                    Path.Combine(frontDir, "quads.png"),
                    Path.Combine(frontDir, "biceps.png"),
                    Path.Combine(frontDir, "shoulders.png"),
                    Path.Combine(frontDir, "obliques.png")
                },
                Path.Combine(previewDir, "full_body_highlight_preview.png")
            );
        }

        static void CompositeToFile(string[] layers, string outputPath) {
            using (var bmp = CreateCanvas())
            using (var g = Graphics.FromImage(bmp)) {
                ConfigureGraphics(g);

                foreach (var layerPath in layers) {
                    if (File.Exists(layerPath)) {
                        using (var layer = Image.FromFile(layerPath)) {
                            g.DrawImage(layer, 0, 0, CanvasWidth, CanvasHeight);
                        }
                    }
                }

                bmp.Save(outputPath, ImageFormat.Png);
                Console.WriteLine("Saved preview: " + Path.GetFileName(outputPath));
            }
        }

        // --- HELPERS ---

        static void ConfigureGraphics(Graphics g) {
            g.SmoothingMode = SmoothingMode.AntiAlias;
            g.InterpolationMode = InterpolationMode.HighQualityBicubic;
            g.PixelOffsetMode = PixelOffsetMode.HighQuality;
            g.CompositingQuality = CompositingQuality.HighQuality;
        }

        static void MaskWithBase(Bitmap overlay, string basePath) {
            if (!File.Exists(basePath)) return;

            using (var baseBmp = new Bitmap(basePath)) {
                int w = Math.Min(overlay.Width, baseBmp.Width);
                int h = Math.Min(overlay.Height, baseBmp.Height);

                for (int y = 0; y < h; y++) {
                    for (int x = 0; x < w; x++) {
                        Color baseColor = baseBmp.GetPixel(x, y);
                        if (baseColor.A < 40) {
                            // If base body is transparent here, mask out overlay pixel
                            overlay.SetPixel(x, y, Color.Transparent);
                        }
                    }
                }
            }
        }
    }
}

