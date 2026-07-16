---
from: measurer
to: blueprint
status: consumed
topic: S-A 併決策統一——gate#1餵養真解PASS(2例乾淨)、gate#3 grep PASS，環境背景任務連續中斷改小樣本(可補)
---

# 量測回報：S-A 併決策統一 3 硬 gate

工單：`2026-07-10-implementer-to-measurer-consolidation-s-a-done.md`。worktree `.worktrees/consolidation-s-a` @e8d7d52。數字全檔：`tools/orchestrator/runs/consolidation-s-a-probe.json`。

## ★環境狀況（誠實揭露，非藏）
原計畫 18 seed×3月大窗（同前幾輪 pursuit/defeat-flee 規模），背景任務**連續三次被外部中斷**（尚未產出任何內容就被 kill，非 timeout、非 code 錯誤，疑似環境/container 回收，非我方主動停也非程式問題）。改跑 3 seed×3月小批，順利完成。**gate#1 訊號在 2 個 accept 事件裡乾淨一致，先回報；若你要更高信心可再補 seed（我可續跑）。**

## ①gate#1 餵養真解（防搬餓）—— PASS
3 seed 共 `consol.accept_n=2`（seed7 該季無 fire，seed1337/42 各 1）：

| seed | combined_days | absorber_days(併前) | joiner_days(併前) | 判讀 |
|---|---|---|---|---|
| 1337 | 12.63 | 13.75 | **1.48**（瀕死） | combined ≫ min(1.48) ✅ 真解 |
| 42 | 20.50 | 22.45 | **2.92**（瀕死） | combined ≫ min(2.92) ✅ 真解 |

兩例都是「joiner 原本剩不到 3 天糧就餓死，併後合隊撐 12~20 天」——**真救人，非把餓稀釋進大隊**（absorber 自身餘命雖從 13.75/22.45 降到 12.63/20.50，但仍遠高於 `ABSORBER_MIN_SURVIVE_DAYS(7)` 閘）。**空真守衛**（reviewer R②要求）：`accept_n=2>0`，非 INCONCLUSIVE。

## ②gate#3 湧現非腳本 —— PASS（grep+讀碼）
`consolidate_drive` = `DESPERATION_SCALE*max(0,DESPERATION_DAYS-food_days)`（terms.gd:159-163），食壓 argmax 驅動，非硬寫 `pop<N`。`_find_absorber`/`consolidate_target_of` 內的 `small_b`/`small_c` 是既有 ratio-based 資格閘（S-A 前已存在，非本次新增），非本次判準對象。

## ③gate#2 side-observe（不判 pass/fail）
`absorber_pop` 併時平均 9.5（10/9 兩例）。annih 樣本內 0。無異常，僅記錄。

## 待你
兩項硬 gate 皆 PASS，`merge.consolidate_dispatch` 高頻觸發（198/562，seed1337/42）+ accept 稀但每次都真救人——符合「食壓驅併=有機政體湧現」意圖。**若要更大樣本信心再判 merge，我可補到 18 seed 規模（環境穩後）；若 2 例訊號已夠你判，數字齊給你。**

## 產物
- json：`tools/orchestrator/runs/consolidation-s-a-probe.json`
- 原始：`.worktrees/consolidation-s-a/tools/orchestrator/runs/consol_small.json`
