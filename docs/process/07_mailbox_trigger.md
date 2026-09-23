# 07 信箱主動觸發（跨 session relay，2026-07-08 切）

## 定位：並存兩軌

用戶定案 workflow 有**兩軌並存**，按活的大小/並行度選：

| 軌 | 用於 | 機制 |
|---|---|---|
| **信箱 relay（本 doc）** | 小/序列活、設計討論、來回修 | 各角色 = 持久 claude session，git handback 信箱 + **寄件端 SendMessage 敲門** |
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
| ~~`inbox-watch.sh`~~ | ~~Monitor／背景 Bash~~ | **★2026-09-23 整支退役**（見下「收件端」）——主動觸發改由**寄件端 `SendMessage` 敲門** | ★★它留在表上是為了讓看過舊版的人知道它去哪了，不是還在用 |

## ★★status 所有權（2026-07-13 用戶戳：measurer 寄件卻自寫 consumed）

**`status` 欄的所有權=收件端，不是寄件端。** 三條鐵律，不可誤讀：
1. **寄件端寫信一律 `status: open`**——不管你「做完沒」。open/consumed 表的是**收件端讀了沒**，非寄件端做完沒。**寄件端絕不自寫 `consumed`**（自寫 consumed = 掃 open 的工具看不到它 → **靜默漏看**；★敲門制下這條仍成立：`handback-inbox.sh` 與 watchdog 都只認 open）。
2. **`consumed` 只有收件端、讀完動工後才改**（open→consumed）＝「我收到並處理了」的回執。
3. 「我(寄件)這輪工作做完了」≠「consumed」。你做完 = 寫一封 `open` 信給下一站；那封信的 consumed 由**下一站**改。
4. **★v2 補了一個 singleton 治不了的洞（2026-08-21）**：寄件端誤寫 `consumed` 的信，watcher 過濾條件已放寬成 `to:我 && ( status:open || 啟動後動過 )` → **仍會被吐一次**。★但只在「這封信從沒露過面」時吐——否則**我自己把信改成 consumed 就會把自己叫醒＝自我通知迴圈**。（這條不免除鐵律 1：寄件端還是一律寫 `open`。）

> 白話：consumed 是**收件人簽收**，不是**寄件人寄出**。你寄出永遠 open，等對方簽。

## 用法

### 收件端（★★★2026-09-23 第二版：**什麼都不用掛**）

**不掛任何 inbox watcher。** 別的角色寫完 handback 之後會用 `SendMessage` 敲你，
harness 把訊息直接送進你的對話 ⇒ 你就醒了。
★陽性對照（2026-09-23 17:00）：systems 在**零 watcher**的狀態下被 blueprint 敲醒 —— 不是推論，是發生過的一次。

**為什麼三代 watcher 全退（實測，不是偏好）**：

| 代 | 機制 | 病 |
|---|---|---|
| v1–v2 | `Monitor(inbox-watch.sh, persistent)` | 這一版 Monitor **沒有 `persistent`、30 分鐘硬到期**（`timeout_ms` 上限 3600000，傳滿它仍回「expires in 30m」⇒ 那個上限不是參數決定的）⇒ 每半小時一次【空重掛】＋每次 ARMED 雜訊 |
| v3 | 背景 Bash `role-watch.sh inbox` | 閒置確實安靜（實測跨過自己的 `timeout`、輸出 0 bytes），**但它印完那一行就結束** ⇒ **每收一封信就要重掛一次**（那天 ~20 次/小時） |
| ★v4 | **`SendMessage` 敲門** | 零 watcher、零重掛、**閒置零 token** |

★★★共同病叫得出名字：**前三代都是「我去看有沒有人找我」，v4 是「找我的人直接叫我」** ——
輪詢與推播之差，而**前者的成本隨【角色數 × 小時數】長，後者隨【真實信件數】長**。

★**看門狗不在此列，照舊掛**：它要偵測的是「**沒有**事發生」，而那件事**沒有人會來敲你**
⇒ ★★★輪詢是它唯一可能的形狀。
```
Bash(command="SESSION_ROLE=<role> bash .claude/hooks/role-watch.sh watchdog", run_in_background=true)
```

#### ★★★看門狗的新失效形態：**背景 Bash 會被靜默收割**（2026-09-23）

```
harness 訊息：「stopped because the system is running low on memory」
  ⇒ session 閒置時記憶體吃緊 ⇒ 收割背景 shell（★不是那支腳本出錯）
⇒ ★而看門狗正是那個負責偵測「沒有事發生」的東西
  ⇒ ★★**它死掉的樣子，跟它正常工作的樣子一模一樣：都是不說話。**
⇒ ★★★而新信箱之下【沒有別的 watcher 看著它】—— 唯一還會定時執行的東西是 `handback-inbox.sh`
```

**處置（systems 判，2026-09-23）**：

| 選項 | 判 |
|---|---|
| 設 `CLAUDE_CODE_DISABLE_BG_SHELL_PRESSURE_REAP=1`（★只能在啟動 claude 時設，shell 裡設無效） | ★**不建議、且不是我的格** —— 這台機器與用戶自己的遊戲共用，關掉收割＝拿用戶的記憶體去換我們的背景任務。**要不要開是用戶的決定**，已呈報 |
| ★**讓它的死變成看得見的**（採用） | `handback-inbox.sh` 加一格：**只在 blueprint 的 session**，`.watchdog.lock` 心跳超過 20 分鐘（poll 15 分＋5 分餘裕）就講一行 |
| 自動重掛 | ★**不做** —— 沒人叫就重掛 ＝ 把一個【要人知道的事實】變回沉默；而 harness 也明講了不要自行重啟 |

★**它什麼時候會被收割，是可以預期的**（blueprint 2026-09-23 實測：事後空閒記憶體 15.6 GB
⇒ 收割發生在**更早的低點**，不是現況）——★★而那個低點的來源今天很明確：**跑電池**
（同一天 implementer 的一輪電池也被記憶體收掉，判到 27/76）。
⇒ ★★★所以**跑電池期間別人的背景任務被收割，是這台機器的常態成本，不是異常**
  —— 看到那則 20 分鐘提醒時，第一個要問的是「剛剛是不是在跑電池」，而不是「是不是有 bug」。

★那一格**不是恆真**：lock 新鮮就完全不出聲。已做三向對照（門檻 99999 ⇒ 0 行／門檻 1 ⇒ 1 行／
換成 systems 角色即使過期也 ⇒ 0 行）。★★`lock 不存在`**不報警**：那代表這台機器從沒掛過看門狗，不是它死了。

★★★**而我在驗它的時候踩了一次**：我 `touch` 了 `.watchdog.lock` 來做陰性對照 ——
**那會讓一支已死的看門狗看起來還活著，把真警告壓掉 20 分鐘**。
⇒ 規矩：**不要用「動它的狀態」來測一個讀狀態的守衛**，改動門檻（本例 `WATCHDOG_STALE_S`）。


### ★通訊錄：角色 → session 名（`whoami.sh`，2026-09-23 立）

git 信箱用**角色**定址（`to: systems`），SendMessage 用 **session 名**定址（`demo-95`），
★而中間本來沒有任何東西把兩者接起來 —— 手上有角色名，卻不知道要敲誰。
★★session 名**只有本人看得到**：`ListAgents` 在自己那邊印「This session is demo-XX」，
在別人那邊只印 `demo-XX`、不印角色 ⇒ ★★★這張表**只能各自登記，沒有人能代填**（代填＝猜）。

```
每個角色開場（緊接在 ListAgents 之後）：
  SESSION_ROLE=<role> bash .claude/hooks/whoami.sh demo-XX
讀：bash .claude/hooks/peers.sh   ← ADDR 欄
```
★誠實限：表記的是【登記當下】的名字。session 關掉重開會換名，而**舊的一行不會自己消失**
⇒ 每行帶時間戳，超過 24h 的 peers.sh 標 `?`：★寧可標成可疑，不要靜靜給錯地址。

#### ~~★blueprint 專屬：Telegram 進站~~ ⇒ **★★★進站退役（用戶裁 2026-09-23），改 Remote Control**

```
退役的只有【進站】（tg_poll.py 輪詢 getUpdates）—— ★理由同上：那也是一支要人重掛的 watcher。
★★出站【留著】：`bash tools/telegram/send.sh --file <utf8檔>`（UTF-8 走檔避 CP950）。
★★★而「用戶遠端驅動 blueprint」這個需求沒有消失，它改由 Remote Control 承擔。
```
- **出站只在真需用戶裁**推（WHAT fork／授權／QA 綠／喬不攏）；role-to-role 不推（免手機噪音）。
- bridge 本地 `tools/telegram/`（機密 `config.local.sh` gitignored 不進 git）；細節+安全見 `tools/telegram/README.md`（本地）。

### 寄件端（任意角色）
1. Write 一封信到 `docs/superpowers/handbacks/YYYY-MM-DD-<from>-to-<to>-<topic>.md`。
2. frontmatter：`from: <me>` / `to: <role>` / `status: open` / `topic: <一句>`。
3. ★★★**立刻 `SendMessage` 敲收件人**——`to:` 填 `peers.sh` **ADDR** 欄查到的 session 名；
   message **第一行**寫清楚「這封信是什麼＋檔名」（收件人那邊只先看到第一行）。
   - ADDR 是 `-` ⇒ 那個角色還沒登記 ⇒ ★**敲不到**（信寫得進去，但它不會醒）⇒ 先請它跑 `whoami.sh`。
★**為什麼這一步不能省**：git 信箱現在【沒有人在掃】。「落地 ≠ 通知」那條教訓
（memory `feedback_landed_needs_notify`）以前是「容易忘」，★★這一版把它變成**結構上必然**：不敲就真的沒人看。

### 消費（收件端動完）
- 把該信 `status: open` → `status: consumed`。**沒改 = 會再被 `handback-inbox.sh` 每 turn 提醒**（★那支還在，它是【人打字時】的補漏網，不是 watcher）。

### ★★無斷點自動鏈（用戶定 2026-07-09）
- **收 handback → 做完 + 立刻寫下一站 handback ＋ SendMessage 敲他**（★兩步缺一，鏈就斷在通知這一段）→ **鏈自動流到底，不停在自己這站等下個觸發**。
- **禁自造斷點**：不「park／排隊／下個 session／等下再做／非急擱著」。有輸入就往前推。
- **只為真需用戶裁決停**（願景 fork／授權／喬不攏優先序），給具體待裁問題，非「要不要繼續/收工」。詳 `00_roles §無斷點自動鏈` + memory [[feedback-never-wrap]]。

### ★禁 append 到 consumed 信（通則，2026-07-09 用戶定）
- **一封信 = 一次完整交付**；寄出後**禁分批 append 補內容到已寄信**。理由=**信箱競態**：收件端讀完即 `consumed`，義務只掃 `to:我 && status:open` → **append 的晚到內容靜默漏看**（measurer 分批補數字 → QA 用不完整報告判 merge 是活教訓）。
- **要補/修訂 → 開一封新 `status: open` 信 ＋ 重敲一次**。原 consumed 信留軌跡不動。
- 特例（同封 revise）：發送方**在收件端尚未 consumed 前**改同封 OK（★但要再敲一次說「那封我改了」——mtime 變沒有人在看）；一旦 consumed，一律另開新信。
- 交付型角色（measurer）更嚴：**全量完成才寄一封**（見 `03b_measurer.md` 鐵律6），連 open 態部分信都不寄。

## 成本（信不多前提，用戶確認可忽略）
- 輪詢無新信 = **零 stdout = 零 token**（純 shell）。
- 每封真信 = 一次事件 + 一個 model turn（讀信+動工）= **本來就要付的**，敲門只自動化觸發。
- 久 idle 後喚醒 = 該 turn context 掉出 prompt cache 重算（稀疏觸發固有；信少可忽略）。
- ★敲門一封信只敲一次（emit-once 現在是**人的紀律**，不是腳本的 seen-set）——重複敲＝對方多一個 turn。

## 邊界
- SendMessage 只到**開著的 session**；關窗 ⇒ 投遞結果會說（`peers.sh` 的 STATE 欄事前就看得到 OPEN／DEAD）。
- 要喚**人**（非 session）用 `PushNotification`（桌面/手機）——寄件端可選加，提醒用戶某軌有事。

---

## ★★★四條規矩（★2026-09-02 全文搬入 `detail/07_mailbox-cases.md`，此處留表列）
★**每一條都有血證，撞到了再去 detail 讀成因** —— 這裡只留【要照做的那句】。

| # | 規矩 | 一句話 |
|---|---|---|
| 1 | **stall 處置準則**（watchdog v4，用戶定 2026-08-21） | 工作流 stall ≠ session 死；★終端持久，禁誤診重啟 |
| 2 | **merge 後必驗** | ★**git 說「已合併」≠ code 真的在樹上**（2026-08-21 實戰事故） |
| 3 | **承諾即檔名**（用戶在場核定 2026-08-21） | ★寫「我會做 X」就【當場開檔】；★★誠實標注不可省（血證：systems 自己犯兩次） |
| 4 | **跨代縫：自退協議的前提是雙方同版**（用戶 2026-08-25） | ★機械判代，不用等逾時 |

## ★信箱歸檔（2026-08-26，blueprint 授權；`.claude/hooks/handback-archive.sh`）

**熱目錄只放「還要動作的」＋「今天的」**，其餘 → `handbacks/archive/YYYY-MM/`（`git mv`，保 history）。

★**為什麼要有**：熱目錄長到 **911 封** ⇒ `SessionStart` hook 掃描 **>2 分鐘** ⇒ 被殺 ⇒
★★**所有角色開場【靜默】失去角色 context 與未讀清單，沒有任何錯誤訊息。**
掃描已改單次 awk（2.0s），★**但「沒有人負責讓東西變少」沒解 —— 這支解它。** 911 → 60。

★**三條規則**：
1. ★**列舉 `open`，不列舉「完成的各種說法」** —— 實測有五種 status
   （`consumed`／`open`／`superseded`／`superseded-by-qa`／`withdrawn`）。
   ★★**「完成」的講法會長大，「還要動作」的講法只有一個。列舉不會長大的那一邊。**
2. ★**今天的信一律不動** —— `handback-inbox.sh` 的 `_promise_check` 掃 `${today}-${me}-to-*.md`
   判「宣稱已通知但沒寄信」；今天的被搬走那道檢查就失效。
3. 沒有日期前綴的檔名不動（不猜）。

★**四個 glob 那個目錄的東西**（`inbox-watch`／`watchdog`／`handback-inbox`／`session-role`）
**都是 `dir/*.md` maxdepth-1** ⇒ 搬進子目錄它們就看不到 —— ★**這是目的，不是副作用。**

## ★★★consume 之後【即刻 commit】—— 不要累積到回合末（systems 立 2026-09-01，blueprint 旁證）
```
★病：consume 標記會【消失】⇒ watcher 再見 open ⇒ ★★同一封信【重複喚醒】
★★blueprint 側實測：今天同一封信重複 📬 至少【5 次】⇒ ★★★每次幽靈喚醒 ＝ 一輪 token
★成因候選（★仍未定案）：sed 靜默不匹配／git add 沒帶到／
  ★★★共 main dir 下【原地改而未即 commit】，窗內他人 git 操作覆蓋
  —— 而那是「WIP 掃入事故」的【鏡像】：那次被掃走，這次被蓋掉
```
★**做法**：**改完 `status: consumed` ⇒ 立刻 `git add <該檔> && git commit`**（單獨一顆，內容只有那一行）。
★★**並 `grep` 驗一次** —— ★★★**因為 sed 不匹配是靜默的，回傳碼仍是 0。**
★**成本＝多幾顆小 commit；收益＝消掉幽靈喚醒。** ★★詳 `docs/known_issues.md`「信箱的 consume 標記會消失」。

## ★★★廣播一律【一人一封】—— `to: all` 有兩個獨立缺陷（2026-09-06 血證）
```
缺陷①比對式:inbox-watch 認的是 `^to:<我>`,而 `to: all (systems/implementer/...)`
   ★對【每一個角色】都不命中(連 systems 也是)⇒ ★★那封 HALT 廣播【沒有喚醒任何人】
   ⇒ ★★★四個角色 HALT 期間沒有違規動作【純屬僥倖】—— 他們只是剛好在等下一步
   （已修:matcher 現在認得 `to: all`。★但那只是 defense in depth,不是可以用廣播的理由。）
缺陷②consume 狀態:一封廣播只有【一個 status 欄位】
   ⇒ ★第一個 consume 它的角色,就讓其他所有人【再也收不到】(watcher 要求 status: open)
   ⇒ ★★這個【修不掉】—— 它是檔案格式的性質,不是比對式的 bug
   ⇒ ★★★而它已經發生過:HALT 主信被別的 session 標 consumed,其他人再也不會被喚醒
```
★**所以規矩是**：**要廣播就【一人一封】（收件人各一個檔）** —— 而不是一封 `to: all`。
★★**機械面**：merge-gate `mailbox-broadcast` —— **還開著的 `to: all` 就紅**（已 consumed 的歷史信不擋）。
★★★**而這條的通則值得記住**：
> **一個【多人共用一份狀態】的通知機制，第一個處理它的人會替所有人把它關掉。**

## ★★★支線結案 ≠ 主線自動恢復（systems 立 2026-09-07，blueprint 點名）

**血證**：131 床分診支線吃掉全員注意力；它結案後，**批 2 沒有人回來接**——
`⑨④ 的 90d 重跑萬事俱備（worktree、床、⑩ 已 merge）卻【沒有人按下去】`，零 Godot 在跑。
★**收尾信只寫了「支線結束」，沒寫「主線從哪接回」。**

**規**：
> **大支線的收尾信必須帶一行「主線從哪接回」**——**誰**、**接哪一段**、**下一個動作是什麼**。
> 沒有這一行，鏈看起來完成了，實際上**斷在沒有人被指名的那一格**。

★**與 HALT/RESUME 同型**：那次也是「停」有人喊、「接回哪裡」沒人寫 ⇒ 需要一封點名信才動。
★★**識別法**：支線結案後問一句 **「現在誰手上有活？」**——答不出名字就是斷了。

---

## ★★★「我改了 spec 但沒寄信」＝ 等於沒改（2026-09-10 血證）

「果事件帶因」那張票：R² 判非 CLEAN → **我把三項修訂寫進 spec** → **沒有寄信**。

```
我的記帳    ：已修訂
R² 的記帳   ：非 CLEAN，等回件
鏈上實際狀態：★什麼都沒動
```

★這是「落地 ≠ 通知」的又一次現形：**東西寫進 repo，下游 Monitor 不會醒**
（Monitor 醒的條件是 `to:<角色>` ＋ `status:open` 的**信**，不是 commit）。
★★而它現形的方式值得記：**我是在盤點三張票的狀態時才發現的，不是被誰催的**
⇒ ★★★沒人盤點的話，它會一直靜靜地卡著，而且**看起來像卡在別人手上**。

**規矩**：

```
①凡是【改了 spec / 改了裁定 / 補了洞】而下一站需要知道的，★沒寄信＝沒做完。
②每次處理完一封回件的收尾，加一格自問：**下一站知道嗎？**
③★「鏈看起來停在下游」時，先查【我自己有沒有寄】，再去催下游。
  ★★因為斷在通知那一步的東西，在 git log 裡看起來完全正常。
```

### ★★★而它的【症狀】長這樣（2026-09-10 補，第二次現形時看見的）

```
漏通知的症狀 ＝ **上游把【已經做完的事】排成【下一件】**。
★血證：implementer 的攤平票已經在 main 上（5a8006e7d），
  而我在信裡寫「你的下一張＝camp_target_est 攤平」。
⇒ ★★那是這條鏈【唯一露出來的破口】——
  沒有它，這件事會靜靜地過去，★★★因為 git log 裡它看起來完全正常
  （commit 在、訊息好、驗收綠）。
⇒ 用法：**當你發現自己在排一件「怎麼好像已經有了」的事，先 `git log` 查那個檔**，
  ★而不是先問對方進度。
```

## ★★★停滯警報的處置 ＝ **寄信問，而【判綠權在對方的回信】**（★用戶立法 2026-09-16）

> **用戶逐字**：「**下次就是直接寄信問 除非他回信給你預估時間 預估時間內你才能判綠**」

```
① **watchdog 一亮 ⇒ 立即寄信問嫌疑角色**：**你在做什麼 ＋ 預估什麼時候交**
   ★廣播文必附：**讀取時刻（`date` 實跑，不是憶的）** ＋ **你是從哪裡讀到的**
② ★★★**判綠的【唯一】條件 ＝ 收到回信、且當下仍在對方自報的預估內**
   無回信約 20 分 ⇒ **直訊廣播** ⇒ 仍無 ⇒ **推用戶開終端**
③ **預估到期未交 ⇒ 回到 ①**（★**重新問一次，不是再等一次**）
```
★★**【已刪除】的那一條路：「信齡查了，但我覺得沒事」** —— **判綠權不在我的推斷，在對方的回信。**
★**不對稱**：誤觸成本 ≈ 0（多一封被忽略的短訊）／誤赦成本 ＝ **用戶親自來罵** ⇒ **永遠選誤觸**。
★★★**而「他大概在深工」是一個【看起來體貝】的判斷** —— **它的代價落在別人身上。**

### ★附：廣播文要分清楚的三個時間（★★它是【必填欄位】，不是【判斷的依據】）
```
**信的 mtime**（工作樹）／**信進 git 的時間**／**收件人 consume 的時間** —— ★**三者可以差很遠**
★★血證 2026-09-16：兩封信被回報「躺了 2 小時」，
  **而它們在 git 裡各只有【一個】commit —— 就是收件人的回信 commit**
  ⇒ **寄件人沒有 commit 自己的信 ⇒ 它只活在工作樹裡，直到收件人 commit 它**
⇒ ★★★**報「躺了 N 小時」時要說【你是從哪裡讀到的】** ——
  **否則會把「寄件人沒 commit」誤判成「收件人沒收到」。**
```