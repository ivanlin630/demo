---
slice: 子隊抵達 ＝ **一個決策點**，不是一條生命週期規則（`subteam-idle` de-patch）
owner: systems
status: ★**前置量測已回**（§8）⇒ 裁定【slice，不是 arc】；門檻已預註冊（§8.3）⇒ **待 R² 再確認 → CLEAN 才 dispatch**
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

---

# §7 ★★★R² 第一輪的硬發現：**我驗的母體 ≠ 我要改的母體**（reviewer 2026-09-22，我數過了，比他說的更大）

```
★我把這一票當成「覓食子隊的問題」—— 而 3972 那條 blanket 管的是
  **【任何沒有專屬分支的 task type】**，不是 FORAGE。
★★我實際數過（`team_data.gd` 的 `const TASK_*` ∩ `_evaluate_subteam` 3904-3971 的分支）：
    task 型別總數        ＝ **36**
    有專屬分支的         ＝ **11**（BUILD／CONSTRUCT／CONVOY／ESCORT／EXPAND／FORAGE／HERALD／MIGRATE／SCOUT／SETTLE／UPGRADE）
    IDLE 走它自己那條    ＝ 1
    ⇒ ★★★**落到 blanket 的 ＝ 24 種**：
      ATTACK BEG CAMP DEFEND DIPLOMACY FLEE GOVERN HOLD JOIN LOOT MANUFACTURE MERGE
      PACIFY PATROL PRODUCE REST RETURN_HOME REVOLT SEEK_HOME SHELTER TRADE TRAIN TRIBUTE TRIBUTE_OFFER
⇒ **我驗證了 1 種，而我要改的行為涵蓋 24 種。**
```
★**而 A1–A4 的 tap 全部是 FORAGE-scoped** ⇒ 驗收會綠，而**另外 23 種沒有任何一格看得到**。
★★另一層（reviewer 指出）：`merge_queue` 是**全域共用 list**（`:1315`／`:1377`）
⇒ 歸建**時機**一變，**佇列順序**就可能變 ⇒ 影響面不只本隊。
⇒ ★★★**這正好解釋了我自己在送審信裡那個疑問**：我問「A5（未觸及型別指紋逐字相同）是不是注定會紅」
   —— **答案是：在目前這個 spec 下，它注定會紅，因為根本沒有『未觸及的型別』。**

## §7.1 ★訂正：**先量，再決定這是哪一張票**

```
★**前置量測（在任何行為改動之前）**：在現 main 加一顆**按 task 型別分類**的 tap
    `merge.blanket_evicted.<task>` ＋ `subteam.arrived.<task>`
⇒ ★★它把「影響面未知」變成一個數：**24 種裡，實際上有幾種真的會抵達並被歸建？**
⇒ ★★★**而那個數決定這是哪一張票**：
   ・若實際只有少數幾種會發生 ⇒ 本票的影響面是可控的 ⇒ 照 §3 的 de-patch 做
   ・若 24 種裡有一大半都在發生 ⇒ **這不是一張 slice，是一條 arc** ⇒ 退回 WHAT 重新排
★**在這顆數字回來之前，本票不 dispatch。**
```

## §7.2 ★★同族，而我原本把它匿名丟進「六個 return」（reviewer 訂正）

```
`faction_ai_system.gd:3943-3951` —— CONSTRUCT／UPGRADE／EXPAND：
   抵達後未轉 BUILD ⇒ **給一次重試，逾時才 release/merge**
   而那個逾時是 `const CONSTRUCT_TRANSIT_TIMEOUT: int = 10 * TICKS_PER_DAY  # TEST VALUE`
⇒ ★**同病同型**：也是「抵達之後怎麼辦」被寫成規則而不是決策，
   ★★而且它還多一顆**死常數**（★且註解自己標著 TEST VALUE）
⇒ ★★★**我原本把它跟另外五個 return 混在一起寫成「沒普查」** —— 那是**匿名化一個已知同型**。
   現在點名：**它與本票同族**，而**是否併票由 §7.1 的數字決定**。
```

## §7.3 ★A1 的門檻改法（reviewer ①）

```
★原本我寫「降到 < 50%」—— 而 **50% 是我隨手挑的**（我在送審信裡已經承認）
⇒ ★★改成**錨在量測基線 ＋ 多 seed 變異**：
   ①先量 baseline（現 main，按 task 型別）②門檻寫成「**相對 baseline 下降 ≥ X 個標準差**」
   ③★**而 X 與 baseline 都在前置量測回來之後、實作之前預註冊**
⇒ ★★★**不是「看完數字再挑門檻」** —— 是「**先有 baseline 才知道門檻該用什麼單位**」。
```

---

# §8 ★★★前置量測回來了 —— **它同時解決了範圍問題，也打掉了我的靜態清單**

```
        seed1337                    seed77
  EXPAND   arrived 1420  evicted 0    arrived 1337  evicted 0   ← ★最大宗（七成以上），而它【一次都沒被歸建】
  SCOUT    arrived  325  evicted 54   arrived  274  evicted 29  ← ★★歸建的主力
  HERALD   arrived  246  evicted 0    arrived  108  evicted 0
  FORAGE   arrived    3  evicted 3    arrived    9  evicted 9   （100%，但次數是個位數）
  CONVOY / TRIBUTE / DEFEND / CAMP：個位數
  合計     arrived 1999  evicted 59   arrived 1744  evicted 44   ⇒ ★**整體歸建率 ≈ 3%**
  ★有抵達的型別 ＝ **7／36**（兩顆種子一致）
```

## §8.1 ★★★**我的「24 種」是錯的**（而量測員沒有把數字對齊成我的 —— 對的）

```
★我用靜態掃 3904-3971 的 `TeamData.TASK_*` 當成「有專屬分支 ⇒ 不受 blanket 管」
⇒ ★★而 **SCOUT 的分支是 `if task == SCOUT and task_reason == "info_scout"`** ——
   **只有 info_scout 會 return，其餘 SCOUT 子隊【照樣落到 blanket】**
⇒ ★★★而它正是**歸建的主力**（54／29，佔全部 evicted 的九成）
⇒ **我把主力排除在母體之外了。**
★這正是那條認識論界限：**靜態讀得出「什麼存在」，讀不出「哪條路會走到」** ——
  ★★而 `HERALD`／`CONVOY`／`EXPAND` 同理（它們的分支也帶條件），只是它們碰巧 evicted＝0。
★★★**量測員原樣呈報差額、不替我圓** —— 那是對的做法，我把它記在這裡。
```

## §8.2 ★裁定：**是 slice，不是 arc**（依 §7.1 預先寫下的判準）

```
判準原文：「少數幾種 ⇒ 影響面可控，照 §3 的 de-patch 做｜一大半都在發生 ⇒ 是 arc，退回 WHAT」
⇒ ★**7／36 有抵達，而其中只有 4~5 種真的被歸建，整體 3%** ⇒ **少數 ⇒ slice**
⇒ ★★**而最大宗的 EXPAND（七成抵達）一次都沒進過這條 blanket**
   ⇒ **這條規則不是「抵達規則」，它是一條只咬到落單者的 fallback** ⇒ **風險比我原先怕的低**
```

## §8.3 ★A1 的門檻（現在有 baseline 了，**在實作之前預註冊**）

```
baseline（世代 6／HW-2、8 天窗、warring、兩顆種子）：
  ★整體 evicted/arrived ＝ **2.95%／2.52%**
  ★★SCOUT ＝ **16.6%／10.6%**（歸建主力）｜FORAGE ＝ **100%／100%**（次數個位數）
**門檻**：
  ①【主】**SCOUT 的 evicted/arrived 下降 ≥ 一半**（16.6→≤8.3、10.6→≤5.3）
     —— ★理由：它是唯一**既有量又有比率**的型別；FORAGE 的 100% 分母只有 3／9，**動一格就翻**
  ②【副】整體 evicted/arrived **不得上升**
  ③★★★**FORAGE 不設門檻，只做觀察欄** —— **分母個位數的比率不可當判準**
     （★而我上一版把 FORAGE 當主角，正是因為我只量了它）
```
