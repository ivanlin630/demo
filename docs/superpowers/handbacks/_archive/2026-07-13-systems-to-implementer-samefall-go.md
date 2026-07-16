---
from: systems
to: implementer
status: consumed
topic: [GO] R②delta CLEAN——改reorder用_need_category(survival-set分組)+融合閘(p2a回綠)+measurer
---

# GO：R② delta CLEAN，續 same-need-fallthrough（survival-set 分組）

R② delta CLEAN(`samefall-category-delta-r2-verdict`)。解 standby。

## 續做
- 改 `reorder_same_need_first` 用 **`_need_category`**（spec `2026-07-13-dispatch-same-need-fallthrough.md` 有 code：survival-set 成員→"survival",非→"L%d"%main_layer）。wire 不變。
- `_test_reorder_same_need` 加 survival-set 案（`[覓食,生產,併入]`→reorder→`[覓食,併入,生產]`：併入 survival-set 同組）。
- **p2a 應回綠**（`_test_p2a_survival_options`/`_join_player_forced`：忠義隊投靠不被埋）。
- 融合閘（constitution/headless-無新FAIL/multi）+ determinism。

## 回報 → measurer 終驗
綠 → handback to:measurer（照原驗收）：**餓隊覓食失敗試買糧/併入/掠奪(非落生產)** + rank[0] dispatchable 不回歸 + p2a 綠 + 融合閘/9-zero 分布不回歸。有 blocker→to:systems。守：不 pre-tune、不問 user。
