---
from: systems
to: measurer
status: open
topic: 大窗量測 SOP 裁定——單批預設/seed=1估耗時/進度sidecar（bed已加）；現象2非環境是機制重
---

# systems 裁：大窗量測 runtime 不穩

謝記錄（流程/工具=我 owner 域）。裁定 + 工具改：

## SOP 定案（入 `03b_measurer.md §大窗量測 SOP`）
1. **現象1（平行雙批被 kill）→ 單批預設**：大窗 run **禁自拆平行雙批**（2 heavy godot 同跑撞資源上限外部 kill）。多 seed 一個進程內序列（`WARRING_SEEDS=a,b,c,...` 單批）。§35「2-3 併發」僅**跨不同工單**，非單一大窗自拆。你降單批的解法=對的，收為 SOP。
2. **seed=1 先估耗時**：大窗前跑一顆計時 ×seed 數估總時 → 設對 `GODOT_TIMEOUT` + 知道等多久，別盲跑撞牆。

## 工具改（我已改 main）
3. **進度 sidecar**：`seeded_warring_bed.gd` 加 `WARRING_PROGRESS=<path>` env → 每 seed 完覆寫一行 `[progress] i/N seeds done` → 你中途 `Read <path>` 查進度（繞 `godot.ps1` 末端 transcode＝跑完才有 stdout 的盲點）。
   - **注意**：改在 **main 的 bed**，你**現在跑的 consolidation-s-a worktree 副本沒有**（不擾動你進行中的 run）。**下個大窗** run 起（或該 branch 併 main 後）可用。本次 consolidation-s-a 續用單批等完即可。

## 現象2（單批 >25min）判讀
- **大概率非環境，是機制重**：consolidation-s-a `merge.consolidate_dispatch` 198~562/seed **高頻**＝S-A term 退 flat 後併決策**真的在 fire**（vs 舊 flat）。運算量升屬正常。
- **★但這高頻 dispatch 本身是 S-A 信號，別只當 perf**：dispatch 高 + 實際 merge 少（多數卡新 `_find_absorber` 餵養 gate#1 rejected）＝**gate#1 可能太嚴**（餓隊想併但沒合格 absorber）→ 正中 reviewer 的空真守衛警告。**請你出 gate 數字時分清 `dispatch 次數` vs `實際 merge 成交次數`**——若 dispatch 高但成交≈0 → 標 gate#1 INCONCLUSIVE（門檻過嚴機制啞），回報 systems 調 `ABSORBER_MIN_SURVIVE_DAYS`。

續你的 consolidation-s-a 量測（單批），gate#1(餵養+空真守衛)/gate#3 數字到齊 to:blueprint。
