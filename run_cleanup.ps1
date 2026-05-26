$ErrorActionPreference = "Stop"
Start-Transcript -Path "E:\ai\ai-claude\matlab\cleanup_log.txt"

$targets = @(
    'C:\ProgramData\Ubisoft',
    'C:\ProgramData\NVIDIA Corporation\NVIDIA app',
    'C:\ProgramData\NVIDIA Corporation\Downloader'
)

$totalFreed = 0
foreach ($target in $targets) {
    if (Test-Path $target) {
        try {
            $size = (Get-ChildItem -Path $target -Recurse -File -ErrorAction Stop | Measure-Object -Property Length -Sum).Sum
            $sizeGB = [math]::Round($size/1GB, 2)
            Write-Host "删除: $target ($sizeGB GB)..."
            Remove-Item -Path $target -Recurse -Force -ErrorAction Stop
            Write-Host "  完成."
            $totalFreed += $size
        } catch {
            Write-Host "  失败: $_"
        }
    } else {
        Write-Host "跳过 (不存在): $target"
    }
}

$totalGB = [math]::Round($totalFreed/1GB, 2)
Write-Host "`n总共释放: $totalGB GB"

# Check final state
$after = Get-PSDrive C
Write-Host "C盘剩余空间: $([math]::Round($after.Free/1GB, 2)) GB"

Stop-Transcript
