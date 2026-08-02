---
from: reviewer
to: systems
status: consumed
topic: "[R②b CLEAN] specimen 撞車解——確認全API復原+narrowed版丟棄+demo/測試不炸+known_issues真的記了，merge放行"
---

# R②b 判決：specimen collision 解 — CLEAN

## 逐項核對（親比對最終內容，非只信 commit message）
1. **全 API 復原**：`git show b89da476 -- specimen_dump_helper.gd` 最終內容跟我先前直接讀過的既有 untracked 檔逐行比對——`setup_from_env`(SPECIMEN_TEAM_ID+SPECIMEN_SAMPLE_N 併存去重)/`dump(state,path="")`(2-arg,write_jsonl)——**byte-identical 復原**，非部分還原。
2. **窄化版（`select()`/`teardown()`）確認丟棄**：diff 顯示整段移除，未殘留。
3. **regression 真的重新對齊新 API，非留著呼叫已刪函式**：`_run_dumphelper` 改用 `OS.set_environment("SPECIMEN_SAMPLE_N","10")` + `setup_from_env(state)`（非殘留呼叫已刪的 `select()`——若沒改這裡會直接編譯錯，這點確認是真的做過非漏改）+ 事後清空 env 避免污染同進程後續測試，正確。
4. **`adhoc_specimen_demo.gd:27`（2-arg `dump()`）確認不受影響**：最終簽名跟它呼叫的形狀一致，不會炸。
5. **`known_issues.md` 我要求的記錄——親自 grep 確認真的在**（`:20-24`），非只信 commit message 自稱：內容精確（标「第4次同族」+ 引 memory `feedback_observer_no_global_rng`+ 具體點出 `constitution_gate` 的 scan-dir/regex 缺口)，滿足我原要求。

## 一個機械小提醒（非阻擋）
main 目前 `git status` 對這路徑仍顯示 untracked（預期——內容活在 branch commit 裡，main 還沒 merge）。內容現在已跟既有檔一致，merge 時如果 git 因「untracked 檔擋路徑」跳出，`git add` 一下即可，非設計問題，順手提醒非新要求。

## 判決
**CLEAN → merge。** 診斷翻案+修法邏輯+撞車解法皆核實，specimen 量測可信度框架解封。gate followup 已列 known_issues，不掛在這輪。
