using System.Runtime.InteropServices;
using Drawing = System.Drawing;
using Drawing2D = System.Drawing.Drawing2D;
using Imaging = System.Drawing.Imaging;
using Forms = System.Windows.Forms;

namespace MoveBreak.Services;
public sealed class NotificationService : IDisposable
{
    private readonly Forms.NotifyIcon _icon;
    private readonly Drawing.Icon _appIcon;
    private readonly Forms.ToolStripItem _openItem;
    private readonly Forms.ToolStripItem _pauseItem;
    private readonly Forms.ToolStripItem _exitItem;
    private readonly LocalizationService _localization;
    public event Action? ShowRequested; public event Action? PauseRequested; public event Action? ExitRequested;
    public NotificationService(LocalizationService localization)
    {
        _localization = localization;
        var menu = new Forms.ContextMenuStrip();
        _openItem = menu.Items.Add("", null, (_,_) => ShowRequested?.Invoke());
        _pauseItem = menu.Items.Add("", null, (_,_) => PauseRequested?.Invoke());
        _exitItem = menu.Items.Add("", null, (_,_) => ExitRequested?.Invoke());
        _appIcon = LoadApplicationIcon();
        _icon = new Forms.NotifyIcon { Icon = _appIcon, Text = "MoveBreak", Visible = true, ContextMenuStrip = menu };
        _icon.DoubleClick += (_,_) => ShowRequested?.Invoke();
        _icon.MouseClick += (_, e) => { if (e.Button == Forms.MouseButtons.Left) ShowRequested?.Invoke(); };
        _icon.BalloonTipClicked += (_, _) => ShowRequested?.Invoke();
        UpdateLanguage();
        localization.LanguageChanged += UpdateLanguage;
    }

    private static Drawing.Icon LoadApplicationIcon()
    {
        try
        {
            var resource = System.Windows.Application.GetResourceStream(
                new Uri("pack://application:,,,/Assets/MoveBreak.png", UriKind.Absolute));
            if (resource is not null)
            {
                using (resource.Stream)
                using (var source = new Drawing.Bitmap(resource.Stream))
                    return CreateTrayIcon(source);
            }
        }
        catch
        {
            // Fall back to the executable icon when the PNG resource cannot be read.
        }

        var executablePath = Environment.ProcessPath;
        if (!string.IsNullOrWhiteSpace(executablePath))
        {
            var extractedIcon = Drawing.Icon.ExtractAssociatedIcon(executablePath);
            if (extractedIcon is not null)
            {
                return extractedIcon;
            }
        }

        return (Drawing.Icon)Drawing.SystemIcons.Application.Clone();
    }

    private static Drawing.Icon CreateTrayIcon(Drawing.Bitmap source)
    {
        var contentBounds = FindVisibleBounds(source);
        using var trayBitmap = new Drawing.Bitmap(32, 32, Imaging.PixelFormat.Format32bppArgb);
        using (var graphics = Drawing.Graphics.FromImage(trayBitmap))
        {
            graphics.Clear(Drawing.Color.Transparent);
            graphics.CompositingMode = Drawing2D.CompositingMode.SourceCopy;
            graphics.CompositingQuality = Drawing2D.CompositingQuality.HighQuality;
            graphics.InterpolationMode = Drawing2D.InterpolationMode.HighQualityBicubic;
            graphics.PixelOffsetMode = Drawing2D.PixelOffsetMode.HighQuality;
            graphics.SmoothingMode = Drawing2D.SmoothingMode.HighQuality;

            const float inset = 1f;
            var scale = Math.Min((32f - (inset * 2)) / contentBounds.Width, (32f - (inset * 2)) / contentBounds.Height);
            var width = contentBounds.Width * scale;
            var height = contentBounds.Height * scale;
            var destination = new Drawing.RectangleF((32f - width) / 2f, (32f - height) / 2f, width, height);
            graphics.DrawImage(source, destination, contentBounds, Drawing.GraphicsUnit.Pixel);
        }

        var handle = trayBitmap.GetHicon();
        try
        {
            using var icon = Drawing.Icon.FromHandle(handle);
            return (Drawing.Icon)icon.Clone();
        }
        finally
        {
            DestroyIcon(handle);
        }
    }

    private static Drawing.Rectangle FindVisibleBounds(Drawing.Bitmap source)
    {
        using var normalized = new Drawing.Bitmap(source.Width, source.Height, Imaging.PixelFormat.Format32bppArgb);
        using (var graphics = Drawing.Graphics.FromImage(normalized))
            graphics.DrawImageUnscaled(source, 0, 0);

        var area = new Drawing.Rectangle(0, 0, normalized.Width, normalized.Height);
        var data = normalized.LockBits(area, Imaging.ImageLockMode.ReadOnly, Imaging.PixelFormat.Format32bppArgb);
        try
        {
            var bytes = new byte[Math.Abs(data.Stride) * data.Height];
            Marshal.Copy(data.Scan0, bytes, 0, bytes.Length);
            var minX = normalized.Width;
            var minY = normalized.Height;
            var maxX = -1;
            var maxY = -1;

            for (var y = 0; y < normalized.Height; y++)
            {
                var row = data.Stride >= 0 ? y * data.Stride : (normalized.Height - 1 - y) * -data.Stride;
                for (var x = 0; x < normalized.Width; x++)
                {
                    if (bytes[row + (x * 4) + 3] < 12) continue;
                    minX = Math.Min(minX, x);
                    minY = Math.Min(minY, y);
                    maxX = Math.Max(maxX, x);
                    maxY = Math.Max(maxY, y);
                }
            }

            return maxX >= minX && maxY >= minY
                ? Drawing.Rectangle.FromLTRB(minX, minY, maxX + 1, maxY + 1)
                : area;
        }
        finally
        {
            normalized.UnlockBits(data);
        }
    }

    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool DestroyIcon(nint handle);

    private void UpdateLanguage() { _openItem.Text=_localization.Text("TrayOpen"); _pauseItem.Text=_localization.Text("TrayPause"); _exitItem.Text=_localization.Text("TrayExit"); }
    public void ShowBreak(string title, string text, bool sound)
    {
        _icon.BalloonTipTitle = title; _icon.BalloonTipText = text; _icon.BalloonTipIcon = Forms.ToolTipIcon.Info;
        _icon.ShowBalloonTip(8000); if (sound) System.Media.SystemSounds.Asterisk.Play();
    }
    public void Dispose()
    {
        _localization.LanguageChanged -= UpdateLanguage;
        _icon.Visible = false;
        _icon.Dispose();
        _appIcon.Dispose();
    }
}
