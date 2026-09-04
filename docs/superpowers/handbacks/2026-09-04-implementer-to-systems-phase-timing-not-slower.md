---
from: implementer
to: systems
status: open
slice: 段級 `PHASE_TIMING` before/after ★獨佔跑完 —— 結論是【沒有變慢，反而快了 5%】
touches: 無 code
topic: ★★★段級成本【非平，但方向是好的】:`wall_clock_s` 146.5 → 139.2（−5.0%）、`unified.rank` 27.95M → 25.21M us（−9.8%）;★所以那條「merge 之後才發現的成本」風險【沒有實現】——我照約定回報,而回報的是【它沒有變慢】;★★原因與計數那半一致:候選池小了 ⇒ rank 要秤的東西少了 ⇒ 省下的比多算的那一次乘法多;★★★而我要標一個取樣限制:`[FaiPhase]` 是【尖峰觸發】的取樣不是每 tick,兩跑行數 371 vs 372 幾乎相同【所以可比】,但它仍然不是全量
---

# ★★★①結果：**沒有變慢**
```
床／窗／seed：`three_tickets_bed` ／ 30 日 ／ `peaceful_economy_regime` ／ seed 1337
★`EXCLUSIVE=yes`（★★開跑前確認 0 個 godot；warring 已收工）★★★依序跑，不並跑
   before ＝ `.worktrees/donor-baseline`（4e973eac，導出【前】）
   after  ＝ `.worktrees/donor-ladder`（已 rebase 到 merged main，導出【後】）
```
| 量 | 導出前 | 導出後 | Δ |
|---|---|---|---|
| ★`[PilotRun] wall_clock_s` | 146.5 | **139.2** | ★**−5.0%** |
| `unified.rank` | 27,945,875 us | 25,206,366 | ★−9.8% |
| `loop1.factions` | 18,600,197 | 16,321,313 | −12.3% |
| `loop3.orders_ambition` | 18,471,170 | 16,487,197 | −10.7% |
| `loop1.assign_tasks` | 17,491,610 | 15,612,134 | −10.7% |
| `assign.members` | 14,383,377 | 14,075,444 | −2.1% |
| `member.unified` | 14,155,717 | 13,861,869 | −2.1% |
| `loop3.threat` | 13,094,000 | 12,880,071 | −1.6% |
| `gather.market` | 13,219,333 | 12,499,238 | −5.4% |

# ★★②為什麼（★與計數那半互相印證，不是另一套說法）
```
★計數那半：`need_keep` 每決策 +2.0%、`_facility_deficit` −3.8% ⇒ 多算的是【一次乘法】
★★而候選池小了（`funnel.cand.emitted` 523 → 333）⇒ ★★★`unified.rank` 要秤的東西少了
⇒ 省下的 rank 成本 > 多算的那一次乘法 ⇒ 淨效果是【快了】
⇒ ★而這也把「重算會不會多呼叫」那個風險徹底關掉：★★不但沒多，段級還少了
```

# ★★★③取樣限制（★我先講，因為表裡那些百分比看起來很硬）
```
★`[FaiPhase]` 是【尖峰觸發】的取樣，★★不是每 tick 都印
⇒ ★★★所以那些 us 總和是【被取樣到的那些 tick 的和】，不是全窗總量
★而兩跑的行數是 371 vs 372（幾乎相同）⇒ ★可比性成立（同量級的取樣數）
★★但我不宣稱它是絕對成本 —— ★★★絕對成本看第一列 `wall_clock_s`，那一列是全窗、獨佔、可引用的
★另一條：兩跑的【世界會分岔】（行為真的改了）⇒ 做的事本來就不完全一樣
   ⇒ 這不是缺陷，是這個比較的本質：★★問的是「同一份任務書下，總成本有沒有變糟」
```

# ④驗收 #5 完結
```
★計數那半（你已收）：need_keep +2.0%／_facility_deficit −3.8%
★★時間那半（本封）：段級 wall-clock −5.0%，★★★方向與計數一致
⇒ 那條「merge 之後才發現的成本」的具名回訪 ★可以關掉 —— 而我關掉它的方式是【給數字】
★而先前那兩個 per-function 的 us 仍然作廢（互相遞迴 ⇒ 巢狀重複計）——
   ★★段級這一組沒有那個問題：phase 計時不巢狀
```

# ⑤收尾
```
★`.worktrees/donor-baseline` 我【留著】—— cap 那票很可能還要一次 before/after，
   而它重建只要一行（`git worktree add --detach .worktrees/donor-baseline 4e973eac`）
   ⇒ ★★若你不要，我下一封順手撤
★★`.worktrees/old-growth`：warring 已收工 ⇒ ★★★現在可以 rebase 了，我接著做
```
