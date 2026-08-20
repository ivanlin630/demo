# 資訊網 B herald 非team carrier + A③ 名冊 refine — HOW spec

**from**: systems | **status**: FINALIZED → reviewer R²（blueprint 全裁 GO） | **branch**: `feat/info-network-whole`（續）
**root（diagnostic 確認）**：B=herald team-carrier full-sim 黑洞（on_leader_death promote 1-pop 出 throwaway named=team-ness 副作用、full-sim team 互動吃掉 herald tick）；A=warring 求援 target 前置（solo-heavy 正確罕 fire；mobile-lord 名冊解不出）。
**WHAT 裁**：blueprint (B carrier + A 三點全 ratify)——信使=in-transit 訊息物件非 team=category error 家族正解歸位。

## B — herald 非team 輕 carrier（in-transit 訊息物件、免撞全部 team 機具）
### 新結構（net-new、非 team）
`state.in_transit_letters: Array[Dictionary]`，每封：
```
{origin_team_id, faction_id, target_lord_id, target_pos(seat), kind:"help",
 payload(distress:origin food need/買單 snapshot), current_pos, spawn_tick, timeout, speed}
```
**★非 state.teams 成員** → **免撞 succession/cull/subteam-routing/on_leader_death/combat-target/全部 full-sim team 互動**（B root 根治）。

### spawn（reframe `_try_herald_side:1534`）
- side-dispatch mini-util>0 → **建 letter 物件**（非 `_spawn_anon_herald` team）+ **detach 1 pop 從 mother anon**（真成本、自限）→ append `state.in_transit_letters`。
- payload = origin 的 food 買單 snapshot（simple distress、非複雜情報）。

### 新 tick step `_step_tick_letters`（sim_runner、置 move 後）
每封 letter：
1. **move toward target_pos**（1 hex/tick 或 speed、物理走=delay；PathSystem 真地形）。
2. **抵達 seat（current_pos==target_pos）→ 交付**：
   - **target_lord co-located at seat → deposit distress 進 lord.team_known**（reuse `_deposit_help_need`）→ `help.delivered` → remove letter。
   - **lord 不在 seat → register distress 進 seat outpost board**（`market_orders`、reuse `_register_on_board`-like；**領主不在也留著等取**、Part1 read_market_board 接力）→ remove letter。
3. **timeout（>budget）→ remove**（`help.letter_timeout`、pop 已耗=真成本）。
4. **★途中可死（守感知鐵律、determinism）**：current_pos tile 有**敵 faction 隊在場 → 攔截 killed**（`help.letter_intercepted`、物理攔截零 RNG、pop 已耗）→ remove。

## A③ — 名冊 refine：target=最近自家 faction 固定 outpost（full 名冊）
- `_resolve_help_target` **target_pos = 最近自家 faction 固定 outpost**（iterate faction **所有**固定 outpost via full 名冊、pick 離 origin 最近）——**非只 lord 自家 `_faction_roster_pos`**（治 mobile-lord：faction 有 seat 即可解）。
- 用戶定「成員知自家所有固定據點」做全：herald 目標=最近自家固定 outpost、信 deposit 在 seat、物理郵件到駐地。
- **warring solo（faction_id=-1）仍 target 不解=正確**（無 lord 可求、solo 絕境走既有 flee/relocate、blueprint ratify）。

## scope note（scout 保留、不動）
- **scout 現 full-sim 真 fire（35/40 含 info_returned）=working**——**本批不轉 carrier**（不修 working、measure-first）。若後續 scout 證 fragile→另批 unify carrier。**本批只 herald→carrier**（B root 在 herald）。

## 守（reviewer R²）
- **genuine 非 crank**：side-dispatch mini-util（前批）不動；carrier 只換 herald 的載體實現（team→letter 物件）、非動 fire 條件。
- **感知鐵律**：letter payload=simple distress（origin 自己 need）、名冊 target position-only 組織常識；物理走+delay；攔截/死=物理零 god-view；`constitution_gate` 綠（letter 非 indexed 他隊 live 態）。
- **determinism 零新 randf**（move/攔截/timeout 全確定性；letter 遍歷 deterministic order）。
- **economy/pop**：detach 1 pop 真成本；letter 不搬 resource（空手）。
- **★de-patch/unify 非增殖**：herald 從「假裝 team」→ 還原成真實 in-transit 訊息物件（category error 家族正解）；免 succession marker（補丁閘味、blueprint 明否）。

## 驗收（★re-measure on FACTION bed、症1 端到端）
- **bed 換 economy/§5 faction setup**（lord+resident+固定 outpost）——**症狀住的地方**（warring solo-heavy 非症1 場景）。
- **症1 端到端鏈**：`help.herald/letter dispatched>0`（餓 resident 派信）→ **letter 抵 seat deposit**（`help.delivered`>0）→ **領主聞（team_known/board）**→ `distribute.dispatch/food_delivered>0`（distribute util 0.659 已證會 fire）→ **糧真到 resident runway 回升**。
- full-sim 無黑洞（letter 有 delivered/timeout/intercepted 明確 tap、非消失）+ 人格分化保留 + determinism + Part1+3 不退 + economy 不爆。

**路 reviewer R²（審 letter 非team 免 team 機具/A③名冊 full/感知鐵律 letter 零特權/determinism/de-patch 非增殖）→ CLEAN → build（續 `feat/info-network-whole`）→ re-measure on faction bed（症1 端到端）→ QA 故事稽核（回溯三因果+whole、verdict ref）→ blueprint 對用戶驗收。**
