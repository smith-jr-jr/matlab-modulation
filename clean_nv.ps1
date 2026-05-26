$ErrorActionPreference = "Continue"

# Step 1: Stop NVIDIA services
Write-Host "Step 1: Stopping NVIDIA services..."
$svcs = @(Get-Service | Where-Object { $_.Name -match 'NVDisplay|NVContainer|NvTelemetry|NVLocalSystem' -and $_.Status -eq 'Running' })
foreach ($s in $svcs) {
    try {
        Stop-Service $s.Name -Force -ErrorAction Stop
        Write-Host "  Stopped: $($s.DisplayName)"
    } catch {
        Write-Host "  Failed to stop $($s.DisplayName): $_"
    }
}

# Step 2: Kill remaining NVIDIA processes
Write-Host "Step 2: Killing NVIDIA processes..."
$procs = @(Get-Process | Where-Object { $_.ProcessName -match 'nvcontainer|nvidia|nvdisplay|nvsphelper|nvbackend|nvapi|nvapp' })
foreach ($p in $procs) {
    try {
        Stop-Process -Id $p.Id -Force -ErrorAction Stop
        Write-Host "  Killed: $($p.ProcessName) (PID: $($p.Id))"
    } catch {
        Write-Host "  Could not kill $($p.ProcessName): $_"
    }
}

Start-Sleep -Seconds 2

# Step 3: Delete NVIDIA app folder
Write-Host "Step 3: Deleting NVIDIA app folder..."
$target = 'C:\ProgramData\NVIDIA Corporation\NVIDIA app'
if (Test-Path $target) {
    try {
        $size = (Get-ChildItem $target -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        Remove-Item -Path $target -Recurse -Force -ErrorAction Stop
        Write-Host ("  Deleted: " + [math]::Round($size/1GB, 2) + " GB")
    } catch {
        Write-Host "  FAILED: $_"
    }
} else {
    Write-Host "  Already deleted"
}

# Step 4: Restart services
Write-Host "Step 4: Restarting NVIDIA services..."
$toRestart = @('NVDisplay.ContainerLocalSystem', 'NVContainerLocalSystem')
foreach ($sn in $toRestart) {
    try {
        Start-Service $sn -ErrorAction Stop
        Write-Host "  Started: $sn"
    } catch {
        Write-Host "  Could not start $sn - will restart on its own or after reboot"
    }
}

# Final disk check
$c = Get-PSDrive C
Write-Host ("`nFinal C drive free: " + [math]::Round($c.Free/1GB, 2) + " GB")
