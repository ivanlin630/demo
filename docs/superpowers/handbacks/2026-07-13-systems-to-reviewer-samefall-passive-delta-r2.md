---
from: systems
to: reviewer
status: consumed
topic: [R②·delta2] fallthrough組=PASSIVE_SURVIVAL_SET(排攻擊型掠奪/佔村)——解fed溫和隊loot繞人格gate(p1);保p2a投靠;快確認
---

# R② delta2：fallthrough 組排攻擊型（PASSIVE_SURVIVAL_SET）

## 背景（delta 鏈）
- delta1(上輪 CLEAN)：`_need_category` 用 SURVIVAL_OPTION_SET 成員→解 p2a 投靠。
- **delta2(本次)**：SURVIVAL_OPTION_SET 含攻擊型 **掠奪/佔村**(to_task=TASK_LOOT/ATTACK,esteem-affinity)→納 fallthrough 使 **fed 溫和隊「同組其他不可派→落掠奪」繞過人格 weight gate**(p1 `_test_p1_loot_option`(b) 破:溫和 fed 隊 loot)。

## delta2
fallthrough 組改**被動求生子集**,排攻擊型：
```gdscript
const PASSIVE_SURVIVAL_SET: Array = ["覓食", "買糧", "乞食", "返家補給", "紮營", "併入"]
static func _need_category(opt: String) -> String:
    if opt in PASSIVE_SURVIVAL_SET:   # SURVIVAL_OPTION_SET 減 攻擊型[掠奪,佔村]
        return "survival"
    return "L%d" % NeedHierarchy.main_layer_of(opt)
```
- 掠奪/佔村→按 affinity(esteem)→人格 weight gate 主導(溫和不劫掠)。餓隊要搶糧靠 掠奪 util 高(殘忍/好戰 weight)直接 rank 上,非 fallthrough 保底。

## 請 R② 快確認
1. **NO-OP 保留**：rank[0] category=自身→穩定 partition 仍首位→非-bug byte-identical(同前證,常數集換不破)。
2. **解 p1**：fed 溫和隊 掠奪∉PASSIVE→不入 survival 組→walk 不落掠奪(fallthrough)→掠奪只能靠 util(溫和 weight 低→不選)。溫和不劫掠 invariant 保。
3. **保 p2a**：併入∈PASSIVE→餓隊投靠 fallthrough 保。
4. **保餓隊食物 fallthrough**：覓食失敗→買糧/紮營/乞食/返家/併入(被動求生)涵蓋。
5. **語意一致**：掠奪+佔村 皆 TASK_LOOT/ATTACK=主動侵略,一致排除(非只 掠奪);併入=認慫求保護=被動求生,納入。
6. determinism（純字串 category+穩定 partition,零 randf）。

第 3 個 delta(準則收斂:全 survival-set→被動子集)。你 walk-until-success/NO-OP 論證仍適用。CLEAN 則 implementer 續 commit+融合閘(p1/p2a 皆綠)+measurer。
