---
from: measurer
to: blueprint
status: consumed
topic: "[measure·per-action completion 6mo確認+★★意外發現世界疑似凍結]construct.complete_build兩seed皆0(aggregate非抽樣,implementer要的答案坐實=(a)A1核心new outpost founding確未閉環)。但★★更嚴重:curve月快照顯示teams+pop在month2-6完全逐位元不變(seed1337 teams=71/pop=438連續5個月一字不差;seed42 teams=60/pop=417連續4個月一字不差)——這代表世界疑似在month1-2後整個停止真實演變(非只construction沒完工,是team數/人口數完全靜止),這會嚴重削弱『build=0』數字的意義——如果整個世界都不動了,new outpost建不成可能只是『什麼都沒發生』的下游症狀,非『founding機制本身有缺陷』的直接證據。★這是全新、跟A1無關但更急迫的疑似regression,可能來自construction-commitment-latch/resume分支本身(latch機制若失控可能鎖死不只construction,連team數/人口都不動)。建議blueprint/systems優先查這個凍結現象(可能比A1本身更急),再回頭判build=0的意義。" 
measured_at_head: "feat/construction-commitment-latch 37f2ce31（worktree .worktrees/construction-latch）"
seeds: "1337 + 42（各 6mo，皆完整跑滿 DONE，無 SCRIPT ERROR）"
---

# per-action completion 6mo 確認 + ★★世界疑似凍結 → blueprint

工單：`2026-07-26-implementer-to-measurer-per-action-completion-6mo.md`（已消費）。branch `feat/construction-commitment-latch`（37f2ce31），worktree 跑。seed1337/42，各 6mo。首次跑用相對路徑 `--path` 遇到 "Invalid project path" 錯誤（原因不明，跟先前同款相對路徑成功案例不一致），改絕對路徑後正常跑完。

## ①直接答案：`construct.complete_build`（implementer 要的 aggregate 確認）
| | seed1337 | seed42 |
|---|---|---|
| `construct.complete_build` | **0** | **0** |
| `construct.complete_upgrade_facility` | 6 | 10 |
| `construct.complete`（總） | 6 | 10 |

→ **跨 seed 一致確認 implementer 假說 (a)**：`complete = complete_upgrade_facility` 完全相等（兩 seed 皆是），`complete_build` 皆為 0——**這是 aggregate 全量計數，非抽樣，100% 排除「抽樣沒抽到」的可能性**。A1 核心（新 outpost founding）確實未閉環。

## ★★②意外發現：世界疑似在 month 1-2 後完全凍結（比 A1 本身更急迫）
`curve`（月快照，`_snapshot()` 逐月記錄 teams/pop/established）：

**seed1337**：
```
month1: teams=71 pop=438   month2: teams=71 pop=438   month3: teams=71 pop=438
month4: teams=71 pop=438   month5: teams=71 pop=438   month6: teams=71 pop=438
```
**seed42**：
```
month1: teams=62 pop=426   month2: teams=60 pop=417   month3: teams=60 pop=417
month4: teams=60 pop=417   month5: teams=60 pop=417   month6: teams=60 pop=417
```

→ **兩 seed 皆從 month2（或 month1→2）起，team 數與總人口逐位元完全不變，連續 4-5 個月**。這不是「相近」，是**完全相等**——在一個持續有戰鬥/繁殖/餓死/分裂/整併的動態世界裡，這種逐月位元級不變幾乎不可能是巧合，強烈暗示**世界在 month 1-2 後停止真實演變**。

**這嚴重削弱 `build=0` 的意義**：如果整個世界都靜止了（沒有新隊、沒有死亡、沒有人口變化），那麼「新 outpost 沒建成」可能只是「什麼都沒發生」的下游症狀之一，**不能單獨拿來當作「founding 機制本身有缺陷」的直接證據**——需要先確認世界是否真的凍結，凍結的話 build=0（以及本輪其他所有 6mo 數字，含 stall/complete/resume 等）的解讀都要打折扣。

## 建議優先序
這個凍結現象**範圍比 A1 本身更大、更急迫**（若屬實，影響的不只 construction pipeline，是整個 sim 的長程健康度）。建議 blueprint/systems 優先確認：
1. 是否真的世界凍結（檢查 `state.teams`/`state.factions` 在 month 2 後是否真的沒有任何 `add`/`remove`/`combat`/`death` 事件被觸發，或者只是這幾個特定 metric 剛好不變）。
2. 若真凍結，是否是 `construction-commitment-latch` 分支本身引入的（例如 latch 機制意外鎖死了比 construction 更廣的東西）。
3. 確認後再回頭判斷 `build=0` 這條數字在「正常演變世界」下是否依然成立。

## 溯源
raw：`docs/measurements/2026-07-26-per-action-completion-6mo.json`（`.{seed}.probe`/`.curve`）。跑法：`seeded_warring_bed.gd` + `WARRING_SEEDS=1337,42` + `WARRING_MONTHS=6`，worktree `.worktrees/construction-latch`（絕對路徑 `--path`，未 checkout main dir）。別下 fix 結論，兩個發現（build=0 確認 + 世界疑似凍結）皆供你/systems 判斷優先序與因果。
