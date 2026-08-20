---
from: implementer
to: systems
status: consumed
topic: "[統一派遣模型 DONE·feat/unified-dispatch commit 285bca8f]3 drain 點(scout/care/rescue)改 named-led、架構修、行為變 slice·真根=dispatch_anon_messenger 生 leaderless 孤匿名→loop3:784 succession 每 tick 誤升 anon→named→匿名 monotonic drain+幽靈團膨脹·fix=新 _pick_dispatch_runner(借 named_members 統領最低=次要記名、無 spare→-1 少做 named-scarcity genuine 非 crank)+_dispatch_named_runner(共用入口→SubteamSystem.dispatch() named-led+補 dispatch 未設的 scout lifecycle 欄 reason/start_tick/extra_data+equip_mounts)·named-led→leader_id≠-1→784 從不誤觸(機械升格 0)+recall→merge_back 記名回 roster(§3 歸隊 zero-drain)+pop_count=1 零 anon 跟班(§1 單獨=記名)·herald 移出(in_transit_letters 非 subteam、不動)·primitive dispatch_anon_messenger 保留(infonet_part2_test 測基元、僅 3 prod caller 移除)·§4 主動升格 parked·★驗全綠:unified_dispatch_test 17/17+missing_contact_ledger ⑧ 更新 named-led+infonet_part2 PASS+headless 0-new+constitution 75+determinism 3-run byte-identical(75759db9)·★fp intended-divergence LIVE(seed8181 dispersed 45天 baseline vs branch:FP 5433290e→75759db9、lord anon 4→0 drain 斷成 4→4、團數 end6 幽靈→end4 無殘、scout 4→2 named-scarcity 少做)·★下游 re-measure 硬數字(團數/O(N²)貢獻/組成分化/湧現升格率)=measurer 完整量化(4× over-claim 教訓非預設)·請 R²(named-led 3 點+歸隊+機械升格 0 前提+§2 util genuine 非 crank+fp 分化 intended)→measurer→QA specimen→merge"
branch: feat/unified-dispatch
commit: 285bca8f
---

# 統一派遣模型 DONE（3 drain 點 named-led、用戶拍 B、架構修、行為變 slice）

feat/unified-dispatch commit `285bca8f`（off origin/main 199dd40b=含 iii merged；已 push）。

## 真根確認（code-read）
scout/care-scout/rescue 用 `dispatch_anon_messenger` 生 **leaderless（leader_id=-1）孤匿名 subteam** → loop3:784 `if team.leader_id == -1: on_leader_death` **每 tick 對其誤觸** → succession 升 anon→named → 匿名池 **monotonic drain** + 幽靈 named 團膨脹（餵 O(N²)）。

## fix（§1–§5、★不動 faction_ai:784 本身）
- 新 `_pick_dispatch_runner(state, team)`：借 `named_members` 中**統領最低者**（次要記名、留親信/強將辦要事）當跑腿領隊；無 spare → **-1**（§2 named-scarcity **genuine 戰略約束**=領主少做、非 crank、非孤匿名頂替；§1 匿名不落單）。
- 新 `_dispatch_named_runner(...)`：3 點共用入口 → `SubteamSystem.dispatch()`（named-led、sub_leader ∈ named_members）+ **補 dispatch() 未設的 scout lifecycle 欄**（`task_reason`/`task_start_tick`/`task_extra_data.timeout`）+ `equip_envoy_mounts`。
  - named-led → `leader_id != -1` → succession **784 從不誤觸**（機械升格 0）。
  - 任務完 `recall_envoy` → `try_merge_back` → **記名回母 roster**（§3 歸隊 zero-drain）。
  - `pop_count=1` → 零 anon 跟班（§1 單獨=記名）。
- 3 點：`_try_scout_side`(info_scout) / `_dispatch_care_scout`(info_scout) / `_apply_contact_reaction` rescue(contact_rescue)。
- ★**herald 移出 scope**（R² 訂正）：`_try_herald_side` 走 `in_transit_letters`（letter-as-data、非 subteam）→ 不觸 succession、不動。
- ★`dispatch_anon_messenger` primitive **保留**（infonet_part2_test 測基元、dispatch_anon_migrants 鏡射參照）；僅 3 個 prod caller 移除。**flag**：修後此 primitive **無 prod caller**（只 test 引用）→ systems 可評估 prune 或留給 parked 主動升格。
- §4 主動/deliberate 升格 = parked（本 arc 不做）；真 leaderless 團（記名領隊真死）succession 照走不受影響。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `unified_dispatch_test` | **17/17 PASS**：①次要記名 pick 統領最低 + 無 spare→-1 ②named-led leader≠-1（784 不誤觸前提）+ 零 anon 跟班 + lifecycle 欄補設 + 母隊 anon 池不變 ③named-scarcity 少做不派 ④歸隊: recall→merge_back→記名回 roster + anon 守恆 + population 復原 + 子隊 erase 無幽靈團 |
| `missing_contact_ledger_test` ⑧ | 更新 named-led（rescue leader=P12 次要記名、非孤匿名）**ALL PASS** |
| `infonet_part2_test` | **ALL PASS**（messenger primitive 保留） |
| headless | **0-new**（3 baseline FAIL：Team23建設×2/弱目標） |
| constitution_gate | **PASS sites=75**（dispatch()=既有 primitive、無新 task-assign site） |
| determinism | **3-run byte-identical**（seed8181 dispersed、FP `75759db9`；`_pick` = deterministic argmin 零 RNG） |

## ★fp intended-divergence LIVE（seed8181 dispersed 45天、baseline[fix off] vs branch[fix on]）
| metric | baseline(fix off) | branch(fix on) |
|---|---|---|
| **FP** | `5433290e…` | `75759db9…` **DIVERGED(intended)** |
| lord(Team0) anon 池 | 4 → **0（drain=4）** | 4 → **4（drain=0）** ★drain 斷 |
| 團數 | peak 7 / **end 6**（幽靈團殘留） | peak 5 / **end 4**（無幽靈團殘留） |
| scout.dispatched | 4 | 2（named-scarcity 少做、記名歸隊後可再派） |

（sanity：baseline FP `5433290e` = iii branch FP → 確認 stash 乾淨隔離、unified 是唯一變因。）

## ★下游 re-measure（硬數字非預設、4× over-claim 教訓 → measurer 完整量化）
本 probe 是 implementer LIVE 方向證（單 seed 單 scenario）；**團數 / O(N²) per-tick 成本貢獻 / 組成分化(要害→親信/routine→次要/規模→帶團) / 湧現升格率(領隊死接班) / 機械升格=0 全域驗 / relief-care-builder 下游派得出否** = **measurer 職**，硬數字定、勿預設。上表只證：drain 真斷（4→0→4）、幽靈團真消（end6→end4）、fp 真分化、determinism 保持。

## 路
1. **你 R²**（named-led 3 點 ✓ + 歸隊 zero-drain ✓ + 機械升格 0 前提[leader≠-1] ✓ + §2 util genuine 非 crank[次要 pick + named-scarcity 少做] ✓ + fp 分化 intended ✓；核 primitive 保留/prune 決策）。
2. → **measurer 量**（anon 穩全域 + 組成分化 + 湧現升格照 fire + 機械升格 0 + 下游 re-measure 團數/O(N²) 硬數字 + 校 named-scarcity 少做是否過抑）。
3. → QA specimen（scout 派記名→歸隊 story）→ merge → re-measure → blueprint 推用戶。地基 KEEP。

（F2 disk flag：~115 stale worktrees 仍待 systems prune。）
