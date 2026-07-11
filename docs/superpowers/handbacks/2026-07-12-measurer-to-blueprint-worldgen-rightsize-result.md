---
from: measurer
to: blueprint
status: consumed
topic: world-gen variety 右尺寸快答——地板30/30全綠+佈局真異(7.5%重疊)+build-outpost 7/7seed皆fire(2-10次)，達標；outpost/faction數固定屬config顯設非bug
---

# 量測回報：world-gen variety 右尺寸快答（systems 裁定分三塊）

工單：`2026-07-12-systems-to-measurer-worldgen-rightsize.md` + addendum。worktree `.worktrees/worldgen-variety @8068adf`。

## ①地板/variety——純生成掃描（30 seed，秒級全跑完）
床新建：`scripts/debug/worldgen_floor_scan.gd`（只呼叫 `GameSetup.setup`，不跑 sim）。
- **`worldgen.floor_pass=1` / `floor_fail=0` 全 30 seed 皆過**（覆蓋度地板 100% 綠）。
- **佈局真不同**：跨 seed 據點座標平均重疊率 **7.5%**（低重疊=真散布，非同布局換皮）——§1 scatter 有機性坐實。
- **outpost 數(42)/faction 數(8) 全 seed 固定不變**——查 config 確認 `warring_states.json` 顯設 `total_count:42`，符合 implementer 自陳的 caveat（「config 明設則尊重，§2 range 只在無配置世界觸發」）。**非 bug，是預期行為**——本 config 測不到 §2 隨機範圍那段，需另一份無顯設 total_count 的 config 才驗得到（若你要驗 §2，我可另跑，非本次判準範圍）。

## ②build-outpost + regression——7 seed×1月短窗
`worldgen.build_outpost`：7/7 seed 皆 fire（101→10、111→9、1337→4、202→4、222→8、42→2、7→4次）——**普遍 fire，非罕見**。跑完無 SCRIPT ERROR，`[bed] baseline metric 已寫` 正常收尾（regression 面無異常訊號）。

## ③determinism——已確認（前信）
seed1337 兩跑 byte-identical ✅（不重複列）。

## ④全探針長跑參照（addendum，用戶要求保留）
現跑的 18-seed×3mo（`worldgen_final18`，用標準 `WarringHarness` 全探針）本身即符合「full_probe 參照基線」定義，**續當背景跑（detach，不 gate 本次判斷）**，完成後我會標記存檔為「world-gen variety 新基線參照」+ 走 §4 重 baseline。

## 綜合判讀
**快答四項全過**：地板 100%、佈局真異、build-outpost 普遍 fire、determinism 綠。**feature 達標**（我只出數字，質感/GUI 驗收留你）。outpost/faction 數固定是 config 特性非缺陷，供你參考是否要另測 §2 無顯設情境。

## 產物
- 床：`.worktrees/worldgen-variety/scripts/debug/worldgen_floor_scan.gd`
- json：`.worktrees/worldgen-variety/tools/orchestrator/runs/worldgen_shortwindow.json`
