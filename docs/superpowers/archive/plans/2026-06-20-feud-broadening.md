# A 類 feud 放寬 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:test-driven-development（每 Task 先寫失敗測試再實作）+ superpowers:executing-plans。Steps 用 checkbox 追蹤。

**Goal:** 血仇由「被侵害」本身形成（劫掠/吞併/屠/背叛），滅族 → faction 餘部繼承，嚴重度×個性 gate 避免噪音。把 G2 §5 血仇傳播做實。

**Architecture:** 集中單一形成點 `NpcAiSystem.form_feud`（severity × 個性 factor，FEUD_MIN gate）+ `spread_feud`（faction 餘部繼承）。現有 3 觸發（looted/extorted/betrayal）改走 gate；新增 subjugate 觸發 + 戰敗滅團/屠村擴散。複用 RelationGraph feud 邊、既有 memory、Probe，零新資料結構，不碰守恆。

**Tech Stack:** Godot 4.2.2 GDScript；`npc_ai_system.gd`（主）+ `npc_combat_system.gd` + `encounter_system.gd`（call sites）；headless + world_sim harness。

## Global Constraints

- wrapper 跑（UTF-8）：`.\tools\godot.ps1`。
- **只改關係邊 / goals，不碰資源 / coin / population / 守恆**。coin_eq 無關。
- 來源：`specs/2026-06-20-feud-broadening-design`、藍圖 ruling `2026-06-20-blueprint-to-systems-feud-scenarios-ruling`（A 類）。
- 回歸閘：headless 全綠、coin_eq=0、InvariantAudit 0。不用 multi drift。
- 全 severity / gate / spread 值 = TEST VALUE。
- 血親傳播**不做**（G2 無血緣邊，待 ④Trait/家族樹）；獨立團無餘部 = 仇隨滅消（可接受）。

## File Structure

- `scripts/simulation/npc_ai_system.gd`（const + `form_feud` + `spread_feud` static；`_write_relation_edge` 改走 gate；`_activate_goal` 轉 static）。
- `scripts/simulation/npc_combat_system.gd`（`_end_combat` 戰敗擴散 + `_try_subjugate` 吞併觸發/擴散）。
- `scripts/simulation/encounter_system.gd`（`_massacre_residents` 屠村擴散）。
- `scripts/debug/headless_test.gd`（gate / spread / subjugate 測試）。

---

### Task 1: form_feud gate + 現有 3 觸發改走 gate

**Files:**
- Modify: `scripts/simulation/npc_ai_system.gd`
- Test: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 寫失敗測試**（`_initialize()` 註冊 `_test_feud_gate()`）

```gdscript
func _test_feud_gate() -> void:
	print("--- A feud: severity×個性 gate ---")
	var sys := NpcAiSystem.new()
	# 高義氣受害 + massacre severity → 結深仇
	var honorbound := PersonData.new(); honorbound.id = 1
	honorbound.values["義氣"] = 0.9; honorbound.values["好戰"] = 0.5
	assert(NpcAiSystem.form_feud(honorbound, 99, 1.0, 10) == true, "高義氣+屠族應結仇")
	var e: Dictionary = RelationGraph.strongest(honorbound.relation_edges, "feud")
	assert(not e.is_empty() and e["target"] == 99, "應有對 99 的 feud 邊")
	# 寬厚受害 + 例行劫掠 severity → 放下（不結仇）
	var forgiving := PersonData.new(); forgiving.id = 2
	forgiving.values["義氣"] = 0.2; forgiving.values["好戰"] = 0.2
	assert(NpcAiSystem.form_feud(forgiving, 99, 0.35, 10) == false, "寬厚+例行劫掠應放下")
	assert(RelationGraph.strongest(forgiving.relation_edges, "feud").is_empty(), "不應有 feud 邊")
	# 自己不結仇自己
	assert(NpcAiSystem.form_feud(honorbound, 1, 1.0, 10) == false, "perp==self 應 false")
	print("feud gate OK")
```

- [ ] **Step 2: --import + 跑驗證失敗**（`form_feud` 未定義 → parse/assert 掛）

- [ ] **Step 3: 實作 form_feud + const**

`npc_ai_system.gd` 檔頭加 const：
```gdscript
# A feud：嚴重度×個性 gate。全 TEST VALUE。
const FEUD_BASE_FACTOR := 0.2
const FEUD_HONOR_W := 0.7
const FEUD_BELLIGERENCE_W := 0.4
const FEUD_MIN := 0.30
const FEUD_SPREAD_FACTOR := 0.6
const FEUD_SEVERITY := {
	"massacre": 1.0, "betrayal": 0.8, "subjugated": 0.5, "looted": 0.35, "extorted": 0.30,
}
```

加 static（`form_feud` + `spread_feud`，照 spec）：
```gdscript
static func form_feud(victim: PersonData, perp_id: int, severity: float, tick: int) -> bool:
	if victim == null or perp_id == -1 or victim.id == perp_id:
		return false
	var honor: float = float(victim.values.get("義氣", 0.5))
	var bell: float  = float(victim.values.get("好戰", 0.5))
	var factor: float = FEUD_BASE_FACTOR + honor * FEUD_HONOR_W + bell * FEUD_BELLIGERENCE_W
	var intensity: float = clampf(severity * factor, 0.0, 1.0)
	if intensity < FEUD_MIN:
		return false
	RelationGraph.add_edge(victim.relation_edges, "feud", perp_id, intensity, tick)
	_activate_goal(victim, "revenge", perp_id)
	Probe.bump("g2.feud_formed")
	return true

static func spread_feud(state: WorldState, victim_team: TeamData, perp_id: int, severity: float, tick: int) -> void:
	var fid: int = victim_team.faction_id
	if fid == -1 or not state.factions.has(fid):
		return
	var perp: PersonData = state.persons.get(perp_id)
	var perp_team: int = perp.team_id if perp else -1
	for tid in state.factions[fid].member_team_ids:
		if tid == victim_team.team_id or tid == perp_team:
			continue
		var t: TeamData = state.teams.get(tid)
		if t == null:
			continue
		form_feud(state.persons.get(t.leader_id), perp_id, severity * FEUD_SPREAD_FACTOR, tick)
```

`_activate_goal` 轉 static（現 instance，無用 self → 直接加 `static`）。確認其它 caller（`_trigger_goals`）仍能呼（GDScript 同 class static 可由 instance method 直呼）。

`_write_relation_edge` 的 feud 分支改走 gate（取代無條件 `add_edge` + `Probe.bump`）：
```gdscript
	match type:
		"betrayal", "looted", "extorted":
			NpcAiSystem.form_feud(p, subject_id, FEUD_SEVERITY.get(type, intensity), tick)
		"kindness", "aided_in_battle":
			RelationGraph.add_edge(p.relation_edges, "gratitude", subject_id, intensity, tick)
		"master":
			RelationGraph.add_edge(p.relation_edges, "protect", subject_id, intensity, tick)
```
> 注意：feud 的 `Probe.bump` 移進 `form_feud`（避免雙計）；gate 不過 = 不 bump（正確，未結仇）。

- [ ] **Step 4: --import + 跑驗證通過**（`feud gate OK`；既有 feud 相關測試對齊 gate——見 Step 5）

- [ ] **Step 5: 既有測試對齊**

grep 既有依賴「looted/betrayal/extorted → 必有 feud 邊」的測試。現改為 gate：若測試人物個性中庸（義氣 0.5/好戰 0.5），severity looted 0.35 × factor(0.2+0.35+0.2=0.75)=0.26 < 0.30 → **不再結仇** → 測試會掛。對齊：把該測試受害者個性設高義氣（如 0.9）使跨閾，或斷言改「視個性」。逐一修，不放寬 gate。

- [ ] **Step 6: 回歸 + Commit**
```
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected：`feud gate OK`、`=== DONE ===`、coin_eq=0、InvariantAudit 0。
```bash
git add scripts/simulation/npc_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(feud): 集中 form_feud gate(severity×個性)+現有觸發改走 gate"
```

---

### Task 2: 滅族擴散（戰敗 / 屠村 / 吞併）

**Files:**
- Modify: `scripts/simulation/npc_combat_system.gd`、`scripts/simulation/encounter_system.gd`
- Test: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 寫失敗測試**（`_test_feud_spread()`，註冊）

```gdscript
func _test_feud_spread() -> void:
	print("--- A feud: 滅族 faction 餘部繼承 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	# faction 0：victim team0(滅) + remnant team1（餘部）
	var victim := TeamData.new(); victim.team_id = 0; victim.faction_id = 0; victim.leader_id = 10
	var remnant := TeamData.new(); remnant.team_id = 1; remnant.faction_id = 0; remnant.leader_id = 11
	var rl := PersonData.new(); rl.id = 11; rl.values["義氣"] = 0.9; rl.values["好戰"] = 0.6
	state.teams[0] = victim; state.teams[1] = remnant; state.persons[11] = rl
	var fac := FactionData.new(); fac.faction_id = 0; fac.member_team_ids = [0, 1]
	state.factions[0] = fac
	# 加害方 perp leader 99（不同 faction）
	var perp := PersonData.new(); perp.id = 99; perp.team_id = 5
	state.persons[99] = perp
	NpcAiSystem.spread_feud(state, victim, 99, NpcAiSystem.FEUD_SEVERITY["massacre"], 10)
	var e: Dictionary = RelationGraph.strongest(rl.relation_edges, "feud")
	assert(not e.is_empty() and e["target"] == 99, "餘部 leader 應繼承對 99 的 feud")
	print("feud spread OK (餘部 intensity=%.2f)" % e["intensity"])
```

- [ ] **Step 2: --import + 跑驗證失敗**（spread 接線未上 → 此單測其實測 Task1 的 spread_feud；若 Task1 已加 spread_feud 函式，此測會過。改：本 Step 測 **call site** 接線——見下方真實接線測試）

> 修正：spread_feud 函式 Task1 已建。Task2 測**接線**：屠村/戰敗後餘部真的拿到仇。用 `_massacre_residents` 真路徑較重；可改直接斷言三 call site 各呼 spread。以下 Step 3 接線後，補一條經 `encounter._massacre_residents` 的整合測試（resident 有 faction 餘部 → 餘部得 feud）。

- [ ] **Step 3: 接線三 call site**

`encounter_system.gd._massacre_residents`（:1451 `erase_team` **前**）：
```gdscript
	NpcAiSystem.spread_feud(state, resident, attacker.leader_id, NpcAiSystem.FEUD_SEVERITY["massacre"], state.world.current_tick)
	state.erase_team(rid)
```

`npc_combat_system.gd._end_combat`（:237 looted 迴圈後）：
```gdscript
	# 戰敗 faction 餘部繼承（滅團=massacre 級，倖存=looted 級）
	var sev_key: String = "massacre" if maxi(loser.population - loser.wounded, 0) <= 1 else "looted"
	NpcAiSystem.spread_feud(state, loser, winner.leader_id, NpcAiSystem.FEUD_SEVERITY[sev_key], state.world.current_tick)
```

`npc_combat_system.gd._try_subjugate`（:510 `set_team_faction` **前**——抓 loser 原 faction 餘部）：
```gdscript
	# 吞併：loser leader 結仇 + 原 faction 餘部繼承（在 set_team_faction 前，否則 loser 已入勝方 faction）
	var loser_leader: PersonData = state.persons.get(loser.leader_id)
	NpcAiSystem.form_feud(loser_leader, winner.leader_id, NpcAiSystem.FEUD_SEVERITY["subjugated"], state.world.current_tick)
	NpcAiSystem.spread_feud(state, loser, winner.leader_id, NpcAiSystem.FEUD_SEVERITY["subjugated"], state.world.current_tick)
	state.set_team_faction(loser, fid)
```
> loser.faction_id 在 subjugate 進入時為 -1（:505 守衛 `loser.faction_id != -1 → return`）→ spread_feud 對 loser 自身 faction(-1) 無餘部 = 不傳（正確，獨立團被吞無餘部）。**保留接線**：未來 loser 有 faction 時自動生效，且語意一致。subjugate 的 `form_feud(loser_leader)` 是主效果。

- [ ] **Step 4: 整合測試**（經 `_massacre_residents` 真路徑驗餘部得仇）+ --import + 跑

- [ ] **Step 5: 回歸 + Commit**
```
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected：`feud spread OK`、`=== DONE ===`、coin_eq=0、InvariantAudit 0。
```bash
git add scripts/simulation/npc_combat_system.gd scripts/simulation/encounter_system.gd scripts/debug/headless_test.gd
git commit -m "feat(feud): 滅族 faction 餘部繼承(屠村/戰敗/吞併 call site)"
```

---

### Task 3: 回歸 + world_sim 重量 + 回報

**Files:** 無 code 改（跑 + 回報）。

- [ ] **Step 1: headless 回歸**（`=== DONE ===`、coin_eq=0、InvariantAudit 0、feud gate/spread OK）。

- [ ] **Step 2: world_sim 重量（2 年，seed 77）**
```
.\tools\godot.ps1 --headless --script scripts/debug/world_sim.gd
```
Expected：跑通無 SCRIPT ERROR；`[ProbeSummary]` 印；`g2.feud_formed` 對照前次（≈0）顯著上升；`g2.vendetta_trigger`（脫軌）連帶觀察；非全民世仇（gate 擋例行劫掠）。

- [ ] **Step 3: 回報 handback** `docs/superpowers/handbacks/2026-06-20-implementer-to-systems-feud-broadening.md`（`from: implementer / to: systems / status: open`）：
- gate/spread 單測結果。
- world_sim `[ProbeSummary]` feud_formed / vendetta 對照前次。
- feud 是否過量（噪音）或仍偏少（gate 太嚴）→ TEST VALUE 調整建議回報藍圖/系統。
- 異常（守恆 / 連帶戰爭過熱 / flaky）。

- [ ] **Step 4: Commit handback**
```bash
git add docs/superpowers/handbacks/2026-06-20-*feud-broadening*.md
git commit -m "docs(feud): A 類放寬 world_sim 重量回報(feud_formed 0→?)"
```

---

## Self-Review 註記

- **集中 chokepoint**：feud 形成唯一走 `form_feud`（gate 內建）→ 觸發集擴張只是加 call site，gate/severity 不散落。符合 RelationGraph「加型別=加 reader」精神。
- **守恆安全**：只動 relation_edges / goals（非資源/coin/pop）。coin_eq 無關。回歸驗 InvariantAudit 0。
- **gate = 反噪音**：FEUD_MIN 擋「公平交手/寬厚/例行劫掠」；severity 階梯讓屠族>背叛>吞併>劫掠。全 TEST VALUE，重量後依 feud 量調。
- **擴散在事件當下（erase 前）**：避免碰 fragile erase_team/extinct 延遲路徑；perp 當下已知。餘部 = 同 faction member team（非血親，符 ruling 暫定）。
- **行為非保留**：feud 變多 → 脫軌/戰爭增 = 預期（藍圖要世界活）。既有依賴「無條件結仇」的測試對齊 gate（Task1 Step5），不放寬 gate 遷就測試。
- **subjugate 順序坑**：spread 必在 `set_team_faction` 前（否則 loser 已轉勝方 faction，抓錯餘部）。已在 plan 標。
- **probe 不雙計**：`Probe.bump("g2.feud_formed")` 只在 `form_feud` 成功時，移出舊 `_write_relation_edge`。
- **與 #0b 並行無衝突**：本 plan 改 npc_ai/npc_combat/encounter；#0b 改 person_generator。無共用檔。各自 worktree branch，merge 順序無關（不同檔，naive merge 安全）。
