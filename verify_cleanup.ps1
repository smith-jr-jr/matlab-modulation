Write-Host "=== Cleanup Verification ==="

# Check NVIDIA app
if (Test-Path 'C:\ProgramData\NVIDIA Corporation\NVIDIA app') {
    $size = 0
    try { $size = (Get-ChildItem 'C:\ProgramData\NVIDIA Corporation\NVIDIA app' -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum } catch { }
    Write-Host ("NVIDIA app left: " + [math]::Round($size/1GB, 2) + " GB")
} else {
    Write-Host "NVIDIA app: DELETED OK"
}

# Check Ubisoft
if (Test-Path 'C:\ProgramData\Ubisoft') {
    Write-Host "Ubisoft: STILL EXISTS"
} else {
    Write-Host "Ubisoft: DELETED OK"
}

# Check NVIDIA Downloader
if (Test-Path 'C:\ProgramData\NVIDIA Corporation\Downloader') {
    Write-Host "NVIDIA Downloader: STILL EXISTS"
} else {
    Write-Host "NVIDIA Downloader: DELETED OK"
}

# Disk space
$c = Get-PSDrive C
$free = [math]::Round($c.Free/1GB, 2)
$total = [math]::Round(($c.Used + $c.Free)/1GB, 0)
Write-Host ("C drive free: " + $free + " GB / " + $total + " GB")

# NVIDIA processes
Write-Host "`n=== Running NVIDIA Processes ==="
$procs = @(Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -match 'nvcontainer|nvdisplay|nvidia' })
if ($procs.Count -gt 0) {
    foreach ($p in $procs) {
        Write-Host ("  " + $p.ProcessName + " (PID: " + $p.Id + ")")
    }
} else {
    Write-Host "  (none)"
}

# NVIDIA services
Write-Host "`n=== NVIDIA Services ==="
$svcs = @(Get-Service -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'NVDisplay|NVContainer|NvTelemetry|NVLocalSystem' })
if ($svcs.Count -gt 0) {
    foreach ($s in $svcs) {
        Write-Host ("  " + $s.DisplayName + " : " + $s.Status)
    }
} else {
    Write-Host "  (none)"
}
