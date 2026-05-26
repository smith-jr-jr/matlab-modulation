$folders = @(
    'C:\Users\zjr\AppData',
    'C:\Users\zjr\Downloads',
    'C:\Users\zjr\Documents',
    'C:\Users\zjr\Desktop',
    'C:\Users\zjr\.cache',
    'C:\Users\zjr\.gradle',
    'C:\Users\zjr\.m2',
    'C:\Windows\Temp',
    'C:\Users\zjr\AppData\Local\Temp',
    'C:\Windows\SoftwareDistribution',
    'C:\ProgramData\Docker',
    'C:\Users\zjr\AppData\Local\Docker',
    'C:\ProgramData\DockerDesktop',
    'C:\ProgramData\Microsoft\Windows\WER'
)

$results = @()
foreach ($f in $folders) {
    if (Test-Path $f) {
        $size = 0
        try {
            $size = (Get-ChildItem -Path $f -Recurse -File -ErrorAction Stop | Measure-Object -Property Length -Sum).Sum
        } catch { }
        $results += [PSCustomObject]@{Path=$f; SizeGB=[math]::Round($size/1GB, 2)}
    }
}
$results | Sort-Object SizeGB -Descending | Format-Table -AutoSize
