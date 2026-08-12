---
from: systems
to: implementer
status: open
topic: "[build:晉升→初始心情/忠誠(spec LOCKED 2026-08-12-promotion-initial-mood-loyalty-design.md、blueprint R①+R² CLEAN)·新 branch feat/promotion-initial-mood-loyalty 自 main HEAD·★systems grounding 驗證坐實(citations 對=team_data.gd:116 unrest_turns/:227 known_reputations/person_generator.gd:55-56 stress=0 fear=0 白紙、感知鐵律 OK 源訊號全 belief/own-state)·★★HOOK 位置命門:不可改通用 generate(person_generator.gd:53 generate 所有生成共用、改它污染全體)→在 _try_promote_advisor『state.add_member(team,new_named.id)』之後 hook 新 helper _apply_promotion_initial_state(state,team,new_named,fired_desperate)調整該 officer stress/fear/loyalty(promotion-specific、desperate 布林在此)·★★§HOW-binding:①初始忠誠=LoyaltyBank 重設 baseline(override generate 的 rng 0.5-1.0 預設)=提拔感激正底 + 源團態度調(團 unrest_turns 高→discontent carryover 低/known_reputations[領主] belief 若有 overlord 關係 + _benefactor_strength self-memory、mirror _faction_stay_benefit faction_ai:5125 pattern)+ 情境調(desperate) + 義氣/信義人格 modulate(mirror stay_benefit pmod)②初始心情=stress/fear 從 state 算取代白紙 0/0:提拔滿足=低 stress 正底 + 情境(fired_desperate→摻 stress/fear 非0[急徵火線]、fired_normal→冷靜低值)+ 源團艱困(team.unrest_turns 高→carryover stress)·★★§4.5 命門(同 iii/A+B bounded、machine-demonstrate):三調 bounded 非情境決定死值——怨團拔→低忠誠但★非 0(舊怨 vs 感激拉扯有翻轉空間)/絕境急徵→摻壓但★非崩潰/和平練成→冷靜但★非麻木;避免退化情境→硬設死值·★★genuine 非死常數(用戶命門):初始值從真 state 算(unrest/known_reputations/benefactor/desperate)、非 flat 白紙非 flat 常數;人格 weight 穿秤 OK(義氣/信義 modulate)但★禁硬設情境→死結果·★★determinism:純從 state 算、★禁新 randf(既有 generate 的 seeded rng 不動、調整層 deterministic 從 state=可重現+genuine)·③下游零新 plumbing:promoted officer loyalty 餵既有 defect_util(讀 officer 自己 loyalty→怨團拔個體日後真可能叛=賭注真實、確認接線非新機制)·★★驗收(spec §5、硬數據、realistic 非只 unit、6gap+committed-task 教訓):①★不同情況分化=幸福村(低 unrest+好 reputation)vs 怨團(高 unrest)/和平練成(fired_normal)vs 絕境急徵(fired_desperate)→初始 stress/fear/loyalty 明顯不同(machine-demonstrate 逐案印值)②★提拔感激→忠誠加成可測(提拔後 officer 對領主 loyalty > 中性基線)③bounded §4.5 machine-demonstrate(怨團非0/絕境非崩潰/和平非麻木)④怨團拔個體日後真叛(realistic 接 defect、賭注真實)⑤determinism/regression(active_promotion+named_scarcity_ab)/constitution(初始從 state 算無新死常數)·★行為變 slice=fp 分化 intended·完成 handback to:systems→merge-gate 硬讀(核 hook 非污染 generate+感知鐵律+§4.5 bounded+genuine 無死常數+無新 randf)→QA adversarial(spec §5 分化+感激加成+怨團日後叛+bounded)→merge→blueprint 推用戶·★收官必回 blueprint·地基 KEEP"
---

# build：晉升 → 初始心情/忠誠（spec LOCKED）

spec `docs/superpowers/specs/2026-08-12-promotion-initial-mood-loyalty-design.md`（blueprint R①+R² CLEAN）。新 branch `feat/promotion-initial-mood-loyalty` 自 main HEAD。

## ★systems grounding 驗證（坐實、citations 對）
- `team_data.gd:116 unrest_turns`（團自身 unrest=own-state）/ `:227 known_reputations`（belief 信任軸）/ `person_generator.gd:55-56 p.stress=0.0; p.fear=0.0`（白紙設點）。
- **感知鐵律 ✓**：源訊號全 belief/own-state（unrest own、known_reputations belief、desperate own context）、無 god-view。

## ★★HOOK 位置命門
**不可改通用 `generate`**（`person_generator.gd:53` 所有生成共用、改它污染全體）→ 在 `_try_promote_advisor` 的 `state.add_member(team, new_named.id)` **之後** hook 新 helper `_apply_promotion_initial_state(state, team, new_named, fired_desperate)` 調整該 officer stress/fear/loyalty（promotion-specific、desperate 布林在此可用）。

## ★★§HOW-binding
1. **初始忠誠** = `LoyaltyBank` 重設 baseline（override `generate` 的 rng 0.5-1.0 預設）= 提拔感激正底 + 源團態度調（`team.unrest_turns` 高→discontent carryover 低 / `known_reputations[領主]` belief 若有 overlord 關係 + `_benefactor_strength` self-memory、**mirror `_faction_stay_benefit`（faction_ai:5125）pattern**）+ 情境調（desperate）+ 義氣/信義人格 modulate（mirror stay_benefit pmod）。
2. **初始心情** = stress/fear 從 state 算取代白紙 0/0：提拔滿足=低 stress 正底 + 情境（`fired_desperate`→摻 stress/fear 非0[急徵火線]、`fired_normal`→冷靜低值）+ 源團艱困（`team.unrest_turns` 高→carryover stress）。

## ★★§4.5 命門（同 iii/A+B bounded、machine-demonstrate）
三調 bounded 非情境決定死值——怨團拔→低忠誠但★**非 0**（舊怨 vs 感激拉扯有翻轉空間）/ 絕境急徵→摻壓但★**非崩潰** / 和平練成→冷靜但★**非麻木**；避免退化情境→硬設死值。

## ★★genuine + determinism（用戶命門）
- **genuine 非死常數**：初始值從真 state 算（unrest/known_reputations/benefactor/desperate）、非 flat 白紙非 flat 常數；人格 weight 穿秤 OK（義氣/信義）但★禁硬設情境→死結果。
- **determinism**：純從 state 算、★**禁新 randf**（既有 generate seeded rng 不動、調整層 deterministic 從 state=可重現+genuine）。

## ③ 下游零新 plumbing
promoted officer loyalty 餵**既有 `defect_util`**（讀 officer 自己 loyalty→怨團拔個體日後真可能叛=賭注真實）、確認接線非新機制。

## ★★驗收（spec §5、硬數據、realistic 非只 unit、6gap+committed-task 教訓）
1. ★**不同情況分化** = 幸福村（低 unrest+好 reputation）vs 怨團（高 unrest）/ 和平練成（fired_normal）vs 絕境急徵（fired_desperate）→ 初始 stress/fear/loyalty 明顯不同（machine-demonstrate 逐案印值）。
2. ★**提拔感激→忠誠加成可測**（提拔後 officer 對領主 loyalty > 中性基線）。
3. **bounded §4.5 machine-demonstrate**（怨團非0 / 絕境非崩潰 / 和平非麻木）。
4. **怨團拔個體日後真叛**（realistic 接 defect、賭注真實）。
5. determinism/regression（active_promotion + named_scarcity_ab）/ constitution（初始從 state 算無新死常數）。
★行為變 slice = fp 分化 intended。

## 序
完成 handback `to:systems` → merge-gate 硬讀（核 hook 非污染 generate + 感知鐵律 + §4.5 bounded + genuine 無死常數 + 無新 randf）→ QA adversarial（spec §5 分化+感激加成+怨團日後叛+bounded）→ merge → blueprint 推用戶。地基 KEEP。
