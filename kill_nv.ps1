Write-Host "=== NVIDIA 相关进程 ==="
$nvProcs = @()
Get-Process | Where-Object { $_.ProcessName -match 'nvidia|nvcontainer|nvdisplay|nvsphelper|nvbackend' } | ForEach-Object {
    $nvProcs += $_
    Write-Host "$($_.ProcessName) (PID: $($_.Id)) - $($_.Path)"
}

if ($nvProcs.Count -eq 0) {
    Write-Host "没有找到 NVIDIA 进程."
    exit 0
}

Write-Host "`n正在停止 NVIDIA 进程..."
$stopped = @()
foreach ($p in $nvProcs) {
    try {
        $name = $p.ProcessName
        $pid = $p.Id
        Stop-Process -Id $pid -Force -ErrorAction Stop
        Write-Host "  ✓ $name (PID: $pid)"
        $stopped += $name
    } catch {
        Write-Host "  ✗ $($p.ProcessName) (PID: $($p.Id)): $_"
    }
}

Write-Host "`n已停止进程: $($stopped -join ', ')"

# Now delete the NVIDIA app folder
Write-Host "`n删除 NVIDIA app 目录..."
$target = 'C:\ProgramData\NVIDIA Corporation\NVIDIA app'
if (Test-Path $target) {
    try {
        Remove-Item -Path $target -Recurse -Force -ErrorAction Stop
        Write-Host "  ✓ 已删除"
    } catch {
        Write-Host "  ✗ 删除失败: $_"
    }
} else {
    Write-Host "  目录不存在"
}

# Restart NVIDIA services/app
Write-Host "`n重新启动 NVIDIA..."
$nvidiaServices = Get-Service | Where-Object { $_.Name -match 'NVDisplay|NVContainer|NvTelemetry|NVLocalSystem' }
foreach ($svc in $nvidiaServices) {
    try {
        Start-Service $svc.Name -ErrorAction Stop
        Write-Host "  ✓ 服务已启动: $($svc.DisplayName)"
    } catch {
        Write-Host "  ! $($svc.DisplayName): $_"
    }
}

# Check final disk space
$c = Get-PSDrive C
Write-Host "`nC盘剩余空间: $([math]::Round($c.Free/1GB, 2)) GB"
