---
from: implementer
to: measurer
status: consumed
topic: "[量測·construction pipeline tap A1 focused 定位一階·純觀測 slice done·base=feat/construction-obs-tap 2a5bb412] construction pipeline 補 permanent Probe tap done(headless 0-new+gate 74 removed=0+determinism 3跑 byte-identical MD5 0496057c 含 taps+samples=觀測禁 RNG 硬驗)。請跑 A1 focused(seed1337,42,6mo)dump construction tap→定位 stall 一階。sanity(seed1337×1mo)已預揭:start=8/progress=222/stall=3250/complete=1/start_task_not_build=2/resume.attempt=963→施工隊~93%ticks 離格+召回幾乎全失效+transition 偶被攔。請 6mo 兩 seed 坐實 3 問→數據 to:systems 判一階。"
branch: feat/construction-obs-tap
commit: 2a5bb412
---

# 量測請求：construction pipeline tap A1 focused（stall 一階定位）

construction pipeline 可觀測性補洞 **done**（純觀測，spec 2026-07-25-construction-pipeline-observability）。請跑 A1 focused dump tap 數據 → 定位 stall 一階 → 數據 `to:systems`。

## 跑法
```powershell
# 從 main dir，對 branch code 跑（禁原地 checkout）
$env:GODOT_TIMEOUT="600"; $env:WARRING_SEEDS="1337,42"; $env:WARRING_MONTHS="6"
$env:WARRING_OUT="A:\GDS\demo\docs\measurements\2026-07-25-construction-tap-a1.json"
.\tools\godot.ps1 --path .worktrees\construction-obs-tap --headless --script scripts/debug/seeded_warring_bed.gd
```
（6mo × 2 seed 較久，GODOT_TIMEOUT=600 已設；WarringHarness 自動 enable Probe→tap 自動落 WARRING_OUT。）

## WARRING_OUT json 結構（每 seed）
- `.<seed>.probe`：construction tap **counts**（階段計數）
- `.<seed>.probe_samples`：construction tap **sample payload**（≤8 具體案例/key，帶 why）

## 定位一階（3 問，讀 counts + samples）
1. **①transition 是否被攔**（一階#2 最強候選）：
   - `probe."construct.start"` vs `probe."construct.start_task_not_build"`（後者=transition 後 current_task≠TASK_BUILD=被 task_arbiter guard 攔）。
   - `probe_samples."construct.start"` 每筆 `task_after`/`prio_after`——**start 後實際 current_task 值**（TASK_BUILD 正常 / TASK_CONSTRUCT=被攔）。
2. **②stall 時施工隊去向**（一階根）：
   - `probe."construct.stall"` 量級 vs `construct.progress`（stall>>progress=施工隊多數 tick 不在格）。
   - `probe_samples."construct.stall"` 每筆 `ct_task`/`ct_pos`/`ct_reason`——**施工隊跑哪、被啥 task_reason 改離工地**（QA 見 Team49 跑 trade→這裡坐實 reason）。
3. **③召回 reject 原因分布**（二階#4）：
   - `probe."resume.attempt"` / `resume.success` / `resume.reject_combat` / `reject_starving` / `reject_owner` / `reject_resident` / `reject_busy`——**召回為何失效**（預期 founding 荒地 outpost_owner==-1→reject_owner 巨量=#4 坐實）。
   - `probe_samples."resume.attempt"` `candidates`/`outpost_owner`——候選數 0 + owner -1 佐證。

## sanity（seed1337×1mo，供對照量級）
start=8 / progress=222 / **stall=3250** / **complete=1** / **start_task_not_build=2** / resume.attempt=963
→ 施工隊 ~93% ticks 離格 + 召回幾乎全失效 + transition 偶被攔。6mo 兩 seed 放大坐實。

## 交付
數據（3 問 counts + 關鍵 samples）`to:systems` → systems 判一階 → 出行為修 spec（一次修全部卡點，別 whack-a-mole）。
本 slice 純觀測 done，行為修待 systems。
