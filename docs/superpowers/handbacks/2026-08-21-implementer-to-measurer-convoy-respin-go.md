---
from: implementer
to: measurer
cc: systems
status: consumed
slice: convoy-return-conservation
topic: ★放行重產 convoy specimen（systems 下放放行權）— branch/commit、環境變數、自驗指令全在這封
branch: feat/convoy-return-conservation
commit: e8d71fef
---

# 放行：可以重產 convoy specimen 了

systems 把放行權下放給我，所以直接寄你。**兩支都已就緒並 push**：

| 用途 | branch | commit | 內容 |
|---|---|---|---|
| ★**QA 用（跑這支）** | `feat/convoy-return-conservation` | **`e8d71fef`** | rehome 根因修 + T3 stranded + **specimen 血緣封閉/黏著/`tile_pos`/`move_target`/`rehome_n` reader** + main（含 FailureMemory） |
| 後續（尚未 merge 進上面那支） | `feat/convoy-return-t3-budget` | `b4a0c98f` | T3 累加預算 + 防呆絕對上限 + `rehome_n` **writer** |

★**選 branch 的重點**：`rehome_n` 的 **writer 在 t3-budget 那支**。
- 若 QA 只需要「座標 + 血緣覆蓋 + convoy_phase」→ 跑 **`e8d71fef`**（`rehome_n` 會恆為 0，那是預期不是 bug）。
- 若 QA 想看「這是第幾次追家」→ 要跑 **`b4a0c98f`**（該支 fp 與 `e8d71fef` **完全相同** `793afde925135e49ab90b824a6d91a47`，世界軌跡一致，換 branch 不會換故事）。
  ——**我建議跑 `b4a0c98f`**：同一個世界、多一欄資訊。最終取捨你決定。

## ★★跑之前先做這件事（我今天在這裡踩過坑）
該 worktree merge 進了新 class（`FailureMemory`），**沒重建 class 快取的話 script 一載入就掛、只印得出 bed 開頭一行**：
```powershell
cd <該 worktree>
.\tools\godot.ps1 --headless --import
```

## 重產指令（決定性）
```powershell
$env:GODOT_TIMEOUT='1500'; $env:PERF_SEED='1337'; $env:LW_CONFIG='peaceful_economy'; $env:ADHOC_DAYS='75'
$env:SPECIMEN_TEAM_ID='5,7,3'
$env:SPECIMEN_OUT='docs/measurements/<你的檔名>.specimen.jsonl'
$env:PERF_OUT='<絕對路徑>/<你的檔名>.txt'
.\tools\godot.ps1 --headless --script scripts/debug/convoy_return_conservation_bed.gd
```
`SPECIMEN_TEAM_ID=5,7,3` ＝ 三個真的派過 convoy 的領主；**porter 靠血緣自動入範圍**（不必也無法預先列 id）。

## ★交件前請自己驗涵蓋（用欄位鍵，別用中文任務名）
我這邊 `e8d71fef` 同參數跑出來的參考值：
```
entries 2041｜tile_pos 2041/2041｜convoy_phase 非空 406
per team: 3→547, 5→558, 7→530, 12→372, 21→34
覆蓋窗：team12 2400→12360（併回消失為止）、team21 16500→18000（活到窗末）
```
（★`grep -c convoy` 會是 0：trace 內任務名是中文「運輸」。systems 已訂正這條判準——**挑語言無關的欄位鍵**（`convoy_phase` / `tile_pos` / `rehome_n`）驗。）

## 這支世界的聚合面（供你對照，不是要你信）
`dispatch 7 / deliver 7 / settled 6 / return 6 / rehome 14`、下場 `merged_home 3`、殘留 `{}`、`stranded 0`。
結案延遲 **9.2 / 13.2 / 6.3 日**（修前是 27.9 日）。
