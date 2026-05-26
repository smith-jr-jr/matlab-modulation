# Top-level dirs in C:\Users\zjr
$results = @()
Get-ChildItem -Path 'C:\Users\zjr' -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $size = 0
    try { $size = (Get-ChildItem -Path $_.FullName -Recurse -File -ErrorAction Stop | Measure-Object -Property Length -Sum).Sum } catch { }
    if ($size -gt 0) {
        $results += [PSCustomObject]@{Name=$_.Name; SizeGB=[math]::Round($size/1GB, 2)}
    }
}
$results | Sort-Object SizeGB -Descending | Select-Object -First 15 | Format-Table -AutoSize
