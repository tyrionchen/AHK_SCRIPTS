Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class ScreenRes {
    [DllImport("user32.dll")]
    public static extern IntPtr GetDC(IntPtr hWnd);
    [DllImport("gdi32.dll")]
    public static extern int GetDeviceCaps(IntPtr hdc, int nIndex);
    [DllImport("user32.dll")]
    public static extern int ReleaseDC(IntPtr hWnd, IntPtr hDC);
    public static int GetWidth() {
        IntPtr hdc = GetDC(IntPtr.Zero);
        int w = GetDeviceCaps(hdc, 118); // DESKTOPHORZRES
        ReleaseDC(IntPtr.Zero, hdc);
        return w;
    }
    public static int GetHeight() {
        IntPtr hdc = GetDC(IntPtr.Zero);
        int h = GetDeviceCaps(hdc, 117); // DESKTOPVERTRES
        ReleaseDC(IntPtr.Zero, hdc);
        return h;
    }
}
"@

Add-Type -AssemblyName System.Drawing

$width = [ScreenRes]::GetWidth()
$height = [ScreenRes]::GetHeight()

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$saveDir = "C:\Users\tyrionchen\Desktop\screenshot"
if (-not (Test-Path $saveDir)) {
    New-Item -ItemType Directory -Path $saveDir | Out-Null
}
$savePath = Join-Path $saveDir ("screenshot_{0}.png" -f $timestamp)

$bitmap = New-Object System.Drawing.Bitmap $width, $height
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.CopyFromScreen(0, 0, 0, 0, $bitmap.Size)
$bitmap.Save($savePath, [System.Drawing.Imaging.ImageFormat]::Png)
$graphics.Dispose()
$bitmap.Dispose()

Write-Host "Screenshot saved to $savePath"