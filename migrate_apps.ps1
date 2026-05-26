$ErrorActionPreference = "Continue"
$StartTime = Get-Date

# Check E: has enough space
$e = Get-PSDrive E
$freeE = [math]::Round($e.Free/1GB, 2)
Write-Host "E drive free: $freeE GB"
if ($e.Free -lt 40GB) {
    Write-Host "WARNING: Less than 40GB free on E:. Migration needs ~29GB."
}

# Create target folders
$targetBase = 'E:\soft'
if (-not (Test-Path $targetBase)) {
    New-Item -Path $targetBase -ItemType Directory -Force
    Write-Host "Created $targetBase"
}

$migrations = @(
    @{Src='C:\Program Files\Microsoft Visual Studio'; Dst="$targetBase\VS2022"; Label='Visual Studio 2022'},
    @{Src='C:\Program Files\AnsysEM';               Dst="$targetBase\AnsysEM"; Label='ANSYS EM 19.0'},
    @{Src='C:\Keil_v5';                             Dst="$targetBase\Keil_v5";  Label='Keil v5'},
    @{Src='C:\ST';                                  Dst="$targetBase\ST';       Label='STM32 Tools'}
)

Write-Host "`n=== Step 1: Close related processes ==="
$processPatterns = @('devenv', 'msbuild', 'vcpkgsrv', 'ServiceHub', 'ansys*', 'Uv4', 'STM32*', 'st-link*', 'Cube*')
foreach ($pat in $processPatterns) {
    $procs = @(Get-Process -Name $pat -ErrorAction SilentlyContinue)
    if ($procs.Count -gt 0) {
        foreach ($p in $procs) {
            try {
                Stop-Process -Id $p.Id -Force -ErrorAction Stop
                Write-Host "  Killed: $($p.ProcessName) (PID: $($p.Id))"
            } catch {
                Write-Host "  Skip: $($p.ProcessName) - $_"
            }
        }
    }
}

Write-Host "`n=== Step 2: Migrate with Junction ==="
foreach ($m in $migrations) {
    $src = $m.Src
    $dst = $m.Dst
    $label = $m.Label

    Write-Host "`n--- $label ---"
    Write-Host "  Source: $src"
    Write-Host "  Target: $dst"

    if (-not (Test-Path $src)) {
        Write-Host "  SKIP: source not found"
        continue
    }

    # Get source size for reporting
    $srcSize = 0
    try {
        $srcSize = (Get-ChildItem $src -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    } catch { }
    Write-Host "  Size: $([math]::Round($srcSize/1GB, 2)) GB"

    if (Test-Path $dst) {
        Write-Host "  WARNING: target already exists at $dst, skipping"
        continue
    }

    # Move the directory - Robocopy then delete source
    Write-Host "  Moving files (robocopy)..."
    $robocopyArgs = @($src, $dst, '/E', '/COPYALL', '/DCOPY:T', '/MOVE', '/R:2', '/W:5', '/NP', '/NFL', '/NDL')
    $rcResult = & robocopy $src $dst /E /COPYALL /DCOPY:T /MOVE /R:2 /W:5 2>&1
    $rcCode = $LASTEXITCODE
    if ($rcCode -ge 8) {
        Write-Host "  ERROR: robocopy failed with exit code $rcCode"
        Write-Host "  Output: $rcResult"
        continue
    }
    Write-Host "  Files moved (robocopy exit: $rcCode)"

    # After MOVE, src should be empty or gone. If src still has files, try to remove remnants
    if (Test-Path $src) {
        $leftovers = @(Get-ChildItem $src -Recurse -ErrorAction SilentlyContinue)
        if ($leftovers.Count -eq 0) {
            Remove-Item $src -Force -Recurse -ErrorAction SilentlyContinue
            Write-Host "  Removed empty source dir"
        } else {
            Write-Host "  WARNING: $($leftovers.Count) items remain in source, force removing..."
            Remove-Item $src -Force -Recurse -ErrorAction SilentlyContinue
        }
    }

    # Create junction
    try {
        New-Item -Path $src -ItemType Junction -Value $dst -Force -ErrorAction Stop
        Write-Host "  Junction created: $src -> $dst"
        Write-Host "  SUCCESS: $label migrated"
    } catch {
        Write-Host "  FAILED to create junction: $_"
        Write-Host "  Files already moved to $dst, but junction not created."
        Write-Host "  You can manually create: mklink /J `"$src`" `"$dst`""
    }
}

# Final report
Write-Host "`n=== Final Check ==="
$c = Get-PSDrive C
Write-Host "C drive free: $([math]::Round($c.Free/1GB, 2)) GB"
$duration = [math]::Round(((Get-Date) - $StartTime).TotalMinutes, 1)
Write-Host "Duration: $duration minutes"

# Verify junctions
Write-Host "`n=== Junction Verification ==="
foreach ($m in $migrations) {
    $src = $m.Src
    if (Test-Path $src) {
        $attr = (Get-Item $src -Force).Attributes
        $isJunction = $attr -band [System.IO.FileAttributes]::ReparsePoint
        if ($isJunction) {
            $target = (Get-Item $src -Force).Target
            Write-Host "  OK: $src -> $target"
        } else {
            Write-Host "  WARN: $src exists but is NOT a junction"
        }
    } else {
        Write-Host "  MISSING: $src"
    }
}
