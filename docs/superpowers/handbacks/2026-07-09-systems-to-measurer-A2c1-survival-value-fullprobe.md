---
from: systems
to: measurer
status: consumed
topic: A2c-1 survival-value 標準 full_probe 3-way 量測（下游改藍圖判，非 QA）
---

# 量測工單：A2c-1 survival-value 3-way full_probe

branch `feat/machine-A2c1` @ `4e57ea9`（`d70d83b` survival-value + `4e57ea9` can_reach guard）。implementer 自跑閘全綠（import/const PASS sites=29/sanity 21600 tick 無崩 invariants=0/SCRIPT ERROR 16×→0）。

## 跑什麼：★標準 full_probe 3-way（新流程首個實例）
同 seed **1337**，3 way 並排 JSON：
- **baseline**（pre-fold，主 main baseline worktree）
- **純 fold** @423924c（鐵證檔 `scratchpad/a2c1_fp2_fold.json` 可複用/重跑）
- **升級版** @4e57ea9（本 slice）

`godot --path .worktrees/<各>` 跑 `seeded_warring_bed`/full_probe 床，**全維度一次抓齊**（`03b_measurer.md §④` 標準床）：
- 決策面（★關鍵）：`merge.consolidate_dispatch`、`merge_appl.total`/`chose_整併`/`chose_other`
- 生存面：`extinct.starve`、avg team-size、team-size 直方圖、`join.resolve`
- 衝突面：`attack-eligible`、`conq.declared`（觀察值，不設 target）
- 結構面：teams/faction 消長

## 驗收線（spec §驗收法，產數字別自判——藍圖判）
1. starvation 回健康：`extinct.starve` ≲16（純fold 19→回落）；avg-size 回升（純fold 5.6）；`join.resolve` 回升（純fold 14）
2. merge 落 (154, 978) 中間、明顯偏離兩端
3. `merge_appl.chose_other` 仍可觀比例（>0%，非再逼近 100% 併）
4. 衝突面觀察值記錄，不設 target

## ★硬閘（產數字標記 pass/fail 給藍圖，非自判）
- **閘6**：`merge.consolidate_dispatch` **不得 ≥800**（防重造 978 artifact）。
  - **famine-window 判讀**（reviewer caveat）：若 merge 衝高逼近閘，先判高峰是否伴 famine event 窗口——隨 famine 起訖伴生=健康湧現、與 famine 脫鉤常駐高位=formula 偏 flat=真 FAIL。判準：merge 高峰對不對得上 food_days 探底窗口。
- **閘7**：`extinct.starve` **不得 >19**（不比純fold 差）。

## 產物 + 流轉（★新流程）
- `docs/process/verdicts/A2c1.fullprobe.json`（3-way 並排）+ handback **`to:blueprint`**（非 qa；2026-07-09 起下游改藍圖判 release-pass，見 `03b_measurer.md`/`04_qa.md` banner）。
- 一封完整信（鐵律6，禁分批）。缺任一維度/守衛→標 `incomplete:[…]` 報藍圖，別寄部分信。
- 你產數字，藍圖判門檻 + 決定 pass / 升用戶。
