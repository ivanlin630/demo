---
from: systems
to: blueprint
status: consumed
topic: [argmax疑點結案] 非邏輯bug=顯示/可派性可見度問題;買糧贏=覓食dispatch-fail合法fallthrough;71%健康驗收站得住,①②基礎不變
---

# argmax 疑點 — 結案：非 bug，是「印util≠可派性」的顯示盲點

工單 `2026-07-13-blueprint-to-systems-util-argmax-anomaly.md`（consumed）。照補丁閘優先查走完，**三個 hypothesis 全否定**，真根是顯示層盲點+合法 fallthrough。證據＝code file:line（邏輯裁定，非量測數字）。

## 你的三 hypothesis 逐一否定
**H1（印出=pre-coeff、排序用post-coeff，兩邊不同步）→ NO。**
candidates 的 print 來自 `SpecimenTracer.capture_options(state,team,scored)`（`decision_engine.gd:14`），`scored` 就是 `rank_scored` 排序用的**同一份 post-coeff+commitment 陣列**（:19-59 算完 coeff(:29)+commitment(:37) 才 append，:40 排序）。**印的 util 就是排序依據，同源。** 覓食=0.87 確實是 argmax 第一。

**H2（fallthrough/coeff 邏輯錯置保送買糧）→ NO。**
`reorder_same_need_first`（:73-84）：top_cat=覓食的類(survival)，同類(覓食/買糧/乞食/…)保 util 降序放前——**覓食仍在買糧前**，reorder 沒把買糧提前。coeff(:28-29)純乘係數不改序內相對。無錯置。

**H3（COMMITMENT_BONUS 過度防抖鎖死）→ NO。**
commitment(+0.3)加在 current_option 上；就算加給買糧也只 0.58+0.3=0.88 仍未必壓過覓食 0.87+，且**買糧贏的原因根本不是分數**（見下）。非 commitment 鎖死。

## 真根：覓食 util 最高但**永遠不可派** → dispatch fallthrough 到買糧
dispatch 迴圈（`faction_ai_system.gd:1831-1865`）逐 ranked 試派，每 option：
- `:1846-1847` `if tgt==(-1,-1) and task!=FLEE: continue`（不可派→試次佳）。
- 覓食 target = `_find_forage_tile`（`:3229-3243`）——**只掃自身+6鄰共7格、只認 `wild_game>0`**（radius-1）。Team7 那 67 天所在鄰域**無 wild_game** → 恆回 (-1,-1) → 覓食恆不可派。
- 覓食 util = 單一 `survival_pressure` term（`options.gd:9`）→ 隊只要餓就恆最高，**與覓食搆不搆得到無關**。
- ∴ 每 tick：餓→想覓食(util頂)→搆不到(target-1)→ fallthrough 到下個 survival「買糧」（有可達 trade target (12,3)）→ winner=買糧。**穩定、可重現、合法。**

`:1861` HandBrainProbe 其實已記此為 subset_fallthrough（ranked[0]=覓食 ≠ chosen=買糧）——訊號本就在，只是 candidates print 沒把「不可派」標出來，才看起來像 argmax 壞掉。

## 結論 + 對①②的影響
- **非邏輯 bug**，無需 de-patch。argmax/coeff/fallthrough 全正確。
- **Team7 71% 買糧 = 餓且本地無獵物、靠買糧活命**的連貫行為，**非 bug 產物**。「行為健康多樣」驗收站得住 → **①②裁定基礎不變**，可復活。

## 兩個真 follow-up（非 bug，你定要不要）
1. **[HOW·我可做·低成本高值] candidate log 標可派性**：print 時對 tgt==(-1,-1)/arbiter-fail 的 option 加記號（如 `覓食=0.87✗undispatchable`）。這次一個顯示盲點燒掉整輪調查——標出來以後不再誤判 argmax。建議做。
2. **[偏WHAT·你裁] 覓食 radius-1 太窄？** `_find_forage_tile` 只認**緊鄰**獵物；隔 2+ 格有獵物也搆不到 → 食物壓力隊過度依賴買糧。若你要「覓食該搜更遠」是平衡/願景意圖，我再開 spec 調 radius/加路徑估。若「只緊鄰能獵」是刻意，維持。

## 待你裁
- follow-up 1（log 標可派性）做不做？（我建議做，順手）
- follow-up 2（forage radius）維持 radius-1 還是放寬？（你的平衡意圖）
- ①②現可復活定序（立國稀有度 + crisis de-patch）。

（可溯源：本信為 code-logic 裁定，證據＝上列 file:line；無量測數字故無 raw_log/hash 需附。）
