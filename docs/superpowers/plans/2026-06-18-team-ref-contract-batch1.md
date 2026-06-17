# Team Ref 契約 批次1（立基 + 形態 A 轉換）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 立 team-ref 契約基建（`WorldState.require_team` + `invariants.md` 契約節），並轉換最乾淨的形態 A 站（納管集合迭代 / -1 已先檢的單 ref）—— 把純 dangling 的 `.get()+null` 自癒分支改 `require_team`。

**Architecture:** 依 spec `2026-06-18-team-ref-contract-design.md`。納管 team-ref（erase_team 維護的）保證 -1 或 live；`require_team(tid)` 對不存在 assert（debug 抓、release 剝離）。批次 1 只動「-1 不可能或已先檢」的純 dangling 站，行為等價（dangling 分支本不可達）。形態 B（-1 與 dangling 纏死的 combat_target 等）留批次 2。

**Tech Stack:** Godot 4.2.2 GDScript。閘 = `headless_test.gd`（`=== DONE ===`）+ `game_sim_multi.gd`（`_check_no_dangling_team_id` 維持 0、全 invariant 0、coin_eq=0）。

**前置（強制，依 `docs/process/03_implementer.md`）：**
```powershell
git worktree add .worktrees/team-ref-batch1 -b feat/team-ref-batch1
cd .worktrees/team-ref-batch1
```

**Baseline：** `headless_test.gd` → `=== DONE ===`；`game_sim_multi.gd` 全 invariant 0、coin_eq=0。

---

## File Structure

| 檔案 | 動作 |
|---|---|
| `scripts/data/world_state.gd` | Modify | 加 `require_team(tid)` |
| `docs/invariants.md` | Modify | 加「team ref 契約」節 |
| `scripts/debug/headless_test.gd` | Modify | 加 `_test_require_team` |
| `scripts/simulation/faction_ai_system.gd` | Modify | member/subteam 迭代 + order_target/parent 純 dangling 站轉 require_team |
| `scripts/simulation/{player_api_mapper,movement,subteam}_system.gd` | Modify | 同類純 dangling 站轉 |

> **明確不動**：`invariant_audit.gd` 的 `if t == null`（:31/50/51 等）—— 那是**懸空偵測器本身**，靠它抓違反，**絕不可改 require_team**。

---

## Task 1: require_team + 單元測試

**Files:** Modify `scripts/data/world_state.gd`（接在 `erase_team` 後）、`scripts/debug/headless_test.gd`

- [ ] **Step 1: 加 require_team**

`scripts/data/world_state.gd`：
```gdscript
# 解析「保證活」的 team ref（契約：納管 team-ref 非 -1 即指向活 team）。
# caller 須先處理 -1（語意上的「無」）再呼叫。不存在 = 不變量被破 → assert
# （debug 抓 bug；release 剝離 → 不崩，保 1000-tick 韌性）。
func require_team(tid: int) -> TeamData:
	assert(teams.has(tid), "require_team: Team%d 不存在（team-ref 不變量被破）" % tid)
	return teams[tid]
```

- [ ] **Step 2: 加單元測試 + 註冊**

`scripts/debug/headless_test.gd`：
```gdscript
func _test_require_team() -> void:
	var st := WorldState.new()
	var t := TeamData.new(); t.team_id = 7; st.teams[7] = t
	assert(st.require_team(7) == t, "存在 → 回該 team")
	# 不直接觸 assert crash（headless 會中止）；驗存在性前置即可
	assert(st.teams.has(7) and not st.teams.has(99), "require_team 契約：非 -1 須存在（99 不存在 → 不該呼叫）")
	print("[OK] _test_require_team")
```
註冊於 `_initialize()`：`_test_require_team()`。

- [ ] **Step 3: 跑 headless**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `[OK] _test_require_team`、`=== DONE ===`、無 `SCRIPT ERROR`。

- [ ] **Step 4: Commit**

```bash
git add scripts/data/world_state.gd scripts/debug/headless_test.gd
git commit -m "feat(state): require_team 契約存取函式 + 單元測試"
```

---

## Task 2: invariants.md 契約節

**Files:** Modify `docs/invariants.md`

- [ ] **Step 1: 加節**

在「資料模型不變量規則」節後加：
```markdown
## team reference 契約

team 之間的引用（`combat_target` / `order_target_id` / `parent_team_id` / `subteam_ids` / `faction.member_team_ids` / `faction.leader_team_id` / `team_known` / `team_discovered` 內元素）只准兩種狀態：
- `-1` = 語意上的「無」（合法，須顯式處理）
- 指向**保證存在**的 team（「指向已 erase 的 team」結構上不可能 —— `erase_team` chokepoint + `_check_no_dangling_team_id` audit 擔保）

**解析統一形狀**（納管 ref）：
```
if tid == -1:
    # ...「無」分支...
else:
    var t := state.require_team(tid)   # 保證活，不檢 null
```
- 納管 ref **不可**寫 `if t == null` 防 dangling（dangling 不可能；寫了 = 死碼/遮蔽 bug）。
- `require_team` 對不存在 assert（debug 抓、release 剝離）。
- **不納管**（照舊 `teams.get()` + null 處理）：玩家輸入 tid、`teams.keys()` 快照迭代期間可能已 erase、persons/tiles/factions 等非 team-ref lookup。
- 移除 team 一律走 `state.erase_team(tid)`（唯一 chokepoint，清光所有納管 ref）。
```

- [ ] **Step 2: Commit**

```bash
git add docs/invariants.md
git commit -m "docs(invariants): team reference 契約節"
```

---

## Task 3: member/subteam 迭代純 dangling 站轉 require_team

迭代 `faction.member_team_ids` / `subteam_ids`（每元素必活）內的 `teams.get()+null` → `require_team`。**只移除 null 那一個 clause**，其餘條件保留。

- [ ] **Step 1: 轉換**

各站把 `var t = state.teams.get(X)` + 緊接的 `if t == null ...` 的 **null clause** 改掉（X 來自 member_team_ids/subteam_ids 迭代）：

- `scripts/simulation/faction_ai_system.gd`：
  - `:1259-1260`：`var t = state.teams.get(tid)` / `if t == null: continue` → `var t = state.require_team(tid)`（刪 null 檢查行）。同樣 `:1270-1271`、`:1282-1283`（皆 `for tid in faction.member_team_ids` 迴圈內）。
  - `:466-467`：`if tid == f.leader_team_id: continue` 後 `var member_team = state.teams.get(tid)` → `var member_team = state.require_team(tid)`（若其後有 `if member_team == null` 則刪該 clause；無則僅換 get→require）。
  - `:709-710`：同理 `var mt = state.teams.get(mid)` → `require_team(mid)`，刪其後 null clause（保留其他條件）。
- `scripts/simulation/player_api_mapper.gd:614-615`：`for mid in f.member_team_ids:` 內 `var mt = state.teams.get(mid)` / `if mt == null: continue` → `var mt = state.require_team(mid)`（刪 null 行）。

> ⚠ **逐站讀** null 檢查是否含**其他條件**（如 `if t == null or t.xxx: continue`）→ 只刪 `t == null` 那半，保留其餘（改成 `if t.xxx: continue`）。`require_team` 已保證非 null。
> ⚠ **不碰** `invariant_audit.gd`（偵測器）。

- [ ] **Step 2: 跑 headless**

```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`、無 `SCRIPT ERROR`、faction 相關測試綠。

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "refactor(team-ref): member/subteam 迭代純 dangling 站走 require_team"
```

---

## Task 4: -1 已先檢的單 ref 站轉 require_team

`order_target_id` / `parent_team_id` 在 lookup **前已 `== -1` 先檢/return** 的站 → 其後 `.get()+null` 純 dangling → `require_team`。

- [ ] **Step 1: 轉換**

- `scripts/simulation/faction_ai_system.gd:819-824`：`:819 if team.order_target_id == -1: return` 已先擋 → `:821 var target = state.teams.get(team.order_target_id)` + `:822 if target == null:` 自癒（release+order=-1）整段 → 改：
  ```gdscript
  var target: TeamData = state.require_team(team.order_target_id)
  ```
  刪 `if target == null: TaskArbiter.release(team); team.order_target_id = -1` 自癒區塊（dangling 不可能）。
- `scripts/simulation/faction_ai_system.gd:484-486`：`:484 if sub.parent_team_id == -1: continue` 先擋 → `:486 var parent = state.teams.get(sub.parent_team_id)` → `require_team(sub.parent_team_id)`（刪其後 null clause 若有）。
- `scripts/simulation/faction_ai_system.gd:868-869`（`_evaluate_idle_subteam`）：`:869 var parent = state.teams.get(sub.parent_team_id)` → **先確認** sub.parent_team_id 在此必非 -1（caller 只對 subteam 呼叫；讀上下文）。若保證非 -1 → `require_team`；否則前置 `if sub.parent_team_id == -1: return` 再 require_team。
- `scripts/simulation/subteam_system.gd:74-77`：`:74 if sub == null or sub.parent_team_id == -1: return false` 先擋 → `:77 var parent = state.teams.get(sub.parent_team_id)` → `require_team(sub.parent_team_id)`（刪其後 null clause 若有）。
- `scripts/simulation/movement_system.gd:37-38`：**先讀** :36-38 確認 `order_target_id == -1` 是否已先檢。若是 → `:38 var target = state.teams.get(team.order_target_id)` → `require_team`；若否（-1 未先檢）→ **此站留批次 2**（屬形態 B）。

> 通則：lookup 前能保證 ref 非 -1（顯式先檢/return/continue）→ 轉 require_team + 刪 dangling 自癒。不能保證非 -1 → 留批次 2。

- [ ] **Step 2: 跑 headless**

Expected: `=== DONE ===`、無 `SCRIPT ERROR`。

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "refactor(team-ref): -1 先檢的單 ref 站走 require_team"
```

---

## Task 5: 回歸 + hand-back

- [ ] **Step 1: 全回歸**

```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
```
Expected: headless `=== DONE ===`、`[OK] _test_require_team`；multi `_check_no_dangling_team_id` 0、全 invariant 0、coin_eq=0、無 `SCRIPT ERROR`。**行為等價**（轉換站的 dangling 分支本不可達，移除無行為差異）。

- [ ] **Step 2: hand-back** `docs/superpowers/handbacks/2026-06-18-team-ref-contract-batch1.md`：
- 實作摘要：require_team + invariants.md 契約節 + 轉換站清單（每檔一行）。
- 驗證：headless 綠、全 invariant/懸空 0、coin_eq=0；轉換行為等價。
- 與 spec：批次 1（立基 + 形態 A）。`invariant_audit.gd` 偵測器明確未動。movement:38 若 -1 未先檢則留批次 2（註明）。
- 待主 session：批次 2（形態 B：combat_target 等 `-1 or not has` 纏死站逐站拆 -1/dangling）。

- [ ] **Step 3: Commit + push + 回報**

```bash
git add docs/superpowers/handbacks/2026-06-18-team-ref-contract-batch1.md
git commit -m "docs: team ref 契約 批次1 hand-back"
git push -u origin feat/team-ref-batch1
```
回報分支（finishing 選 Option 3，主 session merge）。

---

## Self-Review

**Spec coverage：** 實作 spec「推行」步驟 1（立基 require_team + invariants.md）+ 步驟 3 批次 1（形態 A）。形態 B 留批次 2（spec 已列）。納管 vs 不納管判準依 spec 清單。

**Placeholder scan：** 無 TBD。Task 4 movement:38 / faction_ai:869 附「先讀確認 -1 先檢，否則留批次 2」明確判準，非 placeholder。

**Type consistency：** `require_team(tid: int) -> TeamData` 為 WorldState 方法，呼叫端持 `state`。轉換通則一致（移除 null clause、保留其他條件）。`invariant_audit` 偵測器全程不動（跨 task 一致排除）。
