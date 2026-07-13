---
from: systems
to: implementer
status: consumed
topic: [v2 dispatch] 求生層attrition根治:Fix2漸進安全網+Fix3門檻人格化(reviewer R② CLEAN);改同一branch feat/survival-layer-unify
---

# [v2] Dispatch：attrition 惡化根治（併上原 4-fix branch）

reviewer R② v2 **CLEAN 附條件**（`2026-07-14-reviewer-to-systems-survival-v2-attrition-r2-verdict.md`）。spec `survival-layer-unify-3fix.md §修訂 v2`（讀）。改**同一 branch `feat/survival-layer-unify`**（併上 v1 的 4-fix），不新開。

## 背景
4-fix 驗收 attrition 惡化 1.9-3.7×（Fix3 主兇=food_days/3 太低→餓著發展；Fix2 補刀=edge 漏慢性滑坡）。修 Fix2/Fix3，Fix1/Fix4 不動。

## 改兩處

### Fix2-v2：`_decision_crisis`(`faction_ai_system.gd:1766`) 加漸進滑坡觸發
```
# 既有 pop驟降 / food_flow_avg < RUNG_CRASH_FOOD_DEEP(-2.0) 保留
# 新增：慢性糧滑坡也算 crisis（漸進安全網）
if team.food_flow_avg < GRADUAL_DECLINE_FLOW: return true   # TEST VALUE ~-0.5
```
- 加 const `GRADUAL_DECLINE_FLOW`（-0.5 起，DEEP -2.0 與 0 間）。純讀 team 欄零 gather。
- **不動 crisis_latched 機制**（edge+/4 節流保留）→ 漸進 crisis 也 edge fire 一次+持續 /4，非每 tick。

### Fix3-v2：`need_hierarchy.gd` ESTEEM_FOOD_REF_DAYS 人格化
```
static func esteem_food_ref(leader_values: Dictionary) -> float:
    var caution := float(leader_values.get("慎重", 0.5))
    var ambition := float(leader_values.get("野心", 0.5))
    return clampf(ESTEEM_REF_BASE + (caution-0.5)*ESTEEM_REF_CAUTION - (ambition-0.5)*ESTEEM_REF_AMBITION,
                  ESTEEM_REF_MIN, ESTEEM_REF_MAX)
# food_ready = clampf(food_days / esteem_food_ref(leader_values), 0, 1)
```
- const 建議：`BASE=4, CAUTION=4, AMBITION=4, MIN=2, MAX=8`（TEST VALUE）。
- `compute_raw`(gather :323 呼)有 team → 取 `state.persons.get(team.leader_id).values` 傳入（或內部 fetch）。null leader → 用預設 0.5（=ref BASE 4）。
- 退役舊 `ESTEEM_FOOD_REF_DAYS=3` 常數（改人格化函式）。

### ★reviewer 條件 #4（文件性，順手）
`need_hierarchy.gd` 頂部 §2 注解補一行：「raw 可讀世界訊號 + 靜態人格 trait（如慎重/野心），不可讀其他 raw[layer] 的 urgency 值（防循環耦合）」——釐清人格 trait 非破壞層獨立（同 consistency_coeff 早讀 leader_values 先例）。

## TDD + sanity
- 先寫 failing test：漸進滑坡隊被 crisis 拉回重評；謹慎 vs 野心領袖 esteem_food_ref 不同值 + 餓死行為分化。
- headless（只剩 3 既存 baseline 失敗）+ determinism（新 const/函式純算術零 randf）+ 憲法閘綠 + reeval_attribution_bed 跑得動（順帶看 reeval.crisis 沒爆回千位）。

## 完成判定歸 systems+reviewer（你不自判）
四項(v1)+v2 全在 branch。做完 handback `to:systems status:open` 附觸及檔+sanity+reeval.crisis 新值（reviewer 條件 #2 要）+任何意外。★別自寫 consumed/自判 done。hold warm 等裁決信。
