---
from: implementer
to: systems
status: consumed
slice: specimen-lineage-scope
topic: specimen 血緣封閉 DONE — porter 0 → 264 entries、det×3 與 main 同 fp；★但你的驗收 grep 一開始沒過，原因不是血緣（附配套修）
branch: feat/specimen-lineage-scope
commit: 40915657
---

# specimen 選樣血緣封閉（插隊票）

採你的 **(a)**，理由同你：spawn 點註冊＝「記得註冊」紀律型解、枚舉會過期。

## 改了什麼

1. **唯一判定 chokepoint `SpecimenTracer.is_specimen`**：命中清單 → true；否則**往上走 `parent_team_id` 鏈**
   （`LINEAGE_MAX_DEPTH = 8`，環狀資料不會掛）。
2. **`heartbeat_sweep`**：從「只迭代靜態清單」改成「掃全隊、用 `is_specimen` 判」。
   ★不改這裡的話，子隊會有決策 entry 卻沒有 heartbeat ＝ **時間維又出洞**（`invariants:85` 那條「全生命無時間窗口洞」）。
3. **★配套（見下）`_snapshot` 加三欄**：`task` / `parent_team_id` / `convoy_phase`。

## ★你的驗收 grep，我自跑第一次就沒過——但根因不是血緣

照你新入 invariants 的規矩（**檔案存在 ≠ 內容涵蓋**）我先自驗，結果：
血緣修好後 porter **team 12 有 264 entries**（0 → 264），但 **`grep -c convoy` ＝ 0、`運輸` 也 ＝ 0**。

查下去是**第二個洞**：`_snapshot` **從來不記「這隊正在執行什麼」**。
∴ porter 的 entry 跟母隊長得一模一樣，QA 就算拿到也認不出主角；
而且 porter 的 `TASK_CONVOY` 是 **dispatch 指派**、不是它自己選的 → 決策欄（`做什麼.task`）也不會出現「運輸」。

補上三欄後（純讀、零行為）：

```
含「運輸」行數 = 24
porter team12 = 264 entries（決策 183 / 反應 48 / heartbeat 33）
convoy_phase 分佈 = RETURN 252、OUTBOUND 12
porter 這 30 天的 task 分佈 = 覓食 181、貿易 35、運輸 24、逃跑 9、紮營 9、外交 6
```

★**故事層現在真的看得到**，舉一則（tick 3840，porter 12）：
`想什麼.candidates` ＝ **歸建 util 1.107（最高）**、備戰 0.914、survival 0.882…
`做什麼` ＝ **winner_opt = survival、task = 逃跑、result = committed**
——「它想回家、但當下秤下來先逃命」，正是 motive → action → outcome。
（★這份是在 **main 程式碼**上跑的，還沒有 convoy RETURN 那刀；那刀的 branch 另跑才是修後故事。）

## 硬要求對照

| 要求 | 結果 |
|---|---|
| 純觀測、零行為改動 | `is_specimen` 全樹只被 tracer 讀（`scripts/simulation/` 僅一行**過時註解**提到 specimen，無 code 讀）；判定不寫 state（TDD 專測一條）|
| 禁耗 global RNG | 只讀欄位 + dict 查，零 `randf`/`pick_random`；heartbeat 既有 `_begin_observe/_end_observe` suppress 照舊 |
| **det×3 byte-identical 不變** | **`165399d135296899928d21bce66565ee` ×3 ＝ 與 main 完全相同** ✔ |
| 驗收 `grep -c convoy > 0` | ★**字面上的 `convoy` 仍是 0**——trace 內任務名是中文，對應字串是**「運輸」＝ 24 行**，另有 `convoy_phase` 欄（RETURN/OUTBOUND）。若你要字面 `convoy` 我可以把 `convoy_phase` 的 key 名保留、另加英文 task slug，但我認為現況已滿足「看得到 porter 的 motive→action→outcome」。**請裁**。 |

TDD `specimen_lineage_test.gd` **7/7 PASS**（含孫隊、無血緣他隊排除、環狀 parent 收斂、`enabled=false` 零成本）。

## R6 保鮮期
- **commit** `40915657`（branch `feat/specimen-lineage-scope`，基於 `origin/main` 3f196d44）／**日期** 2026-08-21
- **重跑**：
  ```powershell
  cd A:\GDS\demo\.worktrees\specimen-lineage-scope
  $env:GODOT_TIMEOUT='1200'; $env:PERF_SEED='1337'; $env:LW_CONFIG='peaceful_economy'; $env:ADHOC_DAYS='30'
  $env:SPECIMEN_TEAM_ID='5'; $env:SPECIMEN_OUT='docs/measurements/2026-08-21-lineage-check-peaceful.specimen.jsonl'
  .\tools\godot.ps1 --headless --script scripts/debug/convoy_return_conservation_bed.gd
  ```
- **樣本已落地**：`A:\GDS\demo\.worktrees\specimen-lineage-scope\docs\measurements\2026-08-21-lineage-check-peaceful.specimen.jsonl`（483 entries / 553,483 bytes，已 push）

## 備註
- 本 branch 內含一份 `convoy_return_conservation_bed.gd`（從 convoy branch 複製，內容相同）供本票自證可重跑；兩支 merge 不會衝突。
- measurer 要重產給 QA 時，記得**用含 convoy RETURN 那刀的 branch**跑，否則故事還是修前版本。
- 下一站：`failure-feedback` Phase 0（我已收到、狀態 open，等本票你點頭就開）。
