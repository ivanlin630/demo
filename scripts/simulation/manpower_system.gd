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
# ③ asm 做深（全 TEST VALUE）
const CAPTIVE_FOOD_RATE: float = 0.5   # 厚待每 captive/日撥糧（< free pop 標準口糧 FOOD_PER_PERSON_PER_DAY=0.8）
const FEED_FAIL_Q: float    = 0.3    # feed_quality < → 厚待失效（餓著=虐待，delta=MORALE_HARSH×0.5）
const GUARD_RATIO_MAX: float = 0.5   # 看守撥比上限
const GUARD_CAUTION_W: float = 0.3   # guard_ratio = clampf(慎重×此 + load×GUARD_LOAD_W, 0, MAX)
const GUARD_LOAD_W: float   = 0.3    # 持有量占比權重（俘越多越加派看守）
const FLEE_COEF: float      = 0.3    # 逃機率係數：p = clampf(captive/(guard_n+1)×(1-morale)×此, 0, P_FLEE_MAX)
const P_FLEE_MAX: float     = 0.5    # 每日逃機率上限
const GUARD_CAP_MULT: float = 3.0    # captive_cap = guard_n × 此（超限→強制處置超額，逼決策別囤）

# ───── 待遇決策（means-end driver；連回 holder leader 意圖）─────
# driver：野心/欲壯兵 → 厚待同化（服務征服/擴張）；殘忍/急用 → 苛待；無力養（缺糧）→ 釋放。
# Phase 1 anon batch default（不個別）。回擴 dict {treatment, guard_ratio}。
# treatment ∈ {"厚待","苛待","釋放"}；guard_ratio ∈ [0, GUARD_RATIO_MAX]（看守強度連續決策）。
static func decide_treatment(state: WorldState, holder: TeamData, group: Dictionary) -> Dictionary:
	var leader: PersonData = state.persons.get(holder.leader_id)
	var ambition: float = float(leader.values.get("野心", 0.5)) if leader else 0.5
	var cruelty:  float = float(leader.values.get("殘忍", 0.5)) if leader else 0.5
	var guard_ratio: float = _decide_guard_ratio(state, holder)
	# 無力養（缺糧）→ 釋放（守恆：captive 離開，不白增）
	var captive_n: int = AnonTierSystem.total_captives(holder)
	var food_per_cap: float = ResourceSystem.effective_food(state, holder) \
		/ maxf(holder.population + captive_n, 1)
	if food_per_cap < 0.5:   # TEST VALUE：養不起
		return {"treatment": "釋放", "guard_ratio": guard_ratio}
	# 厚待 util（壯兵意圖）vs 苛待 util（殘忍/速用）
	var kind_util: float  = 0.3 + ambition * 0.6 - cruelty * 0.4
	var harsh_util: float = 0.2 + cruelty * 0.7 - ambition * 0.3
	var treatment: String = "厚待" if kind_util >= harsh_util else "苛待"
	return {"treatment": treatment, "guard_ratio": guard_ratio}

# ───── 看守強度決策（holder-level，連續 0..GUARD_RATIO_MAX）─────
# driver：leader 慎重（謹慎者多派看守）+ 持有量占比（俘越多越需看守）。TEST VALUE 公式。
static func _decide_guard_ratio(state: WorldState, holder: TeamData) -> float:
	var leader: PersonData = state.persons.get(holder.leader_id)
	var caution: float = float(leader.values.get("慎重", 0.5)) if leader else 0.5
	var captive_n: int = AnonTierSystem.total_captives(holder)
	var load: float = clampf(
		float(captive_n) / maxf(float(AnonTierSystem.total_pop(holder)), 1.0), 0.0, 1.0)
	return clampf(caution * GUARD_CAUTION_W + load * GUARD_LOAD_W, 0.0, GUARD_RATIO_MAX)

# ───── 每 captive group tick（一次待遇套用 + 軌跡 check）─────
# treatment ∈ {"厚待","苛待","釋放"}。守恆：同化/暴動/逃全經 AnonTierSystem。
static func tick_captives(state: WorldState, holder: TeamData, treatment: String) -> void:
	if holder.captive_groups.is_empty():
		return
	# duplicate：transition 會 erase group（同化/暴動全脫離）
	for group in holder.captive_groups.duplicate():
		if not holder.captive_groups.has(group):
			continue
		_apply_treatment(state, holder, group, treatment)
		_check_trajectory(state, holder, group, treatment)

# 待遇套用：morale delta（厚待吃真餵養質量）+ treatment_history（provenance 延伸）。
# 厚待 = 真掏糧：captive 吃 CAPTIVE_FOOD_RATE/人/日，從 holder 食扣（ResourceBank 守恆路由）；
#   feed_quality = 實撥/需求（0..1）→ morale delta = MORALE_KIND × feed_quality；
#   feed_quality < FEED_FAIL_Q（斷糧）→ 厚待名存實亡（delta=MORALE_HARSH×0.5，餓著=虐待）。
static func _apply_treatment(state: WorldState, holder: TeamData, group: Dictionary, treatment: String) -> void:
	var delta: float = MORALE_NEUTRAL
	var feed_quality: float = 1.0
	match treatment:
		"厚待":
			var captive_n: int = AnonCohort.total(group.get("cohorts", {}))
			var need: float = float(captive_n) * CAPTIVE_FOOD_RATE
			var got: float = ResourceBank.remove(holder, "food", need, "captive_feed") if need > 0.0 else 0.0
			feed_quality = clampf(got / maxf(need, 0.001), 0.0, 1.0)
			if feed_quality < FEED_FAIL_Q:
				delta = MORALE_HARSH * 0.5   # 斷糧厚待 = 虐待（morale 掉）
			else:
				delta = MORALE_KIND * feed_quality
		"苛待": delta = MORALE_HARSH
		"釋放": delta = MORALE_NEUTRAL
	group["morale"] = clampf(float(group.get("morale", 0.0)) + delta, 0.0, 1.0)
	# treatment_history 記 {treatment, feed_quality, guard_ratio}（provenance 延伸；粗量化壓縮：連續同段不膨脹）
	var hist: Array = group.get("treatment_history", [])
	var rec: Dictionary = {
		"treatment": treatment,
		"feed_quality": snappedf(feed_quality, 0.25),
		"guard_ratio": snappedf(float(holder.captive_guard_ratio), 0.1),
	}
	if hist.is_empty() or hist[hist.size() - 1] != rec:
		hist.append(rec)
	group["treatment_history"] = hist

# 軌跡 check（守恆）：morale 閾 → 同化 / 暴動 / 逃 / 釋放。
static func _check_trajectory(state: WorldState, holder: TeamData, group: Dictionary, treatment: String) -> void:
	var morale: float = float(group.get("morale", 0.0))
	# [longwindow probe] captive lifecycle：首次觀測此 group = created（純觀測，Probe.enabled guard 零成本、零行為變）
	if Probe.enabled and not group.has("_lw_created_tick"):
		group["_lw_created_tick"] = state.world.current_tick
		Probe.bump("asm.created")
		Probe.add_amount("asm.created_morale_sum", float(group.get("morale", 0.0)))
	# 釋放：立即脫離（流民路由，守恆）
	if treatment == "釋放":
		_flee(state, holder, group, 1.0, "released")
		return
	# 同化（厚待達標）→ captive 轉 holder free pop（解 (a)）
	if morale >= ASSIM_T:
		var n: int = AnonTierSystem.assimilate_captives(holder, group)
		if n > 0:
			Probe.bump("p1.assimilate")
			# [longwindow probe] completed + 耗時（tick）→ 裁② 慢 vs 結構性分流
			if Probe.enabled:
				Probe.bump("asm.completed")
				Probe.add_amount("asm.completed_dur_sum",
					float(state.world.current_tick - int(group.get("_lw_created_tick", state.world.current_tick))))
			print("[P1Assim] Team%d 同化 captive +%d → free pop" % [holder.team_id, n])
		return
	# 暴動（morale 崩）→ 脫離 + 部分戰損 + holder unrest
	if morale <= REVOLT_T:
		_revolt(state, holder, group)
		return
	# 逃（低 morale + 機會：看守薄 → 高逃機率；看守厚 → 壓低）。每日擲。
	if morale <= FLEE_T:
		var p_flee: float = _flee_probability(holder, morale)
		if p_flee > 0.0 and randf() < p_flee:
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
	if Probe.enabled: Probe.bump("asm.interrupted_scatter")   # [longwindow probe] 暴動散 = 結構性中斷
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
	# [longwindow probe] 逃/釋放分流：released=holder 養不起主動放、fled=低 morale 機會逃
	if Probe.enabled: Probe.bump("asm.released" if reason == "released" else "asm.escaped")
	print("[P1Flee] Team%d captive %s 脫離%d → 流民隊" % [holder.team_id, reason, total])
	_spawn_breakaway(state, holder, detached, total, 0)

# 逃機率（連續）：看守 anon = total_pop × guard_ratio；p = captive/(guard_n+1) × (1-morale) × FLEE_COEF。
# 看守厚 → guard_n 大 → 難逃/難暴動；看守薄 → stakes 真咬。刪舊 readiness<0.4 恆真項。TEST VALUE。
static func _flee_probability(holder: TeamData, morale: float) -> float:
	var captive: int = AnonTierSystem.total_captives(holder)
	if captive <= 0:
		return 0.0
	var guard_n: float = float(AnonTierSystem.total_pop(holder)) * float(holder.captive_guard_ratio)
	var p: float = float(captive) / (guard_n + 1.0) * (1.0 - morale) * FLEE_COEF
	return clampf(p, 0.0, P_FLEE_MAX)

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

# ───── guard-cap：captive_cap = guard_n × GUARD_CAP_MULT，超限強制處置超額（逼決策別囤）─────
# means-end：殘忍 leader → 苛用（部分戰損處置）；否則 → 釋放（全數保留成流民）。守恆：走既有 detach/breakaway 路由。
static func _enforce_guard_cap(state: WorldState, holder: TeamData) -> void:
	var guard_n: float = float(AnonTierSystem.total_pop(holder)) * float(holder.captive_guard_ratio)
	var cap: int = int(floor(guard_n * GUARD_CAP_MULT))
	var total: int = AnonTierSystem.total_captives(holder)
	if total <= cap:
		return
	var excess: int = total - cap
	var leader: PersonData = state.persons.get(holder.leader_id)
	var cruelty: float = float(leader.values.get("殘忍", 0.5)) if leader else 0.5
	var cruel: bool = cruelty >= 0.5
	Probe.bump("asm.guardcap_forced")
	if Probe.enabled: print("[GuardCap] Team%d 超限 total=%d cap=%d → 強制處置 excess=%d (%s)" % [
		holder.team_id, total, cap, excess, "苛用" if cruel else "釋放"])
	var remaining: int = excess
	for group in holder.captive_groups.duplicate():
		if remaining <= 0:
			break
		if not holder.captive_groups.has(group):
			continue
		var gtotal: int = AnonCohort.total(group.get("cohorts", {}))
		if gtotal <= 0:
			continue
		var take: int = mini(remaining, gtotal)
		var frac: float = float(take) / float(gtotal)
		var detached: Dictionary = AnonTierSystem.detach_captives(holder, group, frac)
		var dt: int = AnonCohort.total(detached)
		if dt <= 0:
			continue
		remaining -= dt
		if cruel:
			var slain: int = int(round(float(dt) * REVOLT_COMBAT_LOSS))
			_spawn_breakaway(state, holder, detached, dt - slain, slain)   # 部分死=真死亡路由，守恆
		else:
			_spawn_breakaway(state, holder, detached, dt, 0)               # 全釋放進流民，守恆

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
		# 看守決策（holder-level）：guard_ratio 連續 → 記 holder.captive_guard_ratio
		holder.captive_guard_ratio = _decide_guard_ratio(state, holder)
		# guard-cap：超限強制處置超額（在待遇前，逼決策別囤）
		_enforce_guard_cap(state, holder)
		# 每 group 各自待遇決策（means-end driver）+ tick
		for group in holder.captive_groups.duplicate():
			if not holder.captive_groups.has(group):
				continue
			var decision: Dictionary = decide_treatment(state, holder, group)
			_apply_treatment(state, holder, group, decision["treatment"])
			_check_trajectory(state, holder, group, decision["treatment"])
