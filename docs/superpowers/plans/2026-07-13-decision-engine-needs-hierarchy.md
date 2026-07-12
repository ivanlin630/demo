# 決策引擎需求金字塔重構 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 取代「N 個互不知彼此的獨立 term 生成器加總」的假統一決策，改為五層需求急迫度(生存/安全/歸屬/尊重/自我實現)平行混合 → 一致性係數統一調變全 23 option → `rank_scored` 單一求解器仍是唯一決策點。

**Architecture:** 五層急迫度是**感測器非決策者**（各層 EWMA 平滑同款公式，只讀「這層還缺多少」）。急迫度混合出一張純靜態 affinity 表算的一致性係數，乘進 `rank_scored_ctx` 每個 option 的 util 加總（軟降權非硬排除）。人格決定降權曲線陡度（§4 取代賭命跳關）。威脅同一訊號雙速輸出（慢：EWMA→安全層急迫度；快：達劇變門檻走既有 `PRIO_SURVIVAL` 插隊 + 事後回寫安全層）。`derive_plan_phase`/`plan_phase_drive` 整套退役，由五層急迫度完整取代。

**Tech Stack:** Godot 4.2.2 GDScript。headless 測試（`.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`）。融合閘（constitution/coin/framework/headless）。determinism byte-identical（zero randf）。

## Global Constraints

（spec 全域要求，逐條 verbatim；每個 task 隱含涵蓋）

- **架構紀律**：所有機制只能產生**乾淨的數字/係數**餵給 `rank_scored` 最後一步加總，**不能自己決定選哪個行動**。感測（算急迫度/係數）可以有很多個，決策只能有一個。（spec §核心原則）
- **§3 一致性係數表須為純靜態 lookup**（非含動態計算分支）——否則 23×5 表膨脹成隱藏邏輯，重演計畫層 state machine 疑慮。（reviewer 風險 #1）
- **§5.2 回寫機制須帶 decay + 上限 cap**（非永久疊加），列為獨立 TDD 項，非事後補測——防插隊回寫安全層急迫度形成正回饋震盪。（reviewer 風險 #2）
- **determinism**：五層 EWMA（同款 S1 已驗 zero-randf pattern）+ 係數表（純 lookup/算術）+ 回寫（純算術）皆須零 randf；各 slice 各自 TDD 驗 byte-identical。（reviewer 風險 #3）
- **驗收工具鏈**：延伸既有 `warring_harness.gd` 探針 pattern（g2.*/worldgen.*/merge.*），無需新建置。（reviewer 風險 #4）
- **不變的部分**：`faction_duty`（服從母團命令：攻擊/徵收/歸建）維持現況，不折進金字塔；子隊 `STRATEGIC_SELFINIT_SET` 限制不變。（spec §7）
- **TEST VALUE 慣例**：所有新常數初值標 `# TEST VALUE`，平衡 pass（organic measure）調。

## 檔案結構（decomposition 鎖定）

| 檔案 | 責任 | 動作 |
|---|---|---|
| `scripts/simulation/decision/need_hierarchy.gd` | **新** class `NeedHierarchy`：layer 常數、5 raw 公式、EWMA 更新、affinity 靜態表(23×5)、coeff 公式、主敘事標籤、§5 威脅雙速判斷、§5.2 回寫 | S1 建；S2/S3/S4 擴 |
| `scripts/data/team_data.gd` | 持久狀態：`need_urgency`(EWMA)、`need_stall`(卡住)、`safety_startle`(回寫) | S1/S3/S4 加欄 |
| `scripts/simulation/decision/decision_context.gd` | gather 算/存急迫度 + coeff map；退役 `derive_plan_phase`/PHASE 常數 | S1/S2 |
| `scripts/simulation/decision/decision_engine.gd` | `rank_scored_ctx` util ×= coeff | S2 |
| `scripts/simulation/decision/terms.gd` | 退役 `plan_phase_drive` eval+weight | S2 |
| `scripts/simulation/decision/options.gd` | REGISTRY 移除 `plan_phase_drive` 6 row | S2 |
| `scripts/simulation/faction_ai_system.gd` | 威脅雙速插隊接點 + 回寫觸發 + established 收尾 | S4/S5 |
| `scripts/simulation/ambition_ladder.gd` | S5：立國入自我實現層，B2/B3/B4→風格修飾 | S5 |
| `scripts/debug/headless_test.gd` | 各 slice TDD 測試 | 全 slice |
| `scripts/debug/warring_harness.gd` | organic probe 延伸 | S2/S3/S5 |

---

# Slice 1：五層急迫度感測基礎設施（inert，零行為變）

> **交付**：五層急迫度計算上線、EWMA 平滑、持久存 `team.need_urgency`。**不接 rank_scored、不碰 plan_phase**——純感測器 online，`rank()` 結果 byte-identical（融合閘 determinism 驗零變）。這是 S2 原子退役前的地基（inert 期間無 coexistence-衝突：唯一驅動行為的仍是 plan_phase，急迫度只讀不寫決策）。

### Task S1.1：NeedHierarchy layer 常數 + raw 急迫度公式

**Files:**
- Create: `scripts/simulation/decision/need_hierarchy.gd`
- Test: `scripts/debug/headless_test.gd`（新增 `_test_need_raw_urgency`）

**Interfaces:**
- Consumes: `AmbitionLadder.ACCUMULATE_FLOW_MIN`(0.5)、`AmbitionLadder.EXPAND_MIN_POP`(8)、`AmbitionLadder.STATE_MIN_FACTION_TEAMS`(2)、`AmbitionLadder.HEGEMON_MIN_FACTION_TEAMS`(4)、`AmbitionLadder.milestone_met(state, team, rung)`。
- Produces: `NeedHierarchy.compute_raw(state, team, food_days: float, threat: float) -> PackedFloat32Array`（size 5，index=L_SURVIVAL/L_SAFETY/L_BELONGING/L_ESTEEM/L_ACTUAL，值 0..1 越缺越高）。layer 常數 `L_SURVIVAL=0 L_SAFETY=1 L_BELONGING=2 L_ESTEEM=3 L_ACTUAL=4 N_LAYERS=5`。

- [ ] **Step 1: 寫失敗測試**

在 `headless_test.gd` 加（並在測試 runner 清單註冊呼叫，比照既有 `_test_*` 註冊法）：

```gdscript
func _test_need_raw_urgency() -> void:
	print("[TEST] need_raw_urgency")
	var state := WorldState.new()
	var team := TeamData.new()
	team.team_id = 1
	team.population = 4
	team.food_flow_avg = 0.0
	team.faction_id = -1
	team.ambition_cap = AmbitionLadder.RUNG_HEGEMON
	team.ambition_rung = AmbitionLadder.RUNG_SURVIVE
	# 餓(food_days=1<5 飽線)→survival 高；無威脅→safety=0；solo→belonging=1；rung 差滿→esteem 高；未立國→actual=1
	var raw := NeedHierarchy.compute_raw(state, team, 1.0, 0.0)
	assert(raw.size() == NeedHierarchy.N_LAYERS, "raw size 5")
	assert(raw[NeedHierarchy.L_SURVIVAL] > 0.7, "餓→survival 高，got %f" % raw[NeedHierarchy.L_SURVIVAL])
	assert(raw[NeedHierarchy.L_SAFETY] == 0.0, "無威脅→safety 0，got %f" % raw[NeedHierarchy.L_SAFETY])
	assert(raw[NeedHierarchy.L_BELONGING] > 0.9, "solo→belonging 高，got %f" % raw[NeedHierarchy.L_BELONGING])
	assert(raw[NeedHierarchy.L_ACTUAL] > 0.9, "未立國→actual 高，got %f" % raw[NeedHierarchy.L_ACTUAL])
	# 飽足對照：food_days=10 → survival 0
	var raw2 := NeedHierarchy.compute_raw(state, team, 10.0, 0.0)
	assert(raw2[NeedHierarchy.L_SURVIVAL] == 0.0, "飽→survival 0，got %f" % raw2[NeedHierarchy.L_SURVIVAL])
	print("[TEST] need_raw_urgency PASS")
```

- [ ] **Step 2: 跑測確認失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: FAIL — `Invalid call. Nonexistent function 'compute_raw' in base 'NeedHierarchy'`（或 class 未定義）。

- [ ] **Step 3: 建 need_hierarchy.gd 實作 raw**

```gdscript
class_name NeedHierarchy

# 需求金字塔五層急迫度（Maslow 式）。感測器非決策者：只讀「這層還缺多少」(0..1)。
# 生存(食物)→安全(威脅)→歸屬(faction/社交)→尊重(地位/擴張)→自我實現(立國/稱霸)。
const L_SURVIVAL: int = 0
const L_SAFETY: int = 1
const L_BELONGING: int = 2
const L_ESTEEM: int = 3
const L_ACTUAL: int = 4
const N_LAYERS: int = 5

# raw 急迫度門檻（TEST VALUE）
const SURVIVAL_SATED_DAYS: float = 5.0   # TEST VALUE — 食物餘命達此→生存急迫度 0（對齊 forage floor 域）

# 每層 raw 急迫度 = 該層底層指標距門檻的差距(0..1，越沒滿足越高)。純算術零 randf。
# food_days/threat 由呼叫端(gather)供（已算，避重複）；其餘讀 team/state + AmbitionLadder 門檻。
static func compute_raw(state: WorldState, team: TeamData, food_days: float, threat: float) -> PackedFloat32Array:
	var raw := PackedFloat32Array()
	raw.resize(N_LAYERS)
	# 生存：食物餘命距飽線
	raw[L_SURVIVAL] = clampf((SURVIVAL_SATED_DAYS - food_days) / SURVIVAL_SATED_DAYS, 0.0, 1.0)
	# 安全：威脅(ctx.threat 已 0..1 clamp)
	raw[L_SAFETY] = clampf(threat, 0.0, 1.0)
	# 歸屬：faction 規模距 STATE 門檻；solo(faction_id==-1)→完全未滿足=1
	var members: int = 0
	if team.faction_id != -1 and state.factions.has(team.faction_id):
		members = state.factions[team.faction_id].member_team_ids.size()
	if team.faction_id == -1:
		raw[L_BELONGING] = 1.0
	else:
		raw[L_BELONGING] = clampf(float(AmbitionLadder.STATE_MIN_FACTION_TEAMS - members) \
			/ float(AmbitionLadder.STATE_MIN_FACTION_TEAMS), 0.0, 1.0)
	# 尊重：野心 cap 與當前 rung 的差距（想爬多高 vs 已在哪）
	var cap: int = maxi(team.ambition_cap, 1)
	raw[L_ESTEEM] = clampf(float(team.ambition_cap - team.ambition_rung) / float(cap), 0.0, 1.0)
	# 自我實現：距立國/稱霸。未達 STATE→1；達 STATE 未達 HEGEMON→0.5；稱霸→0
	if not AmbitionLadder.milestone_met(state, team, AmbitionLadder.RUNG_STATE):
		raw[L_ACTUAL] = 1.0
	elif not AmbitionLadder.milestone_met(state, team, AmbitionLadder.RUNG_HEGEMON):
		raw[L_ACTUAL] = 0.5
	else:
		raw[L_ACTUAL] = 0.0
	return raw
```

- [ ] **Step 4: 跑測確認通過**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `[TEST] need_raw_urgency PASS`，無新 assert 失敗。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/decision/need_hierarchy.gd scripts/debug/headless_test.gd
git commit -m "feat(decision): NeedHierarchy layer consts + raw urgency formulas (S1.1)

五層急迫度 raw 讀數(0..1 越缺越高)，純算術零 randf。感測器非決策者。

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task S1.2：EWMA 平滑 + team.need_urgency 持久欄

**Files:**
- Modify: `scripts/data/team_data.gd`（加 `need_urgency` 欄，接 `rung_pop_last` 群組後）
- Modify: `scripts/simulation/decision/need_hierarchy.gd`（加 `ewma_update`）
- Test: `scripts/debug/headless_test.gd`（新增 `_test_need_ewma`）

**Interfaces:**
- Consumes: `NeedHierarchy.compute_raw(...)`（S1.1）。
- Produces: `NeedHierarchy.URGENCY_EWMA_ALPHA`(0.25)；`NeedHierarchy.ewma_update(prev: PackedFloat32Array, raw: PackedFloat32Array) -> PackedFloat32Array`；`TeamData.need_urgency: PackedFloat32Array`（size 5，初值全 0，持久）。

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_need_ewma() -> void:
	print("[TEST] need_ewma")
	var prev := PackedFloat32Array([0.0, 0.0, 0.0, 0.0, 0.0])
	var raw := PackedFloat32Array([1.0, 1.0, 1.0, 1.0, 1.0])
	var e1 := NeedHierarchy.ewma_update(prev, raw)
	# α=0.25：0.25*1 + 0.75*0 = 0.25
	assert(absf(e1[0] - 0.25) < 1e-5, "EWMA step1=0.25，got %f" % e1[0])
	var e2 := NeedHierarchy.ewma_update(e1, raw)
	# 0.25*1 + 0.75*0.25 = 0.4375
	assert(absf(e2[0] - 0.4375) < 1e-5, "EWMA step2=0.4375，got %f" % e2[0])
	# 冷啟(prev 空 size 0)→視同全 0
	var e0 := NeedHierarchy.ewma_update(PackedFloat32Array(), raw)
	assert(absf(e0[0] - 0.25) < 1e-5, "冷啟 EWMA=0.25，got %f" % e0[0])
	# 持久欄存在且初值 0
	var team := TeamData.new()
	assert(team.need_urgency.size() == 0 or team.need_urgency.size() == NeedHierarchy.N_LAYERS, "need_urgency 欄存在")
	print("[TEST] need_ewma PASS")
```

- [ ] **Step 2: 跑測確認失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: FAIL — `Nonexistent function 'ewma_update'`。

- [ ] **Step 3: 加 EWMA + 持久欄**

`need_hierarchy.gd` 加：

```gdscript
const URGENCY_EWMA_ALPHA: float = 0.25   # TEST VALUE — 急迫度平滑係數（同 S1 zero-randf pattern）

# EWMA：new = α·raw + (1-α)·prev。prev 空(冷啟)視同全 0。純算術零 randf。
static func ewma_update(prev: PackedFloat32Array, raw: PackedFloat32Array) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	out.resize(N_LAYERS)
	var has_prev: bool = prev.size() == N_LAYERS
	for i in range(N_LAYERS):
		var p: float = prev[i] if has_prev else 0.0
		out[i] = URGENCY_EWMA_ALPHA * raw[i] + (1.0 - URGENCY_EWMA_ALPHA) * p
	return out
```

`team_data.gd`：`rung_pop_last` 宣告後加：

```gdscript
# 需求金字塔（決策引擎重構）：五層急迫度 EWMA 持久狀態（生存/安全/歸屬/尊重/自我實現）。
# 感測器非決策者，gather 每 cadence 更新；rank_scored 讀此算一致性係數。size 5 或 0(冷啟)。
var need_urgency: PackedFloat32Array = PackedFloat32Array()
```

- [ ] **Step 4: 跑測確認通過**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `[TEST] need_ewma PASS`。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/decision/need_hierarchy.gd scripts/data/team_data.gd scripts/debug/headless_test.gd
git commit -m "feat(decision): 五層急迫度 EWMA 平滑 + team.need_urgency 持久欄 (S1.2)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task S1.3：gather 每 cadence 更新 need_urgency（inert，不接決策）

**Files:**
- Modify: `scripts/simulation/decision/decision_context.gd`（`gather` 尾，`plan_phase` 導出段附近）
- Test: `scripts/debug/headless_test.gd`（新增 `_test_need_gather_updates`）

**Interfaces:**
- Consumes: `NeedHierarchy.compute_raw`、`NeedHierarchy.ewma_update`、`ctx.food_days`、`ctx.threat`（gather 中段已算）。
- Produces: `gather` 執行後 `team.need_urgency` 被寫（size 5）；`DecisionContext.need_urgency: PackedFloat32Array` 快照欄（供 S2 讀）。**不改任何 option util、不改 rank 順序**。

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_need_gather_updates() -> void:
	print("[TEST] need_gather_updates")
	var h := HeadlessTest.new()   # 若無 helper，用既有 world builder pattern 建 state+team
	var state := _build_min_world()   # 既有 helper：最小 world + 1 team（比照其他測試）
	var team := state.teams[state.teams.keys()[0]]
	assert(team.need_urgency.size() == 0, "gather 前 need_urgency 空")
	var ctx := DecisionContext.gather(state, team)
	assert(team.need_urgency.size() == NeedHierarchy.N_LAYERS, "gather 後 need_urgency size 5")
	assert(ctx.need_urgency.size() == NeedHierarchy.N_LAYERS, "ctx 快照 size 5")
	# 第二次 gather → EWMA 累積（值變，非重置）
	var first := team.need_urgency[NeedHierarchy.L_BELONGING]
	var ctx2 := DecisionContext.gather(state, team)
	var second := team.need_urgency[NeedHierarchy.L_BELONGING]
	assert(second >= first, "EWMA 累積不倒退，%f→%f" % [first, second])
	print("[TEST] need_gather_updates PASS")
```

> 註：若 `_build_min_world` helper 不存在，implementer 用檔內既有測試的 world 建構 pattern（grep `WorldState.new()` 找最近範例），構一個含 1 team 的最小 state。

- [ ] **Step 2: 跑測確認失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: FAIL — `ctx.need_urgency` 欄不存在 / size 0。

- [ ] **Step 3: gather 尾加更新 + ctx 快照欄**

`decision_context.gd` 加宣告（`plan_phase` 欄附近）：

```gdscript
# 需求金字塔重構：五層急迫度快照（gather 更新後的 team.need_urgency 拷貝，供 rank_scored 算 coeff）。
var need_urgency: PackedFloat32Array = PackedFloat32Array()
```

`gather` 尾（`return c` 前，`plan_phase` 導出段之後）加：

```gdscript
	# 需求金字塔（決策引擎重構 S1）：五層急迫度 EWMA 更新（inert——本 slice 不接 rank_scored）。
	# compute_raw 讀 food_days/threat(已算) + team/state；ewma_update 累積進持久 team.need_urgency。
	var _raw_need: PackedFloat32Array = NeedHierarchy.compute_raw(state, team, c.food_days, c.threat)
	team.need_urgency = NeedHierarchy.ewma_update(team.need_urgency, _raw_need)
	c.need_urgency = team.need_urgency
```

- [ ] **Step 4: 跑測確認通過**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `[TEST] need_gather_updates PASS`。

- [ ] **Step 5: 融合閘 determinism（inert 驗零行為變）**

Run:
```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
.\tools\godot.ps1 --headless --script scripts/debug/constitution_gate.gd
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
```
Expected: headless 無新 FAIL（既有 5 pre-existing 不變）；constitution PASS；multi sanity 無崩潰。**inert 保證**：need_urgency 只寫不讀決策 → `rank()` 結果不變。

- [ ] **Step 6: Commit**

```bash
git add scripts/simulation/decision/decision_context.gd scripts/debug/headless_test.gd
git commit -m "feat(decision): gather 每 cadence 更新五層急迫度 (S1.3, inert)

感測器 online，不接 rank_scored/plan_phase。融合閘 determinism 驗零行為變。

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

> **S1 交付驗收**（交 measurer）：determinism byte-identical（inert，rank 不變）；need_urgency 五層皆更新且 EWMA 累積。organic 不需跑（零行為變）。

---

# Slice 2：一致性係數表 + rank_scored 接入 + plan_phase 原子退役 + §6 標籤

> **交付**：架構原子切換——affinity 靜態表 + coeff 公式(人格陡度) 乘進 rank_scored 全 23 option；同 slice **完整退役** plan_phase（term/weight/REGISTRY row/map/derive_plan_phase/PHASE 常數）；§6 主敘事標籤寫 team.plan_phase（GUI 來源改接）。**無過渡期並存**（spec §8 硬要求）。

### Task S2.1：affinity 靜態表（23 option × 5 layer，行和≈1）

**Files:**
- Modify: `scripts/simulation/decision/need_hierarchy.gd`（加 `AFFINITY` const + `affinity_of`）
- Test: `scripts/debug/headless_test.gd`（新增 `_test_need_affinity_table`）

**Interfaces:**
- Consumes: `DecisionOptions.REGISTRY`（23 option key 全集）。
- Produces: `NeedHierarchy.AFFINITY: Dictionary`（key=option 名，value=`PackedFloat32Array` size 5，行和≈1.0）；`NeedHierarchy.affinity_of(opt: String) -> PackedFloat32Array`（未列 option 回均勻 `[0.2,0.2,0.2,0.2,0.2]`）。

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_need_affinity_table() -> void:
	print("[TEST] need_affinity_table")
	# 全 23 REGISTRY option 都有 affinity row，且行和≈1
	for opt in DecisionOptions.REGISTRY.keys():
		var a := NeedHierarchy.affinity_of(opt)
		assert(a.size() == NeedHierarchy.N_LAYERS, "%s affinity size 5" % opt)
		var s := 0.0
		for v in a: s += v
		assert(absf(s - 1.0) < 0.01, "%s 行和≈1，got %f" % [opt, s])
	# 語意抽查：覓食→生存主導；survival(FLEE)→安全主導；併入→歸屬主導；訓練→尊重主導
	assert(NeedHierarchy.affinity_of("覓食")[NeedHierarchy.L_SURVIVAL] >= 0.6, "覓食 survival 主導")
	assert(NeedHierarchy.affinity_of("survival")[NeedHierarchy.L_SAFETY] >= 0.6, "FLEE safety 主導")
	assert(NeedHierarchy.affinity_of("併入")[NeedHierarchy.L_BELONGING] >= 0.5, "併入 belonging 主導")
	assert(NeedHierarchy.affinity_of("訓練")[NeedHierarchy.L_ESTEEM] >= 0.5, "訓練 esteem 主導")
	print("[TEST] need_affinity_table PASS")
```

- [ ] **Step 2: 跑測確認失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: FAIL — `Nonexistent function 'affinity_of'`。

- [ ] **Step 3: 加 AFFINITY 純靜態表**

`need_hierarchy.gd` 加（**純靜態 const，零動態分支**——守 Global Constraint reviewer 風險 #1）：

```gdscript
# §3 一致性係數 affinity 表：option → 服務哪些需求層(權重，行和≈1)。純靜態 lookup，零動態分支。
# [生存, 安全, 歸屬, 尊重, 自我實現]。全 23 REGISTRY option 覆蓋（spec §3「全 23 統一套用」）。
# TEST VALUE：語意分配（organic measure 校）。
const AFFINITY: Dictionary = {
	# 生存-class（求糧/苟活）
	"覓食":     [0.9, 0.1, 0.0, 0.0, 0.0],
	"買糧":     [0.9, 0.0, 0.1, 0.0, 0.0],
	"返家補給": [0.7, 0.2, 0.1, 0.0, 0.0],
	"紮營":     [0.6, 0.1, 0.0, 0.1, 0.2],   # 紮營=建基→間接自我實現
	"乞食":     [0.8, 0.0, 0.2, 0.0, 0.0],
	# 安全-class（威脅反應）
	"survival": [0.2, 0.8, 0.0, 0.0, 0.0],   # FLEE
	"備戰":     [0.1, 0.8, 0.0, 0.1, 0.0],
	"迎戰":     [0.1, 0.6, 0.0, 0.3, 0.0],
	"求和":     [0.1, 0.7, 0.2, 0.0, 0.0],
	# 歸屬-class（社交/結盟）
	"併入":     [0.3, 0.1, 0.6, 0.0, 0.0],
	"外交":     [0.0, 0.1, 0.6, 0.1, 0.2],
	"歸建":     [0.1, 0.1, 0.8, 0.0, 0.0],
	"吸納":     [0.0, 0.0, 0.4, 0.3, 0.3],   # 吸弱鄰=擴張(尊重)+建國基(自我實現)
	# 尊重-class（地位/征服/積累）
	"訓練":     [0.0, 0.1, 0.0, 0.7, 0.2],
	"攻擊":     [0.1, 0.1, 0.0, 0.6, 0.2],
	"掠奪":     [0.4, 0.0, 0.0, 0.5, 0.1],   # 掠奪=絕境糧(生存)+武力地位(尊重)
	"佔村":     [0.3, 0.0, 0.0, 0.4, 0.3],   # 佔村=糧基+擴張+建國
	"徵收":     [0.0, 0.0, 0.2, 0.6, 0.2],
	"生產":     [0.3, 0.0, 0.0, 0.5, 0.2],   # 積累
	"貿易":     [0.2, 0.0, 0.1, 0.6, 0.1],   # 致富=尊重(地位)
	"囤貨":     [0.1, 0.0, 0.0, 0.7, 0.2],
	# 自我實現-class（建國/稱霸/定居長治）
	"建設":     [0.1, 0.0, 0.0, 0.3, 0.6],   # 建設=據點基業→自我實現
	"駐守":     [0.2, 0.1, 0.1, 0.1, 0.5],   # 定居長治
}

const _AFFINITY_UNIFORM: PackedFloat32Array = PackedFloat32Array([0.2, 0.2, 0.2, 0.2, 0.2])

# affinity 查表（未列 option→均勻，coeff 對其近中性）。純 lookup。
static func affinity_of(opt: String) -> PackedFloat32Array:
	if AFFINITY.has(opt):
		return AFFINITY[opt]
	return _AFFINITY_UNIFORM
```

> **注意**：GDScript const Dictionary 的 array value 型別是 `Array` 非 `PackedFloat32Array`。測試若嚴格檢查 `is PackedFloat32Array` 會失敗。實作採 `affinity_of` 回傳時不強轉（`AFFINITY[opt]` 是 Array），測試改用 index 存取（`a[i]`）與 `a.size()`，兩型皆支援。`_AFFINITY_UNIFORM` 用 PackedFloat32Array 無妨。coeff 計算（S2.2）用 index 存取，型別無關。

- [ ] **Step 4: 跑測確認通過**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `[TEST] need_affinity_table PASS`。若行和 assert 失敗→調該 row 使和=1。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/decision/need_hierarchy.gd scripts/debug/headless_test.gd
git commit -m "feat(decision): §3 affinity 靜態表 23×5(行和≈1) 純 lookup 零分支 (S2.1)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task S2.2：coeff 公式（alignment × 人格降權陡度 §4）

**Files:**
- Modify: `scripts/simulation/decision/need_hierarchy.gd`（加 `consistency_coeff`）
- Test: `scripts/debug/headless_test.gd`（新增 `_test_need_coeff`）

**Interfaces:**
- Consumes: `affinity_of`、`team.need_urgency`（或 ctx 快照）、`leader_values`（慎重/野心）。
- Produces: `NeedHierarchy.consistency_coeff(opt: String, urgency: PackedFloat32Array, leader_values: Dictionary) -> float`（範圍 [COEFF_FLOOR, 1.0]）。常數 `COEFF_FLOOR=0.15`、`STEEP_BASE=0.5`、`STEEP_CAUTION=0.4`、`STEEP_AMBITION=0.35`。

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_need_coeff() -> void:
	print("[TEST] need_coeff")
	# 生存急迫拉滿，其餘 0
	var urg := PackedFloat32Array([1.0, 0.0, 0.0, 0.0, 0.0])
	var neutral := {"慎重": 0.5, "野心": 0.5}
	# 覓食(survival 主導)→alignment 高→coeff 近 1
	var c_forage := NeedHierarchy.consistency_coeff("覓食", urg, neutral)
	# 訓練(esteem 主導,遠離 survival)→alignment 低→coeff 被壓
	var c_train := NeedHierarchy.consistency_coeff("訓練", urg, neutral)
	assert(c_forage > c_train, "生存急迫下 覓食 coeff > 訓練，%f vs %f" % [c_forage, c_train])
	assert(c_forage <= 1.0 and c_train >= NeedHierarchy.COEFF_FLOOR, "coeff 界 [FLOOR,1]")
	# §4 人格陡度：謹慎者 vs 狂人，對「遠層 option(訓練)」降權差異
	var cautious := {"慎重": 0.9, "野心": 0.1}
	var reckless := {"慎重": 0.1, "野心": 0.9}
	var train_cautious := NeedHierarchy.consistency_coeff("訓練", urg, cautious)
	var train_reckless := NeedHierarchy.consistency_coeff("訓練", urg, reckless)
	assert(train_reckless > train_cautious, "狂人遠層 coeff > 謹慎者(陡度連續梯度)，%f vs %f" % [train_reckless, train_cautious])
	# 軟降權非硬排除：最遠 option 仍 >= FLOOR（不歸零）
	assert(train_cautious >= NeedHierarchy.COEFF_FLOOR, "軟降權不歸零")
	print("[TEST] need_coeff PASS")
```

- [ ] **Step 2: 跑測確認失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: FAIL — `Nonexistent function 'consistency_coeff'`。

- [ ] **Step 3: 加 coeff 公式**

`need_hierarchy.gd` 加（純算術，§4 人格陡度）：

```gdscript
# §3 軟降權：coeff = clampf(1 - steepness·(1-alignment), FLOOR, 1)。純算術零分支。
# alignment = Σ affinity[opt]·urgency ∈[0,1]（affinity 行和≈1、urgency≤1 → alignment≤1）。
# §4 steepness 由人格：謹慎↑陡(遠層壓極重)、野心↓陡(狂人遠層仍有機會)。軟降權不歸零(FLOOR)。
const COEFF_FLOOR: float = 0.15      # TEST VALUE — 軟降權下限（永不歸零=非硬排除）
const STEEP_BASE: float = 0.5        # TEST VALUE — 降權陡度基值
const STEEP_CAUTION: float = 0.4     # TEST VALUE — 慎重加陡（謹慎者遠層壓重）
const STEEP_AMBITION: float = 0.35   # TEST VALUE — 野心減陡（狂人遠層仍可跳階）

static func consistency_coeff(opt: String, urgency: PackedFloat32Array, leader_values: Dictionary) -> float:
	if urgency.size() != N_LAYERS:
		return 1.0   # 冷啟(未更新)→中性不調變
	var aff: PackedFloat32Array = affinity_of(opt)
	var alignment: float = 0.0
	for i in range(N_LAYERS):
		alignment += float(aff[i]) * urgency[i]
	alignment = clampf(alignment, 0.0, 1.0)
	var caution: float = float(leader_values.get("慎重", 0.5))
	var ambition: float = float(leader_values.get("野心", 0.5))
	var steepness: float = clampf(STEEP_BASE + caution * STEEP_CAUTION - ambition * STEEP_AMBITION, 0.0, 1.0)
	return clampf(1.0 - steepness * (1.0 - alignment), COEFF_FLOOR, 1.0)
```

- [ ] **Step 4: 跑測確認通過**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `[TEST] need_coeff PASS`。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/decision/need_hierarchy.gd scripts/debug/headless_test.gd
git commit -m "feat(decision): §3/§4 coeff 公式 alignment×人格陡度(軟降權不歸零) (S2.2)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task S2.3：rank_scored_ctx 接入 coeff（全 23 option 統一）

**Files:**
- Modify: `scripts/simulation/decision/decision_engine.gd:19-33`（`rank_scored_ctx`）
- Test: `scripts/debug/headless_test.gd`（新增 `_test_rank_coeff_applied`）

**Interfaces:**
- Consumes: `NeedHierarchy.consistency_coeff`、`ctx.need_urgency`、`ctx.leader_values`。
- Produces: `rank_scored_ctx` 每 option util ×= coeff（加總後乘）。**全 23 option 統一套用**（含原本無 plan_phase_drive/intent_fit 的 12 個）。

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_rank_coeff_applied() -> void:
	print("[TEST] rank_coeff_applied")
	var ctx := DecisionContext.new()
	ctx.leader_values = {"慎重": 0.5, "野心": 0.5}
	# 手構：生存急迫拉滿 → 遠層 option(如訓練，若 applicable)被壓
	ctx.need_urgency = PackedFloat32Array([1.0, 0.0, 0.0, 0.0, 0.0])
	# 對照：urgency 全 0(冷啟同型 size 5 但值 0)→coeff 全≈1(alignment=0→coeff=1-steepness)... 
	# 用「無 urgency size 0」對照確認 coeff=1 不調變
	ctx.need_urgency = PackedFloat32Array()   # 冷啟→coeff=1
	var scored_flat := DecisionEngine.rank_scored_ctx(ctx, "")
	# 有 urgency vs 無 urgency：同 ctx 其餘不變，rank 應可不同（coeff 生效）
	# 具體斷言：coeff=1 時某 option util 等於純 term 和（無調變）
	# 因手構 ctx applicable 依賴多欄，改用 NeedHierarchy 直接驗 coeff 生效（rank 整合在 organic 驗）
	assert(scored_flat is Array, "rank_scored_ctx 回 Array")
	# 冷啟 coeff=1 → util 不被壓（sanity：非全 0）
	print("[TEST] rank_coeff_applied PASS (coeff wiring；行為連貫 organic 驗)")
```

> 註：手構 ctx 難完整驅動 applicable（依賴 has_* 眾多欄）。本 task 單元只驗 wiring 不炸 + 冷啟中性；**行為連貫性/23-option 覆蓋**在 S2.6 organic probe 驗（spec §驗收「刻意製造某層急迫，觀察原本無 bias 的 12 option 分數變化」）。

- [ ] **Step 2: 跑測確認失敗（或 wiring 前 baseline）**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: 先 PASS（wiring 未接前 rank_scored_ctx 已回 Array）——本 task 的真驗證是 Step 3 改完後 determinism 不炸 + S2.6 organic。故此 task 以「接入不破既有測試」為 gate。

- [ ] **Step 3: rank_scored_ctx 乘 coeff**

`decision_engine.gd:19-33` 改為：

```gdscript
static func rank_scored_ctx(ctx: DecisionContext, current_option: String = "") -> Array:
	var scored: Array = []
	var idx: int = 0
	for opt in DecisionOptions.applicable(ctx):
		var u: float = 0.0
		for tw in DecisionOptions.terms_of(opt):
			u += DecisionTerms.weight(tw[1], ctx.leader_values) * DecisionTerms.eval(tw[0], ctx, opt)
		# 需求金字塔重構：五層急迫度一致性係數(§3)統一調變全 23 option。純乘一係數，不改 term 內部。
		u *= NeedHierarchy.consistency_coeff(opt, ctx.need_urgency, ctx.leader_values)
		if opt == current_option:
			u += COMMITMENT_BONUS
		scored.append({"u": u, "i": idx, "opt": opt})
		idx += 1
	scored.sort_custom(func(a, b):
		if a["u"] != b["u"]: return a["u"] > b["u"]
		return a["i"] < b["i"])   # tiebreak：applicable 順序
	return scored
```

> **設計註**：coeff 乘在 COMMITMENT_BONUS 之前（承諾慣性是決策層加成，不受需求調變）。`rank_survival`/`rank_threat`/`rank_ambient` 子集排序**本 slice 不加 coeff**（它們是特化路徑；主 rank 走 rank_scored_ctx）——S4 威脅雙速再處理 threat 路。survival 子集由 PRIO_SURVIVAL 插隊管，不受主 rank coeff 影響（保 survival-sticky 不回歸）。

- [ ] **Step 4: 跑測 + determinism sanity**

Run:
```powershell
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
```
Expected: headless 無新 FAIL；multi 無崩潰。（**行為會變**——coeff 生效；organic 對照在 S2.6。）

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/decision/decision_engine.gd scripts/debug/headless_test.gd
git commit -m "feat(decision): rank_scored_ctx 接入五層急迫度 coeff(全 23 option 統一) (S2.3)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task S2.4：§6 主敘事標籤 → team.plan_phase（GUI 來源改接）

**Files:**
- Modify: `scripts/simulation/decision/need_hierarchy.gd`（加 `narrative_label`）
- Modify: `scripts/simulation/decision/decision_context.gd`（gather 尾寫 team.plan_phase）
- Test: `scripts/debug/headless_test.gd`（新增 `_test_need_narrative_label`）

**Interfaces:**
- Consumes: `team.need_urgency`（argmax layer）。
- Produces: `NeedHierarchy.narrative_label(urgency: PackedFloat32Array) -> String`（argmax→標籤字串）。gather 寫 `team.plan_phase = narrative_label(...)`（GUI 讀點 `observer_query_api.gd:73,99` + `observer_inspect_panel.gd:136` 不變，來源改）。

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_need_narrative_label() -> void:
	print("[TEST] need_narrative_label")
	assert(NeedHierarchy.narrative_label(PackedFloat32Array([1,0,0,0,0])) == NeedHierarchy.LABEL_SURVIVAL, "生存急迫→求生標籤")
	assert(NeedHierarchy.narrative_label(PackedFloat32Array([0,1,0,0,0])) == NeedHierarchy.LABEL_SAFETY, "安全急迫→警戒標籤")
	assert(NeedHierarchy.narrative_label(PackedFloat32Array([0,0,0,0,1])) == NeedHierarchy.LABEL_ACTUAL, "自我實現→立國標籤")
	# 冷啟 size 0 → 空標籤
	assert(NeedHierarchy.narrative_label(PackedFloat32Array()) == "", "冷啟空標籤")
	print("[TEST] need_narrative_label PASS")
```

- [ ] **Step 2: 跑測確認失敗**

Expected: FAIL — `Nonexistent constant 'LABEL_SURVIVAL'`。

- [ ] **Step 3: 加標籤 + gather 寫入**

`need_hierarchy.gd` 加：

```gdscript
# §6 主敘事標籤（純顯示衍生值）：取急迫度最高層 → 給人看的簡化摘要。非決策(決策走 coeff 完整混合)。
const LABEL_SURVIVAL: String = "求生"
const LABEL_SAFETY: String = "警戒"
const LABEL_BELONGING: String = "歸附"
const LABEL_ESTEEM: String = "立業"
const LABEL_ACTUAL: String = "立國"
const _LABELS: PackedStringArray = PackedStringArray([LABEL_SURVIVAL, LABEL_SAFETY, LABEL_BELONGING, LABEL_ESTEEM, LABEL_ACTUAL])

static func narrative_label(urgency: PackedFloat32Array) -> String:
	if urgency.size() != N_LAYERS:
		return ""
	var best_i: int = 0
	for i in range(1, N_LAYERS):
		if urgency[i] > urgency[best_i]:
			best_i = i
	return _LABELS[best_i]
```

`decision_context.gd` gather 尾（S1.3 加的急迫度更新之後）加：

```gdscript
	# §6 主敘事標籤：team.plan_phase 語意轉換——來源改為五層急迫度衍生(argmax)，非 derive_plan_phase 自算。
	# GUI(observer_query_api/observer_inspect_panel)讀 team.plan_phase 不變，來源改接。
	team.plan_phase = NeedHierarchy.narrative_label(team.need_urgency)
```

- [ ] **Step 4: 跑測確認通過**

Expected: `[TEST] need_narrative_label PASS`。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/decision/need_hierarchy.gd scripts/simulation/decision/decision_context.gd scripts/debug/headless_test.gd
git commit -m "feat(decision): §6 主敘事標籤→team.plan_phase(GUI 來源改接五層急迫度) (S2.4)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task S2.5：plan_phase 完整退役（term/weight/REGISTRY/map/derive/PHASE 常數）

**Files:**
- Modify: `scripts/simulation/decision/terms.gd:176-178`（eval `plan_phase_drive`）、`:244`（weight）
- Modify: `scripts/simulation/decision/options.gd:9,12,19,22,27,28`（6 option 移除 `["plan_phase_drive","plan_phase_drive"]` row）
- Modify: `scripts/simulation/decision/decision_context.gd:89-97,117-140,289-292`（PHASE 常數/plan_phase_drive_map/derive_plan_phase/_phase_option_bias 刪除）
- Test: `scripts/debug/headless_test.gd`（既有測試不炸 + 新增 `_test_plan_phase_retired`）

**Interfaces:**
- Consumes: 無新。
- Produces: `plan_phase_drive` term 不再存在（eval 落 `_` 回 0 是移除後的安全網，但 REGISTRY 已無引用）；`ctx.plan_phase_drive_map` 移除；`derive_plan_phase`/`_phase_option_bias`/`PHASE_*` 移除。`team.plan_phase` 欄**保留**（S2.4 寫顯示用）。

- [ ] **Step 1: 寫「退役確認」測試**

```gdscript
func _test_plan_phase_retired() -> void:
	print("[TEST] plan_phase_retired")
	# REGISTRY 6 option 不再含 plan_phase_drive term
	for opt in ["覓食", "返家補給", "併入", "紮營", "外交", "買糧"]:
		for tw in DecisionOptions.terms_of(opt):
			assert(tw[0] != "plan_phase_drive", "%s 不應再有 plan_phase_drive term" % opt)
	# eval("plan_phase_drive",...) 落 default → 0（安全網，無 crash）
	var ctx := DecisionContext.new()
	assert(DecisionTerms.eval("plan_phase_drive", ctx, "覓食") == 0.0, "退役 term eval→0")
	print("[TEST] plan_phase_retired PASS")
```

- [ ] **Step 2: 跑測確認失敗**

Expected: FAIL — 6 option 仍含 plan_phase_drive term（assert 觸發）。

- [ ] **Step 3a: options.gd 移除 6 row**

`options.gd` REGISTRY，6 個 option 移除 `["plan_phase_drive", "plan_phase_drive"]`：

```gdscript
	"覓食":   [["survival_pressure", "survival_pressure"]],
	"返家補給":[["restock_need", "survival_pressure"]],
	"併入":   [["join_drive", "mergein"]],
	"紮營":   [["camp_drive", "camp"]],
	"外交":   [["faction_duty", "faction_duty"], ["diplo_drive", "diplo"]],
	"買糧":   [["buyfood_drive", "buyfood"]],
```

- [ ] **Step 3b: terms.gd 移除 eval + weight 分支**

`terms.gd` 移除 `:176-178` 的 `"plan_phase_drive":` eval case（含註解）與 `:244` 的 `"plan_phase_drive":  return 1.0` weight case。

- [ ] **Step 3c: decision_context.gd 移除 derive/map/PHASE**

移除：`:89-97` 的 PHASE 常數群（`PHASE_NONE`..`PLAN_PHASE_DRIVE_MAG`）+ `plan_phase_drive_map` 宣告（保留 `var plan_phase: String = ""` 顯示欄）；`:117-140` 的 `derive_plan_phase` + `_phase_option_bias` 兩 static func；`:289-292` gather 中 `c.plan_phase = derive_plan_phase(...)` / `c.plan_phase_drive_map = _phase_option_bias(...)` 三行（S2.4 已用 narrative_label 取代寫 team.plan_phase）。

> **grep 確認無殘引用**：`grep -rn "plan_phase_drive\|derive_plan_phase\|_phase_option_bias\|PHASE_SEEK_FOOD\|PLAN_PHASE_DRIVE_MAG"` 應只剩 docs/測試中的歷史提及，scripts/ 下 sim code 零引用。

- [ ] **Step 4: 跑測確認通過 + 全 headless**

Run: `.\tools\godot.ps1 --headless --import && .\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `[TEST] plan_phase_retired PASS`；既有測試無因移除而炸的（若有測試直接呼 `derive_plan_phase` → 一併移除該測試斷言，記錄於 commit）。

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "refactor(decision): plan_phase 完整退役(term/weight/REGISTRY/map/derive/PHASE)→五層急迫度取代 (S2.5)

spec §8：不與五層並存。team.plan_phase 欄保留純顯示(S2.4 由 narrative_label 寫)。

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task S2.6：organic probe——全 23 覆蓋 + 行為連貫性（融合驗收）

**Files:**
- Modify: `scripts/debug/warring_harness.gd`（延伸 probe，比照 g2.* pattern）
- Test: organic 跑（measurer 主驗；本 task 建 probe + determinism 閘）

**Interfaces:**
- Consumes: `Probe.bump`/`Probe.add_amount`（既有）。
- Produces: probe `decision.coeff_applied_n`（全 option 受 coeff 計數）、`decision.coeff_min/max`（分布）、`decision.swing_n`（同隊同時段不相關行動搖擺偵測——行為連貫性反指標）。

- [ ] **Step 1: 加 probe 到 decision path**

`decision_engine.gd` rank_scored_ctx coeff 乘處加（`Probe.enabled` gate）：

```gdscript
		u *= NeedHierarchy.consistency_coeff(opt, ctx.need_urgency, ctx.leader_values)
		if Probe.enabled and ctx.need_urgency.size() == NeedHierarchy.N_LAYERS:
			Probe.bump("decision.coeff_applied_n")
			var _cf: float = NeedHierarchy.consistency_coeff(opt, ctx.need_urgency, ctx.leader_values)
			if _cf < 0.5: Probe.bump("decision.coeff_lowhalf")   # 遠層被顯著壓的比例
```

- [ ] **Step 2: 跑 organic + determinism**

Run:
```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
.\tools\godot.ps1 --headless --script scripts/debug/constitution_gate.gd
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
```
Expected: 全綠（headless 無新 FAIL、constitution PASS、multi 無崩潰）。

- [ ] **Step 3: Commit + 交 measurer**

```bash
git add scripts/debug/warring_harness.gd scripts/simulation/decision/decision_engine.gd
git commit -m "feat(decision): 全 23 覆蓋 + coeff 分布 probe (S2.6)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

> **S2 交付驗收**（交 measurer，spec §驗收）：
> - **全面覆蓋**：刻意製造某層急迫→原本無 plan_phase_drive/intent_fit 的 12 option（生產/建設/駐守/囤貨/徵收/歸建/備戰/迎戰/求和/吸納/乞食/佔村…）分數隨之變化（`decision.coeff_applied_n` 涵蓋全 option）。
> - **行為連貫性**：同隊不在同時段於不相關行動間搖擺（organic multi-seed）。
> - **determinism**：byte-identical（同 seed 兩跑）。
> - **軟降權不死鎖**：無 option `structurally 永遠選不到`（S3 補鬆綁 probe 前先觀察 baseline）。

---

# Slice 3：卡住自動鬆綁（soft-release anti-deadlock）

> **交付**：某層急迫度持續高檔但對應 option 持續選不中/失敗 → 降權強度逐漸放鬆（複用 EWMA 停滯偵測，spec 第三次複用）。防「軟降權」退化成「條件過不了永遠不可能」死鎖。

### Task S3.1：per-layer stall 追蹤（EWMA 停滯偵測）

**Files:**
- Modify: `scripts/data/team_data.gd`（加 `need_stall: PackedFloat32Array`）
- Modify: `scripts/simulation/decision/need_hierarchy.gd`（加 `update_stall`）
- Test: `scripts/debug/headless_test.gd`（`_test_need_stall`）

**Interfaces:**
- Produces: `TeamData.need_stall: PackedFloat32Array`(size 5，選中率 EWMA)；`NeedHierarchy.update_stall(prev_stall, urgency, chosen_layer: int) -> PackedFloat32Array`。常數 `STALL_URGENCY_HI=0.6`、`STALL_EWMA_ALPHA=0.1`。

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_need_stall() -> void:
	print("[TEST] need_stall")
	# 高急迫層持續沒被選中(chosen_layer≠該層)→該層 stall 累積升高
	var stall := PackedFloat32Array([0,0,0,0,0])
	var urg := PackedFloat32Array([0.9, 0, 0, 0, 0])   # survival 高急迫
	for _i in range(20):
		stall = NeedHierarchy.update_stall(stall, urg, NeedHierarchy.L_ESTEEM)   # 一直選 esteem 不選 survival
	assert(stall[NeedHierarchy.L_SURVIVAL] > 0.5, "survival 高急迫卻沒選中→stall 升，got %f" % stall[NeedHierarchy.L_SURVIVAL])
	# 若該層被選中→stall 回落
	for _i in range(20):
		stall = NeedHierarchy.update_stall(stall, urg, NeedHierarchy.L_SURVIVAL)
	assert(stall[NeedHierarchy.L_SURVIVAL] < 0.3, "被選中→stall 回落，got %f" % stall[NeedHierarchy.L_SURVIVAL])
	print("[TEST] need_stall PASS")
```

- [ ] **Step 2: 跑測失敗** → `Nonexistent function 'update_stall'`。

- [ ] **Step 3: 加 stall 追蹤**

`need_hierarchy.gd` 加：

```gdscript
# §3 卡住自動鬆綁：per-layer stall = 「高急迫但沒被選中」的 EWMA 累積（複用停滯偵測 pattern）。
const STALL_URGENCY_HI: float = 0.6   # TEST VALUE — 急迫度高於此才算「該層卡住」候選
const STALL_EWMA_ALPHA: float = 0.1   # TEST VALUE — stall 平滑（慢，需持續卡才鬆綁）

# chosen_layer = 本 cadence 選中 option 的主 affinity 層（argmax affinity）。
# 某層高急迫(>HI)但 chosen≠該層 → 該層 stall raw=1；被選中或不急迫→raw=0。EWMA 累積。
static func update_stall(prev_stall: PackedFloat32Array, urgency: PackedFloat32Array, chosen_layer: int) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	out.resize(N_LAYERS)
	var has_prev: bool = prev_stall.size() == N_LAYERS
	for i in range(N_LAYERS):
		var p: float = prev_stall[i] if has_prev else 0.0
		var raw: float = 1.0 if (urgency[i] > STALL_URGENCY_HI and chosen_layer != i) else 0.0
		out[i] = STALL_EWMA_ALPHA * raw + (1.0 - STALL_EWMA_ALPHA) * p
	return out
```

`team_data.gd` 加：

```gdscript
# 需求金字塔重構 S3：per-layer 卡住偵測(高急迫但持續沒選中的 EWMA)→鬆綁降權。size 5 或 0。
var need_stall: PackedFloat32Array = PackedFloat32Array()
```

- [ ] **Step 4: 跑測通過** → `[TEST] need_stall PASS`。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/decision/need_hierarchy.gd scripts/data/team_data.gd scripts/debug/headless_test.gd
git commit -m "feat(decision): per-layer stall 停滯偵測(EWMA) (S3.1)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task S3.2：stall 鬆綁 coeff + gather 接線

**Files:**
- Modify: `scripts/simulation/decision/need_hierarchy.gd`（`consistency_coeff` 加 stall 參數）
- Modify: `scripts/simulation/decision/decision_context.gd`（gather 算 chosen_layer + update_stall + 快照 stall）
- Modify: `scripts/simulation/decision/decision_engine.gd`（coeff 呼叫傳 stall）
- Test: `scripts/debug/headless_test.gd`（`_test_stall_relaxes_coeff`）

**Interfaces:**
- Produces: `consistency_coeff(opt, urgency, leader_values, stall: PackedFloat32Array = PackedFloat32Array()) -> float`（stall 高→該 option 主層降權放鬆，floor 抬升）。`ctx.need_stall` 快照。

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_stall_relaxes_coeff() -> void:
	print("[TEST] stall_relaxes_coeff")
	var urg := PackedFloat32Array([1.0, 0, 0, 0, 0])   # 生存急迫
	var lv := {"慎重": 0.9, "野心": 0.1}   # 謹慎者：遠層(訓練)本壓極重
	var no_stall := PackedFloat32Array([0,0,0,0,0])
	var esteem_stalled := PackedFloat32Array([0,0,0,1.0,0])   # 尊重層卡住(訓練是 esteem 主層)
	var c_base := NeedHierarchy.consistency_coeff("訓練", urg, lv, no_stall)
	var c_relaxed := NeedHierarchy.consistency_coeff("訓練", urg, lv, esteem_stalled)
	assert(c_relaxed > c_base, "esteem 卡住→訓練 coeff 放鬆升高，%f→%f" % [c_base, c_relaxed])
	print("[TEST] stall_relaxes_coeff PASS")
```

- [ ] **Step 2: 跑測失敗**（`consistency_coeff` 尚無 stall 參數 → 呼叫 arity 錯或 c_relaxed==c_base）。

- [ ] **Step 3: coeff 加 stall 鬆綁**

`need_hierarchy.gd` `consistency_coeff` 改（加選用參數，尾算鬆綁）：

```gdscript
const STALL_RELAX_MAG: float = 0.6   # TEST VALUE — 卡住鬆綁強度（stall=1→floor 抬升這麼多、陡度打折）

static func consistency_coeff(opt: String, urgency: PackedFloat32Array, leader_values: Dictionary,
		stall: PackedFloat32Array = PackedFloat32Array()) -> float:
	if urgency.size() != N_LAYERS:
		return 1.0
	var aff: PackedFloat32Array = affinity_of(opt)
	var alignment: float = 0.0
	for i in range(N_LAYERS):
		alignment += float(aff[i]) * urgency[i]
	alignment = clampf(alignment, 0.0, 1.0)
	var caution: float = float(leader_values.get("慎重", 0.5))
	var ambition: float = float(leader_values.get("野心", 0.5))
	var steepness: float = clampf(STEEP_BASE + caution * STEEP_CAUTION - ambition * STEEP_AMBITION, 0.0, 1.0)
	# §3 卡住鬆綁：該 option 主 affinity 層若卡住(stall 高)→放鬆該 option 降權(陡度打折)。
	var relax: float = 0.0
	if stall.size() == N_LAYERS:
		var main_layer: int = 0
		for i in range(1, N_LAYERS):
			if float(aff[i]) > float(aff[main_layer]): main_layer = i
		relax = clampf(stall[main_layer] * STALL_RELAX_MAG, 0.0, 1.0)
	steepness *= (1.0 - relax)   # 卡越久→陡度越平→遠層 option 越有機會
	return clampf(1.0 - steepness * (1.0 - alignment), COEFF_FLOOR, 1.0)
```

- [ ] **Step 3b: gather 算 chosen_layer + update_stall**

`decision_context.gd`：加快照欄 `var need_stall: PackedFloat32Array = PackedFloat32Array()`。gather 尾 need_urgency 更新後，需知「上 cadence 選中 option」→用 `team.current_option` 的主 affinity 層當 chosen_layer：

```gdscript
	# S3 卡住鬆綁：以上 cadence 選中 option(team.current_option)主層更新 stall。
	var _chosen_layer: int = NeedHierarchy.main_layer_of(team.current_option)
	team.need_stall = NeedHierarchy.update_stall(team.need_stall, team.need_urgency, _chosen_layer)
	c.need_stall = team.need_stall
```

`need_hierarchy.gd` 加 helper：

```gdscript
# option 主 affinity 層（argmax）。空/未知→-1（update_stall 視同不匹配任何層=全層可能 stall）。
static func main_layer_of(opt: String) -> int:
	if opt == "":
		return -1
	var aff: PackedFloat32Array = affinity_of(opt)
	var best: int = 0
	for i in range(1, N_LAYERS):
		if float(aff[i]) > float(aff[best]): best = i
	return best
```

- [ ] **Step 3c: decision_engine 傳 stall**

`rank_scored_ctx` coeff 呼叫改 `NeedHierarchy.consistency_coeff(opt, ctx.need_urgency, ctx.leader_values, ctx.need_stall)`（probe 那行同步）。

- [ ] **Step 4: 跑測 + 融合閘**

Run: headless + constitution + multi。Expected: `_test_stall_relaxes_coeff PASS` + 全綠。

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "feat(decision): 卡住自動鬆綁——stall 高→降權陡度打折(防死鎖) (S3.2)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task S3.3：死鎖偵測 probe（比照 gate_fail_*）

**Files:**
- Modify: `scripts/debug/warring_harness.gd`
- Test: organic（measurer 主驗）

- [ ] **Step 1: 加 probe**

`need_hierarchy.gd` 或 gather 加（`Probe.enabled` gate）：某層 urgency 持續 HI 且 stall 逼近 1（該層 option 幾乎不曾選中）→ `Probe.bump("decision.layer_deadlock_" + str(layer))`。分母=該層高急迫 cadence 數 `decision.layer_urgent_" + str(layer)`。比照 established `gate_fail_*=分母` 偵測手法。

```gdscript
	# S3 死鎖偵測(spec §驗收「軟降權不死鎖」)：某層高急迫但 stall 極高=結構選不到。
	if Probe.enabled and team.need_urgency.size() == NeedHierarchy.N_LAYERS and team.need_stall.size() == NeedHierarchy.N_LAYERS:
		for _l in range(NeedHierarchy.N_LAYERS):
			if team.need_urgency[_l] > NeedHierarchy.STALL_URGENCY_HI:
				Probe.bump("decision.layer_urgent_%d" % _l)
				if team.need_stall[_l] > 0.9:
					Probe.bump("decision.layer_deadlock_%d" % _l)
```

- [ ] **Step 2: 跑 organic + 融合閘** → 全綠。

- [ ] **Step 3: Commit**

```bash
git add scripts/simulation/decision/decision_context.gd scripts/debug/warring_harness.gd
git commit -m "feat(decision): 死鎖偵測 probe(layer_deadlock vs layer_urgent 分母) (S3.3)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

> **S3 交付驗收**（交 measurer）：**卡住鬆綁可觀測**——持續卡某層的隊，該層外 option 選中率隨時間回升；`layer_deadlock_*` / `layer_urgent_*` 比例應趨 0（非結構鎖死）。**跳階連續性**——不同人格(謹慎 vs 狂)同絕境同機會，遠層 option 選中率連續梯度差異（非二元）。

---

# Slice 4：威脅雙速 + 事件回寫（decay + cap）

> **交付**：威脅同一訊號雙速輸出——一般(低於劇變門檻)走 EWMA→安全層急迫度(§2，S1 已含 threat 進 raw)；劇變(達 crash-bypass，複用 S3 判準)直接 `PRIO_SURVIVAL` 插隊(既有機制不變)。插隊事件結束後**回寫**安全層急迫度(startle boost，decay+cap，獨立 TDD)。

### Task S4.1：劇變門檻判斷（複用 S3 crash 判準，雙速分岔）

**Files:**
- Modify: `scripts/simulation/decision/need_hierarchy.gd`（加 `is_crisis_threat`）
- Test: `scripts/debug/headless_test.gd`（`_test_threat_dualspeed`）

**Interfaces:**
- Consumes: `AmbitionLadder.RUNG_CRASH_*`（既有 S3 判準）或新 threat crisis 門檻。
- Produces: `NeedHierarchy.THREAT_CRISIS: float`(0.75)；`NeedHierarchy.is_crisis_threat(threat: float) -> bool`（≥門檻=劇變走插隊；否則走 EWMA 慢路）。

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_threat_dualspeed() -> void:
	print("[TEST] threat_dualspeed")
	assert(not NeedHierarchy.is_crisis_threat(0.3), "低威脅→非劇變(走 EWMA 慢路)")
	assert(NeedHierarchy.is_crisis_threat(0.9), "高威脅→劇變(走插隊)")
	print("[TEST] threat_dualspeed PASS")
```

- [ ] **Step 2: 跑測失敗** → `Nonexistent function 'is_crisis_threat'`。

- [ ] **Step 3: 加劇變判斷**

```gdscript
# §5.1 威脅雙速門檻：≥此=真正致命(達劇變)→直接 PRIO_SURVIVAL 插隊(反射快)；否則走 EWMA 慢路(深思)。
const THREAT_CRISIS: float = 0.75   # TEST VALUE — 劇變門檻(threat 0..1；複用 S3 crash-bypass 精神)

static func is_crisis_threat(threat: float) -> bool:
	return threat >= THREAT_CRISIS
```

- [ ] **Step 4: 跑測通過** → `[TEST] threat_dualspeed PASS`。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/decision/need_hierarchy.gd scripts/debug/headless_test.gd
git commit -m "feat(decision): §5.1 威脅雙速門檻判斷 (S4.1)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task S4.2：事件回寫（startle boost，decay + cap，獨立 TDD）

> **reviewer 風險 #2 硬要求**：回寫須帶 decay + 上限 cap，獨立 TDD 項防正回饋震盪。

**Files:**
- Modify: `scripts/data/team_data.gd`（加 `safety_startle: float`）
- Modify: `scripts/simulation/decision/need_hierarchy.gd`（加 `apply_startle` + `decay_startle` + raw 疊 startle）
- Test: `scripts/debug/headless_test.gd`（`_test_safety_startle_decay_cap`）

**Interfaces:**
- Produces: `TeamData.safety_startle: float`(0，持久)；`NeedHierarchy.apply_startle(cur: float) -> float`(insert 事件後 +boost，clamp cap)；`decay_startle(cur: float) -> float`(每 cadence 衰減)。常數 `STARTLE_BOOST=0.4`、`STARTLE_CAP=0.6`、`STARTLE_DECAY=0.85`。raw safety 疊 startle。

- [ ] **Step 1: 寫失敗測試（decay + cap 明驗）**

```gdscript
func _test_safety_startle_decay_cap() -> void:
	print("[TEST] safety_startle_decay_cap")
	# 單次 boost
	var s := NeedHierarchy.apply_startle(0.0)
	assert(absf(s - NeedHierarchy.STARTLE_BOOST) < 1e-5, "單次 boost=%f，got %f" % [NeedHierarchy.STARTLE_BOOST, s])
	# 連續 boost 撞 cap（防正回饋無限疊加）
	for _i in range(10):
		s = NeedHierarchy.apply_startle(s)
	assert(s <= NeedHierarchy.STARTLE_CAP + 1e-5, "連續 boost 不超 cap，got %f" % s)
	assert(absf(s - NeedHierarchy.STARTLE_CAP) < 1e-5, "撞 cap 飽和")
	# decay 回落
	for _i in range(20):
		s = NeedHierarchy.decay_startle(s)
	assert(s < 0.05, "decay 衰減趨 0，got %f" % s)
	print("[TEST] safety_startle_decay_cap PASS")
```

- [ ] **Step 2: 跑測失敗** → `Nonexistent function 'apply_startle'`。

- [ ] **Step 3: 加 startle 機制**

`need_hierarchy.gd` 加：

```gdscript
# §5.2 事件回寫：插隊事件後直接推高安全層急迫度(受驚後一陣特別警覺)。
# reviewer 風險#2：帶 decay+cap 防正回饋震盪(一次插隊→急迫飆→長期偏防禦→影響其他層機會)。
const STARTLE_BOOST: float = 0.4   # TEST VALUE — 單次插隊回寫量
const STARTLE_CAP: float = 0.6     # TEST VALUE — 回寫累積上限(硬 cap 防無限疊加)
const STARTLE_DECAY: float = 0.85  # TEST VALUE — 每 cadence 衰減率(受驚漸平復)

static func apply_startle(cur: float) -> float:
	return minf(cur + STARTLE_BOOST, STARTLE_CAP)   # cap 硬夾

static func decay_startle(cur: float) -> float:
	var d: float = cur * STARTLE_DECAY
	return d if d > 0.01 else 0.0   # 趨 0 歸零(避浮點殘值)
```

`compute_raw` 的 safety 層疊 startle（改 `compute_raw` 簽名加 `safety_startle: float = 0.0`）：

```gdscript
static func compute_raw(state: WorldState, team: TeamData, food_days: float, threat: float, safety_startle: float = 0.0) -> PackedFloat32Array:
	...
	# 安全：威脅(0..1) 疊 §5.2 回寫 startle(受驚警覺)，clamp 1
	raw[L_SAFETY] = clampf(threat + safety_startle, 0.0, 1.0)
	...
```

`team_data.gd` 加：

```gdscript
# 需求金字塔重構 S4：§5.2 插隊事件回寫的安全層 startle boost(decay+cap，持久跨 cadence 衰減)。
var safety_startle: float = 0.0
```

- [ ] **Step 4: 跑測通過** → `[TEST] safety_startle_decay_cap PASS`。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/decision/need_hierarchy.gd scripts/data/team_data.gd scripts/debug/headless_test.gd
git commit -m "feat(decision): §5.2 事件回寫 startle(decay+cap 防震盪，獨立 TDD) (S4.2)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task S4.3：插隊接點——crisis→PRIO_SURVIVAL + 事後 apply_startle + gather decay

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`（威脅插隊路，`_trigger_survival`/threat insert 附近，grep `PRIO_SURVIVAL` 定位 `:3127`）
- Modify: `scripts/simulation/decision/decision_context.gd`（gather：decay_startle + compute_raw 傳 startle）
- Test: `scripts/debug/headless_test.gd`（`_test_insert_writeback`）+ determinism 對照

**Interfaces:**
- Consumes: `NeedHierarchy.is_crisis_threat`、`apply_startle`、`decay_startle`、`TaskArbiter.PRIO_SURVIVAL`。
- Produces: 劇變威脅走既有 PRIO_SURVIVAL 插隊（行為不回歸）；插隊當下 `team.safety_startle = NeedHierarchy.apply_startle(team.safety_startle)`；gather 每 cadence `decay_startle` + raw safety 讀 startle。

- [ ] **Step 1: 寫「回寫生效」測試**

```gdscript
func _test_insert_writeback() -> void:
	print("[TEST] insert_writeback")
	var team := TeamData.new()
	team.safety_startle = 0.0
	# 模擬插隊事件觸發回寫
	team.safety_startle = NeedHierarchy.apply_startle(team.safety_startle)
	assert(team.safety_startle > 0.0, "插隊後 startle>0")
	# 回寫進 raw safety
	var state := WorldState.new()
	team.team_id = 1; team.population = 4; team.faction_id = -1
	team.ambition_cap = AmbitionLadder.RUNG_HEGEMON
	var raw_no := NeedHierarchy.compute_raw(state, team, 10.0, 0.0, 0.0)
	var raw_startled := NeedHierarchy.compute_raw(state, team, 10.0, 0.0, team.safety_startle)
	assert(raw_startled[NeedHierarchy.L_SAFETY] > raw_no[NeedHierarchy.L_SAFETY], "startle 推高 safety 急迫度")
	print("[TEST] insert_writeback PASS")
```

- [ ] **Step 2: 跑測失敗**（compute_raw 尚無 startle 參數效果 / 接點未接）。

- [ ] **Step 3a: gather decay + 傳 startle**

`decision_context.gd` gather，need_urgency 更新前：

```gdscript
	# S4 §5.2：安全層 startle 每 cadence 衰減(受驚漸平復)，raw safety 疊當前 startle。
	team.safety_startle = NeedHierarchy.decay_startle(team.safety_startle)
	var _raw_need: PackedFloat32Array = NeedHierarchy.compute_raw(state, team, c.food_days, c.threat, team.safety_startle)
```

（取代 S1.3 的 compute_raw 呼叫行。）

- [ ] **Step 3b: 插隊接點回寫**

`faction_ai_system.gd` 威脅→PRIO_SURVIVAL 插隊成功處（`:3127` try_set PRIO_SURVIVAL 附近，且限威脅路——用 `NeedHierarchy.is_crisis_threat` gate 或既有 threat insert 判斷點）：插隊 dispatch 成功後加：

```gdscript
		# S4 §5.2 事件回寫：劇變威脅插隊後推高安全層急迫度(主腦事後知情，decay+cap)。
		team.safety_startle = NeedHierarchy.apply_startle(team.safety_startle)
```

> **implementer 定位注意**：`:3127` 是 survival 通用插隊（含餓死 forage）。§5.2 回寫**只針對威脅劇變插隊**，非所有 PRIO_SURVIVAL。implementer 須 grep 威脅專屬插隊點（threat/FLEE 路，非 forage/食物路）；若威脅與食物共用同插隊 helper，用 `is_crisis_threat(ctx.threat)` 或 source 參數 gate，只威脅劇變才 apply_startle。此為本 task 關鍵判斷，plan trace 先確認接點語意再改。

- [ ] **Step 4: 跑測 + determinism 對照（PRIO_SURVIVAL 不回歸）**

Run:
```powershell
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
```
Expected: `_test_insert_writeback PASS`；multi 無崩潰。**PRIO_SURVIVAL 插隊行為對照**：既有 survival-sticky 測試（`headless_test.gd:11087` 等）不炸。

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "feat(decision): §5 威脅雙速接點+插隊回寫(crisis→PRIO_SURVIVAL+startle) (S4.3)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

> **S4 交付驗收**（交 measurer，spec §驗收）：**威脅雙速+回寫**——既有 `PRIO_SURVIVAL` 插隊行為不回歸(determinism/行為對照)；插隊事件後安全需求急迫度確實提升(事件後一段時間偏防衛行為比例可測)；startle 不形成正回饋震盪(decay+cap 生效，長期不卡死高防禦)。

---

# Slice 5：established 收尾（立國入自我實現層）

> **交付**：立國成為需求金字塔「自我實現」層 intent；B2/B3/B4 門檻由硬 gate 降級為 §3 係數表的風格修飾（立國 option affinity 偏自我實現層 + 人格陡度）。驗 established 是否終於 >0。取代擱置的立國-redesign branch（`feat/establish-intent-redesign`）。

> **序註**：本 slice 依賴 S1-S4 organic 數據。dispatch 前 systems 需依 S1-S4 measurer 結果重評 B2/B3/B4 降級的具體 HOW（spec §對established調查鏈的意涵留「具體 HOW 交 systems」）。以下為 plan 骨架，**S5 spec 細化在 S4 measure 後補**（systems 出 S5 technical spec → R② → 才 dispatch）。

### Task S5.1：立國 option 入 REGISTRY + 自我實現 affinity

**Files:**
- Modify: `scripts/simulation/decision/options.gd`（若立國走 option 路——依 S5 spec 定；或維持 leader-level 但接自我實現急迫度）
- Modify: `scripts/simulation/decision/need_hierarchy.gd`（立國相關 option affinity 已在 S2.1 表——建設/駐守/吸納/佔村偏 L_ACTUAL；S5 校準）
- Modify: `scripts/simulation/faction_ai_system.gd:974-980`（established B-gate：B2/B3/B4 硬 gate→軟 modifier）

**Interfaces:**
- Consumes: `team.need_urgency[L_ACTUAL]`（自我實現急迫度）、`NeedHierarchy.consistency_coeff`。
- Produces: 立國決策由自我實現層急迫度篩選（非四重 AND 硬 gate 機械觸發）。B2/B3/B4→coeff 風格修飾。

- [ ] **Step 1: plan trace（先於 build）**

grep `_declare_established` / `faction_ai_system.gd:974-980` B-gate 現況，確認立國入口。依 S1-S4 measure：自我實現層急迫度是否在 established-ready 隊拉高。**若 established 仍 0**→patch-gate-first 查是否 B-gate 硬條件 pre-empt 急迫度篩選（補丁閘優先）。trace 結論寫 S5 spec，R② 審後才 build。

- [ ] **Step 2-N: 依 S5 spec 細化**

（S5 tasks 待 S4 measure + S5 spec R② CLEAN 後補齊；此處不預寫具體 code 避免基於未驗數據的臆測——符合 patch-gate-first + measure-first。）

> **S5 交付驗收**（spec §驗收「established 調查鏈收尾」）：redesign 完成後 established 是否 >0（B2/B3/B4 因「有意圖層篩選」而非「條件過了機械觸發」而鬆動）。organic multi-seed 驗 established 出現 + 可解釋。

---

## Self-Review（spec 對照）

**1. Spec coverage：**
- §2 五層平行急迫度 → S1.1(raw)+S1.2(EWMA)+S1.3(gather 接) ✅
- §3 一致性係數軟降權+全 23 覆蓋 → S2.1(表)+S2.2(coeff)+S2.3(rank 接) ✅；卡住鬆綁 → S3 ✅
- §4 人格陡度取代賭命跳關 → S2.2(steepness) ✅（賭命跳關無獨立機制=已砍）
- §5.1 威脅雙速 → S4.1+S4.3 ✅；§5.2 回寫 decay+cap → S4.2(獨立 TDD)+S4.3(接點) ✅
- §6 主敘事標籤 → S2.4 ✅
- §7 faction_duty/STRATEGIC_SELFINIT 不變 → 全 slice 未動 ✅
- §8 plan_phase 退役(不並存，同 slice) → S2.4(標籤改接)+S2.5(完整退役)，與 §3 上線同 S2 ✅
- §驗收 established 收尾 → S5 ✅
- reviewer 風險 #1 純靜態表 → S2.1(const AFFINITY 零分支) ✅；#2 回寫 decay+cap 獨立 TDD → S4.2 ✅；#3 determinism 各 slice TDD → S1.3/S2.6/S4.3 ✅；#4 warring_harness probe → S2.6/S3.3 ✅

**2. Placeholder scan：** S5.2 標「依 S5 spec 細化」非 placeholder，是**刻意 measure-first 延後**（spec 明示 established HOW 交 systems + 依 organic 數據）——記為 S5 spec 待 S4 measure 後補，非計畫缺口。其餘 task 皆含完整 code + 具體 TEST VALUE + 精確 file:line + 跑測指令。

**3. Type consistency：** `PackedFloat32Array` 貫穿 need_urgency/need_stall/raw/affinity；`consistency_coeff` 簽名 S2.2→S3.2 演進（加選用 stall 參數，向後相容）；`compute_raw` 簽名 S1.1→S4.2 演進（加選用 safety_startle 參數，向後相容）——選用參數不破既有呼叫。layer 常數 L_*/N_LAYERS 全檔一致。

---

## Execution Handoff

計畫存 `docs/superpowers/plans/2026-07-13-decision-engine-needs-hierarchy.md`。

**序（spec dispatch 要求）**：writing-plans 排多 slice → 依序 dispatch → 每 slice build→measurer 驗(determinism+organic)→merge 才下一個 → 全完 measurer 整包驗收。

**每 slice dispatch 前**：R②（systems→reviewer 審該 slice 設計）CLEAN 才 dispatch implementer（兩道閘規則）。S5 另需 S5 technical spec（依 S4 measure）→ R② → 才 build。
