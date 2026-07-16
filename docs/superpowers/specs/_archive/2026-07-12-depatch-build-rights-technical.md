# de-patch 建造權：faction-leader-team-only → outpost-owner-team（技術 spec）

> 願景/WHAT = 用戶裁定（blueprint `defarm-depatch-spec`，R② premise CLEAN）。絕境經濟死鎖結構根：獨立隊/非leader成員隊擁 outpost 卻無建造評估 → 無農場 → 餓死。
> 真根（reviewer R² 細化）：非「faction-only」而是 **faction-leader-team-only**——`_evaluate_infrastructure` 只評 `faction.leader_team_id` 自己的 outpost。**呼叫端遍歷結構改**，非內部加 if。

## 真根精確（file:line）
- `_evaluate_all_body:626` `for fid in state.factions` → `_evaluate_infrastructure(state, f)`（:642，每 INFRA_INTERVAL=50h）。
- `_evaluate_infrastructure:2710` 讀 `faction.leader_team_id`→leader_team，內部所有 tile 掃只認 `tile.outpost_owner == leader_team.team_id`（:2723 升級 / :2741 擴建）。
- ∴ 評估對象 = **每 faction 的 leader team 一隊**。獨立隊（不在任何 faction）+ faction 非 leader 成員隊（自有 crude camp outpost）**皆漏評** = 潛伏 bug，本次 de-patch 順修。

## WHAT（用戶裁定，固定不可變）
1. **全開**建造權（outpost 建/升級/8 設施，非只 farm）：判準 faction → **「隊擁有該 outpost」**。
2. **範圍鎖**：只解**自己 outpost** 的建造權（`tile.outpost_owner == builder_team.team_id`），非任意隊對任意 outpost 動工（占領邏輯不動）。
3. martial 獨立隊（military outpost→farming 永禁）**本輪不修**，留下輪。
4. crude camp（免費/任何隊/既有）不動——零 outpost 隊拿第一個 outpost 的入口。
5. 第二個以後 outpost 選址（`_evaluate_new_outpost_location:2568`）原封繼承。

## HOW

### §1 遍歷結構改（核心）——faction 迴圈 → outpost-owner-team 遍歷
`_evaluate_all_body` 現況在 faction 迴圈內以 `f.leader_team_id` 單隊評 infra。改為**遍歷所有擁 outpost 的 team**（獨立 + faction 成員含非 leader）。

**新結構**（`_evaluate_all_body` 內，取代 :641-642 的 faction-scoped infra call）：
```
# INFRA cadence：建 owner→tiles 索引一次，遍歷擁 outpost 的 team
if state.world.current_tick % INFRA_INTERVAL == 0:
    var owner_tiles: Dictionary = _build_owner_outpost_index(state)   # {team_id: [HexTileData]}
    for owner_tid in owner_tiles:                                     # 穩定序（見 §5）
        var builder: TeamData = state.teams.get(owner_tid)
        if builder == null: continue
        _evaluate_infrastructure(state, builder, owner_tiles[owner_tid])
```
- **移出 faction 迴圈**（不再 per-faction，改 per-owner-team）。faction 迴圈內其餘（member_snap/update_goals/assign_tasks/diplo/betray）不動。
- `_build_owner_outpost_index(state)`：掃 `state.world.tiles` 一趟，`tile.outpost_level>0 && tile.outpost_owner!=-1` → 累進 `{owner: [tile]}`。**一趟 O(tiles)**，取代原「每 faction 各掃全 tiles」（見 §4 perf）。

### §2 `_evaluate_infrastructure` 重構：`(faction)` → `(builder_team, owned_tiles)`
簽名改 `_evaluate_infrastructure(state, builder_team: TeamData, owned_tiles: Array)`。內部 `leader_team` 全改 `builder_team`；tile 掃改**只走 `owned_tiles`**（非 `for tile_id in state.world.tiles`）：
- **(1) 升級既有 outpost**（原 :2721-2728）：`for tile in owned_tiles`（已保證 owner==builder），去掉 `if tile.outpost_owner != leader_team.team_id: continue`。
- **(2) 擴建設施**（原 :2731-2770）：`for tile in owned_tiles`。**移除同-faction-成員 outpost 的跨隊評估**（:2741-2743 那段 `owner_team != leader_team && same faction` 邏輯）——因每隊現自評自己 outpost（範圍鎖#2），不再由 leader 代評成員 outpost。**保留** owner 在場就地開工 / resident 出工 / `_dispatch_facility_builder`（labor 機制不變，只是決策者改成 owner 自己）。
- **(3) 蓋新 outpost**（原 :2771-2793）：govern-accumulate + `_evaluate_new_outpost_location` + `_dispatch_builder` 照舊（選址邏輯#5 不動），對象改 builder_team。
- player leader skip（:2716-2718）：改判 `builder_team.leader_id == state.player_id`。
- `_pick_outpost_type:2689` 的 `_faction_has_workshop`：獨立隊 faction_id=-1 → 該函式 :2706 已 `&& leader_team.faction_id != -1` 守，回 false → 獨立隊只憑手上 tools 判軍/民（既有正確，不動）。

### §3 owner→tiles 索引（§1 helper）
`_build_owner_outpost_index`：純掃 tiles 建 dict，**無狀態、每 INFRA tick 重建**（避免增量維護的失效風險；INFRA_INTERVAL=50h 頻率低，一趟掃可接受）。不改 `OutpostOwnerBank`（它只設 scalar，無索引，維持）。

### §4 perf guard（O(N²) 敏感，known_issues LOD）
- 原成本：per-faction(~8) × 全 tiles 掃 ×2。新成本：owner 索引一趟 O(tiles) + per-owner-team × **自有 tiles**（多數隊 1-2 outpost，非全 tiles）→ **總 tile 訪問量 ≈ O(tiles + Σ owned) ≈ O(tiles)**，比原「8×tiles」**更省**（原每 faction 重掃全 tiles）。擁 outpost 隊數雖增（獨立隊納入），但每隊只掃自有 → 不放大。
- **stagger 免同 tick 尖峰**：現況所有 faction 同一 INFRA tick 評。隊數增後仍同 tick 全評 → 集中。**可選** stagger：`if (current_tick + builder.team_id) % INFRA_INTERVAL == 0` 分散（決定性）。**本 spec 標為 SHOULD**（先無 stagger 上，measurer 量 infra phase 尖峰,超標再加 stagger，避免過早最佳化）。

### §5 determinism（硬約束）
- owner 索引遍歷須**穩定序**：`owner_tiles` 用 `state.teams` 既有插入序 filter，或對 owner_tid 排序後遍歷。**選 team_id 升序遍歷**（`owner_tiles.keys()` 排序）→ 跨 run byte-identical，不依賴 dict hash 序。
- `_build_owner_outpost_index` 掃 `state.world.tiles`（既有固定 key 序）累進 → tile 列表序穩定。
- **零 randf 新增**。dispatch/扣款走既有 deterministic 路徑（reviewer 審查點#3：扣款走 TeamData 自身欄位，無 faction 池依賴）。

### §6 不動範圍（重申，禁碰）
成本（OUTPOST_COST/FACILITY_DEF cost）、slot（FACILITY_SLOTS）、地形（required_terrain）、allowed_outpost 型別（**farming civilian-only 不變**）、crude camp 免費機制 + is_military 判定、INFRA_INTERVAL(50h)、選址（`_evaluate_new_outpost_location`）。

### §7 行為變 watch（measurer 驗，非 bug）
- **faction 成員自建**：非-leader 成員 outpost 現由 owner 自評（原 leader 代評/漏評）→ faction outpost 開發更分散/更多。驗**非 regression**（faction 據點發展不塌、不暴增亂蓋）。
- **獨立隊建農**：核心目標——獨立隊 civilian outpost farming_level 0→>0 → 食物脫 raw regen → 存活/建國率升。
- **outpost proliferation**：任何擁 outpost 隊可蓋第二個（#5 選址繼承）→ 驗 outpost 總數不失控（硬上限 OUTPOST_DENSITY_CAP 仍守，world-gen §2）。

## 驗收法（measurer 產數字，藍圖判）
1. **死鎖解**：default.json 12mo 深度——獨立隊 `farming_level` 從恆0 → 有隊 >0；established 從恆0 → 有隊立國；attrition 降、終局 pop 升（對照 pre-depatch baseline `worldgen_deep_reference.json`）。
2. **corroborate 死鎖**（平行，pre-build）：pre-depatch 獨立隊 farming_level 恆0 vs faction 隊 >0 × 存活差 + crude camp civ/mil 比例（型別閘實測，佐證 martial 隊本輪未解）。
3. **determinism**：同 seed byte-identical（含新遍歷）。
4. **perf**：infra phase 計時 ≤ 原級（§4；超標則加 §4 stagger）。
5. **faction 不回歸**：faction 據點發展數/established 不塌不暴增（§7）。
6. **融合閘**：constitution（sites 不增，OutpostOwnerBank 不動）/coin/framework/sanity 綠。

## 流程
- spec → **R②**（審遍歷結構設計健全 + determinism 穩定序 + perf 不放大 + §2 移除跨隊評估無漏 + 範圍鎖#2 只自 outpost）→ CLEAN → implementer 疊 worktree。
- measurer 平行 corroborate（驗收②，pre-build）+ build 後全驗收。
- 真根=faction-leader-team-only，遍歷結構為設計重點（reviewer 細化納入）。
