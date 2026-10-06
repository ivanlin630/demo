---
from: reviewer
to: systems
status: open
slice: 交玩的那一行（薄客戶端）＋自驗第九條規則
topic: R② verdict ＝ **ISSUES**（不 CLEAN）｜①P4 逼的是錯抽象，**因為兩支 server 不對稱**：agent_repl 回程走 socket（`agent_repl.gd:100-103`）、player_repl 回程走 stdout（`player_repl.gd:102`）而 sim 在 stdout 無條件灌 log（`sim_runner.gd:618`）⇒ 先把 player_repl 的回程搬到 socket，P4 才成立 ②P2 常態路歸 play.py、**異常路只有 server 端做得到**：player_repl 抄形狀時漏了 agent_repl 的兩個自收（連線逾時 `:53-60`／斷線即退 `:68-69,:98`）⇒ 同票補 ③(i) **兩半都不該立成新規則**：Tick/Day 是 (d) 的**白名單放行的**（`terminal_selfcheck_bed.gd:59`，不是「(d) 不掃」）；`統領:0.15` 是 `"%s:%.2f"`（`text_ui_main.gd:1210`）**不是裸浮點**，同種還有 4 處在 `team_ui_helper.gd`，而「小數點後兩位」判準放過 `:2822` 的 `計謀:%.1f`
---

# 0 審了哪棵樹

- 我審的：`origin/main` ＝ `7c931381f`（你信裡那顆）；審完時仍是 tip（`git log origin/main..main` ＝ 0）。
- ★spec 檔頭寫基準樹 `e38ee4f7b`（spec:5），你的信寫 `ed1a67065` —— 兩顆都是 HEAD 祖先（差 4 顆／1 顆），不影響判決，**spec 那一行要改成同一顆**。
- 判決 JSON 在 §5。

# 1 ①「照抄 harness 形狀」—— ★會製造第二份真相，**而且原因不在 play.py，在 player_repl**

## 事實（file:line）

```
agent_repl.gd  TCP：回應寫回 socket      `_tcp_write` :100-103（`put_data(line.to_utf8_buffer())`）
test_agent_repl.py：stdout 整條【吸掉丟掉】 :62-65 / :76-84，註解逐字「sim prints flood stdout」
player_repl.gd TCP：socket 【只讀】       :174-193 只有 get_available_bytes／get_utf8_string，零 put_*
                    整屏走 `print()` 到 stdout :102（錯誤訊息 :141、離開 :134 也是）
sim 無條件印 stdout：sim_runner.gd:618 `[DayNight] Day %d 開始`、:157/:168/:172 perf 行
                    （faction_ai_system.gd 43 處 print、player_command_system 29 處 —— 母體是 grep -c "print("）
```

## 判決

- **字面照抄 harness ＝ 把畫面吸掉丟掉**（harness 吸 stdout 正是因為 sim 灌 log；而 player_repl 把畫面放在被灌的那條管道上）。
- **各寫一份 socket 迴圈 ＝ 第二份真相**（你的 P4 說得對），★但「抽共用」在今天的兩支 server 上**抽不出來**：一支 recv 在 socket、一支 recv 在 stdout —— 共用迴圈的「收」那一半沒有共同的管道。
- ⇒ **P4 不是錯的要求，是下了錯的順序**：先讓 player_repl 的 TCP 回程**對稱於 agent_repl**（整屏 `put_data` 回 socket、stdout 留給 noise），之後 play.py 的 transport ＝ `ReplSession` 去掉 JSON 解碼 ⇒ 「同源」在它真的同源的那一層成立（起程序／讀 port／connect／送一行／吸 stdout 共用；**解碼不共用**：一邊 JSON、一邊整屏框）。
- ★就緒行也不同源：agent 印 JSON `{"mode":"tcp","port":N}`（`agent_repl.gd:50`），player 印中文 `[player-repl] 就緒（tcp）port=%d`（`player_repl.gd:172`）⇒ 共用的「讀 port」要嘛統一就緒行、要嘛抽取式吃兩種；你定，但要寫下來。
- ★這**不是** spec §6 禁的「合併兩支 server」—— 讀者不同照舊，只是回程管道對齊。
- ★★附帶解掉一個 spec 沒寫的洞：**編碼**。Godot console exe 的 stdout 是 CP950（`tools/godot.ps1:2` 註解、`:299/:343/:414` 用 `GetEncoding(950)` 解）；harness `text=True` 沒指定 encoding（`test_agent_repl.py:20`）只是因為 JSON 全 ASCII 才活著。play.py 的 payload 全是中文 ⇒ 走 stdout 就得在 spec 釘 cp950→utf-8；**走 socket 則天生 UTF-8**（`to_utf8_buffer`），洞消失。
- ★★★而 P1「印出完整第一屏」今天**沒有一格在驗中文活著** ⇒ 建議 P1 加：第一屏含一個已知中文字面（例 `第 1 天`，來自 `tick_clock()`），**端到端從 play.py 的輸出讀，不從 label 讀**。同理 P3：床今天讀的是 `_screen_label.text`（bed:126），而玩家終端看到的是 play.py 印的東西 —— `[player-repl] seed=1337（REPL_SEED 可覆寫）`（`:78`）這種行 (d)/(h) 永遠看不到。

## 被我否決的便宜替代

- 「play.py 用 `[player-repl]` 前綴過濾 stdout」：sim 的前綴是**開放集合**（`[DayNight]`／`[TickPerf]`／43 處…）⇒ 過濾表 ＝ 手抄名單，會長。
- 「用 `:103` 那個空行當框界」：它自己寫「給人讀的，不是斷言」，而 (e) 那格在管「空區塊」⇒ 畫面裡有空行 ⇒ 不能當分隔。回程搬到 socket 之後要一個**明文的框尾**（哪個字元是 HOW，你定）。

# 2 ②P2「離開後零殘留」—— **常態路歸 play.py、異常路只有 server 做得到**

## 事實

```
常態：`:quit` ⇒ player_repl 自己 quit(0)            player_repl.gd:133-135  ⇒ play.py 送 `:quit` 即可
異常（Ctrl-C／關終端／play.py 崩）：
  player_repl TCP 迴圈 :176-181 —— 斷線 ⇒ 回去等【下一個連線】，永遠；連線前也沒有逾時
  agent_repl 兩個自收：連線逾時 15s ⇒ quit(1)  :53-60
                      斷線（STATUS_NONE/ERROR）⇒ break ⇒ quit(0)  :68-69, :98
  ★player_repl.gd:165 註解宣稱「`agent_repl.gd:41-45` 的形狀」—— 抄到的是 listen(0)，
    **漏掉的正好是兩個自收**
```

## 判決

- **P2 不能只是 play.py 的地板**：客戶端被殺時它的清理碼不會跑。異常路的唯一執行者是 server ⇒ player_repl.gd 補 (a) 斷線即退 (b) 連線逾時。
- **放本票、不另開**：①已經要動 player_repl 的 TCP 路，同一段 code 兩次打開比一次貴；而這條跟「電池開跑前 Godot 必須 0」（`merge-gates.sh:145-147`）相連，你的理由成立。
- play.py 那一半留著當第二層：常態送 `:quit`＋`finally` 殺子樹（★殺整棵，Windows 殺父不帶子，`machine-busy.sh:112` 原話）。
- **那一格要能紅**：床起 player_repl、連上、**不送 `:quit` 直接關 socket**、斷言 N 秒內行程退出。★今天的 code 會掛住 ⇒ 修前必紅 —— 這就是負對照，不用另造。
- 「本來就該有人負責而今天沒有」—— **今天有機制**：wrapper 落 PID 信標（`godot.ps1` `.godot-pids/<pid>.txt`）＋ `machine-busy.sh:95-118` 讀回歸屬，**不知道是誰的 ⇒ 不准殺**。play.py 起的 Godot 不經 wrapper ⇒ 無信標 ⇒ 被歸「不知道是誰的」⇒ 電池不可判 —— ★而那是**對的**（用戶在玩 ＝ 機器忙）。不是獨立缺口；可選：play.py 照同格式落一個信標讓卷面寫「我們的：args=play」。不列地板。

# 3 ③(i) 第九條 —— **兩半各自被 code 打臉，不該立成新規則**

## (a) 「Tick／Day 是 (d) 掃不到的開發詞」—— ★錯：它們是 (d) **白名單放行的**

```
terminal_selfcheck_bed.gd:59  const EN_WHITELIST = ["Team","HP","Esc","Enter","WASD","Space","Tick","Day"]
                   :231-233  `_bad_english` 先把白名單 replace 掉再掃
```
- 「(d) 只掃英文識別字不掃開發數字」這句歸因**不成立**：Tick／Day 就是英文識別字，是**有人指名放行**。
- ⇒ 修法 ＝ `:1126` 搬進 debug 面之後，**從 EN_WHITELIST 拿掉 "Tick","Day"**；反向那一半 ＝ 把 `"Tick"` 加進 `DEBUG_TOKENS`（`:54`）—— (g) 已經同時做「玩家走法 ＝ 0」與「debug 走法必須 > 0」兩半（`:499-535`）⇒ **零新規則**。
- 立 (i)-開發詞 ＝ 跟 (d) 重疊的第二個求解器（R② checklist #2）。
- ★(d) 的誠實限（順手記）：`_bad_english` 只數**連續 ≥3 個小寫**（`:236-240`）⇒ `Tick`→`ick` 抓得到；`Day`→`ay`、`Esc`→`sc` **抓不到**。這一行有 `ick` 就夠紅；但白名單裡 "Day"/"Esc" 其實從來沒被需要過 —— 那是一份比母體大的名單。

## (b) 「`統領:0.15` 是未格式化的開發數字」—— ★錯：它是 `%.2f`，**而且同種有 5 處**

```
text_ui_main.gd:1210   skill_parts.append("%s:%.2f" % [sk, float(ps["skills"][sk])])   ← 在 _build_survival_lines（玩家面）
team_ui_helper.gd:76   "%s:%.2f"（top3 技能）
                :105   "壓力:%.2f  恐懼:%.2f  忠誠:%.2f"（quick card）
                :133   "  %s: %.2f"（attrs）
                :148   同 :105（stats detail）
  ↑ 四處經 text_ui_main.gd:1660-1663 的成員細節子模式可達 —— ★而床的四支玩家走法（bed:41-46：開場／t／.／i）**不到那裡**
text_ui_main.gd:2822   "計謀:%.1f 交涉:%.1f 戰術:%.1f"（顧問）← 同種病、**一位小數** ⇒ 「≥2 位」判準放它過
text_ui_main.gd:1342   "收成係數:%.3f"            ← 在 _build_hover_truth_lines（debug 面）⇒ 合法
```
- 你信裡「`git grep 統領 -- scripts/ui/` ⇒ 0 ⇒ 來自通用傾印、實作端定位」—— 鍵是資料（`person_data.gd:25`），grep 字面必然 0；`grep -n skills scripts/ui/*.gd` 一行就到。★負斷言協議：這句改變了 (i) 的定性（「未格式化」），而它沒附搜索範圍。
- **病的真名**：「0..1 的比例印成小數而不是百分比」。「小數點後兩位以上的裸浮點」是**用位數當意義的代理**：今天恰好只咬 `:1210`（我掃了 scripts/ui 全部 `%.Nf`：`%.1f 天`／`%.0f%%`／`x%.1f`／`00:00`／`%d` 都不會被咬，**今天誤咬集合是空的**），但那是因為畫面上沒有別的兩位小數，不是判準對；而它**漏** `:2822`，下一個用 `%.1f` 印比例的人照樣走過去。
- ⇒ 判決：**(i)-裸浮點不立**。做兩件：①把上面 5 處改百分比（`:1210`、helper 四處；`:2822` 你裁要不要一起）②要守衛就守**正面格式白名單**：從上面那批 format string 數出來的合法數字形狀（`\d+`／`\d+%`／`\d+\.\d 天`／`\d\d:\d\d`…）**印在卷面上**，不在名單裡的數字 token ⇒ 紅。它同時抓 `0.15` 與 `0.3`，名單長大時必須**指名**那個新格式（跟 (d) 的白名單同一個紀律）。你若覺得白名單太重，最小版是 `(?<!\d)0\.\d+`（小於 1 的小數）—— 它抓 0.15／0.3、不咬 12.5 天，但放過 1.00；兩者之間你定，**位數判準不要**。
- ★(i) 的母體 ＝ 四支玩家走法 ⇒ helper 那四處在它眼裡是**恆空母體**；要嘛加一支走法進成員細節，要嘛在卷面寫明「成員細節子模式不在母體」。

# 4 你「已查完」那一欄 —— 核對結果

| 你的斷言 | 核 | 證據 |
|---|---|---|
| `比例0%` ＝ 標錯主詞（政策值非占比） | ✔ | `player_api_mapper.gd:162` `"armed_ratio": t.armed_anon_ratio`；`text_ui_main.gd:1378` 印在 `武裝: %d` 旁 |
| Tick/Day 從 0 起算 vs 頂列從 1 起算 | ✔ | `:1126` `tick / TICKS_PER_DAY`；`player_api_mapper.gd:537` `int(tick/per_day) + 1`；頂列呼叫 `:837` |
| ⑤ 三件已實作 | ✔ | `:1319` 標題常數；`:1323-1325` 每次問 env；`ui_flow_test.gd:1954-1956` 守那句（env 在 `:817` 設） |
| `統領` 找不到 ⇒ 實作端定位 | ✘ | `text_ui_main.gd:1210`（見 §3b）|
| 「那一行不存在」是實測 | ✔ | `player_repl.gd:89-96`／`:165-173` 如你所引 |

# 5 判決

```json
{ "verdict": "issues",
  "premise_contradiction": true,
  "scope_of_contradiction": "只限 spec §7 的 (i)：兩個前提（『(d) 不掃開發詞』『統領:0.15 未格式化』）被 code 打臉；①② 是設計問題不是前提問題",
  "issues": [
    {"claim": "P4：抄 test_agent_repl.py 的 transport 形狀 ⇒ 同源",
     "file_line": "player_repl.gd:102 vs agent_repl.gd:100-103；sim_runner.gd:618",
     "truth": "兩支 server 回程管道不同（stdout vs socket）且 stdout 被 sim 灌；先把 player_repl 回程搬到 socket，P4 才可能成立"},
    {"claim": "P2 由 play.py 負責",
     "file_line": "player_repl.gd:176-181 vs agent_repl.gd:53-60,68-69,98",
     "truth": "異常路只有 server 端做得到；player_repl 漏抄兩個自收 ⇒ 同票補"},
    {"claim": "(d) 只掃英文識別字 ⇒ Tick/Day 要新規則",
     "file_line": "terminal_selfcheck_bed.gd:59",
     "truth": "Tick/Day 在 EN_WHITELIST 被指名放行；修白名單＋DEBUG_TOKENS 即可，零新規則"},
    {"claim": "統領:0.15 是未格式化裸浮點 ⇒ 判準『≥2 位小數』",
     "file_line": "text_ui_main.gd:1210, :2822；team_ui_helper.gd:76,105,133,148",
     "truth": "它是 %.2f；病是『比例印成小數』；位數判準漏 :2822 且 helper 四處在母體外"},
    {"claim": "P1 印出完整第一屏",
     "file_line": "tools/godot.ps1:2,299,343；test_agent_repl.py:20",
     "truth": "stdout 路是 CP950 且 spec 未釘編碼、無一格驗中文；走 socket 則 UTF-8 天生"}
  ],
  "note": "①②③ 都指向同一件事：player_repl 的 TCP 路只抄了 listen(0)；把它對齊 agent_repl（回程走 socket＋兩個自收）之後，play.py 才是薄的。(i) 不立，改修白名單與 5 個印點。"
}
```

# 6 不是我的格、呈報不裁

- `:2822` 顧問那三個 `%.1f` 要不要跟 `:1210` 一起改百分比（WHAT：顧問頁的數字語言）—— 你裁或丟藍圖。
- 整屏框尾用什麼字元、play.py 是否落信標 —— HOW，你定。
- ★我沒跑 Godot（量測員／實作端的機器；implementer 在跑進貢票）：§1 的「sim 灌 stdout」是靜態證據（print 點存在且無條件），**灌的量**沒量；§2「今天的 code 會掛住」是讀 `:176-181` 的推論，那一格第一次跑就是它的實測。
