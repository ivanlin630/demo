# Economy / Spam Fix 批次 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task.
> L2 批次（root cause 皆已調查定案，無 spec；背景見 `docs/known_issues.md` Bug2 / trade 殘餘 + handback 2026-06-11-task-arbiter）

**Goal:** 5 個小修：salary 量入為出（解 coin 負債）、trade partner 限居民團、diplomacy reject cooldown、equip churn 修根、P3 dead entry 清。

**Verified facts:**
- `salary_system.gd:28-65` `_pay_salary`：named loop（line 42）先、anon（line 60）後；ratio-loyalty 機制 line 50-59；負債只 unrest+1（line 63）
- `strategic_ai_system.gd:227` `_find_trade_partner` 回 `{ "team_id": int, "outpost_pos": Vector2i }` 或空 dict
- `diplomatic_ai_system.gd:65-94` `_send_diplomacy_message` → `handle_diplomacy_message` 回 "accept"/"reject"/"refuse"；主動發起在 `try_proactive_diplomacy`
- `equipment_system.gd:46` `[Equip]` print 只在 `equipped_count > 0` 時印 → ×1008 spam = **真實 equip churn**（每 tick 重複裝備），不是純 print 問題。根因待查（equip_order 振盪 or 裝備被每 tick 清除）
- `skill_system.gd:13` 殘留 `"P3_recruit"` mapping（P3 已刪）
- `FactionAISystem._is_resident_team(state, team)`（instance method）
- 測試跑法：`.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`；新 class 後先 `--import`

---

## 檔案結構

| 檔案 | 變更 |
|---|---|
| `scripts/simulation/salary_system.gd` | budget_ratio 量入為出 + coin floor 0 |
| `scripts/simulation/strategic_ai_system.gd` | `_find_trade_partner` 限居民團 tile |
| `scripts/simulation/diplomatic_ai_system.gd` | reject cooldown 7 天 |
| `scripts/data/team_data.gd` | 加 `diplomacy_reject_cooldown: Dictionary = {}` |
| `scripts/simulation/equipment_system.gd`（或churn根因檔）| 修 equip churn |
| `scripts/simulation/skill_system.gd` | 清 P3 entry |
| `scripts/debug/headless_test.gd` | ~7 測試 |

---

## Task 1: Salary 量入為出

**Files:**
- Modify: `scripts/simulation/salary_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 失敗測試**

```gdscript
func _test_salary_budget_ratio() -> void:
	print("--- EcoFix Task1a: 量入為出 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var team := TeamData.new(); team.team_id = 0; team.population = 5
	team.tags = ["軍隊"]
	var leader := PersonData.new(); leader.id = 1
	leader.values = { "義氣": 0.5, "信義": 0.5, "貪婪": 0.5 }
	state.persons[1] = leader; team.leader_id = 1
	var m := PersonData.new(); m.id = 2; m.team_id = 0
	m.skills = { "戰鬥": 0.5 }   # fair = 1.0
	state.persons[2] = m
	team.named_members = [2]
	# payroll = named (≈1.0) + anon wage；coin 只給一半
	var anon_total: float = AnonTierSystem.total_wage(team)
	var named_total: float = 1.0 * 2.0   # fair = sum(skills)*SALARY_PER_SKILL_POINT
	var payroll: float = named_total + anon_total
	team.resources = { "coin": payroll * 0.5 }
	var ss := SalarySystem.new()
	ss._pay_salary(state, team)
	var coin_after: float = float(team.resources.get("coin", 0))
	assert(coin_after >= -0.001, "coin 不得為負，實際=%.2f" % coin_after)
	assert(coin_after < 0.5, "錢應幾乎發光（按比例縮水發完），實際=%.2f" % coin_after)
	assert(m.coin > 0.0, "named 領到減額薪資")
	assert(m.loyalty < 0.0 + 1.0, "減薪 → 既有 ratio 路徑掉 loyalty")
	print("EcoFix Task1a OK")

func _test_salary_full_pay_unchanged() -> void:
	# coin 充足 → budget_ratio = 1.0，行為與舊版相同
	# ...
	print("EcoFix Task1b OK")
```

- [ ] **Step 2: 改 `_pay_salary`**

named loop 前先估 payroll、算 budget_ratio；named 薪資與 anon wage 都乘 budget_ratio：

```gdscript
func _pay_salary(state: WorldState, team: TeamData) -> void:
	if team.tags.has(TeamData.TAG_PRODUCE):
		return
	var is_player_team: bool = (team.leader_id == state.player_id and state.player_id != -1)
	var npc_salary_mult: float = 1.0
	if not is_player_team:
		var leader: PersonData = state.persons.get(team.leader_id)
		if leader != null:
			var honor: float = (float(leader.values.get("義氣", 0.5)) \
				+ float(leader.values.get("信義", 0.5))) / 2.0
			var greed: float = float(leader.values.get("貪婪", 0.5))
			npc_salary_mult = clampf(1.0 + (honor - greed * 0.5) * 0.4, 0.7, 1.3)
	# ── 量入為出：估總 payroll，coin 不足 → 全員按比例減薪（leader 主動緊縮，非賴帳）──
	var named_payroll: float = 0.0
	for pid in team.named_members:
		var p0: PersonData = state.persons.get(pid)
		if p0 == null: continue
		if _has_master_memory(p0, team.leader_id): continue
		named_payroll += (p0.salary if is_player_team else _calc_fair_salary(p0) * npc_salary_mult)
	var anon_total: float = AnonTierSystem.total_wage(team)
	var payroll: float = named_payroll + anon_total
	var coin_avail: float = maxf(float(team.resources.get("coin", 0)), 0.0)
	var budget_ratio: float = 1.0
	if payroll > 0.0 and coin_avail < payroll:
		budget_ratio = coin_avail / payroll
	for pid in team.named_members:
		var p: PersonData = state.persons.get(pid)
		if p == null: continue
		if _has_master_memory(p, team.leader_id): continue
		var fair: float = _calc_fair_salary(p)
		if not is_player_team:
			p.salary = fair * npc_salary_mult
		var paid: float = p.salary * budget_ratio
		var ratio: float = paid / maxf(fair, 0.01)
		team.resources["coin"] = maxf(float(team.resources.get("coin", 0)) - paid, 0.0)
		p.coin += paid
		if ratio >= 1.0:
			p.loyalty = minf(p.loyalty + (ratio - 1.0) * OVERPAY_BONUS, MAX_LOYALTY)
			var intensity: float = clampf((ratio - 1.0) * 0.5, 0.05, 0.8)
			_npc_ai.write_memory(p, "kindness", team.leader_id,
				state.world.current_tick, intensity)
		else:
			p.loyalty -= (1.0 - ratio) * SALARY_LOYALTY_PENALTY
	var anon_paid: float = anon_total * budget_ratio
	team.resources["coin"] = maxf(float(team.resources.get("coin", 0)) - anon_paid, 0.0)
	team.anon_treasury += anon_paid
	if budget_ratio < 1.0:
		team.unrest_turns += 1
		print("[Salary] Team%d 減薪 %.0f%%（coin 不足）" % [team.team_id, (1.0 - budget_ratio) * 100.0])
	print("[Salary] Team%d 薪水結算 coin=%.1f" % [team.team_id, float(team.resources.get("coin", 0))])
```

- [ ] **Step 3: 跑 + Commit**

```powershell
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
git add scripts/simulation/salary_system.gd scripts/debug/headless_test.gd
git commit -m "fix(salary): 量入為出 budget_ratio + coin floor 0 (Task 1)"
```

---

## Task 2: Trade partner 限居民團 tile

**Files:**
- Modify: `scripts/simulation/strategic_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_trade_partner_requires_resident() -> void:
	print("--- EcoFix Task2: partner 限居民團 tile ---")
	# Setup A: outpost 有 owner 但 tile 上無居民團 → 不選
	# Setup B: outpost tile 上有 PRODUCE 居民團 → 選, outpost_pos 正確
	# ...
	print("EcoFix Task2 OK")
```

- [ ] **Step 2: 改 `_find_trade_partner`**

outpost 判定後加居民團 check（重用 FactionAISystem._is_resident_team 或 inline 同格 PRODUCE scan）：

```gdscript
func _find_trade_partner(state: WorldState, trader: TeamData) -> Dictionary:
	for tid in state.team_discovered.get(trader.team_id, []):
		var t: TeamData = state.teams.get(tid)
		if t == null: continue
		if t.faction_id != -1 and t.faction_id == trader.faction_id: continue
		for tile_id in state.world.tiles:
			var tile: HexTileData = state.world.tiles[tile_id]
			if tile.outpost_owner != tid: continue
			# W2 修正：tile 上要有居民團（村長）才派 — trader 到了才有人成交
			if not _tile_has_resident(state, tile): continue
			return { "team_id": tid, "outpost_pos": tile.tile_pos }
	return {}

func _tile_has_resident(state: WorldState, tile: HexTileData) -> bool:
	for rid in state.teams:
		var r: TeamData = state.teams[rid]
		if r.tile_pos != tile.tile_pos: continue
		if "生產" in r.tags: return true
	return false
```

- [ ] **Step 3: 跑 + Commit**

```powershell
git add scripts/simulation/strategic_ai_system.gd scripts/debug/headless_test.gd
git commit -m "fix(trade): partner 限 tile 上有居民團的 outpost (Task 2)"
```

---

## Task 3: Diplomacy reject cooldown

**Files:**
- Modify: `scripts/data/team_data.gd`
- Modify: `scripts/simulation/diplomatic_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_diplomacy_reject_cooldown() -> void:
	print("--- EcoFix Task3: reject cooldown ---")
	# Setup: A propose alliance to B, B reject → A.diplomacy_reject_cooldown[B] 設 7 天
	# 7 天內 try_proactive_diplomacy 再跑 → 不發 propose（grep print 數）
	# ...
	print("EcoFix Task3 OK")
```

- [ ] **Step 2: 加欄位 + 邏輯**

`team_data.gd`：
```gdscript
var diplomacy_reject_cooldown: Dictionary = {}   # { target_tid: tick_until }
```

`diplomatic_ai_system.gd`：
- `try_proactive_diplomacy` 選定 target 後、發送前 check：
```gdscript
if state.world.current_tick < int(self_team.diplomacy_reject_cooldown.get(other.team_id, 0)):
	return   # 或 continue（依該函式結構）
```
- `_send_diplomacy_message` 收到 "reject"/"refuse" 回應後加：
```gdscript
const REJECT_COOLDOWN: int = WorldState.TICKS_PER_DAY * 7

if response == "reject" or response == "refuse":
	sender.diplomacy_reject_cooldown[target.team_id] = \
		state.world.current_tick + REJECT_COOLDOWN
```

- [ ] **Step 3: 跑 + Commit**

```powershell
git add scripts/data/team_data.gd scripts/simulation/diplomatic_ai_system.gd scripts/debug/headless_test.gd
git commit -m "fix(diplomacy): reject 後 7 天 cooldown 同對象 (Task 3)"
```

---

## Task 4: Equip churn 修根

**Files:**
- Modify: 依診斷（equipment_system.gd / faction_ai_system.gd）
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 診斷**

`[Equip] Team9 裝備 melee_low ×N` 在 multi 出現 1008 次 = **每 tick 真的在重新裝備**，不是 print 問題。可能根因：
- `_update_equip_order`（faction_ai）每輪重算 equip_order 在兩值間振盪（target 0↔1）
- 或某系統每 tick 清 `p.equipment["hand_1"]`（grep `equipment["hand_1"] = ` 找清除點；encounter `_return_pool_equipment` 是已知歸還點，確認是否被誤呼叫）

加暫時 debug print 跑 `game_sim_test` 200 tick 觀察 Team 裝備流向，找出循環來源。

- [ ] **Step 2: 修根因**

依診斷結果修（振盪 → equip_order 加 hysteresis 或只在變化時重算；誤清除 → 修清除條件）。**不接受純 diff-print 掩蓋**——除非診斷證明 churn 是合理行為（如武器在 named 間每 tick 輪轉屬預期），才退而 print 降頻。

- [ ] **Step 3: 驗證**

```powershell
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_test.gd > godot_test.log 2>&1
Get-Content godot_test.log | Select-String "\[Equip\]" | Measure-Object | Select-Object Count
```
預期：90 天 [Equip] 次數降到合理量級（裝備變動才印，< 100）。

- [ ] **Step 4: Commit**

```powershell
git add -A scripts/
git commit -m "fix(equip): 修 equip churn 根因 (Task 4)"
```

---

## Task 5: P3 dead entry 清 + 整合 + handback

**Files:**
- Modify: `scripts/simulation/skill_system.gd`
- Create: `docs/superpowers/handbacks/2026-06-12-economy-spam-fixes.md`

- [ ] **Step 1: 清 P3**

`skill_system.gd:13` 附近 `"P3_recruit"` mapping 刪除。grep 確認無其他 P3 殘留：
```powershell
grep -rn "P3_recruit" scripts/
```

- [ ] **Step 2: 跑全測試 + multi**

```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_test.gd > godot_test.log 2>&1
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd > godot_multi.log 2>&1
Get-Content godot_multi.log | Select-String "min_coin|減薪|Market|propose" | Select-Object -Last 20
```

驗收：
- multi 4 config min_coin **≥ 0**（baseline -57）
- 減薪 print 出現（窮團隊緊縮）
- Diplomacy 同對象連發消失（reject 後 7 天靜默）
- [Equip] 次數量級下降
- ALL INVARIANTS PASSED

- [ ] **Step 3: handback + Commit**

```markdown
# Hand Back: Economy / Spam Fixes

## 實作摘要
[5 task 各檔變更]

## 行為變化
- min_coin：[baseline -57 → 實測]
- 減薪事件次數 / Diplomacy propose 次數對比 / [Equip] 次數對比
- equip churn 根因：[診斷結果]

## 驗證
[headless + invariants + multi]

## 待主 session 確認
- 減薪 unrest 累積速度
- equip churn 根因處置是否合意
```

```powershell
git add docs/superpowers/handbacks/2026-06-12-economy-spam-fixes.md
git commit -m "docs: economy/spam fixes handback (Task 5)"
```
