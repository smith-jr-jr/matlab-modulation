$paths = @(
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
)

$results = @()
foreach ($path in $paths) {
    if (Test-Path $path) {
        Get-ItemProperty $path -ErrorAction SilentlyContinue | ForEach-Object {
            if ($_.DisplayName -and $_.DisplayName -notmatch 'Update|Hotfix|Package|Driver|Runtime|Language|Resource|Component|Add-in|Addin') {
                $size = 0
                if ($_.InstallLocation -and (Test-Path $_.InstallLocation)) {
                    try {
                        $size = (Get-ChildItem $_.InstallLocation -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
                    } catch { }
                }
                $results += [PSCustomObject]@{
                    Name = $_.DisplayName
                    InstallLocation = $_.InstallLocation
                    SizeGB = [math]::Round($size/1GB, 2)
                    EstimatedSize = $_.EstimatedSize
                }
            }
        }
    }
}

# Remove duplicates by name, keep the one with InstallLocation or larger size
$unique = $results | Group-Object Name | ForEach-Object {
    $g = $_.Group | Sort-Object { if ($_.InstallLocation) { 1 } else { 0 } }, SizeGB -Descending
    $g[0]
} | Sort-Object SizeGB -Descending

Write-Host "=== Installed Software on C: (>0.5 GB) ==="
$shown = 0
foreach ($item in $unique) {
    if ($item.SizeGB -gt 0.5) {
        $loc = if ($item.InstallLocation) { $item.InstallLocation } else { "(no path)" }
        Write-Host ("  [{0:0.00} GB] {1}" -f $item.SizeGB, $item.Name)
        Write-Host ("          $loc")
        $shown++
    }
}
Write-Host "`nTotal shown: $shown apps >0.5 GB"

# Also show top-level folder sizes for apps without InstallLocation
Write-Host "`n=== Large folders in C:\ (apps without registry entry) ==="
Get-ChildItem 'C:\' -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $s = 0
    try { $s = (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum } catch { }
    if ($s -gt 1GB -and $_.Name -notin @('Windows','Users','Program Files','Program Files (x86)','ProgramData','PerfLogs','Recovery','System Volume Information')) {
        [PSCustomObject]@{Name=$_.Name; SizeGB=[math]::Round($s/1GB, 2)}
    }
} | Sort-Object SizeGB -Descending | Format-Table -AutoSize
