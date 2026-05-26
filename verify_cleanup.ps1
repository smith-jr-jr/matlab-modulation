Write-Host "=== 清理验证 ==="

# Check NVIDIA app
if (Test-Path 'C:\ProgramData\NVIDIA Corporation\NVIDIA app') {
    $size = 0
    try { $size = (Get-ChildItem 'C:\ProgramData\NVIDIA Corporation\NVIDIA app' -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum } catch { }
    Write-Host ("NVIDIA app 目录残留: " + [math]::Round($size/1GB, 2) + " GB")
} else {
    Write-Host "NVIDIA app 目录: 已删除 ✓"
}

# Check Ubisoft
if (Test-Path 'C:\ProgramData\Ubisoft') {
    Write-Host "Ubisoft 目录还在!"
} else {
    Write-Host "Ubisoft 目录: 已删除 ✓"
}

# Check NVIDIA Downloader
if (Test-Path 'C:\ProgramData\NVIDIA Corporation\Downloader') {
    Write-Host "NVIDIA Downloader 目录还在!"
} else {
    Write-Host "NVIDIA Downloader 目录: 已删除 ✓"
}

# Disk space
$c = Get-PSDrive C
Write-Host ("`nC盘剩余空间: " + [math]::Round($c.Free/1GB, 2) + " GB (总计 " + [math]::Round($c.Used/1GB + $c.Free/1GB, 0) + " GB)")

# NVIDIA processes
Write-Host "`n=== NVIDIA 后台进程 ==="
Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -match 'nvcontainer|nvdisplay|nvidia' } | ForEach-Object {
    Write-Host ("  " + $_.ProcessName + " (PID: " + $_.Id + ")")
}

Write-Host "`n=== NVIDIA 服务状态 ==="
Get-Service -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'NVDisplay|NVContainer|NvTelemetry|NVLocalSystem' } | ForEach-Object {
    Write-Host ("  " + $_.DisplayName + " : " + $_.Status)
}
