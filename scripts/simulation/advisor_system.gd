class_name AdvisorSystem
# ★顧問讀信念、不擲骰（spec 2026-10-15-advisor-reads-belief-and-text-externalization-pilot §一；意圖帳「顧問讀信念不擲骰」）
#   ★準不準＝雜訊（技能換幅度、決定性雜湊、零 RNG）；偏頗＝人格偏移；判斷帶從【偏移後的數字】算（不另寫鷹派句）
#   ★全部只讀附身隊自己的帳：belief（best_claim／known_reputations／threat_scan）＋自家真值（糧、己方武裝）
#   ★入口只有一條：玩家指令 ask_advisor（PlayerCommandApi）——UI 不直呼（直呼＝觀測改變被觀測物）
#   ★句子在 data/text/advisor.tsv（TextBank 外置）；組句＝fact ＋ 判斷句 ＋ 語氣尾；不知道＝unknown ＋ 語氣尾

const SITUATION_SKILL_MAP: Dictionary = {
	"assess_enemy":  "戰術",
	"diplomatic":    "交涉",
	"resources":     "生產",
	"strategic":     "計謀",
	"intel_read":    "偵查",
}

const SITUATION_LABELS: Dictionary = {"assess_enemy": "評估敵情", "diplomatic": "外交判讀", "resources": "資源狀況",
	"strategic": "大局", "intel_read": "解讀情報"}

# ★玩家選單的情境集合＝這五個（舊版「∩ TextBank 有模板」改由 text_keys_bed 的執行期對帳守）
const TEXT_SITUATIONS: Array = ["assess_enemy", "diplomatic", "resources", "strategic", "intel_read"]
const NEEDS_TARGET: Array = ["assess_enemy", "diplomatic"]
const TARGET_MENU_MAX: int = 9

# ★雜訊命名空間：唯一的既有生產呼叫點 path_system 傳 (tick, 隊 id, 隊 id)；person id 與隊 id 都從 0 起
#   ⇒ 不加這個，兩個系統的雜訊會相關（A9 證撞點存在）
const ADVISOR_NOISE_NS: int = 1 << 40
const ADVISOR_BIAS_GAIN: float = 0.3      # TEST VALUE：bias ＝ (好戰 − 慎重) × 此
const ADVISOR_UNKNOWN_U: float = 0.8      # TEST VALUE：uncertainty ≥ 此 ⇒ 不知道
# 判斷帶（TEST VALUE）
const BAND_ASSESS_GOOD: float = 1.3       # 己方武裝 ÷ 敵估 ≥ ⇒ 優
const BAND_ASSESS_BAD: float = 0.77       # ≤ ⇒ 劣
const BAND_DIPLO_GOOD: float = 0.6
const BAND_DIPLO_BAD: float = 0.4
const BAND_FOOD_GOOD: float = 10.0        # 天
const BAND_FOOD_BAD: float = 5.0          # < ⇒ 劣（沿用舊句門檻）
const BAND_STRAT_FAR_MULT: float = 2.0    # 最近敵對 > 視野 × 此 ⇒ 優
const BAND_INTEL_GOOD: float = 0.6
const BAND_INTEL_BAD: float = 0.3

static func menu_situations() -> Array:
	return TEXT_SITUATIONS.duplicate()

static func situation_label(k: String) -> String:
	return String(SITUATION_LABELS.get(k, k))

static func needs_target(situation: String) -> bool:
	return NEEDS_TARGET.has(situation)

# ★顧問算 u 只准經這一支（NS 與 salt 都在這裡；不動 observation_noise01 本體）
#   salt＝target_id×8＋情境序；target＝-1 ⇒ −(情境序＋1)：兩段值域互斥，同一目標的五個情境各拿各的 u
static func noise_u(tick: int, advisor_pid: int, target_id: int, situation: String) -> float:
	var idx: int = TEXT_SITUATIONS.find(situation)
	var salt: int = target_id * 8 + idx if target_id >= 0 else -(idx + 1)
	return PathSystem.observation_noise01(tick, advisor_pid + ADVISOR_NOISE_NS, salt)

# 目標選單：附身隊 belief 裡未過期的隊，位置 tick 新的在前（與情報頁隊伍類同一個序），最多 9 個
static func target_menu(state: WorldState, ptid: int) -> Array:
	var rows: Array = []
	for tgt in BeliefSystem.known_targets(state, ptid):
		var g: int = int(tgt)
		if g == ptid or state.live_team(g) == null:   # ★死隊／待刪隊不上選單
			continue
		var bc: Dictionary = BeliefSystem.best_claim(state, ptid, g)
		if bc.is_empty() or BeliefSystem.belief_stale(state, _claim_tick(bc)):
			continue
		var val: Dictionary = bc.get("value", {})
		rows.append({"id": g, "t": int(val.get("last_tick", -1)) if val.has("tile_pos") else -1})
	rows.sort_custom(func(a, b): return a["t"] > b["t"] or (a["t"] == b["t"] and a["id"] < b["id"]))
	var out: Array = []
	for r in rows.slice(0, TARGET_MENU_MAX):
		out.append(int(r["id"]))
	return out

static func _claim_tick(bc: Dictionary) -> int:
	var val: Dictionary = bc.get("value", {})
	return int(val.get("last_tick", bc.get("tick", 0)))

static func _noise_f(state: WorldState, advisor: PersonData, situation: String, target_id: int) -> float:
	var skill: float = float(advisor.skills.get(String(SITUATION_SKILL_MAP.get(situation, "計謀")), 0.0))
	var amp: float = BeliefSystem.observation_noise(0.0, skill)
	var u: float = noise_u(state.world.current_tick, advisor.id, target_id, situation)
	return 1.0 + (2.0 * u - 1.0) * amp

static func _bias(advisor: PersonData) -> float:
	return (float(advisor.values.get("好戰", 0.5)) - float(advisor.values.get("慎重", 0.5))) * ADVISOR_BIAS_GAIN

# 敵方估計（assess_enemy 與 strategic 的「劣」共用這一支算式）：只讀 best_claim；己方讀自家上場武裝
static func _assess(state: WorldState, advisor: PersonData, pt: TeamData, tgt: int, situation: String) -> Dictionary:
	var bc: Dictionary = BeliefSystem.best_claim(state, pt.team_id, tgt)
	if bc.is_empty() or BeliefSystem.belief_stale(state, _claim_tick(bc)) \
			or BeliefSystem.uncertainty(state, pt.team_id, tgt) >= ADVISOR_UNKNOWN_U:
		return {}
	var val: Dictionary = bc.get("value", {})
	if not val.has("population_est"):
		return {}
	var pop_est: float = float(val["population_est"])
	var armed_est: float = BeliefSystem.estimate_armed(val, pop_est, advisor.values)
	var k: float = _noise_f(state, advisor, situation, tgt) * (1.0 - _bias(advisor))
	var pop2: float = maxf(pop_est * k, 0.0)
	var armed2: float = maxf(armed_est * k, 0.0)
	var own: int = EncounterSystem.armed_on_field(state, pt)
	var ratio: float = float(own) / maxf(armed2, 0.001)
	var band: String = "good" if ratio >= BAND_ASSESS_GOOD else ("bad" if ratio <= BAND_ASSESS_BAD else "even")
	return {"claim": bc, "pop": pop2, "armed": armed2, "own": own, "ratio": ratio, "band": band}

# ── 主入口：回 {text, band, basis:{source_word, source_id, tick}, situation, target}（handler 呼；ok 由 handler 給）──
static func advise(state: WorldState, advisor: PersonData, situation: String, target_id: int) -> Dictionary:
	var pt: TeamData = state.teams.get(advisor.team_id)
	var now: int = state.world.current_tick
	var ctx: Dictionary = {"situation": situation, "target": target_id, "band": "unknown"}
	match situation:
		"assess_enemy":
			if target_id >= 0:
				var a: Dictionary = _assess(state, advisor, pt, target_id, situation)
				if not a.is_empty():
					ctx.merge(a, true)
		"diplomatic":
			if target_id >= 0:
				var bc: Dictionary = BeliefSystem.best_claim(state, pt.team_id, target_id)
				if not bc.is_empty() and not BeliefSystem.belief_stale(state, _claim_tick(bc)):
					# ★只讀附身隊 known_reputations（R² M3：目標隊長是誰 belief 沒有 ⇒ 不讀 feud 邊）
					var rep: float = float(pt.known_reputations.get(target_id, 0.5))
					var rep2: float = clampf(rep * _noise_f(state, advisor, situation, target_id) - _bias(advisor) * 0.5, 0.0, 1.0)
					ctx["claim"] = bc
					ctx["rep"] = rep2
					ctx["band"] = "good" if rep2 >= BAND_DIPLO_GOOD else ("bad" if rep2 <= BAND_DIPLO_BAD else "even")
		"resources":
			var days: float = maxf(PlayerApiMapper.food_days(pt) * _noise_f(state, advisor, situation, -1), 0.0)
			ctx["days"] = days
			ctx["band"] = "good" if days >= BAND_FOOD_GOOD else ("bad" if days < BAND_FOOD_BAD else "even")
		"strategic":
			var sc: Dictionary = PlayerApiMapper.threat_scan(state)
			if int(sc["enemy_n"]) > 0 and int(sc["enemy_id"]) >= 0:
				var eid: int = int(sc["enemy_id"])
				var d: int = int(sc["enemy_d"])
				var n: int = int(sc["n"])
				ctx["target"] = eid
				ctx["enemies"] = int(sc["enemy_n"])
				ctx["dist"] = d
				ctx["claim"] = BeliefSystem.best_claim(state, pt.team_id, eid)
				var band: String = "even"
				if float(d) > float(n) * BAND_STRAT_FAR_MULT:
					band = "good"
				elif d <= n:
					var a2: Dictionary = _assess(state, advisor, pt, eid, situation)
					if not a2.is_empty() and String(a2["band"]) == "bad":
						band = "bad"
				ctx["band"] = band
		"intel_read":
			var latest: Dictionary = {}
			var latest_tgt: int = -1
			for tgt in BeliefSystem.known_targets(state, pt.team_id):
				for c in BeliefSystem.claims(state, pt.team_id, int(tgt)):
					if PlayerQueryApi.is_firsthand(c, pt.team_id):
						continue
					if latest.is_empty() or int(c["tick"]) > int(latest["tick"]) \
							or (int(c["tick"]) == int(latest["tick"]) and int(tgt) < latest_tgt):
						latest = c
						latest_tgt = int(tgt)
			if not latest.is_empty():
				var cred: float = BeliefSystem.effective_credibility(state, latest)
				var cred2: float = clampf(cred * _noise_f(state, advisor, situation, -1)
					- (float(advisor.values.get("慎重", 0.5)) - 0.5) * ADVISOR_BIAS_GAIN, 0.0, 1.0)
				ctx["target"] = latest_tgt
				ctx["claim"] = latest
				ctx["cred"] = cred2
				ctx["band"] = "good" if cred2 >= BAND_INTEL_GOOD else ("bad" if cred2 <= BAND_INTEL_BAD else "even")
	# 依據
	var basis: Dictionary = {"source_word": "無", "source_id": -1, "tick": now}
	if situation == "resources":
		basis = {"source_word": "自家帳", "source_id": -1, "tick": now}
	elif ctx.has("claim") and not (ctx["claim"] as Dictionary).is_empty() and ctx["band"] != "unknown":
		var c2: Dictionary = ctx["claim"]
		var first: bool = PlayerQueryApi.is_firsthand(c2, pt.team_id)
		basis = {"source_word": "親見" if first else "聽說", "source_id": int(c2.get("source_id", -1)), "tick": int(c2.get("tick", now))}
	ctx["basis"] = basis
	return {"text": compose(state, advisor, ctx), "band": ctx["band"], "basis": basis,
		"situation": situation, "target": int(ctx["target"])}

# 組句（fact ＋ 判斷 ＋ 語氣尾；不知道＝unknown ＋ 語氣尾）
static func compose(state: WorldState, advisor: PersonData, ctx: Dictionary) -> String:
	var tone: String = _advisor_tone(advisor)
	var tail: String = TextBank.fmt("advisor_tone", tone, _params_for("advisor_tone", tone, state, ctx))
	if String(ctx["band"]) == "unknown":
		return _join([TextBank.fmt("advisor_unknown", "default", _params_for("advisor_unknown", "default", state, ctx)), tail])
	var key: String = "advisor_" + String(ctx["situation"])
	var band: String = String(ctx["band"])
	return _join([TextBank.fmt(key, "fact", _params_for(key, "fact", state, ctx)),
		TextBank.fmt(key, band, _params_for(key, band, state, ctx)), tail])

static func _join(parts: Array) -> String:
	var out: String = ""
	for p in parts:
		out += String(p)
	return out

# ★params 的唯一一支（槽對帳床拿它的 key 集合跟句子裡的 {槽} 比）：只回那一句真的用到的槽
static func _params_for(key: String, variant: String, state: WorldState, ctx: Dictionary) -> Dictionary:
	if variant != "fact" and key != "advisor_source":
		return {}
	match key:
		"advisor_source":
			return {"from": "Team%d" % int(ctx.get("basis", {}).get("source_id", -1))} if variant == "聽說" else {}
		"advisor_assess_enemy":
			return {"target": "Team%d" % int(ctx["target"]), "pop": roundi(float(ctx["pop"])),
				"armed": roundi(float(ctx["armed"])), "source": _source_text(ctx), "age": _age_text(state, ctx)}
		"advisor_diplomatic":
			return {"target": "Team%d" % int(ctx["target"]), "rep": "%.2f" % float(ctx["rep"]),
				"source": _source_text(ctx), "age": _age_text(state, ctx)}
		"advisor_resources":
			return {"days": "%.0f" % float(ctx["days"]), "source": _source_text(ctx)}
		"advisor_strategic":
			return {"enemies": int(ctx["enemies"]), "target": "Team%d" % int(ctx["target"]), "dist": int(ctx["dist"]),
				"source": _source_text(ctx), "age": _age_text(state, ctx)}
		"advisor_intel_read":
			return {"target": "Team%d" % int(ctx["target"]), "cred": "%.2f" % float(ctx["cred"]),
				"source": _source_text(ctx), "age": _age_text(state, ctx)}
	return {}

static func _source_text(ctx: Dictionary) -> String:
	var w: String = String(ctx["basis"]["source_word"])
	return TextBank.fmt("advisor_source", w, _params_for("advisor_source", w, null, ctx))

# 「幾天前」＝(now − claim.tick) / TICKS_PER_DAY；不到一天印「今天」
static func _age_text(state: WorldState, ctx: Dictionary) -> String:
	var days: int = (state.world.current_tick - int(ctx["basis"]["tick"])) / WorldState.TICKS_PER_DAY
	return "今天" if days <= 0 else "%d 天前" % days

static func _advisor_tone(advisor: PersonData) -> String:
	# ★接對 dict（2026-09-09）：`計謀` 是 skills 鍵不是 values 鍵 ⇒ 舊寫法恆 0.5
	#   ⇒ `> 0.7` 這一支【永遠不會 fire】＝ "sarcastic" 語氣是死碼。
	# ★★default 一起改 0.0：skills 的預設是 0.0，沿用 0.5 會把【沒有計謀技能的人】當成中等。
	# ★★★這裡是 presentation（文案 variant 的離散選擇），不是決策閘 —— blueprint 2026-09-09 裁。
	if float(advisor.skills.get("計謀", 0.0)) > 0.7 \
			and float(advisor.values.get("義氣", 0.5)) < 0.3:
		return "sarcastic"
	if float(advisor.values.get("好戰", 0.5)) > 0.7: return "blunt"
	if float(advisor.values.get("信義", 0.5)) > 0.6: return "formal"
	return "default"
