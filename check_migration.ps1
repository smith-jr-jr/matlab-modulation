$migrations = @(
    @{Src='C:\Program Files\Microsoft Visual Studio'; Dst='E:\soft\VS2022'; Label='Visual Studio 2022'},
    @{Src='C:\Program Files\AnsysEM';               Dst='E:\soft\AnsysEM'; Label='ANSYS EM 19.0'},
    @{Src='C:\Keil_v5';                             Dst='E:\soft\Keil_v5';  Label='Keil v5'},
    @{Src='C:\ST';                                  Dst='E:\soft\ST';       Label='STM32 Tools'}
)

Write-Host "=== Migration Status ==="
$allDone = $true
foreach ($m in $migrations) {
    $src = $m.Src
    $dst = $m.Dst
    $label = $m.Label

    $srcExists = Test-Path $src
    $dstExists = Test-Path $dst

    if ($srcExists) {
        $attr = (Get-Item $src -Force).Attributes
        $isJunction = [bool]($attr -band [System.IO.FileAttributes]::ReparsePoint)
        if ($isJunction) {
            $target = (Get-Item $src -Force).Target
            Write-Host "[OK] $label : Junction $src -> $target"
        } else {
            Write-Host "[WAIT] $label : src exists, not a junction yet (still moving?)"
            $allDone = $false
        }
    } elseif ($dstExists) {
        Write-Host "[FAIL] $label : files moved to $dst but no junction at src"
        $allDone = $false
    } else {
        Write-Host "[WAIT] $label : src and dst don't exist (still copying?)"
        $allDone = $false
    }
}

# Disk space
Write-Host "`n=== Disk Space ==="
$c = Get-PSDrive C
$e = Get-PSDrive E
Write-Host "C: $([math]::Round($c.Free/1GB, 2)) GB free"
Write-Host "E: $([math]::Round($e.Free/1GB, 2)) GB free"

# Check E:\soft content
if (Test-Path 'E:\soft') {
    Write-Host "`n=== E:\soft contents ==="
    Get-ChildItem 'E:\soft' -Directory | ForEach-Object { Write-Host "  $_" }
}

if ($allDone) {
    Write-Host "`nAll migrations complete!"
}
