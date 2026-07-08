# Hand Back: 單寫者 slice3 — leader desync 修 + ledger 接線 + 反向 roster audit

> branch `feat/singlewriter-slice3`;未 merge。plan = `plans/2026-07-01-singlewriter-slice3-leader-desync.md`。
> status: **open**（待系統 session 消費）。

## 實作摘要
- `scripts/data/person_data.gd`：加 `is_dead: bool` 留屍標記（反向 roster audit 跳過死者）。
- `scripts/data/world_state.gd`：加 `set_leader(team, pid, old_leader_action="none")` 統一 leader 指派 chokepoint——設 `leader_id` + `person.team_id`（**強制回指本隊，即使新 leader 曾持 stale team_id → 根修 desync**）+ `role="leader"` + 出 `named_members`；`old_leader_action="member"` 時舊 leader 降 named。mirror `add_member`/`set_team_faction`。
- `scripts/simulation/invariant_audit.gd`：`_check_roster_bidir` 加反向（person→roster）——凡活人 `team_id!=-1` 須在該隊 leader/named；`p.is_dead` 或 team 不存在則跳過。
- `scripts/simulation/sim_runner.gd`：`_step1_advance_time` 開 ledger 時填 `driver_tick_hint = current_tick`（off 跳，避 hot path）→ record 帶真 tick 溯源。
- leader_id 直寫 site 遷 `set_leader`：`event_system`（succession named + anon 晉升）/`event_unrest_replace`（"member" 舊 leader 降 named）/`event_unrest_split`（新團 leader）/`game_setup`（建國 ×3）。
- 留屍標記 site：`health_system`（餓死）+ `encounter_system`（戰死）標 `is_dead`。`npc_combat._kill_named_npc` **不標**（隨後 `persons.erase` → 屍不入 `state.persons`，反向 audit 看不到）。
- `scripts/debug/headless_test.gd`：加 `_test_set_leader_chokepoint` + `_test_invariant_reverse_roster` + `_test_driver_ledger` tick 斷言；`_test_invariant_audit` 離隊改走 `remove_member`（否則新反向 audit 誤報 test 設置殘 team_id）。

## 與 spec 的差異
- **spec 列 `person_generator`/`faction_ai(晉升)` 為 leader_id site，實查無直寫 `team.leader_id=`**：`person_generator.generate_for_team` 只設 `p.team_id`（不設 leader）；`faction_ai._dispatch_subteam_settle` 用局部 `sub_leader_id` → 走 `SubteamSystem.dispatch`（已同步 leader_id+team_id）。二者無需遷。succession anon 晉升的 `set_leader` 已涵蓋「generate_for_team + 升 leader」路徑。
- **scope 只列 `health_system` 留屍標記，實際 `encounter_system` 戰死也留屍入 `state.persons`** → 反向 audit 若不標會在 warzone 大量誤報。故 `encounter_system:1204` 加 1 行 `is_dead`（同結構屍體 pattern，非 scope 外新機制）。已驗 warzone 全窗 0 反向違反。
- **未碰** `player_command`（heir 繼任，非 scope 且已同步：heir ∈ named）、`combat_target` chokepoint（延）、`decision/*`、`faction_ai` 決策函數。

## 驗收（強制閘）
- headless：`=== DONE ===` 無 `SCRIPT ERROR`；`set_leader chokepoint OK` / `roster 反向 OK` / `roster 雙向 OK` / `driver-ledger OK`。
- coin_eq 全池 delta=0（4 配置）；framework S1-S6 全 PASS（DORMANT=0）。
- **game_sim_multi ×3 run 全配置 InvariantSummary（forward+反向 roster）=0**，含 warzone（戰鬥重負，驗 is_dead 屍體跳過正確）。

## 連動風險
- `invariant_audit`（forward+反向 roster）：任何**新**「person team_id 設但不入 roster、且未標 is_dead」路徑會觸反向違反。現存路徑已清（3× multi 全窗 0）。**新增轉隊/晉升/死亡路徑須：入 roster（add_member/set_leader）或標 is_dead**，否則反向 audit 抓。
- `set_leader` role 副作用：chokepoint 一律設 `role="leader"`。若未來有「暫代 leader 不改 role」需求需另設 flag（目前無此語意）。
- `is_dead` flag 目前**僅供反向 audit**；非通用存活模型。若他系統改用 is_dead 判活/死，須確認所有死亡路徑都標（現只 health/encounter；npc_combat 因 erase 未標）。

## 待主 session 確認
1. **文件更新（系統 owner）**：
   - `invariants.md`「資料模型不變量規則 2」：`leader_id` 賦值不再「各 site 自理」→ 改走 `set_leader` chokepoint（涵蓋 leader↔team_id）。「規則 3 roster 雙向」補反向（person→roster，is_dead 跳）。
   - `invariants.md` 三對稱不變量「所有權域」：slice2 揭的 leader/team_id desync **根修**（chokepoint 化）；driver_tick_hint 接線完成（ledger tick 溯源真）。
   - `known_issues.md`/統一矩陣 F-S3：merchant leader desync 條目 → 結構性關閉（chokepoint + 反向 audit 守）。
2. **merchant P0 desync=1 baseline 未在此環境重現**：game_sim_multi 無 seed（[[reference_multi_sanity_unseeded]]），3× 全跑 0 violations（含改前 baseline 亦 0）。desync 為間歇性/依 RNG。本 slice 提供**結構保證**（chokepoint 強制 team_id 同步 + 反向 audit 常駐監控），非復現單一 case。若系統要確定性復現，需 seeded 場景（backlog）。
3. **pre-existing FAIL（非本 slice）**：headless `[FAIL] 治療目標未加入戰鬥 goal` 在改前 baseline main 已存在，與本 slice 無關，未動。
4. **後續 slice**（plan 明列，延）：`combat_target` chokepoint（means-end 征服路徑定後綁 BEG/JOIN）、tile-granary-bank / tile.resources bank。
5. **merge 序**：與 means-end 並行同碰 `faction_ai` 不同函數（本 slice 實查 faction_ai **未改**；means-end 碰 `_decide_unified`/攻擊）→ 無實際衝突，但 `event_system`/`game_setup` 若 means-end 也動需序解。
