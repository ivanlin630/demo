# Hand Back: 單寫者 slice2 — driver-ledger + roster chokepoint

> plan `docs/superpowers/plans/2026-07-01-singlewriter-ledger-roster.md`。零行為變（純所有權重構）。

## 實作摘要

### Task 1 — Pattern B driver-ledger（真記）
- `world_state.gd`：加 static `driver_ledger`（ring-buffer, cap=4096 TEST VALUE）+ `driver_ledger_enabled`（**預設 off**）+ `record_driver(entity, field, delta, reason)` + `clear_driver_ledger()`。off 時只一次 bool 檢查 = 正常 run 零成本；on 時 bounded（超 cap `pop_front`）。
- 5 bank reason → `WorldState.record_driver`（現丟棄 → 真 append）：
  - `resource_bank.gd`：add/remove/set_amt/clear_all/adjust_person_coin
  - `anon_treasury_bank.gd`：deposit/withdraw/transfer/transfer_all/reset
  - `loyalty_bank.gd`：adjust/set_baseline
  - `outpost_owner_bank.gd`：set_owner
  - `unrest_bank.gd`：add/reduce/reset
- **sink 形式決策**：state 級 static（非 Probe 擴充）—— banks 是 static 無 state ref，static sink 是唯一能從 banks 觸達的形式。tick 溯源用 `driver_tick_hint`（sim_runner 開 ledger 時填；本 slice 未接線，off 時無意義）。

### Task 2 — roster chokepoint + bidir
- `world_state.gd`：`add_member(team, pid)` / `remove_member(team, pid, clear_team_id := true)`（`named_members` ↔ `person.team_id` bidir，類比 `set_team_faction`）。
- **收 pid（非 person 物件）**：多數 site 只持 id；`persons.get(pid)` 缺席容忍（null 不設 team_id）。
- **leader_id 語意 = 獨立**：chokepoint 只涵蓋 `named_members`；leader_id 賦值仍各 site 自理（晉升/繼承）。晉升 = named→leader，走 `remove_member(..., false)`（出 named 但仍屬本隊，team_id 不清）。
- **`clear_team_id=false` 三類**（離 named 但 team_id 不變）：晉升 leader、死亡留屍（famine，保 `get_player_team_id`）、轉隊時 team_id 已先設目標隊。

### Task 3 — 33 生產直寫 site 遷 chokepoint（逐檔零行為變）
- reaction_system(3)、health_system(1)、subteam_system(9)、event_system(1)、npc_combat_system(1)、encounter_system(1)、faction_ai_system(2)、game_setup(3)、player_command_system(4)、events/event_unrest_replace(1)、events/event_unrest_split(4)。
- 轉隊 site 拆成 `remove_member(src, pid, false)` + `add_member(dst, pid)`（team_id 由 add 設目標隊，淨值與原碼相同）。
- **未遷（2，明示豁免）**：
  - `beast_system.gd:30` `t.named_members = []`：全新 `TeamData` 欄位初始化（無 person、無 bidir 意義）= 建隊構造豁免。
  - `subteam_system.gd:_merge_into` 尾 `absorbed.named_members.clear()`：per-member `add_member` 後的 bulk 清空（人已轉、team_id 皆已=absorber）；等價逐筆 remove，保留 bulk 形式。
- **59 vs 33**：plan「59 site」含 `scripts/debug/*` 測試 fixture；spec §檔案 只列 production。測試 fixture 直建 state（無 bidir 契約需求）→ 不遷。production 全走 chokepoint。

### Task 4 — InvariantAudit roster bidir
- `invariant_audit.gd`：`_check_roster_bidir`（forward）——凡 `named_members`/`leader_id` 內 person，其 `team_id` 須回指本隊。單值 team_id → 亦擋「一人列兩隊」。

### 測試
- `headless_test.gd`：`_test_driver_ledger`（記錄/off 零記/ring-buffer bound/5 bank 各記）+ `_test_roster_chokepoint`（add/remove bidir/idempotent/false 保 team_id）+ `_test_invariant_roster_bidir`（正常綠 + named/leader 破口偵測）。

## 零行為變證
- headless（**權威 gate**）：`=== DONE ===`、無 `SCRIPT ERROR`、無新增 assert 失敗。
- coin 全池守恆 / Fief / W4 / 投靠(coin_eq) / framework 決策引擎 TC 皆 PASS（無 SCRIPT ERROR = 內部 assert 全過）。dedicated roster/ledger 三測綠。
- **pre-existing soft-fail**：`[FAIL] 弱目標未加入攻擊 goal`（faction_ai `_update_goals` 攻擊 belief 目標測）在**原 main 600abf0 即存在**（另建 worktree 實證），非本軌引入 → 零行為變成立。

## ★ 新 audit 揭露 pre-existing leader/named team_id desync（強制閘首個「可查對象」）
`game_sim_multi`（觀測性 InvariantAudit sampler，非 gating）本軌前後對比：
- **migrated**：merchant `Team0 leader P0 但其 team_id=11`（tick 7200→21600 persistent，1 項）；tyrant / warzone / game_sim_test **0 項**。
- **base（Task1/2/4 audit 在、migration 不在）**：merchant **同一** P0 desync（1 項）＋ tyrant **4 項**（`P3→16`、`leader P4011→18`、`P4→21`…）。
- **結論**：roster chokepoint **減少** desync（tyrant 4→0，named-transfer 現 add_member 同步 team_id）；migration 無辜。merchant `P0` 屬 **leader-team_id** desync，經**非 named-add 路徑**（leader 指派 / 非-chokepoint team_id 寫）產生 → 本軌 named_members chokepoint 覆蓋不到，故殘留。
- **這正是本軌目的**：第3不變量 audit 現有真實可查對象。root fix = 行為變（動 leader 指派或既有 team_id 寫路徑）→ **逾零行為變 scope，交系統 triage**。headless gate 仍 0（dedicated 測用乾淨 fixture；multi 揭示生產 sim 真髒）。

## 連動風險
- `sim_runner`：未接 `driver_tick_hint`。若主 session 要 ledger 帶真 tick → sim_runner 每 tick（或僅 `if driver_ledger_enabled`）填 `WorldState.driver_tick_hint = tick`。本 slice 未做（off 預設，tick 無意義；避動 hot path）。
- `AnonTierSystem` roster：anon 無 person entity，不經 named_members chokepoint（既有 cohort 入口自理）—— roster bidir 只管 named/leader。無連動。
- 反向 audit（person→roster）**未實作**：health famine「死亡留屍保 team_id」（蓄意，`health_system:219` 文件化）致 dead person `team_id!=-1` 卻不在任何 roster → 反向會誤報。forward-only 避免此誤報且仍擋核心 desync（roster entry 指錯隊 / 一人列兩隊）。若日後要反向，需先給 person 存活標記或清 dead team_id（動既有不變量，另議）。

## 待主 session 確認
- **設計決策**：ledger sink = state static（非 Probe）；`remove_member` 帶 `clear_team_id` bool；audit forward-only。三者皆 spec「開放細節（plan 定）」範圍內，已定並文件化，請確認納入 `invariants.md`（第3不變量 / roster 契約）。
- **建議後續**：
  - `driver_tick_hint` sim_runner 接線（若要真 tick 溯源）。
  - 反向 roster audit（需先解 dead person team_id 保留語意）。
  - `beast:30` / `subteam clear()` 兩豁免若要收進 chokepoint = 邊際收益，暫緩。
  - pre-existing `弱目標未加入攻擊 goal` FAIL（belief/targeting，非本軌）建議入 `known_issues.md`。
  - **★ leader-team_id desync（merchant/tyrant，audit 揭露）建議入 `known_issues.md` + 系統排查 root path**：leader 指派或非-chokepoint `person.team_id =` 寫，使 person 成某隊 leader 卻 team_id 指他隊。= 第3不變量待補的「leader 版單寫者」（本軌只做 named_members 版）。可能下一 slice：leader_id 亦走 chokepoint（`set_leader`）同步 team_id。
