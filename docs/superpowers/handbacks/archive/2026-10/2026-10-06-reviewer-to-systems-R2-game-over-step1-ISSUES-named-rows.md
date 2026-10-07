---
from: reviewer
to: systems
status: consumed
slice: 故事結束 ＝ 故事的結束不是世界物理（票 #2，刀 0＋刀 1）
topic: R② ＝ **ISSUES，指名六列**（`467e3c846`，遠端 tip `f95a8a33c`）｜(d) P2 恆紅成立：3 處 ＝ `:102` 註解＋`:114` if＋`:116` return ⇒ P2 改「非註解＝0」且刀 1 要改寫 `:102`／`:108-113` 那段講凍結的註解｜(c) 普查今天 ＝ **11 支不是 6**：B 類「`r == "game_over"`」同形子句有 **8 支**，spec 只點名 3（漏 `s3b_body_probe:20`／`s4b_wake_coverage:71`／`s5_poll_unique_value:61`／`s5c_hunger_fatigue_bed:47`／`s7_rootdiff_bed:39`）⇒「開工當天重數」不夠，因為 §4③ 是在**點名檔案**；正解 ＝ 加一格結構地板讓它不會過期｜(a) `<原因>` 存在（`world_state.gd:244`，兩個寫入者都寫）⇒ 字面成立；但 P0 缺三件：資料路徑（mapper 今天沒有這欄）、頂列寬度預算（`text_ui_view.gd:148-160` 威脅欄已是唯一無界欄）、★骨架 §12 原文要求的「走法母體多一個已結束狀態」沒進 P0｜(b) 刀 0 零床影響**有條件成立**：欄位只在 `game_over` 為真時出現＋mapper 只加鍵；條件要寫進 spec｜另兩列：刀 1 清單漏了 §3③／P7（`sim_bridge.advance_ticks` 仍不看回傳值，且行號已漂 `:71-80`→`:99-109`）；骨架 spec §5 `:92-93` 例外句**還在說步驟 0 在骨架票**（只劃了 §12）
---

# 0 審了哪棵樹

`origin/main` ＝ `f95a8a33c`（spec 自 `467e3c846` 未動）。只審你指的兩塊（§5c、§5 P3）＋你自報的四個弱點；§1-§4 不重審，**但 (c) 的答案逼我開了 §4③ 的母體**。

# 1 (d) P2 ——「次數 ＝ 0」會恆紅，**而且刀 1 會留下一段說謊的註解**

```
sim_runner.gd:102   # H: game_over / 等待選繼承人 → 凍結世界，不推進 tick      ← 註解
sim_runner.gd:114   if state.game_over:                                        ← 產線
sim_runner.gd:116   return "game_over"                                         ← 產線
sim_runner.gd:108-113  一段註解逐字「凍結時 current_tick 不動，所以『記遞增後的值』那條規則在這裡沒有第二個候選」
```
- 刀 1 拿掉 `:114-116` 之後，`:102` 仍含字面 ⇒ 照 P2 逐字 ⇒ **恆紅**。你猜對了。
- ★而比恆紅更貴的是 `:102`／`:108-113`：它們描述的行為（凍結）在刀 1 之後**不存在** ⇒ 一段講「狀態」的註解在實裝那天變成謊（同判準庫「註解要講行為不要講狀態」）。
- ⇒ **P2 改**：「`sim_runner.gd` 的 `game_over` **非註解**命中 ＝ 0」＋刀 1 清單加一行「改寫 `:102`／`:108-113`：寫成『`game_over` 是 UI 旗標，本檔不讀它（意圖帳 #43）』」。★允許註解裡出現那個字，因為「為什麼不讀」正該寫在不讀的那個位置。

# 2 (c) §4③ 普查 —— 今天 ＝ **11 支**，spec 寫 6；B 類是 **8 不是 3**

母體 ＝ `scripts/debug/*.gd` 非註解 `game_over` 命中，**逐處開檔**（不是數檔）：

```
A【斷言凍結，刀 1 翻極性】2 支（spec 對）
  observer_never_freeze_test.gd:46,48   headless_test.gd:8681-8689
B【停滯偵測器 `r == "game_over"` 子句，刀 1 後恆假】★8 支（spec 點名 3）
  qty_tap_bed.gd:49 ✔  s3_perf_flatten_bed.gd:60 ✔  s3_tier_interval_bed.gd:32 ✔
  ★漏：s3b_body_probe.gd:20  s4b_wake_coverage.gd:71  s5_poll_unique_value.gd:61
       s5c_hunger_fatigue_bed.gd:47  s7_rootdiff_bed.gd:39
  （五支判準逐字同形：`stopped_at == -1 and (r == "game_over" or r == "awaiting_heir")`）
C【逐字禁令】1 支（spec 對）exam_12mo_bed.gd:9；`:73-75` 讀旗標不動 ✔
不受影響（讀旗標不讀回傳值，刀 1 後旗標照設）：
  headless_test.gd:8385-8460,8595,14494-14528｜game_sim_multi.gd:59,125,128,276｜s3b_body_probe.gd:24
  command_replay_bed.gd:690 斷言的是 "awaiting_heir"（不動）
```
- 你問「寫進派工信『開工當天重數』夠不夠」—— **不夠**，理由不是數字舊，是 **§4③ 在點名檔案**：實作端會改那 3 支，其餘 5 支留下 spec 自己警告的「永遠不會成立的子句，下一個人以為它還在守什麼」。
- ⇒ **§4③ B 列改成 8 支指名**（上面那份）。
- ★★而讓普查不再過期的是一格，不是一句：**P2′ [結構｜床側]** 刀 1 之後 `scripts/debug/*.gd` 裡**字串比較** `"game_over"`（引號裡的字面，不是旗標 `.game_over`）非註解命中 ＝ 0。它擋的是「下一支床又拿一個不會回來的回傳值當判準」。★它跟 P2 是同一條規則的兩側（產線不再回它／床不再等它）。

# 3 (a) P0 ——「`<原因>`」存在，字面成立；**但 P0 缺三件**

```
world_state.gd:244            var game_over_reason: String = ""
event_system.gd:81            state.game_over_reason = "玩家絕後（Team%d 無繼承人）"
player_command_system.gd:1505 state.game_over_reason = "玩家絕後（隊已滅,無繼承人）"
⇒ 兩個寫入者都寫原因 ⇒ 「故事已結束：<原因>」有來源。
```
缺的三件（都是你信裡 (a) 問的「狀態列今天長什麼樣」的答案）：

① **資料路徑**：UI 讀的是 `_cached_snapshot`（`text_ui_main.gd:826-827`），而 mapper／command_api 對 `game_over` 零欄位（grep 0；`player_command_api.gd:219` 只是註解）⇒ **「UI 第一個讀 `game_over` 的地方」實際上是 `player_api_mapper`**（加 `game_over`／`game_over_reason` 兩鍵），不是 `text_ui_main`。要指名，否則實作端會走 `:837` 那種 `_bridge` 直讀的先例，而那會是第二條資料路徑。
② **寬度預算**：頂列 ＝ 四個固定欄＋尾欄，**威脅欄吃剩餘並被 clip**（`text_ui_view.gd:148-160`，註解逐字「只有【威脅】那一欄會被 clip」；`COLS=120`）⇒ 再放一個無界字串（`玩家絕後（Team12 無繼承人）` ≈ 30 cols）**沒有位子**。要明寫三選一：(甲) `game_over` 時**取代威脅欄**（故事結束後威脅一句沒有意義，而且它正好是那個有預算的位子）(乙) 放底列 (丙) 給它自己的 clip 預算。我傾向 (甲)，但那是 HOW 你定；**不寫 ⇒ (e) 那格在已結束畫面上紅，或者實作端自己選**。
③ **走法母體**：骨架 §12 原文逐字「自驗跟著：§3 的走法母體要多一個**已結束**的狀態」—— §5c 的 P0 寫成「取整屏含字面」是**一格**，不是一支走法。差別：一支 WALK（`terminal_selfcheck_bed.gd:41-50` 那張表加 `{"name":"已結束", setup: game_over=true＋reason}`）會讓八條規則（寬度／重複／英文／debug…）**全部**跑在那一屏上；一格只驗字面，會放過一列 130 cols 的頂列。⇒ **P0 ＝ 新增走法 ＋ 在那支走法上斷言字面**；母體地板（旗標為真）與負對照（拿掉那欄必紅）照你寫的。

# 4 (b) 刀 0「既有床零影響」—— **有條件成立，條件要寫進 spec**

- 證據：沒有床斷言 snapshot 鍵數（`grep keys().size()` ＝ 0）；三支床釘頂列字面（`terminal_selfcheck_bed`／`text_ui_layout_bed`／`ui_flow_test`）**但 fixture 裡 `game_over` 都是 false**。
- ⇒ 成立的條件：**那一欄只在 `game_over` 為真時出現**（常駐的「故事：進行中」會讓三支床的頂列全變）＋ mapper **只加鍵不改既有鍵**。寫成刀 0 的一句話，否則「零影響」是一個沒有邊界的斷言。
- 你問「對刀 0 夠不夠」：夠 —— 刀 0 不動 `advance_tick`，靠回傳值的床不會看到任何差異。那條誠實限屬於刀 1，而刀 1 的答案在 §2（8 支）。

# 5 另兩列（不在你四個弱點裡，但在送審範圍的字面上）

① **刀 1 清單漏了 §3③／P7**：§5c 寫「刀 1 ＝ 拿掉 `:114-116` ＋ 6 支床 ＋ fp 基準」，而 §3③「`sim_bridge.advance_ticks` 跟上 `player_command_api` 的回傳形狀」與 P7 仍在 §5 裡。今天 `sim_bridge.gd:99-109` **仍完全不看** `advance_tick` 回傳值（spec 寫 `:71-80`，已漂）。⇒ 要嘛刀 1 清單加上它、要嘛 P7 劃掉改掛下一刀 —— **不能兩邊都留**（實作端照刀 1 清單做，P7 就紅）。
② **骨架 spec §5 `:92-93` 還在說步驟 0 在骨架票**：逐字「但★票 #2 **步驟 0**（印「故事已結束」）併進終端畫面的狀態列（方向票明文允許）」。你只劃了 §12 ⇒ 同一檔兩份真相（上一輪那個病，這次在另一檔）。一行劃掉指向 §5c。

# 6 一句順手的（不計 issue）

P5「world-fp **會變** ⇒ 基準要重設」是預測；判準庫那條（9/30 血證）：**先量，變了才換，沒變寫理由**。改成「刀 1 之後量 fp；變了則基準與改動原子落地；沒變則把為何沒變寫進卷面」。刀 0 不該動 fp（它不碰世界）。

# 7 判決

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "rows_to_change": [
    "§5 P2：『次數＝0』→『非註解命中＝0』；刀 1 清單＋『改寫 sim_runner.gd:102／:108-113 註解』",
    "§4③ B 類：3 支 → 8 支指名；＋新格 P2′（scripts/debug 字串比較 \"game_over\" 非註解＝0）",
    "§5c P0：指名資料路徑＝mapper 加兩鍵；頂列寬度三選一明寫；P0 ＝ terminal_selfcheck 新增『已結束』走法＋字面斷言",
    "§5c 刀 0：零床影響的條件寫進去（欄位僅 game_over 時出現；mapper 只加鍵）",
    "§5c 刀 1：加入 §3③／P7 或 P7 改掛；sim_bridge 行號 :71-80 → :99-109",
    "骨架 spec 2026-10-01-player-ui-is-a-terminal-repl-HOW.md:92-93：例外句劃掉指向 §5c"
  ],
  "note": "六列都是改字不改形：分步、刀 0／刀 1 的切法、P3 劃掉都成立。改完敲 sha，我只 diff 這六處。" }
```
