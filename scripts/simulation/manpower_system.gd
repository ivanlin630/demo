class_name ManpowerSystem

# 受控人力 Phase 1（純 anon、零跨域）：captive 群的待遇決策 + 軌跡轉換。
# entry（吸收，見 npc_combat）→ 待遇 means-end 決策（driver=服務意圖）→ outcome（同化/暴動/逃）。
#   厚待 → morale 升 → 同化（captive→holder free pop，解 (a)）
#   苛待 → morale 崩 → 暴動（脫離+部分戰損，觸 unrest）/ 逃（機會+低 morale 部分離開）
# 守恆：同化/暴動/逃皆經 AnonTierSystem API（assimilate/detach），pop 轉移非憑空增減。
# 待遇 driver-complete：每次決策寫進 group.treatment_history（provenance：可追 entry + 待遇史）。

# ───── 閾值 / 常數（全 TEST VALUE）─────
const ASSIM_T: float        = 0.75   # morale ≥ → 同化
const REVOLT_T: float       = 0.08   # morale ≤ → 暴動
const FLEE_T: float         = 0.20   # morale ≤（且機會）→ 逃
const MORALE_KIND: float    = 0.02   # 厚待每 tick morale +
const MORALE_HARSH: float   = -0.015 # 苛待每 tick morale −
const MORALE_NEUTRAL: float = 0.0    # 釋放前中性
const REVOLT_COMBAT_LOSS: float = 0.4   # 暴動脫離時戰損比例（鎮壓血腥，守恆=消滅非憑空）
const FLEE_FRACTION: float  = 0.5    # 逃時脫離比例
const CAPTIVE_CADENCE: int  = WorldState.TICKS_PER_DAY   # 每日決策/tick 一次（tick_all 用）

# ───── 待遇決策（means-end driver；連回 holder leader 意圖）─────
# driver：野心/欲壯兵 → 厚待同化（服務征服/擴張）；殘忍/急用 → 苛待；無力養（缺糧）→ 釋放。
# Phase 1 anon batch default（不個別）。回 "厚待" / "苛待" / "釋放"。
static func decide_treatment(state: WorldState, holder: TeamData, group: Dictionary) -> String:
	var leader: PersonData = state.persons.get(holder.leader_id)
	var ambition: float = float(leader.values.get("野心", 0.5)) if leader else 0.5
	var cruelty:  float = float(leader.values.get("殘忍", 0.5)) if leader else 0.5
	# 無力養（缺糧）→ 釋放（守恆：captive 離開，不白增）
	var captive_n: int = AnonTierSystem.total_captives(holder)
	var food_per_cap: float = ResourceSystem.effective_food(state, holder) \
		/ maxf(holder.population + captive_n, 1)
	if food_per_cap < 0.5:   # TEST VALUE：養不起
		return "釋放"
	# 厚待 util（壯兵意圖）vs 苛待 util（殘忍/速用）
	var kind_util: float  = 0.3 + ambition * 0.6 - cruelty * 0.4
	var harsh_util: float = 0.2 + cruelty * 0.7 - ambition * 0.3
	return "厚待" if kind_util >= harsh_util else "苛待"

# ───── 每 captive group tick（一次待遇套用 + 軌跡 check）─────
# treatment ∈ {"厚待","苛待","釋放"}。守恆：同化/暴動/逃全經 AnonTierSystem。
static func tick_captives(state: WorldState, holder: TeamData, treatment: String) -> void:
	if holder.captive_groups.is_empty():
		return
	# duplicate：transition 會 erase group（同化/暴動全脫離）
	for group in holder.captive_groups.duplicate():
		if not holder.captive_groups.has(group):
			continue
		_apply_treatment(group, treatment)
		_check_trajectory(state, holder, group, treatment)

static func _apply_treatment(group: Dictionary, treatment: String) -> void:
	var delta: float = MORALE_NEUTRAL
	match treatment:
		"厚待": delta = MORALE_KIND
		"苛待": delta = MORALE_HARSH
		"釋放": delta = MORALE_NEUTRAL
	group["morale"] = clampf(float(group.get("morale", 0.0)) + delta, 0.0, 1.0)
	var hist: Array = group.get("treatment_history", [])
	# 壓縮 history：只記最近一段（連續同待遇不膨脹）
	if hist.is_empty() or hist[hist.size() - 1] != treatment:
		hist.append(treatment)
	group["treatment_history"] = hist

# 軌跡 check（守恆）：morale 閾 → 同化 / 暴動 / 逃 / 釋放。
static func _check_trajectory(state: WorldState, holder: TeamData, group: Dictionary, treatment: String) -> void:
	var morale: float = float(group.get("morale", 0.0))
	# 釋放：立即脫離（流民路由，守恆）
	if treatment == "釋放":
		_flee(state, holder, group, 1.0, "released")
		return
	# 同化（厚待達標）→ captive 轉 holder free pop（解 (a)）
	if morale >= ASSIM_T:
		var n: int = AnonTierSystem.assimilate_captives(holder, group)
		if n > 0:
			Probe.bump("p1.assimilate")
			print("[P1Assim] Team%d 同化 captive +%d → free pop" % [holder.team_id, n])
		return
	# 暴動（morale 崩）→ 脫離 + 部分戰損 + holder unrest
	if morale <= REVOLT_T:
		_revolt(state, holder, group)
		return
	# 逃（低 morale + 機會：holder 戰力薄/無看管）
	if morale <= FLEE_T and _flee_opportunity(holder):
		_flee(state, holder, group, FLEE_FRACTION, "fled")
		return

# 暴動：captive cohorts 脫離 holder（部分戰損鎮壓，守恆=消滅非憑空），觸 holder unrest。
static func _revolt(state: WorldState, holder: TeamData, group: Dictionary) -> void:
	var detached: Dictionary = AnonTierSystem.detach_captives(holder, group, 1.0)
	var total: int = AnonCohort.total(detached)
	if total <= 0:
		return
	# 鎮壓戰損：部分死（守恆——脫離後一部分在鎮壓中消滅，非憑空消失，是真死亡路由）
	var slain: int = int(round(float(total) * REVOLT_COMBAT_LOSS))
	var escaped: int = total - slain
	UnrestBank.add(holder, 5, "captive_revolt")
	Probe.bump("p1.revolt")
	print("[P1Revolt] Team%d captive 暴動：脫離%d（鎮壓亡%d/逃散%d）→ holder unrest" % [
		holder.team_id, total, slain, escaped])
	# escaped 部分 → 流民隊（reuse split 概念：成獨立無 faction 隊）；slain = 真死亡（路由消滅）
	if escaped > 0:
		_spawn_breakaway(state, holder, detached, escaped, slain)

# 逃：部分 captive 脫離 → 流民隊（守恆路由）。fraction=比例，reason 遙測。
static func _flee(state: WorldState, holder: TeamData, group: Dictionary, fraction: float, reason: String) -> void:
	var detached: Dictionary = AnonTierSystem.detach_captives(holder, group, fraction)
	var total: int = AnonCohort.total(detached)
	if total <= 0:
		return
	Probe.bump("p1.flee")
	print("[P1Flee] Team%d captive %s 脫離%d → 流民隊" % [holder.team_id, reason, total])
	_spawn_breakaway(state, holder, detached, total, 0)

# 機會：holder 看管薄（戰力 anon 少 or readiness 低）→ captive 易逃。TEST VALUE。
static func _flee_opportunity(holder: TeamData) -> bool:
	var guard: int = AnonTierSystem.total_pop(holder)
	var captive: int = AnonTierSystem.total_captives(holder)
	return guard < captive or holder.readiness < 0.4

# 脫離者成獨立流民隊（守恆：detached cohorts 中 keep_n 進新隊、slain 已是真死亡不入任何隊）。
static func _spawn_breakaway(state: WorldState, holder: TeamData, detached: Dictionary, keep_n: int, _slain: int) -> void:
	if keep_n <= 0:
		return
	var nt := TeamData.new()
	nt.team_id = _next_team_id(state)
	nt.tile_pos = holder.tile_pos
	nt.faction_id = -1
	nt.tags = [TeamData.TAG_EXILE]
	ResourceBank.clear_all(nt, "captive_breakaway")
	# detached cohorts 按比例放入新隊（keep_n / total），其餘 = 鎮壓亡（不入任何隊，守恆=真死亡）
	var total: int = AnonCohort.total(detached)
	var placed: int = 0
	for key in detached.keys():
		var parts: Array = AnonCohort._parse(key)
		var n: int = int(detached[key])
		var put: int = int(round(float(n) / float(total) * float(keep_n)))
		put = mini(put, keep_n - placed)
		if put > 0:
			AnonCohort.add(nt.anon_cohorts, parts[0], parts[1], put)
			placed += put
	# 殘餘 keep_n 補滿（取整誤差）
	if placed < keep_n:
		for key in detached.keys():
			if placed >= keep_n: break
			var parts2: Array = AnonCohort._parse(key)
			AnonCohort.add(nt.anon_cohorts, parts2[0], parts2[1], 1)
			placed += 1
	if AnonCohort.total(nt.anon_cohorts) <= 0:
		return
	state.teams[nt.team_id] = nt
	state.team_known[nt.team_id] = []
	state.team_discovered[nt.team_id] = []

static func _next_team_id(state: WorldState) -> int:
	var max_id: int = 0
	for tid in state.teams:
		if tid > max_id:
			max_id = tid
	return max_id + 1

# ───── 每 tick 全域 captive 處理（cadence；sim 主迴路呼）─────
static func tick_all(state: WorldState) -> void:
	if state.world.current_tick % CAPTIVE_CADENCE != 0:
		return
	for tid in state.teams.keys():
		if not state.teams.has(tid):
			continue
		var holder: TeamData = state.teams[tid]
		if holder.captive_groups.is_empty():
			continue
		# 每 group 各自待遇決策（means-end driver）+ tick
		for group in holder.captive_groups.duplicate():
			if not holder.captive_groups.has(group):
				continue
			var treatment: String = decide_treatment(state, holder, group)
			_apply_treatment(group, treatment)
			_check_trajectory(state, holder, group, treatment)
