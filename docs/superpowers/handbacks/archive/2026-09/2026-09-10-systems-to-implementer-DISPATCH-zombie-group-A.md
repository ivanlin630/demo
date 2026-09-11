---
from: systems
to: implementer
status: consumed
slice: 殭屍窗群甲（決策污染兩站 ＋ 根）—— ★DISPATCH
topic: ★派工：`specs/2026-09-10-zombie-window-group-A-decision-poisoning-HOW.md`（R² 判 CLEAN，直接 dispatch）｜★★而這張票的主體【不是那兩站】，是根：`sim_runner` 有兩條路會整段跳過 `_step_cleanup_extinct_teams`（`:354` 伏擊早退／`:272-281` encounter 分支）⇒ 殭屍窗 ＝ **encounter 全長 ＋ 1 tick**｜★★★驗收主詞換了：本批第一張【會改變行為】的票，**fp 必須變**，fp 相同反而是紅燈
---

# ① 派工

```
spec  docs/superpowers/specs/2026-09-10-zombie-window-group-A-decision-poisoning-HOW.md
R²    ★CLEAN（三格全打完，含我標【未驗】那一格 —— 他追到底了，見 §⑤）
序    ★★在 camp_target_est 攤平（人話層第一件）之後
```

# ② ★★主體是【根】，不是那兩站

```
sim_runner.gd:379 的 cleanup 掛在 tick 尾，而它前面有兩條路跳過它：
  :354  伏擊起 encounter ⇒ return "player_turn"（★這一 tick 走不到 :379）
  :272-281  encounter_active ⇒ 整個 tick body 被 encounter 分支取代
★而 WorldEvents.consume_and_clear 在 encounter 那條路【有】被特別補上（:279-280 註解寫著理由）
  ⇒ ★★同一個「跨 tick 存活」的問題被想過一次，而 teams_pending_erase 沒跟著補。
★★★修法【不是兩處各補一行】：把清除搬到一個【所有 return 路徑都會經過】的地方
   （wrapper：`advance_tick` 呼 `_advance_tick_body`，拿到結果之後、回傳之前呼一次）
   ⇒ **下一個新增的 early return 不會再製造同一個洞**。
```

★**R² 幫我們界定了窗的長度，這個數字你會用到**：

```
encounter 期間【不會新增】待清除者（判死的程式碼在 encounter 期間根本不會被執行）
⇒ 存活的是【encounter 開始那一刻已經在 pending 裡的那些】
⇒ ★窗 ＝ encounter 全長 ＋ 1 tick。
```

# ③ 兩站（★即使根修好也要修）

```
npc_combat_system.gd:150  team_strength 護衛加總 ⇒ 加 `if not state.is_live_team(tid): continue`
vision_system.gd:41       被觀測側 ⇒ 改 is_live_team
  ★★★而觀測者那一側（:27）【已經有守衛】，它用的是 has() —— 認不出 pending_erase。
     ⇒ R² 記了一筆我完全同意的：**「半個守衛」比完全沒守衛更危險，因為它不會引人懷疑。**
     ⇒ 兩側都要改。
★根修的是【窗會不會延長到跨 tick】，站修的是【窗內誰在看】——兩件事，都要。
```

# ④ ★★★驗收：本批第一張【會改變行為】的票

```
①根：造一個 encounter（伏擊）＋同 tick 有隊滅團 ⇒ encounter 期間 teams_pending_erase 必須是空
   ★成對對照：把 wrapper 拿掉 ⇒ 這一格必須紅
②窗長度：判死→從 state.teams 消失經過幾 tick（修前 >1，修後 =1）
③戰力灌水：team_strength 逐次呼叫值分布；★灌水那幾次要具名（哪 tick／哪隊／灌多少）
④belief 污染：指向「已判死未 erase 之隊」的 team_intel row 數
   ★★若修前也是 0 ⇒ 那是【本窗不可達】，如實回報，★★★不得把 0 讀成「修好了」
⑤★fp【必須變】—— fp 相同反而是紅燈（表示兩站的守衛沒咬到任何東西）
   ★★而 R² 要求寫死的那一句：**本格必須跑在①②的同一個構造場景上，
      不得用自然長跑／隨機 seed 驗** —— 否則「沒觸發」與「沒做」無法分辨。
⑥既有紅（recovery_r1_test／headless_test 那組）修前後同一組，★不得變多
```

★**誠實限先講**：③④ 是分布／計數，不是「世界該長怎樣」的判準；
★★而 ⑤ 的反向斷言有它自己的風險 —— **fp 變了不代表變對了**，②③④ 才是歸因。

# ⑤ 風險（★預先講好處理方式，免得事後臨場判斷）

```
戰力變化會傳到潰退／敗北出路 ⇒ 滅團率可能動。
★若滅團率暴走 ⇒ **回 blueprint，不 revert 這張票**（同攻擊門那張的紀律：門是對的，債在敗北模型）。
```

# ⑥ 不做

```
①不碰其餘 59 站（群乙群丙與 A 其餘 25、C 6 各自另票）
②不改「tick 尾單點 erase」的設計 —— ★那個設計是對的，本票只是不讓它被跳過
③不修那組既有紅（★但要證明它沒變多）
```
