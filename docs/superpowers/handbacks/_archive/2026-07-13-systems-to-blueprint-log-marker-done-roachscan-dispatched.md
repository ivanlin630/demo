---
from: systems
to: blueprint
status: consumed
topic: [①做完+④已派measurer] candidate log可派性標記✗已上;蟑螂普查工單已發measurer;②③已結案
measured_at_head: 98a9841-dirty
---

# 四題執行回報

用戶四題定案（`2026-07-13-blueprint-to-systems-and-measurer-final-dispatch.md`，consumed）逐項落地。

## ① candidate log 標可派性 → 做完
`specimen_tracer.gd` 改三處：
- `capture_options`：每 candidate 算 `to_task` target，鏡射 dispatch 迴圈跳過條件（`faction_ai:1844` task==IDLE / `:1846` target==(-1,-1) 非 FLEE）→ 存 `nd`(不可派) 旗標。只讀 lookup、specimen-gated（enabled=false 預設→零非-specimen 成本）。
- `_print_entry`：不可派 option print 加 `✗`（如 `覓食=0.87✗ 買糧=0.58`）。
- flush 表頭加圖例（`✗=當下不可派/無target，util雖高仍fallthrough`）。

**驗證狀態（誠實）**：3 個 bed 跑過**零 SCRIPT ERROR/Parse Error**，marker 邏輯是 dispatch 迴圈跳過條件的**逐字鏡射**。但**尚未捕到正向 ✗ render**——econ/warring specimen 那些窗內 top option 剛好都可派；我用 seed1337 Team7 快速重跑想抓 Team7 那個已知覓食✗ 案例，但我的 specimen 設法（`specimen_team_ids=[7]`）30 天 0 entries（未命中 measurer 那條 Team7 決策路徑=harness 差異）。**正向 ✗ 目視確認交由 measurer 的蟑螂普查**（他們有能重現 Team7 lockstep 的 harness，那正是此 marker 服務的場景）。若 measurer 跑出仍無 ✗，我再查 marker。

## ④ crisis de-patch → 押後，蟑螂普查已派 measurer
工單 `2026-07-13-systems-to-measurer-roach-scan-undispatchable-lockstep.md`（`to:measurer status:open`，Monitor 會喚）。要 measurer：
- 用現有 3-5 隊 90 天日記掃 winner 連續 >30 天同一 task 不變的隊。
- 疑似隊設 specimen 重跑，讀新 ✗ 標記 timeline，判「util-top 恆 ✗ fallthrough」是否成立 + fallthrough 動作有沒有解決需求（健康 vs 病態判準已寫工單）。
- 找到真蟑螂 → 回報細節；查無 → 回報「查無蟑螂」。
- **crisis de-patch(i/ii) 定序 gating 在此結果**——measurer 回報後我才回頭問用戶。

## ②③ 已結案
- ② forage radius-1 維持（刻意設計）。
- ③ established 稀有度維持 A（霸主 archetype 專屬、1/3 seed 可接受）。

## 現況
系統 standby，唯一在飛 = measurer 蟑螂普查。等其結果 → 回頭問用戶 crisis de-patch 定序。此信可 consume。

（可溯源：本信無新量測數字；marker 驗證的 raw log = `docs/measurements/2026-07-13-specimen-undispatchable-smoketest-98a9841-dirty.log`（0 錯誤，0 ✗），measured_at_head=98a9841-dirty。）
