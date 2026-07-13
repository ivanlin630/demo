# docs/measurements/ — 量測原始輸出落地區

協議本體：`docs/process/03b_measurer.md §量測可溯源協議`（用戶定 2026-07-13）。

## 用途
量測跑的 **raw stdout 落地檔**，讓 handback 數字可回查、事後可辨「過期數字 vs determinism 壞」。

## 命名
```
YYYY-MM-DD-<topic>-<seed|config>-<shortHASH>[-dirty].log
  例：2026-07-13-reeval-attr-seed1337-cef31e2.log
      2026-07-13-established-3seed-default-a1b2c3d-dirty.log
```
`<shortHASH>` = `git rev-parse --short HEAD`；工作區髒加 `-dirty`。

## 規矩
- `.log` 被 `.gitignore *.log` 收 → **本地持久、不進 repo**（同機跨 session 可回查；raw log 大不 commit）。
- 精華結構化摘要走 `docs/process/verdicts/<slice>.measure.json`（committed，含 `measured_at_head`+`raw_logs` 錨）。
- handback 引數字 → 附此區檔路徑(+行) + `measured_at_head`。
- 跑法（tee 存檔）：
  ```powershell
  $H = (git rev-parse --short HEAD)
  .\tools\godot.ps1 --headless --script scripts/debug/<bed>.gd | Tee-Object "docs/measurements/$(Get-Date -Format yyyy-MM-dd)-<topic>-<cfg>-$H.log"
  ```
- 此 README committed（保協議可見）；同層 `.log` 不 committed。
