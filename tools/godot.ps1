#!/usr/bin/env pwsh
# Godot wrapper: Godot win console exe writes stdout in system locale (CP950).
# ★★★PARSE ERROR 長得像【卡住】，不像【錯誤】（2026-09-08 血證，implementer 發現）
#   Godot 對【載入失敗】彈阻斷對話框 —— ★--headless 也彈。
#   ⇒ 一個 parse error / 繼承錯誤的腳本，表現是【燒滿 GODOT_TIMEOUT 才被砍】，
#     而不是一個二秒就回來的錯誤訊息。
#   ★★血證二則：①`data_test.gd`（extends Node）被全掃拉進去 ⇒ 184s 而且被判【綠】；
#     ②抽函式時誤刪了下游還在用的變數 ⇒ 同樣燒滿逾時。
#   ⇒ ★★★改了 .gd 之後、或遇到【跑很久而沒有輸出】時，先跑：
#       godot --headless --check-only --script <那支.gd>      ← 兩秒內就看得到 Parse Error
#     而不是去猜【為什麼它卡住】。
# Launch with a hard timeout (kill if it hangs), then transcode CP950 -> UTF-8.
# Usage: .\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
# Timeout: default 360s; override via env GODOT_TIMEOUT (seconds).
#   Guards against: assert-before-quit idle hang + concurrent import-lock deadlock.
# Worktree note: tools/godot/*.exe is gitignored (absent in worktrees) -> fallback to main repo path.
# NOTE: keep this file ASCII-only. PS 5.1 reads BOM-less files as ANSI; non-ASCII comments corrupt parsing.
# STDOUT ENCODING (2026-09-04). This wrapper decodes Godot's CP950 bytes into .NET strings,
# but PS 5.1 then RE-ENCODES them on the way out using the ANSI codepage whenever stdout is
# redirected (a file, or a pipe into any caller). So the transcode above was undone at the last
# step and consumers got CP950 after all. It went unnoticed for a long time because every
# godot-backed merge gate happens to have an ASCII-only expect string -- i.e. the bug was
# invisible to the channel we check through. Measured before/after with a two-char probe:
# without this line the bytes are b2 cf ae da (CP950); with it they decode as U+7D2E U+6839.
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false
# CALLER CONTRACT (2026-09-04, measured -- this is a real limit, not a style note).
# The line above only takes effect while nothing has written to stdout yet in this process
# chain. PowerShell fixes its host output writer on first write, and neither
# [Console]::OutputEncoding nor [Console]::SetOut can retarget it afterwards (both tried,
# both failed). So:
#   powershell -File tools/godot.ps1 ...            -> UTF-8 (verified: U+7D2E U+6839)
#   a.ps1 prints, then calls tools/godot.ps1        -> CP950 (verified: b2 cf ae da)
#   a.ps1 writes to STDERR, then calls this script  -> UTF-8 (verified)
# A launcher that wants to announce something before the run must use
# [Console]::Error.WriteLine(...), not plain output. This bit us once already: a detached
# warring run printed its env banner to stdout first and the whole 90-day log came back CP950.
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$exe = Join-Path $root "godot\Godot_v4.2.2-stable_win64_console.exe"
if (-not (Test-Path $exe)) {
    $exe = "A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe"
}
# Class-cache guard (2026-09-03). A fresh checkout (e.g. `git worktree add` of an old
# commit) has no .godot/global_script_class_cache.cfg. Without it EVERY class_name type
# fails to resolve, the script is never loaded, and the run prints parse errors only --
# i.e. a grep for failures returns ZERO, which reads exactly like "ran fine, all clean".
# That misread already happened twice in one day, in opposite directions:
#   "cache missing" read as "the bed is broken", and "cache missing" read as "the tree was clean".
# Cost note (measured, not guessed): --import takes ~22s even on an already-imported tree,
# so running it unconditionally would add ~22s to EVERY call (merge-gates has 12 of them).
# Therefore: import only when the cache file is ABSENT, and say so on stdout.
# The check itself is one Test-Path, i.e. free on the normal path.
$skipCacheGuard = $false
foreach ($a in $args) { if ($a -eq "--import") { $skipCacheGuard = $true } }
if (-not $skipCacheGuard) {
    $projPath = (Get-Location).Path
    for ($i = 0; $i -lt ($args.Count - 1); $i++) {
        if ($args[$i] -eq "--path") { $projPath = $args[$i + 1] }
    }
    $cacheFile = Join-Path $projPath ".godot\global_script_class_cache.cfg"
    if (-not (Test-Path $cacheFile)) {
        Write-Output "[godot.ps1] class cache MISSING: $cacheFile"
        Write-Output "[godot.ps1] running --import first (one-off, ~20s). Without it every class_name type"
        Write-Output "[godot.ps1] fails to resolve and this run would print ZERO failures while testing NOTHING."
        $imp = Start-Process -FilePath $exe -ArgumentList @("--headless", "--path", $projPath, "--import") -NoNewWindow -PassThru -Wait
        # Third cause (2026-09-05, blood evidence): --import can RUN, exit 0, and still leave the
        # cache empty (8 bytes) in a fresh worktree. The old message reported the exit code -- a
        # state the reader had to interpret -- and then the run failed with unresolved types, which
        # reads as "the change I just made broke it". A guard must report the DISPOSED RESULT.
        # Predicate is semantic, not a size threshold: a real cache lists entries as `"class": &"X"`.
        $built = (Test-Path $cacheFile) -and ((Get-Content $cacheFile -Raw -ErrorAction SilentlyContinue) -match '"class":')
        if ($built) {
            Write-Output "[godot.ps1] import finished (exit $($imp.ExitCode)); cache BUILT ($((Get-Item $cacheFile).Length) bytes); continuing."
        } else {
            Write-Output "[godot.ps1] *** import RAN (exit $($imp.ExitCode)) BUT THE CACHE IS STILL EMPTY ***"
            Write-Output "[godot.ps1] This is the THIRD cause, not stale-cache and not a missing type:"
            Write-Output "[godot.ps1] --import did not take in this tree (seen in fresh `git worktree add`)."
            Write-Output "[godot.ps1] Every class_name type will fail to resolve and the run below tests NOTHING"
            Write-Output "[godot.ps1] while it may still print ZERO failures. Do NOT read the errors as your change."
            Write-Output "[godot.ps1] If this branch adds no new class_name file, the main tree's cache is equivalent:"
            Write-Output "[godot.ps1]   verify equality first, then copy .godot\global_script_class_cache.cfg over."
        }
    }
}
$timeoutSec = if ($env:GODOT_TIMEOUT) { [int]$env:GODOT_TIMEOUT } else { 360 }
# STREAMING (2026-09-03, systems). The old shape redirected stdout to a temp file and printed
# it only after the process exited. That is correct output but wrong timing: if THIS wrapper is
# killed from outside (an outer timeout), the caller gets ZERO bytes even though the run had
# already printed thousands of lines. Measured: a 3-seed measurement was lost exactly that way.
# Streaming keeps the CP950->UTF-8 transcode (that is the only reason the temp file exists) but
# emits as the run goes. Decode only up to the LAST COMPLETE NEWLINE -- CP950 is multi-byte and
# a chunk boundary in the middle of a character produces mojibake.
# Verified before swapping: byte-identical output vs the old shape on material_hold_test /
# settlement_s2b_test / seam1_registry_test, AND the point of the change -- killed from outside,
# old shape produced 0 bytes, this one produced 713751 bytes.
# BUSY BEACON (2026-09-06, systems). bash-guard guard #2 warns when another role is already
# running Godot -- two long runs share the CPU and CONTAMINATE perf numbers. That guard read
# .busy.* beacons that measurer/implementer were supposed to hand-write, and a 2026-09-06 audit
# found ZERO beacons had ever been written: the population was always empty, so the guard always
# passed and never once fired -- while two Godot processes were in fact running concurrently at
# that very moment. A guard whose input is never produced is indistinguishable from a guard that
# looked and found nothing.
# So the wrapper stamps it itself: this is the single entry point for every long run.
# The beacon carries the PID because the OPPOSITE failure is just as bad: if this process is
# killed the cleanup never runs, the beacon leaks, and a permanently-stale beacon turns
# "never fires" into "always fires" -- the same disease with the sign flipped. Readers MUST
# treat a beacon whose PID is dead as ABSENT.
# The run window goes to an out-of-band log, NOT to stdout: several gates compare output
# byte-for-byte (fp), and a timestamp line in the stream would break every one of them.
$beaconRole = if ($env:SESSION_ROLE) { $env:SESSION_ROLE } else { "unknown-$PID" }
$hookDir = "A:\GDS\demo\.claude\hooks"
$beaconFile = Join-Path $hookDir ".busy.$beaconRole"
$runLog = Join-Path $hookDir ".godot-runs.log"

# 2026-09-08 (implementer found it, systems ruled). GetTempFileName() has only 4 hex digits,
# so it throws once the temp dir holds 65535 tmpNNNN.tmp files -- and killed/orphaned wrappers
# never reach their Remove-Item, so the count only grows. When it threw, $tempOut became $null:
# Godot's stdout went nowhere, Pump-Out spat a Test-Path error every 150ms, the deadline loop
# kept counting, and the run was killed at the timeout and RECORDED AS 'timeout'.
# That is the worst shape of lie: an infrastructure failure wearing the name of a slow bed.
# Fix per ruling: (1) our own scratch dir with unique names (no 65535 ceiling), and
# (2) failure gets ITS OWN NAME -- not timeout, not crash. Callers must be able to tell
# "the wrapper could not start" apart from "the bed misbehaved".
# NOTE: -ErrorAction Stop on every New-Item below is load-bearing. New-Item emits a
# NON-TERMINATING error by default, so try/catch does not see it: the first version of this
# guard let the run continue with unusable paths and recorded it as 'ok'. A guard that cannot
# fire is worse than no guard, because it reads as coverage.
$scratchDir = Join-Path $hookDir "wrapper-scratch"
try {
    if (-not (Test-Path $scratchDir)) { New-Item -ItemType Directory -Path $scratchDir -Force -ErrorAction Stop | Out-Null }
    # Killed wrappers never reach their Remove-Item, so this dir leaks exactly the way the
    # system temp dir did. Bound it here instead of waiting for a second incident: drop files
    # older than 6h at startup. 6h is far longer than any legitimate run (slowest bed ~190s).
    try {
        Get-ChildItem $scratchDir -File -ErrorAction SilentlyContinue |
            Where-Object { ((Get-Date) - $_.LastWriteTime).TotalHours -gt 6 } |
            Remove-Item -Force -ErrorAction SilentlyContinue
    } catch { }
    $stamp = (Get-Date).ToString('yyyyMMddHHmmssfff')
    $tempOut = Join-Path $scratchDir ("out-$PID-$stamp-" + [guid]::NewGuid().ToString('N') + ".txt")
    $tempErr = Join-Path $scratchDir ("err-$PID-$stamp-" + [guid]::NewGuid().ToString('N') + ".txt")
    New-Item -ItemType File -Path $tempOut -Force -ErrorAction Stop | Out-Null
    New-Item -ItemType File -Path $tempErr -Force -ErrorAction Stop | Out-Null
} catch {
    Write-Output "[GODOT WRAPPER FAIL: no-scratch-file] $($_.Exception.Message)"
    Write-Output "[GODOT WRAPPER FAIL] scratch dir = $scratchDir"
    Write-Output "[GODOT WRAPPER FAIL] the run did NOT start -- this is NOT a bed timeout and NOT a bed crash."
    try {
        "$((Get-Date).ToString('yyyy-MM-ddTHH:mm:ss'))`t$((Get-Date).ToString('yyyy-MM-ddTHH:mm:ss'))`t$beaconRole`tpid=$PID`twrapper-error`t$($args -join ' ')" |
            Out-File -FilePath $runLog -Encoding ascii -Append
    } catch { }
    exit 97
}

# --- Tree provenance stamp (2026-09-07) -------------------------------------
# Blood evidence: a 90d acceptance run used --path <worktree>, which reads the
# WORKING TREE, not any commit. Three bed improvements were sitting uncommitted,
# so the verdict was built on code that existed nowhere anyone could fetch.
# "I measured it" != "anyone else can measure it" -- and only the person who
# aimed --path knows which tree they aimed at. So the wrapper states it, every
# run, in the output itself. No discipline required.
$provPath = (Get-Location).Path
for ($i = 0; $i -lt ($args.Count - 1); $i++) {
    if ($args[$i] -eq "--path") { $provPath = $args[$i + 1] }
}
try {
    $provSha = (& git -C $provPath rev-parse --short HEAD 2>$null)
    $provDirty = @(& git -C $provPath status --porcelain 2>$null)
    if ($provSha) {
        # Only dirt that can change the RUN matters. Docs churn is constant here
        # (six sessions share this repo), and a stamp that shouts every time is a
        # stamp people learn to ignore -- the same 'drowned in noise' failure as a
        # push_error on every tick.
        $codeDirty = @($provDirty | Where-Object { $_ -match ' (scripts|config|tools|addons)/' })
        if ($codeDirty.Count -gt 0) {
            Write-Output "[TREE] path=$provPath commit=$provSha clean=NO code-dirty=$($codeDirty.Count)"
            Write-Output "[TREE]   *** measuring the WORKING TREE, not commit $provSha ***"
            foreach ($d in ($codeDirty | Select-Object -First 8)) { Write-Output "[TREE]   $d" }
        } elseif ($provDirty.Count -gt 0) {
            Write-Output "[TREE] path=$provPath commit=$provSha clean=code-yes (docs-dirty=$($provDirty.Count), does not affect this run)"
        } else {
            Write-Output "[TREE] path=$provPath commit=$provSha clean=yes"
        }
    } else {
        Write-Output "[TREE] path=$provPath commit=UNKNOWN (git said nothing)"
    }
} catch {
    Write-Output "[TREE] path=$provPath commit=UNKNOWN (git unavailable)"
}
# ---------------------------------------------------------------------------
# --- Time-scale stamp (2026-09-07) ------------------------------------------
# Blood evidence: three people in a row read "1000 tick" as "a long run".
# TICKS_PER_DAY = 1440, so it was 0.69 days -- 17 game-hours. A "no children
# were born" world-level finding was pure window artifact, and it travelled
# through a token, a spec and a ruling before anyone checked the unit.
# A number without its window length is not a number. So the wrapper prints
# the conversion factor on every run: the reader never has to know 1440.
try {
    $wsFile = Join-Path $provPath "scripts/data/world_state.gd"
    if (Test-Path $wsFile) {
        $tphLine = Select-String -Path $wsFile -Pattern 'const TICKS_PER_HOUR[^0-9]*([0-9]+)' | Select-Object -First 1
        if ($tphLine -and $tphLine.Matches[0].Groups[1].Value) {
            $tph = [int]$tphLine.Matches[0].Groups[1].Value
            $tpd = $tph * 24
            Write-Output ("[SCALE] TICKS_PER_HOUR=$tph TICKS_PER_DAY=$tpd  |  1000t=" + [math]::Round(1000/$tpd,2) + "d  10000t=" + [math]::Round(10000/$tpd,1) + "d  " + ($tpd*30) + "t=30d(1 month)")
            Write-Output "[SCALE]   *** a tick count without its day-conversion is not a number ***"
        }
    }
} catch { }
# ---------------------------------------------------------------------------
$runStart = Get-Date
if (Test-Path $hookDir) {
    try {
        "pid=$PID started=$($runStart.ToString('yyyy-MM-ddTHH:mm:ss')) args=$($args -join ' ')" |
            Out-File -FilePath $beaconFile -Encoding ascii -Force
    } catch { }
}

# COLLISION RECORD (2026-09-06). bash-guard warns before a Godot run, but a PreToolUse hook
# only ever sees calls that go THROUGH the tool -- a WMI-detached run does not, so neither a
# warning nor a hard block can reach it. The only thing that sits on both sides of that
# boundary is this wrapper. So instead of trying to PREVENT the overlap here, record it:
# "was there a collision, with whom, for how long" becomes a fact you can look up afterwards,
# which replaces the question "did anyone see the warning" -- a question nobody can answer.
if (Test-Path $hookDir) {
    try {
        $fresh = Get-ChildItem -Path (Join-Path $hookDir ".busy.*") -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -ne (".busy." + $beaconRole) -and ((Get-Date) - $_.LastWriteTime).TotalSeconds -lt 60 }
        # SAME-ROLE BLIND SPOT (2026-09-08). The filter above excludes this role's own
        # beacon -- deliberately, so a wrapper does not collide with itself. But the side
        # effect is that N concurrent instances of the SAME role never register a collision,
        # and that is by far the commonest overlap: one person spawning parallel work.
        # Blood evidence: 10 concurrent `systems` sweeps, ZERO collisions logged, 150 beds
        # timed out at the 360s cap while the average healthy run was 41s. The detector's
        # blind spot was exactly the collision that happened.
        # So: also look at the world directly -- another Godot already running is a fact
        # that does not care whose beacon it is.
        try {
            $others = @(Get-Process -Name "*odot*" -ErrorAction SilentlyContinue |
                Where-Object { $_.Id -ne $PID })
            if ($others.Count -gt 0) {
                "$($runStart.ToString('yyyy-MM-ddTHH:mm:ss'))`tCOLLISION-SAMEROLE`t$beaconRole`tgodot-already-running=$($others.Count)" |
                    Out-File -FilePath $runLog -Encoding ascii -Append
            }
        } catch { }
        if ($fresh) {
            $who = ($fresh | ForEach-Object { $_.Name -replace "^\.busy\.", "" }) -join ","
            "$($runStart.ToString('yyyy-MM-ddTHH:mm:ss'))`tCOLLISION`t$beaconRole`tstarted-while-running=$who" |
                Out-File -FilePath $runLog -Encoding ascii -Append
        }
    } catch { }
}

$cp950 = [System.Text.Encoding]::GetEncoding(950)
$proc = Start-Process -FilePath $exe -ArgumentList $args `
    -RedirectStandardOutput $tempOut -RedirectStandardError $tempErr `
    -NoNewWindow -PassThru
$sb = New-Object System.Text.StringBuilder
$script:pos = 0
function Pump-Out {
    if (-not (Test-Path $tempOut)) { return }
    try {
        $fs = New-Object System.IO.FileStream($tempOut, [System.IO.FileMode]::Open,
            [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
        try {
            if ($fs.Length -le $script:pos) { return }
            $fs.Position = $script:pos
            $buf = New-Object byte[] ($fs.Length - $script:pos)
            $n = $fs.Read($buf, 0, $buf.Length)
            $last = -1
            for ($i = $n - 1; $i -ge 0; $i--) { if ($buf[$i] -eq 10) { $last = $i; break } }
            if ($last -lt 0) { return }
            $chunk = $cp950.GetString($buf, 0, $last + 1)
            $script:pos = $script:pos + $last + 1
            [void]$sb.Append($chunk)
            # $chunk always ends with a newline, so -split leaves a trailing "" element: drop ONLY
            # that last one. Interior blank lines are real output and must survive.
            $parts = $chunk -split "`r?`n"
            for ($k = 0; $k -lt ($parts.Count - 1); $k++) { $parts[$k] }
        } finally { $fs.Dispose() }
    } catch { }
}
$deadline = (Get-Date).AddSeconds($timeoutSec)
$timedOut = $false
$lastBeat = Get-Date
while (-not $proc.HasExited) {
    Pump-Out
    # HEARTBEAT (2026-09-06). The beacon is refreshed, not just written once, so that a
    # killed wrapper leaves a beacon that goes STALE on its own. That is why the reader can
    # decide with one mtime check and never has to resolve a Windows PID from inside bash.
    # Self-expiring beats self-cleanup: cleanup is exactly what does not run when killed.
    if (((Get-Date) - $lastBeat).TotalSeconds -ge 10) {
        $lastBeat = Get-Date
        try { (Get-Item $beaconFile -ErrorAction Stop).LastWriteTime = $lastBeat } catch { }
    }
    if ((Get-Date) -gt $deadline) { $timedOut = $true; try { $proc.Kill() } catch {}; break }
    Start-Sleep -Milliseconds 150
}
try { [void]$proc.WaitForExit(5000) } catch {}
Pump-Out
# Read redirect files tolerantly: after a Kill the handles may not be released yet, so
# ReadAllBytes throws "being used by another process" and the whole stdout vanishes.
# FileShare::ReadWrite lets us read while the handle lives; retry with backoff covers the
# brief window where even shared open is refused. Returns empty array only if all attempts fail.
# Note: returns are comma-wrapped and typed [byte[]] - PowerShell unrolls arrays on output,
# which turns an empty (0-byte) file into $null and breaks Encoding.GetString().
function Read-BytesTolerant([string]$path) {
    for ($i = 0; $i -lt 5; $i++) {
        try {
            $fs = New-Object System.IO.FileStream($path, [System.IO.FileMode]::Open,
                [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
            try {
                $ms = New-Object System.IO.MemoryStream
                try { $fs.CopyTo($ms); return ,[byte[]]$ms.ToArray() } finally { $ms.Dispose() }
            } finally { $fs.Dispose() }
        } catch {
            Start-Sleep -Milliseconds 300
        }
    }
    return ,[byte[]]@()
}
$bytesOut = Read-BytesTolerant $tempOut
$bytesErr = Read-BytesTolerant $tempErr
Remove-Item $tempOut, $tempErr -ErrorAction SilentlyContinue
# Clear the beacon and record the run window out-of-band (see BUSY BEACON above).
# If this wrapper was killed, neither line runs: the beacon is left behind with a dead PID,
# which readers must treat as absent -- and its absence from the run log is itself the
# evidence that the run did not finish.
try {
    $runEnd = Get-Date
    # 2026-09-07 FIX (implementer found it): this row used to be written unconditionally,
    # so a run killed at the timeout deadline left EXACTLY the same evidence as a run that
    # finished. The row was being used as the 'did this run complete' witness, so a timeout
    # was silently counted as a completion -- and every 'no bad news' conclusion drawn from
    # a timed-out bed was therefore unfounded. The witness had the disease it was meant to cure.
    # The outcome now travels WITH the row: ok | timeout. No row at all still means the
    # wrapper itself died (killed from outside), which is a third, different state.
    $outcome = if ($timedOut) { 'timeout' } else { 'ok' }
    "$($runStart.ToString('yyyy-MM-ddTHH:mm:ss'))`t$($runEnd.ToString('yyyy-MM-ddTHH:mm:ss'))`t$beaconRole`tpid=$PID`t$outcome`t$($args -join ' ')" |
        Out-File -FilePath $runLog -Encoding ascii -Append
    Remove-Item $beaconFile -ErrorAction SilentlyContinue
} catch { }

$fullOut = $cp950.GetString($bytesOut)
$errText = $cp950.GetString($bytesErr)
# Reproduce the old boundary EXACTLY: the old shape did ONE split over ($out + $err), so no blank
# line appears between stdout and stderr, and a trailing "" IS emitted when the text ends with a
# newline. The complete lines were already streamed (without that trailing ""), so emit the rest.
$rest = $fullOut.Substring([Math]::Min($sb.Length, $fullOut.Length)) + $errText
$rest -split "`r?`n"
$text = $fullOut + $errText
if ($timedOut) { "[GODOT TIMEOUT ${timeoutSec}s - process killed]" }
# Stale-cache detector (2026-09-03). The guard above only covers a MISSING cache.
# A cache that EXISTS but is out of date (a new class_name file was added and nobody
# re-imported) produces the same family of symptom -- unresolved class_name types --
# and that reads like "the change I just made broke it". Half a guard is worse than none
# here, because after the missing-cache guard exists people stop suspecting this direction.
# So: after the run, if the output mentions unresolved types WHILE the cache file exists,
# say so. This detector cannot tell "stale cache" from "that class really does not exist",
# so the message names both, and it does NOT re-import on its own.
if ((-not $skipCacheGuard) -and (Test-Path $cacheFile)) {
    if ($text -match 'Could not find type "|Identifier ".*" not declared') {
        # "The cache EXISTS" is not the same as "the cache has content": an import that did not take
        # leaves an 8-byte file that passes Test-Path. Separate that case FIRST, otherwise the
        # two-cause message below sends the reader hunting for a stale cache or a missing type
        # when neither is true -- the list itself being incomplete is what costs the round.
        $hasEntries = ((Get-Content $cacheFile -Raw -ErrorAction SilentlyContinue) -match '"class":')
        if (-not $hasEntries) {
            Write-Output "[godot.ps1] *** cache file EXISTS but is EMPTY (no entries): $cacheFile ***"
            Write-Output "[godot.ps1] That is cause (c): --import ran or was skipped but never populated it."
            Write-Output "[godot.ps1] The unresolved types above are NOT evidence about your code."
        } else {
            Write-Output "[godot.ps1] unresolved class_name type(s) above, while the cache HAS ENTRIES: $cacheFile"
            Write-Output "[godot.ps1] two causes look identical here: (a) cache is STALE (new class_name added"
            Write-Output "[godot.ps1] without --import) or (b) that type genuinely does not exist. Try --import first."
        }
    }
}
