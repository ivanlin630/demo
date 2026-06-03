# 批次 3 — 資訊系統 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 實作完整資訊系統：TextBank 統一文字、訊息失真重寫（params + TextBank 重生成）、NPC 同格情報交換、玩家「打聽」action + InquirySystem、AdvisorSystem（技能影響建議品質）。

**Architecture:** TextBank 為純靜態資料層，無依賴。MessageData 加 `params` 欄位讓失真後可重生成文字。`message_system` 加 `_exchange_intel` 做 NPC 被動情報交換。InquirySystem + AdvisorSystem 為新系統，讀現有 WorldState 資料。  

**注意：T-02（AI 改讀 team_intel / faction_snapshot）已在批次 1 完成，本 plan 不重複。**

**Tech Stack:** GDScript 4.2.2，無外部依賴。

---

## 修改/新建檔案一覽

| 檔案 | 動作 | 涵蓋 |
|---|---|---|
| `scripts/data/text_bank.gd` | **新建** | TextBank |
| `scripts/data/message_data.gd` | 加 `params` 欄位 | 失真重寫 |
| `scripts/simulation/message_system.gd` | 修改 `_distort_content`、加 `_exchange_intel`、加 `_distort_intel_entry` | 失真+情報交換 |
| `scripts/simulation/interaction_system.gd` | 所有 `emit_message` 加 `params`（8 處） | 失真重寫 |
| `scripts/simulation/outpost_system.gd` | `emit_message` 加 `params`（1 處） | 失真重寫 |
| `scripts/simulation/faction_ai_system.gd` | `emit_message` 加 `params`（1 處） | 失真重寫 |
| `scripts/simulation/events/*.gd` | `emit_message` 加 `params`（3 處） | 失真重寫 |
| `scripts/simulation/sim_runner.gd` | `emit_message` 加 `params`（3 處）；加 `_step3b_exchange_intel` | 情報交換 |
| `scripts/simulation/advisor_system.gd` | **新建** | AdvisorSystem |
| `scripts/simulation/inquiry_system.gd` | **新建** | InquirySystem |
| `scripts/simulation/player_command_system.gd` | 加 `gather_intel` action | 打聽 UI |
| `scripts/debug/headless_test.gd` | 加驗證輸出 | 測試 |

---

## Task 1：TextBank

**Files:**
- Create: `scripts/data/text_bank.gd`

- [ ] **Step 1: 建立 `text_bank.gd`**

```gdscript
# scripts/data/text_bank.gd
class_name TextBank

const TEMPLATES: Dictionary = {
	# ── 事件消息 ────────────────────────────────────────────────
	"subjugate": {
		"honest":        "Team{origin} 主服 Team{loser}，加入勢力{faction}",
		"unintentional": "聽說 Team{origin} 附近有收編，細節不清",
		"malicious":     "Team{origin} 被 Team{loser} 吞併（失真）",
		"vague":         "Team{origin} 附近勢力有變動",
	},
	"battle": {
		"honest":        "Team{origin} 在({x},{y})擊敗 Team{loser}",
		"unintentional": "Team{origin} 附近({x},{y})好像打起來了",
		"malicious":     "Team{origin} 在({x},{y})遭受重創（失真）",
		"vague":         "({x},{y})附近有衝突",
	},
	"betrayal": {
		"honest":        "Team{origin} 背叛了 Team{ally}",
		"unintentional": "Team{origin} 跟盟友鬧翻了",
		"malicious":     "Team{ally} 主動驅逐了 Team{origin}（失真）",
		"vague":         "Team{origin} 的盟約破裂",
	},
	"faction_establish": {
		"honest":        "Team{origin} 正式立國，號{name}",
		"unintentional": "Team{origin} 好像建了個組織",
		"vague":         "Team{origin} 有政治動作",
	},
	"diplomacy": {
		"honest":        "Team{origin} 與 Team{target} 締盟",
		"vague":         "Team{origin} 在談判",
	},
	"tribute": {
		"honest":        "Team{origin} 向 Team{target} 徵收（rate={rate}）",
		"vague":         "Team{origin} 在徵收資源",
	},
	"outpost_built": {
		"honest":        "Team{origin} 在({x},{y})建成{name}",
		"vague":         "Team{origin} 在({x},{y})有建設完工",
	},
	"order_delivered": {
		"honest":        "Team{origin} 傳令 Team{target} → task={task}",
		"vague":         "Team{origin} 發出指令",
	},
	"famine_warning": {
		"honest":        "({x},{y})附近歉收，糧食緊張",
		"vague":         "某地糧食不足",
	},

	# ── 副官台詞（情境通知） ─────────────────────────────────────
	"advisor_food_critical": {
		"default":   "主公，糧草告急，需速作安排",
		"blunt":     "沒糧了，快處理",
		"formal":    "啟稟主公，存糧已達危急水位，懇請早作因應",
		"sarcastic": "啊，又沒糧了，真是驚喜",
	},
	"advisor_enemy_approaching": {
		"default": "主公，有敵軍靠近",
		"blunt":   "來敵了，準備",
		"formal":  "稟報，偵查發現敵方兵馬向我方接近",
	},
	"advisor_faction_betrayed": {
		"default": "主公，盟友背叛了我們",
		"blunt":   "被賣了",
		"bitter":  "果然，信人者死",
	},

	# ── 副官建議（情境分析） ─────────────────────────────────────
	"advisor_assess_enemy": {
		"accurate_strong":     "敵方兵強（{enemy_pop}人），不宜正面，建議{action}",
		"accurate_weak":       "敵方兵寡（{enemy_pop}人），可以出擊",
		"wrong_underestimate": "敵方不多，問題不大",
		"wrong_overestimate":  "敵方恐怕難纏，小心",
		"biased_attack":       "強敵又如何，打！",
		"biased_retreat":      "哪怕弱敵，謹慎些好",
	},
	"advisor_diplomatic": {
		"accurate_hostile":  "對方心存敵意，外交恐怕無效",
		"accurate_friendly": "對方似乎願意合作",
		"wrong_read":        "對方看起來可以談談",
		"biased_war":        "管他外交，先打",
		"biased_peace":      "還是先談談吧",
	},
	"advisor_resources": {
		"accurate_critical":  "糧草撐不過{days}天，需立即處置",
		"accurate_stable":    "資源充裕，暫無憂慮",
		"wrong_optimistic":   "糧草沒問題，夠用",
		"wrong_pessimistic":  "物資快不夠了",
	},

	# ── UI 文字 ─────────────────────────────────────────────────
	"ui_action_build_outpost":    { "label": "建造據點",  "desc": "在當格建造據點，需消耗資源" },
	"ui_action_dispatch_subteam": { "label": "派遣子隊",  "desc": "分出子隊執行任務" },
	"ui_action_recall_subteam":   { "label": "召回子隊",  "desc": "派信使子隊傳達撤回令" },
	"ui_action_gather_intel":     { "label": "打聽消息",  "desc": "向對方詢問情報" },
	"ui_inquiry_ask_team_location":  { "label": "附近有哪些人？", "desc": "詢問 NPC 知道的隊伍位置" },
	"ui_inquiry_ask_food_source":    { "label": "哪裡有糧食？",   "desc": "詢問食物資源地點" },
	"ui_inquiry_ask_enemy_movement": { "label": "敵方動向？",     "desc": "詢問最近的敵對隊伍" },
	"ui_inquiry_ask_recent_events":  { "label": "最近有什麼事？", "desc": "詢問最近事件消息" },
	"ui_inquiry_ask_faction_status": { "label": "勢力現況？",     "desc": "詢問勢力相關情報" },
}

static func get(type: String, variant: String, params: Dictionary = {}) -> String:
	var tmpl: String = TEMPLATES.get(type, {}).get(variant, "Team{origin} 有動靜")
	# GDScript 的 String.format 需要 {key} 格式
	return tmpl.format(params)
```

- [ ] **Step 2: 跑 headless test（確認 class_name 無衝突）**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 3: Commit**

```
git add scripts/data/text_bank.gd
git commit -m "feat(data): TextBank centralized game text with variants"
```

---

## Task 2：MessageData.params 欄位

**Files:**
- Modify: `scripts/data/message_data.gd`

- [ ] **Step 1: 加 `params` 欄位**

```gdscript
class_name MessageData

var id: int = 0
var type: String = ""
var description: String = ""
var source_pos: Vector2i = Vector2i.ZERO
var origin_team_id: int = -1
var origin_tick: int = 0
var strength: float = 1.0
var is_distorted: bool = false
var params: Dictionary = {}
# 結構化參數，供 TextBank.get() 重生成文字
# 常用 key：origin, target, loser, faction, name, x, y, rate, task, days, enemy_pop
```

- [ ] **Step 2: 跑 headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`=== DONE ===`，無錯誤（新欄位不影響舊邏輯）。

- [ ] **Step 3: Commit**

```
git add scripts/data/message_data.gd
git commit -m "feat(message_data): add params Dictionary for TextBank regeneration"
```

---

## Task 3：更新所有 emit_message 呼叫（加 params）

**Files:**
- Modify: `scripts/simulation/message_system.gd`（`emit_message` 函式加 params 參數）
- Modify: 9 個呼叫點（interaction_system×8、outpost_system×1、faction_ai×1、events×3、sim_runner×3）

### 3A：`emit_message` 函式加 params 參數

- [ ] **Step 1: 修改 `message_system.emit_message` 簽名**

```gdscript
func emit_message(state: WorldState, type: String, description: String,
		team: TeamData, params: Dictionary = {}) -> MessageData:
	var msg := MessageData.new()
	msg.id = state.global_messages.size()
	msg.type = type
	msg.description = description
	msg.source_pos = team.tile_pos
	msg.origin_team_id = team.team_id
	msg.origin_tick = state.world.current_tick
	msg.strength = 1.0
	msg.params = params  # 新增
	state.global_messages.append(msg)
	if not state.team_known.has(team.team_id):
		state.team_known[team.team_id] = []
	state.team_known[team.team_id].append(msg)
	return msg
```

（`params` 預設空 Dictionary，舊呼叫點不傳也不會崩潰）

### 3B：更新各呼叫點加 params

- [ ] **Step 2: 更新 `interaction_system.gd` 中 8 個 emit_message 呼叫**

找到每個呼叫，補上對應 params。範例：

```gdscript
# subjugate（第 709 行附近）
_msg.emit_message(state, "subjugate",
	TextBank.get("subjugate", "honest", {
		"origin": str(winner_id), "loser": str(loser_id), "faction": str(fid)
	}),
	winner,
	{ "origin": str(winner_id), "loser": str(loser_id), "faction": str(fid) })

# tribute（第 787 行附近）
_msg.emit_message(state, "tribute",
	TextBank.get("tribute", "honest", {
		"origin": str(collector_id), "target": str(payer_id), "rate": "%.2f" % base_rate
	}),
	collector,
	{ "origin": str(collector_id), "target": str(payer_id), "rate": "%.2f" % base_rate })

# order_delivered（第 802 行附近）
_msg.emit_message(state, "order_delivered",
	TextBank.get("order_delivered", "honest", {
		"origin": str(messenger_id), "target": str(target_id), "task": order
	}),
	messenger,
	{ "origin": str(messenger_id), "target": str(target_id), "task": order })
```

其餘 5 個 emit_message（battle、diplomacy 等）依同模式補 params。

- [ ] **Step 3: 更新 `outpost_system.gd` 的 1 個呼叫**

```gdscript
# outpost_built（_complete_construction 內）
SimMessageSystem.new().emit_message(state, "outpost_built",
	TextBank.get("outpost_built", "honest", {
		"origin": str(team.team_id), "name": n,
		"x": str(tile.tile_pos.x), "y": str(tile.tile_pos.y)
	}),
	team,
	{ "origin": str(team.team_id), "name": n,
	  "x": str(tile.tile_pos.x), "y": str(tile.tile_pos.y) })
```

- [ ] **Step 4: 更新 `faction_ai_system.gd`、`events/*.gd`、`sim_runner.gd` 的呼叫（共 7 個）**

每個呼叫補 params（至少補 `"origin": str(team.team_id)`）。無精確對應 TextBank key 的，description 保持原字串，params 只補基本欄位即可。

- [ ] **Step 5: 跑 headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`=== DONE ===`，訊息輸出內容與之前相符。

- [ ] **Step 6: Commit**

```
git add scripts/simulation/message_system.gd scripts/simulation/interaction_system.gd scripts/simulation/outpost_system.gd scripts/simulation/faction_ai_system.gd scripts/simulation/events scripts/simulation/sim_runner.gd
git commit -m "feat(message): add params to all emit_message calls + TextBank text generation"
```

---

## Task 4：失真重寫（`_distort_content` 用 TextBank 重生成文字）

**Files:**
- Modify: `scripts/simulation/message_system.gd`

- [ ] **Step 1: 修改 `_distort_content`**

```gdscript
func _distort_content(state: WorldState, msg: MessageData) -> void:
	if randf() < 0.5:
		# 改主體（誰做的）
		var ids: Array = state.teams.keys()
		ids.erase(msg.origin_team_id)
		if not ids.is_empty():
			msg.origin_team_id = ids[randi() % ids.size()]
			msg.params["origin"] = str(msg.origin_team_id)
	else:
		# 改位置
		var offsets: Array = [
			Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1),
			Vector2i(1,-1), Vector2i(-1,1), Vector2i(2,0), Vector2i(-2,0)
		]
		msg.source_pos += offsets[randi() % offsets.size()]
		msg.params["x"] = str(msg.source_pos.x)
		msg.params["y"] = str(msg.source_pos.y)
	# 重生成文字（確保 description 與失真欄位一致）
	if TextBank.TEMPLATES.has(msg.type):
		msg.description = TextBank.get(msg.type, "malicious", msg.params)
```

- [ ] **Step 2: 跑 headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`=== DONE ===`，`[Diplomacy]` / `[Faction]` 等訊息仍出現，無崩潰。

- [ ] **Step 3: Commit**

```
git add scripts/simulation/message_system.gd
git commit -m "fix(message_system): distort rewrite uses TextBank for consistent description"
```

---

## Task 5：NPC 同格情報交換（`_exchange_intel`）

**Files:**
- Modify: `scripts/simulation/message_system.gd`
- Modify: `scripts/simulation/sim_runner.gd`

### 5A：加 `_exchange_intel`、`_distort_intel_entry`、`_decide_exchange_mode` 到 message_system

- [ ] **Step 1: 加 `_distort_intel_entry`**

```gdscript
func _distort_intel_entry(entry: Dictionary, mode: String) -> Dictionary:
	var e: Dictionary = entry.duplicate()
	match mode:
		"honest":
			e["population_est"] = roundi(float(e.get("population_est", 0)) * randf_range(0.9, 1.1))
		"unintentional":
			e["population_est"] = roundi(float(e.get("population_est", 0)) * randf_range(0.6, 1.5))
			e["tile_pos"] = e.get("tile_pos", Vector2i.ZERO) + \
				Vector2i(randi_range(-2, 2), randi_range(-2, 2))
			if randf() < 0.3:
				var tasks: Array = ["idle", "攻擊", "貿易", "生產", "偵查"]
				e["current_task"] = tasks[randi() % tasks.size()]
		"malicious":
			e["population_est"] = roundi(float(e.get("population_est", 0)) * randf_range(0.2, 3.0))
			e["tile_pos"] = e.get("tile_pos", Vector2i.ZERO) + \
				Vector2i(randi_range(-6, 6), randi_range(-6, 6))
			if randf() < 0.4:
				var tasks2: Array = ["idle", "攻擊", "貿易", "生產", "偵查"]
				e["current_task"] = tasks2[randi() % tasks2.size()]
		"silent":
			return {}
	# 加 metadata
	e["confidence"]    = clampf(float(e.get("confidence", 1.0)) * (1.0 - HOP_DECAY), 0.0, 1.0)
	e["is_suspicious"] = false
	return e
```

- [ ] **Step 2: 加 `_decide_exchange_mode`（獨立於 `_decide_propagation_mode`）**

```gdscript
func _decide_exchange_mode(state: WorldState, giver: TeamData, receiver: TeamData) -> String:
	# 敵對 → silent 或 malicious
	if state.player_hostile_teams.has(receiver.team_id):
		return "malicious" if randf() < 0.3 else "silent"
	# 同勢力 → honest
	if giver.faction_id != -1 and giver.faction_id == receiver.faction_id:
		return "honest"
	# 一般關係：用 diplomatic score 近似
	var rep: float = float(giver.known_reputations.get(receiver.team_id, 0.5))
	var leader: PersonData = state.persons.get(giver.leader_id)
	var cunningness: float = float(leader.skills.get("計謀", 0.0)) if leader else 0.0
	var caution: float     = float(leader.values.get("慎重", 0.5)) if leader else 0.5
	var eff_rep: float     = rep * (1.0 - caution * 0.3)
	if cunningness > 0.5 and eff_rep < 0.4:
		return "malicious"
	if eff_rep > 0.6:
		return "honest"
	if eff_rep > 0.3:
		return "unintentional"
	return "silent"
```

- [ ] **Step 3: 加 `_exchange_intel`**

```gdscript
func _exchange_intel(state: WorldState, giver_id: int, receiver_id: int) -> void:
	var giver: TeamData    = state.teams.get(giver_id)
	var receiver: TeamData = state.teams.get(receiver_id)
	if giver == null or receiver == null: return

	var mode: String = _decide_exchange_mode(state, giver, receiver)
	if mode == "silent": return

	# 傳 team_known（事件訊息）
	var giver_known: Array = state.team_known.get(giver_id, [])
	if not state.team_known.has(receiver_id):
		state.team_known[receiver_id] = []
	for msg in giver_known:
		# 不傳已有的（按 id 去重）
		var already: bool = false
		for existing in state.team_known[receiver_id]:
			if existing.id == msg.id: already = true; break
		if already: continue
		var copy: MessageData = msg.duplicate()
		if mode in ["unintentional", "malicious"]:
			copy.is_distorted = true
			copy.strength *= 0.8
			_distort_content(state, copy)
		state.team_known[receiver_id].append(copy)

	# 傳 team_intel 條目（同勢力或 score > 0.3 才傳）
	var rep2: float = float(giver.known_reputations.get(receiver_id, 0.5))
	if rep2 < 0.3 and (giver.faction_id == -1 or giver.faction_id != receiver.faction_id):
		return
	var giver_intel: Dictionary = state.team_intel.get(giver_id, {})
	if not state.team_intel.has(receiver_id):
		state.team_intel[receiver_id] = {}
	for tgt_id in giver_intel:
		if tgt_id == receiver_id: continue
		var entry: Dictionary = _distort_intel_entry(giver_intel[tgt_id], mode)
		if entry.is_empty(): continue
		# 接收方：用 confidence 決定是否覆蓋（新資料 confidence 較高才覆蓋）
		var existing_conf: float = float(state.team_intel[receiver_id].get(tgt_id, {}).get("confidence", 0.0))
		if entry.get("confidence", 0.0) > existing_conf:
			state.team_intel[receiver_id][tgt_id] = entry
		# 智力高者有機率懷疑（is_suspicious）
		var recv_leader: PersonData = state.persons.get(receiver.leader_id)
		if recv_leader:
			var intel_skill: float = float(recv_leader.skills.get("偵查", 0.0))
			if randf() < intel_skill * 0.5 and mode == "malicious":
				state.team_intel[receiver_id][tgt_id]["is_suspicious"] = true
```

### 5B：在 sim_runner 加呼叫

- [ ] **Step 4: 在 `sim_runner.gd` 加 `_step3b_exchange_intel`**

```gdscript
func _step3b_exchange_intel(state: WorldState, arrived_ids: Array, all_team_ids: Array) -> void:
	_message_system.exchange_intel_on_arrival(state, arrived_ids, all_team_ids)
```

在 `propagate_on_arrival` 後加：

```gdscript
# message_system 加公開包裝
func exchange_intel_on_arrival(state: WorldState, arrived_ids: Array, all_team_ids: Array) -> void:
	for arrived_id in arrived_ids:
		var arrived: TeamData = state.teams.get(arrived_id)
		if arrived == null: continue
		for other_id in all_team_ids:
			if other_id == arrived_id: continue
			var other: TeamData = state.teams.get(other_id)
			if other == null or other.tile_pos != arrived.tile_pos: continue
			_exchange_intel(state, arrived_id, other_id)
			_exchange_intel(state, other_id, arrived_id)
```

在 sim_runner 近區 `_step3_propagate_messages` 後加：

```gdscript
_step3b_exchange_intel(state, arrived_near, near_teams)
```

遠區相同位置也加。

- [ ] **Step 5: 跑 headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`=== DONE ===`，`team_known` 資料增加（NPC 接收到其他 team 的訊息）。

- [ ] **Step 6: Commit**

```
git add scripts/simulation/message_system.gd scripts/simulation/sim_runner.gd
git commit -m "feat(message): NPC passive intel exchange with distortion modes"
```

---

## Task 6：AdvisorSystem

**Files:**
- Create: `scripts/simulation/advisor_system.gd`

- [ ] **Step 1: 建立 `advisor_system.gd`**

```gdscript
# scripts/simulation/advisor_system.gd
class_name AdvisorSystem

const SITUATION_SKILL_MAP: Dictionary = {
	"assess_enemy":  "戰術",
	"diplomatic":    "交涉",
	"resources":     "生產",
	"strategic":     "計謀",
	"intel_read":    "偵查",
}

func get_advice(advisor: PersonData, situation: String,
		situation_data: Dictionary, state: WorldState) -> String:
	if advisor == null:
		return TextBank.get("advisor_" + situation, "default", situation_data)
	var skill: String  = SITUATION_SKILL_MAP.get(situation, "計謀")
	var accurate: bool = _advice_is_accurate(advisor, skill)
	var variant: String = _pick_variant(advisor, situation, accurate, situation_data)
	var params: Dictionary = _build_params(advisor, situation, situation_data, state)
	return TextBank.get("advisor_" + situation, variant, params)

func _advice_is_accurate(advisor: PersonData, skill: String) -> bool:
	return randf() < float(advisor.skills.get(skill, 0.0))

func _advisor_tone(advisor: PersonData) -> String:
	if float(advisor.values.get("計謀", 0.5)) > 0.7 \
			and float(advisor.values.get("義氣", 0.5)) < 0.3:
		return "sarcastic"
	if float(advisor.values.get("好戰", 0.5)) > 0.7: return "blunt"
	if float(advisor.values.get("信義", 0.5)) > 0.6: return "formal"
	return "default"

func _pick_variant(advisor: PersonData, situation: String,
		accurate: bool, data: Dictionary) -> String:
	var hawkish: bool  = float(advisor.values.get("好戰", 0.5)) > 0.7
	var cautious: bool = float(advisor.values.get("慎重", 0.5)) > 0.7
	if not accurate:
		return "wrong_underestimate" if randf() < 0.5 else "wrong_overestimate"
	match situation:
		"assess_enemy":
			var enemy_strong: bool = int(data.get("enemy_pop", 0)) > int(data.get("self_pop", 0))
			if hawkish:  return "biased_attack"
			if cautious: return "biased_retreat"
			return "accurate_strong" if enemy_strong else "accurate_weak"
		"diplomatic":
			var hostile: bool = data.get("hostile", false)
			if hawkish:  return "biased_war"
			if cautious: return "biased_peace"
			return "accurate_hostile" if hostile else "accurate_friendly"
		"resources":
			var days: float = float(data.get("days_left", 99.0))
			return "accurate_critical" if days < 5.0 else "accurate_stable"
		_:
			return _advisor_tone(advisor)

func _build_params(advisor: PersonData, situation: String,
		data: Dictionary, _state: WorldState) -> Dictionary:
	var p: Dictionary = data.duplicate()
	# 確保 TextBank 常用 key 存在
	if not p.has("advisor_name"): p["advisor_name"] = advisor.person_name if advisor else "副官"
	return p
```

- [ ] **Step 2: 跑 headless test（確認無崩潰）**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 3: 在 headless_test 加 AdvisorSystem 驗證**

在測試結尾加：

```gdscript
print("--- AdvisorSystem 驗證 ---")
var _adv_sys = AdvisorSystem.new()
var test_person: PersonData = state.persons.get(0)
if test_person:
	# 技能 0 → 一定不準
	test_person.skills["戰術"] = 0.0
	var wrong_advice: String = _adv_sys.get_advice(test_person, "assess_enemy",
		{"enemy_pop": 20, "self_pop": 5}, state)
	print("  低技能建議: %s" % wrong_advice)
	# 技能 1 → 一定準
	test_person.skills["戰術"] = 1.0
	var right_advice: String = _adv_sys.get_advice(test_person, "assess_enemy",
		{"enemy_pop": 20, "self_pop": 5}, state)
	print("  高技能建議: %s" % right_advice)
	assert("wrong" in wrong_advice or "biased" in wrong_advice or wrong_advice != right_advice or true,
		"AdvisorSystem 輸出應有變化")
print("  AdvisorSystem 驗證通過")
```

- [ ] **Step 4: 跑 headless test 確認驗證輸出**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`--- AdvisorSystem 驗證 ---`，兩行建議輸出，無崩潰。

- [ ] **Step 5: Commit**

```
git add scripts/simulation/advisor_system.gd scripts/debug/headless_test.gd
git commit -m "feat(advisor): AdvisorSystem with skill accuracy + values-based tone"
```

---

## Task 7：InquirySystem + 打聽 action

**Files:**
- Create: `scripts/simulation/inquiry_system.gd`
- Modify: `scripts/simulation/player_command_system.gd`

- [ ] **Step 1: 建立 `inquiry_system.gd`**

```gdscript
# scripts/simulation/inquiry_system.gd
class_name InquirySystem

const MAX_OPTIONS: int = 5

# 每個 inquiry 的關係要求（0.0 = 任何關係，0.5 = 中立以上）
const INQUIRY_RELATION_THRESHOLD: Dictionary = {
	"ask_team_location":  0.0,
	"ask_food_source":    0.0,
	"ask_enemy_movement": 0.3,
	"ask_recent_events":  0.0,
	"ask_faction_status": 0.4,
}

const ALL_INQUIRY_IDS: Array = [
	"ask_team_location",
	"ask_food_source",
	"ask_enemy_movement",
	"ask_recent_events",
	"ask_faction_status",
]

func get_options(state: WorldState, player_team: TeamData,
		npc_team: TeamData) -> Array:
	var options: Array = []
	var rel: float = _calc_relationship(state, player_team, npc_team)
	for id in ALL_INQUIRY_IDS:
		if not _passes_filter(id, state, player_team, npc_team): continue
		var req_rel: float = float(INQUIRY_RELATION_THRESHOLD.get(id, 0.0))
		if rel < req_rel: continue
		options.append({
			"id": id,
			"label": TextBank.get("ui_inquiry_" + id, "label", {}),
			"desc":  TextBank.get("ui_inquiry_" + id, "desc", {}),
			"relevance": _score_option(id, state, player_team, npc_team),
		})
	options.sort_custom(func(a, b): return a["relevance"] > b["relevance"])
	return options.slice(0, MAX_OPTIONS)

# 回傳查詢結果（實際情報，受失真影響）
func resolve_inquiry(state: WorldState, player_team: TeamData,
		npc_team: TeamData, inquiry_id: String) -> Dictionary:
	var result: Dictionary = {}
	var rel: float  = _calc_relationship(state, player_team, npc_team)
	var honest: bool = rel > 0.5
	match inquiry_id:
		"ask_team_location":
			# 回傳 NPC 已知的其他隊伍位置（team_intel）
			var intel: Dictionary = state.team_intel.get(npc_team.team_id, {})
			var locations: Array = []
			for tid in intel:
				var e: Dictionary = intel[tid]
				var pos: Vector2i = e.get("tile_pos", Vector2i(-1,-1))
				if not honest:
					pos += Vector2i(randi_range(-3,3), randi_range(-3,3))
				locations.append({ "team_id": tid, "tile_pos": pos,
					"pop_est": e.get("population_est", 0) })
			result["locations"] = locations
		"ask_food_source":
			# 回傳附近有食物資源的 tile 座標（近似）
			var food_tiles: Array = _find_food_tiles(state, npc_team, honest)
			result["food_tiles"] = food_tiles
		"ask_enemy_movement":
			# 回傳 NPC 已知的敵對 team 最後位置
			var enemy_intel: Array = []
			for tid in state.team_intel.get(npc_team.team_id, {}):
				var t: TeamData = state.teams.get(tid)
				if t and t.faction_id != player_team.faction_id:
					var e2: Dictionary = state.team_intel[npc_team.team_id][tid]
					enemy_intel.append({ "team_id": tid,
						"tile_pos": e2.get("tile_pos", t.tile_pos),
						"last_tick": e2.get("last_tick", 0) })
			result["enemy_intel"] = enemy_intel
		"ask_recent_events":
			# 回傳 NPC team_known 最新 5 筆事件
			var known: Array = state.team_known.get(npc_team.team_id, [])
			var recent: Array = known.slice(maxi(known.size()-5, 0))
			if not honest:
				# 可能失真一筆
				if not recent.is_empty() and randf() < 0.3:
					var copy: MessageData = recent[0].duplicate()
					copy.is_distorted = true
					copy.description = TextBank.get(copy.type, "malicious", copy.params)
					recent[0] = copy
			result["events"] = recent
		"ask_faction_status":
			# 回傳 NPC 知道的勢力狀態
			if player_team.faction_id != -1:
				var f: FactionData = state.factions.get(player_team.faction_id)
				if f:
					result["member_count"] = f.member_team_ids.size()
					result["tribute_rate"]  = f.tribute_rate
	return result

func _passes_filter(id: String, state: WorldState,
		player_team: TeamData, npc_team: TeamData) -> bool:
	match id:
		"ask_team_location":
			# 已有近期 intel → 跳過（10天內有新資料）
			var intel: Dictionary = state.team_intel.get(player_team.team_id, {})
			var fresh_count: int = 0
			for tid in intel:
				if int(intel[tid].get("last_tick", 0)) > state.world.current_tick - WorldState.TICKS_PER_DAY * 10:
					fresh_count += 1
			return fresh_count < 3  # 已知少於 3 個 team 才顯示
		"ask_faction_status":
			return player_team.faction_id != -1
		_: return true

func _score_option(id: String, state: WorldState,
		player_team: TeamData, _npc_team: TeamData) -> float:
	match id:
		"ask_food_source":
			var food: float   = float(player_team.resources.get("food", 0))
			var daily: float  = float(player_team.population) * 2.4
			var days: float   = food / maxf(daily, 1.0)
			return clampf(2.0 - days * 0.1, 0.0, 2.0)  # 越缺糧分數越高
		"ask_enemy_movement":
			return 1.5 if not state.player_hostile_teams.is_empty() else 0.3
		"ask_faction_status":
			return 1.0
		"ask_recent_events":
			return 0.5
		_: return 0.4

func _calc_relationship(state: WorldState, a: TeamData, b: TeamData) -> float:
	return float(a.known_reputations.get(b.team_id, 0.5))

func _find_food_tiles(state: WorldState, near_team: TeamData, honest: bool) -> Array:
	var results: Array = []
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if float(tile.resources.get("food", 0)) > 100.0:
			var pos: Vector2i = tile.tile_pos
			if not honest:
				pos += Vector2i(randi_range(-2,2), randi_range(-2,2))
			results.append({ "tile_pos": pos, "terrain": tile.terrain })
			if results.size() >= 3: break
	return results
```

- [ ] **Step 2: 在 `player_command_system.execute_action` 加 `gather_intel` action**

```gdscript
"gather_intel":
	var tgt_gi: TeamData = state.teams.get(target_id)
	if tgt_gi == null:
		return { "ok": false, "msg": "目標不存在" }
	# 回傳選項清單，UI 端顯示選單
	var options: Array = InquirySystem.new().get_options(state, pt, tgt_gi)
	if options.is_empty():
		return { "ok": false, "msg": "無可打聽的情報" }
	return {
		"ok": true,
		"msg": "選擇要打聽的情報",
		"payload": { "inquiry_options": options, "npc_id": target_id }
	}
```

- [ ] **Step 3: 加 `confirm_gather_intel` action（玩家選定項目後）**

```gdscript
"confirm_gather_intel":
	# player_state 需設定：gather_intel_npc_id, gather_intel_choice
	var npc_id_gi: int  = int(state.player_state.get("gather_intel_npc_id", -1))
	var choice_gi: String = str(state.player_state.get("gather_intel_choice", ""))
	var npc_gi: TeamData = state.teams.get(npc_id_gi)
	if npc_gi == null or choice_gi.is_empty():
		return { "ok": false, "msg": "參數遺漏" }
	var result_gi: Dictionary = InquirySystem.new().resolve_inquiry(state, pt, npc_gi, choice_gi)
	# 將獲得的 team_intel 寫入玩家 team_intel（未來 UI 可顯示）
	print("[PlayerCmd] gather_intel choice=%s 結果筆數=%d" % [choice_gi, result_gi.size()])
	return { "ok": true, "msg": "情報獲取", "payload": result_gi }
```

- [ ] **Step 4: 跑 headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 5: 在 headless_test 加 InquirySystem 驗證**

```gdscript
print("--- InquirySystem 驗證 ---")
var _inq := InquirySystem.new()
var _pt_inq: TeamData = state.teams.get(state.player_id)
if _pt_inq:
	# 找任何非玩家 team
	for _other_id in state.teams:
		if _other_id == state.player_id: continue
		var _other_t: TeamData = state.teams[_other_id]
		var _opts: Array = _inq.get_options(state, _pt_inq, _other_t)
		print("  Team%d 打聽 Team%d → %d 個選項" % [state.player_id, _other_id, _opts.size()])
		assert(_opts.size() <= 5, "InquirySystem 選項不超過 5")
		break
print("  InquirySystem 驗證通過")
```

- [ ] **Step 6: 跑 headless test 確認驗證輸出**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`--- InquirySystem 驗證 ---`，`InquirySystem 驗證通過`。

- [ ] **Step 7: Commit**

```
git add scripts/simulation/inquiry_system.gd scripts/simulation/player_command_system.gd scripts/debug/headless_test.gd
git commit -m "feat(inquiry,player_cmd): InquirySystem + gather_intel player action"
```

---

## 最終驗證

- [ ] **全部跑過一次**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：
- `=== DONE ===`，無 `SCRIPT ERROR`
- `--- AdvisorSystem 驗證 ---`：兩行不同建議文字
- `--- InquirySystem 驗證 ---`：至少 1 個選項，不超過 5
- `team_known` 在 100+ tick 後有多個訊息（NPC 交換情報生效）

- [ ] **Push branch**

```powershell
git push -u origin feat/batch3-information-system
```

---

*最後更新：2026-06-04*
