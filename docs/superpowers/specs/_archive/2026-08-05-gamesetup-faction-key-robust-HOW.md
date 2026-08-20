# game_setup faction-key robust — HOW spec（config faction_id → actual id map）

**from**: systems | **status**: FINALIZED → reviewer R²（blueprint 裁 (a) GO） | **branch**: `feat/info-network-whole`（續）
**root（T3 診斷確認）**：`world_state.create_faction(leader_team_id)` 內 `f.faction_id = _next_faction_id`（**SEQUENTIAL 0,1,2…**、非 config faction_id 非 leader team id）。game_setup 非 leader（`:583-586`）用 **config faction_id** 查 `state.factions.has(config_fid)`——config faction_id vs 實際 sequential id **不一致** → 亂配。血證 `infonet_whole.json`：Team0→faction0、Team2→faction1（seq）；Team1(cfg fac1) `has(1)=TRUE` 誤入 faction1（=Team2 的）、Team3(cfg fac2) `has(2)=FALSE` factionless。
**WHAT 裁**：blueprint (a) robust——甲 correctness 修 infra、非 (b) config workaround 留地雷。game_setup=test-infra（constitution/感知不涉）。

## 修（game_setup：config faction_id → actual id map）
`game_setup.gd` 第二段（create factions）+ 第三段（非 leader 加入）：
```
# 第二段：create factions + 建 config faction_id → actual(sequential) faction id map
var cfg_to_actual: Dictionary = {}     # config faction_id → 實際 in-sim faction id
var seen: Dictionary = {}
for t_cfg in teams_cfg:
    var fid: int = int(t_cfg.get("faction_id", -1))
    if fid == -1 or seen.has(fid): continue
    seen[fid] = true
    if t_cfg.get("is_faction_leader", false):
        var actual_fid: int = state.create_faction(int(t_cfg["id"]))   # 回實際 sequential id
        if actual_fid != -1:
            cfg_to_actual[fid] = actual_fid                            # ★map config→actual
# 第三段：非 leader 用 map 查 actual id（非直接 config faction_id）
for t_cfg in teams_cfg:
    var fid2: int = int(t_cfg.get("faction_id", -1))
    if fid2 == -1 or t_cfg.get("is_faction_leader", false): continue
    var tid: int = int(t_cfg["id"])
    if cfg_to_actual.has(fid2) and state.teams.has(tid):
        state.set_team_faction(state.teams[tid], cfg_to_actual[fid2])   # ★用 actual id 入正確 faction
```
- **不動 `world_state.create_faction`（engine、in-sim 建國用）**——只改 game_setup（test-infra）的 config→actual 映射。
- ★**其餘用 config faction_id 的 game_setup 處**（如 god-view seed 同 faction 互 discovered）若用 config faction_id 比對 → 一併改用 actual id / team.faction_id（實際）。**掃 game_setup 全檔 config faction_id 用點、確保全用 actual**（避免同款殘留）。

## 守（reviewer R²）
- **★驗不破他 bed（blueprint 條件①）**：conforming bed（config faction_id 恰 == sequential 建序、如 0,1,2 依序）→ map 給同結果=neutral（byte-identical）；差者（infonet faction_id=1,2）→ 修正。跑既有 faction bed（warring/economy/lord_distribution）確認 faction 結構不變（除 infonet 修正）。
- **determinism 不變（條件②）**：map 純 teams_cfg 順序建、零 RNG。
- **scope=test-infra（條件③）**：只改 `game_setup.gd`（test setup）、**不碰 sim/decision/engine code**、constitution/感知鐵律不涉（faction 結構 setup 非決策讀值）。
- **無殘留 config-faction_id 直用**：掃 game_setup 全檔確保無其他「用 config faction_id 當 in-sim id」殘留。

## 驗收（re-measure 症1 端到端 on persist bed）
- **in-sim faction 結構=config 意圖**：T0/T1=同 faction、T2/T3=同 faction（tap faction membership 確認）。
- **★T3 也救活**（T2 現真在 T3 同 faction → 領主賑濟 T3 → 糧真到 → runway 回升、alive_at_end；同 T1）＝症1 對稱兩 resident 皆救活。
- 迴歸：T1 仍救活 + distribute/deliver/food_delivered 保持 + 他 bed faction 結構不變 + determinism。

**路 reviewer R²（審 config→actual map/驗不破他 bed/determinism/scope=test-infra/無殘留直用）→ CLEAN → build → re-measure 症1 端到端（★T3 也救活）+ warring 2seed（measurer 平行）→ QA 故事稽核（回溯三因果+whole+T1/T3 救活故事+真給非賣）→ arc-done 判 → 推用戶驗收。**
