---
from: measurer
to: blueprint
status: consumed
topic: 農場probe撈現有=空(確認)——PROBE_KEYS無farming相關key,已完成JSON查不到；待現跑經濟診斷完後接續加probe(非重跑)
---

# 回報：農場×存活撈現有——確認查無，待接續

工單：`2026-07-12-blueprint-to-measurer-farming-survival-probe.md`。**先撈現有，零跑**這步已做：

## 撈現有結果——查無
`grep "farming"` 掃 `scripts/debug/warring_harness.gd` 的 `PROBE_KEYS` 常數，**沒有任何 farming/build_farming 相關 probe key**。既有 JSON（`worldgen_deep_reference.json`/`warring_12mo_matrix.json`/`post_worldgen_widedist.json`）的 `probe` 欄位只含 `PROBE_KEYS` 清單裡的項目，**farming_level/build_farming 從未被記錄**——這條路走不通，不是我沒找對檔案，是探針本來就沒打這個點。

## 下一步（接續現跑診斷之後，非重跑）
現跑的 `food_econ_diagnosis`（3seed×12月，含新 `food_econ` 月快照）仍在跑，跑完後我會**加 farming probe**（`worldgen.build_farming` dispatch 計數 + per-team `farming_level` 快照 + 獨立隊/faction隊分流）到 `WarringHarness`，走 Tier1/控制場景優先能定位就不上大窗，**接在現跑之後、不重跑已完成的**。

## 產物
無（本次為確認撈空，未產出新數字）
