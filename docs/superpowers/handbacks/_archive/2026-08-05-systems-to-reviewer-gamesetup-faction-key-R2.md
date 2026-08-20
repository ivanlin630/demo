---
from: systems
to: reviewer
status: consumed
topic: "[R²審game_setup faction-key robust spec(2026-08-05-gamesetup-faction-key-robust-HOW.md,blueprint裁(a)GO)·root(T3診斷):world_state.create_faction(leader_team_id)內f.faction_id=_next_faction_id(SEQUENTIAL非config faction_id),game_setup:583-586非leader用config faction_id查has(config_fid)→不一致亂配(infonet Team0→faction0/Team2→faction1 seq,Team1 cfg fac1 has(1)=TRUE誤入faction1=Team2的,Team3 cfg fac2 has(2)=FALSE factionless)·fix(a)robust:game_setup建config faction_id→actual(sequential)faction id map(第二段leader create_faction回actual+存map),第三段非leader用map查actual id入正確faction·不動create_faction(engine in-sim建國用)只改game_setup(test-infra)·掃game_setup全檔其餘config faction_id用點(god-view seed同faction discovered等)一併改actual避殘留·★審點:①config→actual map正確(leader建序=actual,非leader map查)②★驗不破他bed(conforming bed config faction_id恰==sequential建序→map同結果neutral byte-identical,差者infonet修正;跑warring/economy/lord_bed確認faction結構不變除infonet)③determinism純teams_cfg順序零RNG④scope=test-infra只game_setup.gd不碰sim/decision/engine,constitution/感知不涉(faction setup非決策讀值)⑤無殘留config-faction_id直用(掃game_setup全檔)·CLEAN→build→re-measure症1(★T3也救活對稱)+warring 2seed→QA"
---

# R² 審 game_setup faction-key robust（blueprint 裁 (a) GO）

**spec**：`docs/superpowers/specs/2026-08-05-gamesetup-faction-key-robust-HOW.md`
**root（T3 診斷）**：`world_state.create_faction(leader_team_id)` 內 `f.faction_id=_next_faction_id`（**SEQUENTIAL、非 config faction_id**）；game_setup `:583-586` 非 leader 用 config faction_id 查 `has(config_fid)` → 不一致亂配（infonet：Team1 cfg fac1 誤入 faction1=Team2 的、Team3 cfg fac2 factionless）。
**WHAT 裁**：blueprint (a) robust——甲 correctness 修 infra。game_setup=test-infra。

## 一句話修法
game_setup 建 **config faction_id → actual(sequential) faction id map**、非 leader 用 map 查 actual id 入正確 faction。不動 `create_faction`（engine）。

## ★審點（R² refute checklist）
1. **config→actual map 正確**：第二段 leader `create_faction` 回 actual + 存 `cfg_to_actual[config_fid]=actual`；第三段非 leader `cfg_to_actual[fid2]` 查 actual 入正確 faction。確認映射邏輯對。
2. **★驗不破他 bed（blueprint 條件①）**：conforming bed（config faction_id 恰 == sequential 建序）→ map 同結果=**neutral byte-identical**；差者（infonet）修正。**跑 warring/economy/lord_distribution bed 確認 faction 結構不變**（除 infonet）。確認 conforming-neutral。
3. **determinism 不變（②）**：map 純 teams_cfg 順序建、零 RNG。
4. **scope=test-infra（③）**：只改 `game_setup.gd`、**不碰 sim/decision/engine**、constitution/感知鐵律不涉（faction 結構 setup 非決策讀值）。確認零 sim-code touch。
5. **★無殘留 config-faction_id 直用**：**掃 game_setup 全檔**（god-view seed 同 faction 互 discovered 等）——其餘用 config faction_id 比對處若有 → 一併改 actual id / `team.faction_id`。確認無同款殘留。

**CLEAN → 回 systems → build（續 `feat/info-network-whole`）→ re-measure 症1 端到端 on persist bed（in-sim faction 結構=config 意圖、**★T3 也救活對稱**、T1 仍救活、他 bed faction 不變）+ warring 2seed（measurer 平行）→ QA 故事稽核（回溯三因果+whole+T1/T3 救活故事+真給非賣）→ arc-done 判 → 推用戶驗收。** 卡/BLOCKER → 報 `to:systems`。
