# 電池拆成獨佔段與可並行段 — HOW（流程；第二版，依 R² M1–M4／S1–S7）

- WHAT：藍圖票 `docs/superpowers/handbacks/2026-10-18-blueprint-to-systems-TICKET-split-battery-into-exclusive-timing-section-and-parallel-safe-section.md`（用戶裁 2026-10-18「拆」）。
- 審查：R² `docs/superpowers/handbacks/2026-10-18-reviewer-to-systems-R2-battery-split-ISSUES.md`。
- 動的檔：`docs/process/merge-gates.tsv`（加一欄）、`.claude/hooks/merge-gates.sh`（runner）、`.claude/hooks/machine-busy.sh`（交接判準）、`docs/process/03_implementer.md` §兩條實作線、`docs/process/03b_measurer.md` 一句。CLAUDE.md 不動（那一行只指向 runner）。
- 不新加閘（用戶 2026-09-10）；不放寬任何門檻。
- ★`merge-gates.sh` 是 systems 在 auto 模式下被權限層擋過的檔；runner 改動等用戶在權限上放行，已送藍圖轉用戶（`2026-10-18-systems-to-blueprint-Q-heir-faction-and-battery-runner-permission.md` ②）。不請別的角色代改。

---

## 一、現況：為什麼大家都在等

- runner 開跑前兩道剎車（`merge-gates.sh:89-160`）：
  1. 全機只准一份電池（`.merge-gates-running` 標記，掃所有 worktree）；
  2. 開跑前 Godot 行程數必須是 0。
- ★第一道今天其實不動：讀端用 `kill -0` 判標記主人活著（`:118`），而標記裡寫的是 Windows pid（`:145`）——Git Bash 的 `kill -0` 看不到 Windows 行程，恆回「已不在」（`machine-busy.sh:27-39` 的註解寫過這件事，並為自己加了 `tasklist` 分支 `_mb_alive`）。今天撐住「一次一份」的是第二道（Godot＝0）。（R² M1）
- `machine-busy.sh` 給 QA／量測員用：有電池標記或 Godot 行程數 ≠ 0 ⇒ BUSY。
- ⇒ 兩條實作線的電池互斥；QA 真玩起 Godot 會讓電池不能開跑，電池在跑時 QA 也不能玩。

## 二、哪些閘要獨佔：三型判準

判決會因為「旁邊同時有別的東西在跑」而改變的閘進 `excl`：

| 型 | 說明 | 初篩（main `94a9f28a6`，R² 複掃一致） |
|---|---|---|
| 讀牆鐘 | 判決用到時間預算或時間門檻（只印不判的不算） | `player-entry-smoke`（`player_entry_smoke_bed.gd:54-65`） |
| 讀全機行程數 | 判決用到全機 Godot／行程數 | `play-selfcheck`（`tools/play_selfcheck.py:55,120-123`） |
| 共用可變狀態 | 判決依賴同一棵樹內、同機其他行程可能同時寫的檔（`res://` 下的輸出、`.godot` 匯入快取、`MG_LOG`） | 由 §四「一棵樹一份 par」整體處理，不逐支分類 |

- 只印不判、留 `par`：`fp-longwindow`（`:26-30`）、`cursor-hover`（`:347-349`）、`my-orders-panel`（`:294-302`）。
- 讀時間或行程數但與負載無關（留 `par`，交件**實測**負載下仍綠）：`phase-root-conservation`（同一行程內根相位總和對該 tick 總時）、`tier2-sweep-staleness`、`watchdog-beacon`（selfcheck 在 `:197` 就 exit，到不了 `tasklist`）。
- 走很多路徑的床（`ui-flow`、`terminal-e2e`）與床呼叫的 helper（`MeasureBedHelper` 等）：實作端掃 `get_ticks_*`／`Get-Process`／`tasklist`／`time.time` 是否進了判決，交件列結果。
- `GODOT_TIMEOUT` 是卡死保險，不是判準 ⇒ 不因為有它就進 `excl`；被負載拖到超時由 §四第 5 點處理。
- 埠：`tools/play.py` 是握手動態取埠（`:48,146-156`），不衝突；交件確認 `play-selfcheck`、`terminal-e2e` 同理。

## 三、註冊表

- 每一列加**第 5 欄 `section`**：`excl` 或 `par`。全部列在本張一次填完。
- runner 讀列檢查（S4）：
  - 欄數必須是 5；不是 ⇒ 該列報錯、不跑、計紅（防中間欄為空時欄位左移）。
  - `section` 不是 `excl`／`par`（大小寫、空白、`parallel` 一律算不認得）⇒ 當 `excl`，印「未知段別：<值>」。空欄同樣當 `excl`，印「未分類」。交件時這兩種數量＝0。
- 註解列（`#` 開頭）不動。

## 四、runner

### 1. 標記與存活判斷（M1）
- 所有「標記主人活著嗎」共用一支：把 `machine-busy.sh` 的 `_mb_alive`（含 `tasklist` 分支）抽到一個共用檔（例如 `.claude/hooks/lib-alive.sh`），runner 與 machine-busy 都 source 它。runner `:118` 的 `kill -0` 改用它。不准再寫第二份。
- 標記一律落 main 工作樹的 `.claude/hooks/`，內容一行 `winpid=<n> tree=<路徑> role=<角色> section=<excl|par> state=<狀態> since=<時間>`；讀端掃所有 worktree（沿用今天掃樹的寫法，舊位置也讀）。
- 狀態（M2）：
  - par：`queued`（拿不到份數、在等）／`running-gate`（正在跑某一支，另記 `gate=<id>`）／`paused`（停在兩支之間讓獨佔段）。
  - excl：`waiting`（在等安靜）／`running`。
- 舊標記 `.merge-gates-running`：讀端當成 `excl running` 認（舊版 runner 還在別的樹上時）；寫端不再寫。

### 2. 參數與順序
- `MG_SECTION=all|par|excl`，預設 `all`＝先 `par` 段、再 `excl` 段。摘要逐格多印一欄段別。
- `MG_FROM`／`MG_TO` 仍以**註冊表列號**為準，在各段內過濾；`PARTIAL` 橫幅不變（S2）。
- 建議用法（S3）：在釘死 HEAD 的 worktree 跑（今天就是這樣）。在 main 上跑時，excl 段開始等待前重驗一次 HEAD；變了 ⇒ 照今天「開跑與結束 HEAD 不同 ⇒ 不可判」的規則處理。

### 3. 可並行段
- **份數上限** `MG_PAR_MAX=2`（TEST VALUE；＝兩條實作線）＋**一棵樹同一時間只准一份 par**（標記含 tree 路徑；同 tree 有活的 par 標記就等）——後者處理共用可變狀態（M4）。
- 拿份數前先看有沒有 excl 標記（`waiting` 或 `running`）：有 ⇒ 寫 `queued`、等。
- 每支閘開跑前：
  - 有 excl 標記（`waiting`／`running`）**且**它的阻擋者只有 par（見第 4 點）⇒ 寫 `paused`、等到 excl 結束；
  - FreeMB < `MG_PAR_MIN_FREE_MB=4000`（TEST VALUE）⇒ 等，最多 30 分鐘；仍不夠 ⇒ 該支記「不可判：記憶體」（不是紅）。
  - 寫 `running-gate gate=<id>`。
- 每支閘跑完後再讀一次 FreeMB，低於門檻 ⇒ 下一支前暫停（S6）。
- 不再要求「開跑前 Godot＝0」。開跑時印 Godot 行程「我們的 N／不知道誰的 M」（沿用 `machine-busy.sh:91-122` 的信標讀法）；M>0 印警告，不判不可判（S1：孤兒偵測不丟）。

### 4. 獨佔段（M2）
- 一進入就寫 `excl waiting` 標記（不是通過剎車後才寫），讓 par 看得到它在等。
- 開跑條件：沒有 par 在 `running-gate` **且** Godot 行程數＝0。不是「par 份數＝0」——停在兩支之間（`paused`）的 par 不擋獨佔段，這樣不會互等。
- 等待中每 60 秒檢查一次阻擋者並印出：
  - 只有 par 在 `running-gate` ⇒ 等它跑完當下那一支（par 看到 `waiting` 會在下一支前停）。
  - 有不是電池起的 Godot（QA 的遊戲、用戶的遊戲、孤兒）⇒ 印歸屬；**par 不停**（停了也等不到安靜，只會讓兩條線白等）；獨佔段繼續等。
  - 等超過 60 分鐘 ⇒ 獨佔段整段記「不可判：等不到安靜」（不是紅），結語寫明。
- 用戶自己的遊戲算 Godot ⇒ 獨佔段照舊等它（不殺、不請用戶關）。
- 開跑後寫 `excl running`；跑完刪標記（trap，同今天）。

### 5. 並行中被拖到超時（M3）
- 判定超時＝輸出裡有**行首錨定**的 `^\[GODOT TIMEOUT [0-9]+s - process killed\]`（`tools/godot.ps1:421`）。直接呼 `godot.ps1` 的閘再加 `RC == 98`（`:456-458`）雙條件；包裝過的閘（`headless-regression.sh`、`bed-sweep-tier2.sh` 等，rc 被映射）只能用標記——交件列出兩類各有哪幾支。
- 判定為超時 ⇒ 不當場判紅，記「超時（並行中）」，**完整輸出照現有慣例落檔**（`_mg_dump`），排進本輪 excl 段尾巴**單獨重跑一次**；重跑結果才是判決。
- 重跑通過**不是無聲綠**：摘要那一格印「PASS（並行超時後獨佔重跑通過）」，並進 carry（`MG_CARRY_RE` 加這個字面，selfcheck 給陽性對照）；這一輪結語不得寫「全部乾淨通過」。
- 同一輪有幾支「超時（並行中）」印出數量。重跑自己也超時 ⇒ 紅。
- ⇒ 間歇性卡死不會被洗掉：它至少留下一次落檔的超時輸出與一格非乾淨的 PASS。

### 6. 基線寫入
- 基線（`:499-530`）只在 `MG_SECTION=all` 且兩段都跑完時寫（同今天「分批跑不寫基線」）。

## 五、交接判準（machine-busy）

- 預設回答「**獨佔段在不在跑、或正在等安靜**」：有活著的 excl 標記（`waiting` 或 `running`）⇒ BUSY；否則 FREE，另印「par N 份（各自狀態）、Godot 行程 我們的／不知道誰的、FreeMB」當資訊。
- 預設輸出多印一行：「若要量時間，請用 `--excl`；par 在跑時你的計時會被拖慢」（S7）。
- `--excl`：給要跑獨佔段或量時間的人——與 runner 獨佔段同一個條件（沒有 par 在 `running-gate`、Godot＝0）。
- QA 開玩前只看預設那一個答案（WHAT 3）。量測員的計時量測用 `--excl`（`03b_measurer.md` 加一句）。
- 存活判斷用 §四 1 那支共用的。

## 六、驗收

- runner 自我檢查（`--selfcheck` 擴充，不新增閘）。★先把標記、存活、等待、段別解析抽成函式，放在 `--selfcheck` 分支之前（今天 `--selfcheck` 在檔頭就 exit，`:32-49`；不抽的話 selfcheck 測的是另一份複寫；S5）：
  - 段別：假註冊表五列（`par`／`excl`／空／`PAR`／欄數 4）⇒ 讀對、空與不認得的當 excl 並印、欄數錯的報錯。
  - 存活（M1）：起一個背景子行程，讀它的 `/proc/<pid>/winpid` 寫進假標記 ⇒ 判活；用已結束行程的 winpid ⇒ 判死。兩個方向都要，不准用 `$$`。
  - 份數：兩份活 par（真 winpid）⇒ 第三份 `queued`；同 tree 兩份 ⇒ 第二份等。
  - 互等（M2）：par `paused`＋excl `waiting` ⇒ excl 判「可開跑」（不死鎖）；excl `waiting` 時新 par 不拿份數；阻擋者含非電池 Godot ⇒ par 不停。
  - 超時（M3）：假輸出行首有標記＋RC 98 ⇒ 記「超時（並行中）」；標記不在行首（轉述）⇒ 不算；重跑通過 ⇒ 該格字面是「PASS（並行超時後獨佔重跑通過）」且 carry 接到。
- 真跑一次（判準照藍圖票）：
  - 兩條實作線各起一輪 `MG_SECTION=all`、同時 QA 起一局真玩。
  - 三者互不等待（獨佔段除外）；印每條的等待秒數；三份標記同時存在時第三份真的印出「等待」並附秒數（M1-3）。
  - 獨佔段的數字（`player-entry-smoke` 牆鐘、`play-selfcheck` 行程數）與單跑時一致。
  - 全程 FreeMB 最低值印出；不出現 2026-09-23 那種被收割。
- **par 分類的對照**（M4）：同一個 par 段跑兩次——一次機器安靜、一次同時開合成負載（一個空轉的 Godot headless＋一個吃 CPU 的子行程）；兩次的**逐格判決**逐字相同（時間欄不比）。不同 ⇒ 那支改 `excl` 並記一筆。
- 分類複核：交件信列每一支 `excl` 的理由（file:line）、「讀時間但留 par」三支的負載實測、`ui-flow`／`terminal-e2e` 與 helper 的掃描結果、超時判定兩類（直接／包裝）的名單。

## 誠實限

- 可並行段在負載下會變慢；總時間不一定變短，變短的是「互相等」的時間。
- 份數上限與記憶體門檻是保守的測試值，沒有用真跑校過；第一輪真跑後再調。
- 記憶體只在每支閘前後檢查，擋不住兩份 par＋QA 的遊戲在同一支閘中途一起膨脹（2026-09-23 的收割就是中途發生）。
- 分類以靜態讀＋一次負載對照為準；對照只蓋那一次跑到的路徑。
