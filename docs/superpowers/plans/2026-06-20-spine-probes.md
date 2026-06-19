# 因果脊椎探針（Spine Probes）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 加兩層量測探針（時間軸取樣 + 跑完彙總）觀測 G1/G2/G3 + 既有功能行為，供 measure-first 平衡判斷。純觀測零行為變。

**Architecture:** `Probe` static 累計器（flag gated，事件點 1 行 bump，預設 off → 一般跑 no-op）。`SpineTrace` static 對 watched team/named 印分脊椎結構化行。Host = `game_sim_test.gd`（確定 7200-tick 全功能場景）。探針只讀+計數，不改遊戲 state。

**Tech Stack:** Godot 4.2.2 GDScript；`class_name Probe`/`SpineTrace`（新 → `--import`）；headless harness。

## Global Constraints

- wrapper 跑（UTF-8）；新 class_name 後 `--import`。
- **純觀測零行為變**：`Probe.bump`/`SpineTrace.dump` 只讀+計數，**禁改遊戲 state**（守恆/AI/決策不動）。
- **flag gated**：`Probe.enabled` 預設 `false` → 一般 headless_test/multi/正式跑全 no-op。只 game_sim_test 開。
- 來源：`specs/2026-06-20-spine-probes-design`。
- 回歸閘：(a) `headless_test` flag off **零行為變**（既有測試 0 變動）；(b) `game_sim_test` flag on 跑通無錯 + coin_eq/不變量維持 + `[G1]/[G2]/[G3]/[Named]/[ProbeSummary]` 出現且關鍵計數非零。不用 multi drift。

## File Structure

- `scripts/debug/probe_stats.gd`（新，`class_name Probe`：flag + counts + bump/note/summary/reset）。
- `scripts/debug/spine_trace.gd`（新，`class_name SpineTrace`：timeline dump G1/G2/G3/Named + named auto-pick）。
- 事件點鉤（各 1 行 `Probe.bump`，gated）：`scripts/simulation/` 之 `belief_system.gd`/`message_system.gd`/`faction_ai_system.gd`/`ambition_ladder.gd`/`order_system.gd`/`outpost_system.gd`/`encounter_system.gd`。
- `scripts/debug/game_sim_test.gd`（接線：enable/dump/summary）。

---

### Task 1: Probe 累計器（flag + bump + summary）

**Files:**
- Create: `scripts/debug/probe_stats.gd`
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Produces:
  - `Probe.enabled: bool`（static，預設 false）
  - `Probe.bump(event: String, n: int = 1) -> void`（gated；累加 counts）
  - `Probe.note(event: String, value: float) -> void`（gated；記峰值 max）
  - `Probe.reset() -> void`
  - `Probe.summary() -> void`（印 `[ProbeSummary]` 各計數 + 衍生率）

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_probe_accumulator() -> void:
	print("--- Probe 累計器 ---")
	Probe.reset(); Probe.enabled = true
	Probe.bump("g3.scout_dispatch")
	Probe.bump("g3.scout_dispatch", 2)
	Probe.bump("g3.scout_converge")
	Probe.note("g3.claim_peak", 5.0)
	Probe.note("g3.claim_peak", 3.0)
	assert(Probe.counts.get("g3.scout_dispatch", 0) == 3, "bump 累加")
	assert(Probe.counts.get("g3.scout_converge", 0) == 1, "bump 單")
	assert(Probe.peaks.get("g3.claim_peak", 0.0) == 5.0, "note 取 max")
	# gated：off → no-op
	Probe.enabled = false
	Probe.bump("g3.scout_dispatch")
	assert(Probe.counts.get("g3.scout_dispatch", 0) == 3, "off 不累加")
	Probe.reset()
	assert(Probe.counts.is_empty(), "reset 清空")
	Probe.enabled = false
	print("probe accumulator OK")
```
`_initialize()` 註冊。

- [ ] **Step 2: 跑 harness 驗證失敗**

Expected: `Probe` 不存在 → parse fail。

- [ ] **Step 3: 建 Probe**

`scripts/debug/probe_stats.gd`：
```gdscript
class_name Probe

# 量測累計器（純觀測）。enabled 預設 false → 一般跑 no-op；只 game_sim_test 開。
# 事件點插 1 行 Probe.bump(...)；結尾 Probe.summary()。禁改遊戲 state。
static var enabled: bool = false
static var counts: Dictionary = {}
static var peaks: Dictionary = {}

static func bump(event: String, n: int = 1) -> void:
	if not enabled: return
	counts[event] = int(counts.get(event, 0)) + n

static func note(event: String, value: float) -> void:
	if not enabled: return
	peaks[event] = maxf(float(peaks.get(event, 0.0)), value)

static func reset() -> void:
	counts = {}; peaks = {}

static func _rate(num_key: String, den_key: String) -> String:
	var den: int = int(counts.get(den_key, 0))
	if den == 0: return "n/a"
	return "%.1f%%" % (100.0 * float(counts.get(num_key, 0)) / float(den))

static func summary() -> void:
	print("\n========== [ProbeSummary] ==========")
	var keys: Array = counts.keys(); keys.sort()
	for k in keys:
		print("[ProbeSummary] %-28s = %d" % [k, int(counts[k])])
	for k in peaks:
		print("[ProbeSummary] %-28s peak= %.1f" % [k, float(peaks[k])])
	# 衍生率
	print("[ProbeSummary] 訂單履約率   = %s" % _rate("g1.order_fulfilled", "g1.order_placed"))
	print("[ProbeSummary] 套利命中率   = %s" % _rate("g1.arb_hit", "g1.arb_attempt"))
	print("[ProbeSummary] scout 收斂率 = %s" % _rate("g3.scout_converge", "g3.scout_dispatch"))
	print("====================================")
```

- [ ] **Step 4: --import + 跑驗證通過**

Expected: `probe accumulator OK`、`=== DONE ===`。

- [ ] **Step 5: Commit**
```bash
git add scripts/debug/probe_stats.gd scripts/debug/headless_test.gd
git commit -m "feat(probe): Probe 累計器(flag gated bump/note/summary,純觀測)"
```

---

### Task 2: G3 事件點打點（識破/trust/scout/誘殺）

**Files:**
- Modify: `scripts/simulation/message_system.gd`、`scripts/simulation/belief_system.gd`、`scripts/simulation/faction_ai_system.gd`、`scripts/simulation/encounter_system.gd`
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: `Probe.bump`（Task1）。
- Produces: `Probe.ambush_check(state, attacker_id, defender_id) -> void`（誘殺判定 helper，置 Probe）。

> **所有 bump 為 1 行、gated（enabled off 時 no-op）、不改遊戲邏輯**。放在既有事件分支內。

- [ ] **Step 1: 寫失敗測試**（誘殺判定 helper）

```gdscript
func _test_probe_ambush_check() -> void:
	print("--- Probe 誘殺判定 ---")
	Probe.reset(); Probe.enabled = true
	var s := WorldState.new(); s.world = WorldData.new(); s.team_intel = {}
	s.teams = {}
	var atk := TeamData.new(); atk.team_id = 1; atk.population = 10; s.teams[1] = atk
	var def := TeamData.new(); def.team_id = 2; def.population = 30; s.teams[2] = def  # 真強
	# 攻方 belief：def 弱（armed_est 低報）
	BeliefSystem.record_claim(s, 1, 2, 9, "流民", {"population_est": 5, "armed_est": 4}, 0.6, true)
	Probe.ambush_check(s, 1, 2)   # 攻方信弱(4) 實強(30) → 誘殺
	assert(Probe.counts.get("g3.ambush", 0) == 1, "信弱實強→誘殺計數")
	# 對照：belief 接近真值 → 非誘殺
	Probe.reset(); Probe.enabled = true
	BeliefSystem.record_claim(s, 1, 2, 1, "親見", {"population_est": 30, "armed_est": 28}, 1.0, false)
	Probe.ambush_check(s, 1, 2)
	assert(Probe.counts.get("g3.ambush", 0) == 0, "信實相符→非誘殺")
	Probe.enabled = false
	print("ambush check OK")
```

- [ ] **Step 2: 跑驗證失敗**

- [ ] **Step 3a: Probe.ambush_check helper**（加 `probe_stats.gd`）

```gdscript
const AMBUSH_UNDEREST := 0.5   # TEST VALUE：belief 武力低估 < 真值 50% → 視為被誤導

static func ambush_check(state: WorldState, attacker_id: int, defender_id: int) -> void:
	if not enabled: return
	var defender = state.teams.get(defender_id)
	if defender == null: return
	var bel: Dictionary = BeliefSystem.best_estimate(state, attacker_id, defender_id)
	if bel.is_empty(): return
	var bel_str: float = float(bel.get("armed_est", bel.get("population_est", 0.0)))
	var real_str: float = float(defender.population)   # 真實力 proxy（armed 解算在戰鬥，pop 為穩定 proxy）
	if real_str > 0.0 and bel_str < real_str * AMBUSH_UNDEREST:
		bump("g3.ambush")
```

- [ ] **Step 3b: G3 事件點 bump**（各 1 行）

- `message_system.gd` 識破分支（`detection_discount` 後）→ 依 discount 對應 const 分級：
```gdscript
			if det["discount"] == BeliefSystem.DETECT_ADJUDICATE_MULT: Probe.bump("g3.detect_裁決")
			elif det["discount"] == BeliefSystem.DETECT_SUSPECT_MULT: Probe.bump("g3.detect_生疑")
			else: Probe.bump("g3.detect_信假")
```
- `belief_system.gd` `reconcile_firsthand` 的 `update_reputation` 兩處：`+TRUST_DELTA` 後 `Probe.bump("g3.trust_up")`；`-TRUST_DELTA` 後 `Probe.bump("g3.trust_down")`。
- `belief_system.gd` `record_claim` 尾（cap 前）：`Probe.note("g3.claim_peak", float(cs.size()))`。
- `faction_ai_system.gd` `_evaluate_prosperity_attack`：scout dispatch（`[Scout]` print 處）後 `Probe.bump("g3.scout_dispatch")`；scout→attack 收斂（confident 後 release scout 再 try_set ATTACK 成功處，即「原 task 為 scout」分支）`Probe.bump("g3.scout_converge")`；scout timeout release 處 `Probe.bump("g3.scout_timeout")`。
- `encounter_system.gd` 戰鬥敗北結算（`_loot_treasury_share` 或 winner/defeat 確定處，loser 為主動攻擊方時）：`Probe.ambush_check(state, loser.team_id, winner.team_id)`（loser=發起攻擊的攻方時才有意義；置於 loser 為 prosperity/loot 發起方判定後）。

> 識破 bump 需 `det` 在 scope（message Task G3c-2 已有 `det` 變數）；分級用 `BeliefSystem.DETECT_*_MULT` const 非 magic number。

- [ ] **Step 4: --import + 回歸**

```
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected: `ambush check OK`、`=== DONE ===`、**既有測試 0 變動**（flag off → bump no-op → 行為零變）、coin_eq=0、InvariantAudit 0。

- [ ] **Step 5: Commit**
```bash
git add scripts/simulation/message_system.gd scripts/simulation/belief_system.gd scripts/simulation/faction_ai_system.gd scripts/simulation/encounter_system.gd scripts/debug/probe_stats.gd scripts/debug/headless_test.gd
git commit -m "feat(probe): G3 事件點打點(識破分級/trust±/scout/誘殺,gated)"
```

---

### Task 3: G1 + G2 事件點打點

**Files:**
- Modify: `scripts/simulation/order_system.gd`、`scripts/simulation/faction_ai_system.gd`、`scripts/simulation/outpost_system.gd`、`scripts/simulation/ambition_ladder.gd`
- Test: `scripts/debug/headless_test.gd`（沿用既有功能測試 + flag-on 斷言計數）

**Interfaces:**
- Consumes: `Probe.bump`（Task1）。

- [ ] **Step 1: 寫失敗測試**（最小：開 flag 跑既有 order/ambition 路徑 → 計數 >0）

```gdscript
func _test_probe_g1g2_hooks() -> void:
	print("--- Probe G1/G2 打點 ---")
	Probe.reset(); Probe.enabled = true
	var os := OrderSystem.new()
	var s := WorldState.new(); s.world = WorldData.new(); s.teams = {}
	var t := TeamData.new(); t.team_id = 1; s.teams[1] = t
	os.post_order(s, t, "buy", "food", 50)
	assert(Probe.counts.get("g1.order_placed", 0) >= 1, "post_order 打點")
	Probe.enabled = false
	print("probe g1g2 hooks OK")
```
> 本 unit 測只驗 `g1.order_placed`（`OrderSystem.post_order` 公開可直呼）。其餘 G1/G2 打點（套利/鑄幣/野心/vendetta/feud/立國）無乾淨對外 entry → 由 Task5 game_sim_test 整合驗（sim 中自然發生 → summary 計數非零）。勿在此 unit 測直呼內部升降。

- [ ] **Step 2: 跑驗證失敗**

- [ ] **Step 3: G1/G2 事件點 bump**

**G1：**
- `order_system.gd` `post_order`（建立 order 成功 return id 前）：`Probe.bump("g1.order_placed")`。
- `order_system.gd` 履約處（買/賣單被滿足、order 標記 fulfilled/移除的分支，於 `tick_team_orders` 或 merchant 消費）：`Probe.bump("g1.order_fulfilled")`。
- `faction_ai_system.gd` 商隊套利（`best_arbitrage_order` 消費端：取得套利目標 `Probe.bump("g1.arb_attempt")`；實際成交 `Probe.bump("g1.arb_hit")`；短缺發買單處 `Probe.bump("g1.shortage_buy")`）。
- `outpost_system.gd` `_tick_mint`（`rate>0` 實鑄處）：`Probe.bump("g1.mint")`。

**G2：**
- `ambition_ladder.gd:72`（安全崩 demote）後：`Probe.bump("g2.ambition_demote")`；`:77`（promote）後：`Probe.bump("g2.ambition_promote")`。
- `faction_ai_system.gd` vendetta dispatch（`PRIO_VENDETTA` try_set 成功處）：`Probe.bump("g2.vendetta_trigger")`。
- `npc_ai_system.gd` `RelationGraph.add_edge("feud",...)` 後：`Probe.bump("g2.feud_formed")`。
- `faction_ai_system.gd:2353`（`[Faction] 立國` print 處）：`Probe.bump("g2.faction_found")`。

> 全 1 行、gated、置既有事件分支內，不改邏輯。

- [ ] **Step 4: --import + 回歸**

Expected: `probe g1g2 hooks OK`、`=== DONE ===`、既有測試 0 變動（flag off）、coin_eq=0。

- [ ] **Step 5: Commit**
```bash
git add scripts/simulation/order_system.gd scripts/simulation/faction_ai_system.gd scripts/simulation/outpost_system.gd scripts/simulation/ambition_ladder.gd scripts/simulation/npc_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(probe): G1/G2 事件點打點(訂單/套利/鑄幣/野心/vendetta/feud/立國,gated)"
```

---

### Task 4: SpineTrace 時間軸 dump（G1/G2/G3/Named）

**Files:**
- Create: `scripts/debug/spine_trace.gd`
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Produces: `SpineTrace.dump(state, tick) -> void`（對 WATCHED team + auto-pick named 印分脊椎行）。
- Consumes: `BeliefSystem.best_estimate/uncertainty/claims/known_targets`、`AmbitionLadder`、既有 data 欄。

- [ ] **Step 1: 寫失敗測試**（dump 不崩 + 印關鍵 prefix）

```gdscript
func _test_spine_trace_dump() -> void:
	print("--- SpineTrace dump ---")
	var s := WorldState.new(); s.world = WorldData.new(); s.world.current_tick = 240
	s.teams = {}; s.persons = {}; s.team_intel = {}; s.team_discovered = {}
	var t := TeamData.new(); t.team_id = 0; t.population = 8
	t.ambition_rung = 1; t.ambition_archetype = AmbitionLadder.ARCHETYPE_FORCE
	var ld := PersonData.new(); ld.id = 100; ld.team_id = 0; t.leader_id = 100
	ld.skills["計謀"] = 0.5; ld.values["野心"] = 0.7
	s.teams[0] = t; s.persons[100] = ld; s.team_discovered[0] = []
	SpineTrace.dump(s, 240)   # 不崩即過（純讀）
	print("spine trace OK")
```

- [ ] **Step 2: 跑驗證失敗**

- [ ] **Step 3: 建 SpineTrace**

`scripts/debug/spine_trace.gd`（純讀，仿 TeamTrace 風格）：
```gdscript
class_name SpineTrace

const WATCHED: Array = [0, 1, 2, 3, 4]   # 統領/商隊/敵軍/生產村/流亡

static func dump(state: WorldState, tick: int) -> void:
	var day: int = tick / 240
	for tid in WATCHED:
		var t: TeamData = state.teams.get(tid)
		if t == null: continue
		_dump_g1(state, day, t)
		_dump_g2(state, day, t)
		_dump_g3(state, day, t)
	_dump_named(state, day)

static func _dump_g1(state: WorldState, day: int, t: TeamData) -> void:
	print("[G1] d%d T%d order=%s/%s coin=%.0f food=%.0f mat=%.0f goods=%.0f" % [
		day, t.team_id, str(t.order_target_id), t.order_task,
		float(t.resources.get("coin", 0)), float(t.resources.get("food", 0)),
		float(t.resources.get("material", 0)), float(t.resources.get("goods", 0))])

static func _dump_g2(state: WorldState, day: int, t: TeamData) -> void:
	var leader: PersonData = state.persons.get(t.leader_id)
	var edges: Array = leader.relation_edges if leader else []
	var feud := 0; var grat := 0; var prot := 0; var trust := 0
	for e in edges:
		match e.get("type", ""):
			"feud": feud += 1
			"gratitude": grat += 1
			"protect": prot += 1
			"trust": trust += 1
	print("[G2] d%d T%d rung=%d arch=%s cap=%d vendetta=%d edges(feud%d/grat%d/prot%d/trust%d)" % [
		day, t.team_id, t.ambition_rung, str(t.ambition_archetype), t.ambition_cap,
		t.vendetta_target, feud, grat, prot, trust])

static func _dump_g3(state: WorldState, day: int, t: TeamData) -> void:
	var tgts: Array = BeliefSystem.known_targets(state, t.team_id)
	var claim_total := 0
	var max_unc := 0.0
	for tg in tgts:
		claim_total += BeliefSystem.claims(state, t.team_id, tg).size()
		max_unc = maxf(max_unc, BeliefSystem.uncertainty(state, t.team_id, tg))
	# trust（known_reputations）分佈
	var lo := 1.0; var hi := 0.0; var sum := 0.0; var n := 0
	for k in t.known_reputations:
		var v: float = float(t.known_reputations[k])
		lo = minf(lo, v); hi = maxf(hi, v); sum += v; n += 1
	var trust_s: String = "%.2f/%.2f/%.2f" % [lo if n > 0 else 0.0, (sum / n) if n > 0 else 0.0, hi] if n > 0 else "-"
	print("[G3] d%d T%d task=%s belief(tgt%d/claim%d/maxUnc%.2f) trust(lo/avg/hi=%s)" % [
		day, t.team_id, t.current_task, tgts.size(), claim_total, max_unc, trust_s])

static func _dump_named(state: WorldState, day: int) -> void:
	# 5 leader + auto-pick 最高計謀/野心 named_member
	var named_ids: Array = []
	for tid in WATCHED:
		var t: TeamData = state.teams.get(tid)
		if t and t.leader_id != -1: named_ids.append(t.leader_id)
	var best_scheme := -1; var best_scheme_v := -1.0
	var best_amb := -1; var best_amb_v := -1.0
	for pid in state.persons:
		var p: PersonData = state.persons[pid]
		if p.role == "leader": continue   # 已含
		var sc: float = float(p.skills.get("計謀", 0.0))
		var am: float = float(p.values.get("野心", 0.0))
		if sc > best_scheme_v: best_scheme_v = sc; best_scheme = pid
		if am > best_amb_v: best_amb_v = am; best_amb = pid
	if best_scheme != -1 and not named_ids.has(best_scheme): named_ids.append(best_scheme)
	if best_amb != -1 and not named_ids.has(best_amb): named_ids.append(best_amb)
	for pid in named_ids:
		var p: PersonData = state.persons.get(pid)
		if p == null: continue
		var t: TeamData = state.teams.get(p.team_id)
		var rung: int = t.ambition_rung if t else -1
		print("[Named] d%d P%d(T%d) 統%.1f偵%.1f謀%.1f術%.1f商%.1f | 慎%.1f野%.1f戰%.1f殘%.1f貪%.1f信%.1f | rung=%d loy%.2f str%.2f fear%.2f" % [
			day, pid, p.team_id,
			float(p.skills.get("統領",0)), float(p.skills.get("偵查",0)), float(p.skills.get("計謀",0)),
			float(p.skills.get("戰術",0)), float(p.skills.get("商業",0)),
			float(p.values.get("慎重",0)), float(p.values.get("野心",0)), float(p.values.get("好戰",0)),
			float(p.values.get("殘忍",0)), float(p.values.get("貪婪",0)), float(p.values.get("信義",0)),
			rung, p.loyalty, p.stress, p.fear])
```

- [ ] **Step 4: --import + 跑驗證通過**

Expected: `spine trace OK`、`=== DONE ===`。

- [ ] **Step 5: Commit**
```bash
git add scripts/debug/spine_trace.gd scripts/debug/headless_test.gd
git commit -m "feat(probe): SpineTrace 時間軸 dump(G1/G2/G3/Named+auto-pick)"
```

---

### Task 5: game_sim_test 接線 + 回歸

**Files:**
- Modify: `scripts/debug/game_sim_test.gd`

- [ ] **Step 1: 接線**

`game_sim_test.gd`：
- 開頭（`_initialize` 起始、建場景前）：`Probe.enabled = true; Probe.reset()`。
- 取樣鉤（現 `TeamTrace.dump(state, tick + 1)` @:150 旁）：加 `SpineTrace.dump(state, tick + 1)`。
- 結尾（sim loop 後、quit 前）：`Probe.summary()`；並 `Probe.enabled = false`（還原，避免污染同進程後續）。

- [ ] **Step 2: --import + 跑 game_sim_test（flag on 場景）**

```
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_test.gd
```
Expected: 跑通無 SCRIPT ERROR；`[G1]`/`[G2]`/`[G3]`/`[Named]` 行出現；`[ProbeSummary]` 印；coin_eq/不變量段維持（探針不破）。至少 `g1.order_placed`、`g3.scout_dispatch` 或 `g2.*` 有非零（脊椎在動）。

- [ ] **Step 3: 回歸 headless（flag off 零變）**

```
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`、既有測試 0 變動、coin_eq=0、InvariantAudit 0（Probe.enabled 預設 false → 全 no-op，行為零變）。

- [ ] **Step 4: Commit**
```bash
git add scripts/debug/game_sim_test.gd
git commit -m "feat(probe): game_sim_test 接線 SpineTrace+Probe.summary(flag on 場景)"
```

---

## Self-Review 註記

- **spec 覆蓋**：Layer1 時間軸(Task4 G1/G2/G3/Named)、Layer2 彙總(Task1 Probe + Task2/3 打點)、代表 team[0-4]+named auto-pick(Task4)、誘殺判定(Task2 ambush_check)、host game_sim_test(Task5)、flag gated 零行為變(全 task)。皆有 task。
- **純觀測零行為變**：bump/dump 只讀+計數、gated；回歸閘雙驗（flag off headless 零變 + flag on 場景跑通）。
- **打點精度風險**：事件點放錯計數不準（非遊戲破壞）。Task2/3 置既有事件分支內，審 diff 可捕；rung/order/scout 在 game_sim_test 應自然非零（脊椎在動），summary 全零 = 打點漏，停查。
- **named auto-pick**：role!="leader" 掃最高計謀/野心，避免重複 leader；場景無 named_member 則只 5 leader（不崩）。
- **TEST VALUE**：AMBUSH_UNDEREST=0.5（誘殺低估門檻）。
- **執行確認**：新 class_name（Probe/SpineTrace）→ `--import`；識破分級用 `BeliefSystem.DETECT_*_MULT` const；ambush_check loser 為攻方時才有意義（置 loser=發起方判定後）；game_sim_test 結尾還原 `Probe.enabled=false`。
- **Task3 測試務實**：AmbitionLadder 無公開升降 entry → G2 打點由 Task5 game_sim_test 計數非零驗（sim 中自然發生），Task3 unit 測只留 `g1.order_placed`（OrderSystem.post_order 公開）。
