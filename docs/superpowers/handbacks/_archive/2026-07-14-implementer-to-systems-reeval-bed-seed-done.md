---
from: implementer
to: systems
status: consumed
topic: "[裁定 Option 1 完] reeval_bed 加 seed(seed_val)——determinism 達成:Team7 兩跑 jsonl hash 相同(170faba,264行);可跑 seed1337 acceptance"
---
# Hand Back：reeval_bed seed 修（determinism 達成）

`feat/survival-execution-lock` @ `1f5a8764`（已 push），承接裁定 Option 1。

## 做了什麼（L3）
`reeval_attribution_bed.gd`：
1. `GameSetup.setup` 前加 `seed(seed_val)`（播全域 runtime RNG 72 處 bare randf/randi，鏡射 `WarringHarness.run:91`）。
2. 更新頂部「第三種死法」註解：標已結案（3154d52e，Fix B 修 tap-gap）+ bed 現 seed 全域 RNG＝確定性，無非-seeded 依賴（防下個讀者誤解）。

## 驗（determinism 達成）
- `SPECIMEN_TEAM_ID=7 FORCE_FULL_HD=1 SPECIMEN_JSONL_OUT=<path>` **兩跑 jsonl hash 相同**：`170faba962c24311f3d1b47e2a810143`（各 264 行）。→ **跨-run 確定，seed1337 reproducible**。
- DONE 無 SCRIPT ERROR；bed attribution 輸出正常（世界因全域播種而變＝264 vs 前 265 行，裁定已接受；bed 無硬斷特定隊命運）。

## 現狀（acceptance 工具鏈備齊）
execlock 分支 `1f5a8764` 現有：非侵入 LOD + write_jsonl + reeval_bed（force_full_hd + jsonl + seeded determinism）→ **measurer 可跑 seed1337 reproducible 全-HD acceptance**：
- headline churn/attrition：branch(`1f5a8764`) vs base 在 force_full_hd。
- seed1337 `.specimen.jsonl`（force_full_hd + SPECIMEN_JSONL_OUT）給 QA 故事判官。

## 待確認
- 純 debug 床修（determinism 正確性），無設計改、無需 R②。完成判定 = systems + reviewer/QA。context hold warm 等 measurer 結果 → 裁決信。
