---
from: systems
to: implementer
status: consumed
topic: "[dispatch build game_setup faction-key robust(R²CLEAN+2澄清,spec=2026-08-05-gamesetup-faction-key-robust-HOW.md,blueprint裁(a),T3根治)·root:world_state:121 f.faction_id=_next_faction_id(sequential),game_setup:578 create_faction(int(t_cfg[id]))連回傳值都沒接=根本沒存,:585-586直接拿config faction_id當actual id用has(fid2)/set_team_faction(...,fid2)→亂配(Team1誤入Team2 faction/Team3 factionless)·fix:①:578改var actual_fid=state.create_faction(int(t_cfg[id]))+cfg_to_actual[fid]=actual_fid map②:585-586改if cfg_to_actual.has(fid2):set_team_faction(...,cfg_to_actual[fid2])用actual id(查不到沿舊靜默不指派factionless非新失敗模式)·★澄清①(硬守):只修:578/585-586真bug,:598/607 god-view seed是純config-only自比較(fa==config faction_id不碰state.factions/team.faction_id,同config→同actual map保證下config互比正確)=不需改別硬改(硬改可能查未建actual id引新bug)·★澄清②:conforming判準=leader出現順序跟config faction_id遞增一致(供measurer解讀非新驗證)·守:驗不破他bed(跑warring/economy/lord_distribution確認faction結構不變除infonet修正)/determinism純teams_cfg順序零RNG/scope=test-infra只game_setup.gd不碰create_faction engine/decision/faction_ai·branch續feat/info-network-whole·完HANDBACK to:systems我路measurer re-measure症1端到端(★T3也救活對稱T1仍救活+他bed不變)+warring 2seed→QA"
branch: feat/info-network-whole
---

# dispatch build — game_setup faction-key robust（R² CLEAN + 2 澄清、T3 根治）

**spec**：`docs/superpowers/specs/2026-08-05-gamesetup-faction-key-robust-HOW.md`（R² CLEAN）。**branch**：續 `feat/info-network-whole`。
**root**：`world_state:121 f.faction_id=_next_faction_id`（sequential）；`game_setup:578 create_faction(int(t_cfg["id"]))` **連回傳值都沒接=根本沒存**；`:585-586` 直接拿 config faction_id 當 actual id（`has(fid2)`/`set_team_faction(...,fid2)`）→亂配（Team1 誤入 Team2 faction/Team3 factionless）。

## 建什麼
1. **`:578`**：`state.create_faction(int(t_cfg["id"]))` → **`var actual_fid: int = state.create_faction(int(t_cfg["id"]))`** + **`if actual_fid != -1: cfg_to_actual[fid] = actual_fid`**（config faction_id → actual map）。
2. **`:585-586`**：`if state.factions.has(fid2) and state.teams.has(tid): set_team_faction(..., fid2)` → **`if cfg_to_actual.has(fid2) and state.teams.has(tid): set_team_faction(state.teams[tid], cfg_to_actual[fid2])`**（用 actual id）。查不到沿舊靜默不指派（factionless、非新失敗模式）。

## ★2 澄清（硬守）
1. **只修 `:578/585-586` 真 bug**。**`:598/607` god-view seed 是純 config-only 自比較**（`fa==config faction_id`、不碰 `state.factions`/`team.faction_id`）——同 config→同 actual（map 保證）下 config 互比**正確**、**不需改、別硬改**（硬改可能查未建 actual id 引新 bug）。
2. conforming 判準=「leader 出現順序跟 config faction_id 遞增一致」（measurer 解讀用、非本 build 驗證項）。

## 守（build 硬守）
- **★驗不破他 bed**：跑 warring/economy/lord_distribution bed 確認 faction 結構不變（除 infonet 修正）。
- **determinism 純 teams_cfg 順序零 RNG** + **scope=test-infra**（只 `game_setup.gd`、**不碰 `create_faction`[engine]/decision/faction_ai**）。

## 驗收（re-measure 症1 端到端 on persist bed、我路 measurer）
- **in-sim faction 結構=config 意圖**（T0/T1 同 faction、T2/T3 同 faction）。
- **★T3 也救活對稱**（T2 現真在 T3 同 faction→領主賑濟 T3→糧真到→runway 回升 alive_at_end、同 T1）。
- T1 仍救活 + distribute/deliver/food_delivered 保持 + 他 bed faction 不變 + determinism。

**完 → HANDBACK `to:systems` → 我路 measurer re-measure 症1 端到端（★T3 也救活）+ warring 2seed（平行）→ QA 故事稽核（回溯三因果+whole+T1/T3 救活故事+真給非賣）→ arc-done 判 → 推用戶驗收。** 卡 → 報 `to:systems`。
