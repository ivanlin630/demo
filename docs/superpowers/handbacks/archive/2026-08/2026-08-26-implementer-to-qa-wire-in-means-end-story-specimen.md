---
from: implementer
to: qa
status: consumed
slice: acquisition-paths-wire-in
topic: ★故事稽核請收:means-end specimen trace 已落地【exact path 在內】(1964 entries/142 決策/90天 seed1337);★★故事線=缺weapon→提出蓋兵器坊(tick10)→之後轉買/製造→86 committed vs 24 try_set_noop;★★★兩個讀法陷阱寫在信裡(nd 假陽性已修、label 讀不出設施名)
---

# means-end 接線的**故事 specimen** — 交付

## ★★★exact path（★**不是「已請／已產」，是路徑**）
| | |
|---|---|
| ★**trace 檔** | `A:\GDS\demo\.worktrees\wire-in-specimen\docs\measurements\2026-08-26-wire-in-means-end-story.specimen.jsonl` |
| **也在 git 裡** | `git show feat/wire-in-specimen-trace:docs/measurements/2026-08-26-wire-in-means-end-story.specimen.jsonl` |
| **branch / commit** | `feat/wire-in-specimen-trace` @ `6f498756` |
| **床** | `scripts/debug/means_end_specimen_bed.gd`（同 branch） |
| **完整 stdout** | `…\scratchpad\specimen_90d_v4.txt` |
| **參數** | `peaceful_economy` / `seed 1337` / **90 天**（★**與 measurer 那輪世界層量測同床同 seed**） |
| **規模** | **1964 entries**、**142 個決策 entry**、specimen ＝ **Team0 / Team1 / Team2** |

## ★故事線（你要判的那條）
```
tick 10  Team0/1/2 三隊都缺 weapon_melee_low 與 tools（material=0、腳下 manufacturing_level=0）
         → means-end 提出兩種手段，其中【蓋】那條：
              opt = "maintain_weapons:location:delegate"
              要做的事 = {build_type: civilian, target: [10,9] / [5,8] / [8,5]}
              util = 1.272   ← ★全場最高
         → 但 winner = 「駐守」util 0.200，result = committed
之後     → means-end 轉成「取得原料」那條：
              "maintain_weapons:resource" → 要做的事 {task: 貿易, target: …}
              "maintain_tools:resource"   → 要做的事 {task: 製造, target: [6,8]}
         → 這條【真的贏了 argmax】並被派出：committed 86 次 / try_set_noop 24 次
```
★**要你判的三件**：
1. **「util 最高的蓋工坊候選，為什麼一次都沒贏」** —— 是 genuine（蓋太慢、折現輸）還是被什麼 pre-empt？
2. ★**`try_set_noop` 24 次** ＝ 決策贏了、手沒動（手不聽腦第 N 型？）——**這 24 筆的 tick/target 都在 trace 裡。**
3. **只有 tick 10 出現「蓋」那條，之後再也沒有** —— 是世界變了（有設施了？）還是候選被誰吃掉。

## ★★兩個【讀法陷阱】（★先講清楚，免得你誤判）
| 陷阱 | 說明 |
|---|---|
| ★**`nd`（✗ 不可派）曾經是假陽性** | `DecisionOptions.to_task` 只認得靜態 option，goal candidate 的 label 不在 `REGISTRY` ⇒ `options.gd:539-540` 一律回 IDLE ⇒ **每個 means-end 候選都被標成「不可派」**，而同一筆 entry 的 winner 其實 `committed`。★**本輪已修**（候選改用自己的 `to_task` 判）⇒ **這份 trace 裡 means-end 候選的 `nd` 全部是 `false`（181/181）**。★**若你手上有更早的 trace，那裡的 `nd` 不可信。** |
| ★**label 讀不出設施名** | candidate 的 label ＝ `goal_type:frontier_kind`，**兵器坊/工坊這個名字不在 label 裡**。★本輪補了 **`要做的事`** 欄（`facility`/`build_type`/`task`/`target`）⇒ **設施/動作要看那一欄，不是看 label。** |

## ★聚合數字（★**只作背景，不可拿來下因果**——因果請你讀故事）
```
means-end 候選出現 877 次｜其中贏得 argmax 338 次
既有機制沉默處補上的(unique_no_existing) 522｜與既有重複 219
means_end.unique_no_existing.weaponsmith = 522
候選資源分佈：weapon_melee_low 522 / tools 355
```

## ★背景（你判讀時可能要）
**世界層那顆數字仍是懸案**：`dispatch_fail.資源不足` 接線前 **33** → 接線後 **41**（上升）。
★**今天補了分母**：`dispatch_builder.attempt`（已 merge `09c93b33`）—— **20 天 seed1337 ＝ 39 次嘗試 / 39 次資源不足 ＝ 100%**。
⇒ ★**「失敗次數上升」與「失敗率上升」現在分得開了**，但 **90 天的分母要等 measurer 跑**。
★**我不代跑他的量測，也不在這裡下因果結論。**
