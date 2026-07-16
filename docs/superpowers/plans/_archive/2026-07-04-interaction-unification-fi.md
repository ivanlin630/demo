# 互動統一 F-I2/I4/I5/I7+I6 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 互動格統一收斂——tribute accept 三公式→1（belief-gated）、distortion 三引擎+dormant→1、RelationGraph feud/gratitude 接線、combat verb 轉 belief、tribute_refused memory 補 type 欄。

**Architecture:** 統一 accept 公式 = `DiplomaticAiSystem.tribute_accept`（static，單一 owner，F-I1 precedent：interaction 委派 diplomatic）。統一失真引擎 = 新檔 `DistortionEngine`（static class，own「失真怎麼算」；call site 傳 mode/context）。C 類紀律：舊公式/舊引擎全刪，不留平行路。

**Tech Stack:** Godot 4.2.2 GDScript headless。跑指令一律 `.\tools\godot.ps1`（UTF-8 wrapper）。

## Global Constraints（spec 硬約束）

- 凡身分=權重非路徑切換：統一公式內差異走輸入權重（threat 參數），非分叉公式。
- 凡 belief→provenance：新 belief 讀取經 `BeliefSystem.best_estimate`；不引入新 god-view 讀。
- RNG 流神聖：randf 塊 1:1 移植勿重排勿 memoize；行為改變 OK、順序假設不 OK。
- 單寫者格局不動：distortion 寫 intel 走既有寫點（`_write_tier2_intel` 名字與 `record_claim` 呼叫留在 interaction）。
- 勿碰：`manpower_system.gd`、`scenes/`、`scripts/ui/*`。
- seeded warring hash 允許變，附前後 final 摘要。**Baseline（pre-change）**：seed=1337 `{teams:45, factions:8, established:1, pop:222}`；seed=42 `{teams:49, factions:9, established:1, pop:265}`；seed=7 `{teams:50, factions:8, established:0, pop:405}`。
- Baseline 回歸現況：headless = 1 pre-existing FAIL（「弱目標未加入攻擊 goal」）+ 0 SCRIPT ERROR + `=== DONE ===`；framework_validation PASS=7 DORMANT=0。

## Measure-first 已完成（F-I5 judge 依據）

12000 ticks × 2 configs（game_sim_test/warzone）edge 統計：
- `feud`：warzone 2 條（producer `form_feud` 活、consumer `vendetta_target` 活）。
- `gratitude`：game_sim_test 6 條（3 cross-team，producer salary `kindness` + combat `aided_in_battle` 活、**無 consumer**）。
- `protect`：0 條（`_write_relation_edge` "master" arm 存在但全 codebase 無人寫 "master" memory → writer-dead）。
- `killed`：0 條（全 codebase 無 writer、無 reader，僅 person_data.gd:63 註解提及）。

**Judge 裁決：接線**——feud/gratitude 有真資料 → 入統一 accept 公式當權重項（血仇不屈/恩義軟化）。protect/killed = dormant type，跨 scope（salary_system 讀 "master"）不動 code，列 handback 報告。

---

### Task 1: `DiplomaticAiSystem.tribute_accept` 統一公式（F-I2+F-I5 接線+F-I7 belief 輸入）+ F-I6

**Files:**
- Modify: `scripts/simulation/diplomatic_ai_system.gd`（constants 區、`handle_diplomacy_message` demand_tribute 分支 :149-159、`_send_diplomacy_message` tribute_refused 塊 :122-132）
- Test: `scripts/debug/headless_test.gd`（新增 `_test_tribute_unified_edges`）

**Interfaces:**
- Produces: `static func tribute_accept(state: WorldState, defender: TeamData, aggressor: TeamData, threat: float) -> bool`（Task 2 的 interaction caller 依賴此簽名）

- [x] **Step 1: 加常數**（diplomatic_ai_system.gd 常數區尾）

```gdscript
# F-I2 統一貢金/勒索屈服公式權重（TEST VALUE，seeded 校）。單一 owner：三 caller
#（LOOT 同格勒索 / 外交 demand_tribute / 玩家直接勒索）全走 tribute_accept，
# 情境差異=輸入權重（threat），非分叉公式。
const TRIBUTE_W_POWER: float = 0.4      # believed 實力比（沿舊 demand_tribute 權重）
const TRIBUTE_W_CAUTION: float = 0.3
const TRIBUTE_W_HONOR: float = 0.3      # 義氣抗屈服
const TRIBUTE_W_SURVIVAL: float = 0.2   # 求生欲傾向屈服（沿舊 _should_pay_tribute）
const TRIBUTE_W_FEAR: float = 0.2       # 恐懼傾向屈服（沿舊 resolve_extortion_direct）
const TRIBUTE_W_THREAT: float = 0.2     # 兵臨城下壓力（caller 輸入：同格=aggressor readiness、遠程外交=0）
const TRIBUTE_W_FEUD: float = 0.3       # F-I5 接線：血仇不屈
const TRIBUTE_W_GRATITUDE: float = 0.2  # F-I5 接線：恩義軟化
const TRIBUTE_ACCEPT_THRESHOLD: float = 0.1
const TRIBUTE_POWER_R_CAP: float = 3.0
```

- [x] **Step 2: 加 `tribute_accept` + `_edge_intensity_to`**（`_get_pop_est` 後）

```gdscript
# F-I2 統一屈服公式（C 類：舊 interaction._should_pay_tribute / 本檔 demand_tribute 內嵌分 /
# interaction.resolve_extortion_direct 內嵌分全退役）。
# F-I7：aggressor 實力讀 believed pop（無估 fallback=self pop=視為等強，保守不偷看真值）。
# F-I5：consult feud/gratitude typed 邊當權重項。
static func tribute_accept(state: WorldState, defender: TeamData, aggressor: TeamData,
		threat: float) -> bool:
	if defender.current_task == TeamData.TASK_FLEE:
		return true
	var leader: PersonData = state.persons.get(defender.leader_id) if defender.leader_id != -1 else null
	if leader == null:
		return false
	var caution: float  = float(leader.values.get("慎重", 0.5))
	var honor: float    = float(leader.values.get("義氣", 0.5))
	var survival: float = float(leader.values.get("求生欲", 0.5))
	var agg_pop_est: int = BeliefSystem.best_estimate(state, defender.team_id, aggressor.team_id) \
		.get("population_est", defender.population)
	var power_r: float = clampf(float(agg_pop_est) / maxf(float(defender.population), 1.0),
		0.0, TRIBUTE_POWER_R_CAP)
	var score: float = (power_r - 1.0) * TRIBUTE_W_POWER \
		+ caution * TRIBUTE_W_CAUTION - honor * TRIBUTE_W_HONOR \
		+ survival * TRIBUTE_W_SURVIVAL + leader.fear * TRIBUTE_W_FEAR \
		+ clampf(threat, 0.0, 1.0) * TRIBUTE_W_THREAT
	if aggressor.leader_id != -1:
		score -= _edge_intensity_to(leader.relation_edges, "feud", aggressor.leader_id) * TRIBUTE_W_FEUD
		score += _edge_intensity_to(leader.relation_edges, "gratitude", aggressor.leader_id) * TRIBUTE_W_GRATITUDE
	return score > TRIBUTE_ACCEPT_THRESHOLD

# typed 邊 reader（指定 type+target 最強 intensity；無邊 0）。加 reader 不改 RelationGraph 核心。
static func _edge_intensity_to(edges: Array, type: String, target: int) -> float:
	var best: float = 0.0
	for e in RelationGraph.edges_of_type(edges, type):
		if int(e.get("target", -1)) == target:
			best = maxf(best, float(e.get("intensity", 0.0)))
	return best
```

- [x] **Step 3: demand_tribute 分支改委派**（:149-159 整段換）

```gdscript
		"demand_tribute":
			# F-I2 統一公式（遠程外交無兵臨壓力 threat=0）
			return "accept" if tribute_accept(state, self_team, sender_team, 0.0) else "refuse"
```

- [x] **Step 4: F-I6 tribute_refused 走 write_memory**（`_send_diplomacy_message` :122-132 memory append 換）

```gdscript
	if action == "demand_tribute" and response == "refuse":
		var sender_leader: PersonData = state.persons.get(sender.leader_id) if sender.leader_id >= 0 else null
		if sender_leader != null:
			# F-I6：走 write_memory 統一 schema（type 欄 → type-scan counter 可見）。0.2 TEST VALUE
			NpcAiSystem.new().write_memory(sender_leader, "tribute_refused",
				target.leader_id, state.world.current_tick, 0.2)
		sender.update_reputation(target.team_id, -0.1)
		target.update_reputation(sender.team_id, -0.05)
		print("[Diplomacy] Team%d 拒絕進貢 → demander memory tribute_refused, rep -0.1/-0.05" % target.team_id)
```

- [x] **Step 5: headless 加 `_test_tribute_unified_edges`**（放 `_test_leak_tribute_response_belief` 後，並在其呼叫點旁註冊）

```gdscript
# F-I2+F-I5：統一公式 consult feud/gratitude 邊。同 belief 同人格，僅差 feud 邊 → accept 翻 refuse。
func _test_tribute_unified_edges() -> void:
	print("--- F-I2/I5 統一公式 typed 邊權重 ---")
	var st := WorldState.new(); st.world = WorldData.new()
	var agg := TeamData.new(); agg.team_id = 1; agg.tile_pos = Vector2i(0,0); _seed_pop(agg, 15)
	st.teams[1] = agg
	var al := PersonData.new(); al.id = 301; st.persons[301] = al; agg.leader_id = 301
	var def_t := TeamData.new(); def_t.team_id = 0; def_t.tile_pos = Vector2i(0,0); _seed_pop(def_t, 10)
	st.teams[0] = def_t
	var dl := PersonData.new(); dl.id = 300
	dl.values = { "慎重": 0.5, "義氣": 0.5, "求生欲": 0.5 }
	st.persons[300] = dl; def_t.leader_id = 300
	BeliefSystem.record_claim(st, 0, 1, 0, "親見", {"population_est": 15}, 1.0, false)
	# base：power_r=1.5 → score=0.2+0.15-0.15+0.1=0.3 > 0.1 → accept
	assert(DiplomaticAiSystem.tribute_accept(st, def_t, agg, 0.0), "無邊 → 屈服")
	# feud 邊 1.0 → score 0.3-0.3=0.0 < 0.1 → refuse（血仇不屈）
	RelationGraph.add_edge(dl.relation_edges, "feud", 301, 1.0, 0)
	assert(not DiplomaticAiSystem.tribute_accept(st, def_t, agg, 0.0), "feud 邊 → 不屈")
	print("tribute unified edges OK")
```

- [x] **Step 6: 跑 headless 驗證**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `=== DONE ===`、0 SCRIPT ERROR、僅 1 pre-existing FAIL、新測 print 出現。

- [x] **Step 7: Commit** `feat(interaction): F-I2 tribute 統一公式 tribute_accept + F-I5 typed 邊接線 + F-I6 type 欄`

---

### Task 2: interaction caller 收斂 + `_should_attack` belief（F-I2 收尾+F-I7）

**Files:**
- Modify: `scripts/simulation/interaction_system.gd`（LOOT 分支 :299-316、`_should_pay_tribute` :320-332 刪、`_should_attack` :334-345、`resolve_extortion_direct` :937-951）
- Test: `scripts/debug/headless_test.gd`（新增 `_test_combat_verb_belief_gate`）

**Interfaces:**
- Consumes: `DiplomaticAiSystem.tribute_accept(state, defender, aggressor, threat)`（Task 1）

- [x] **Step 1: LOOT 分支改委派**（:299-316，`_should_pay_tribute(state, id_b, id_a)` → `DiplomaticAiSystem.tribute_accept(state, b, a, a.readiness)`；對稱分支 `(state, a, b, b.readiness)`）
- [x] **Step 2: 刪 `_should_pay_tribute` 函數**（C 類退役）
- [x] **Step 3: `_should_attack` 轉 belief**（整函數換）

```gdscript
func _should_attack(state: WorldState, atk_id: int, def_id: int) -> bool:
	var atk: TeamData = state.teams[atk_id]
	var leader: PersonData = state.persons.get(atk.leader_id)
	if leader == null:
		return false
	# F-I7 belief-gate：無情報 → 保守不攻（G3-E「無估 fallback=不行動」，不偷看真值）
	if not BeliefSystem.has_belief(state, atk_id, def_id):
		return false
	var ambition: float  = float(leader.values.get("野心", 0.5))
	var caution: float   = float(leader.values.get("慎重", 0.5))
	var greed: float     = float(leader.values.get("貪婪", 0.5))
	var martial: float   = float(leader.values.get("好戰", 0.5))
	# F-I7：對方實力讀 believed armed_est（tier2 偽裝/虛張在此咬），退 pop_est；自身讀真 armed
	var bel: Dictionary = BeliefSystem.best_estimate(state, atk_id, def_id)
	var own_armed: float = maxf(float(_combat.calc_armed(state, atk)), 1.0)
	var def_est: float = float(bel.get("armed_est", bel.get("population_est", own_armed)))
	var str_ratio: float = own_armed / maxf(def_est, 1.0)
	var score: float = ambition * 0.3 + martial * 0.3 + greed * 0.2 + (str_ratio - 1.0) * 0.2 - caution * 0.5
	return score > 0.0
```

- [x] **Step 4: `resolve_extortion_direct` NPC-refuse 塊改委派**（:940-951 換）

```gdscript
	if aggressor_id == player_team_id:
		# F-I2 統一公式（同格勒索=兵臨城下 threat=aggressor readiness）
		if not DiplomaticAiSystem.tribute_accept(state, to_t, from_t, from_t.readiness):
			print("[Extort] Team%d 拒絕勒索" % target_id)
			return { "ok": true, "accepted": false, "msg": "對方拒絕勒索" }
```

- [x] **Step 5: headless 加 `_test_combat_verb_belief_gate`**

```gdscript
# F-I7：combat verb 讀 belief。無情報→保守不攻；誤報 believed strength→決策跟 belief 走。
func _test_combat_verb_belief_gate() -> void:
	print("--- F-I7 combat verb belief-gate ---")
	var st := WorldState.new(); st.world = WorldData.new()
	var inter := InteractionSystem.new()
	var atk := TeamData.new(); atk.team_id = 0; atk.tile_pos = Vector2i(0,0); _seed_pop(atk, 20)
	atk.armed_anon_ratio = 1.0; st.teams[0] = atk
	var al := PersonData.new(); al.id = 400
	al.values = { "野心": 0.9, "好戰": 0.9, "貪婪": 0.9, "慎重": 0.0 }
	st.persons[400] = al; atk.leader_id = 400
	var def_t := TeamData.new(); def_t.team_id = 1; def_t.tile_pos = Vector2i(0,0); _seed_pop(def_t, 3)
	st.teams[1] = def_t
	var dl2 := PersonData.new(); dl2.id = 401; st.persons[401] = dl2; def_t.leader_id = 401
	# A) 真弱(pop3) 無 belief → 保守不攻（不偷看真值）
	assert(not inter._should_attack(st, 0, 1), "無情報 → 保守不攻")
	# B) 誤報超強（armed_est 200，真弱）→ 依 belief 不攻
	BeliefSystem.record_claim(st, 0, 1, 0, "親見", {"population_est": 200, "armed_est": 200}, 1.0, false)
	assert(not inter._should_attack(st, 0, 1), "belief 強 → 不攻（跟 belief 走）")
	# C) 改報超弱 → 依 belief 攻（同源覆寫 claim）
	BeliefSystem.record_claim(st, 0, 1, 0, "親見", {"population_est": 2, "armed_est": 1}, 1.0, false)
	assert(inter._should_attack(st, 0, 1), "belief 弱+莽者 → 攻")
	print("combat verb belief gate OK")
```

- [x] **Step 6: 跑 headless**（同 Task 1 期望）
- [x] **Step 7: Commit** `feat(interaction): F-I7 combat verb 轉 belief + F-I2 caller 收斂（舊 _should_pay_tribute 退役）`

---

### Task 3: DistortionEngine 統一失真引擎（F-I4）

**Files:**
- Create: `scripts/simulation/distortion_engine.gd`
- Modify: `scripts/simulation/message_system.gd`（`_exchange_one_way` :81-93、`_distort_content` :117-133 刪、`_distort_intel_entry` :146-169 刪、`_exchange_intel` :213-226、`exchange_messages` :250-267 刪 dormant）
- Modify: `scripts/simulation/interaction_system.gd`（`_write_tier2_intel` :816-851 欺敵塊、`_biggest_established_faction` :861-870 移居 engine）

**Interfaces:**
- Produces:
  - `static func distort_message(state: WorldState, msg: MessageData, mode: String) -> void`
  - `static func distort_intel_entry(entry: Dictionary, mode: String, hop_decay: float) -> Dictionary`
  - `static func apply_observation_deception(state: WorldState, snap: Dictionary, tgt: TeamData, tgt_leader: PersonData, actual_armed: int) -> void`

- [x] **Step 1: 建 engine 檔**（randf 塊 1:1 移植，deceive_chance 人格計算一併入 engine=「失真怎麼算」單一 owner）

（完整代碼見實作，核心結構：）

```gdscript
class_name DistortionEngine
# F-I4 單一失真引擎：估值擾動/位置偏移/身分誤報/任務謠傳/觀察欺敵 單一 owner。
# C 類退役：message._distort_content、message._distort_intel_entry、
# interaction._write_tier2_intel 內嵌欺敵塊 → 收斂於此；message.exchange_messages（dormant 第4引擎）刪。

const HEX_NEIGHBORS: Array = [...6 鄰格...]
const POS_OFFSETS_FAR: Array = [...8 偏移...]
const TASK_RUMORS: Array = ["idle", "攻擊", "貿易", "生產", "偵查"]

static func distort_message(state, msg, mode) -> void   # unintentional=40% 鄰格漂移；malicious=原 _distort_content
static func distort_intel_entry(entry, mode, hop_decay) -> Dictionary   # 原 _distort_intel_entry 1:1
static func apply_observation_deception(state, snap, tgt, tgt_leader, actual_armed) -> void
	# 原 _write_tier2_intel：deceive_chance=(1-信義)*0.5+計謀*0.2 → 偽裝平民/虛張聲勢/謊稱勢力 三塊 1:1
static func _biggest_established_faction(state) -> int   # 自 interaction 移入（謊稱勢力用）
```

- [x] **Step 2: rewire message_system**：`_exchange_one_way` unintentional/malicious 塊呼 `DistortionEngine.distort_message`；`_exchange_intel` 訊息迴圈同；intel 迴圈 `DistortionEngine.distort_intel_entry(src_val, mode, HOP_DECAY)`；刪 `_distort_content`/`_distort_intel_entry`/`exchange_messages`。
- [x] **Step 3: rewire interaction**：`_write_tier2_intel` 三欺敵塊+deceive_chance 計算 → `DistortionEngine.apply_observation_deception(state, snap, tgt, tgt_leader, actual_armed)`；刪 `_biggest_established_faction`。觀察噪音（G3c-2 observation_noise 塊）與 `record_claim` 留原地（寫點不動）。
- [x] **Step 4: `--import` 重建 class 快取**（新 class_name）
- [x] **Step 5: 跑 headless**（distortion 既有測試靠 `_write_tier2_intel` 公名不變）
- [x] **Step 6: Commit** `feat(message): F-I4 DistortionEngine 統一失真引擎（三引擎+dormant exchange_messages 退役）`

---

### Task 4: 回歸 + 文件 + handback

- [x] **Step 1: 刪臨時量測腳本** `scripts/debug/_tmp_edge_measure.gd`
- [x] **Step 2: 全套回歸**
  - headless：`=== DONE ===`、0 SCRIPT ERROR、1 pre-existing FAIL、coin_eq 測過
  - `framework_validation.gd`：PASS=7 DORMANT=0
  - `seeded_warring_bed.gd`：3 seed final 摘要 vs baseline（量級不崩）
  - `game_sim_multi.gd`：無崩潰 sanity
- [x] **Step 3: 文件**：`docs/message.md`（失真引擎統一）、`docs/faction.md`（tribute 統一公式）、`docs/known_issues.md`（protect/master writer-dead chain、killed dead type）
- [x] **Step 4: 順盤報告**（finder 濾鏈清單，grep `_find_` 整理進 handback，不動手）
- [x] **Step 5: handback** `docs/superpowers/handbacks/2026-07-04-interaction-unification-fi.md`（實作摘要/spec 差異/連動風險/待確認/前後 warring 摘要/F-I5 judge 裁決/濾鏈順盤）
- [x] **Step 6: Commit + push** `git push -u origin feat/interaction-unification-fi`
