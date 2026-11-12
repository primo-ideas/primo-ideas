# Starts a program, waits for its main window, records that window with ffmpeg's gfxcapture
# (Windows.Graphics.Capture: works on GPU-rendered windows, even partly covered), then stops it.
#   record-window.ps1 -Exe path -ArgList @(...) -WorkDir dir -Out file.mp4 -Seconds 20 -Warmup 3
#   record-window.ps1 -Exe attach:<process name> -Out file.mp4 -Seconds 20 -Warmup 0 [-KeepRunning]
# Needs Python with `pip install imageio-ffmpeg` (an ffmpeg build with gfxcapture). See docs/clips.md.
param(
    [string]$Exe, [string[]]$ArgList = @(), [string]$WorkDir = '.', [string]$Out,
    [int]$Seconds = 20, [double]$Warmup = 3, [int]$Fps = 30, [switch]$KeepRunning
)
$ErrorActionPreference = 'Stop'
$ff = python -c "import imageio_ffmpeg as f; print(f.get_ffmpeg_exe())"
if ($Exe -like 'attach:*') {
    # attach:<process name>: the process of that name, started by someone else, whose window is
    # the largest (several clients may run at once, the one to film being the big one).
    Add-Type -Namespace W -Name U -MemberDefinition @'
[StructLayout(LayoutKind.Sequential)] public struct RECT { public int L, T, R, B; }
[DllImport("user32.dll")] public static extern bool GetClientRect(IntPtr h, out RECT r);
'@
    $name = $Exe.Substring(7)
    $deadline = (Get-Date).AddSeconds(30)
    while ($true) {
        $p = Get-Process -Name $name -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 } |
            Sort-Object { $r = New-Object W.U+RECT; [void][W.U]::GetClientRect($_.MainWindowHandle, [ref]$r); $r.R * $r.B } |
            Select-Object -Last 1
        if ($p) { break }
        if ((Get-Date) -gt $deadline) { throw "no $name window" }
        Start-Sleep -Milliseconds 200
    }
} else {
    $p = Start-Process -FilePath $Exe -ArgumentList $ArgList -WorkingDirectory $WorkDir -PassThru
}
$deadline = (Get-Date).AddSeconds(60)
while ($true) {
    $p.Refresh()
    if ($p.MainWindowHandle -ne 0) { break }
    if ($p.HasExited) { throw "the program exited before showing a window" }
    if ((Get-Date) -gt $deadline) { $p.Kill(); throw "no window after 60 s" }
    Start-Sleep -Milliseconds 200
}
$hwnd = $p.MainWindowHandle.ToInt64()
Start-Sleep -Milliseconds ([int]($Warmup * 1000))
& $ff -hide_banner -loglevel error -y -f lavfi -i "gfxcapture=hwnd=${hwnd}:max_framerate=${Fps}:capture_cursor=0,hwdownload,format=bgra,fps=$Fps" `
    -t $Seconds -c:v libx264 -preset veryfast -crf 14 -pix_fmt yuv420p $Out
$code = $LASTEXITCODE
if (-not $KeepRunning -and -not $p.HasExited) { $p.Kill() }
if ($code -ne 0) { throw "ffmpeg failed ($code)" }
Write-Output "recorded $Out (pid $($p.Id))"
