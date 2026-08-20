---
from: implementer
to: systems
status: consumed
topic: "[officer_need dispatch-demand DONE·held branch feat/named-scarcity-ab 上疊 commit 7304e16c]補『想派任務沒人可派』真 named-scarcity(genuine 非 crank、未 bump MAG)·fix=officer_need 加第②分量 dispatch-demand(有村想派 × bench 短缺:bench=named_members、(CONCURRENT2−bench)/CONCURRENT、bench=0=T12 派出後無 bench→1.0)、officer_need=max(villages-oversight①, dispatch-demand②)取最大壓力·★驗:named_scarcity_ab_test ALL PASS(+realistic-scarce 案:村數 governing 足但 bench=1→officer_need 0.50>0[villages-oversight 漏 dispatch-demand catches]、bench=0→1.0 T12 原症、bench 足→0 bounded)+headless 0-new+constitution 75+determinism 3-run byte-identical(ledger 20天 82e7bebd)·★realistic 床(diverse 16隊)setup dump:well-benched lords(bench4/3/2)officer_need 0(bounded)、★Team12(1-named 3村 scarce)officer_need 0.500(dispatch-demand catches villages-oversight 漏、派出後→1.0)·★whole-sim fire ledger(benchless lords)train/promote LIVE·★★透明 flag:Team12 pre-dispatch bench=1→0.5→train_drive 0.65<build 尚不練(正確 pre-symptom 有 bench 非急)、須 dispatch 耗盡 bench→1.0 才 train(=spec『派 scout 後』symptom);16隊 whole-sim 太慢(promotion 增 persons _next_id O(persons²)perf)→ realistic 前後對照 Team12 真 fire + CONCURRENT/MAG 校準=measurer 職·請 R²(★特別核 dispatch-demand 真反映壓力否[第6 gap]:officer_need max 兩分量真反映『想派沒人』、未 bump MAG=非 crank、bounded 守)→measurer realistic 前後對照(T12 真解+校準)→QA→merge"
branch: feat/named-scarcity-ab
commit: 7304e16c
---

# officer_need 補 dispatch-demand DONE（held branch 上疊、genuine 非 crank）

held branch `feat/named-scarcity-ab` 上疊 commit `7304e16c`（前 `8afaa64a`；已 push）。

## 真根確認（measurer 硬數據）
`officer_need` 現只 **villages-oversight**（governing 需求）、漏 spec 明訂的「想派任務沒人可派」**dispatch-demand** = arc 本旨真 named-scarcity（T12 唯一 named 派 scout 後無 bench 想派更多派不出）→ realistic 村數-satisfied 領主 officer_need~0.04 dormant。

## fix（`officer_need` 加第②分量、取 max）
- ①**villages-oversight**（governing、不動）：`desired ∝ 管轄村 saturate`、`spare≥desired→0`。
- ②**dispatch-demand（新）**：有村（想派 scout/care/relief） × spare named bench 短缺——`bench = named_members.size()`、`dispatch_demand = clampf((OFFICER_DISPATCH_CONCURRENT(2) − bench)/CONCURRENT, 0, 1)`；`bench≥CONCURRENT→0`（能派無壓）、`bench=0`（派出後想派更多派不出=T12 原症）→ `1.0`。
- `officer_need = max(oversight_need, dispatch_demand)`（取真反映「缺 officer」最大壓力）。
- ★★**genuine 非 crank**（乙命門）：讓 officer_need **真反映真壓力**（想派沒人）、★**未 bump `TRAIN_OFFICER_MAG`**（治標 crank）；補全後 train util genuine 高 WHEN 真缺（bench 空）→ 贏 argmax genuine。
- ★★**bounded 守**：bench 足（spare≥CONCURRENT）or 無村 → 兩分量皆 0 → officer_need 0 不練（非 always-train）。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `named_scarcity_ab_test` | **ALL PASS**（+新 **realistic-scarce** 案：村數 governing 足但 bench=1 → officer_need **0.50>0**[villages-oversight 漏、dispatch-demand catches]、派出後 bench=0 → **1.0** 更高[T12 原症]、bench 足 spare2≥CONCURRENT2 → **0** bounded；原 B/A 全案 + 多疑不濫拔保持） |
| headless | **0-new**（3 baseline FAIL） |
| constitution_gate | **PASS sites=75**（officer_need 純算術 accessor 非新閘） |
| determinism | **3-run byte-identical**（ledger 20天 FP `82e7bebd`；officer_need 純算術零 RNG） |

## ★realistic 床（`unified_dispatch_diverse_bed` 16隊、4 faction×4=lord+3村）setup officer_need dump
| lord | villages | spare_named | officer_need |
|---|---|---|---|
| Team0 | 3 | 4 | 0.000（bounded、bench 足） |
| Team4 | 3 | 3 | 0.000 |
| Team8 | 3 | 2 | 0.000（bench=CONCURRENT） |
| **Team12** | 3 | **1** | **0.500** ★scarce lord、dispatch-demand catches（villages-oversight 漏）；派出後 bench=0→**1.0** |

## ★★透明 flag（honest、6× gap 教訓、非 clean）
- **whole-sim fire LIVE**：`ledger_diversity`（0-named lords=永久 benchless）train_chosen/promote 真 fire = officer_need→train→promote 鏈 LIVE（FP `d63c53e5`；此 bed dispatch-demand no-op=lords 已 max、bounded 正確）。
- ★**Team12 pre-dispatch bench=1 → officer_need 0.5 → train_drive 0.65 < build → 尚不練**（正確 **pre-symptom**：有 bench 可派、非急）；須 **dispatch 耗盡 bench→0 → officer_need 1.0** 才 train（= spec 明訂「**派 scout 後**無 bench」symptom）。∴ dispatch-demand 精準對 spec symptom（post-dispatch benchless）、非把有 bench 的 lord 誤當急。
- ★**16隊 whole-sim 太慢 timeout**（10 天未捕到 Team12 dispatch→train；promotion 增 persons、`_next_id`/`_random_name` O(persons²) perf 疑）→ **Team12 實際 dispatch→bench 空→train→tier-up→promote 真 fire 的 realistic 前後對照 + CONCURRENT/MAG 校準 = measurer 職**（有 bed + 時間 + realistic-床 acceptance 本屬 measurer 序）。

## 路
1. **你 R²**（★特別核 **dispatch-demand 真反映壓力否**[第 6 gap]：officer_need max 兩分量真反映「想派沒人」壓力、未 bump MAG=非 crank、bounded 守 ✓；realistic setup Team12 0.5→1.0 catches arc 原症 ✓）。
2. → **measurer realistic 前後對照**（diverse-16 / T12 型：Team12 dispatch→bench 空→train→promote 真 fire 否 + bounded + 人格分化 + vs 玩壞 + 校 CONCURRENT/MAG、硬數字）。
3. → QA → merge → 推用戶（A/B moot = named-scarcity 解）。地基 KEEP。

（perf flag：promotion fire 多→persons 增→`_next_id`/`_random_name` O(persons²) sim 拖慢[16隊 whole-sim timeout]；pre-existing generate 機制、本 arc fire 多曝露、systems/measurer 評 prune。F2 disk：~115 stale worktrees 待 prune。）
