$after = Get-PSDrive C
$free = [math]::Round($after.Free/1GB, 2)
Write-Host "C drive free: $free GB"

$sxs = (Get-ChildItem 'C:\Windows\WinSxS' -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
Write-Host "WinSxS: $([math]::Round($sxs/1GB, 2)) GB"
