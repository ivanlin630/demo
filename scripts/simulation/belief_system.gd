class_name BeliefSystem

# team_intel[obs][tgt] = Array of claim（G3b multi-claim）。
# claim: { value:Dictionary, source_id:int, source_type:String, tick:int, credibility:float, distorted:bool }
# 禁直讀 state.team_intel（決策/UI 一律走此）。讀容錯舊式 Dict（test/transitional）。

const MAX_CLAIMS_PER_TARGET := 4      # TEST VALUE
const MAX_CLAIMS_PER_OBSERVER := 200  # TEST VALUE
# TIER: n/a — 語意時長非節律（某事多久算過期，不是多久評一次）
const BELIEF_STALE_TICKS: int = WorldState.TICKS_PER_DAY * 3   # TEST VALUE — 位置 belief 超此視同未知(過期)→防永久 threat/pursuit loop

# 類型基準表（TEST VALUE，序遵 game-design：親見>隊友>商旅>流民）。
# 官方/酒館/書籍待 producer 再加（免休眠；現無寫端產這些類別）。
const CRED_BASE := { "親見": 1.0, "隊友": 0.8, "商旅": 0.6, "流民": 0.3 }
const TRUST_FLOOR := 0.5             # trust 0..1 → 乘數 0.5..1.5
const BELIEF_HOP_DECAY := 0.15       # 對齊 message HOP_DECAY
const CRED_AGE_FULL_DECAY := WorldState.TICKS_PER_DAY * 30  # TEST VALUE
const CRED_TIME_FLOOR := 0.2         # TEST VALUE
const TRUST_DELTA := 0.05            # TEST VALUE：親見比對 relayed → ±口碑步長

# G3c-2 技能識破（信假/生疑/裁決）
const DETECT_SCHEME_GAIN := 0.8       # TEST VALUE：對方計謀壓低我識破
const DETECT_SUSPECT_T := 0.3         # TEST VALUE：生疑門檻
const DETECT_ADJUDICATE_T := 0.6      # TEST VALUE：裁決門檻
const DETECT_SUSPECT_MULT := 0.5      # TEST VALUE：生疑 cred 折扣
const DETECT_ADJUDICATE_MULT := 0.2   # TEST VALUE：裁決 cred 折扣
# G3c-2 觀察吃技能
const OBS_SKILL_NOISE_GAIN := 0.5     # TEST VALUE：低技能額外觀察噪
# G3d-1 決策風險 gate
const GATE_CONF_LOW := 0.0    # TEST VALUE：莽者門檻
const GATE_CONF_HIGH := 0.6   # TEST VALUE：慎重者門檻
# G3d-2 scout 主動查證
const SCOUT_TIMEOUT := WorldState.TICKS_PER_DAY * 3   # TEST VALUE：斥候逾時未收斂 → 釋放回常規（防永 scout）

# ── 戰力迷霧 fallback（未偵察武裝 → 人格化尺寸代理，非埋死「陌生=滿武裝」常數）──
# 基準武裝比＝世界參數（第三家）：村多平民 → 未偵察目標的武裝占比明顯 <1（measure 調）。
const ARMED_FRACTION_BASE := 0.35        # TEST VALUE：中性領袖對未知目標估的武裝/人口比（<1）
const ARMED_FRACTION_CAUTION_SKEW := 0.3 # TEST VALUE：慎重抬高（高估防禦、保守觀望）
const ARMED_FRACTION_CRUELTY_SKEW := 0.25 # TEST VALUE：殘忍壓低（把陌生者當軟柿）

# 期望武裝比（第一家：讀 leader 人格）：基準（世界參數）× 脾性偏移。
# 慎重↑ → 抬（高估對方防禦，保守）；殘忍↑ → 壓（軟柿讀，激進）。中性(0.5/0.5)→約基準。
static func expected_armed_fraction(leader_values: Dictionary) -> float:
	var caution: float = float(leader_values.get("慎重", 0.5))
	var cruelty: float = float(leader_values.get("殘忍", 0.5))
	var frac: float = ARMED_FRACTION_BASE \
		+ (caution - 0.5) * ARMED_FRACTION_CAUTION_SKEW \
		- (cruelty - 0.5) * ARMED_FRACTION_CRUELTY_SKEW
	return clampf(frac, 0.05, 1.0)

# 單 owner 戰力估計：有 armed_est belief 用它；否則 pop_est × 人格化期望武裝比（迷霧 fallback）。
# 消滅 finder 內 inline `.get("armed_est", pop_est)`（＝假設陌生=滿武裝 → 違三個家）。
static func estimate_armed(bel: Dictionary, pop_est: float, leader_values: Dictionary) -> float:
	if bel.has("armed_est"):
		return float(bel["armed_est"])
	return pop_est * expected_armed_fraction(leader_values)

# 寫時可信度（時不變部分）：類型基準 × 身份信任 × 跳數衰減。
# 身份信任 = obs team known_reputations[source]（0..1，default 0.5）；親見 source==obs → 1.0。
static func source_credibility(state: WorldState, observer_id: int,
		source_type: String, source_id: int, hop: int) -> float:
	var base: float = float(CRED_BASE.get(source_type, 0.3))
	var trust := 0.5
	var obs_team: TeamData = state.teams.get(observer_id)
	if obs_team != null and source_id != observer_id:
		trust = float(obs_team.known_reputations.get(source_id, 0.5))
	var hop_decay: float = pow(1.0 - BELIEF_HOP_DECAY, hop)
	return clampf(base * (TRUST_FLOOR + trust) * hop_decay, 0.0, 1.5)

static func _time_decay(state: WorldState, tick: int) -> float:
	var age: int = state.world.current_tick - tick
	if age <= 0: return 1.0
	return clampf(1.0 - float(age) / float(CRED_AGE_FULL_DECAY), CRED_TIME_FLOOR, 1.0)

# 讀時可信度（排序用）= 寫時 cred × 時效衰減 → 新鮮勝陳舊。
static func effective_credibility(state: WorldState, claim: Dictionary) -> float:
	return float(claim["credibility"]) * _time_decay(state, int(claim["tick"]))

# 識破分級（信假/生疑/裁決）：我理解力 vs 對方計謀 → cred 折扣 + 疑點 flag。
# 非 un-distort（真值不隨行）：只壓對該謊的信任，不還原值。
static func detection_discount(my_skill: float, their_scheme: float) -> Dictionary:
	var detect: float = clampf(my_skill - their_scheme * DETECT_SCHEME_GAIN, 0.0, 1.0)
	if detect >= DETECT_ADJUDICATE_T:
		return { "discount": DETECT_ADJUDICATE_MULT, "suspicious": true }
	if detect >= DETECT_SUSPECT_T:
		return { "discount": DETECT_SUSPECT_MULT, "suspicious": true }
	return { "discount": 1.0, "suspicious": false }

# 觀察品質吃觀察者技能：base = 距離噪；低技能疊殘留噪（親見也錯，cred 仍 1.0）。
static func observation_noise(base_noise: float, skill: float) -> float:
	return clampf(base_noise + (1.0 - clampf(skill, 0.0, 1.0)) * OBS_SKILL_NOISE_GAIN, 0.0, 1.0)

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
	var r: bool = not claims(state, obs_id, tgt_id).is_empty()
	if Probe.enabled:
		Probe.bump("bel.has_belief_call")
		if r: Probe.bump("bel.has_belief_true")
	return r

static func known_targets(state: WorldState, obs_id: int) -> Array:
	return state.team_intel.get(obs_id, {}).keys()

# ★位置感知 belief 化（god-view 位置根治）：observer 對 target 的「最後可見/可知」位置。
# 通道分流（感知鐵律位置版）：
#   - 同-faction 自家人 → faction.known_member_states（自帶 last_tick，非 BeliefSystem，遠方同僚沒 claim 也知位）。
#   - 跨-faction 敵情/社交 → BeliefSystem.best_estimate last-seen tile_pos。
# 皆過 staleness gate（last_tick 超 BELIEF_STALE_TICKS 視同未知）。
# ★fallback 鐵則：無有效 belief/過期 → 回 (-1,-1)（caller 據此棄該 option/target）；★絕不退自身位置
#   （退自身＝catch-up 恆追上 / threat 幽靈貼臉，比 god-view 更糟）。靜態設施(outpost)/自身位置由 caller 走真值通道。
static func belief_pos(state: WorldState, observer_id: int, target_id: int) -> Vector2i:
	var obs: TeamData = state.teams.get(observer_id)
	var tgt: TeamData = state.teams.get(target_id)
	if obs == null or tgt == null:
		return Vector2i(-1, -1)
	var now: int = state.world.current_tick
	# 同-faction → known_member_states 通道（自家人）
	if tgt.faction_id != -1 and tgt.faction_id == obs.faction_id:
		var f = state.factions.get(obs.faction_id)
		if f == null:
			return Vector2i(-1, -1)
		var kms: Dictionary = f.known_member_states.get(target_id, {})
		if kms.is_empty() or now - int(kms.get("last_tick", 0)) > BELIEF_STALE_TICKS:
			return Vector2i(-1, -1)
		return kms.get("tile_pos", Vector2i(-1, -1))
	# 跨-faction → BeliefSystem last-seen
	var bel: Dictionary = best_estimate(state, observer_id, target_id)
	if bel.is_empty() or now - int(bel.get("last_tick", 0)) > BELIEF_STALE_TICKS:
		return Vector2i(-1, -1)
	return bel.get("tile_pos", Vector2i(-1, -1))

static func best_estimate(state: WorldState, obs_id: int, tgt_id: int) -> Dictionary:
	var cs: Array = claims(state, obs_id, tgt_id)
	if Probe.enabled: Probe.bump("bel.best_call")
	if cs.is_empty(): return {}
	var best: Dictionary = cs[0]
	var best_eff: float = effective_credibility(state, best)
	for c in cs:
		var eff: float = effective_credibility(state, c)
		if eff > best_eff \
				or (eff == best_eff and int(c["tick"]) > int(best["tick"])):
			best = c; best_eff = eff
	if Probe.enabled:
		Probe.bump("bel.best_hit")
		var age: int = state.world.current_tick - int(best["tick"])
		if age < WorldState.TICKS_PER_MONTH: Probe.bump("bel.claim_fresh")
		elif age < 3 * WorldState.TICKS_PER_MONTH: Probe.bump("bel.claim_mid")
		else: Probe.bump("bel.claim_stale")
	return best["value"]

# credibility-weighted（G3d-2）：(1−最強源 eff_cred) + cred 加權值分歧。
# 親見高 cred 主導 → top→1 + 假源時效衰權重低 → spread 小 → 壓低不確定（查證可收斂）。
# 無 claim → 1.0；純未驗 relay → (1−cred) 高；真打架(雙新鮮高 cred 矛盾) → spread 高。
static func uncertainty(state: WorldState, obs_id: int, tgt_id: int) -> float:
	var cs: Array = claims(state, obs_id, tgt_id)
	if cs.is_empty(): return 1.0
	var best_val: float = float(best_estimate(state, obs_id, tgt_id).get("population_est", 0.0))
	var top := 0.0
	var wsum := 0.0
	var num := 0.0
	for c in cs:
		var w: float = effective_credibility(state, c)
		top = maxf(top, w)
		wsum += w
		num += w * absf(float((c["value"] as Dictionary).get("population_est", best_val)) - best_val)
	var spread := 0.0
	if wsum > 0.0001 and best_val > 0.0001:
		spread = num / (wsum * best_val)
	return clampf((1.0 - top) + spread, 0.0, 1.0)

# 風險 gate：個性慎重 × 情報不確定性 → 是否夠把握 commit 攻擊性行動。
# 莽者門檻低(照衝,假情報誘殺)；慎重者需高 confidence(矛盾情報按兵)。
static func confident_enough(state: WorldState, observer_id: int, target_id: int, caution: float) -> bool:
	var confidence: float = 1.0 - uncertainty(state, observer_id, target_id)
	var threshold: float = lerpf(GATE_CONF_LOW, GATE_CONF_HIGH, clampf(caution, 0.0, 1.0))
	return confidence >= threshold

static func record_claim(state: WorldState, obs_id: int, tgt_id: int,
		source_id: int, source_type: String, fields: Dictionary,
		credibility: float, distorted: bool) -> void:
	if not state.team_intel.has(obs_id):
		state.team_intel[obs_id] = {}
	var cs: Array = _coerce(state.team_intel[obs_id].get(tgt_id, null))
	# ★裁A（belief-freshness 縫，Slice D）：firsthand 親見（source_id==obs_id）= 觀察者本 tick 直接確認位置
	# → value.last_tick=current_tick（對齊 vision:114 另一 firsthand 路）。轉述(source≠obs)不寫（轉述≠親見 fresh，
	# 位置該當 last-seen 非「本 tick 可見」）。value.last_tick 語意=「位置最後被 firsthand 直接確認的 tick」。
	# ★T0-A1 ③：關鍵情報抵達＝【首見該目標】或【已知位置改變】→ 觀察者當 tick 可重新思考
	# （原本要等 cadence 才會用上新情報）。純讀既有 claims，零 RNG。
	if fields.has("tile_pos"):
		var _prev: Array = _coerce(state.team_intel.get(obs_id, {}).get(tgt_id, null))
		var _known_pos = null
		for _c in _prev:
			var _cv: Dictionary = _c["value"]
			if _cv.has("tile_pos"): _known_pos = _cv["tile_pos"]; break
		if _known_pos == null or _known_pos != fields["tile_pos"]:
			WorldEvents.emit(state, "intel_arrived", [obs_id])
	var firsthand: bool = source_type == "親見" and source_id == obs_id
	var found := false
	for c in cs:
		if int(c["source_id"]) == source_id:
			(c["value"] as Dictionary).merge(fields, true)  # 同源累積/覆寫欄
			if firsthand: (c["value"] as Dictionary)["last_tick"] = int(state.world.current_tick)
			c["tick"] = int(state.world.current_tick)
			c["credibility"] = credibility
			c["distorted"] = distorted
			found = true
			break
	if not found:
		var v: Dictionary = {}
		v.merge(fields, true)
		if firsthand: v["last_tick"] = int(state.world.current_tick)
		cs.append({ "value": v, "source_id": source_id, "source_type": source_type,
			"tick": int(state.world.current_tick), "credibility": credibility, "distorted": distorted })
	Probe.note("g3.claim_peak", float(cs.size()))
	_cap_target(cs)
	state.team_intel[obs_id][tgt_id] = cs
	_cap_observer(state, obs_id)
	# 親見 record → 被動查證：比對同 tgt relayed claim 調 source 口碑
	if source_type == "親見" and source_id == obs_id:
		reconcile_firsthand(state, obs_id, tgt_id)

# 被動身份信任迴路：obs 對 tgt 有親見 → 比對各 relayed source pop_est → ±口碑。
# 準（比值近 1）升、離譜/失真降。scout 主動查證 = G3d（本層只被動偶遇）。
static func reconcile_firsthand(state: WorldState, obs_id: int, tgt_id: int) -> void:
	var obs_team: TeamData = state.teams.get(obs_id)
	if obs_team == null: return
	var cs: Array = claims(state, obs_id, tgt_id)
	var truth := -1.0
	for c in cs:
		if c["source_type"] == "親見" and int(c["source_id"]) == obs_id:
			truth = float((c["value"] as Dictionary).get("population_est", -1.0)); break
	if truth <= 0.0: return
	if Probe.enabled: Probe.bump("bel.reconcile_opportunity")
	for c in cs:
		var sid: int = int(c["source_id"])
		if sid == obs_id or c["source_type"] == "親見": continue
		if not state.teams.has(sid): continue   # 死 source（claim 存活過來源隊）→ 不更新口碑，免 known_reputations 重注入死 id（dangling 根因）
		var rep: float = float((c["value"] as Dictionary).get("population_est", -1.0))
		if rep <= 0.0: continue
		if Probe.enabled: Probe.bump("bel.reconcile_compared")
		var r: float = rep / truth
		if r >= 0.7 and r <= 1.3:
			obs_team.update_reputation(sid, TRUST_DELTA)
			Probe.bump("g3.trust_up")
		elif r < 0.4 or r > 2.5 or bool(c.get("distorted", false)):
			obs_team.update_reputation(sid, -TRUST_DELTA)
			Probe.bump("g3.trust_down")

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

# ★★★從 `goal_resolver.gd` 搬過來（systems R² 定案 2026-09-02）：faction_ai 的佔村候選也要用它。
#   ★不留第二份拷貝 —— 兩份會漂。goal_resolver 保留一個 delegate 給既有 caller。
#   ★★★相互引用【已解】（systems 裁 2026-09-02，★兩者都是零行為移除）：
#     ①`_hex_dist` 全站已有 11 份逐字相同的拷貝 ⇒ 直接呼 `PathSystem._hex_dist`（已是 static），不抄第 12 份
#     ②`_msg_market_pos` 是【純解析】（只讀 msg dict、零 faction_ai 狀態）⇒ 跟著搬過來
#   ⇒ ★本檔對 `FactionAISystem` 的依賴為 0 ⇒ systems 當初「零依賴所以不會循環」的 seam 理由恢復成立。
# ★team_tile_known belief harvest（鏡射 _harvest_market_known）：兩源=bounded vision + relay。禁 RNG。
static func harvest_tile_known(state: WorldState, team: TeamData) -> void:
	var known: Dictionary = state.team_tile_known.get(team.team_id, {})
	var vr: int = VisionSystem.VISION_RADIUS
	for dx in range(-vr, vr + 1):   # bounded=vision（非全圖 god-view）
		for dy in range(-vr, vr + 1):
			var p: Vector2i = team.tile_pos + Vector2i(dx, dy)
			if PathSystem._hex_dist(team.tile_pos, p) > vr:   # ★改呼 PathSystem（公式逐字相同，零行為）
				continue
			var tid: int = p.x * 1000 + p.y
			if state.world.tiles.has(tid):
				known[tid] = true
	# relay：team_known tile 訊息 pos（reuse market pos extractor）→ known
	for msg in state.team_known.get(team.team_id, []):
		var mpos: Vector2i = msg_market_pos(msg)
		if mpos == Vector2i(-999, -999):
			continue
		known[mpos.x * 1000 + mpos.y] = true
	state.team_tile_known[team.team_id] = known

# ★★★從 `faction_ai_system.gd` 搬過來（systems 裁 2026-09-02）：★純解析 msg dict，零狀態 ⇒ 零行為。
#   ★搬它的理由不是整理，是【解掉 belief_system ↔ faction_ai 的相互引用】。
#   ★★faction_ai 留一個 delegate（`_msg_market_pos`），既有 caller 零改動、不留第二份實作。
static func msg_market_pos(msg) -> Vector2i:
	if msg.type == "order_buy" or msg.type == "order_sell":
		var op = msg.params.get("origin_pos", null)
		if op is Vector2i:
			return op
	elif msg.type == "outpost_built":
		return msg.source_pos
	return Vector2i(-999, -999)

# ══════════════════════════════════════════════════════════════════════════
# ★★★感知兩層：外觀層（親見可得）—— blueprint 裁、R² 過（2026-09-02）
# ══════════════════════════════════════════════════════════════════════════
# ★層次：①外觀層＝親見看得到的 ②組織/內心層＝只能靠情報 ③`unknown` ＝【誠實第三態】
#   ⇒ ★★禁 default-pass、禁 fallback 回 live（那是 baseline 第 76 行的形狀）。
#
# ★★★而【怎麼決定外觀活動】是本刀最容易偷渡「意圖可見」的一格：
#   ✗ 原 spec：`current_task` 列舉 → 外觀類別的【投影表】
#     ⇒ ★reviewer 打掉：30+ 個 TASK_* ⇒ ★★【每一格都是一次偷渡意圖的機會】
#   ✓ 改用【真正觀察得到的底層信號】當根：
#     血證：`npc_combat_system.gd:110-111` —— `combat_target` 只在 `start_combat()` 真開打才設；
#           而 `current_task == TASK_ATTACK` ★在還在趕路時就已經是那個值
#     ⇒ ★★★兩者【不同義】：一個是「正在打」，一個是「打算打」
#   ⇒ ★所以本函式【根本不讀 current_task】—— 防線是「拿不到」不是「記得別讀」。
#
# ★★對應不到底層信號的活動 ⇒ 歸 `unknown`，★★★不為了補滿類別去讀 task。
const ACT_COMBAT: String = "combat"     # 正在交戰（combat_target 已設＝真開打）
const ACT_MOVING: String = "moving"     # 位置與上一步不同＝真的在動（不是「打算動」）
const ACT_BUILDING: String = "building" # 腳下 tile 的 construction_team_id ＝ 它＝工地上真的有它的人
const ACT_SETTLED: String = "settled"   # 站在自己的據點/營地上＝駐紮（tile 狀態，非 task）
const ACT_IDLE: String = "idle"          # ★★★觀察到、靜止、無可辨識活動（★寫入端的預設答案）
const ACT_UNKNOWN: String = "unknown"   # ★★只屬於【讀取端】：沒有 activity 欄位／claim 過期
# ★★★分類表的層次（systems 裁 2026-09-02，已入 invariants 細則 1a）：
#   ★「我看著它，而我不知道它在幹嘛」與「我沒看到它」是【兩件事】
#   ⇒ 本函式是在【vision 記錄親見的當下】被呼叫的 —— 那一刻【你正看著它】
#   ⇒ ★★所以寫入端【沒有「未知」這個答案】：落到最後 ＝ 觀察到但靜止 ＝ ACT_IDLE
#   ⇒ ★★★在寫入端回 unknown ＝【類別錯誤】：那代表分類表缺一格，
#     而「分類表沒有一格給它」不叫做未知 —— 它叫做分類表不完整。
#   ★同一個形狀：今天的「指標＝0 三讀法」——「沒發生」與「沒觀測到」長得一樣而不是一件事。

# ★純讀、零 RNG、零寫入。★★只讀【真的發生了才會變】的狀態。
static func observed_activity(state: WorldState, tgt: TeamData) -> String:
	if tgt.combat_target != -1:
		return ACT_COMBAT
	var _t: HexTileData = state.world.tiles.get(tgt.tile_pos.x * 1000 + tgt.tile_pos.y)
	if _t != null and _t.construction_team_id == tgt.team_id:
		return ACT_BUILDING
	if tgt.last_tile_pos != Vector2i(-999, -999) and tgt.last_tile_pos != tgt.tile_pos:
		return ACT_MOVING
	if _t != null and (_t.outpost_owner == tgt.team_id or _t.camp_level > 0):
		return ACT_SETTLED
	# ★★★預設是 IDLE 不是 UNKNOWN：★這一刻我正看著它，只是它沒在做可辨識的事
	return ACT_IDLE

# ★外觀 belief 的讀取端 helper（★三態分得開：有值／過期／從未觀察到 —— 各自一個桶）
#   回 `{"activity": String, "tags": Array, "in_combat": bool, "state": "fresh|stale|never"}`
static func appearance(state: WorldState, obs_id: int, tgt_id: int) -> Dictionary:
	var bel: Dictionary = best_estimate(state, obs_id, tgt_id)
	if bel.is_empty() or not bel.has("activity"):
		if Probe.enabled: Probe.bump("appearance.never")
		return {"activity": ACT_UNKNOWN, "tags": [], "in_combat": false, "state": "never"}
	if state.world.current_tick - int(bel.get("last_tick", 0)) > BELIEF_STALE_TICKS:
		if Probe.enabled: Probe.bump("appearance.stale")
		return {"activity": ACT_UNKNOWN, "tags": [], "in_combat": false, "state": "stale"}
	if Probe.enabled: Probe.bump("appearance.fresh")
	return {
		"activity": String(bel.get("activity", ACT_UNKNOWN)),
		"tags": bel.get("tags_seen", []),
		"in_combat": bool(bel.get("in_combat", false)),
		"state": "fresh",
	}

