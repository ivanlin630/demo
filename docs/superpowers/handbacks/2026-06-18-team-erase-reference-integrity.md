# Hand-back：Team Erase 引用完整性（erase_team chokepoint + 無懸空 audit）

分支：`feat/team-erase-integrity`
Plan：`docs/superpowers/plans/2026-06-18-team-erase-reference-integrity.md`

## 實作摘要（每檔一行）

- `scripts/data/world_state.gd`：加 `erase_team(tid)` 單一 chokepoint — 一處清光母子 + faction(member/known_member_states/盟主解散) + 其他隊 int ref(combat_target/order_target_id) + dict 鍵(known_reputations/invite_cooldown/diplomacy_reject_cooldown/strategic_assignments) + registry(team_known/team_discovered 自身+交叉) + teams.erase。
- `scripts/simulation/faction_ai_system.gd`：`cleanup_extinct_teams`（滅團）改走 `erase_team`。
- `scripts/simulation/subteam_system.gd`：`_erase_absorbed_team`（合併）整個委派 `erase_team`。
- `scripts/simulation/beast_system.gd`：`_cleanup`（野獸）整個委派 `erase_team`。
- `scripts/simulation/encounter_system.gd`：`_massacre_residents`（屠村）改走 `erase_team`（**plan 漏列的第 4 條移除路徑**）。
- `scripts/simulation/invariant_audit.gd`：加 `_check_no_dangling_team_id`（combat_target/order_target_id/known_reputations/strategic_assignments/team_discovered）。
- `scripts/debug/headless_test.gd`：加 `_test_erase_team` 單元測試（int ref/dict 鍵/交叉/registry/子隊孤兒化全驗）。

## 驗證

- `headless_test.gd` → `=== DONE ===`，無 `SCRIPT ERROR`，`_test_erase_team` 綠。
- `game_sim_multi.gd` 4 config（game_sim_test/tyrant/merchant/warzone）：**懸空 team_id → 0**；既有 cohort/faction/subteam/population invariant 全 0、coin_eq delta=0 維持；無 `SCRIPT ERROR`。

## Plan 外發現（驗證階段才浮現）

1. **第 4 條 erase 路徑**：`encounter_system._massacre_residents` 屠村滅團，plan 只列 3 條（滅團/合併/野獸）。原手動清 faction 後 `teams.erase`，漏清其他隊的交叉 ref。已併入 chokepoint。
2. **`known_reputations` 鍵 overload**：除 `tid(int)→聲望` 外，`faction_ai_system.gd:2491,2501` 另存 String 快取鍵 `_cached_owner_leader_%d`。audit 原 `for k: if not teams.has(k)` 把 String 鍵當死 team → 餵 `%d` 產空字串假違反（warzone 取樣 11 例，顯示 `["", ""]`）。修：`known_reputations`/`strategic_assignments` 審查加 `k is int` 防護。
   - 註：`erase_team` 的 `o.known_reputations.erase(tid)` 只清 int tid 鍵；String 快取鍵（含已死 owner_id）為時限性無害殘留，會被覆寫/忽略，不檢（同 cooldown 死鍵哲學）。

## 連動風險 / 後續

- 「無懸空 team_id」現為真不變量 → 消費端靜默 `.get()+continue` guard 變**冗餘**，可後續 sweep 拆（改 assert 或刪）。本 plan **不動 guard**（先立不變量，deguard 另開）。
- cooldown dict（invite/diplomacy_reject）死鍵未檢（時限無害）。`known_reputations` String 快取鍵同未檢。
- `erase_team` 現為唯一生產 `teams.erase` 點（`world_state.gd` 內部除外；headless_test.gd 為測試 fixture，直接 erase 不影響不變量）。

## 與工作哲學

完成 reference integrity（單一入口 + audit），呼應「code 寫好就不靠 guard」——靠結構保證而非紀律。erase_team 同 `set_subteam_parent`/`set_team_faction` 雙向單一入口模式延伸。
