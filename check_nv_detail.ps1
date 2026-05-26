if (Test-Path 'C:\ProgramData\NVIDIA Corporation\NVIDIA app') {
    Write-Host "=== NVIDIA app 子目录 ==="
    $results = @()
    Get-ChildItem -Path 'C:\ProgramData\NVIDIA Corporation\NVIDIA app' -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $s = 0
        try { $s = (Get-ChildItem -Path $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum } catch { }
        $results += [PSCustomObject]@{Folder=$_.Name; SizeGB=[math]::Round($s/1GB, 2)}
    }
    $results | Sort-Object SizeGB -Descending | Format-Table -AutoSize
}

if (Test-Path 'C:\ProgramData\NVIDIA Corporation\Downloader') {
    Write-Host "`n=== Downloader 子目录 ==="
    Get-ChildItem -Path 'C:\ProgramData\NVIDIA Corporation\Downloader' -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        [PSCustomObject]@{Folder=$_.Name}
    } | Format-Table -AutoSize
}

if (Test-Path 'C:\ProgramData\Ubisoft') {
    Write-Host "`n=== Ubisoft 子目录结构(深度2层) ==="
    Get-ChildItem -Path 'C:\ProgramData\Ubisoft' -Recurse -Depth 2 -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Host $_.FullName
    }
}
