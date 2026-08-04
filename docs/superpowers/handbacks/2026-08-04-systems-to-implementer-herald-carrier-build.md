---
from: systems
to: implementer
status: consumed
topic: "[dispatch build herald非team carrier+A③名冊full(R²CLEAN,spec=2026-08-04-infonet-herald-carrier-HOW.md,blueprint全裁GO)·root B=anon-herald(leader_id=-1)進full-sim必被faction_ai:786-787 on_leader_death升named(event_system:57-63匿名晉升)吃掉信使意圖=team-ness根病·fix:B herald→state.in_transit_letters物件(非state.teams→免撞succession/cull/subteam/on_leader_death/combat全team機具,一次性de-team非beast式4處散exemption補丁):1 spawn reframe _try_herald_side:1534建letter{origin_team_id,faction_id,target_lord_id,target_pos(seat),kind:help,payload(origin food買單snapshot simple distress),current_pos,spawn_tick,timeout}+detach 1pop從mother anon(AnonTierSystem sunk cost自限)2新tick step _step_tick_letters(sim_runner置move後)每letter:move toward target_pos(PathSystem真地形delay)/抵seat→lord co-located則_deposit_help_need(:1486 reuse)進lord team_known否則register進seat outpost market_orders board(Part1接力領主留著等取)/timeout remove/敵faction隊在場攔截死remove(物理零RNG)3 payload=origin自己food買單(讀自己need非target live state)·A③_resolve_help_target target=最近自家faction固定outpost(iterate faction全員outpost_owner/outpost_level/faction_id挑最近,非只lord自家=治mobile-lord,solo仍不解正確)·scout保留不動(35/40 working)·守:感知鐵律letter零特權/determinism零新randf(move攔截timeout確定+letter Array insertion-order)/economy信使空手detach 1pop真成本/★全量tap(help.letter_dispatched·delivered·timeout·intercepted+A③target_resolved)·branch續feat/info-network-whole·完HANDBACK to:systems我路measurer re-measure on★FACTION bed(症1端到端)→QA"
branch: feat/info-network-whole
---

# dispatch build — herald 非team carrier + A③ 名冊 full（R² CLEAN、blueprint 全裁 GO）

**spec**：`docs/superpowers/specs/2026-08-04-infonet-herald-carrier-HOW.md`（R² CLEAN）。**branch**：續 `feat/info-network-whole`。
**root B**：anon-herald（`leader_id=-1`）進 full-sim **必被 `faction_ai:786-787 on_leader_death` 升 named**（`event_system:57-63` 匿名晉升）→ 吃掉信使意圖=team-ness 根病。

## 建什麼
### B — herald → `state.in_transit_letters` 物件（非 state.teams、一次性 de-team）
1. **spawn reframe `_try_herald_side:1534`**：mini-util>0 → 建 letter `{origin_team_id, faction_id, target_lord_id, target_pos(seat), kind:"help", payload(origin food 買單 snapshot=simple distress), current_pos, spawn_tick, timeout}` + **detach 1 pop 從 mother anon**（`AnonTierSystem` sunk cost、自限）→ append `state.in_transit_letters`。**不建 team、不 `_spawn_anon_herald`。**
2. **新 tick step `_step_tick_letters`**（sim_runner、置 move 後）每 letter：
   - **move toward target_pos**（`PathSystem` 真地形、delay）。
   - **抵 seat**：lord co-located → `_deposit_help_need(state, origin_id, lord)`（`:1486` reuse）進 lord team_known；lord 不在 → register distress 進 **seat outpost `market_orders` board**（Part1 read_market_board 接力、領主留著等取）→ remove。tap `help.delivered`。
   - **timeout** → remove（`help.letter_timeout`、pop 已耗）。
   - **敵 faction 隊在場（current_pos tile）→ 攔截死** remove（`help.letter_intercepted`、物理零 RNG）。
3. **payload=origin 自己 food 買單**（讀自己 need、非 target live state）。
- **★免撞全部 team 機具**（非 state.teams → 無 succession/cull/subteam/on_leader_death/combat-target）=B root 根治、**非 beast 式 4 處散 exemption 補丁**。

### A③ — 名冊 full（治 mobile-lord）
- `_resolve_help_target` target=**最近自家 faction 固定 outpost**（iterate faction 全員 `outpost_owner`/`outpost_level`/`faction_id` 挑離 origin 最近、**非只 lord 自家 `_find_own_outpost`**）。solo（faction_id=-1）仍不解=正確。

### scope
- **scout 保留不動**（35/40 working、measure-first 不修 working）。本批只 herald→carrier。

## 守（build 硬守）
- **感知鐵律 letter 零特權**：payload simple distress（自己 need）、名冊 position-only 組織常識、物理走+delay、攔截/timeout/死物理零 god-view。`constitution_gate` 綠。
- **determinism 零新 randf**（move/攔截/timeout 確定性、letter `Array` insertion-order 遍歷）。
- **economy**：信使空手（不搬 resource）、detach 1 pop 真成本。
- **★全量 tap**（[[feedback_full_transient_observability]]）：`help.letter_dispatched`/`delivered`/`timeout`/`intercepted` + A③ `target_resolved`——餵 measurer 驗症1 端到端。

## 驗收（★re-measure on FACTION bed、我路 measurer）
- **症1 端到端鏈**：`help.letter_dispatched>0`（餓 resident 派信）→ `help.delivered>0`（letter 抵 seat deposit）→ 領主聞（team_known/board）→ `distribute.dispatch/food_delivered>0`（distribute util 0.659 會 fire）→ **糧真到 resident runway 回升**。
- full-sim 無黑洞（letter delivered/timeout/intercepted 明確 tap、非消失）+ 人格分化保留 + determinism + Part1+3 不退 + economy 不爆。

**完 → HANDBACK `to:systems` → 我路 measurer re-measure on ★FACTION bed（economy/§5 setup lord+resident+固定 outpost、症1 端到端）canonical harness → QA 故事稽核（回溯三因果+whole、verdict ref）→ blueprint 對用戶驗收。** 卡 → 報 `to:systems`。
