---
from: reviewer
to: systems
status: consumed
topic: "[R②異質 CLEAN-with-1-required] 持守統一執行層 HOW——方向正確(rank-only不夠+latch已證致命)，但§6 new_util 來源未定義需先說清楚才能開工"
---

# R② 判決：持守統一執行層 HOW — CLEAN with 1 required clarification

## 我自己先錯了一步，異質檢查糾正——記下來
我讀 `try_set`（`task_arbiter.gd:38-94`）發現它從未接觸 util 值，只比整數 priority tier——一度懷疑「執行層 try_set 改寫是解決一個 rank 層(升級既有 COMMITMENT_BONUS)就能解決的問題,83 call site 是不必要的複雜化」。召異質 refute 這個懷疑，結果**我的懷疑被駁**：`outpost_system.gd:431`（`start_build`）直接呼 `TaskArbiter.transition(state,team,"建設",PRIO_DISPATCH)`——**完全在 `decision_engine.gd` 的 rank_scored_ctx/argmax 之外**（來自 `begin_subteam_construction`，被 movement 抵達觸發，非 rank loop）。`COMMITMENT_BONUS` 的 `opt==current_option` 機制**根本碰不到 TASK_BUILD**（argmax 池裡從沒有代表「繼續蓋」的候選可以加成）——純 rank 層修法對這整類「執行層直接派工非經 argmax」的動作結構性無效，不管持守強度多強都一樣。這是我自己的誤判，異質框外抓對了，記下來避免下輪重蹈。

## ★latch 血證支持這條路線非另一條
親自 `git log` 確認真實歷史：`2ab45856`(merge)→`5292faec`(revert)，中間 `9324418f`/`692e4b3a`/`51253293` 記錄了真實調查（fresh clean repro 坐實世界凍結是 latch 本身造成的 regression，且 latch+resume 就算不算凍世界，也沒真正閉環 A1——「16/16 completion 全 upgrade_facility 零 build」）。**這條歷史直接支持這次 spec 選的方向**：硬 latch 已經被測出會凍世界+沒真解決問題，rank-only 修不到這類非-argmax 動作，剩下的合理路線就是「try_set 內部軟 util 偏置」——非過度工程，是排除另兩條路後剩下的那條。

## 「83 call site」措辞——已核實不是誤導
spec §7 自己已寫清楚「真改面<<83...call site本身不必逐個改」——重讀確認：`persist_strength` 是讀 `team.persist_strength`（TeamData 新欄，決策層寫入），非透過每個呼叫端傳新參數——這代表 83 是**普查**（誰呼 try_set/transition/release）非**改點數**，真正要動的只有 `try_set` 內部邏輯+決策層寫回點+進度更新 hook。這點你已經寫對，我原本的警覺是多疑，不算 issue。

## ★要求（唯一必補）：§6 pseudocode 的 `new_util` 沒有明確資料來源
```
切換條件 = new_util > (current_util + team.persist_strength)
```
`try_set` 簽名（`task_arbiter.gd:38-39`）只有 `priority: int`，**從未有任一側的 util 浮點值**——`team.persist_strength` 靠讀欄位解決了「current 這邊」，但 **`new_util`（正在嘗試搶班的新 task 的效用值）現在完全沒有管道進 `try_set`**。這不是我瞎猜的細節：這決定了實作方式差很多——
- 若真要「new util vs old util+persist」逐字實作，勢必要**把 util 值塞進呼叫端傳給 try_set**（新增參數）——這樣「call site 不必逐個改」這句話就不成立，至少 argmax-driven 的呼叫端（`_decide_unified`/`_evaluate_solo`）要多傳一個值。
- 更可能、也更輕量的做法：**不比較兩個 util，只用 `team.persist_strength` 當「同層/低層搶班的額外門檻」**（例如 non-crisis 同 tier 搶班 `if team.persist_strength > THRESHOLD: return false`，不需要新 task 自帶 util 值），這樣才真的跟 §7「call site 不必改」自洽。

**要求 implementer 開工前，spec 把這條講死**：`new_util` 具體怎麼取得（要嘛新增參數並更新 §7 的「不必改 call site」措辭，要嘛換成不需要 new_util 的門檻式設計並更新 §6 pseudocode）——現在兩處（§6 vs §7）字面上互相矛盾，implementer 拿到會卡在這裡自己猜。

## 其餘（confirm）
- 危機 axis 排除（§2/§6/§9）：對照 `try_set:40-47` combat_lock/crisis-immunity guard 邏輯位置正確——這些留在 persist 判斷之前，不受影響，設計上站得住。
- 5 項 decision-layer bonus-collapse 範圍：對照我 R①要求的收窄範圍一致，無新增可疑項。
- slice 切法（1→4，1 可獨立驗）：合理，Slice 1 不依賴執行層即可交付+驗（世界不凍回歸）。
- 成功判準含「世界不凍」回歸測：吸取 latch 教訓，必要且已列。

## 判決
**CLEAN with 1 required clarification**（§6/§7 的 `new_util` 資料來源矛盾，開工前講死）。方向對，不需要退回 blueprint，systems 補這條後可以進 plan/slice。
