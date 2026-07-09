---
from: implementer
to: measurer
status: consumed
topic: A2c1 consolidate 折入引擎（FA5）— 驗證完成，交量測
---

## 做了啥

commit b689df2 已含完整實作（前 session 做的，此輪確認+驗證，無新改動）：

- `decision_context.gd`：+`consolidate_target_id:int=-1`，gather 內算
- `faction_ai_system.gd`：+static `consolidate_target_of`（抽 `_try_consolidate_merge` 兩支邏輯，逐條件等價）；拆 `_assign_member_tasks` consolidate pre-gate；刪 `_try_consolidate_merge`（無他 caller）
- `terms.gd`：+`CONSOLIDATE_DRIVE` const + `consolidate_drive` term（flat 高量級，保現行 fire 恆勝）
- `options.gd`：+「整併」option（applicable + to_task）
- `constitution_baseline.txt`：移除舊 pre-gate try_set 指紋
- `scripts/debug/a2c1_consolidate_bed.gd`：新 TDD bed，15 case

## 驗了啥

1. `--headless --import`：乾淨（僅 cursor/blend 無關 warning）
2. `a2c1_consolidate_bed.gd`：15/15 PASS，fail_count=0
3. `constitution_gate.gd`：PASS（sites=29, removed=0）— 憲法閘契約守住
4. `headless_test.gd`（全量回歸）：跑到 `_test_strategic_reads_ladder` 斷言失敗
   → **已查證此失敗於 A2c1 前（parent commit 8fb3bb0）同樣重現**（起 `/tmp` worktree
   checkout 8fb3bb0 單獨跑同一測試，同一行、同一斷言失敗）。**與本 slice 無關，pre-existing**。
   建議 known_issues 記一筆或另案查（非本輪 scope，未動 `_decide_unified`/rank/expand 邏輯）。

## 殘留疑點

- `_test_strategic_reads_ladder`（headless_test.gd:13775）pre-existing 失敗，需另案根因（非 consolidate 相關 term/option 未動到 expand 路徑，本輪已排除嫌疑）。
- scope.json touch_files 全數命中，無 scope 外改動。no_touch 清單（_decide_unified/survival/threat term/interaction 消費端/三常數/leader路/子隊路）均未碰。
