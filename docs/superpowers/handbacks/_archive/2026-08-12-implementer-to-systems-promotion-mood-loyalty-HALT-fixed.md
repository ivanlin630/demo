---
from: implementer
to: systems
status: consumed
topic: "[HALT fix DONE·feat/promotion-initial-mood-loyalty 上疊 commit 71609428]移除 heard_rep 惰性項(偽 state-derived、你坐實正確)·接受 fix A:heard_rep=known_reputations.get(team.leader_id) 恆惰性 0.5(①TEAM-id keyed vs PERSON id 型別 mismatch 恆 miss ②own-team 領主無自 reputation entry 拓撲 mismatch)→rep_bonus 0.1 惰性常數違 genuine 命門→移除 rep_bonus 項+PROMOTE_LOY_REP_W const、忠誠=感激−unrest−急徵(honest 3-signal、源團態度 unrest 完整捕捉)·★驗:promotion_mood_test ALL PASS(②更新:幸福 loy 0.5 gratitude-only 顯著>怨團 floor 0.2、高義氣 0.7>中性 0.5 人格 modulate;①分化③bounded④determinism⑤uprising 接線保持)+headless 0-new+constitution 75+active_promotion/named_scarcity_ab regression PASS+determinism 3-run byte-identical(2cbd13dc)·★fp 前後對照 LIVE(ledger 45天 baseline[白紙0/0] vs branch:FP c98e7029→a3863d99 DIVERGED、init_loyalty_peak 0→0.415[state-derived 含 unrest carryover 故<0.5]、init_stress 0→0.450、promote.fired 5→5)·test 盲點補:②改 relative(幸福>怨團 floor+人格 modulate)非絕對 0.5、rep 惰性根除·請 merge-gate re-硬讀(核 rep 項已移、忠誠 3-signal 全 genuine work[unrest+desperate+人格]、無死常數殘留)→QA→merge→blueprint 推用戶"
branch: feat/promotion-initial-mood-loyalty
commit: 71609428
---

# HALT fix DONE：移除 heard_rep 惰性項（偽 state-derived、systems 坐實正確）

feat/promotion-initial-mood-loyalty 上疊 commit `71609428`（前 `1be4d9a9`；已 push）。

## ★接受你的坐實（正確、file:line 驗證）
`heard_rep = team.known_reputations.get(team.leader_id, 0.5)` 恆惰性 0.5：
1. **型別 mismatch**：`known_reputations` TEAM-id keyed（faction_ai:3018/:4944/:4977/:5138 + team_data:244 `update_reputation` 全 team_id）、我用 `team.leader_id`=PERSON id → 恆 miss → 0.5（person_id 撞 team_id key 更是讀錯隊 latent bug）。
2. **拓撲 mismatch**：officer_need 只 leader-team 非零 → promote team = faction 領主隊自己、隊不存自己領主的 known_reputations（那是對外隊 belief）→ 即使 keying 對也無此 entry。
∴ `rep_bonus = 0.1 惰性常數` = 偽 state-derived、違 genuine 命門（同族「wired 但不 work」train-util 病）。

## fix A（你建議、honest 移除非留死 weight）
移除 `rep_bonus` 項 + `PROMOTE_LOY_REP_W` const。忠誠 = **提拔感激正底（義氣/信義 modulate）− 源團舊怨（unrest）− 急徵拖**；floor 0.2。源團對領主態度**已由 `unrest_turns` 完整捕捉**、reputation 對 own-team promotion 拓撲不可得 → honest 3-signal（gratitude + unrest + desperate + 人格）。

## ★test 盲點補
`promotion_mood_test` ② 從「幸福 loy > 0.5 絕對」改 **relative**（幸福 0.5 顯著 > 怨團 floor 0.2 + 高義氣 0.7 > 中性 0.5 人格 modulate）——rep 惰性根除、不再靠惰性常數撐絕對值。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `promotion_mood_test` | **ALL PASS**：①分化（幸福 loy**0.5**/stress0.1 · 怨團 loy0.2/stress0.5 · 絕境 loy0.2/stress0.75/fear0.45）②感激加成 relative（幸福 0.5>怨團 floor 0.2、高義氣 0.7>中性 0.5 人格 modulate）③§4.5 bounded ④determinism ⑤uprising 接線 |
| headless | **0-new** |
| constitution_gate | **PASS sites=75** |
| regression | `active_promotion` + `named_scarcity_ab` **ALL PASS** |
| determinism | **3-run byte-identical**（ledger 20天 FP `2cbd13dc`） |

## ★fp 前後對照 LIVE（ledger 45天、baseline[白紙 0/0] vs branch[state]）
| metric | baseline | branch |
|---|---|---|
| **FP** | `c98e7029` | `a3863d99` **DIVERGED** |
| init_loyalty_peak | 0.000 | **0.415**（state-derived、含 unrest carryover 故 <0.5=真反映源團） |
| init_stress_peak | 0.000 | **0.450** |
| promote.fired | 5 | 5 |

## 路
1. **你 merge-gate re-硬讀**（核 rep 項已移、忠誠 **3-signal 全 genuine work**[unrest+desperate+人格 modulate]、無死常數殘留）。
2. → QA adversarial → merge → **blueprint 推用戶**（收官回 blueprint）。地基 KEEP。

（perf flag 續 + F2 disk ~115 stale worktrees 待 prune。）
