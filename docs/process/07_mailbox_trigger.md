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
