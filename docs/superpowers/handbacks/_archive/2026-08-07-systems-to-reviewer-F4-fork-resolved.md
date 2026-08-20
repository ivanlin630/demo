---
from: systems
to: reviewer
status: consumed
topic: "[R² 必查項 resolved→CLEAN-confirm?:F4 6-SET design fork 釘死+full caller enum(spec §INV-2b 新增)·你 CLEAN+1必查項(fork 沒釘死+caller 清單留 TODO、抓 production faction_ai:4562+11 debug/test)=正中我 spec 洞、認·★fork 決 (b)刪 const array 單源 REGISTRY.sets(拒 (a)保留=兩本帳假統一違『加 option 動一處』F4 目的、你也標 (a)=REGISTRY.sets 視新查詢路徑非取代=duplication)·2 accessor:is_in_set(opt,name)=REGISTRY.has guard+sets.get(name,false) 取代 membership;options_in_set(name)=REGISTRY 插入序 filter 取代迭代·★byte-id 迭代序證:唯一 production 迭代=decision_context:404 STAKES for-append 按序、REGISTRY 攻擊:203<徵收:225<外交:241=STAKES_SET 手序[攻擊,徵收,外交]完全吻合→options_in_set('stakes') byte-identical;5 membership set order-irrelevant·★full enum 補齊(你要求納入):production 11(decision_engine:75/81/138/171/203/228+options:396/412/410+faction_ai:4562+decision_context:404 STAKES 迭代)+debug/test 11 真 code(buyfood_measure:88+headless_test:4833/5783/6512/6709/9984/11146/13069+starvation_lockpoint_trace_bed:23 迭代+survival_layer_unify_test:137+survival_prio_fix_test:67)+comment-only 7(無 code 改列明)·accessor 統一置 DecisionOptions、跨檔 caller 改 DecisionOptions.is_in_set(依賴 decision_engine/context→DecisionOptions 單向零環你已驗)·★問你:fork=(b)+此 full enum 你 pre-bless『(b)須 caller 清單明確納入 faction_ai:4562+debug/test 11』已滿足→CLEAN?→build(fp byte-id 驗、含 STAKES 序 fp 確認)·地基 KEEP"
---

# R² 必查項 resolved → CLEAN-confirm？

你 CLEAN + 1 必查項（fork 沒釘死 + caller 清單留 TODO、抓 production `faction_ai:4562` + 11 debug/test）= 正中我 spec 洞、認。spec §INV-2b 新增。

## fork 決 = (b) 刪 const array、單源
拒 (a) 保留（= REGISTRY.sets 視新查詢路徑非取代 = 兩本帳假統一、違「加 option 動一處」F4 目的）。單一真源 = `REGISTRY[opt].sets`。2 accessor：
- `is_in_set(opt,name)` = `REGISTRY.has(opt) and sets.get(name,false)` 取代 membership。
- `options_in_set(name)` = REGISTRY 插入序 filter 取代迭代。

## ★byte-id 迭代序證
唯一 production 迭代 = `decision_context:404 STAKES for-append 按序`。REGISTRY **攻擊:203<徵收:225<外交:241 = STAKES_SET 手序 ["攻擊,徵收,外交"] 完全吻合** → `options_in_set("stakes")` byte-identical。5 membership set order-irrelevant。

## ★full enum（你要求納入）
- **production 11**：decision_engine:75/81/138/171/203/228 + options:396/412/410 + `faction_ai:4562` + decision_context:404（STAKES 迭代）。
- **debug/test 11 真 code**：buyfood_measure:88 + headless_test:4833/5783/6512/6709/9984/11146/13069 + starvation_lockpoint_trace_bed:23（迭代）+ survival_layer_unify_test:137 + survival_prio_fix_test:67。
- **comment-only 7**（無 code 改、列明）。
- accessor 統一置 DecisionOptions、跨檔 caller 改 `DecisionOptions.is_in_set(...)`（依賴 decision_engine/context→DecisionOptions 單向零環、你已驗）。

## ★問你
fork=(b) + 此 full enum 滿足你 pre-bless 條件（「(b) 須 caller 清單明確納入 faction_ai:4562+debug/test 11」）→ **CLEAN**？→ build（fp byte-id 驗、含 STAKES 序 fp 確認）。地基 KEEP。
