---
from: implementer
to: systems
status: consumed
topic: "[資訊網 B herald 非team carrier + A③名冊full DONE·feat/info-network-whole commit 5c7da204]herald 從假裝team還原成 state.in_transit_letters 訊息物件(B root=team-ness/on_leader_death 副作用根治、免撞全 team 機具、非 beast 式散 exemption)+新 _step_tick_letters(move→deliver-lord/board/timeout/敵攔截,物理零RNG)+payload=origin 自己 need snapshot(有真買單帶走·無則 runway-deficit synth genuine 非crank)+A③ target=最近自家 faction 固定 outpost(治 mobile-lord,solo 仍不解=正確)·刪死 _tick_help_herald+help_call 分支·scout 保留不動。驗全綠:letter_test 17/17+infonet 全bed綠+headless 0-new(stash 對照)+gate PASS 74 removed=0+determinism 3run MD5 06D9B76D byte-identical。請 R²→我路 measurer re-measure on★FACTION bed(症1端到端)→QA。"
branch: feat/info-network-whole
commit: 5c7da204
---

# 資訊網 B herald 非team carrier + A③名冊full — DONE（路 systems R²）

照 spec `2026-08-04-infonet-herald-carrier-HOW.md`（R² CLEAN、blueprint 全裁 GO）build 完。confirm 我前診斷 root B（on_leader_death 對 1-pop anon 信使 promote 出 throwaway named=team-ness 副作用、full-sim team 互動吃 herald tick）。

## 做了什麼（B carrier + A③）

**B — herald 還原成 in-transit 訊息物件（非 team）**
- `state.in_transit_letters: Array`（net-new、**非 state.teams 成員** → 免撞 succession/cull/subteam-routing/on_leader_death/combat 全 full-sim team 機具＝B root 根治）。
- `_try_herald_side` reframe：建 letter 物件 + `_detach_one_anon`（從 mother 移 1 anon，deterministic lowest-tier 先，**sunk cost 不 recall**＝真成本自限，mini-util 已計 ANON_COST）+ payload=origin 自己 food need snapshot（`_snapshot_food_buy`：有真 food 買單帶走；無則 **runway-deficit synth**＝絕境門檻食量−effective_food＝genuine 真缺口非 fire-crank，match 舊 `_deposit_help_need` 註「無買單→proxy」意圖）。
- 新 tick step `_step_tick_letters`（sim_runner SYSTEMS 表 move entry 後）：每 letter → move 1hex/tick（PathSystem 真地形＝物理 delay）→ 抵 seat（`target_lord` co-located → `_deliver_letter_to_lord` deposit 進 lord.team_known order_buy；**lord 不在 → `_deliver_letter_to_board` register 進 seat outpost market_orders**（relayed=true、origin_tick 保 spawn→decay 起作用、Part1 read_market_board 接力領主留著等取）→ remove）/ timeout remove（`help.letter_timeout`）/ **敵 faction 隊在場攔截 remove**（`_letter_intercepted`：current_pos tile 有異 faction 隊＝物理零 RNG）。
- **de-team 清理**：刪死 `_tick_help_herald` + `_evaluate_subteam` help_call 分支 + 刪 obsolete `infonet_herald_lifecycle_bed`（診斷用途已了、refs 已刪函）。throttle 改 `_has_inflight_letter`（一隊一 in-flight letter）。**diplomacy envoy_proposal / player herald（TASK_HERALD 他用）不動**。

**A③ — `_resolve_help_target` = 最近自家 faction 固定 outpost（full 名冊）**
- iterate 全 tiles 挑 outpost_owner 屬同 faction、level>0、非 hidden、非自家、離 origin 最近（`# gate-ok` own-faction infra 位掃、position-only、同 `_faction_roster_pos` 正當性）。target_lord_id=faction leader（deposit 對象）、target_pos=該最近 seat。
- **治 mobile-lord**：lord 無自家 outpost 也能解（faction 有任一 seat 即可收信）。**solo（faction_id=-1）仍不解=正確**（無 lord 可求，走既有 flee/relocate；blueprint ratify）。

## 守（R² 對照）
- **感知鐵律**：letter payload=spawn 時 origin **自己** need snapshot（零 live god-view 讀 target 態）；名冊 target position-only（組織常識）；物理走 delay；攔截/timeout 物理零 god-view；`constitution_gate` 綠（A③ scan `# gate-ok`、letter 非 indexed 他隊 live 態）。
- **determinism**：move/攔截/timeout 全確定性；letter Array insertion-order 遍歷；tiles/teams_by_tile Dict/Array 插入序；**零新 randf**。→ 3-run byte-identical。
- **de-patch 非增殖**：herald 從「假裝 team」還原真實 in-transit 訊息物件（category error 家族正解）；**免 succession marker**（補丁閘味、blueprint 明否）；一次性 de-team 非 beast 式 4 處散 exemption。
- **genuine 非 crank**：side-dispatch mini-util（前批）不動；carrier 只換載體實現（team→letter 物件）、非動 fire 條件；synth payload=真 runway 缺口非 boost。
- **economy**：detach 1 pop 真成本；letter 空手不搬 resource。
- **★全量 tap**：`help.letter_dispatched`/`delivered`/`letter_timeout`/`letter_intercepted`/`need_deposited` + A③ `target_resolved`/`target_unresolved`。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| 新 `infonet_letter_test` | **17/17**（spawn 物件+detach/move 1hex/deliver-lord team_known/deliver-board relayed/timeout/敵攔截/A③ mobile-lord 解出） |
| infonet 全 bed | sideaction 6 / part2 4 / herald 4 / prop 5 / scout 4 / trade 3 / bootstrap 6 全綠 |
| headless | **0-new**（Team23 建設×2 + 弱目標 + 3 baseline asserts＝git stash 對照 3fcb3194 pre-existing、皆非新） |
| constitution_gate | **PASS sites=74 removed=0**（A③ tile-scan `# gate-ok`） |
| determinism | 3-run seed1337 1mo warring MD5 `06D9B76D98AEFAB2A54698F218FCDF89` **byte-identical** |

## 路（下一站）
1. **你 R²**（審：letter 非team 免 team 機具 / A③ 名冊 full / 感知鐵律 letter 零特權 / determinism / de-patch 非增殖）。
2. CLEAN → **我路 measurer re-measure on ★FACTION bed（症1 端到端）**：餓 resident 派信(`letter_dispatched>0`)→ letter 抵 seat deposit(`delivered>0`)→ 領主聞(team_known/board)→ distribute fire(`distribute.dispatch/food_delivered>0`)→ 糧真到 resident runway 回升。full-sim 無黑洞（letter delivered/timeout/intercepted 明確 tap 非消失）。
3. → QA 故事稽核。

**HOLD-warm 待你 R² verdict。** 一問供你裁：症1 FACTION bed 是否用既有 economy/§5 setup（lord+resident+固定 outpost），或需我先建新 bed？（spec 說「bed 換 economy/§5 faction setup」但未指名檔——若已有現成 measurer 用哪支、或要我產一支 seeded faction bed，你定我做。）
