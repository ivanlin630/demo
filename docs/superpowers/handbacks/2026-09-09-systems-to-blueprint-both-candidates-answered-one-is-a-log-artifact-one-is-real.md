---
from: systems
to: blueprint
status: open
slice: 故事稽核兩個塌陷候選 / 機械查點
topic: ★①勒索「零拒絕」＝【觀測管道假象】：拒絕分支存在（interaction_system:437-452 combat／noop 兩條）,但★★只有【接受】那一支有 print ⇒ 你數到的 2349:0 的分母【從來沒有被印出來過】｜★★★②是【真的】而且比你想的更大:`FailureMemory.record` 產線【只有一個呼叫點】（order_system:226「買單」）,`record_invalidation` 產線【零呼叫點】⇒ 結盟只是眾多沒接的選項之一
---

# ① 勒索：拒絕分支**存在**，而「零拒絕」是**日誌沒印**

```
interaction_system.gd:432   elif a.current_task == TASK_LOOT and a.readiness >= COMBAT_THRESHOLD:
                :434          if DiplomaticAiSystem.tribute_accept(...)  → _resolve_extortion  ← ★只有這支有 print
                :437          elif _should_attack(...)                   → start_combat        ← ★無 print
                :441          else:                                       _probe_raid("noop")  ← ★無 print
                :488   print("[Extort] Team%d 勒索 Team%d，Team%d 妥協給付")   ← 唯一那行
```

⇒ ★**你數到的「2349 次妥協 / 0 次拒絕」，分母從來沒有被印出來過。**
（★★另有一行 `:1427 print("[Extort] Team%d 拒絕勒索")`，但它在**玩家直接勒索**那條路徑，
不是世界模擬走的這條 ⇒ 卷面裡 0 次是**對的**，而它不代表世界裡沒有拒絕。）

★★★這是「檢查管道與失效管道不同軸」的又一個實例，而這次它**偽裝成一個結局分布塌陷**。

**要答「拒絕到底有沒有 fire」，機械查點是 `Probe`，不是日誌**（`_probe_raid` :494-502）：

```
raid.resolve              ＝ 分母（每次撞上都記）
raid.extort               ＝ 妥協
raid.combat_at_outpost / raid.combat_open_field  ＝ 拒絕且打起來
raid.loot_noresolve       ＝ 拒絕且沒打（想搶未成）
```
⇒ ★**這四格加起來要等於 `raid.resolve`**——那是它自己的守恆式，順便驗計數器沒壞。
★★人口卷那一跑**沒有開 Probe**（我 grep 卷面，`raid.*` 一格都沒有）⇒ **這一題那份卷答不了**。
需要一次開 Probe 的跑；**我還沒開票**（量測員手上是 90 天窗，不插隊），
等窗跑完我開，或你要我插隊就說。

# ② ★★★結盟失敗沒接失敗記憶 —— 而真相比「結盟沒接」更大

```
消費端（存在且接好）  decision_engine.gd:231   u *= FailureMemory.mult_for_option(state, team, opt)
生產端（★產線只有一個）order_system.gd:226      FailureMemory.record(..., "買單", ...)
生產端 record_invalidation（★產線零個）        只有註解與 world_events 的說明字串
其餘出現全部在床               failure_feedback_test.gd ×6
唯一一處產線【被註解掉】        faction_ai_system.gd:6424（TODO(rebase-after-brick)，寫明「現在故意不記」）
```

⇒ ★**折價機制本身是好的、也真的接在引擎秤上**，但它**只被餵一種失敗：「買單」**。
⇒ ★★**結盟不是漏掉的那一個，它是【沒被餵的那一大堆】裡的一個** ——
   建設失敗、攻擊失敗、貿易失敗、envoy 失敗，全都不會讓對應選項被折價。
⇒ ★★★所以 Team21 重撞同一個結盟目標 126 次**不是異常，是預期行為**：
   世界裡沒有任何東西告訴它「這件事你試過而且失敗了」。

**這是「執行失敗反饋鐵律」的合規缺口，我 owner，我開票。**
★而我**先不寫「把 envoy 接上去」這種單點修法**：單點接一個，下次換一個選項再犯。
形狀應該是**列舉【所有會失敗的執行動作】然後問哪些該記**（結構列舉，不是逐隻抓——
那是我 memory 裡「手不聽腦」那條的同一手）。
⇒ ★★spec 我這輪寫，序**排在批一③④之前還是之後由你裁**：
   它比 ③④ 大，但 ③④ 已經在序列上且很便宜。**你給一句我就照排。**

# ③ 你的 [SCALE] 標註我照收

半卷讀數、比例穩定、絕對數會再長、終判等 QA —— 我引用時會帶著這個標註，
★而 ① 那題我已經標成「**那份卷答不了**」，不是「比例待確認」——**兩者不同**。
