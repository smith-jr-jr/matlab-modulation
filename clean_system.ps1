Write-Host "=== Step 1: DISM Component Cleanup ==="
Write-Host "Running DISM /StartComponentCleanup..."
$result = Dism /online /Cleanup-Image /StartComponentCleanup 2>&1
$result | ForEach-Object { Write-Host $_ }

Write-Host "`n=== Step 2: Clean Temp Files ==="
$tempPaths = @(
    'C:\Windows\Temp\*',
    'C:\Users\zjr\AppData\Local\Temp\*',
    'C:\Windows\Prefetch\*'
)
foreach ($tp in $tempPaths) {
    $dir = Split-Path $tp -Parent
    if (Test-Path $dir) {
        try {
            $count = 0
            Get-ChildItem $tp -ErrorAction SilentlyContinue | ForEach-Object {
                try { Remove-Item $_.FullName -Recurse -Force -ErrorAction Stop; $count++ } catch { }
            }
            Write-Host "  Cleaned $dir ($count items)"
        } catch {
            Write-Host "  Skipped $dir: $_"
        }
    }
}

Write-Host "`n=== Step 3: Delivery Optimization Files ==="
$deliveryOpt = 'C:\Windows\ServiceState\DeliveryOptimization'
if (Test-Path $deliveryOpt) {
    try {
        Remove-Item $deliveryOpt -Recurse -Force -ErrorAction Stop
        Write-Host "  Cleaned Delivery Optimization cache"
    } catch {
        Write-Host "  Could not clean: $_"
    }
}

Write-Host "`n=== Step 4: Recycle Bin ==="
try {
    $shell = New-Object -ComObject Shell.Application
    $shell.Namespace(0xA).Items() | ForEach-Object { Remove-Item $_.Path -Recurse -Force }
    Write-Host "  Emptied Recycle Bin"
} catch {
    Write-Host "  Recycle Bin already empty or inaccessible"
}

# Final disk check
$after = Get-PSDrive C
Write-Host "`nC drive free after system cleanup: $([math]::Round($after.Free/1GB, 2)) GB"
