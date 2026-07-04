# Hand Back: Leader 繼承單一真值源

Branch: `feat/leader-succession`（已 push origin）
Spec: `docs/superpowers/specs/2026-06-19-leader-succession-single-source-design.md`
Plan: `docs/superpowers/plans/2026-06-19-leader-succession-single-source.md`

## 實作摘要

- `scripts/data/world_state.gd`：新增 `get_player_team_id() -> int`（player 所屬 team_id 單一源；player 死亡反查掛載 team）。
- `scripts/simulation/faction_ai_system.gd`：偵測點 gate 由 `leader_id==-1 and named非空` 改為純 `leader_id==-1` → 呼 `EventSystem.on_leader_death`（唯一偵測點）；刪 `_promote_successor` + `_handle_player_leader_death`；`_get_player_team_id` 改 delegate 到 WorldState。
- `scripts/simulation/player_command_system.gd`：`_get_player_team_id` 改 delegate；choose_heir stale-heir 終局改呼 `EventSystem.handle_player_succession`。
- `scripts/simulation/event_system.gd`：刪 `const COMMAND_SKILL_MIN`；`on_leader_death` 重寫（NPC 掃 named_members、**無統領門檻**、anon fallback、晉升後 `check_overflow_for_team`）；加 player 偵測分支（含冪等）+ public `handle_player_succession`。
- `scripts/simulation/encounter_system.gd`：`_check_player_wiped` 改呼 `EventSystem.handle_player_succession`。
- `scripts/simulation/health_system.gd`：註解更新（指向單一 owner）。
- `scripts/debug/headless_test.gd`：新增 9 個 `_test_succession_*` + `_test_world_get_player_team_id`；遷移既有 5 處 `_promote_successor`/2 處 `_handle_player_leader_death` test caller 到新 API。
- `docs/invariants.md`：新增「Leader 繼承單一 owner」節。
- `docs/known_issues.md`：E-1 繼承分叉標 ✅ 已修。

回歸閘：headless `=== DONE ===`、0 SCRIPT ERROR、0 assert fail、0 InvariantAudit 違反、conservation(coin_eq) 全綠、200-tick sim 無崩潰。

## 與 spec/plan 的差異（需確認）

1. **plan Task 4 Step 1 的 STOP 條件觸發**：plan 假設 `_handle_player_leader_death` 只有 faction_ai 內部引用，實際有 **2 個 production 外部 caller**（`encounter_system._check_player_wiped`、`player_command_system` choose_heir stale 終局）。經用戶裁定走「加 public 入口，全導向」：把 `_handle_player_succession` 改 public `handle_player_succession`，兩個外部 caller 直呼（繞過 `get_player_team_id` 自動偵測，避免死者 person 已 erase 時 misroute）。

2. **冪等性位置**：plan 把冪等檢查放 helper 內。改放 `on_leader_death` 的 player 偵測分支（安全網每 tick 重呼需冪等）；`handle_player_succession` 本身不帶冪等（external caller 要即時重評，否則 stale-heir 終局會被冪等短路、漏設 game_over）。行為對 plan 測試一致（兩次呼 `on_leader_death` 仍不重設）。

3. **player 測試 setup 修正**：plan 的 player 測試先 `s.persons.erase(player_leader)` 再靠 `on_leader_death` 自動偵測 → 但所有真實路徑呼 `on_leader_death` 時死者 person 尚在 `persons`（combat 在 erase 前呼、famine/encounter/安全網從不 erase）。原 setup 會讓 `get_player_team_id` 回 -1、player 分支不觸發（plan 內部矛盾）。改為不 erase player person（famine/安全網風格），符合 spec 設計與既有 `Death Task5` 測試的註明假設。

## 連動風險

- `npc_combat_system._kill_named_npc`：**未改**。它在 erase 死者前先呼 `on_leader_death`（順序正確），新邏輯相容。仍為戰中捷徑（非另一 owner），符合 invariant。建議主 session 確認此「捷徑 + 安全網」雙呼不會重複晉升（已驗：捷徑成功後 leader_id!=-1，安全網次 tick 不再觸發）。
- `player_command_system` choose_heir 終局：`handle_player_succession` 若 team 仍有非候選的活 named，會重 raise choose_heir（與舊 `_handle_player_leader_death` 行為一致）。屬既有語意，未變。
- **結構免疫（殲滅模型 A / 敗方 pop 損耗）= 藍圖 WHAT**：本 plan 範圍外。E-1 「弱隊殺不光」結構病灶仍在，僅修繼承分叉。單修繼承會回「named 工廠」死循環直到 anon=0 才滅團——需藍圖補 pop 損耗才真收斂（known_issues E-1 已記）。

## 待主 session 確認

- 上述差異 1/2/3 是否認可（尤其 public `handle_player_succession` 入口進 invariant）。
- `feat/leader-succession` 由主 session merge（未自行 merge main）。
