---
from: reviewer
to: systems
status: consumed
slice: 電池拆段（流程）
topic: R²b VERDICT＝ISSUES（輕）：M1–M4、S1–S7 方向都收了；新設計留 3 條 must-fix（N1–N3）＋ 3 條小項（T1–T3）。靜態讀 runner／machine-busy／godot.ps1（spec 26e9771d2），沒跑任何閘、沒起 Godot。
---

# 一、M1–M4、S1–S7 收沒收
| 條 | 結果 | 依據 |
|---|---|---|
| M1 | ✓ 見 N2 | §一寫明 `:118` 的 `kill -0` 對 winpid 恆死；§四1 存活判斷抽到共用檔、runner 與 machine-busy 都 source；selfcheck 用真背景子行程的 winpid 兩方向（不用 `$$`）；真跑三份標記印等待秒數 |
| M2 | **部分，見 N1** | 標記帶狀態；excl 一進入就寫 `waiting`；開跑條件改成「沒有 par 在 `running-gate`＋Godot＝0」（paused 不擋，不死鎖）；阻擋者含非電池 Godot ⇒ par 不停；selfcheck 三格。互等與餓死兩個問題解了，但舊的「全機只准一份獨佔段」在新條件裡不見了 |
| M3 | ✓ | 行首錨定標記＋直呼閘加 `RC == 98`（我核 `tools/godot.ps1:421,456-458`：標記字面與 98 都對）；包裝閘名單交件列；超時輸出落檔；重跑通過印「PASS（並行超時後獨佔重跑通過）」進 carry、結語不得寫乾淨；同輪超時數量印出 |
| M4 | ✓ 見 N3 | 三型判準＋一棵樹一份 par；安靜／合成負載兩跑逐格判決逐字相同；三支「讀時間但留 par」實測、`ui-flow`／`terminal-e2e`／helper 掃描交件 |
| S1–S7 | ✓ | 開跑印「我們的／不知道誰的」Godot；FROM/TO 照列號；main 上等待前重驗 HEAD；欄數 5 檢查＋未知段別當 excl；函式抽到 selfcheck 之前；每支後再讀 FreeMB；machine-busy 預設印「量時間用 `--excl`」 |

# 二、must-fix

## N1 第二份獨佔段可以插進第一份的兩支閘之間（舊的「一次只准一份獨佔」被新條件吃掉了）
- v1 §四5 寫「沿用現在的兩道剎車：全機只准一份獨佔段…」；v2 §四4 的開跑條件只剩「沒有 par 在 `running-gate` **且** Godot 行程數＝0」。
- 構造：實作線 A 的獨佔段在跑，閘與閘之間 Godot 行程數是 0（`machine-busy.sh:6-9` 寫過這個形狀：「電池是一連串短跑，兩跑之間 Godot 真的是 0」）；實作線 B 的獨佔段正在 `waiting`，輪詢到 0 且沒有 par ⇒ 條件成立，B 開跑，兩份獨佔段交錯。這正是 2026-09-23 「兩輪電池平行跑把機器吃爆」的構造，而且它破壞的是獨佔段存在的理由（計時閘的數字會被另一份 excl 拖慢）。
- 兩份同時 `waiting` 時也一樣：兩邊都看到對方不是 `running` ⇒ 兩邊同時過。
- 另外，所有「檢查再取得」都是兩步（讀標記、再寫標記）：兩個 par 同時各看到 0 份而都拿、三個 par 同時看到 <2 份而都拿，也會超過上限。
- 要求：
  1. 開跑條件加「沒有別的 excl 在 `running`」，並對多份 `waiting` 給固定的先後（例如標記 `since` 最早者先，同時間以 winpid 小者先）；`waiting` 的非隊首者繼續等。
  2. 取得資格（par 的份數、excl 的運行權）用原子操作：`mkdir` 一個鎖目錄（成功者得）或 `ln`/`set -o noclobber` 建檔，不要「讀 → 判斷 → 寫」。
  3. selfcheck 加兩格：(a) 兩份 excl 同時 `waiting` ⇒ 只有隊首過；(b) 一份 excl `running`（閘間 Godot＝0）時另一份 `waiting` ⇒ 不過；負對照：拿掉「別的 excl」條件 ⇒ (b) 紅。

## N2 標記存活只看「這個 pid 在不在」，pid 會被重用 ⇒ 死掉的標記讀成活的
- §四1：存活判斷共用 `_mb_alive`（`kill -0` ＋ `tasklist` 的 `PID eq`）。只回答「有沒有行程用這個號碼」。`machine-busy.sh:105` 的註解已經記過血證：「pid 會被系統重用（信標 10352 是 6 小時前那支 Godot，而那個號碼此刻是我自己的 bash）」，所以 Godot 信標另有 `_mb_same_proc`（行程名＋StartTime 與 `since=` 差 ≤120 秒，`:87-90`）。
- 電池標記是在 harness 殺 shell 時最容易變殘骸的東西（`merge-gates.sh:94-96` 的註解：trap 不會跑）。殘骸 pid 被別的行程重用 ⇒ `_mb_alive` 回活 ⇒ 殘骸 `excl waiting`／`par running-gate` 讓別人等到逾時（60 分鐘「不可判」）或讓 par 一直停。
- 要求：標記的存活 ＝ pid 存在 **且** 行程名是 `bash`/`sh`（Git Bash）**且** `StartTime ≤ since + 容差`（行程比標記早起來才可能是主人）；`since=` 已在標記裡（§四1），共用檔新增 `_mb_marker_alive <pid> <since>`，同樣不准再寫第二份。selfcheck 加一格：用一個**活著但是別的行程**的 pid（例如 `explorer.exe` 的 pid）寫假標記 ⇒ 判死；負對照：退回只看 pid ⇒ 該格紅。

## N3 par 分類的「負載對照」缺負載強度的地板：兩跑逐字相同也可能只是負載太弱
- §六對照：同一個 par 段，安靜一跑、合成負載一跑，逐格判決逐字相同才算分類沒錯。這個斷言預期是綠的；它在「合成負載其實沒有改變任何東西」時一樣綠（空轉的 Godot headless 與一個吃 CPU 的子行程，在 24 核機器上可能完全不影響單執行緒的閘）。預期綠的對照不是對照。
- 要求：
  1. **負載強度地板**：兩跑都印每支 par 閘的耗時，負載那跑的**中位數耗時比**（負載／安靜）必須 ≥ 具名常數（例如 1.3，TEST VALUE）；低於 ⇒ 該次對照「不可判：負載太弱」，不算過。
  2. **陽性對照**：同一個合成負載下跑一個**已知對負載敏感**的 fixture 閘（selfcheck 內建：一個判決讀全機 Godot 行程數的小腳本、一個有牆鐘預算的小腳本）⇒ 必須不綠；否則合成負載沒有咬到任何東西。這兩個 fixture 不進註冊表（不新加閘）。
  3. 兩跑印各自的記憶體最低值（FreeMB），讓人看得到負載有沒有真的吃掉資源。

# 三、小項（不擋，併同輪）
- **T1 `MG_SECTION=par` 或 `excl` 單跑**：只跑一段的結果不能當 merge 判決（缺另一段）。請像 `PARTIAL` 一樣印橫幅「只跑 par／excl 段 ⇒ 不可當 merge 判決」，並不更新基線（spec 已寫基線只在 `all`）。
- **T2 excl 段「等不到安靜」時的整輪語意**：§四4 寫 excl 段整段記「不可判：等不到安靜」；§四5 的超時重跑排在 excl 段尾巴，等不到安靜 ⇒ 重跑也不會跑。請寫明：這種情形下「超時（並行中）」的閘仍是未結案，整輪結論＝不可判（不是綠、不是紅），結語列出未結案的閘名。
- **T3 舊版 runner 的誠實限**：讀端認舊標記（當 `excl running`）只保護「新版看舊版」。舊版 runner 還在別的樹上時，它只看 `.merge-gates-running` 與 Godot＝0，看不到 par／excl 新標記 ⇒ 它可能在 par 的閘間隙開跑（同 `merge-gates.sh:106-112` 的註解「依賴大家都跑新版的守衛不是守衛」）。請在誠實限寫一句，並在落地前清點仍在用舊 runner 的樹（`runner-self` 雜湊，`:211-212`）。

# 四、結論與下一站
- 判定：**ISSUES（輕）**。N1–N3 都在 HOW 內；N1 是「獨佔段不再獨佔」，優先。
- 修完回 R²c，只審 N1–N3＋T1–T3。CLEAN 後即可交用戶放行 runner 權限、排實作。
- 沒重審：M3、S 項已收的段。
