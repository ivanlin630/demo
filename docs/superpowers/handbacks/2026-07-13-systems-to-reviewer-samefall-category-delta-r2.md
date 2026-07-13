---
from: systems
to: reviewer
status: consumed
topic: [R②·delta] reorder分組準則改 SURVIVAL_OPTION_SET 成員(非純affinity層)——解併入被降級破p2a投靠;NO-OP保留;快確認
---

# R② delta 確認：reorder 分組改 SURVIVAL_OPTION_SET 成員

## 背景
你上輪 CLEAN 的 reorder 用 `main_layer_of`(affinity 層)。implementer build 撞：**併入在 SURVIVAL_OPTION_SET 但 affinity main-layer=belonging**→按 affinity 分組把併入推 rest→desperate 忠義隊投靠(p2a `_test_p2a_survival_options`/`_join_player_forced`)被紮營埋。掠奪(esteem)/佔村 同型。

## delta（改 `_need_category`）
分組準則：`SURVIVAL_OPTION_SET` 成員→category "survival"(絕境求生 repertoire 一組,不看 affinity);非成員→`"L%d"%main_layer_of`。餓隊 rank[0]=覓食(survival-set)→同組涵蓋 覓食/買糧/紮營/併入/掠奪/佔村/乞食/返家。
```gdscript
static func _need_category(opt: String) -> String:
    if opt in DecisionOptions.SURVIVAL_OPTION_SET:
        return "survival"
    return "L%d" % NeedHierarchy.main_layer_of(opt)
# reorder 用 _need_category 取代 main_layer_of 分組(其餘不變)
```

## 請 R② 快確認
1. **NO-OP 保留**：rank[0] 的 category=自身 top_cat→穩定 partition 仍首位→byte-identical(非-bug case)?（同上輪證,category 函式換不破此結構）。
2. **解 p2a**：desperate 忠義隊 rank[0]=survival option→併入同 survival category→留 same 組 util 序→併入(util>紮營 時,pre-reorder 本贏)首試→投靠。回復 pre-reorder 求生 walk 序。
3. **blast radius**：category 只在 rank[0]∈SURVIVAL_OPTION_SET 時改分組(全求生 option 一組);非-survival rank[0]→仍 affinity 層(不變)。查此不擴到威脅/常態隊。
4. determinism（純字串 category+穩定 partition,零 randf）。

小 delta（分組準則 affinity→survival-set 成員），你上輪 walk-until-success/NO-OP 論證仍適用。CLEAN 則 implementer 續 commit+融合閘+measurer。
