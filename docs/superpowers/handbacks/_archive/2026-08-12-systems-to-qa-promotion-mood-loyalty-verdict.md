---
from: systems
to: qa
status: consumed
topic: "[QA adversarial release verify:晉升→初始心情/忠誠(spec 2026-08-12-promotion-initial-mood-loyalty)·feat/promotion-initial-mood-loyalty 71609428(含 HALT fix 上疊)·★systems merge-gate 兩輪:首輪坐實 heard_rep 惰性(known_reputations team-id keyed 用 person-id 查恆 miss+own-team 無自 reputation 拓撲)→halt→implementer fix A 移 rep 項→re-merge-gate CLEAN(rep_bonus+REP_W 零殘留、忠誠=clampf(感激×義氣信義 pmod − unrest − 急徵拖, floor0.2, 1.0)honest 3-signal、_faction_stay_benefit 原正確 heard_rep 未動、hook 非污染 generate、感知鐵律全 own-state[unrest own+desperate context+officer 自 values]無 god-view、無新 randf、§4.5 floor0.2/cap0.8/0.7/base0.1)·★請 QA adversarial(讀 specimen+親算、6gap+committed-task 教訓):①★不同情況分化=幸福村(低 unrest)loy 0.5 gratitude-only vs 怨團(高 unrest)floor 0.2 / 和平 fired_normal stress 低 vs 絕境 fired_desperate stress 高摻 fear→初始 stress/fear/loyalty 明顯不同(machine-demonstrate 逐案親算對否)②★提拔感激→忠誠加成(提拔後 loy > 中性、高義氣 0.7 pmod>中性 0.5)③§4.5 bounded(怨團非0=floor0.2/絕境非崩潰≤cap/和平非麻木>0)④怨團拔個體日後真叛(realistic 接 _avg_named_loyalty→_evaluate_uprising:5075)⑤determinism 3-run byte-identical/active_promotion+named_scarcity_ab regression/constitution 75·★fp init_loyalty_peak 0→0.415(state-derived 含 unrest carryover 故<0.5、非白紙)·★test 盲點已補:②改 relative(幸福>怨團 floor+人格 modulate)非絕對·CLEAN→systems merge(stale-base 先 merge main→branch)→blueprint 推用戶;有洞→halt·地基 KEEP"
---

# QA adversarial release verify：晉升→初始心情/忠誠

`feat/promotion-initial-mood-loyalty` `71609428`（含 HALT fix 上疊）。

## ★systems merge-gate 兩輪
首輪坐實 **heard_rep 惰性**（known_reputations team-id keyed 用 person-id 查恆 miss + own-team 無自 reputation 拓撲）→ halt → implementer fix A 移 rep 項 → **re-merge-gate CLEAN**：
- rep_bonus + REP_W **零殘留**、忠誠 = `clampf(感激×義氣信義 pmod − unrest − 急徵拖, floor0.2, 1.0)` honest 3-signal。
- `_faction_stay_benefit` 原**正確** heard_rep 未動（member 隊/外部 overlord/lord_id=team_id）。
- hook 非污染 `generate` / 感知鐵律全 own-state（unrest own + desperate context + officer 自 values）無 god-view / 無新 randf / §4.5 floor0.2·cap0.8/0.7·base0.1。

## ★請 QA adversarial（讀 specimen + 親算、6gap + committed-task 教訓）
1. ★**不同情況分化** = 幸福村（低 unrest）loy 0.5 gratitude-only vs 怨團（高 unrest）floor 0.2 / 和平 fired_normal stress 低 vs 絕境 fired_desperate stress 高摻 fear → 初始 stress/fear/loyalty 明顯不同（machine-demonstrate 逐案親算對否）。
2. ★**提拔感激→忠誠加成**（提拔後 loy > 中性、高義氣 0.7 pmod > 中性 0.5）。
3. **§4.5 bounded**（怨團非0=floor0.2 / 絕境非崩潰≤cap / 和平非麻木>0）。
4. **怨團拔個體日後真叛**（realistic 接 `_avg_named_loyalty`→`_evaluate_uprising:5075`）。
5. determinism 3-run byte-identical / active_promotion + named_scarcity_ab regression / constitution 75。
- ★fp init_loyalty_peak 0→0.415（state-derived 含 unrest carryover 故<0.5、非白紙）。test 盲點已補：② 改 relative（幸福>怨團 floor + 人格 modulate）非絕對。

CLEAN → systems merge（stale-base 先 merge main→branch）→ blueprint 推用戶；有洞 → halt。地基 KEEP。
