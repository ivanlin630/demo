---
from: implementer
to: systems
status: consumed
topic: "[F2 treasury 域模組切 DONE·②結構首刀 byte-identical·feat/framework-F2 commit f5da3319]①CoinTreasury static module:5 域函式+8 const 自 faction_ai 逐字搬(零 logic 改、instance→static 為結構搬移、零反向耦合全呼外部)。②caller 全更新 exhaustive:faction_ai:835/836+player_command:248+resource_system:177+debug/test(extraction_need_driven/material_hold[+COIN_NEED_CAP]/unified_commerce[+PERSONAL_COIN_FLOOR]/headless:8521)→CoinTreasury.。★★命門:fp 對 ce201650 baseline 27/27 byte-identical(diff=0=純移零行為變證)。驗:treasury tests PASS+constitution 75(無新 gate site)+headless 0-new+determinism 天然保持(byte-identical to 3-run-stable baseline)。★unified_commerce_test 5 FAIL=pre-existing(main 同 5、市場 order 非 treasury、非本 slice regression)。★operational flag:disk full(~120 stale worktrees)、我移除自己 4 merged(recovery-r1/r2/r3+framework-F0、work 全在 main+pushed 安全)騰空、餘~115 stale 建議 systems prune。請 R²(核純移零改+全 caller 無漏+fp byte-identical)→QA→merge=F2 收(結構 track 首刀示範)。"
branch: feat/framework-F2
commit: f5da3319
---

# F2 treasury 域模組切 DONE（②結構首刀、byte-identical 純程序）

feat/framework-F2 commit `f5da3319`（已 push、pre-push constitution PASS 75）。②結構 track 第一刀示範。★**純結構搬移零 logic 改**。

## ① `CoinTreasury` static module（`scripts/simulation/coin_treasury.gd`）
5 域函式 + 8 const 自 `faction_ai_system` **逐字搬**：`extract_treasury`/`coin_need`/`extract_buffer`/`consider_extraction`/`collect_member_tax` + `COIN_NEED_CAP`/`EXTRACT_BUFFER_MIN`/`MAX`/`MEMBER_TAX_K`/`K2`/`MIN`/`MAX`/`PERSONAL_COIN_FLOOR`。
- **零 logic 改**（instance→static = 結構搬移非行為變、全函式零 instance state）。內部互呼內化（consider_extraction → coin_need/extract_buffer/extract_treasury）。
- **零反向耦合**：全呼已模組化外部（AnonTreasuryBank/ResourceBank/LoyaltyBank/UnrestBank/TradeValuation/NeedOracle/ResourceSystem/DecisionTerms/Probe）、不回呼 faction_ai。

## ② caller 全更新（exhaustive、R² 補完 debug/test）
| 類 | caller → CoinTreasury. |
|---|---|
| production | `faction_ai loop:835/836`(consider/collect) + `player_command:248`(extract) + `resource_system:177`(extract) |
| debug/test | `extraction_need_driven_test`(coin_need/consider/buffer/extract) / `material_hold_test`(coin_need + `COIN_NEED_CAP`) / `unified_commerce_test`(collect_member_tax + `PERSONAL_COIN_FLOOR`) / `headless_test:8521`(extract) |
| ★未動 | `_action_extract_treasury`(player_command wrapper、非移動函式) / `_test_*extract*`(test 名) |

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| treasury tests | `extraction_need_driven_test` ALL PASS / `material_hold_test` ALL PASS |
| ★★**fp 對 ce201650** | **27/27 byte-identical、diff=0**＝純移零行為變命門證（任一漂=夾帶行為變、無） |
| constitution_gate | **PASS sites=75**（移動無新 gate site；treasury 5 函式無 taskarbiter/decision-gate、const 非 gate-tracked） |
| headless | **0-new**（Team23建設×2/弱目標/p2a/197/rung pre-existing） |
| determinism | 天然保持（fp byte-identical to 3-run-stable ce201650 baseline） |
| ★unified_commerce_test 5 FAIL | **pre-existing**（main 同 5 FAIL、市場 order 直沖/qty_remaining=material 交易非 treasury、F2 前既存、**非本 slice regression**；treasury 相關 assert[collect_member_tax/floor]通過） |

## ★operational flag（呈你、非阻塞）
build 途中撞 **disk full（`No space left on device`）**——`.worktrees/` 累積 ~120 stale worktree（大量已 merged 舊 slice：means-end-s1..s7/seam1-3/threat-oracle/godview-a..f/persist-slice/plan-layer 等）。我移除**自己的 4 merged**（recovery-r1/r2/r3 + framework-F0、work 全在 main + pushed branch=安全可復原）騰空續工。餘 ~115 stale 建議 systems/orchestrator `git worktree prune` + 清已 merged 目錄（worktree 衛生）。

## 路
1. **你 R²**（核：純 code-move 零 logic 改 + 全 caller 無漏 + fp byte-identical 27/27 + 零反向耦合）。
2. → QA → merge = F2 收（結構 track 首刀示範）→ F3。

地基 KEEP。
