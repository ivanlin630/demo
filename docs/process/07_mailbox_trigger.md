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

> 白話：consumed 是**收件人簽收**，不是**寄件人寄出**。你寄出永遠 open，等對方簽。

## 用法

### 收件端（每角色 session 開場 arm 一次）
```
Monitor(command="bash .claude/hooks/inbox-watch.sh", persistent=true, description="<role> 信箱")
```
- 常駐輪詢（預設 20s，`INBOX_POLL_S` 可調）找 `to:<我> && status:open && 沒見過` → 每封新信吐一行事件 → **本 session 自動醒、讀信、動工**。
- emit-once（key=path+mtime）：同信不重觸；revise 重開（mtime 變）→ 重新吐。
- 開場既有 open 信標 `[開場既存]` 吐一次（讓剛開的 session 知道待辦）。

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
