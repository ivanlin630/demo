---
from: implementer
to: systems
status: consumed
topic: "[主動升匿名 DONE·feat/active-anon-promotion commit 630f177c]統一派遣 §4 第3路 deliberate 提拔、解 named-scarcity、bounded 非 crank、行為變 slice·機制=_try_promote_advisor 入 info_side_dispatch_all 日 cadence(先於 dispatch)→generate_for_team(7th caller、kill_random 精銳真扣池+generate 獨立人格+不可逆)+add_member(進 lord roster 非 subteam=與誤升 bug 涇渭)·§2.5 bounded 命門:promote_util=clampf(demand,0,1)×pmult(0.3+野心0.9−慎重0.7)×quality(best_tier_combat/0.7)、demand=(desired−spare)/desired[desired=clampf(oversight×0.5,0,4)、spare≥desired→0 bounded 非逢缺必補]、fire 僅 util>THRESHOLD0.3→多疑/低需求/無夠格候選 util→0 不 fire(非自動補滿)·§3 成本=獨立人格忠誠賭注+kill_random 真扣+不可逆·★驗全綠:active_promotion_test 21/21(①bounded machine-demonstrate 曲線[demand0→0、多疑util≡0 across demand 非flat、野心0→0.97 單調]②三人格分化 野心0.776>中性0.320>多疑0.000 湧現③候選資質gate 平民0.14<菁英1.0④firing named+1/anon-1/獨立人格⑤多疑不提=非自動補滿⑥spare≥desired不提⑦無anon不提⑧info_side_dispatch_all cadence LIVE)+headless 0-new+constitution 75+determinism 3-run byte-identical(75759db9)·★★透明flag:快速標準床 promotion DORMANT(dispersed util_peak0.0114/ledger0.1386 皆<0.3=低-oversight 小faction 未達門檻→fp 對baseline byte-identical)、firing 需高-oversight 領主(unit④ util0.97@8村野心)→whole-sim fire+fp分化+named-scarcity紓解在 measurer 4+16 大床·★★關鍵校準疑問呈報:THRESHOLD0.3 是否真解 T12 named-scarcity(中度-village 領主 util 可能<0.3 仍不提)=measurer 前後對照定、勿我 crank·請 R²(§2.5 bounded machine-demonstrate+三人格湧現非crank+add_member非subteam+成本真扣+fp分化)→measurer 4+16大床前後對照(named-scarcity紓解vs玩壞+人格分化提拔率+校THRESHOLD)→QA→merge"
branch: feat/active-anon-promotion
commit: 630f177c
---

# 主動升匿名 DONE（統一派遣 §4 第 3 路 deliberate 提拔、解 named-scarcity、bounded 非 crank、行為變 slice）

feat/active-anon-promotion commit `630f177c`（off origin/main 4cf76585；已 push）。

## 機制（§4 第 3 路 anon→named、generate_for_team 第 7 caller = wiring 既有原語非新機制）
- `_try_promote_advisor`（faction_ai）入 `info_side_dispatch_all` 日 cadence（★**先於** herald/scout dispatch → promoted advisor 同 tick 可供 dispatch = 直接解 named-scarcity）。
- promote = `PersonGenerator.generate_for_team`（`kill_random` 抽 1 anon 偏高 tier 精銳=**真扣 anon 池** + `generate()` **獨立人格值非複製** + 不可逆）+ `state.add_member`（加記名進 lord roster、**非 spawn 孤立 subteam** = 與機械誤升 bug 涇渭、不重引孤匿名）。
- §4 機械誤升 bug（統一派遣已除）保持除；deliberate 提拔=有動機有代價的第 3 路。

## §2 決策 + §2.5 bounded 非 crank 命門
```
promote_util(demand, ambition, caution, quality)
  = clampf(demand,0,1) × pmult × clampf(quality,0,1)
pmult   = clampf(0.3 + 野心×0.9 − 慎重×0.7, 0, 1.5)          # 野心樂提 / 多疑吝嗇
demand  = clampf((desired − spare)/desired, 0, 1)            # spare≥desired → 0（bounded 非逢缺必補）
desired = clampf(oversight × 0.5, 0, 4)                      # oversight=管轄村數（絕境被迫從高 demand 湧現）
quality = best_anon_tier_combat / 菁英combat(0.7)            # 資質浮現、非每平民幹部料
fire ⟺ util > PROMOTE_THRESHOLD(0.3)
```
三人格分化（絕境被迫 / 野心樂提 / 多疑吝嗇）**從 demand×pmult×quality 競秤湧現**（非三硬 branch）；**多疑 / 低需求 / 無夠格候選 → util→0 不 fire**（非自動補滿、與 §1「禁自動補滿」一致）。TEST VALUE：`NAMED_PER_VILLAGE=0.5 / MAX_DESIRED=4 / THRESHOLD=0.3 / ELITE_COMBAT=0.7`（measurer 校準）。

## §3 genuine 成本
被提者=**獨立人格個體**（`generate()` 忠誠/慾望 = 未來忠誠風險賭注）+ `kill_random` 真扣 anon 池 + **不可逆**。養成/嫉妒 = parked。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `active_promotion_test` | **21/21 PASS**：①§2.5 promote_util **bounded machine-demonstrate 曲線**（demand 0→util 0；**多疑 util≡0 across all demand 非 flat 逢缺必補**；野心 0→0.97 單調）②三人格分化 野心 0.776 > 中性 0.320 > 多疑 0.000 湧現 ③候選資質 gate 平民 0.14 < 菁英 1.0 ④firing named+1/anon-1(真扣)/獨立人格 ⑤多疑同場景不提=非自動補滿 ⑥spare≥desired→demand0 不提 ⑦無 anon 不提 ⑧`info_side_dispatch_all` cadence 接線 LIVE |
| headless | **0-new**（3 baseline FAIL：Team23建設×2/弱目標） |
| constitution_gate | **PASS sites=75**（提拔=決策、無新 task-assign/god-view site） |
| determinism | **3-run byte-identical**（seed8181 dispersed FP `75759db9`；promote_util 純算術、generate deterministic 自 `_team_seed`） |

## ★★透明 flag（非隱瞞、care-loop/iii 同型 dormant-in-fast-beds）
快速標準床 promotion **DORMANT**：dispersed `util_peak=0.0114` / ledger_diversity `util_peak=0.1386`，皆 **< THRESHOLD 0.3** = 低-oversight 小 faction（1–2 村）未達門檻 → **fp 對 baseline byte-identical**（`75759db9` = 統一派遣 branch FP、promotion 零分化）。
- 機制 **LIVE 且 fires**：unit ④ util `0.97` @ 8-village 野心領主 → 提拔 named+1/anon-1；unit ⑧ 走真 cadence `info_side_dispatch_all` fire。
- whole-sim fire + fp 分化 + named-scarcity 紓解 → **measurer 4+16 大床**（§5 前後對照職）= 高-oversight 領主才過門檻。

## ★★關鍵校準疑問呈報（measurer 定、勿我 crank）
**THRESHOLD=0.3 是否真解 T12 named-scarcity？** 中度-village 領主（如 2 村、desired=1、中性人格）util ≈ 0.28 **< 0.3 → 仍不提**。若目標 T12 是中小 faction，0.3 可能過高 → slice 不解目標問題；若 T12 是大 faction（多村）→ 會 fire。**這是 TEST VALUE 校準 = measurer 前後對照定**（named-scarcity 紓解 vs 玩壞），我按 §2.5 genuine 結構給起始值、**不 crank 降門檻逼 fire**（乙教訓）。measurer 若量出 under-fire → 回報調 THRESHOLD/NAMED_PER_VILLAGE。

（perf note：`infonet_established_fragility` 45天 probe >500s timeout — 疑 bed 本身重[fragility-collapse 動態]非本 code，dispersed/ledger 皆 ~1min 正常；measurer 大床若也慢請 flag。）

## 路
1. **你 R²**（§2.5 bounded machine-demonstrate ✓ + 三人格湧現非 crank ✓ + promote=add_member 非 subteam ✓ + 成本真扣 ✓ + fp 分化 intended[dormant-in-fast-beds flag] ✓）。
2. → **measurer 4+16 大床前後對照**（無出口 baseline vs 有出口：named-scarcity genuine 紓解 vs 玩壞 + 人格分化提拔率[野心多/多疑少/絕境被迫] + 被提者日後叛=賭注真實 + **校 THRESHOLD 是否解 T12**）。
3. → QA specimen（弱領主提拔補班底 story）→ merge → re-measure → blueprint 推用戶（named-scarcity 解否 + A/B moot 否）。地基 KEEP。

（F2 disk flag：~115 stale worktrees 仍待 systems prune。）
