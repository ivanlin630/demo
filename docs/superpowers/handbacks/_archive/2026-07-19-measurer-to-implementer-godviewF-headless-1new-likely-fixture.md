---
from: measurer
to: implementer
status: consumed
topic: "[godview-F headless 1新增·極可能同款test-fixture gap] 20d4ce97 comprehensive比對(雙格式)：7個失敗vs baseline 6個,多1個NEW『慎重者矛盾情報→派斥候查證』(headless_test.gd:1013,pre-existing測試非本branch新加)。code追蹤：測試用BeliefSystem.record_claim(...,{population_est:...},...)兩次設矛盾情報但★從沒帶tile_pos欄位→best_estimate().get(tile_pos,sentinel)必回(-1,-1)→F1新guard(scout_pos==(-1,-1)→return false不scout)擋掉→斷言期待TASK_SCOUT失敗。跟你上輪slice2 invite測試漏belief同一種test-fixture gap(測試以前靠live fallback矇過,F1拿掉fallback後曝光)。已暫停organic sim待你確認+補fixture(record_claim加tile_pos欄位)。"
---

# godview-F headless 1 新增（極可能同款 test-fixture gap）

依 `2026-07-19-implementer-to-measurer-godview-F-done.md`（branch `20d4ce97`）。

## 快閘

- char bed `godview_f_test.gd`：**5/5 ALL PASS**。
- `constitution_gate`：PASS(sites=64, removed=0)。
- headless：comprehensive 雙格式（`[FAIL]`+`Assertion failed`）比對——**7 個失敗，vs true baseline 6 個，多 1 個 NEW**。

## 新增：`慎重者矛盾情報→派斥候查證`（`headless_test.gd:1013`，pre-existing 測試）

```
SCRIPT ERROR: Assertion failed: 慎重者矛盾情報→派斥候查證，實際 target=-1 task=idle
```

確認此測試非本 branch 新加（`git log -- headless_test.gd` 最後touch是 `a5495461`，早於 godview-F）。

## code 追蹤：極可能是同款 test-fixture gap

測試（`_test_faction_attack_gate`，1004-1013 行）：
```gdscript
BeliefSystem.record_claim(st_a, 0, 1, 0, "親見", {"population_est": 50}, 1.0, false)
BeliefSystem.record_claim(st_a, 0, 1, 9, "流民", {"population_est": 200}, 0.4, true)
FactionAISystem.new()._commit_conquest_attack(st_a, tm_a, 1)
assert(tm_a.prosperity_target_id == 1 and tm_a.current_task == TeamData.TASK_SCOUT, ...)
```

兩次 `record_claim` 的 `fields` 字典**只帶 `population_est`，從沒帶 `tile_pos`**。查 `faction_ai_system.gd:314`（你這輪 F1 加的）：

```gdscript
var scout_pos: Vector2i = BeliefSystem.best_estimate(state, team.team_id, prey_id).get("tile_pos", Vector2i(-1, -1)) if prey_t else Vector2i(-1, -1)
if scout_pos == Vector2i(-1, -1):
    return false   # 無 belief 位 → 不 scout（不瞎追 live）
```

`best_estimate()` 從 claims 的 `value` 字典找 `tile_pos`——兩個 claim 都沒這欄，必回 sentinel `(-1,-1)`，F1 新 guard 擋下 → `_commit_conquest_attack` 回 false → task 停 idle → 斷言失敗。

**這跟你上輪 slice2-perception 的 3 個 invite 測試同一種問題**：測試以前靠 god-view live-fallback 矇過（沒明確設 belief 位置也能過），F1 拿掉那個 fallback 後曝光——**測試 fixture 本身缺 `tile_pos`，不像是真行為 regression**，但我沒有代替你判定/修改測試（照量測員邊界：不改 production code/測試），需你確認 + 補（比照上輪，`record_claim` 的 `fields` 加 `"tile_pos": <某座標>`）。

## 暫停 organic sim

同上輪處理方式：先確認這是否為 test-fixture gap，避免若判斷有誤還要重跑 8 個月×3seed。

---
measured_at_head: `20d4ce97`（`.worktrees/godview-F`）
raw_logs: `docs/measurements/2026-07-19-godviewF-charbed-20d4ce97.log`、`...-constitution-20d4ce97.log`、`...-headless-20d4ce97.log`
對照 baseline: 真 baseline（a5495461 comprehensive，6 個：`[FAIL]`×3 + assert×3）
