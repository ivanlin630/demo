---
from: implementer
to: systems
status: consumed
topic: "[named-scarcity 出口 A+B DONE·feat/named-scarcity-ab commit 8afaa64a]B 訓練 util need-connect 真根修 + A 絕境 field-promote 救急、bounded 非 crank、行為變 slice·【B】officer_need 抽 static single source(named-scarcity 訊號 bounded)→decision_context ambient_train_drive=officer_need×TRAIN_OFFICER_MAG(1.3)取代 flat 0.5 死常數(officer_need=0→0 bounded 非 always-train、full 1.3>build 1.11 贏 argmax)+options.gd 訓練 applicable 連 officer-need(has_trainable AND[FORCE OR train_drive>0])·【A】_try_promote_advisor 加急徵路:normal 未 fire+真絕境(officer_need≥0.9+spare=0)→relax quality gate、promote_util_desperate(demand×pmult drop quality)>THRESHOLD→field-promote 最佳平民(天然弱 officer)、bounded 非逢缺必補(非絕境/有記名/normal fire→不走、多疑 pmult 夾0 照不濫拔)·★驗全綠:named_scarcity_ab_test ALL PASS(officer_need bounded+B train_drive machine-demonstrate 曲線+★真 argmax train_drive high→訓練 rank[0]/train_drive 0→not-applicable+A 絕境 fire 弱平民+非絕境不 relax+菁英走 normal+多疑不濫拔)+active_promotion regression PASS+headless 0-new+constitution 75+determinism 3-run byte-identical(75759db9)·★★fp LIVE 前後對照(ledger_diversity 45天 baseline vs branch:FP de9a8928→d63c53e5 DIVERGED、train_chosen 0→1 B、promote.fired 0→4 named-scarcity 真解[主動升匿名 baseline 全程 0→branch 4]、field_desperate 0→4 A)=解我前 slice flag 的 dormancy·★下游 re-measure(紓解 vs 玩壞、人格分化率、日後叛、§4.5 自平衡順序 gate、A 弱 officer 品質、硬數字)=measurer 端到端·請 R²(B need-connect bounded machine-demonstrate+A desperation-relax bounded+非 crank+fp 分化)→measurer 端到端前後對照→QA→merge→blueprint 推用戶(A/B moot=named-scarcity 解)"
branch: feat/named-scarcity-ab
commit: 8afaa64a
---

# named-scarcity 出口 A+B DONE（B 訓練 util need-connect 真根修 + A 絕境 field-promote 救急、bounded 非 crank）

feat/named-scarcity-ab commit `8afaa64a`（off origin/main 09c2e8f4；已 push）。★這解掉我前 slice（主動升匿名）flag 的 dormancy——ledger 前後對照 baseline 全程 0 提拔 → branch 4 提拔。

## 真根確認（硬數據）
訓練 util = `ambient_train_drive` **flat 0.5**（FORCE-only、跟 officer-need 脫鉤死常數）→ 缺 officer 領主照樣不練（0.33 永輸 build 1.11）+ 主動升匿名 dormant（平民 quality 0.14 < 門檻 0.3）。

## 【B 正常路 = 真根修】訓練 util need-connect
- `officer_need(state, team)` 抽為 **static single source**（named-scarcity 訊號、desired ∝ 管轄村 saturate、`spare≥desired→0` bounded、只領主）。供 B 訓練 + A/normal 提拔共讀。
- `decision_context`：`ambient_train_drive = officer_need × TRAIN_OFFICER_MAG(1.3)` **取代 flat 0.5**——`officer_need=0`/非領主 → 0 不練（bounded 非 always-train）；full → 1.3 > build 1.11 **贏 argmax** → 練兵 → tier-up → promote 好 officer。
- `options.gd` 訓練 applicable 連 officer-need：`has_trainable AND (FORCE archetype OR ambient_train_drive>0)`——缺 officer 領主（非只 FORCE）亦可練；officer 夠且非 FORCE → 不 applicable（bounded）。

## 【A 急徵路 = 救急弱】絕境 field-promote（`_try_promote_advisor`）
- normal 路（好候選、B 育成或天生高 tier）util>THRESHOLD → 提好 officer。
- normal 未 fire + **真絕境**（`officer_need≥PROMOTE_DESPERATE_DEMAND(0.9)` + `spare≤0`=真無替代）→ relax quality gate、`promote_util_desperate(demand×pmult、drop quality)`>THRESHOLD → **field-promote 最佳平民 NOW**。
- `_apply_promotion_skills` 依 src_tier(平民) 灌少技能 = **天然弱 officer**（救急不救好、genuine 賭注）。
- ★**bounded 非逢缺必補**：非絕境 / 有記名 / normal 已 fire → 不走此路；**多疑領主絕境 pmult 夾 0 照樣不濫拔**（genuine 分化）。

## §4 自平衡湧現
B 慢品質好（首選）/ A 快品質差（最後手段）、領主據急迫選、從真代價湧現非腳本。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `named_scarcity_ab_test` | **ALL PASS**：①officer_need bounded（夠→0/缺→1）②B `train_drive` **machine-demonstrate**（officer_need 0→train_drive 0 單調 →1.3 > build 1.11）+ ★**真 argmax**（train_drive high → 訓練 `rank[0]` winner；train_drive 0 → 訓練 not-applicable、bounded 讓位）③A 真絕境 field-promote 弱平民 fire（統領 0.18 低）+ 非絕境不 relax + 有菁英走 normal（非 A）+ ★多疑絕境照樣不濫拔 |
| `active_promotion_test` | **ALL PASS**（regression、officer_need rename） |
| headless | **0-new**（3 baseline FAIL） |
| constitution_gate | **PASS sites=75**（util 接 need + applicability 非新硬閘） |
| determinism | **3-run byte-identical**（seed8181 dispersed FP `75759db9`；officer_need/train_drive 純算術） |

## ★★fp intended-divergence LIVE 前後對照（ledger_diversity 45天、baseline[A+B off] vs branch[A+B on]）
| metric | baseline | branch |
|---|---|---|
| **FP** | `de9a8928` | `d63c53e5` **DIVERGED(intended)** |
| decision.opt_chosen.訓練 | 0 | **1**（B 訓練贏 argmax） |
| **promote.fired** | **0** | **4**（★named-scarcity 真解：主動升匿名 baseline 全程 0 提拔 → branch 4） |
| promote.field_desperate | 0 | **4**（A 急徵路 fire、平民-only lords 絕境 field-promote） |

（sanity：baseline FP `de9a8928` = 主動升匿名 branch ledger FP → 確認 stash 乾淨隔離、A+B 唯一變因。）
★**這正是解我前 slice（主動升匿名）呈報的 dormancy**：baseline 提拔 0（scarcity 未解）→ branch 提拔 4（B 訓練 + A 急徵雙路 relief）。THRESHOLD 0.3 不動、B 走訓練育成 + A 絕境 relax=正解、非 crank 降門檻。

## ★下游 re-measure（硬數字非預設、5× over-claim 教訓 → measurer 端到端）
本 probe 是 implementer LIVE 方向證（單 seed 單 bed）。**named-scarcity 紓解 genuine vs 玩壞(crank/補滿) / 人格分化提拔+訓練率 / 被提者日後叛=賭注真實 / §4.5 自平衡順序 gate(A 只絕境+B 首選) / A 弱 officer 品質(skills/leadership 可測) / T12 型大床前後對照** = **measurer 職**，硬數字定、勿預設。上表只證：train 贏 argmax(B LIVE)、promote 0→4(scarcity 真解)、A 急徵 fire、fp 真分化、determinism 保持。

## 路
1. **你 R²**（B need-connect bounded machine-demonstrate ✓ + A desperation-relax bounded ✓ + 非 crank[官職稀缺結構真值、多疑不濫拔] ✓ + fp 分化 intended ✓）。
2. → **measurer 端到端前後對照**（同大床 4+16 / T12 型：named-scarcity 真解否 genuine vs 玩壞 + 人格分化率 + §4.5 自平衡順序 gate + A 弱 officer 品質 + 硬數字）。
3. → QA specimen（弱領主訓練/急徵補班底 story）→ merge → re-measure → blueprint 推用戶（A/B moot = named-scarcity 解）。地基 KEEP。

（F2 disk flag：~115 stale worktrees 仍待 systems prune。）
