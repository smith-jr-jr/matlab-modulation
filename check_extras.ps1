# System files
$files = @('C:\hiberfil.sys', 'C:\pagefile.sys', 'C:\swapfile.sys')
$results = @()
foreach ($f in $files) {
    if (Test-Path $f) {
        $size = (Get-Item $f -Force).Length
        $results += [PSCustomObject]@{Name=(Split-Path $f -Leaf); SizeGB=[math]::Round($size/1GB, 2)}
    }
}
if ($results.Count -gt 0) {
    Write-Host "=== 系统文件(hiberfil/pagefile/swapfile) ==="
    $results | Format-Table -AutoSize
}

# Ubisoft
Write-Host "`n=== Ubisoft 子目录 ==="
$ub = @()
if (Test-Path 'C:\ProgramData\Ubisoft') {
    Get-ChildItem -Path 'C:\ProgramData\Ubisoft' -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $s = 0
        try { $s = (Get-ChildItem -Path $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum } catch { }
        $ub += [PSCustomObject]@{Folder=$_.Name; SizeGB=[math]::Round($s/1GB, 2)}
    }
}
$ub | Sort-Object SizeGB -Descending | Format-Table -AutoSize

# NVIDIA
Write-Host "`n=== NVIDIA Corporation 子目录 ==="
$nv = @()
if (Test-Path 'C:\ProgramData\NVIDIA Corporation') {
    Get-ChildItem -Path 'C:\ProgramData\NVIDIA Corporation' -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $s = 0
        try { $s = (Get-ChildItem -Path $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum } catch { }
        $nv += [PSCustomObject]@{Folder=$_.Name; SizeGB=[math]::Round($s/1GB, 2)}
    }
}
$nv | Sort-Object SizeGB -Descending | Format-Table -AutoSize
