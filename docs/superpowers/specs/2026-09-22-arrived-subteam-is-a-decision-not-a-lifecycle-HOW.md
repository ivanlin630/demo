---
slice: 子隊抵達 ＝ **一個決策點**，不是一條生命週期規則（`subteam-idle` de-patch）
owner: systems
status: 待 R²（reviewer）→ CLEAN 才 dispatch
基於: 量測員世代 6／HW-2 症狀複驗（evicted/arrived ＝ 97.6%／100%，13–15 個 distinct parent 反覆）；WHAT 裁定 2026-09-22（手不聽腦第三型，先查補丁閘，de-patch 不加補丁）
---

# §1 ★★★前提（file:line 坐實，**而它自己招了**）

```
`scripts/simulation/faction_ai_system.gd:3972-3978`
  3972  # 抵達目標格 → 歸建（lifecycle，**不進引擎/probe**）
  3973  if sub.move_target == Vector2i(-1, -1) and sub.current_task != TeamData.TASK_IDLE:
  3977      merge_queue.append(sub.team_id)
  3978      return
  3979  # idle → 引擎決策（cadence-gated；A2a …）
  3980  if sub.current_task == TeamData.TASK_IDLE:
★★**它的註解自己寫著「不進引擎」** ⇒ 這不是推論，是**自書**的補丁閘
★★★而**引擎的入口就在它的下一行** ⇒ **每一支「非 IDLE 且已抵達」的子隊，在引擎看到它之前就被處置掉了**
```
**症狀（量出來的，世代 6／HW-2，兩顆種子交叉）**：
```
覓食子隊抵達後被此 blanket 歸建：**97.6% ／ 100%**｜**13–15 個 distinct parent 反覆發生**
⇒ ★它不是邊角案例：**幾乎每一次抵達都被吃掉**
```

# §2 ★病的形狀（★這是「手不聽腦」第三型）

```
腦（引擎）說：這支子隊該去覓食 ⇒ 派出去
手（lifecycle 規則）說：你抵達了 ⇒ **歸建**
⇒ ★★★**抵達目的地這件事，被寫成了「任務結束」的同義詞** —— 而對覓食來說，
   **抵達才是工作的開始**。
⇒ ★而引擎**從來沒有機會表達意見**：`return` 在引擎入口的上一行。
```

# §3 ★★★修法形狀：**把抵達交還給引擎**（de-patch，**不是加例外**）

```
★**不要**寫成「若 task == FORAGE 則不歸建」—— 那是**在補丁上加補丁**：
   下一個任務型別（採礦／護送／駐守…）會再撞一次，而每一次都要有人記得加一格。
★★**正解**：抵達 ⇒ **變成一個決策點**，由引擎在【歸建】與【留下繼續做】之間**用 util 秤**。
   —— 與 `TASK_IDLE` 進引擎是**同一條路**，只是觸發條件多一個「已抵達」。
★★★而**歸建仍然可以是最常見的結果** —— 差別在於它現在是**秤出來的**，不是**寫死的**。
```
★**明確排除**：舊 branch `feat/subteam-idle` 的做法（`_forager_sated` ＋ `FORAGE_SATED_DAYS(10)` ＋
`PARENT_LOW_DAYS(3)`）⇒ ★★**兩顆死常數 ＋ 一個任務型別的例外** ⇒ **憲法禁**（估算器禁手抄物理／de-patch 不加補丁）
⇒ **不把那支 branch 接回來**，以現 main 重做。

# §4 ★不變量檢查（★我 owner 的那幾條，套回本票）

```
①**全量暫態可觀測性**：新增決策點 ⇒ **必接 tap**（`subteam.arrival_decision.{merge,stay}`）
②**記帳可以閘，語意不可以**（不變量 #7）⇒ 決策本身**不得**依附 `Probe.enabled`
③**util 必＝真值**：「留下」的 util 要是**真實期望價值**，★**不得為了讓它 fire 而 crank**
④**感知鐵律**：決策只能吃 belief ⇒ 「母團缺不缺糧」要走 belief，★**不得直接讀母團真值**
   —— ★★★而舊 branch 的 `_parent_needs_food` **正是直接讀母團 food_days**（god-view）⇒ 又一個不接回來的理由
```

# §5 ★★驗收（**預註冊：在實作之前寫死**）

```
A1【症狀消失，硬閘】`merge.forage_blanket_evicted / subteam.forage_arrived`
   從 **97.6%／100%** 降到 **< 50%**（兩顆種子）
   ★★而**不是降到 0** —— 歸建仍然可以是常見結果；★★★**降到 0 反而表示我們只是把硬閘翻面**
A2【引擎真的在決定，硬閘】`subteam.arrival_decision.*` 母體 > 0，**且兩個分支都出現過**
   ★只有 merge 沒有 stay ⇒ 引擎沒有在秤，只是換了個地方寫死
A3【母體衛生】`subteam.forage_arrived` 與症狀複驗那一輪**同量級**（★掉一個量級 ⇒ 控制流被改）
A4【陽性對照】把新決策點的 util 差距人為拉到極端 ⇒ **兩個方向都要能翻**
   ★★沒有這格，A2 綠了也不知道是不是「剛好都選 merge」
A5【等價性】★對**未觸及的任務型別**（非 FORAGE），全世界指紋逐字相同
   ⇒ ★★★若它們也變了，代表這一票的影響面比預期大 ⇒ **停下來重新界定範圍**
```

# §6 ★誠實限

```
①症狀數字來自世代 6／HW-2 兩顆種子；★更長窗是否仍 97%+ 未驗
②`ghost_alive=4`（convoy 那輪的另一個發現）**不在本票** —— 另行分類
③本票只改「抵達」這一個觸發點；★**其他 pre-empt 引擎的 lifecycle 規則沒有普查**
   ⇒ ★★而 `_evaluate_subteam` 裡在它之前還有數個 `return`（HERALD／SCOUT／CONVOY／SETTLE／ESCORT／discipline）
   ⇒ ★★★**它們是不是同一族，本票沒有回答** —— 若要回答，那是一次普查，不是這一票
```
