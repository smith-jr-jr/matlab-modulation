# Check C:\ top-level usage
$targets = @()
Get-ChildItem -Path 'C:\' -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $size = 0
    try { $size = (Get-ChildItem -Path $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum } catch { }
    if ($size -gt 0) {
        $targets += [PSCustomObject]@{Name=$_.FullName; SizeGB=[math]::Round($size/1GB, 2)}
    }
}
Write-Host "=== C:\ Top-Level Directories ==="
$targets | Sort-Object SizeGB -Descending | Format-Table -AutoSize

# Also check hidden system dirs
Write-Host "`n=== Large System Folders ==="
$sysFolders = @(
    'C:\ProgramData',
    'C:\Program Files',
    'C:\Program Files (x86)',
    'C:\Windows\Installer',
    'C:\Windows\WinSxS',
    'C:\Windows\System32'
)
$sysRes = @()
foreach ($f in $sysFolders) {
    if (Test-Path $f) {
        $size = 0
        try { $size = (Get-ChildItem -Path "$f\*" -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum } catch { }
        $sysRes += [PSCustomObject]@{Path=$f; SizeGB=[math]::Round($size/1GB, 2)}
    }
}
$sysRes | Sort-Object SizeGB -Descending | Format-Table -AutoSize
