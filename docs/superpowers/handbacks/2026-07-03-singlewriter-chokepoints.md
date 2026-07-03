# Hand Back: 單寫者收齊 B — chokepoint 掃收（S5/S6/S9/S11/S12）
> Status: consumed（2026-07-03 merged,系統收編）

branch: `feat/singlewriter-chokepoints`（3 commits + 本 handback）
spec/plan: `2026-07-03-singlewriter-chokepoints-{design,}.md`

## 實作摘要

world_state.gd 立 5 新單寫者 chokepoint，全直寫站點收編，各附 CI-scan grep pattern（強制閘地基）。

### 改檔（每檔一行）
- `scripts/data/world_state.gd`：新增 `create_team`(S9)、`set_team_tags`/`add_tag`/`remove_tag`(S5)、`set_readiness`/`set_solo_intent`(S6) 六個 chokepoint（reason 參數 → `record_driver`）。
- `beast_system.gd`：teams 建立→create_team；tags/faction_id→chokepoint。
- `game_setup.gd`：3 建隊站→create_team；player/gen/explicit tags→set_team_tags；explicit faction_id→set_team_faction。
- `manpower_system.gd` / `population_system.gd` / `reaction_system.gd`：breakaway/overflow/solo-exile 建隊站→create_team + tags + faction_id chokepoint。
- `events/event_unrest_split.gd`：split 建隊→create_team + tags + faction_id。
- `events/event_tag_shift.gd`：5 tags shift→add_tag/remove_tag（load-bearing 軍隊/生產/流亡）。
- `events/event_faction_defect.gd`：defect:21 faction_id→clear_team_faction（**單獨 commit**，見下）。
- `faction_ai_system.gd`：tags 站（統領/subteam/紮營/起義流亡）→chokepoint；`_set_solo` 升格呼 `set_solo_intent`。
- `interaction_system.gd`：settle/convert-resident/envoy-orphan tags→chokepoint；recovery readiness→set_readiness。
- `subteam_system.gd`：subteam 建立→create_team + set_team_tags + set_readiness；merge tags→chokepoint。
- `recruit_tutorial.gd`：teams 建立→create_team（**順修漏 init known/discovered desync 病例**）。
- `sim_runner.gd`：beggar reputation→update_reputation（S12，等價 clampf）。
- `docs/known_issues.md`：記完成 + 殘量 + stale-spec 校正。

### commit 結構
1. `feat(single-writer)`：S9/S5/S6/S11-construction/S12 純 refactor 全站點。
2. `refactor(single-writer)`：event_faction_defect:21 單獨（審計用，見 stale-spec）。
3. `docs(known_issues)`。

## 驗收證據
- **pointwise CLEAN**：seeds 1337/42/7 × 3 月，`total_diffs=0`，三 seed 逐點相同 = 行為位元不變。
- **直寫殘量 grep=0**：S5 tags / S6 readiness / S6 solo_intent / S12 reputation 全 0（除 chokepoint 檔自身 + 下列平行豁免）；S11 唯一殘 defect:21 已於 commit 2 收。
- **回歸**：headless `=== DONE ===`、0 SCRIPT ERROR、1 FAIL（`弱目標未加入攻擊 goal` = pre-existing 容忍）；framework **7/7 PASS 0 DORMANT**；InvariantAudit faction/subteam/roster **全 OK（0 violation）**；coin g1a `coin_delta=200` OK；multi sanity 4 config **0 dangling faction violation**。

## 與 spec 差異（★ 需系統確認）

### 1. defect:21 = stale-spec 誤標（非行為修，pointwise CLEAN）
spec/plan 標 `event_faction_defect:21` 為「懸空 member_team_ids 行為修，pointwise DIRTY 預期，單獨驗」。**實查證偽**：
- 現 code line 24 `clear_team_faction`（faction 存在健康路徑）**早已**處理懸空 member_team_ids。
- line 21 僅 **faction-missing 防禦路徑**：faction 不存在 → 無 member list 可懸空。`known_issues` 138/160 佐證 world_sim 0 violation = 防禦清理非 bug。
- 改走 `clear_team_faction`：faction 不存在時 `set_team_faction(t,-1)` 跳過 erase、僅設 faction_id=-1 → **語意等同原 `=-1` → 純 refactor**。
- → 無 DIRTY、無獨立行為修段。仍拆單獨 commit 供審計。既有「defect:21 待 systematic-debug」backlog 項可結（機制已明）。

### 2. create_team 刻意不含 tile 索引 / team_intel row（保 pointwise）
plan 描述 create_team 含「tile index 邀請 + intel row init」。**未納**：
- tile 索引由 `rebuild_team_tile_index`（每 `_step2_move`）重建；建立時預插會使新隊提前現身 `teams_on_tile`/`teams_within` 消費端 = 行為變（pointwise 風險）。
- team_intel row 由 `belief_system` lazy init 專屬。
- create_team 僅收 `teams[id]=` + `known/discovered=[]`（10 站點共同 pattern）→ 保 pointwise CLEAN。若系統要 create_team 兼管 tile 索引，須另評行為影響。

## 連動風險（主 session 決定是否補修）

- **`outpost_system.gd`（tags 5 站：342/343/369/372/375）+ `npc_combat_system.gd`（readiness drain 2 站：183/184）= 平行紀律豁免**：conquest-yield-chain 在飛同機改此二檔，禁碰以避 merge 撞。→ **該波 merge 後補收**（CI-scan pattern 已於 chokepoint 註記，屆時 grep 直接掃）。收前 S5/S6 殘量非 0（僅此二檔）。
- **`faction_ai_system.gd:3479` `known_reputations[cached_key]=owner_leader`**：cache **濫用 known_reputations dict**（string key `_cached_owner_leader_%d` 存 leader id，非 reputation float）。非 S12 對象、未動。建議獨立改名/搬專屬 cache 欄（語意污染 reputation dict）。
- **S6 未收殘欄（本波 scope 外，backlog）**：fatigue/work_morale/current_option/strategic_assignments/ambition_*（一次全收=diff 爆炸，spec 明列本波只收高風險 readiness/solo_intent）。

## 待主 session 確認
- defect:21 stale-spec 校正是否認可（我判純 refactor 已 merge 進 branch，pointwise CLEAN 佐證）。
- create_team 是否需擴充兼管 tile 索引（現刻意排除保 pointwise）。
- 平行豁免二檔（outpost/npc_combat）補收排入 conquest-yield-chain merge 後 backlog。
- faction_ai:3479 cache 濫用 → 是否開獨立小 task 改名。
