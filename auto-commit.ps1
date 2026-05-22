# Auto-commit watcher for matlab-modulation
$repo = "E:\ai\ai-claude\matlab"
$watcher = [System.IO.FileSystemWatcher]::new($repo)
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true

$timer = $null
$lock = [object]::new()

$action = {
    # Debounce: reset timer on each change, commit after 10s of no changes
    if ($null -ne $timer) { $timer.Dispose() }
    $timer = New-Object System.Timers.Timer
    $timer.Interval = 10000
    $timer.AutoReset = $false
    $event = Register-ObjectEvent $timer Elapsed -Action {
        $changes = git -C $repo status --porcelain
        if ($changes) {
            git -C $repo add -A
            $msg = "auto: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
            git -C $repo commit -m $msg
            git -C $repo push 2>&1 | Out-Null
        }
    } | Out-Null
    $timer.Start()
}

$handlers = @()
$handlers += Register-ObjectEvent $watcher Changed -Action $action
$handlers += Register-ObjectEvent $watcher Created -Action $action
$handlers += Register-ObjectEvent $watcher Deleted -Action $action
$handlers += Register-ObjectEvent $watcher Renamed -Action $action

Write-Host "Watching $repo for changes... (Ctrl+C to stop)"
try { Wait-Event } finally { $handlers | Unregister-Event -Force; $watcher.Dispose() }
