# G3b multi-claim 儲存 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `team_intel[r][t]` single dict → **Array of sourced claim**（值/源/時效/可信度/失真，**不覆蓋**）。message 寫入停 confidence-max 覆蓋改 append/同源更新；`best_estimate` 聚合；`uncertainty` 換 claim 分歧；claim 上限/剪枝/LOD。改動全藏 `BeliefSystem` accessor 後（G3a de-risk）→ 決策讀者**零動**。

**Architecture:** G3a 已把 ~8 決策讀者遷 `BeliefSystem.best_estimate/uncertainty/has_belief`（行為保留，回現單 dict）。G3b 換 storage：accessor 內部由「回單 dict」改「聚合多 claim 回單 dict」。寫端三處（vision 親見 / interaction 親見 tier2 / message 傳播）改走新寫 accessor。**這不是行為保留改動**——多源不覆蓋 + 分歧不確定性是真行為變化（藍圖 WHAT）；回歸閘 = 1000 tick 無錯 + coin_eq=0 + InvariantAudit 0（**非**零漂移）。

**Tech Stack:** Godot 4.2.2 GDScript；`BeliefSystem` 擴充（已 class_name，改內容不需新註冊但仍 `--import`）；headless harness。

## Global Constraints

- wrapper 跑（UTF-8）；改 BeliefSystem/新測試後 `--import`。
- WHAT/HOW 來源：`specs/2026-06-19-g3-info-decision-design`（§3）、`...-how-design`（§3 G3b、§7 invariants）。
- 回歸閘：`=== DONE ===` + 0 assert fail + coin_eq=0 + InvariantAudit 0 + 1000 Tick。**不用 multi drift**（無 seed 不可重現，見 memory）。
- **OUT（非本 plan）**：可信度完整公式（類型表×trust 邊×跳數，G3c）、技能識破 / 觀察吃技能（G3c）、決策改讀 uncertainty + 查證迴路（G3d）、team_known 事件謠言 claim 化（G3c/d）。本 plan credibility 用 interim 簡值，決策仍讀 best_estimate（行為近 G3a，多源時改變）。

## 鎖定設計決策（實作者勿再設計）

- **claim shape**（spec §3）：
  ```gdscript
  { "value": Dictionary,     # 觀察到的欄（population_est/tile_pos/last_tick/tier/armed_est/... 沿用現 snap 欄）
    "source_id": int, "source_type": String, "tick": int,
    "credibility": float, "distorted": bool }
  ```
  `value` 內裝原 snap 欄；claim 是外殼。
- **storage canonical = Array**：所有寫端產 Array。
- **讀容錯（transitional）**：`claims()`/`best_estimate()` 讀到舊式 Dict（test 直設、漏遷寫端）→ coerce 成 `[{value:那dict, source_id:obs, source_type:"親見", tick:value.last_tick, credibility:1.0, distorted:false}]`。救 ~18 處 headless_test 直設 + 防崩。**不**在寫端容忍——寫端一律 Array。
- **同源更新 vs 跨源 append**：寫 claim 時找 array 中 `source_id` 相符者 → **更新該 claim**（fields merge 進 `value`、更新 tick/credibility/distorted）；無相符 → **append**。→ 親見 tier01+tier2 同 obs 源累積進同一 claim（保留現「snap duplicate 加欄」行為）；不同 giver 各留 claim（多源不覆蓋）。
- **best_estimate 聚合**：選 credibility 最高 claim（tie → tick 較新）→ 回其 `value` dict。讀者續 `.get(field,…)` 零動。空 → `{}`。
- **uncertainty**：≥2 claim 時 = 數值欄（`population_est` 或 `armed_est`）相對分歧度 `(max-min)/max`，clamp 0..1；單 claim → 沿用 `1-credibility`；無 claim → 1.0。TEST VALUE 欄選 population_est。
- **credibility interim（G3b）**：親見=1.0；relay = `min(來源 claim credibility, entry confidence) * (1-HOP_DECAY)`（無則 0.5 起）。G3c 換 `類型×trust×跳數×時效`。
- **caps（TEST VALUE）**：每 (r,t) cap `MAX_CLAIMS_PER_TARGET=4`，溢出剪最低 credibility（tie→最老 tick）；每 observer cap 總 claim `MAX_CLAIMS_PER_OBSERVER=200`，溢出剪最老。常數放 BeliefSystem。
- **sim_bridge:185 + inquiry 收尾**：UI 與 inquiry 仍直讀 `team_intel`（schema flip 前必遷，否則 UI 破 / inquiry 取錯）。

## File Structure

- `scripts/simulation/belief_system.gd`（擴充：claim 聚合 + 寫 accessor + caps）。
- 寫端遷移：`vision_system.gd:85-110`、`interaction_system.gd:653-701`、`message_system.gd:215-229`。
- 讀端收尾：`sim_bridge.gd:185`、`inquiry_system.gd:45-92`（key 迭代 → 新 `known_targets`）。
- 測試：`scripts/debug/headless_test.gd`。
- docs：`docs/invariants.md`、`docs/known_issues.md`。

---

### Task 1: 讀端收尾（sim_bridge + inquiry）— schema flip 前必先落地

> ⚠ **次序硬約束**：本 task 先 commit，再做 Task 2+ schema flip。否則 sim_bridge UI 直讀 raw dict、schema 變 Array 後 `.get("tile_pos")` 破。

**Files:**
- Modify: `scripts/ui/sim_bridge.gd:185`、`scripts/simulation/inquiry_system.gd:45,47,60,89,91`
- Create accessor: `scripts/simulation/belief_system.gd`（加 `known_targets`）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- 新 `BeliefSystem.known_targets(state, obs_id:int) -> Array`：回 `state.team_intel.get(obs_id, {}).keys()`（obs 對誰有 belief 的 tgt id 集；schema 無關，只取外層 keys）。

- [ ] **Step 1: 加 known_targets accessor**（行為保留，只取 keys）

```gdscript
static func known_targets(state: WorldState, obs_id: int) -> Array:
	return state.team_intel.get(obs_id, {}).keys()
```

- [ ] **Step 2: 遷 sim_bridge:185**

```gdscript
		var intel: Dictionary = BeliefSystem.best_estimate(_state, player_tid, tid)
```
（後續 `intel.get("tile_pos", ...)` 不變。G3a 下行為等價；G3b 後自動吃聚合。）

- [ ] **Step 3: 遷 inquiry key 迭代 + 取值**

`inquiry_system.gd`：`for tid in state.team_intel.get(team_id, {})` → `for tid in BeliefSystem.known_targets(state, team_id)`（:47、:60、:91 三處迴圈源）。取 entry 已走 `BeliefSystem.best_estimate`（:48/:63/:92），保留。:45/:89 的 `var intel: Dictionary = state.team_intel.get(...)` 純為迴圈源 → 刪該行、迴圈直接用 `known_targets`。

- [ ] **Step 4: --import + 回歸（行為零變）**

```
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`、既有測試 0 變動、coin_eq=0、InvariantAudit 0。

- [ ] **Step 5: 確認決策/UI 端無殘留直讀**

```bash
grep -rn "team_intel" scripts/ --include=*.gd | grep -v belief_system.gd | grep -v "team_intel\.has\|team_intel\[" | grep -v "= {.*:.*}"
```
Expected：剩餘只 = 寫端賦值（`team_intel[x][y]=` / `.has`）+ headless_test 直設。讀端全走 accessor。

- [ ] **Step 6: Commit**（schema flip 前的安全點）

```bash
git add scripts/simulation/belief_system.gd scripts/ui/sim_bridge.gd scripts/simulation/inquiry_system.gd scripts/debug/headless_test.gd
git commit -m "refactor(g3b): 遷 sim_bridge/inquiry 走 BeliefSystem(schema flip 前收尾讀端)"
```

---

### Task 2: BeliefSystem multi-claim 核心（聚合 + 寫 accessor + caps）

**Files:**
- Modify: `scripts/simulation/belief_system.gd`
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- `claims(state, obs, tgt) -> Array`：回 claim array（讀容錯：Dict→coerce 單 claim）。
- `best_estimate(state, obs, tgt) -> Dictionary`：最高 credibility claim 的 `value`（tie→新 tick）；空→`{}`。
- `uncertainty(state, obs, tgt) -> float`：≥2 claim→population_est 分歧 `(max-min)/max`；1 claim→`1-credibility`；0→1.0。
- `record_claim(state, obs, tgt, source_id, source_type, fields:Dictionary, credibility:float, distorted:bool) -> void`：同 source_id→更新（fields merge 進 value、刷 tick/cred/distorted）；無→append；寫後套 caps。
- 常數：`MAX_CLAIMS_PER_TARGET=4`、`MAX_CLAIMS_PER_OBSERVER=200`（TEST VALUE）。

- [ ] **Step 1: 寫失敗測試**（多源不覆蓋 + 聚合 + 分歧 + cap）

```gdscript
func _test_belief_multiclaim() -> void:
	print("--- G3b：multi-claim 儲存 ---")
	var s := WorldState.new(); s.world = WorldData.new()
	s.team_intel = {}
	# 親見：obs=1 對 tgt=2，源=自己
	BeliefSystem.record_claim(s, 1, 2, 1, "親見",
		{"population_est": 50, "tile_pos": Vector2i(3,3), "last_tick": 0}, 1.0, false)
	# 同源更新：累積欄、不新增 claim
	BeliefSystem.record_claim(s, 1, 2, 1, "親見", {"armed_est": 10}, 1.0, false)
	assert(BeliefSystem.claims(s, 1, 2).size() == 1, "同源更新非 append")
	assert(BeliefSystem.best_estimate(s, 1, 2).get("population_est") == 50, "親見 pop 留")
	assert(BeliefSystem.best_estimate(s, 1, 2).get("armed_est") == 10, "親見累積 armed")
	# 跨源：giver=9 傳低可信不同值 → append 不覆蓋
	BeliefSystem.record_claim(s, 1, 2, 9, "傳聞",
		{"population_est": 200, "last_tick": 5}, 0.4, true)
	assert(BeliefSystem.claims(s, 1, 2).size() == 2, "跨源 append 多源並存")
	assert(BeliefSystem.best_estimate(s, 1, 2).get("population_est") == 50, "best=最高可信(親見1.0)")
	assert(BeliefSystem.uncertainty(s, 1, 2) > 0.5, "分歧大→高不確定 (50 vs 200)")
	# 讀容錯：舊式 Dict
	s.team_intel[7] = {8: {"population_est": 30, "last_tick": 0}}
	assert(BeliefSystem.best_estimate(s, 7, 8).get("population_est") == 30, "Dict coerce 讀")
	assert(BeliefSystem.claims(s, 7, 8).size() == 1, "Dict coerce 單 claim")
	# cap：第 5 源溢出剪最低可信
	for src in [10, 11, 12]:
		BeliefSystem.record_claim(s, 1, 2, src, "傳聞", {"population_est": 60}, 0.3, false)
	assert(BeliefSystem.claims(s, 1, 2).size() <= BeliefSystem.MAX_CLAIMS_PER_TARGET, "cap 生效")
	assert(BeliefSystem.best_estimate(s, 1, 2).get("population_est") == 50, "cap 後親見仍在(最高可信)")
	print("multi-claim OK")
```

`_initialize()` 加。

- [ ] **Step 2: 跑 harness 驗證失敗**（`record_claim`/`claims`/`MAX_*` 不存在）

- [ ] **Step 3: 實作 BeliefSystem 核心**

```gdscript
class_name BeliefSystem

# team_intel[obs][tgt] = Array of claim（G3b multi-claim）。
# claim: { value:Dictionary, source_id:int, source_type:String, tick:int, credibility:float, distorted:bool }
# 禁直讀 state.team_intel（決策/UI 一律走此）。讀容錯舊式 Dict（test/transitional）。

const MAX_CLAIMS_PER_TARGET := 4    # TEST VALUE
const MAX_CLAIMS_PER_OBSERVER := 200  # TEST VALUE

static func _coerce(raw) -> Array:
	# Array → as-is；Dict（舊式/test）→ 單親見 claim；其餘 → []
	if raw is Array:
		return raw
	if raw is Dictionary and not raw.is_empty():
		return [{ "value": raw, "source_id": -1, "source_type": "親見",
			"tick": int(raw.get("last_tick", 0)),
			"credibility": float(raw.get("confidence", 1.0)), "distorted": false }]
	return []

static func claims(state: WorldState, obs_id: int, tgt_id: int) -> Array:
	return _coerce(state.team_intel.get(obs_id, {}).get(tgt_id, null))

static func has_belief(state: WorldState, obs_id: int, tgt_id: int) -> bool:
	return not claims(state, obs_id, tgt_id).is_empty()

static func known_targets(state: WorldState, obs_id: int) -> Array:
	return state.team_intel.get(obs_id, {}).keys()

static func best_estimate(state: WorldState, obs_id: int, tgt_id: int) -> Dictionary:
	var cs: Array = claims(state, obs_id, tgt_id)
	if cs.is_empty(): return {}
	var best: Dictionary = cs[0]
	for c in cs:
		if float(c["credibility"]) > float(best["credibility"]) \
				or (float(c["credibility"]) == float(best["credibility"]) and int(c["tick"]) > int(best["tick"])):
			best = c
	return best["value"]

static func uncertainty(state: WorldState, obs_id: int, tgt_id: int) -> float:
	var cs: Array = claims(state, obs_id, tgt_id)
	if cs.is_empty(): return 1.0
	if cs.size() == 1:
		return clampf(1.0 - float(cs[0]["credibility"]), 0.0, 1.0)
	var lo := INF; var hi := -INF
	for c in cs:
		var v: float = float((c["value"] as Dictionary).get("population_est", 0))
		lo = minf(lo, v); hi = maxf(hi, v)
	if hi <= 0.0: return 0.0
	return clampf((hi - lo) / hi, 0.0, 1.0)

static func record_claim(state: WorldState, obs_id: int, tgt_id: int,
		source_id: int, source_type: String, fields: Dictionary,
		credibility: float, distorted: bool) -> void:
	if not state.team_intel.has(obs_id):
		state.team_intel[obs_id] = {}
	var cs: Array = _coerce(state.team_intel[obs_id].get(tgt_id, null))
	var found := false
	for c in cs:
		if int(c["source_id"]) == source_id:
			(c["value"] as Dictionary).merge(fields, true)  # 同源累積/覆寫欄
			c["tick"] = int(state.world.current_tick)
			c["credibility"] = credibility
			c["distorted"] = distorted
			found = true
			break
	if not found:
		var v: Dictionary = {}
		v.merge(fields, true)
		cs.append({ "value": v, "source_id": source_id, "source_type": source_type,
			"tick": int(state.world.current_tick), "credibility": credibility, "distorted": distorted })
	_cap_target(cs)
	state.team_intel[obs_id][tgt_id] = cs
	_cap_observer(state, obs_id)

static func _cap_target(cs: Array) -> void:
	while cs.size() > MAX_CLAIMS_PER_TARGET:
		var worst := 0
		for i in range(1, cs.size()):
			if float(cs[i]["credibility"]) < float(cs[worst]["credibility"]) \
					or (float(cs[i]["credibility"]) == float(cs[worst]["credibility"]) and int(cs[i]["tick"]) < int(cs[worst]["tick"])):
				worst = i
		cs.remove_at(worst)

static func _cap_observer(state: WorldState, obs_id: int) -> void:
	var by_obs: Dictionary = state.team_intel[obs_id]
	var total := 0
	for t in by_obs:
		total += _coerce(by_obs[t]).size()
	# 溢出剪最老 claim（跨 tgt 找全域最老）
	while total > MAX_CLAIMS_PER_OBSERVER:
		var oldest_t = -1; var oldest_i = -1; var oldest_tick = INF
		for t in by_obs:
			var arr: Array = _coerce(by_obs[t])
			for i in arr.size():
				if int(arr[i]["tick"]) < oldest_tick:
					oldest_tick = int(arr[i]["tick"]); oldest_t = t; oldest_i = i
		if oldest_t == -1: break
		var arr2: Array = by_obs[oldest_t]
		arr2.remove_at(oldest_i)
		if arr2.is_empty(): by_obs.erase(oldest_t)
		total -= 1
```

> 注意 `current_tick`：`record_claim` 用 `state.world.current_tick` 寫 tick（不用 fields 的 last_tick），確保 cap 老化一致。fields 內仍可帶 last_tick 供讀者（沿用）。

- [ ] **Step 4: --import + 跑驗證通過**

Expected: `multi-claim OK`、`=== DONE ===`、既有測試（含 G3a `_test_belief_accessor`）仍綠（Dict coerce 保 G3a 行為）。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/belief_system.gd scripts/debug/headless_test.gd
git commit -m "feat(g3b): BeliefSystem multi-claim 聚合+寫 accessor+caps(讀容錯舊 Dict)"
```

---

### Task 3: 寫端遷移（vision / interaction 親見 + message 傳播停覆蓋）

**Files:**
- Modify: `vision_system.gd:85-110`、`interaction_system.gd:653-701`、`message_system.gd:215-229`
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: `BeliefSystem.record_claim`（Task2）。
- vision/interaction：親見 → `record_claim(state, obs, tgt, obs, "親見", snap_fields, 1.0, false)`。snap_fields = 現組的欄 dict（去掉直接賦值 `team_intel[obs][tgt]=snap`）。**同源更新**自動保留現「duplicate 既有 snap 加欄」累積（tier01 後 tier2 同 obs 源 merge）。
- message：giver 每 tgt 的 claim → distort → `record_claim(state, receiver, tgt, giver_id, source_type, distorted_fields, cred, distorted)`。**停 :222-224 confidence-max 覆蓋**（多源並存）。giver 端 source 取 `BeliefSystem.best_estimate(state, giver_id, tgt)`（giver 信什麼就傳什麼）。

- [ ] **Step 1: 寫失敗測試**（傳播多源不覆蓋 + 親見累積）

```gdscript
func _test_intel_writers_multiclaim() -> void:
	print("--- G3b：寫端多源 ---")
	# 既有 vision/interaction/message 整合測試應改驗 claim：
	#   - 親見後 claims(obs,tgt).size()==1 source==obs
	#   - 兩個不同 giver 傳同 tgt → receiver claims >=2（不覆蓋）
	#   - best_estimate 仍回最高可信源
	# 復用既有 _test_vision_* / message 交換 scenario，加 claims().size 斷言。
	print("intel writers OK")
```

> 既有 `_test_*`（vision tier、message 交換、:1859/:1933 等讀 `team_intel.get(70,{}).get(71,{})`）→ 改讀 `BeliefSystem.best_estimate(state,70,71)`。直設 snap（:1781/:2026 等）可留（Dict coerce）或改 record_claim；**讀斷言一律走 accessor**。

- [ ] **Step 2: 遷 vision_system `_write_tier01`**

組完 snap 欄（pop_est/tile_pos/last_tick/tier/resource_scale）後，取代尾行 `state.team_intel[obs_id][tgt_id] = snap`：
```gdscript
	BeliefSystem.record_claim(state, obs_id, tgt_id, obs_id, "親見", snap, 1.0, false)
```
（保留前段組 snap；同源更新使 tier 升級 merge 進親見 claim。注意：snap 開頭的 `state.team_intel[obs_id].get(tgt_id, {}).duplicate()` 改取 `BeliefSystem.best_estimate(state, obs_id, tgt_id).duplicate()` 當基底，保留現「在既有估值上累積」。）

- [ ] **Step 3: 遷 interaction_system `_write_tier2_intel`**

同模式：基底取 `BeliefSystem.best_estimate(...)`，尾行改 `record_claim(state, obs_id, tgt_id, obs_id, "親見", snap, 1.0, false)`。

- [ ] **Step 4: 遷 message_system `_share_intel`（:215-229 停覆蓋）**

```gdscript
	for tgt_id in BeliefSystem.known_targets(state, giver_id):
		if tgt_id == receiver_id: continue
		var src_val: Dictionary = BeliefSystem.best_estimate(state, giver_id, tgt_id)
		var entry: Dictionary = _distort_intel_entry(src_val, mode)
		if entry.is_empty(): continue
		var cred: float = (1.0 - HOP_DECAY) * float(entry.get("confidence", 0.5))
		var distorted: bool = mode in ["unintentional", "malicious"]
		BeliefSystem.record_claim(state, receiver_id, tgt_id, giver_id, mode, entry, cred, distorted)
		# 偵查識破 → 標該 source claim 可疑（找 source_id==giver 的 claim 設 value.is_suspicious）
```
刪 `:215 giver_intel`、`:222-224 existing_conf 覆蓋`。`:225-229` 偵查疑心：改在 receiver 對該 tgt 的 claims 找 `source_id==giver_id` 者 `c.value["is_suspicious"]=true`（或設 claim distorted 標記，擇一；保留 is_suspicious 欄供既有讀者）。

- [ ] **Step 5: --import + 回歸**

```
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`、coin_eq=0、InvariantAudit 0、1000 Tick。多源測試綠。**行為允許變**（多源/分歧），但守恆/不崩硬約束。

- [ ] **Step 6: 確認無殘留寫端覆蓋 + 直讀**

```bash
grep -rn "team_intel\[" scripts/simulation scripts/ui --include=*.gd | grep -v belief_system.gd
```
Expected：剩餘只 belief_system 內部寫 + headless_test 直設。生產寫端全走 record_claim。

- [ ] **Step 7: Commit**

```bash
git add scripts/simulation/vision_system.gd scripts/simulation/interaction_system.gd scripts/simulation/message_system.gd scripts/debug/headless_test.gd
git commit -m "feat(g3b): 寫端遷 record_claim(親見/傳播多源不覆蓋,停 confidence-max)"
```

---

### Task 4: invariant + known_issues + 全回歸

**Files:**
- Modify: `docs/invariants.md`、`docs/known_issues.md`

- [ ] **Step 1: invariant 補完**（spec §7）

`docs/invariants.md` belief 段擴：
```markdown
## belief 單一 accessor + multi-claim（G3b）
- 決策/UI 讀 `team_intel` 一律經 `BeliefSystem`（best_estimate/uncertainty/claims/has_belief/known_targets），**禁直讀 state.team_intel**（含 UI/inquiry）。
- storage = `team_intel[obs][tgt]` Array of claim（值/源/時效/可信度/失真）。寫端一律 `record_claim`。
- **多源不覆蓋**：claim 按 source_id 保留，同源更新、跨源 append，**禁 confidence-max 跨源覆蓋**（否則矛盾無從察）。
- **真值不隨行**：傳播失真寫 copy（`_distort_intel_entry` 回新 dict），原 claim 不被改。
- best_estimate = 最高 credibility claim 的 value（G3b interim 可信度；G3c 換 trust 公式）。uncertainty = claim 分歧。
- caps：每 (r,t)≤MAX_CLAIMS_PER_TARGET、每 observer≤MAX_CLAIMS_PER_OBSERVER（TEST VALUE，剪低可信/最老）。
```

- [ ] **Step 2: known_issues / 進度**

G3 進度：G3a accessor ✅ / **G3b multi-claim 儲存 ✅**（多源不覆蓋 + 分歧不確定 + caps；credibility interim、team_known 事件謠言未 claim 化）。G3c 可信度+trust+技能 / G3d 決策讀+查證 = 待。記 TEST VALUE：MAX_CLAIMS_*、uncertainty 欄選、relay cred 公式。

- [ ] **Step 3: 全回歸**

```
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`、coin_eq=0、InvariantAudit 0、1000 Tick。

- [ ] **Step 4: Commit**

```bash
git add docs/invariants.md docs/known_issues.md
git commit -m "docs(g3b): multi-claim invariant + G3 進度 + TEST VALUE 記錄"
```

---

## Self-Review 註記

- **次序硬約束**：Task1（sim_bridge/inquiry 讀端收尾）必先於 Task2+ schema flip，否則 UI/inquiry 讀 raw Array 破。Task1 行為保留、可獨立 commit。
- **讀容錯目的**：accessor coerce 舊 Dict → ~18 headless_test 直設不用全改、漏遷寫端不崩。canonical storage 仍 Array（生產寫端強制）。容錯是 transitional，G3c 可收緊。
- **行為非保留**（與 G3a 別）：多源不覆蓋 + 分歧 uncertainty 是真 WHAT 變化。回歸閘 = 不崩 + 守恆，**非**零漂移。既有讀斷言要改走 accessor（best_estimate）。
- **親見累積保真**：vision tier01→tier2 同 obs 源 → record_claim 同源 merge → 保留現「snap 加欄」行為。基底取 best_estimate 而非 raw `.get(tgt,{})`。
- **真值不隨行**：`_distort_intel_entry` 已回 `entry.duplicate()` 改寫 → 傳的是 copy，原 giver claim 不動。確認 record_claim 存的是 distort 後 entry（copy）。
- **OUT 邊界**：credibility 完整公式/trust 邊/技能識破/觀察吃技能（G3c）；決策改讀 uncertainty + 查證 scout（G3d）；team_known 事件謠言 claim 化（G3c/d）。本 plan 決策仍讀 best_estimate（單值面），多源僅改 belief 內容不改決策接口。
- **caps perf**：`_cap_observer` 全域掃最老 O(claims)，每寫一次——claim 總量受 MAX 約束故有界；若 profile 慢可改增量（OUT，量測後）。
- **執行確認**：新增 record_claim/claims/known_targets/MAX_* → `--import`；grep 確認讀端零直讀（Task1 Step5）、寫端零覆蓋（Task3 Step6）。
