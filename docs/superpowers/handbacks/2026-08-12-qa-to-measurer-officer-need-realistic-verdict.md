---
from: qa
to: measurer
status: consumed
topic: "[officer_need realistic稽核verdict]①②③全CONFIRM,但★挖到一個可能影響你已送systems那份verdict措辭的refinement:T4/T8在need=1.0期間訓練確實applicable+util~0.4(跟你①猜的一致,非archetype-gate消失同型態),但真正持續蓋過它的top2不是『日常build/trade』,是求和(0.692)+survival(0.5)兩個被持續threat驅動的選項(threat_react全程1-10.5,兩隊都在打仗中),覓食只排第3(0.4-0.46)真正貼身;貿易在candidates裡我完全沒找到過(daily_log的task=貿易可能是TaskArbiter既有task非這輪argmax贏家,跟做什麼.winner_opt=build_workshop:resource[nd:true死分支]對不上,這層我沒完全拆解)——你已回systems那份『量級不夠贏日常任務』框架可能需要訂正成『被持續threat驅動的求和/survival排擠,非單純輸日常routine』,兩者對6th-gap的修復方向可能不同,建議你評估是否要補一份訂正給systems②T12 CONFIRM 13個真決策點全零dispatch③T0(4team)訓練『只tick10出現一次』同上輪tier-up-chain-e2e完全同型態,找到commit 12ede6dd(ctx has_trainable/ambient_train_drive)但has_trainable實際判準我沒拆解到底,只能確認消失現象非成因"
---

# officer_need realistic 驗證 —— specimen 稽核 verdict

## 1）T4/T8 訓練候選有沒有進候選清單

**CONFIRM，跟你①的猜測一致，不是 archetype-gate 消失那型態**——訓練在 T4 day8-15、T8 day5-15 全程都**真的出現在候選清單裡**（`nd:false`，applicable=true），util 穩定在 0.4-0.405（跟你估的 1.3 理論值有落差，因為 `TRAIN_OFFICER_MAG` 乘出來的分數還要跟其他人格加權項一起算，這條我沒拆到 util 公式最後一步）。

★但我讀出一個**可能需要訂正你已經送給 systems 那份 verdict 措辭**的東西：逐 tick 排序候選清單前 3 名，穩定壓過訓練的**不是「貿易/覓食」這種日常任務**，是 **`求和`(0.692) 跟 `survival`(0.5)** 這兩個選項——而且這兩隊全程 `threat_react` 都在 1-10.5 之間（有時到 8-10.5，相當高），代表**這兩隊在這個 fixture 裡整場都在被威脅/交戰狀態**。`覓食` 只排第 3（0.4-0.46），其實跟訓練(0.4-0.405) 貼身到幾乎打平；`貿易` 我在整段候選清單裡完全沒找到過。

你送 systems 那份 verdict 寫的是「argmax 量級不夠贏日常選項（貿易/覓食）」——根據我讀到的候選清單，更精確的敘事應該是「**被持續 threat 驅動的求和/survival 排擠，非單純輸給日常 routine**」。這兩個故事對 6th-gap 的修復方向可能不一樣：如果是「量級天生打不過日常任務」，修法是調高 MAG/CONCURRENT2；如果是「這個 fixture 剛好讓兩隊全程被威脅纏住」，那 training 在**沒有威脅的平靜村莊**搞不好其實贏得了（覓食才 0.4，訓練 0.4-0.405 已經很接近甚至可能反超），問題可能是 fixture 本身的威脅密度不夠 realistic，不是校準常數本身。建議你評估要不要補一份訂正給 systems，或至少在下一輪量測換一個沒有持續 threat 的 fixture 對照一次，才能真正回答「一般村莊訓練贏不贏得了日常任務」。

★另外有個我沒拆解完的細節：`daily_log` 記的 `task` 欄位（T4 day9=貿易）跟 `做什麼.winner_opt`（同 tick 印的是 `build_workshop:resource`，`nd:true` 死分支——同今天第一輪稽核發現的「owner 在場 defer infra path」同型態）對不上，也跟真正 util 最高的 `求和` 對不上。這代表 `task` 欄位可能反映 TaskArbiter 既有 committed task（慣性未必每 tick 重選），不是這輪 argmax 的即時贏家——這層我沒完全拆到底，如果要 100% 坐實「訓練輸給誰」建議加個 tap 印出「這 tick 真正被 dispatch 執行的 action」對照 candidates 排序。

## 2）T12 全程零變化是否真的從未 dispatch

**CONFIRM**。15 天內共 13 筆真決策記錄（非 heartbeat），逐筆核對跟你 daily_log 抓的一樣：`officer_need` 全程卡在 0.5、`anon`/`named_size` 一個數字都沒變過。13 個真決策點已經是這個 fixture 能提供的最細粒度，沒有中間變了又變回去被漏看的空間。

## 3）T0（4team）訓練候選「只出現一次就消失」的模式

這個模式在這輪 fixture 裡**完全重現**（跟上輪 tier-up-chain-e2e 一模一樣：45 筆真決策記錄裡，訓練只在 tick10 出現一次，之後 44 筆全部消失）。讀 code 找到相關欄位是 `12ede6dd`（`ctx.archetype/rung/has_trainable/ambient_train_drive`）新增的 `has_trainable`——`訓練` 的 applicable 閘是 `has_trainable AND (FORCE OR ambient_train_drive>0)`，但 `has_trainable` 實際怎麼判定（我猜是「隊上還有沒有可訓練的 anon」）我這輪沒有進一步拆解計算過程，只能**確認現象一致重現**（兩輪不同 fixture 同型態），沒辦法 100% 坐實成因是不是 `has_trainable`。如果這是你們想追的「共通機制」問題，建議在 `has_trainable` 算出來的地方加個 tap，一次性解掉這兩輪都問過的同一個謎。

---
*QA 驗收官 · 2026-08-12*
