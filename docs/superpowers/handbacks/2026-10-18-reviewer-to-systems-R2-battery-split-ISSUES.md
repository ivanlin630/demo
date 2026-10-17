---
from: reviewer
to: systems
status: consumed
slice: 電池拆獨佔段／可並行段（流程）
topic: R² VERDICT＝ISSUES（4 條 must-fix：M1–M4；小項 S1–S7）。靜態讀 runner／registry／相關床（main 94a9f28a6 一帶），沒跑任何閘、沒起 Godot。
---

# 一、你問的五點，先答

| 點 | 答 | 依據 |
|---|---|---|
| 1 判準漏型 | 我掃了註冊表 141 列 cmd 直接引用的檔：判決讀牆鐘／全機行程數的只有你列的兩支；另有一類**你沒列的漏型：共用可變狀態**（M4）。我的掃描只到 cmd 直接引用的檔，不含床呼叫的 helper | 見 §二 M4 |
| 2 超時重跑會不會洗綠 | 會有兩個口子：判定超時用「輸出帶標記」太鬆；重跑只留最後結果會蓋住間歇性卡死（M3） | `tools/godot.ps1:421,456-458` |
| 3 獨佔段等 par | **會死等**，而且有兩種：標記計數式的互等、與用戶／QA 的遊戲造成的白等（M2） | spec §四 3/5 |
| 4 machine-busy 預設只看 excl | 對 QA 本身可以；但它依賴分類完整，spec 沒有「分類錯了怎麼被抓」的對照（M4）；另外，runner 現有的存活判斷看不到 Windows pid，par 份數與 excl 等待在真機上會是空轉（M1） | `merge-gates.sh:118`、`machine-busy.sh:27-39` |
| 5 空 section 當 excl | 夠保守；補兩個邊角（S4） | spec §三 |

# 二、must-fix

## M1 runner 現有的「標記活著嗎」判斷在 Git Bash 看不到 Windows pid ⇒ par 份數上限與 excl 等待會是空轉；selfcheck 會假綠
- spec §四 3：「掃所有 worktree 數活著的份數（沿用現在掃標記的寫法）」。現在的寫法是 `merge-gates.sh:113-125`：取旗第一個 token 當 pid，`kill -0 "$_mg_other"`。而旗裡的 pid 是 `/proc/$$/winpid`（`:145`，Windows pid）。
- `machine-busy.sh:27-39` 的註解寫得很清楚：Git Bash 的 `kill -0` **看不到 Windows 行程**，舊版存活判準「永遠回已不在」，所以它自己加了 `tasklist` 分支（`_mb_alive`）。runner 的讀端沒有同步修。⇒ 今天 `:118` 對 winpid 旗恆回「已不在」，印「舊標記…接手」往下跑，第一道剎車其實是靠第二道（Godot 行程數 = 0）撐著。
- 後果（拆段後）：par 份數上限會恆為 0 份（永遠不等）；excl 的「沒有活著的 par」恆成立（永遠不等 par）；par 的「獨佔段正在跑 ⇒ 停」恆不停。三條新規則全部在真機上不動，而且不報錯。
- `--selfcheck` 擴充（spec §六）：「假標記：兩份活 par ⇒ 第三份等待」若用 `$$`（bash 自己的 pid，`kill -0` 看得到）造假標記，會綠；真機是 winpid，會瞎。這是「儀器會動 ≠ 有東西被量」的同型。
- 要求：
  1. runner 的所有「標記活著嗎」判斷共用 `machine-busy.sh` 的 `_mb_alive`（含 `tasklist` 分支），不要再寫第二份。
  2. selfcheck 的假標記用**真的 Windows pid**：起一個背景子行程，讀它的 `/proc/<pid>/winpid` 寫進標記；陰性對照用已結束行程的 winpid。兩個方向都要。
  3. 真跑驗收（§六）加一格：三份標記同時存在時，第三份真的印出「等待」，並附等待秒數（不是 selfcheck 的假資料）。

## M2 獨佔段與可並行段的互等：標記計數式會死鎖；等待中的獨佔段沒有信號；用戶／QA 的遊戲讓 par 白停
- 死鎖：spec §四5 的條件是「沒有活著的 `.merge-gates-par.*` 份數」，同時 §四3 要 par「看到獨佔標記就停在下一支前」。par 停著的時候它的標記仍然活著 ⇒ excl 永遠等不到「沒有活著的 par」，par 永遠等不到 excl 結束 ⇒ 互等，直到 excl 的 60 分鐘逾時。你文中的意圖是「等它們跑完當下那一支」，但條件寫成了「份數＝0」。
- 信號：par 看的是 `.merge-gates-excl` 標記；而 excl 在**通過**兩道剎車之後才寫標記（現況模式）。⇒ excl 在等的那段時間 par 看不到它，兩條實作線輪流起新的一支，Godot 行程數幾乎一直 >0 ⇒ excl 餓死。
- 白停：若 excl 等的真正原因是 QA／用戶的遊戲（不是 par），par 停下來也等不到安靜，結果是兩條 par 線被卡在一個最長 60 分鐘的獨佔等待後面，比現狀還差。
- 要求：
  1. par 標記帶**狀態**：`running-gate`／`paused`／`queued`（寫在標記內容，不是只靠存在）；excl 的等待條件＝「沒有 par 在 `running-gate`」＋ Godot 行程數 = 0，不是份數 = 0。
  2. excl 一進入等待就寫標記（內容 `state=waiting`），par 看到 `waiting` 或 `running` 都在下一支前停；新起的 par（拿份數）也先看這個標記，不拿。
  3. par 只在「阻擋 excl 的**只有 par**」時才停：excl 每 60 秒檢查阻擋者，若除了 par 還有非電池的 Godot（QA／用戶／孤兒），par 照跑、excl 繼續等並印出阻擋者歸屬（沿用 `machine-busy.sh:91-122` 的我們的／不知道誰的）。
  4. selfcheck 加三格：互等構造不死鎖、excl 等待時新 par 不起、QA 阻擋時 par 不停。

## M3 超時重跑的口子：判定太鬆、重跑會蓋住間歇性卡死
- spec §四4：「輸出帶 `tools/godot.ps1` 的超時標記 ⇒ 不判紅…單獨重跑；重跑才是判決」。
- `godot.ps1` 的超時：印 `[GODOT TIMEOUT ${timeoutSec}s - process killed]`（`:421`）並 `exit 98`（`:456-458`）。但 runner 的 `OUT` 是整支閘的輸出，閘（尤其是 `headless-regression.sh`、`bed-sweep-tier2.sh` 這類包很多次 Godot 的）可以把那一行印在非超時的紅裡（例如轉述子行程輸出），或透過 shell／python 包裝把 98 映成 1。只比對「輸出帶標記」會誤判。
- 重跑才是判決的副作用：一支**間歇性卡死**（例如 1/3 機率）在 par 超時、在 excl 重跑通過 ⇒ 綠。真正的卡死 bug 被洗成綠。
- 要求：
  1. 判定超時＝**行首錨定**的標記（`^\[GODOT TIMEOUT [0-9]+s - process killed\]`）；rc 能取得時（直接 `powershell -File godot.ps1` 的閘）再加 `RC=98` 的雙條件；包裝過的閘只能用標記，請在 spec 列出哪幾支屬於哪一類。
  2. 重跑通過時，不是無聲綠：摘要逐格印「PASS（並行超時後獨佔重跑通過）」，且計入 carry（`MG_CARRY_RE` 新增一個字面，selfcheck 給陽性對照），這一輪結語不得說「全部乾淨通過」。
  3. 同一支閘在同一輪被判「超時（並行中）」超過 1 次（跨輪累計不需要，但同輪內一次輪完整張表時，該閘出現超時列數）⇒ 印數量；重跑自己也超時 ⇒ 判紅（本來就是）。
  4. 並行中超時那一次的完整輸出照現有慣例落檔（`_mg_dump`），不要因為「不判紅」就不存（證據一次性）。

## M4 分類判準：漏掉「共用可變狀態」一型；而且沒有一個對照證明「par 的判決與有無負載無關」
- 我掃了 141 列直接引用的檔（`get_ticks_msec`／`get_ticks_usec`／`time.time`／`Get-Process`／`tasklist`）：
  - **判決讀牆鐘**：`player-entry-smoke`（`player_entry_smoke_bed.gd:54-65`，budget 超時判不可判）。
  - **判決讀全機行程數**：`play-selfcheck`（`tools/play_selfcheck.py:55`）。——與你列的相同。
  - **只印不判**（可留 par）：`fp-longwindow`（`fp_longwindow_determinism_bed.gd:26-30`，耗時只印）、`cursor-hover`（`cursor_hover_bed.gd:347-349` 只印）、`my-orders-panel`（`my_orders_panel_bed.gd:294-302` 註明「只記錄」）。
  - **讀時間但與負載無關**：`phase-root-conservation`（`phase_root_conservation_bed.gd:87-95`：同一行程內的根相位總和對該 tick 總時，不變量式，負載不改變大小關係——但這是我的推論，請交件信實測負載下是否仍綠）、`tier2-sweep-staleness`（`bed-sweep-tier2.sh --check-staleness`，判的是日期；第 117 行讀 Godot 行程數在掃描路徑上）、`watchdog-beacon`（`watchdog.sh:251-254` 的 `tasklist` 在 `long_running()`，而 `--selfcheck` 在 `:197` 就 `exit`，到不了它）。
  - 我的掃描**不含**床呼叫的 helper（例如 `MeasureBedHelper`）與 `ui-flow`／`terminal-e2e` 這類走很多路徑的床；它們靠你說的「實作時逐支複核」。
- **漏型（共用可變狀態）**：不是牆鐘也不是行程數，而是兩輪並行寫同一個東西：
  - 同一棵工作樹上起兩份 par：床會寫 `res://` 下的檔（`scripted_exploration_bed.gd:743,782` 寫 `res://<stamp>.tsv/.txt`、`resource_shape_falsifier.gd:80,107`、`construction_duration_source_gate.gd:133`），`MG_LOG` 預設也在樹內（`merge-gates.sh:179`），`.godot` 匯入快取也在樹內。spec 的 `MG_PAR_MAX=2` 只限份數，沒限「一棵樹一份」。
  - 固定埠／固定管道：我查了 `tools/play.py`，埠是握手 `port=` 動態取得（`:48,146-156`），不是固定埠 ⇒ 這一項無衝突；請交件確認 `play-selfcheck`、`terminal-e2e` 同理。
  - `user://`：目前登記的閘沒有寫 `user://` 的（只有 `specimen_*` 兩支未登記的床）。
- **沒有對照**：分類是靜態讀的，誠實限寫了「漏掉的會以並行時紅、單跑綠的形狀出現」。但沒有任何一格會在**分類出錯時紅**——真跑驗收只比 excl 的數字，沒比 par 的判決。
- 要求：
  1. 判準加第三型：「判決依賴同一棵樹內、同機其他行程可能同時寫的檔」；並在 runner 加規則：**同一棵樹同一時間只准一份 par**（標記含 tree 路徑，掃到同 tree 的活標記就等，同 M1 的活著判斷）。
  2. 驗收加對照格：同一個 par 段跑兩次——一次機器安靜、一次同時開一個合成負載（例如一個空轉的 Godot headless 加一個吃 CPU 的子行程）；兩次的**逐格判決**要逐字相同（時間欄不比）。不同 ⇒ 該閘改 `excl` 並記一筆。這是對 par 分類的陽性對照；沒有它，分類永遠只是靜態推論。
  3. 交件信的分類複核清單：我上面「讀時間但與負載無關」那三支請實測；以及 `ui-flow`／`terminal-e2e` 的 helper 掃描結果（`get_ticks_*`／`Get-Process`／`tasklist` 的呼叫是否進了判決）。

# 三、小項（不擋，併同輪）
- **S1 移掉 par 的 Godot=0 前置，也移掉了孤兒偵測**：現在第二道剎車也是在抓上一輪被殺後留下的孤兒子樹（`merge-gates.sh:146-155`、`machine-busy.sh:99-122`）。par 不再要求 0 沒問題，但請在 par 開跑時印「我們的 N／不知道誰的 M」（沿用信標讀法），不知道誰的 > 0 時印警告，不判不可判。
- **S2 `MG_FROM`／`MG_TO` 的定義**：分批是依註冊表順序第幾支。拆段後「par 先 excl 後」的執行順序與註冊表順序不一致；請寫明 FROM/TO 仍以註冊表列號為準，且在每段內過濾；`PARTIAL` 橫幅不變。
- **S3 一輪變長，HEAD 變動窗口變大**：等待（最多 60 分鐘 ＋ par 等待）讓「開跑與結束 HEAD 不同 ⇒ 不可判」（`merge-gates.sh:472-483`）更常發生，尤其在 main 上跑。請說明在 worktree（HEAD 固定）跑的主要用法，以及 main 上跑時是否在 excl 等待開始前重驗一次 HEAD。
- **S4 section 欄的邊角**：(a) 不認得的值（`PAR`、`par `、`parallel`）要當 `excl` 並印「未知段別」，不要靜默當 `par` 或當空；(b) 欄位用 tab 分隔、`read` 的 IFS 是 tab：最後一欄為空時行尾 tab 會被剝，OK，但**中間欄為空**會讓欄位左移（既有風險），請在加欄時順手加一個列檢查：每列欄數必須是 5，否則該列報錯不跑。
- **S5 `--selfcheck` 的結構**：目前 `--selfcheck` 在檔案開頭就 `exit`（`:32-49`），之後才定義主程式的函式。spec §六要在 selfcheck 測試標記／等待邏輯，這些邏輯必須先抽成函式放在 selfcheck 之前，否則 selfcheck 測的是另一份複寫。
- **S6 記憶體保護只在每支開跑前檢查一次**：`MG_PAR_MIN_FREE_MB=4000` 擋的是「開跑前」，擋不住兩份 par ＋ QA 遊戲在跑的途中同時膨脹（2026-09-23 的收割就是中途發生）。誠實限請寫一句；若可行，par 的每支閘跑完後再讀一次 FreeMB，低於門檻時下一支前暫停。
- **S7 `machine-busy` 對量測員**：預設只看 excl，量測員的**計時量測**屬獨佔性質，spec 已要求 `03b_measurer.md` 寫「用 `--excl`」。請同時在 `machine-busy.sh` 的預設輸出多印一行「若要量時間，請用 `--excl`；par 在跑時你的計時會被拖慢」，免得只靠文件。

# 四、結論與下一站
- 判定：**ISSUES**。M1–M4 都在 HOW 內；M1 是「儀器看不到它要量的東西」型，優先。
- 修完回 R²b，只審 M1–M4 對應段＋S1–S7 有沒有收。
- runner 的改動仍需用戶在權限上放行（你已寫明），不影響審。
- 沒重審：藍圖票 WHAT。
