# 07 信箱主動觸發（跨 session relay，2026-07-08 切）

## 定位：並存兩軌

用戶定案 workflow 有**兩軌並存**，按活的大小/並行度選：

| 軌 | 用於 | 機制 |
|---|---|---|
| **信箱 relay（本 doc）** | 小/序列活、設計討論、來回修 | 各角色 = 持久 claude session，git handback 信箱 + **Monitor 主動觸發** |
| **langgraph 機器** | 大/並行活、自動 pipeline | `tools/orchestrator/`，見 `08_machine_workflow_v2.md` |

信箱軌 = 「回到最早的 relay 工作流」，但補上**主動觸發**：別的角色寫信 → 收件角色 session 被喚醒動工，免人肉轉述。

## 角色 = 持久 session

- **★★信箱 = 唯一一個實體資料夾** `<main-repo>/docs/superpowers/handbacks/`（＝`A:\GDS\demo\...`）。**可見性靠實體資料夾共享，跟 git branch 無關**——branch 只影響 checkout 時 tracked 檔的內容，不藏工作樹裡現有的檔。所以誰寫進這資料夾、誰掃這資料夾，就通。
- **6 角色全 arm**（blueprint/systems/reviewer/qa/measurer/**implementer**）：`SESSION_ROLE` 設好，hook 已把信箱路徑指向 **main repo**（`git rev-parse --git-common-dir` 從 worktree 也算得出）→ **worktree 的 implementer 也 watch 同一 main mailbox → 每站自動讀**（含 systems→implementer）。
- **寄件統一寫 main mailbox**：main dir 角色寫 `docs/superpowers/handbacks/`（相對＝main）；**implementer 在 worktree，handback 寫 main mailbox 絕對路徑**（`<main-repo>/docs/superpowers/handbacks/`，非它 worktree 的）。**code 分 worktree、comms 統一 main mailbox。**
- **留 main dir、別 checkout**：measurer 用 `godot --path .worktrees/<slice>` 跑 branch code；QA 用 `git diff main..<branch>`/`git show <branch>:file`+`.measure.json` 判。**只 implementer 真在 worktree**（改 code）。
- **★絕禁在 `A:\GDS\demo` 原地 `git checkout <branch>`**（2026-07-09 事故：換掉所有共用此 dir session 的 branch → commit 落錯支）。要 branch code 用 `--path`/`git show`，改 code 才用 worktree。
- 信箱檔 frontmatter：`from: / to: / status: / topic:`。

## 兩個 hook（互補，別混）

| hook | 事件 | 何時觸發 | 角色 |
|---|---|---|---|
| `handback-inbox.sh` | UserPromptSubmit | **人在該 session 打字時**掃未讀 → 注入 📬 | 被動（補漏，人主動時） |
| `inbox-watch.sh` | Monitor tool | **session idle 掛著時**，新信主動喚醒 | ★主動觸發（本 doc 核心） |

## ★★status 所有權（2026-07-13 用戶戳：measurer 寄件卻自寫 consumed）

**`status` 欄的所有權=收件端，不是寄件端。** 三條鐵律，不可誤讀：
1. **寄件端寫信一律 `status: open`**——不管你「做完沒」。open/consumed 表的是**收件端讀了沒**，非寄件端做完沒。**寄件端絕不自寫 `consumed`**（自寫 consumed = 收件端 Monitor 只掃 open → **這封信永遠不會被主動喚醒送達** → 靜默漏看）。
2. **`consumed` 只有收件端、讀完動工後才改**（open→consumed）＝「我收到並處理了」的回執。
3. 「我(寄件)這輪工作做完了」≠「consumed」。你做完 = 寫一封 `open` 信給下一站；那封信的 consumed 由**下一站**改。
4. **★v2 補了一個 singleton 治不了的洞（2026-08-21）**：寄件端誤寫 `consumed` 的信，watcher 過濾條件已放寬成 `to:我 && ( status:open || 啟動後動過 )` → **仍會被吐一次**。★但只在「這封信從沒露過面」時吐——否則**我自己把信改成 consumed 就會把自己叫醒＝自我通知迴圈**。（這條不免除鐵律 1：寄件端還是一律寫 `open`。）

> 白話：consumed 是**收件人簽收**，不是**寄件人寄出**。你寄出永遠 open，等對方簽。

## 用法

### 收件端（每角色 session 開場 arm 一次）
```
Monitor(command="bash .claude/hooks/inbox-watch.sh", persistent=true, description="<role> 信箱")
```
- 常駐輪詢（預設 20s，`INBOX_POLL_S` 可調）找 `to:<我> && status:open && 沒見過` → 每封新信吐一行事件 → **本 session 自動醒、讀信、動工**。
- emit-once（key=path+mtime）：同信不重觸；revise 重開（mtime 變）→ 重新吐。
- **★arm 是搶佔式（v2，2026-08-21）**：不比誰心跳新，比誰後 arm。**新的一定贏**；舊的下一輪讀到 lock 不是自己 → 印 `⛔ 讓位` 後自退（孤兒自己清自己）。
  - v1 病：開機判一次、`exit 0` 走人；舊進程每 20s touch ⇒ lock 永遠新鮮 ⇒ **只要舊進程活著就永遠沒辦法合法重新 arm**，唯一出路是手動殺進程。
  - ★取捨：誤開第二個同角色 session，被踢的是舊的（可能才是正在工作的那個）——但**它會印出來，看得見**。土法分辨：**5 分鐘內看到第二次「讓位」＝ 真的有另一個同角色 session 活著**。
- **★arm 完必須看到這三行之一**，否則就是沒 arm 成功——**不要自己解釋成「已有實例覆蓋」**：
  - `✅ ARMED role=<你> pid=<n>（無前任）`
  - `✅ ARMED …（前任 pid=… 將於下輪自退）` / `（前任同 session 但已死，已接手）`
  - `✅ 覆蓋仍在（同 session，watcher pid=X 存活，已驗）` ← **這句現在是可驗證的事實，不是猜測**
  - ★通則（值得記）：**守衛不要輸出「需要被解讀的狀態」，要輸出「已經處置完的結果」。**
    `已有實例在跑 → 退出` 是狀態，agent 得猜下一步；`✅ ARMED（前任將自退）` 是結果，沒有東西要猜。
- **★不再吐 `[開場既存]` 全量 backlog**（v2 刪）：那件事本來就有人做、而且做得更好
  （`session-role.sh` SessionStart 注入待辦 + `handback-inbox.sh` **每 turn** 掃）。**Monitor 現在只做一件事：吐真正新到的信。**
- **★SEEN 落地成檔** `.claude/hooks/.inbox-seen.<role>`：新 watcher 繼承前任吐過什麼 → **重 arm 不重吐**。
  （沒有這條：auto-compact → 重 arm → SEEN 空 → 全部 open 信重吐 → ctx 又漲 → 再 compact…**自我循環**。）
- **★每 turn 閘**（掛在 `handback-inbox.sh`）：watcher 沒在跑 → 你**下一次打字**就會看到 ⛔，而不是幾小時後才發現失聰。
  **兩條紀律不可妥協**：**只警告絕不阻擋**（閘門自己有 bug 就 brick 六個 session）、**fail-open**（讀不到 `session_id`／舊格式 lock 就退回現行行為，**絕不因為讀不到就報警**）。

#### ★blueprint 專屬：Telegram 進站 Monitor（開場**額外** arm 一條、與信箱並列，存活 restart/compact）
用戶要遠端用 Telegram 驅動 blueprint（免盯 CLI）。**只 blueprint 一個 session** 開場多 arm 這條（其他角色不 arm、走 git 信箱）：
```
Monitor(command="source tools/telegram/config.local.sh && python tools/telegram/tg_poll.py",
        persistent=true, description="Telegram 進站(用戶訊息喚醒 blueprint)")
```
- **只 blueprint 一 poller**（`getUpdates` offset 消費、多 poller 互搶同一 update）；其他角色走 git 信箱不變。
- 進站事件 `📱 [Telegram] 用戶: <text>` → **當用戶輸入處理**（≠背景事件）→ `bash tools/telegram/send.sh --file <utf8檔>` 回（UTF-8 via 檔避 CP950）。
- **出站只在真需用戶裁**推（WHAT fork／授權／QA 綠／喬不攏）；role-to-role 不推（免手機噪音）。
- bridge 本地 `tools/telegram/`（機密 `config.local.sh` gitignored 不進 git）；細節+安全見 `tools/telegram/README.md`（本地）。

### 寄件端（任意角色）
1. Write 一封信到 `docs/superpowers/handbacks/YYYY-MM-DD-<from>-to-<to>-<topic>.md`。
2. frontmatter：`from: <me>` / `to: <role>` / `status: open` / `topic: <一句>`。
3. 就這樣——收件 session 的 Monitor ~20s 內醒。

### 消費（收件端動完）
- 把該信 `status: open` → `status: consumed`。下輪 Monitor 不再吐。**沒改 = 會再被 handback-inbox.sh 每 turn 提醒**（但 Monitor 因 seen-set 不重吐）。

### ★★無斷點自動鏈（用戶定 2026-07-09）
- **收 handback → 做完 + 立刻寫下一站 handback**（inbox-watch ~20s 自動喚下一角色）→ **鏈自動流到底，不停在自己這站等下個觸發**。
- **禁自造斷點**：不「park／排隊／下個 session／等下再做／非急擱著」。有輸入就往前推。
- **只為真需用戶裁決停**（願景 fork／授權／喬不攏優先序），給具體待裁問題，非「要不要繼續/收工」。詳 `00_roles §無斷點自動鏈` + memory [[feedback-never-wrap]]。

### ★禁 append 到 consumed 信（通則，2026-07-09 用戶定）
- **一封信 = 一次完整交付**；寄出後**禁分批 append 補內容到已寄信**。理由=**信箱競態**：收件端讀完即 `consumed`，義務只掃 `to:我 && status:open` → **append 的晚到內容靜默漏看**（measurer 分批補數字 → QA 用不完整報告判 merge 是活教訓）。
- **要補/修訂 → 開一封新 `status: open` 信**（Monitor 重吐、收件端義務重掃）。原 consumed 信留軌跡不動。
- 特例（同封 revise）：發送方**在收件端尚未 consumed 前**改同封（mtime 變 → Monitor 重吐）OK；一旦 consumed，一律另開新信。
- 交付型角色（measurer）更嚴：**全量完成才寄一封**（見 `03b_measurer.md` 鐵律6），連 open 態部分信都不寄。

## 成本（信不多前提，用戶確認可忽略）
- 輪詢無新信 = **零 stdout = 零 token**（純 shell）。
- 每封真信 = 一次事件 + 一個 model turn（讀信+動工）= **本來就要付的**，Monitor 只自動化觸發。
- 久 idle 後喚醒 = 該 turn context 掉出 prompt cache 重算（稀疏觸發固有；信少可忽略）。
- ★腳本必須 emit-once + 嚴格過濾，否則假喚醒燒 token（太吵 Monitor 會被自動停）。

## 邊界
- Monitor 只喚**活著的 session**（idle 掛 prompt + monitor armed）。關窗 = 斷；重開再 arm。
- 要喚**人**（非 session）用 `PushNotification`（桌面/手機）——寄件端可選加，提醒用戶某軌有事。

---

## ★stall 處置準則（watchdog v4，2026-08-21 用戶定案）

watchdog v4 不再問「有沒有東西在動」（v3 病：量測跑半天＝全靜＝被誤判成停滯），
改問「**有沒有人在等一個不會來的東西**」。fire 走 stdout → 喚醒 **blueprint**（arm 它的 session）。
訊息由 bash 算完整（誰沒開／最老的信／活著的角色／長工作／最後 commit），目標是 **blueprint 一輪短回合就能判**。

| 收到 | 動作 |
|---|---|
| 🔴 `DEAD-ROLE` | **推用戶**——只有他能開終端。訊息帶 `$env:SESSION_ROLE='<role>'; claude` |
| 🟡 `UNRESPONSIVE` | 信是給我自己的 → 自己動。不是 → 寫信催該角色，**不推用戶**。同一封第二次才推 |
| 🟡 `COMMIT-NO-LETTER` | 查 commit 是誰的活 → 寫信要他補推下一站（他出貨了但沒推鏈） |
| 🟡 `CHAIN-BROKEN` | 查最後一封信在等誰。等用戶裁 → 推；等角色 → 補寫下一站信；查不出 → 推用戶 |
| 🟠 `RUNAWAY` | 推用戶（長工作超過 8h，可能要殺 godot） |

★ 原則：**只有「開終端／WHAT 裁決／授權」才推用戶**，角色間能解的 blueprint 自己推鏈。

**七類分類器**（`DEAD-ROLE` / `RUNNING` / `RUNAWAY` / `UNRESPONSIVE` / `COMMIT-NO-LETTER` / `CHAIN-BROKEN` / `OK`）：
- `DEAD-ROLE` **獨立於 RUNNING**——信給一個沒開的角色，不管別人在不在忙，都是 bug。
- `RUNNING`（beacon／godot 進程／檔案活動任一為真）→ **靜默，不管跑多久**，除非撞 `RUNAWAY`。
- 同一 class 連續成立 → **`RE_ARM`(4h) 內只響一次**（v3 病：fire 後重置 ⇒ 每 5h 重響）。
- ★`COMMIT-NO-LETTER` 與 `CHAIN-BROKEN` 用的 git 信號**不可混**：前者只看 `main`，後者看全 ref。
  （v3 病：取全 ref 最新 commit ⇒ merge 到 main 卻沒寫信，反而把警報壓住 1h。）

**參數**（用戶 2026-08-21 拍板）：`POLL=15m` / `T_DEAD=15m` / `T_UNRESP=1h` / `T_IDLE=1h` / `T_MAX_RUN=8h` / `RE_ARM=4h`。
**長工作 beacon** 的寫法與紀律見 `03b_measurer.md` / `03_implementer.md` §長工作 beacon。

---

## ★P9：派工單 frontmatter 必帶 `slice:` 與 `tier:`

本體與兩檔定義見 `01_architect §P9 交接縫`。要點：`slice:` ＝ branch 名去掉 `feat/`＝**唯一真相來源**；`tier:` **只寫在派工單**（其他產物不寫，免第二個真相）；**tier 由 systems 定，做的人不得自選**；**兩檔都不砍 review**。閘：`bash .claude/hooks/seam-gate.sh`（★**2026-08-21 起預設 HARD ＝ 擋 merge**；逃生門 `SEAM_MODE=soft`）。

---

## ★merge 後必驗：git 說「已合併」≠ code 真的在樹上（2026-08-21 實戰事故）

```bash
bash .claude/hooks/merge-verify.sh        # 掃最近 30 個 merge；exit 1 = 有改動被丟
```

**病**：Windows 上 `git merge` 會瞬鎖 index —— 半途 `MERGE_HEAD` 在、但**沒有任何 staged**，
commit 出來就是**把 branch 記成已合併、改動卻沒帶進來**。
★ **比丟改動更陰險的是**：git 從此認為那條 branch **已 merged** ⇒ 之後再 `git merge` 只會說 *nothing to do*，
**而 code 根本不在樹上**。症狀是「功能莫名其妙不見了」，**而 log 看起來完全正常**。

**血證 `4bdce7c1`**：branch 改了 4 個檔，**3 個新檔進來了、被修改的 `specimen_tracer.gd` 沒進來**
（Windows 鎖的典型半途 stage）。HEAD 裡連 `parent_team_id` 都找不到，但 `git merge` 說沒事可做。

★ **偵測判準第一版我也寫錯過**：問「這個 merge 整體有沒有變化」抓不到——
那個 merge 同時帶了別的檔，**整體有變化，只是把 branch 的改動丟了**。
**正確問法是逐檔**：「branch 改過的每個檔，在 merge 結果裡拿的是誰的版本？」

**修法**：從 branch **補一個新 commit**（**別重寫 history**），**逐檔 `md5sum` 對過再 commit**。


---

## ★★承諾即檔名（用戶在場核定 2026-08-21）

**任何信裡寫「已派／將開票／已排／已通知」，必附【實際檔名】。**
**收件端簽收時 `ls` 驗它存在** —— **驗不到就當那件事沒發生**，回信說「檔名不存在」。

```bash
ls docs/superpowers/handbacks/<你聲稱的檔名>     # 收件端簽收動作的一部分
```

### 為什麼要這條（血證：systems 自己犯兩次）
1. **T3 累加案**：我在 spec 改了設計、**沒推派工單** ⇒ implementer 照**舊版**做了整整一輪。
2. **gate 9 warring 票**：只寫在一封**後來被 consumed 的信**裡，**從沒變成正式工單** ⇒ 掉在地上，**用戶問起才發現**。

★ **偵測器的兩個極限**（這條紀律要補的正是第二個）：
- **粗粒度**：信量大時，**任何一封無關的信都會遮蔽警報**（watchdog 只問「有沒有信」）。
- **★機器全盲**：「**信裡承諾的票沒開**」—— **散文承諾追蹤，機器分不出來**。

★ **這是 [[feedback_specimen_handoff_landed_path]] 那條血訓的推廣**：
當初是「specimen 別說『在我手上』，要標**已落地的 exact path**、而且 producer 自己開檔驗」。
**現在推廣到工單本身**：**別說「我派了」，要說「我派了 `<檔名>`」，而且收件端自己 `ls` 驗。**

### ★誠實標注（不可省）
**「散文承諾追蹤」全自動化不可行** —— **prose ≠ schema**，機器讀不出「這句話承諾了一張票」。
本條紀律 ＝ **收件端人工驗 ＋ 檔名紀律** ＝ **目前能 arm 的最大範圍**。
**其餘（沒附檔名的承諾、口頭排程、信中提到但沒開的票）＝ `declared, unenforced`**，
**明寫在 P7 三態表裡，不假裝有守。**

## ★★跨代縫：**「自退協議」的前提是雙方同版**（用戶 2026-08-25 抓到，額度斷電四天期間曝光）

**病**：`watchdog v4` 與 `inbox-watch v2` 都用「**新的一定贏、舊的自退**」搶佔。
**但那個前提是「舊方也跑新版、會讀 lock 歸屬」。**
跨代時舊方是**上一代常駐碼**（compact 前 Monitor 起的）：
**不讀 lock 歸屬、永不讓位、每 poll 還 touch** ⇒ lock 永遠新鮮
⇒ **新版永遠停在「待命」，舊版照舊每 5h 響 14 連發。**

★**根因不是 lock 寫錯，是【對稱升級假設】** —— **跨代才是常態，不是例外。**
（同族：〈估算器禁手抄物理〉的「第二份拷貝必 drift」；差別只在這裡的第二份是**舊版程式**。）

### 修法：**機械判代，不用等逾時**
本版 lock ＝ **3 欄**（`pid` / `session_id` / `claude_pid`）⇒ ★**欄數 < 3 ＝ 舊代**。
- `watchdog.sh` `claim_lock` 回傳 **0 搶到／1 同代持有（會自退）／2 舊代持有（不會自退）**
- `inbox-watch.sh` arm 時同款判：舊代前任 ⇒ **不准輸出「將於下輪自退」那句安撫話**（跨代下那是假話）

### ★輸出紀律（本專案既有原則的又一次應用）
**守衛不要輸出「需要被解讀的狀態」，要輸出「已經處置完的結果」。**
- 可以自解的 ⇒ 說「無須人工介入」
- **不能自解的 ⇒ 必須說出「人要做什麼」**：
  `🔺 需人工介入：… 處置：TaskStop 那個舊 Monitor task（pid=X）→ 本進程下一輪自動上位`
- ★**升級訊息要複述**（`ESCALATE_EVERY`，預設 8 輪）—— **只說一次會被錯過**，而錯過＝回到無限等。
- 同代久不讓位（疑似卡住）⇒ `STANDBY_MAX_ROUNDS`（預設 8 輪 ≈ 2h）後**也升級**，不無限等。

### 已知停擺型：**額度斷電**（不修，記型）
**全角色 API 餓死、監視器活著但腦全下線。** `watchdog` 分類器對它報 `CHAIN-BROKEN`
—— **分類正確，但當下無人能動**。**不需要修分類器**；認得這個型就好。

### ★跨代縫是**全 harness 通病**，不是兩支 script 的 bug（窮盡掃描 2026-08-25）

**三個案例**：`watchdog`（永遠待命）／`inbox-watch`（同信吐兩次）／
★`tg_poll`（**8/19 老 poller 與 v2 搶 `getUpdates` offset** —— 這個**不是重複，是訊息靜默遺失**）。
**同型缺口出現三次 ＝ 架構信號** ⇒ 不逐案修，做窮盡掃描。

**掃描範圍 ＝ 常駐單例（有 `while true` ／ poll loop 者）**：

| 檔 | 跨代保護 |
|---|---|
| `.claude/hooks/watchdog.sh` | ✅ 已修 |
| `.claude/hooks/inbox-watch.sh` | ✅ 已修 |
| `tools/telegram/tg_poll.py` | ✅ 已修（**顯式 `proto=` 版本戳**） |
| `tools/orchestrator/run.py` | 無 lock，但**非常駐 poller**（pipeline runner、機器軌少用）⇒ 不在此範圍 |
| `tools/telegram/fetch_chat_id.sh` | 一次性 helper，非單例 |

### ★規則：**常駐單例必須自報協議版本**
**欄數判代只是 retrofit** —— 它只認得出「**比現行少欄**」的世代，
**對「舊版也寫同欄數」無效**（`tg_poll` 正是這種）。
⇒ **一律加顯式 `proto=N` 戳**。偵測規則**向後相容、不對現役版本誤報**：

| 前任 lock | 判定 |
|---|---|
| 欄數 < 現行下限 | **舊代**（不會自退） |
| 有 `proto=N` 且 `N <` 現行 | **舊代** |
| 欄數足但**無 `proto`** | **同代**（現役版本，會讀歸屬、會自退） |

### ⚠️ 實作陷阱（我自己踩到，記下來）
★**偵測必須讀「覆寫 lock 之前」的快照。**
第一版我把偵測函式寫在 `open(LOCK,"w")` 之後才呼叫 ⇒ **它讀到的是自己剛寫的內容**
⇒ **永遠判「同代」、守衛靜默失效**。
★**一個永遠回 False 的守衛比沒有守衛更糟** —— 它讓人以為已經被保護了。

### ★待命型 vs 自退型：**「替屍體保溫」是待命型獨有的病**（blueprint 現場抓 2026-08-25）

**症狀**：holder pid 已死，lock 卻一直被 touch 保鮮 ⇒ **`lock stale` 永不成立**
⇒ 全體永遠待命、升級訊息空響。

| 單例 | 非持有者行為 | 有無此病 |
|---|---|---|
| `inbox-watch.sh` ／ `tg_poll.py` | 讓位檢查後**直接 exit** | ❌ 天然免疫（碰不到 touch） |
| ★`watchdog.sh` | ★**留在待命迴圈**（設計如此：要等著接手） | ✅ **唯一有風險** |

**修法**：`touch` **必須 gate 在「lock 第一欄 == `$$`」之後** ——
★**把不變量做成【局部檢查】，不要靠控制流保證**（日後有人搬動那行也不會復發）。

### ★★修完 harness ≠ 生效：**「誰在跑哪一版」要當成交付的一部分**
血證：屍體保溫修好時，blueprint 正在跑的 watchdog **是修前版本**
（`.watchdog.lock` 只有 3 欄、沒有 `proto=` 戳）⇒ **修法對它尚未生效，要重 arm 才吃得到。**
★**這是跨代縫的第四個案例** —— 前三個是「舊版不讓位」，這個是「**修好了但跑著的還是舊碼**」。
⇒ **harness 交付要附一句：「請重 arm，否則跑的還是舊版」**，不能修完就當生效。

