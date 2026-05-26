$files = 'C:\hiberfil.sys', 'C:\pagefile.sys', 'C:\swapfile.sys'
foreach ($f in $files) {
    if (Test-Path $f) {
        $size = (Get-Item $f -Force).Length
        [PSCustomObject]@{Name=Split-Path $f -Leaf; SizeGB=[math]::Round($size/1GB, 2)}
    }
} | Format-Table -AutoSize

Write-Host "`n=== Ubisoft 子目录 ==="
Get-ChildItem -Path 'C:\ProgramData\Ubisoft' -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $s = 0
    try { $s = (Get-ChildItem -Path $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum } catch { }
    [PSCustomObject]@{Folder=$_.Name; SizeGB=[math]::Round($s/1GB, 2)}
} | Sort-Object SizeGB -Descending | Format-Table -AutoSize

Write-Host "`n=== NVIDIA 驱动缓存(C:\ProgramData\NVIDIA Corporation) ==="
Get-ChildItem -Path 'C:\ProgramData\NVIDIA Corporation' -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $s = 0
    try { $s = (Get-ChildItem -Path $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum } catch { }
    [PSCustomObject]@{Folder=$_.Name; SizeGB=[math]::Round($s/1GB, 2)}
} | Sort-Object SizeGB -Descending | Format-Table -AutoSize
