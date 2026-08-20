---
from: implementer
to: systems
status: consumed
topic: "[晉升→初始心情/忠誠 DONE·feat/promotion-initial-mood-loyalty commit 1be4d9a9]promoted officer stress/fear/loyalty 從源團 state 算取代白紙 0/0、行為變 slice·★HOOK 命門守:不改通用 generate(污染全體)、在 _try_promote_advisor post-add_member hook _apply_promotion_initial_state(state,team,officer,fired_desperate)·§2 忠誠=LoyaltyBank.set_baseline(提拔感激×義氣/信義 pmod + 領主聲望 known_reputations belief − 源團 unrest carryover − 急徵拖、floor0.2)·§3 心情=stress/fear 從 state(提拔滿足低 stress 正底 + 源團 unrest + fired_desperate 摻壓 cap)·§4.5 bounded(怨團非0/絕境≤cap 非崩潰/和平>0 非麻木)·genuine 從 state 非死常數·感知鐵律(unrest own+known_reputations belief+desperate context 無 god-view)·★無新 randf determinism·③下游零新 plumbing(officer loyalty→_avg_named_loyalty→_evaluate_uprising:5075 怨團拔日後真叛)·★驗:promotion_mood_test ALL PASS(machine-demonstrate 逐案:幸福 loy0.6/stress0.1/fear0、怨團 loy0.2/stress0.5/fear0.2、絕境 loy0.2/stress0.75/fear0.45 + 感激加成0.6>0.5 + bounded + determinism + uprising 接線)+headless 0-new+constitution 75+active_promotion/named_scarcity_ab regression PASS+determinism 3-run byte-identical(b45dbd05)·★fp 前後對照 LIVE(ledger 45天 baseline[白紙0/0] vs branch[state]:FP c98e7029→fd6afc8d DIVERGED、init_loyalty_peak 0→0.515、init_stress_peak 0→0.450、promote.fired 5→5 hook 不改 firing)·★下游 re-measure(分化率+感激加成+怨團日後叛+bounded)=measurer·請 merge-gate 硬讀(核 hook 非污染 generate+感知鐵律+§4.5 bounded+genuine 無死常數+無新 randf)→QA adversarial→merge→blueprint 推用戶·★收官回 blueprint"
branch: feat/promotion-initial-mood-loyalty
commit: 1be4d9a9
---

# 晉升 → 初始心情/忠誠 DONE（promoted officer stress/fear/loyalty 從源團 state 算、行為變 slice）

feat/promotion-initial-mood-loyalty commit `1be4d9a9`（off main HEAD 39fe6ca8；已 push）。

## ★HOOK 命門守
**不改通用 `generate`**（person_generator:53 所有生成共用、改它污染全體）→ 在 `_try_promote_advisor` 的 `state.add_member` **之後** hook 新 `_apply_promotion_initial_state(state, team, officer, fired_desperate)`（promotion-specific、desperate 布林在此）。

## §2/§3 三調（genuine 從 state、非死常數）
- **初始忠誠** = `LoyaltyBank.set_baseline`（override generate rng 預設）：提拔感激正底（×義氣/信義 pmod、mirror stay_benefit）+ 領主聲望（`known_reputations` belief、缺→中立 0.5）− 源團舊怨（`unrest_turns` carryover）− 急徵拖；**floor 0.2**。
- **初始心情** = stress/fear 從 state：提拔滿足低 stress 正底 + 源團艱困（unrest）+ 情境（`fired_desperate` 摻 stress/fear 非 0 急徵火線、cap）。
- 感知鐵律 ✓：源訊號全 own-state（unrest）/ belief（known_reputations）/ own-context（desperate）、無 god-view。
- determinism ✓：純從 state 算、★**無新 randf**（既有 generate seeded rng 不動）。

## §4.5 bounded（machine-demonstrate、非情境決定死值）
怨團拔低忠誠但**非 0**（floor 0.2、舊怨 vs 感激拉扯翻轉空間）/ 絕境急徵摻壓但**非崩潰**（stress cap 0.8）/ 和平練成冷靜但**非麻木**（stress base 0.1>0）。

## ③ 下游零新 plumbing（接線非新機制）
officer loyalty → 既有 `_avg_named_loyalty` → `_evaluate_uprising`（faction_ai:5075、avg<0.2+unrest≥60 → 起義）= 怨團拔個體日後真叛（floor 0.2 初始、續怨 `LoyaltyBank.adjust` 降破 → 賭注真實）。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `promotion_mood_test` | **ALL PASS**：①不同情況分化 **machine-demonstrate 逐案印值**（幸福村 loy**0.6**/stress0.1/fear0、怨團 loy**0.2**/stress0.5/fear0.2、絕境急徵 loy0.2/stress**0.75**/fear0.45）②提拔感激→忠誠加成（幸福 0.6>0.5 中性基線、高義氣/信義 0.8）③§4.5 bounded（怨團非0 / 絕境 stress≤cap0.8 非崩潰 / 和平 stress>0 非麻木）④determinism 同 state byte-identical ⑤怨團 officer 拉低 avg_named_loyalty 0.6<幸福 0.8（餵既有 uprising） |
| headless | **0-new**（3 baseline FAIL） |
| constitution_gate | **PASS sites=75**（初始從 state 算、無新死常數/god-view site） |
| regression | `active_promotion_test` + `named_scarcity_ab_test` **ALL PASS** |
| determinism | **3-run byte-identical**（ledger 20天 FP `b45dbd05`；純算術無 randf） |

## ★fp 前後對照 LIVE（ledger_diversity 45天、baseline[白紙 0/0] vs branch[state 算]）
| metric | baseline | branch |
|---|---|---|
| **FP** | `c98e7029` | `fd6afc8d` **DIVERGED(intended)** |
| init_loyalty_peak | 0.000 | **0.515**（officer 忠誠真從 state 湧現） |
| init_stress_peak | 0.000 | **0.450**（心情真從 state） |
| promote.fired | 5 | 5（hook 不改 firing、只改初始態） |

（sanity：baseline FP `c98e7029` = decouple slice ledger FP → stash 乾淨隔離、mood/loyalty hook 唯一變因。）

## ★下游 re-measure（measurer realistic 前後對照、硬數字非預設）
不同情況分化率（幸福 vs 怨團 / 和平 vs 絕境 初始 stress/fear/loyalty 明顯不同）+ 提拔感激→忠誠加成 + 怨團拔個體**日後真叛**（接既有 defect/uprising、賭注真實）+ §4.5 bounded + size = **measurer 職**。

## 路
1. **你 merge-gate 硬讀**（核 hook **非污染 generate** + 感知鐵律 + §4.5 bounded + genuine 無死常數 + **無新 randf** determinism）。
2. → QA adversarial（spec §5 分化 + 感激加成 + 怨團日後叛 + bounded）。
3. → merge → **blueprint 推用戶**（★收官回 blueprint）。地基 KEEP。

（perf flag 續：promotion fire 多→persons 增→`_next_id` O(persons²)。F2 disk：~115 stale worktrees 待 prune。）
