Write-Host "=== C:\ProgramData 子目录 ==="
Get-ChildItem -Path 'C:\ProgramData' -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $size = 0
    try { $size = (Get-ChildItem -Path $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum } catch { }
    if ($size -gt 100MB) {
        [PSCustomObject]@{Folder=$_.Name; SizeGB=[math]::Round($size/1GB, 2)}
    }
} | Sort-Object SizeGB -Descending | Format-Table -AutoSize

Write-Host "`n=== C:\Windows\Installer 大小(清理候选) ==="
$winst = 0
try { $winst = (Get-ChildItem -Path 'C:\Windows\Installer' -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum } catch { }
Write-Host "Windows Installer: $([math]::Round($winst/1GB, 2)) GB"

Write-Host "`n=== C:\Program Files 子目录 ==="
Get-ChildItem -Path 'C:\Program Files' -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $size = 0
    try { $size = (Get-ChildItem -Path $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum } catch { }
    if ($size -gt 1GB) {
        [PSCustomObject]@{Folder=$_.Name; SizeGB=[math]::Round($size/1GB, 2)}
    }
} | Sort-Object SizeGB -Descending | Format-Table -AutoSize

Write-Host "`n=== C:\Program Files (x86) 子目录 ==="
Get-ChildItem -Path 'C:\Program Files (x86)' -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $size = 0
    try { $size = (Get-ChildItem -Path $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum } catch { }
    if ($size -gt 1GB) {
        [PSCustomObject]@{Folder=$_.Name; SizeGB=[math]::Round($size/1GB, 2)}
    }
} | Sort-Object SizeGB -Descending | Format-Table -AutoSize

Write-Host "`n=== C:\Users 子目录 ==="
Get-ChildItem -Path 'C:\Users' -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $size = 0
    try { $size = (Get-ChildItem -Path $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum } catch { }
    if ($size -gt 100MB) {
        [PSCustomObject]@{Folder=$_.Name; SizeGB=[math]::Round($size/1GB, 2)}
    }
} | Sort-Object SizeGB -Descending | Format-Table -AutoSize
