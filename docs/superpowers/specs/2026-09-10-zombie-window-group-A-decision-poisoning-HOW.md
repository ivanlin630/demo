# HOW spec：殭屍窗群甲（決策污染兩站）——★而查前提時查到一個**更上游的根**

owner: systems ｜ 2026-09-10 ｜ 上游：`is_live_actor` 普查 61 站（A34/B21/C6），
blueprint 已確認修序 **群甲 → 群乙 → 群丙**（判準＝汙染壽命是否超出那一 tick）。

---

## ⓪ ★★★先講我查前提時查到的東西：**殭屍窗不是一 tick，而且它會【整段跳過清除】**

implementer 說群甲的害處是「**壽命比那一 tick 長**」。我去驗這個前提，發現**它成立，
但理由不是我們任何一個人寫的那個** —— 真正的原因在 `sim_runner`：

```
sim_runner.gd:379  _step_cleanup_extinct_teams(state)   ← 清除掛在【tick 尾】
★而它前面有兩條【跳過它】的路：
  ①sim_runner.gd:354  if pass_r["result"] == "player_turn": return "player_turn"
     （伏擊起 encounter ⇒ ★★這一 tick【不會】跑到 :379）
  ②sim_runner.gd:272-281  if state.encounter_active:
     ⇒ ★★★整個 tick body 被 encounter 分支取代，只跑 _step1_advance_time 就 return
       ⇒ **encounter 持續多久，cleanup 就多久沒被呼叫過**
★注意 `WorldEvents.consume_and_clear` 在 encounter 那條路【有】被特別補上
  （:279 註解寫著「encounter 路也要，否則跨 tick 存活」）
  ⇒ ★★★**同一個「跨 tick 存活」的問題被想過一次，而 `teams_pending_erase` 沒有跟著補。**
     （這正是我們反覆記過的形狀：同型另一處沒跟著改。）
```

**後果（★這是母體級的，不是兩站級的）**：

```
teams_pending_erase 與那些【已判死但還在 state.teams 裡】的隊，
★會活過整個 encounter，並在 encounter 結束後的【第一個正常 tick】被全世界看見一次
  —— 那一 tick 的 61 個迭代站點【全部】會看到它們。
★★而 encounter 正是【玩家在看】的時候。
★★★所以「群甲兩站」是【症狀】；根是【清除可以被跳過】。
```

---

## ① 修法：**先修根，再修那兩站**（★兩件都做，但順序不能反）

### (a) 根：清除不得被跳過

```
①sim_runner.gd:354 的 player_turn 早退：在 return 之前補一次 _step_cleanup_extinct_teams。
  ★安全性論證：那條路早退之後，本 tick 後面的系統【都不會跑】
    ⇒ 「多系統持 team_ids 快照」這個原始理由在此處不成立（沒有後續消費者）。
  ★★但這是【我讀出來的】，不是量出來的 ⇒ R² 要打這一格。
②sim_runner.gd:272-281 的 encounter 分支：同樣補一次。
  ★理由與 `WorldEvents.consume_and_clear` 當初被補上的理由【逐字相同】。
★★★而正確的形狀不是「兩處各補一行」，是把清除搬到一個
   【所有 return 路徑都會經過】的地方（GDScript 沒有 defer ⇒ 用一個小 wrapper：
   `advance_tick` 呼 `_advance_tick_body`，在拿到結果之後、回傳之前呼一次清除）。
   ⇒ ★這樣【下一個新增的 early return】不會再製造同一個洞。
```

### (b) 兩站本身（★即使根修好，這兩站仍要修）

```
npc_combat_system.gd:150  team_strength 的護衛加總迴圈
  現況：for tid in state.teams: … if t.current_task == TASK_ESCORT and … : base += _strength_raw
  ★殭屍護衛仍然加總 ⇒ 灌水戰力，而戰力餵決策（_eff_strength → 敗北出路 → 潰退判斷）
  修法：迴圈內加 `if not state.is_live_team(tid): continue`
vision_system.gd:41  for other_id in state.teams（被觀測的那一側）
  ★現況觀測者那一側（:27）已經有守衛，但它是 `state.teams.has(tid)`
    ⇒ ★★【它知道有這個問題，卻用了錯的謂詞】：has() 認不出 pending_erase。
  修法：兩側都改成 `state.is_live_team(...)`
```

★**為什麼根修好了還要修這兩站**：清除搬到 wrapper 之後，**tick 內**仍然存在
「判死 → tick 尾清除」之間的窗（那是原設計，且它是對的）。
★★**根修的是【窗會不會延長到跨 tick】，站修的是【窗內誰在看】。**

---

## ② ★★★驗收：本票【會改變行為】——所以 fp 一定會變，不得拿 fp 不變當綠

```
★這是本批第一張【不是零行為改變】的票。
⇒ 驗收的主詞從「fp 相同」換成【差異是可解釋、可歸因、有界的】：
```

| # | 格 | 判準 |
|---|---|---|
| ① | **根：清除不再被跳過** | 造一個 encounter（伏擊）＋ 同 tick 有隊滅團 ⇒ ★`teams_pending_erase` 在 encounter 期間**必須是空的**；★★成對對照：把 wrapper 拿掉 ⇒ 這一格必須紅 |
| ② | **窗長度** | dump「一支隊從判死到真的從 `state.teams` 消失」經過幾個 tick ⇒ 修前（encounter 情境下）> 1，修後 ＝ 1 |
| ③ | **戰力灌水** | 同 seed 改前後，`team_strength` 的**逐次呼叫值分布**；★只報分布，★★而【灌水那幾次】要能具名（哪一 tick、哪一隊、灌了多少） |
| ④ | **belief 污染** | 修前後：`team_intel` 裡指向「已判死未 erase 之隊」的 row 數 ⇒ ★修後應為 0；★★若修前也是 0，**那就是這一站在本窗不可達**，要如實回報（不得把 0 讀成「修好了」） |
| ⑤ | **fp** | ★**會變，且【必須變】** —— fp 相同反而是紅燈（表示兩站的守衛沒有咬到任何東西）⇒ ★★這一格是【反向斷言】 |
| ⑥ | **既有紅不變** | `recovery_r1_test`／`headless_test` 那組**既有 FAIL** 修前後**同一組**（★它們是既有紅，本票不負責修，但也不得變多） |

★**誠實限**：③④ 都是**分布／計數**，不是「世界應該長怎樣」的判準。
★★而 ⑤ 的反向斷言有它自己的風險：**fp 變了不代表變對了** ⇒ ②③④ 才是歸因。

---

## ③ 風險

```
①★在 early-return 路徑上跑清除，可能有我沒看到的消費者 ⇒ R² 必打（見 ①(a) 的安全性論證）。
②★★encounter 期間清除死隊：encounter 自己可能持有 team ref（玩家正在打的那一隊）
   ⇒ ★★★若那一隊就是被判死的那一隊，清除會不會把 encounter 的地基抽掉？
     —— 這一格我【沒有查】，標【未驗】，R² 或實作要先確認。
③戰力變化會傳到潰退／敗北出路 ⇒ 滅團率可能動。
   ★預先講好：若滅團率暴走，**回 blueprint，不 revert 這張票**（同攻擊門那張的紀律）。
```

---

## ④ 這張票【不做】

```
①不碰其餘 59 站（群乙群丙與 A 其餘 25、C 6 各自另票）
②不改 teams_pending_erase 的「tick 尾單點 erase」設計 —— ★那個設計是對的
③不修 recovery_r1_test／headless_test 的既有紅（★但要證明它沒變多）
```
---

## ⑤ ★★★R² 回件（2026-09-10）：**CLEAN**，而【我標未驗的那一格】被追到底了

### (1) 「encounter 期間清除會不會抽掉地基」——★不會，而且**我怕的情境結構上進不去**

```
第一層（每輪處理 advance_encounter_tick）：靠 state.encounter_units（獨立 per-person 名冊）
  ＋ encounter_attacker_id/defender_id（★純 int 不是物件參照）；
  _has_active_units／_all_exited（:915-931）只掃 encounter_units，★完全不碰 state.teams。
  唯一 state.teams.get(...) 那處（:890 messenger_exit）已 `if parent:` 守著（:891）。
第二層（resolve_encounter_end）：:1194/:1204/:1211/:1229 每處 get(...) 後面都接 `if t:`。
⇒ 兩層都是防禦寫法，team 不見了就跳過那段記帳，不會崩。

★★★而【我怕的那個情境結構上不會發生】：teams_pending_erase 的寫入點只有
   faction_ai_system.gd:2423/2440/4408-4409 —— ★全部在正常決策迴圈裡，
   而 encounter_active 時整段跳過那個迴圈。
   ⇒ **encounter 進行中，沒有任何程式碼路徑會把新的隊標記成待清除**
     （全庫查 encounter_system／npc_combat_system：零筆 `teams_pending_erase`）。
   ⇒ ★★「encounter 正在用的隊，恰好是這一刻被判死的隊」不會發生 ——
     ★★★不是機率低，是**判死的程式碼在 encounter 期間根本不會被執行**。
```

★**兩層理由都記在這裡**（R² 的建議）：防禦寫法讓它不會崩／結構讓那個情境進不去。
★★**而這也界定了窗的長度**：encounter 期間**不會新增**待清除者
⇒ 存活的是 **encounter 開始那一刻已經在 pending 裡的那些** ⇒ 窗 ＝ **encounter 全長 ＋ 1 tick**。

### (2) early-return 路徑上跑清除：★沒找到反例，論證成立

```
_run_systems（:351）在 :354 檢查【之前已經完整跑完】（pass_r 是它的回傳值，不是進行中的引用）
⇒ 不存在「pass 還在跑、cleanup 把它腳下的隊抽走」的交錯。
下游：sim_bridge.gd:86-87 消費 "player_turn" 只是把訊號原樣往上傳給 UI，★不持有 team_ids 快照；
      :309 的 all_teams 是 _advance_tick_body 的【區域變數】，函式一 return 就消失。
```

### (3) fp 反向斷言：不脆 —— ★但把「同一個構造場景」寫死

**驗收表⑤那一格補上（照 R² 的字）**：

```
★本格【必須在①②的同一個構造場景上跑】（構造一個 encounter ＋ 同 tick 有隊滅團），
★★【不得】用自然長跑／隨機 seed 驗 —— 否則「沒觸發」與「沒做」無法分辨。
⇒ ★★★這樣「窗要選到確定有滅團的那一段」就不是散在腦裡的判斷，是寫在驗收表裡的規則。
```

### (4) R² 順手記的一筆（我收）

```
★「半個守衛」比【完全沒守衛】更危險 —— 因為它不會引人懷疑。
  （vision_system:27 已經有守衛，而它用的是 has()，認不出 pending_erase。）
```

⇒ **R² 判 CLEAN，直接 dispatch。**
