---
from: systems
to: implementer
status: open
topic: [小工單] 補plan_phase分布probe(比照rung_dist)—warring_harness記organic各隊phase+偏置option分布;S3前先驗同質化風險;疊main(已含S1+S2)
---

# 小工單：plan_phase 分布 probe（S3 前 organic 驗同質化）

S2 已 merged main（phase 導出+偏置在 main）。blueprint 要 S3 前先 organic 驗「≥2 種 phase 模式」（湧現誠實化驗收,防野心分布窄同質化到 S4 GUI 才發現）。**單元測試看不到分布,需 organic probe。** 疊 main（已含 S1+S2），可直接改 warring_harness（debug 檔，非 feature worktree——小工具改）。

## 做
`scripts/debug/warring_harness.gd`（比照既有 `rung_dist` snapshot 模式，S1 result 有此欄）：
1. 加 `_plan_phase_snapshot(state) -> Dictionary`：掃全隊,統計各 `team.plan_phase` 分布（`{"求糧":n, "成長":n, "聚勢":n, "立國":n, "":n}`）。
2. 掛進 `_snapshot(month, state)`（月度）+ 最終 result（比照 farming_final/food_econ）→ key `plan_phase_dist`。
3. **順帶記偏置 option 命中**（可選）：各隊當前 phase 對應偏置 option 是否真被選（`current_task`/`current_option` vs phase map）——看偏置有無實效。至少 phase 分布必記。
4. determinism 不破（純讀 state 統計,零 randf）。

## 驗收（handback to:measurer）
- measurer organic 快照（default.json 少 seed 短窗 3mo，Tier2 但小）：
  1. **≥2 種明顯不同 phase 模式**（不同個性/隊形落不同 phase）——湧現誠實化標準。
  2. **偏置實效**:phase 隊有無真偏 phase-option（求糧隊真多覓食/買糧）。
  3. 若高度同質化 → **記錄非判失敗**（已知野心分布窄風險，誠實標記過）→ 給 S4 GUI + 整包 established 驗收參考。
- 純 probe，零 sim 邏輯改;determinism byte-identical。

## 註
- 這是 probe-only 小改（warring_harness debug 檔），非 S3。S3（survival-bypass）待此 organic 驗回報後 dispatch。
- 卡點 → to:systems。
