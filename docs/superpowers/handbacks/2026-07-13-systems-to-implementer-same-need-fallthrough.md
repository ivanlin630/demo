---
from: systems
to: implementer
status: open
topic: [dispatch·同需求fallthrough] rank[0]不可dispatch→同need層優先(裁A)——R②CLEAN;解餓隊覓食失敗落生產
---

# Dispatch：dispatch 同需求 fallthrough（裁 A）

R②CLEAN(`same-need-fallthrough-r2-verdict`,NO-OP 演算法結構證明+conquest/threat walk-until-success 確認)。spec `docs/superpowers/specs/2026-07-13-dispatch-same-need-fallthrough.md`。**新 branch `feat/same-need-fallthrough`,基於最新 origin/main**（含 survival-path merged）。

## 做什麼（小範圍，只改 dispatch 迭代序）
1. **`DecisionEngine` 加 `reorder_same_need_first(ranked)`**（spec 有完整 code）：same main-need-layer(=rank[0]層,`NeedHierarchy.main_layer_of`)在前、其餘在後,各組保 util 序。純函式零 randf。
2. **接兩 dispatch loop**（rank_scored 後、loop 前，同加一行）：
   - `faction_ai_system.gd _decide_unified`：`ranked = rank_scored(...)` 後 → `ranked = DecisionEngine.reorder_same_need_first(ranked)`。
   - `faction_ai_system.gd _evaluate_solo`：同加一行。
   - **loop body 不動**（conquest 征服 scout-verify/threat aux wiring 原樣）。

## 硬約束
- **NO-OP 保證**：rank[0] dispatchable 時重排後 rank[0] 仍首試（穩定 partition，R② 證）→行為 byte-identical。
- 零 randf、determinism。純迭代序改，不動 rank_scored/util/coeff。

## TDD `_test_reorder_same_need`
- `[覓食(surv),生產(esteem),買糧(surv)]`→reorder→`[覓食,買糧,生產]`。
- rank[0] 與後續全同層→順序不變(NO-OP)。單/空→原樣。

## 回報 → measurer 終驗
完 + 融合閘綠 → handback to:measurer：
- **★餓隊覓食失敗→試買糧/乞食/返家/紮營**（非落生產）：Team7 式重跑,覓食 undispatchable 時 winner=食物類替代非生產。
- **rank[0] dispatchable 不回歸**：既有 dispatch byte-identical（determinism）。
- **掠奪/併入 排除殘留**：餓隊是否仍有落非食物殘案（若顯需納 掠奪/併入 回報,擴 spec）。
- 融合閘/TC2/consolidation/combat/9-zero 分布不回歸。
有 blocker→to:systems。守：不 pre-tune、不問 user。
