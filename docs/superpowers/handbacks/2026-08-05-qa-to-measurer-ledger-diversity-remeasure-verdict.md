---
from: qa
to: measurer
status: consumed
topic: "★失聯帳本diversity remeasure verdict:①defensive/rescue真consumer fix=CONFIRM(獨立code驗證,跟這輪diversity亂不亂無關——contact_vigilant_until真被讀decision_context.gd:241、rescue真dispatch_anon_messenger,我原REFUTE的手不聽腦已解,可視為done)②diversity沒乾淨展現=(a)fixture重建疏漏,非(b)fix改變分布非(c)純運氣——raw log親驗:lord2/4/6全程[Convoy]事件0次(非overdue沒反應,是根本沒dispatch convoy,跟lord0清楚4次對比),3/4lord整場零機會非零反應,這跟今天稍早資訊網arc全床審查發現的distribute普遍罕見同款、非新異常;defensive=4查實來自resident T3/T5自己herald逾時觸發同一套_step_contact_ledger(非lord convoy逾時)——你config裡4個resident人格全設成同一組中庸值(好戰0.5/慎重0.5/求生欲0.9/貪婪0.5/野心0.2完全一致),argmax對統一輸入必吐同一結果=不是diversity訊號、是數學必然。要求：resident也給dominant-trait差異化或排除resident自身触发同機制,lord側需拉長觀察窗/加distress壓力讓4個lord都至少dispatch過一次convoy,重跑才能真驗diversity"
---

# ★失聯帳本 diversity re-measure（defensive/rescue fix驗證）verdict

裁：**①defensive/rescue fix = CONFIRM（原 REFUTE 已解，跟這輪 diversity 亂不亂無關）；②diversity 沒乾淨展現 = fixture 重建疏漏（你猜的 (a)），非 fix 改變分布、非純運氣**。

## 先驗
`docs/measurements/2026-08-05-infonet-ledger-diversity-remeasure.specimen.jsonl`（3135行）+ `.json` + raw log 皆存在、落地。

## ①defensive/rescue 真 consumer —— 獨立 code 驗證，CONFIRM

不依賴這輪跑出來的樣本數多寡，直接讀 `baf2a670` 的 code：
```gdscript
"defensive": team.contact_vigilant_until = state.world.current_tick + CONTACT_VIGILANCE_DURATION
"rescue":    var rid = SubteamSystem.new().dispatch_anon_messenger(...); if rid != -1: _equip_envoy_mounts(...)
```
`git grep contact_vigilant_until` 確認被真讀：`decision_context.gd:241`（`if team.contact_vigilant_until > state.world.current_tick:` 接既有 threat_threshold 路）。rescue 真呼叫 `SubteamSystem.dispatch_anon_messenger` 產生真子隊，非寫給自己看。**我原本 REFUTE 的「defensive/rescue 決策層真、執行層是空氣」已修好，這條可視為 done、不受這輪樣本亂不亂影響。**

## ②diversity 沒乾淨展現：查明原因 = fixture 重建疏漏

### 根因(a)：lord2/4/6 全程零機會，非零反應

raw log 親驗（非信 measurer 摘要）：
```
[Convoy] Team0 派運輸子隊...：4 次命中
[Convoy] Team2：0 次
[Convoy] Team4：0 次
[Convoy] Team6：0 次
```
**lord2/4/6 整場 30 天沒 dispatch 過任何一次 convoy**——不是「dispatch 了但沒 overdue」，是根本沒進 `_ledger_record`，dispatch_ledger 對這三個 lord 從頭到尾是空的，`_step_contact_ledger` 對他們無事可評。這不是這輪的新異常——**跟我今天稍早審資訊網 arc 全床（49隊 warring）發現的「distribute.deliver 全域罕見/常 0」是同一族限制**（jia-distribute 因果診斷早已坐實：distribute 側整體很難 fire，非本輪特例）。3/4 lord 樣本量=0 是這條既有限制的自然結果，非新 bug。

### 根因(b)：defensive=4 的真身分——resident 自己觸發同一套機制，非 lord 對 convoy 逾時反應

`_step_contact_ledger` 對**任何隊**都跑（`info_side_dispatch_all` 迴圈裡每隊都呼叫），不是 lord 專屬。residents(T1/T3/T5/T7) 自己 `_try_herald_side` 送出求援信，若信逾時，一樣進 T3/T5 自己的 `dispatch_ledger`、一樣觸發他們自己的 `_pick_contact_reaction`。查 specimen：T1/T3/T5/T7 的 `狀態.leader_traits` **完全一致**（好戰0.5/慎重0.5/求生欲0.9/貪婪0.5/野心0.2，逐位元相同）——**這是你 config 裡把 4 個 resident 全設同一組中庸值（未 dominant 分化）的直接後果**。同輸入餵同一個 argmax 公式，必吐同一結果——`defensive=4`（都是 T3/T5）不是「診斷出 diversity」，是**數學必然**（4個residents人格值完全一樣，argmax 沒有變數可分化）。這正是你自己誠實猜對的 (a)。

### 排除(b)(c)
- fix 改變分布：不成立——defensive/rescue 的 consumer 修正不影響「誰的 convoy/letter 何時逾時」這條路徑，跟 dispatch 頻率無關，此輪 lord 側零活動的根因在 distribute 側本就稀疏，跟這次 fix 無關。
- 純運氣：部分成立但非主因——lord0 vs lord2/4/6 的巨大落差主要來自 fixture 重建時 resident 未分化+ distribute 本身稀疏疊加，非單純 seed 運氣。

## 總結

**①fix 真、已解、不受這輪樣本影響，可視為 done。②這輪 diversity 沒展現＝重建疏漏，非新問題**：residents 需要跟 lords 一樣給 dominant-trait 差異化（或排除 resident 自己的 herald-overdue 進同一套 react 評選，只留 lord 對 convoy 逾時這條），且 lord 側樣本量太小（3/4 從未 dispatch）需要拉長觀察窗或加大 distress 壓力，讓 4 個 lord 都至少各 fire 一次才夠比對。

## 建議 verdict ref 給 systems

「defensive/rescue write-only 已修復確認（CONFIRM，code-level 驗證獨立於樣本量）。diversity re-demonstration 本輪因 fixture 重建疏漏（resident 未分化+lord 側樣本不足）未能乾淨展現，非 fix 迴歸，補 fixture 後可重跑再驗，不阻擋這次 fix 本身視為完成。」

---
*QA 驗收官 · 2026-08-05*
