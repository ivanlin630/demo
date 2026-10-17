# 電池拆成獨佔段與可並行段 — HOW（流程）

- WHAT：藍圖票 `docs/superpowers/handbacks/2026-10-18-blueprint-to-systems-TICKET-split-battery-into-exclusive-timing-section-and-parallel-safe-section.md`（用戶裁 2026-10-18「拆」）。
- 動的檔：`docs/process/merge-gates.tsv`（加一欄）、`.claude/hooks/merge-gates.sh`（runner）、`.claude/hooks/machine-busy.sh`（交接判準）、`docs/process/03_implementer.md` §兩條實作線那一行。CLAUDE.md 不動（那一行只指向 runner）。
- 不新加閘（用戶 2026-09-10）；不放寬任何門檻。
- ★`merge-gates.sh` 是 systems 在 auto 模式下被權限層擋過的檔；本張的 runner 改動要等用戶在權限上放行（見交回）。不請別的角色代改。

---

## 一、現況：為什麼大家都在等

- runner 開跑前兩道剎車（`merge-gates.sh:89-160`）：
  1. 全機只准一份電池（`.merge-gates-running` 標記，掃所有 worktree）；
  2. 開跑前 Godot 行程數必須是 0。
- `machine-busy.sh` 給 QA／量測員用：有電池標記或 Godot 行程數 ≠ 0 ⇒ BUSY。
- ⇒ 兩條實作線的電池互斥；QA 真玩起 Godot 會讓電池不能開跑，電池在跑時 QA 也不能玩。
- 真正需要安靜機器的閘只有少數幾支（下一節）。

## 二、哪些閘要獨佔

判準：**判決會因為旁邊有別的負載而改變**的閘。兩種：
- 判決讀**牆鐘時間**：有時間預算或時間門檻（不是只印出來）。
- 判決讀**全機 Godot 行程數**：別人的 Godot 會被算進去。

靜態初篩（main `97d059175`，實作時要逐支複核）：

| 閘 | 理由 |
|---|---|
| `player-entry-smoke` | 240 秒牆鐘預算，超時判不可判（`player_entry_smoke_bed.gd:52-69`） |
| `play-selfcheck` | 斷言「前後 Godot 行程數相同」，讀的是全機（`tools/play_selfcheck.py:53-56,120-123`） |
| 其他讀全機行程數或牆鐘門檻的 | 實作端 grep：註冊表裡每一支的 cmd 與它跑的床／腳本中 `get_ticks_msec`／`get_ticks_usec`／`tasklist`／`Get-Process` 進了判決的；只印不判的不算 |

- 其餘全部進可並行段：指紋、headless、coin_eq、掃描型、一般床。
- `GODOT_TIMEOUT` 只是「卡死保險」，不是判準 ⇒ 不因為有它就進獨佔段；它被負載拖到超時的情形由 §四第 4 點處理。

## 三、註冊表

- `merge-gates.tsv` 每一列加**第 5 欄 `section`**：`excl` 或 `par`。
- 空欄 ⇒ runner 當成 `excl`（保守：沒分類的不准並行），並印一行「未分類」。全部列在本張一次填完，交件時未分類數＝0。
- 註解列（`#` 開頭）不動。

## 四、runner

1. 讀列改成 `read -r id cmd purpose expect section`。
2. 新參數 `MG_SECTION=all|par|excl`，預設 `all`＝先跑 `par` 段、再跑 `excl` 段。摘要逐格多印一欄段別。
3. **可並行段**：
   - 不再要求「全機只准一份」，改成**份數上限** `MG_PAR_MAX=2`（TEST VALUE；＝兩條實作線）。每份開跑時在 main 工作樹寫 `.merge-gates-par.<winpid>`，掃所有 worktree 數活著的份數（沿用現在掃標記的寫法）；滿了就等（每 60 秒重查並印一行），不判紅。
   - 不再要求「開跑前 Godot 行程數＝0」。
   - 記憶體保護：每支閘開跑前讀 FreeMB（現成 `_mg_freemb`），低於 `MG_PAR_MIN_FREE_MB=4000`（TEST VALUE）就等，最多等 30 分鐘；仍不夠 ⇒ 該支記「不可判：記憶體」（不是紅）。
   - 獨佔段正在跑 ⇒ 可並行段在**下一支閘開跑前**停下來等（已經在跑的那一支跑完）。
4. **被負載拖到超時**：可並行段某支閘失敗，且輸出帶 `tools/godot.ps1` 的超時標記 ⇒ 不判紅，記「超時（並行中）」，排進本輪的獨佔段尾巴**單獨重跑一次**；重跑才是判決。摘要兩次都印。
5. **獨佔段**：
   - 沿用現在的兩道剎車：全機只准一份獨佔段（`.merge-gates-excl` 標記），開跑前 Godot 行程數＝0。
   - 另加一條：沒有活著的 `.merge-gates-par.*` 份數。有 ⇒ 等它們跑完當下那一支（它們看到獨佔標記就會停在下一支之前）。等的時候每 60 秒印一行，等超過 60 分鐘 ⇒ 獨佔段整段記「不可判：等不到安靜」。
   - 用戶自己的遊戲也算 Godot 行程 ⇒ 獨佔段照舊要等它（同今天，不殺、不請用戶關）。
6. 舊標記 `.merge-gates-running`：讀端繼續認它（舊版 runner 還在別的樹上時，視為獨佔），寫端不再寫。
7. 基線寫入（`:499-530`）只在 `MG_SECTION=all` 且兩段都跑完時寫（同今天「分批跑不寫基線」）。

## 五、交接判準（machine-busy）

- `machine-busy.sh` 預設回答「**獨佔段在不在跑、或正在等安靜**」：有活著的 `.merge-gates-excl` 標記 ⇒ BUSY；否則 FREE，另印「可並行電池 N 份在跑、Godot 行程數 M、FreeMB」當資訊。
- `machine-busy.sh --excl`：給要跑獨佔段的人（runner 自己也用同一支判準）——要求 Godot＝0 且無並行份數。
- QA／量測員開玩、開量前只看預設那一個答案（WHAT 3）。
- 量測員的計時量測（perf、per-tick 毫秒）屬獨佔性質：量測協議裡寫一句「量時間的跑法用 `--excl` 判準」（`03b_measurer.md`）。

## 六、驗收

- runner 自我檢查（`--selfcheck` 擴充，不新增閘）：
  - 假註冊表三列（par／excl／空）⇒ 段別讀對、空欄當 excl 並印「未分類」。
  - 假標記：兩份活 par ⇒ 第三份等待；有 excl 標記 ⇒ par 停在下一支前；有 par ⇒ excl 等待。
  - 假超時輸出 ⇒ 記「超時（並行中）」並排進獨佔段重跑。
- 真跑一次（判準照藍圖票）：
  - 兩條實作線各起一輪 `MG_SECTION=all`、同時 QA 起一局真玩。
  - 三者互不等待（獨佔段除外）；印每條的等待秒數。
  - 獨佔段的數字（`player-entry-smoke` 牆鐘、`play-selfcheck` 行程數）與單跑時一致。
  - 全程 FreeMB 最低值印出；不出現 2026-09-23 那種被收割。
- 分類複核：交件信列每一支被分到 `excl` 的理由（file:line），以及「讀牆鐘但只印不判」而留在 `par` 的清單。

## 誠實限

- 可並行段在負載下會變慢；總時間不一定變短，變短的是「互相等」的時間。
- 份數上限與記憶體門檻是保守的測試值，沒有用真跑校過；第一輪真跑後再調。
- 分類是靜態讀的；漏掉的「其實會被負載影響」的閘，會以「並行時紅、單跑綠」的形狀出現——遇到就把它改成 `excl`，並記一筆。
