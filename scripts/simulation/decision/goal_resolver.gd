class_name GoalResolver

# ★means-end 長程規劃（組件 C，HOW spec 2026-07-24 §4）：runtime frontier 合成中間層。
# 對 team.goal_state 每個 active goal，walk GoalRegistry[goal_type].prereqs 拆前置鏈，
# 合成當前可動 frontier candidate 餵 decision rank 池（與 static option 同池 argmax 競爭）。
# ★唯讀合成、每 tick 重算 transient frontier（不寫回 goal_state=無 plan-state，守 HOW §9）。
# ★路徑必 scripts/simulation/decision/（constitution_gate GV_FILE_RE 涵蓋）→ god-view/RNG detector 看得到。
#
# Candidate 結構（HOW §4）：{ util:float, to_task:Dictionary, source_goal:GoalInstance, label:String, delegate:bool }。
#
# ★S2：資源型 resolution 接通（第一實質 slice，打破 byte-identical）。只 resource 前置→「買」取得 candidate；
#   定位(採)/設施(產)前置=S3/S4 回無 candidate（stub 邊界）。折現/委派/子目標=S3-S6 別提前（whole-system-first）。

# ★must-fix① util 護欄（HOW §8，首上場硬做）：goal candidate util 恆 < 絕境 survival-boosted static util。
# = payoff × dev_urgency_coeff（絕境 food_days→0→0=壓遠慾望）+ clamp 上界 < SURVIVAL_BOOST_MAX（硬保證）。
const GOAL_UTIL_CAP: float = 1.5   # TEST VALUE — < DecisionEngine.SURVIVAL_BOOST_MAX(2.5) 硬護欄:goal candidate 永不蓋絕境 survival boost

# ★組件 A（S7 完整 lifecycle）：cadence-gate 每 GOAL_EVAL_CADENCE tick 呼一次（非每 decide=perf,known_issues A）。
# 掛=desire>threshold;★退=build_F 建成 or desire 掉→移除(免 goal_state 無限累積);maintain 冪等持久留。純讀狀態+need_keep,零 randf。
const GOAL_EVAL_CADENCE: int = TimeScale.TICK_PER_DAY * 3   # 3 天評估（鏡射 RESIDENCY_CADENCE）
static func ensure_maintain_goals(state: WorldState, team: TeamData) -> void:
	if state == null or team == null or state.world == null:
		return
	# ★S7 cadence-gate：goal 生成/掛退每 GOAL_EVAL_CADENCE tick 一次（goal_state 持久跨 tick，frontier 每 decide 重驗 holding）。
	if state.world.current_tick < team.goal_eval_next_tick:
		return   # gate-ok: guard cadence early-return（perf 節流，非決策閘）
	team.goal_eval_next_tick = state.world.current_tick + GOAL_EVAL_CADENCE
	var lv: Dictionary = TradeValuation.leader_vals(state, team)
	var have: Dictionary = {}
	for g in team.goal_state:
		have[String(g.get("goal_type", ""))] = true
	# 冪等補齊缺的 maintain goal（決定性順序：REGISTRY key 序）
	for gt in GoalRegistry.MAINTAIN_GOAL_RES:
		if not have.has(gt):
			team.goal_state.append({"goal_type": gt, "target": null,
				"created_tick": state.world.current_tick, "status": "active"})
	# 更新 maintain status：holding < need_keep(res) → active（想維持）；否則 satisfied。
	for g in team.goal_state:
		var gt: String = String(g.get("goal_type", ""))
		if not GoalRegistry.MAINTAIN_GOAL_RES.has(gt):
			continue
		var res: String = String(GoalRegistry.MAINTAIN_GOAL_RES[gt])
		g["status"] = "active" if ResourceSystem.effective_holding(state, team, res) < NeedOracle.need_keep(state, team, res, lv) else "satisfied"
	# ★S4/S7 設施發展 goal 掛退 lifecycle：desire≥threshold 且未建→掛；建成 or desire 掉→退（移除，免累積）。
	var own: Vector2i = FactionAISystem.new()._find_own_outpost(state, team)
	var otile: HexTileData = state.world.tiles.get(own.x * 1000 + own.y) if own != Vector2i(-1, -1) else null
	var fai := FactionAISystem.new()
	var kept: Array = []
	for g in team.goal_state:
		var gt: String = String(g.get("goal_type", ""))
		if not GoalRegistry.BUILD_FACILITY_GOALS.has(gt):
			kept.append(g)   # maintain / 別型 goal 冪等持久留
			continue
		var f: String = String(GoalRegistry.BUILD_FACILITY_GOALS[gt])
		var fdef: Dictionary = OutpostSystem.FACILITY_DEF.get(f, {})
		# 退判定：無合適 outpost / 已建成 / desire 掉 below threshold → 移除。
		if otile == null or not (otile.outpost_type in fdef.get("allowed_outpost", [])) \
				or int(otile.get(fdef.get("current_level_key", ""))) > 0 \
				or fai._facility_deficit(state, team, f, otile) < NeedOracle.CONSTRUCTION_DESIRE_MIN:
			continue   # ★退（不 append=移除）
		kept.append(g)   # desire 仍高+未建→留
	team.goal_state = kept
	# 掛：desire≥threshold+未建+未在 goal_state → 新掛 build_F goal（決定性 REGISTRY key 序）。
	if otile != null:
		for gt2 in GoalRegistry.BUILD_FACILITY_GOALS:
			if have.has(gt2):
				continue
			var f2: String = String(GoalRegistry.BUILD_FACILITY_GOALS[gt2])
			var fdef2: Dictionary = OutpostSystem.FACILITY_DEF.get(f2, {})
			if not (otile.outpost_type in fdef2.get("allowed_outpost", [])):
				continue
			if int(otile.get(fdef2.get("current_level_key", ""))) > 0:
				continue
			if fai._facility_deficit(state, team, f2, otile) >= NeedOracle.CONSTRUCTION_DESIRE_MIN:
				team.goal_state.append({"goal_type": gt2, "target": null,
					"created_tick": state.world.current_tick, "status": "active"})

static func frontier_candidates(state: WorldState, team: TeamData, ctx: DecisionContext) -> Array:
	if state == null or team == null or ctx == null:
		return []   # harness 無 state/team → 無 goal frontier（安全）
	var out: Array = []
	var lv: Dictionary = TradeValuation.leader_vals(state, team)
	for g in team.goal_state:
		if String(g.get("status", "")) != "active":
			continue
		var gt: String = String(g.get("goal_type", ""))
		var def: Dictionary = GoalRegistry.REGISTRY.get(gt, {})
		if def.is_empty():
			continue
		var payoff: float = float(def.get("payoff", 1.0))
		# ★S4 設施發展 goal（build_F）：walk build-cost/facility-type/manpower 前置→frontier or build_F action。
		if def.has("facility"):
			var bc: Dictionary = _resolve_build_facility(state, team, ctx, g, gt, def)
			if not bc.is_empty():
				out.append(bc)
			continue
		for prereq in def.get("prereqs", []):
			var kind: String = String(prereq.get("kind", ""))
			var cand: Dictionary = {}
			if kind == GoalRegistry.PREREQ_RESOURCE:
				# ★接線（spec §3）：這個 caller 本來就在收集多個 candidate 進 rank 池
				#   ⇒ 改 append_array，讓 means-end 的候選與既有手段【同池競爭】，不特別待遇。
				out.append_array(_resource_prereq_candidates(state, team, ctx, g, gt, payoff, prereq))
				continue
			elif kind == GoalRegistry.PREREQ_LOCATION:
				cand = _resolve_location_prereq(state, team, ctx, g, gt, payoff, prereq)   # S3 定位型
			# manpower/facility/subgoal = S4-S6（無 candidate，stub 邊界）
			if not cand.is_empty():
				out.append(cand)
	# ★S5 委派 peer option（組件 D）：build/settle 型 candidate 產「派子隊做」變體並列 rank 池（跟自己做競 util）。
	var delegated: Array = []
	for c in out:
		var dv: Dictionary = _delegate_variant(state, team, ctx, c)
		if not dv.is_empty():
			delegated.append(dv)
	out.append_array(delegated)
	# ★後勤 SLICE A：供給-delivery candidate（surplus holder 知有 demand 市場 → 送貨結買單，GATE-B 撮合物理送貨）。
	out.append_array(_deliver_candidates(state, team, ctx, lv))
	# ★資訊網 distribute side-dispatch：領主賑濟 distribute 已脫主 argmax（跟覓食競爭輸=同 herald/scout 舊病）→
	#   移到 faction_ai._try_distribute_side 平行 side-action（領主下令派賑濟 convoy=directive、body 照覓食）。此處不再進主 rank 池。
	return out

# ★後勤 SLICE B（spec 2026-08-01 §2B、資訊網 de-scan 2026-08-04）：領主憑「聽到的」子民 food buy-order（belief）→ 生 feed-residents candidate。
# 統一光譜:price_factor(honor→0 免費/neutral 公道/greed→markup 高價) + util(relief[honor 放大]+coin[greed 放大])競 argmax
# 對 sell-external(_deliver_candidates)。★連續 weigh 非硬 gate、復用市場非新 class（約束②③④）。
# ★感知鐵律（資訊網 arc de-scan）：**只讀送達 belief（received_buy_orders）+ faction 結構（is_resident_static=組織常識、非 live 態）**——
#   舊「讀本勢力自有居民 deficit=合法 god-view」自辯已被用戶資訊網 arc 否定（領主直掃自家居民 live runway/pop/food=god-view 殘留）。
#   relief 源自 buy-order qty（子民表達了 need），belief stale→可能多送=fog 成本可接受（非偷讀 live 補正）。純算術零 RNG。
const PRICE_MARKUP_CAP: float = 3.0           # TEST VALUE — price_factor 上界（貪婪剝一筆天花板）
# relief need_signal 正規化 scale（★非門檻 gate：任何 qty>=1 仍 fire、NORM 只影響 relief 強度梯度）。
# ★calibration-anchor（DERIVED、PER_HAND 紀律，非 invent 能 fire 常數）：典型小型居民絕境窗全額 food 買單量
#   = 絕境天(DESPERATION_DAYS) × 每人日耗(FOOD_PER_PERSON_PER_DAY) × 典型居民規模(DISTRIB_RELIEF_REF_POP)。
const DISTRIB_RELIEF_REF_POP: float = 5.0     # TEST VALUE — 典型小型定居居民規模（relief scale 參考、非 gate）
const DISTRIB_RELIEF_NORM: float = DecisionTerms.DESPERATION_DAYS * ResourceSystem.FOOD_PER_PERSON_PER_DAY * DISTRIB_RELIEF_REF_POP
# ★de-scan 後 _distribute_candidates 不再用此（deficit 判定改 belief）；仍供 _tick_resident_unrest 居民自讀 runway 回升安全線（自讀非 god-view lord-scan）。
const DISTRIB_DEFICIT_DAYS: float = 4.0       # TEST VALUE — 居民 food runway > 此=脫離 deficit（unrest 回升線）
static func _distribute_candidates(state: WorldState, team: TeamData, ctx: DecisionContext, lv: Dictionary) -> Array:
	var out: Array = []
	# 廉價前閘:僅領主(faction leader)+有餘糧。子隊/無 faction/非領主/太小隊不分配。
	if team.parent_team_id != -1 or team.faction_id == -1 \
			or team.population < FactionAISystem.CONVOY_MIN_PARENT_POP:
		return out
	var f = state.factions.get(team.faction_id)
	if f == null or f.leader_team_id != team.team_id:
		return out   # 只領主分配自有子民
	if float(team.resources.get("food", 0)) <= DELIVER_MARGIN:
		return out   # 廉價 raw-holding 前濾
	var food_surplus: float = ResourceSystem.effective_holding(state, team, "food") \
		- TradeValuation.reserve(team, "food", lv, state)
	if food_surplus <= DELIVER_MARGIN:
		return out   # 無真餘糧可分（守自用 reserve）
	# 人格連續旋鈕（約束②③：weigh 非 gate、price 人格導出連續）
	var greed: float = float(lv.get("貪婪", 0.5))
	var honor: float = float(lv.get("義氣", 0.5))
	var price_factor: float = clampf((0.5 + greed) / (0.5 + honor), 0.0, PRICE_MARKUP_CAP)
	# LIVE-SCAN 在途 convoy 認領（同 _deliver_candidates；散未填單、免堆同居民）。
	var claimed: Dictionary = {}
	for tid in state.teams:
		var pt: TeamData = state.teams[tid]
		if pt.task_extra_data.has("convoy_phase"):
			var coid: int = int(pt.task_extra_data.get("order_id", -1))
			if coid != -1:
				claimed[coid] = float(claimed.get(coid, 0.0)) + float(pt.task_extra_data.get("cargo_qty", 0.0))
	# 掃自有 deficit 居民 food buy-order（received_buy_orders 限本勢力 resident；騎現成 need→buy-order pipeline）。
	var buy_orders: Array = OrderSystem.new().received_buy_orders(state, team)
	var food_val: float = TradeValuation.local_value(team, "food", state)
	var best_util: float = 0.0
	var best: Dictionary = {}
	for o in buy_orders:
		if String(o.get("res", "")) != "food":
			continue
		var rid: int = int(o.get("origin_team", -1))
		if rid == team.team_id or not state.teams.has(rid):
			continue
		var resident: TeamData = state.teams[rid]
		# ★T3 錯位診斷 tap（純觀測、零行為）：領主聽到的每筆 food 買單 origin + faction + pos（定 T2 是否聽到 T1 跨勢力單/gate 擋否）。
		if Probe.enabled:
			Probe.bump_sample("diag.dist_heard", {"lord": team.team_id, "lord_fac": team.faction_id,
				"rid": rid, "rid_fac": resident.faction_id, "opos": str(o.get("pos", Vector2i.ZERO)),
				"gate_same_fac": resident.faction_id == team.faction_id}, 64)
		if resident.faction_id != team.faction_id \
				or not FactionAISystem.is_resident_static(state, resident):
			continue   # 只本勢力自有居民（intra-faction faction 結構=組織常識，非 live 態）
		# ★de-scan（資訊網 arc）：移除 god-view live-read（_resident_food_runway 直讀 resident live pop/food）
		#   + 死常數門檻閘（runway >= DISTRIB_DEFICIT_DAYS continue）。deficit 判定改憑送達 belief（buy-order 存在=子民表達了 need）。
		var mpos = o.get("pos", Vector2i.ZERO)
		if not (mpos is Vector2i) or mpos == team.tile_pos:
			continue
		var oid: int = int(o.get("order_id", -1))
		var eff_rem: float = float(o.get("qty", 0)) - float(claimed.get(oid, 0.0))
		if eff_rem <= 0.0:
			continue   # 已被在途 convoy 認領滿
		var qty: float = minf(food_surplus, eff_rem)
		if qty < 1.0:
			continue
		# util 連續 weigh（約束②、de-scan）：relief（義氣放大救子民）+ coin（貪婪放大抽 coin）。無死常數門檻。
		# ★need_signal 源自送達 belief（buy-order 剩餘 qty=領主聽到的 need 訊）非 live runway；NORM=scale 非 gate。
		var need_signal: float = clampf(eff_rem / DISTRIB_RELIEF_NORM, 0.0, 1.0)
		var relief_term: float = need_signal * (0.3 + honor)
		var coin_term: float = price_factor * food_val * qty * (0.3 + greed) / DELIVER_PAYOFF_NORM
		var u: float = relief_term + coin_term
		if Probe.enabled:
			Probe.bump("distribute.candidate_eval"); Probe.note("distribute.relief_term", relief_term)
		if u > best_util:
			best_util = u
			best = {"qty": qty, "mpos": mpos, "oid": oid, "rid": rid}
	if best.is_empty():
		return out
	# ★T3 錯位診斷 tap（純觀測）：最終選中的賑濟對象 rid + 其 faction + convoy target mpos（定 candidate 選對否/target 解對否）。
	if Probe.enabled:
		Probe.bump_sample("diag.dist_pick", {"lord": team.team_id, "lord_fac": team.faction_id,
			"rid": int(best["rid"]), "rid_fac": (state.teams[int(best["rid"])].faction_id if state.teams.has(int(best["rid"])) else -99),
			"mpos": str(best["mpos"]), "oid": int(best["oid"])}, 32)
	var to_task: Dictionary = {
		"task": TeamData.TASK_CONVOY, "target": best["mpos"], "cargo": {"food": best["qty"]},
		"kind": "distribute", "order_id": int(best["oid"]), "terminus_team_id": int(best["rid"]),
		"price_factor": price_factor, "delegate": true,
	}
	var delay: float = _estimate_delay_days(team, to_task)
	out.append({
		"util": _candidate_util(clampf(best_util, 0.0, GOAL_UTIL_CAP), ctx, delay),
		"to_task": to_task, "label": "distribute_food", "delegate": true,
	})
	return out

# 居民 food runway（複用 resource_system:126 算式：effective_food / burn）。純讀零 RNG。
static func _resident_food_runway(state: WorldState, resident: TeamData) -> float:
	var pop: int = resident.population + resident.minor_population
	if pop <= 0:
		return 9999.0
	var burn: float = float(pop) * ResourceSystem.FOOD_PER_PERSON_PER_DAY
	if burn <= 0.0:
		return 9999.0
	return ResourceSystem.effective_food(state, resident) / burn

# ★後勤 SLICE A（spec 2026-07-31 訂正版 §2）：surplus holder + 知 demand 市場（belief:親聞 buy 單）→ deliver convoy candidate。
# 走 util 秤入 argmax（非 scripted；不 gate ARCHETYPE_TRADE——任何 surplus holder，生產隊菜單缺這個=GATE-B 根）。
# 感知鐵律：demand 讀 received_buy_orders（belief，非 god-view）。純算術零 RNG。
const DELIVER_MARGIN: float = 5.0            # TEST VALUE — surplus 需 > reserve + 此才算真餘量（噪音濾）
const DELIVER_PAYOFF_NORM: float = 100.0     # TEST VALUE — coin gain 正規化（util 秤：coin_gain/此=payoff，clamp<GOAL_UTIL_CAP）
# ★convoy 白名單 res（bound 貴的 reserve/need_keep 呼叫數；只這些值得 convoy 送）。
const CONVOY_RES: Array = ["material", "food", "tools", "goods", "medicine", "arrows"]
static func _deliver_candidates(state: WorldState, team: TeamData, ctx: DecisionContext, lv: Dictionary) -> Array:
	var out: Array = []
	# ★perf 廉價前閘（warring 49+ 隊每 cadence 呼；貴的 received_buy_orders(O(team_known))/reserve 前先廉價濾）：
	if team.parent_team_id != -1 or team.population < FactionAISystem.CONVOY_MIN_PARENT_POP:
		return out   # 子隊/太小隊不派 convoy
	var has_tradeable: bool = false   # 無任何白名單 res 原始餘量 → 免掃 buy orders（廉價 raw holding 檢查）
	for r in CONVOY_RES:
		if float(team.resources.get(r, 0)) > DELIVER_MARGIN:
			has_tradeable = true
			break
	if not has_tradeable:
		return out
	var buy_orders: Array = OrderSystem.new().received_buy_orders(state, team)
	if buy_orders.is_empty():
		return out
	# ★★flow-fix：LIVE-SCAN 在途 convoy 認領（每 order_id 已被 active convoy 認領的 cargo 量）——散未填單、不全堆同單。
	# 鎖 live-scan（禁 state-registry）：死 porter 自動離 state.teams=認領自動失效、結構免疫漏清幽靈認領。純狀態零 RNG。
	var claimed: Dictionary = {}
	for tid in state.teams:
		var pt: TeamData = state.teams[tid]
		if pt.task_extra_data.has("convoy_phase"):
			var coid: int = int(pt.task_extra_data.get("order_id", -1))
			if coid != -1:
				claimed[coid] = float(claimed.get(coid, 0.0)) + float(pt.task_extra_data.get("cargo_qty", 0.0))
	# 散選：掃未填(effective_rem>0)買單，util/gain 秤選 best（非 scripted round-robin；每缺料買家有車去）。
	var best_gain: float = 0.0
	var best: Dictionary = {}
	var reserve_cache: Dictionary = {}   # 每 res 貴的 reserve/effective_holding 只算一次
	for o in buy_orders:
		var res: String = String(o.get("res", ""))
		if res == "" or not (res in CONVOY_RES):
			continue
		if int(o.get("origin_team", -1)) == team.team_id:
			continue   # 自己的買單不送給自己
		if float(team.resources.get(res, 0)) <= DELIVER_MARGIN:
			continue   # ★廉價 raw-holding 前濾（免貴 reserve）
		var mpos = o.get("pos", Vector2i.ZERO)
		if not (mpos is Vector2i) or mpos == Vector2i(-999, -999) or mpos == team.tile_pos:
			continue
		var oid: int = int(o.get("order_id", -1))
		var eff_rem: float = float(o.get("qty", 0)) - float(claimed.get(oid, 0.0))   # 扣在途認領
		if eff_rem <= 0.0:
			continue   # ★該單已被在途 convoy 認領滿 → 跳（散到別單）
		var surplus: float = reserve_cache.get(res, -1.0)
		if surplus < 0.0:
			surplus = ResourceSystem.effective_holding(state, team, res) \
				- TradeValuation.reserve(team, res, lv, state)
			reserve_cache[res] = surplus
		if surplus <= DELIVER_MARGIN:
			continue   # 無真餘量
		var qty: float = minf(surplus, eff_rem)   # ★cap 到 effective_rem（不過載、不搶已認領量）
		if qty < 1.0:
			continue
		var bid: float = TradeValuation.local_value(team, res, state)
		var gain: float = qty * bid
		if gain > best_gain:
			best_gain = gain
			best = {"res": res, "qty": qty, "mpos": mpos, "oid": oid}
	if best.is_empty():
		return out
	# 生 best 未填單的 deliver candidate（散:不同賣方/cadence 各挑未認領 best 單）。
	var to_task: Dictionary = {
		"task": TeamData.TASK_CONVOY, "target": best["mpos"], "cargo": {best["res"]: best["qty"]},
		"kind": "deliver", "order_id": int(best["oid"]), "delegate": true,
	}
	var payoff: float = clampf(best_gain / DELIVER_PAYOFF_NORM, 0.0, GOAL_UTIL_CAP)
	var delay: float = _estimate_delay_days(team, to_task)
	out.append({
		"util": _candidate_util(payoff, ctx, delay),
		"to_task": to_task, "label": "deliver_" + String(best["res"]), "delegate": true,
	})
	return out

# ★S5 委派變體（組件 D）：build/settle 型 action 產「派子隊做」變體。★gate② 正解:applicable=真 viability
# （pop − settler_count ≥ MIN_PARENT_POP_AFTER_DISPATCH，attempt=dispatch 同源→無 pop 8-12 浪費帶）。
# 委派 util=自己做 util+多線紅利(母隊留守+子隊並行)−餘力成本;must-fix① clamp<survival 沿用。純狀態零 randf。
const DELEGATE_MULTILINE_BONUS: float = 0.3   # TEST VALUE — 多線紅利（母隊留守本業+子隊並行，不離 food base）
const DELEGATE_COST: float = 0.1              # TEST VALUE — 餘力成本（分兵管理開銷）
static func _delegate_variant(state: WorldState, team: TeamData, ctx: DecisionContext, self_cand: Dictionary) -> Dictionary:
	# ★A1:founding/facility candidate 本身已 delegate（派子隊建）→ 別再包委派的委派（早退）。
	if self_cand.get("delegate", false):
		return {}
	var to_task: Dictionary = self_cand.get("to_task", {})
	var task: String = String(to_task.get("task", ""))
	if task != TeamData.TASK_BUILD and task != TeamData.TASK_SETTLE:
		return {}   # 只 build/settle 型委派（S5）
	# ★gate② viability（attempt=dispatch 同源，根治 8-12 浪費帶）
	var pop: int = team.population
	var settler: int = clampi(pop / 4, 2, 5)
	if pop - settler < FactionAISystem.MIN_PARENT_POP_AFTER_DISPATCH:
		return {}   # 餘力不足 → 無委派變體（只自己做，pop-guard 擋=多線無委派恆贏）
	var base_u: float = float(self_cand.get("util", 0.0))
	var deleg_u: float = clampf(base_u + DELEGATE_MULTILINE_BONUS - DELEGATE_COST, 0.0, GOAL_UTIL_CAP)   # must-fix① clamp 沿用
	var dtask: Dictionary = to_task.duplicate()
	dtask["delegate"] = true
	dtask["settler"] = settler   # 派子隊 pop（餘力 gate 配額）
	return {
		"util": deleg_u,
		"to_task": dtask,
		"source_goal": self_cand.get("source_goal", {}),
		"label": String(self_cand.get("label", "")) + ":delegate",
		"delegate": true,
	}

# ★S4 設施發展 resolution（組件 C 設施型）：walk build_F 前置鏈——resource(build-cost)→facility(outpost-type)
# →manpower(pop)→全滿 build_F action。first-unsatisfied 前置生 frontier（means-end 湧現順序）。
static func _resolve_build_facility(state: WorldState, team: TeamData, ctx: DecisionContext,
		g: Dictionary, gt: String, def: Dictionary) -> Dictionary:
	var f: String = String(def.get("facility", ""))
	var fdef: Dictionary = OutpostSystem.FACILITY_DEF.get(f, {})
	if fdef.is_empty():
		return {}
	var payoff: float = float(def.get("payoff", 1.5))
	var own: Vector2i = FactionAISystem.new()._find_own_outpost(state, team)
	var own_tile: HexTileData = state.world.tiles.get(own.x * 1000 + own.y) if own != Vector2i(-1, -1) else null
	# F 已建 → satisfied（無 candidate）。
	if own_tile != null and int(own_tile.get(fdef.get("current_level_key", ""))) > 0:
		return {}
	# 前置 1：resource build-cost（material/tools）——缺→接 S2/S3 資源鏈（need_keep 已含 construction need）。
	var cost: Dictionary = OutpostSystem.upgrade_cost(f, 1)
	for res in ["material", "tools"]:
		if float(cost.get(res, 0)) > 0.0:
			var c: Dictionary = _resolve_resource_prereq(state, team, ctx, g, gt, payoff, {"kind": GoalRegistry.PREREQ_RESOURCE, "res": res})
			if not c.is_empty():
				return c   # first-unsatisfied resource → 取得 frontier（買/採）
	# 前置 2：facility outpost-type（需 allowed_outpost type outpost）——無合適 type→建 outpost frontier。
	var allowed: Array = fdef.get("allowed_outpost", [])
	if own_tile == null or not (own_tile.outpost_type in allowed):
		# ★A1 裁②：same-tile founding（隊站空 tile 建 new outpost）無母隊就地 outpost-build 路 → 移除 candidate，靜默。
		# 屬 facility-type-mismatch known_issues followup（non-A1-core），前置未滿=靜默（whole-system-first，不造假）。
		return {}
	# 前置 3：manpower pop（既有 build pop 門檻）——不足→靜默（S4 最小，passive 繁殖增，無主動 recruit task）。
	if team.population < GoalRegistry.FACILITY_BUILD_POP_MIN:
		return {}
	# ★A1 全滿 → facility 建：
	# owner 在場（team 站 own outpost）→ **defer 給 infra path**（不生 candidate）。infra desire-based _pick_facility
	# 選最想建 facility 就地建（較 goal REGISTRY-order 聰明；單一 build slot 不撞），忠於二裁意圖「接 infra path 非另立子隊路」。
	# （goal REGISTRY-order 就地建會壟斷 build slot→礦村建 workshop 非 mint→15360 regression；量測坐實。）
	if team.tile_pos == own_tile.tile_pos:
		return {}
	# owner 不在場（own outpost 在別格）→ facility candidate（派子隊 remote 真移動→抵達→建，_dispatch_facility_builder）。
	return _mk_delegate_candidate(team, g, gt, GoalRegistry.PREREQ_FACILITY, payoff, ctx,
		{"facility": f, "target": own_tile.tile_pos})

# ★S2/S3 資源型前置 resolution：未滿→取得 candidate（S2 買 / S3 採@地形定位）。
const SEEK_TILE_RANGE: int = 30   # TEST VALUE — belief-reachable 上界（bounded seek，非全知 PathSystem live）
# ★★「哪種地形產哪種資源」的【唯一真相源】＝ `ResourceSystem.REGEN_RATE`（2026-08-25）。
#   ★手抄本 `RES_HARVEST_TERRAIN = {"material": "forest"}` 已刪 —— 它與真相源【直接矛盾】：
#   表說 food 不可採，而 REGEN_RATE 裡【三種地形全都產 food】，且 plains 的 food(8.0)
#   是全表最高之一（比它產 material 的 0.5 多 16 倍）。
#   ⇒ 「缺糧 → 去平原建據點採」這條取得手段【整條靜默不存在】：
#     它連「找不到地形」都不會記，在 has(res) 那一行就被判定為「沒有這種手段」。
#   ★量測：2089 次落到本手段，2061 次死在那一行（food 133 / tools 625 / weapon 1303）。
#   ⛔ 修法【不是】把 food 補進表 —— 那是同一個病的延續（〈估算器禁手抄物理〉）。
# ★僅觀測用去重帳（Probe.enabled 才寫）：答【單位】那一問，不影響決策。
static var _fall_seen: Dictionary = {}

static func harvest_terrains(res: String) -> Array:
	var out: Array = []
	for tn in ResourceSystem.REGEN_RATE:   # Dictionary 保持插入序 ⇒ determinism 安全
		var y: float = float((ResourceSystem.REGEN_RATE[tn] as Dictionary).get(res, 0.0))
		if y > 0.0:
			out.append({"terrain": String(tn), "yield": y})
	return out
# ★「產多少才算可採」沒有門檻常數：★>0 就是候選，孰優孰劣交給折現值比。
#   （mountain 的 food 0.5 不需要被一個我拍的門檻擋掉 —— 它會自己輸給 plains 的 8.0。
#    加門檻＝新旋鈕＝把比較的工作換成猜一個數。）

static func _resolve_resource_prereq(state: WorldState, team: TeamData, ctx: DecisionContext,
		g: Dictionary, gt: String, payoff: float, prereq: Dictionary) -> Dictionary:
	var res: String = String(prereq.get("res", ""))
	var lv: Dictionary = TradeValuation.leader_vals(state, team)
	# 組件 E 泛化：qty 走通用 need_keep（任 res）。
	if Probe.enabled: Probe.bump("goal.res_prereq.entry")
	if ResourceSystem.effective_holding(state, team, res) >= NeedOracle.need_keep(state, team, res, lv):
		if Probe.enabled: Probe.bump("goal.res_prereq.satisfied")
		return {}   # 前置滿
	# ── 取得手段 1：買（S2，市場取得不需定位；belief-gated）──
	if not ctx.has_specie:
		if Probe.enabled: Probe.bump("goal.res_prereq.no_specie")
	if ctx.has_specie:
		var mp: Vector2i = FactionAISystem.new()._nearest_market_outpost_with(state, team, res)
		if mp != Vector2i(-1, -1):
			if Probe.enabled: Probe.bump("goal.res_prereq.buy_wins")
			return _mk_candidate(team, g, gt, GoalRegistry.PREREQ_RESOURCE, payoff, ctx, {"task": TeamData.TASK_TRADE, "target": mp})
		if Probe.enabled: Probe.bump("goal.res_prereq.no_market")
	# ── 取得手段 2：採@地形（S3，買不到→定位取得）——★地形集合由真相源導出，不查表。
	# ★湧現閉環：缺料→(a)移動到產地→(b)到了建 outpost→own.terrain 產該資源→採 satisfied。
	if Probe.enabled:
		# ★母體三問（systems 立 2026-08-25）：多大／是不是 0／【單位是什麼】。
		#   血證：同一 team+tick 重複 4 次（一支隊多個 active goal 各問一次同一資源）
		#   ⇒ 這個數是【前置解析次數】，不是【獨立機會數】。
		#   ★兩個都報，不替換：拿哪一個當分母是量測語意的決定，不是我的。
		Probe.bump("goal.res_fall.%s" % res)
		var _dk: String = "%d|%d|%s" % [team.team_id, state.world.current_tick, res]
		if not _fall_seen.has(_dk):
			_fall_seen[_dk] = true
			Probe.bump("goal.res_fall_distinct.%s" % res)
	var terr_cands: Array = harvest_terrains(res)
	if not terr_cands.is_empty():
		var own: Vector2i = FactionAISystem.new()._find_own_outpost(state, team)
		var own_tile: HexTileData = state.world.tiles.get(own.x * 1000 + own.y) if own != Vector2i(-1, -1) else null
		# ★★【已滿足】不是布林，是同一個比較（血證 2026-08-25）：
		#   改成從真相源導出之後，「自家地形有產這個資源」幾乎恆真
		#   （material 三種地形全產，plains 只有 0.5 但 > 0）
		#   ⇒ material 的候選全掉進 satisfied，舊行為退化（量到：emitted.material 28 → 0）。
		#   ★修法不是補一個「產多少才算數」門檻常數（那是新旋鈕），
		#   而是把這個布林也收進【同一個折現值比較】：
		#   ★【自家產地的值 ≥ 任何替代產地的值（含路程折現）】⇒ 沒必要再跑一趟 = 已滿足。
		#   這樣 plains(0.5) 的小產地擋不住 forest(12.0)，而真正夠好的自家產地仍然會止住從軍。
		var own_yield: float = 0.0
		if own_tile != null:
			own_yield = float((ResourceSystem.REGEN_RATE.get(own_tile.terrain, {}) as Dictionary).get(res, 0.0))
		# ★多地形產同一資源時挑哪個：★折現值比較（產量 × 距離延遲），不是新的排序表。
		#   value = pv(產量) × δ^(路程天數) —— 遠的產地被等待折現天然懲罰，近而少產的可能反勝。
		#   ★h 用【隊自己的存續視野】而非逐候選重算：本資源未必是食物，
		#   把 material 產量加進 food 淨流去算視野是量綱錯誤。h 對所有候選相同 ⇒ 排序由 產量×δ^delay 決定。
		var d: float = DiscountedFlow.delta_of(ctx.leader_values)
		var h: float = DiscountedFlow.horizon_eff(ctx.net_food_flow, ctx.food_stock)
		var best_pos: Vector2i = Vector2i(-1, -1)
		var best_v: float = -1.0
		for tc in terr_cands:
			var p: Vector2i = find_nearest_terrain_tile(state, team, String(tc["terrain"]), SEEK_TILE_RANGE)   # 純地形=公共地理
			if p == Vector2i(-1, -1) or p == team.tile_pos:
				continue
			var delay: float = float(FactionAISystem._hex_dist(team.tile_pos, p)) / FactionAISystem.FOOD_BRIDGE_MOVE_PER_DAY
			var v: float = DiscountedFlow.option_value(float(tc["yield"]), 0.0, 0.0, d, h) \
				* pow(clampf(d, DiscountedFlow.DELTA_FLOOR, DiscountedFlow.DELTA_CAP), maxf(delay, 0.0))
			if v > best_v:
				best_v = v
				best_pos = p
		# ★自家產地的值：delay = 0（人已經在那裡），同一支 option_value。
		var own_v: float = DiscountedFlow.option_value(own_yield, 0.0, 0.0, d, h) if own_yield > 0.0 else -1.0
		if own_v >= best_v and own_v > 0.0:
			if Probe.enabled:
				Probe.bump("goal.harvest.satisfied_own_terrain")
				# ★把【判定的依據】也寫出來：帳平只證明沒漏算，不證明每一案判斷正確。
				Probe.bump_sample("goal.harvest.satisfied_own_terrain", {"team": team.team_id, "res": res,
					"own_terrain": own_tile.terrain, "own_yield": own_yield,
					"own_v": snappedf(own_v, 0.001), "best_alt_v": snappedf(best_v, 0.001),
					"tick": state.world.current_tick}, 30)
			return {}   # ★自家產地已經不輸給任何替代 ⇒ 再跑一趟無益
		if Probe.enabled:
			if best_pos == Vector2i(-1, -1):
				Probe.bump("goal.harvest.no_reachable_site")
			else:
				Probe.bump("goal.harvest.emitted")
				Probe.bump("goal.harvest.emitted." + res)
		# ★A1 裁③：remote founding（異格）→ 派子隊（子隊真移動→抵達→建，正常）。
		# ★裁② guard：pos == team.tile_pos（隊已站產地）= same-tile founding，無母隊就地 outpost-build 路 → 已於上面 continue（followup）。
		if best_pos != Vector2i(-1, -1):
			return _mk_delegate_candidate(team, g, gt, GoalRegistry.PREREQ_LOCATION, payoff, ctx,
				{"build_type": "civilian", "target": best_pos})
	elif Probe.enabled:
		Probe.bump("goal.harvest.not_terrain_produced." + res)   # ★B 型：地形本來就不產（缺的是【製造】那條手段）
	return {}   # S3 無取得手段（產=S4 設施 / same-tile founding=followup）

# ★★把 means-end 磚接進決策（systems 裁 2026-08-25，spec §3）。
#   ★磚在上一票已完成但【零 production caller】＝ dormant ⇒「為了取得 X 先做 Y」從來沒進過隊伍的腦。
#   ★新增這支、【不改】既有 `_resolve_resource_prereq` 簽名（:362 的 caller 維持不動）。
#   ⇒ 舊行為（買／採@地形）原樣保留，製造那條是【追加】的候選，由 argmax 自己比。
static func _resource_prereq_candidates(state: WorldState, team: TeamData, ctx: DecisionContext,
		g: Dictionary, gt: String, payoff: float, prereq: Dictionary) -> Array:
	var out: Array = []
	var first: Dictionary = _resolve_resource_prereq(state, team, ctx, g, gt, payoff, prereq)
	if not first.is_empty():
		out.append(first)
		return out   # 買／採@地形已給出手段 ⇒ 不必再問製造（既有優先序不變）
	# ★走到這裡＝既有兩條手段都沒有 ⇒ 問 means-end：「這東西誰產、我缺什麼」
	var res: String = String(prereq.get("res", ""))
	if res == "":
		return out
	for path in AcquisitionPaths.for_resource(state, team, res):
		var blocked: String = String(path.get("blocked_on", ""))
		var pkind: String = String(path.get("kind", ""))
		var _depth: int = int(path.get("depth", 0))   # ★懷疑點(i)：util 隨 depth 的分佈
		if pkind == "facility":
			# ★缺設施 ⇒ 下一步是【蓋它】，走既有 facility 委派路徑（不另造 dispatch）
			# ★payoff 繼承【所服務 goal】（systems WHAT 裁 2026-08-25）：
			#   「為了取得 X 先做 Y」的價值 ＝ 取得 X 的價值 ⇒ 與既有 candidate 【打平】，
			#   勝負交給 delay／depth／成本去分。
			#   ★舊寫法把 maintain goal 的 payoff(1.0) 蓋掉設施自己的(1.5)
			#   ⇒ 量到【每一筆 winner_util 恆等 me_util × 1.5】——同一個行動被評兩次、分數不同。
			#   ★不覆寫：蓋工坊這個行動的價值來自工坊 goal，不因為【是誰問】而改變。
			# ★★★一行動一真值（blueprint WHAT 裁定 2026-08-25，修正它自己先前的錨）：
			#   同一行動【不論哪條推理路徑提出】必須同價。
			#   價值屬於行動的【後果全集】，不屬於觸發它的那個需求——
			#   工坊是耐久資產，後果超出「拿到 tools」，所以帶設施 goal 的 payoff。
			#   ★不靠 default 湊：`_resolve_build_facility` 的 default 剛好也是 1.5，
			#   但【靠 default 達成的相等】在有人改 default 時會靜默斷掉。
			#   ★路徑：systems 曾依舊錨定案 1.0，blueprint 修錨後改判 1.5；兩組實測都在交件信裡。
			var _fname: String = _facility_of_level_key(blocked)
			var _fdef: Dictionary = {"facility": _fname}
			for _rgt in GoalRegistry.REGISTRY:
				var _rd: Dictionary = GoalRegistry.REGISTRY[_rgt] as Dictionary
				if String(_rd.get("facility", "")) == _fname:
					_fdef = _rd
					break
			var fc: Dictionary = _resolve_build_facility(state, team, ctx, g, gt, _fdef)
			# ★★★本票的【世界層價值】只在這一格（systems 最後一格）：
			#   若既有 candidate 總是在，兩者等價 ⇒ means-end 對世界零影響。
			#   ★既有候選存在 ⟺ 隊的 goal_state 裡有對應的 active build_<facility> goal。
			#   ⇒ 這裡直接查：沒有那個 goal 時，means-end 補上的就是【既有機制沉默處】的提案。
			if Probe.enabled and not fc.is_empty():
				var _existing: bool = false
				for _g2 in team.goal_state:
					var _gt2: String = String(_g2.get("goal_type", ""))
					if String(GoalRegistry.BUILD_FACILITY_GOALS.get(_gt2, "")) != _fname:
						continue
					if String(_g2.get("status", "")) == "active":
						_existing = true
						break
				if _existing:
					Probe.bump("means_end.dup_existing_present")
				else:
					Probe.bump("means_end.unique_no_existing")
					Probe.bump("means_end.unique_no_existing." + _fname)
				# ★是【哪一支隊】提的設施(2026-08-26)：計數只說「發生了幾次」，說不出【誰】
				#   ⇒ specimen 挑不到主角、故事線「缺料 → 提出蓋工坊/兵器坊」永遠寫不出來。
				#   純 tap（Probe-gated、零 RNG、不參與任何判斷）。
				Probe.bump_sample("means_end.facility_proposed", {
					"team": team.team_id, "facility": _fname, "res": res,
					"dup": _existing, "tick": state.world.current_tick}, 200)
				# ★★★逐筆身分（measurer 卡住的那顆，systems 派 2026-08-26）：
				#   `means_end.unique_no_existing.<fname>` 只有【加總】bump，沒有身分
				#   ⇒ ★`224` 這個數從落地那天起就沒有可去重的原始資料。
				#   ★★而 `_resolve_build_facility` 在缺料時回的是【去市場買 material】的 candidate
				#     （`task=TASK_TRADE`、target=市場），不是蓋那個 facility 的 —— 外層卻按觸發它的
				#     `_fname` 分開 bump ⇒ 同一個真實行動被計成好幾個不同 facility 的「新提案」。
				#     ⇒ 有了 target/task 就一比就知道。★cap 500（母體 380；小於它會被 first-N 截成假窮盡）。
				#   ★★★加在 `if` 區塊【內】、不動任何控制流（上一次 tap 把 `out.append` 推出 `if` 外，
				#     `emitted 380→2116`，同時作廢了建在那批數字上的整條推論）。
				#   ★★★欄位改名 `task` → `act`（2026-08-26）：它裝的【已經不是 task】——
				#     build／founding candidate 的 `to_task` 既沒有 `task` 也沒有 `facility`，
				#     它有的是 `build_type` ⇒ 舊 fallback 鏈 `task → facility → ""` 一律落到空字串
				#     ⇒ ★量到 114/224（50.9%）身分欄空白，★★而那正是【真的要去蓋東西】的那一類
				#       —— 這顆 tap 想給身分的對象，剛好是它看不見的對象。
				#     ★叫 `task` 會讓下一個讀的人以為那 114 筆「真的沒有 task」。
				var _tt2: Dictionary = (fc.get("to_task", {}) as Dictionary)
				var _act: String = String(_tt2.get("task", _tt2.get("facility", _tt2.get("build_type", ""))))
				# ★★★key 改名(2026-08-26)：舊名 `unique_no_existing.identity` 【在說謊】——
				#   這顆 sample 掛在 `if/else` 之外，★同時記 unique 與 dup（實測 174 = unique 125 + dup 49）
				#   ⇒ 名字宣告了一個它沒做的過濾 ⇒ 讀的人會把 174 當 unique 母體，安靜地大 25%。
				#   ★★名字負責不騙人、註解負責講清楚：**算 unique 請 `filter(existing == false)`**。
				#   ★不改成「只記 unique」：dup 那一支對「同一行動穿幾件戲服」同樣有用，而 `existing` 分得出來。
				Probe.bump_sample("means_end.candidate_identity",
					{"fname": _fname, "target": _tt2.get("target"),
					 # ★tick／team（systems 2026-08-26）：measurer 量到 62 筆 act=貿易 收斂到 3 個 target，
					 #   ★但他明講【未坐實】——沒有 tick 就證明不了「同一個 tick 內」。★欄位名與
					 #   `funnel.cand.identity` 對齊。
					 "tick": state.world.current_tick, "team": team.team_id,
					 # ★★★戲服假說的【判定用鍵】(systems 2026-08-26，明說是為這個問題加的【最後一欄】)：
					 #   ★問題已三次停在「強烈支持、未坐實」（QA 逐位元相同 → measurer 62→3 target →
					 #     funnel 四胞胎樣本），每次都差一個欄位 ⇒ 這次把【是非題答得完】的三鍵一起帶。
					 #   ★★只帶判定用的三鍵（task／target／build_type），★不是整包 to_task
					 #     —— 整包會把無關欄位的差異也算進「不同行動」。
					 #   ★★★這一欄是為【單一問題】加的：戲服假說坐實或推翻之後，這三鍵可以拆掉。
					 #     （加的時候就寫下它什麼時候該死，否則它會變成沒有人敢刪的常設欄位。）
					 "k_task": String(_tt2.get("task", "")),
					 "k_build_type": String(_tt2.get("build_type", "")),
					 "act": _act,
					 # ★仍是空的話，把鍵名原樣帶出來 —— ★★不猜第四個鍵（systems 明令）
					 "to_task_keys": ("" if _act != "" else str(_tt2.keys())),
					 "existing": _existing}, 500)
			if not fc.is_empty():
				fc["me_depth"] = _depth
				# ★設施【具名】(2026-08-26，QA 故事稽核抓的)：candidate 的 label ＝ `goal_type:frontier_kind`，
				#   `to_task` 只帶 `build_type`（`civilian` 是 outpost 類型，不是設施名）
				#   ⇒ ★自建分支在 trace 裡【讀不出它到底要蓋什麼】，故事停在「蓋某個東西」。
				#   純資料欄，只被 tracer 讀，不參與任何判斷。
				fc["me_facility"] = _fname
				out.append(fc)   # ★空字典不能進 out：掉出 if 外會讓 out 幾乎恆非空
		elif pkind == "material":
			# ★缺原料 ⇒ 遞迴結果各自成 candidate：把「缺什麼」變成一個真的可選行動
			var sub: Dictionary = {"kind": GoalRegistry.PREREQ_RESOURCE, "res": blocked}
			var subc: Dictionary = _resolve_resource_prereq(state, team, ctx, g, gt, payoff, sub)
			if not subc.is_empty():
				subc["me_depth"] = _depth
				out.append(subc)   # ★空字典不能進 out：掉出 if 外會讓 out 幾乎恆非空
		elif pkind == "ready":
			# ★前置全滿 ⇒ 直接製造
			var _rc: Dictionary = _mk_candidate(team, g, gt, GoalRegistry.PREREQ_RESOURCE, payoff, ctx,
				{"task": TeamData.TASK_MANUFACTURE, "target": team.tile_pos})
			_rc["me_depth"] = _depth
			out.append(_rc)
		# ★★★stock 形狀：出口【解封】（2026-08-26）。當初裁「不進價值比較」的理由只有一個
		#   ——【沒有正確的尺】（拿流的尺量存量＝系統性高估，且錯成一個看起來正常的數字）。
		#   `DiscountedFlow.stock_utility` 就是那把尺 ⇒ 這裡開始生 candidate。
		elif String(path.get("shape", "")) == "stock":
			if Probe.enabled: Probe.bump("means_end.stock_seen." + res)
			var _spos: Vector2i = path.get("pos", Vector2i(-1, -1))
			var _sgain: float = float(path.get("gain_daily", 0.0))
			var _samt: float = float(path.get("amount", 0.0))
			if _spos != Vector2i(-1, -1) and _sgain > 0.0 and _samt > 0.0:
				var _sdelay: float = float(FactionAISystem._hex_dist(team.tile_pos, _spos)) \
					/ FactionAISystem.FOOD_BRIDGE_MOVE_PER_DAY
				# ★★用【兩把尺的比值】而不是直接拿 stock_utility 當 util —— 理由是【量綱】：
				#   兄弟 candidate 的 util 都出自 `_candidate_util(payoff, ctx, delay)`（payoff 尺），
				#   `stock_utility` 出的是「相當於幾倍餬口」（食物尺）。混在同一個 argmax 裡比大小
				#   ＝ 拿兩把不同單位的尺量同一件事。
				#   ⇒ 這裡只取 stock_utility ÷ flow_utility ＝ ★【有限存量讓這條流的價值剩下幾成】，
				#     它是無量綱的、∈(0,1]，把「礦會挖完」這件事乘進既有尺裡。
				#   ★★驗收③直接落在這裡：存量撐得滿視野 ⇒ 比值 ＝ 1 ⇒ 與「當成流」逐位相同。
				# 日需求＝人口 × 每人日耗（同 `terms.gd:231` 的取法，★同一個真相源不另造）
				var _need_d: float = float(ctx.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY
				var _flow_v: float = DiscountedFlow.flow_utility(_sgain, 0.0, _need_d,
					ctx.leader_values, ctx.net_food_flow, ctx.food_stock, 0.0, _sdelay)
				var _stock_v: float = DiscountedFlow.stock_utility(_sgain, 0.0, _need_d,
					ctx.leader_values, ctx.net_food_flow, ctx.food_stock, _samt, 0.0, _sdelay)
				var _finite_ratio: float = clampf(_stock_v / _flow_v, 0.0, 1.0) if _flow_v > 0.0 else 0.0
				var _sc: Dictionary = _mk_candidate(team, g, gt, "stock_site", payoff, ctx,
					{"task": TeamData.TASK_PRODUCE, "target": _spos})
				_sc["util"] = float(_sc.get("util", 0.0)) * _finite_ratio
				_sc["me_depth"] = int(path.get("depth", 0))
				_sc["me_stock"] = _samt
				_sc["me_finite_ratio"] = _finite_ratio
				out.append(_sc)   # ★空字典不能進 out（同上，那行註解是上一顆 bug 的墓碑）
				if Probe.enabled:
					Probe.bump("means_end.stock_candidate." + res)
					Probe.bump_sample("means_end.stock_priced", {"team": team.team_id, "res": res,
						"stock": snappedf(_samt, 0.1), "gain_daily": snappedf(_sgain, 0.001),
						"days_of_stock": snappedf(_samt / maxf(_sgain, 0.001), 0.01),
						"finite_ratio": snappedf(_finite_ratio, 0.0001),
						"flow_u": snappedf(_flow_v, 0.0001), "stock_u": snappedf(_stock_v, 0.0001),
						"tick": state.world.current_tick}, 60)
	# ★標記來源：【產出】與【贏】是兩件事，要分開量才分得出
	#   「接上了、有產出、但從不改變結果」這個最危險的解釋。
	for _c in out:
		var _cd: Dictionary = _c as Dictionary
		_cd["means_end"] = true
		_cd["me_res"] = res
		_cd["me_payoff"] = payoff   # ★懷疑點(ii)：同 goal 下各 candidate 的 payoff 是否一模一樣
	if Probe.enabled and not out.is_empty():
		Probe.bump("means_end.candidates_emitted")
		Probe.bump("means_end.candidates_emitted." + res)
		# ★★分辨（systems 派）：【發展型】還是【求生型】被 dev_coeff 歸零？
		#   ★dev_coeff = food_days / DESPERATION_DAYS ⇒ 絕境時【所有】goal-derived candidate 都歸 0。
		#   ★快餓死不該想擴張 ＝ 正確；但「為了活下去而必須先做的事」也被壓死 ＝ 可能錯。
		#   ★所以要同時記【服務哪個 goal】與【當下是不是絕境】。
		Probe.bump("means_end.by_goal." + gt)
		if ctx != null and ctx.food_days < DecisionTerms.DESPERATION_DAYS:
			Probe.bump("means_end.desperate_by_goal." + gt)
			Probe.bump_sample("means_end.desperate", {"gt": gt, "res": res,
				"food_days": snappedf(ctx.food_days, 0.01), "team": team.team_id}, 60)
	return out

# ★設施欄位 key → FACILITY_DEF 名（真相源反查，不建對照表）。
static func _facility_of_level_key(level_key: String) -> String:
	for fname in OutpostSystem.FACILITY_DEF:
		if String((OutpostSystem.FACILITY_DEF[fname] as Dictionary).get("current_level_key", "")) == level_key:
			return String(fname)
	return ""

# ★S3 定位型前置 handler（組件 C）：{kind:location, terrain, control?}。查隊在/有滿足 tile，未滿→tile frontier candidate。
static func _resolve_location_prereq(state: WorldState, team: TeamData, ctx: DecisionContext,
		g: Dictionary, gt: String, payoff: float, prereq: Dictionary) -> Dictionary:
	var terrain: String = String(prereq.get("terrain", ""))
	var need_control: bool = bool(prereq.get("control", false))
	# 已滿？隊在/擁有滿足條件 tile（own outpost terrain match）。
	var own: Vector2i = FactionAISystem.new()._find_own_outpost(state, team)
	var own_tile: HexTileData = state.world.tiles.get(own.x * 1000 + own.y) if own != Vector2i(-1, -1) else null
	if own_tile != null and (terrain == "" or own_tile.terrain == terrain):
		return {}   # 已在/擁有 → 前置滿
	# 未滿 → ★tile-resolver 拆兩類（must-fix②）：
	var pos: Vector2i
	if need_control:
		# (ii) 所有權/control 動態狀態 → belief store（踩市集判例，禁全圖 god-view）
		pos = find_nearest_known_tile(state, team, terrain)
	else:
		# (i) 純地形/物理地理 → 公共知識全圖掃（# gate-ok）
		pos = find_nearest_terrain_tile(state, team, terrain, SEEK_TILE_RANGE)
	if pos == Vector2i(-1, -1):
		return {}
	return _mk_candidate(team, g, gt, GoalRegistry.PREREQ_LOCATION, payoff, ctx, {"task": TeamData.TASK_MIGRATE, "target": pos})

static func _mk_candidate(team: TeamData, g: Dictionary, gt: String, frontier_kind: String, payoff: float,
		ctx: DecisionContext, to_task: Dictionary) -> Dictionary:
	return {
		"util": _candidate_util(payoff, ctx, _estimate_delay_days(team, to_task)),   # ★S6:util 含 delay 折現
		"to_task": to_task,
		"source_goal": g,
		"label": gt + ":" + frontier_kind,   # root_goal + frontier_kind（有界 label，HOW §7）
		"delegate": false,   # 委派變體 = S5（組件 D）別提前
	}

# ★A1 founding/facility delegate candidate：新建 outpost（build_type）或自家 outpost 建設施（facility）
# 本質=派子隊施工（複用既有 _dispatch_builder / _dispatch_facility_builder working consumer，非發無 consumer 的 TASK_BUILD）。
# to_task 帶 delegate=true→faction_ai 路由 _dispatch_goal_delegate 型別分支。util 走 must-fix① 護欄（clamp<survival）。
static func _mk_delegate_candidate(team: TeamData, g: Dictionary, gt: String, frontier_kind: String,
		payoff: float, ctx: DecisionContext, core: Dictionary) -> Dictionary:
	var to_task: Dictionary = core.duplicate()
	to_task["delegate"] = true
	to_task["settler"] = clampi(team.population / 4, 2, 5)   # 派子隊配額（founding 分支 _dispatch_builder 內部自估，此為 generic 保底）
	return {
		"util": _candidate_util(payoff, ctx, _estimate_delay_days(team, to_task)),
		"to_task": to_task,
		"source_goal": g,
		"label": gt + ":" + frontier_kind + ":delegate",
		"delegate": true,
	}

# ★must-fix②(i) 純地形/物理地理查詢（公共知識 legit）→ 全圖掃標 # gate-ok（比照 constitution_gate:41）。
# belief-reachable=bounded hex dist（非全知 PathSystem live）。決定性 tie-break tile_id。零 randf。
static func find_nearest_terrain_tile(state: WorldState, team: TeamData, terrain: String, max_range: int) -> Vector2i:
	# ★perf cut1 B(memo) stripped：measurer quantify 證 memo 0 命中（warring frontier 每 goal 查不同 terrain）
	#   =死重量 YAGNI 出局；純掃回歸。刀A（_hex_dist static）保留。
	var best: Vector2i = Vector2i(-1, -1)
	var best_d: int = 1 << 30
	var best_id: int = 1 << 30
	for tid in state.world.tiles:   # gate-ok: 地理=公共知識（terrain 靜態物理地理非動態所有權，比照 constitution_gate:41 市集地理先例）
		var t: HexTileData = state.world.tiles[tid]
		if t == null or (terrain != "" and t.terrain != terrain):
			continue
		var d: int = FactionAISystem._hex_dist(team.tile_pos, t.tile_pos)   # ★perf cut1 A：static（免 fai alloc、保留）
		if d > max_range:
			continue   # belief-reachable bounded（非全知 PathSystem）
		if d < best_d or (d == best_d and int(tid) < best_id):
			best_d = d; best_id = int(tid); best = t.tile_pos
	return best

# ★must-fix②(ii) 所有權/control 動態查詢（踩 invariants:192 市集判例）→ 讀 team_tile_known belief（禁全圖 god-view）。
# 決定性 tie-break tile_id。零 randf。
static func find_nearest_known_tile(state: WorldState, team: TeamData, terrain: String) -> Vector2i:
	_harvest_tile_known(state, team)
	var known: Dictionary = state.team_tile_known.get(team.team_id, {})
	var best: Vector2i = Vector2i(-1, -1)
	var best_d: int = 1 << 30
	var best_id: int = 1 << 30
	for tid in known:   # 只掃 belief store（已發現 tile，非全圖）→ 無 god-view
		var t: HexTileData = state.world.tiles.get(tid)
		if t == null or (terrain != "" and t.terrain != terrain):
			continue
		var d: int = FactionAISystem._hex_dist(team.tile_pos, t.tile_pos)   # ★perf cut1 A：static（免 fai alloc）
		if d < best_d or (d == best_d and int(tid) < best_id):
			best_d = d; best_id = int(tid); best = t.tile_pos
	return best

# ★team_tile_known belief harvest（鏡射 _harvest_market_known）：兩源=bounded vision + relay。禁 RNG。
static func _harvest_tile_known(state: WorldState, team: TeamData) -> void:
	var known: Dictionary = state.team_tile_known.get(team.team_id, {})
	var fai := FactionAISystem.new()
	var vr: int = VisionSystem.VISION_RADIUS
	for dx in range(-vr, vr + 1):   # bounded=vision（非全圖 god-view）
		for dy in range(-vr, vr + 1):
			var p: Vector2i = team.tile_pos + Vector2i(dx, dy)
			if FactionAISystem._hex_dist(team.tile_pos, p) > vr:   # ★perf cut1 A：static
				continue
			var tid: int = p.x * 1000 + p.y
			if state.world.tiles.has(tid):
				known[tid] = true
	# relay：team_known tile 訊息 pos（reuse market pos extractor）→ known
	for msg in state.team_known.get(team.team_id, []):
		var mpos: Vector2i = fai._msg_market_pos(msg)
		if mpos == Vector2i(-999, -999):
			continue
		known[mpos.x * 1000 + mpos.y] = true
	state.team_tile_known[team.team_id] = known

# ★S6 折現（組件 F，HOW §7）：delay-based discount（連續，符憲法 utility 連續）。
const MOVE_TILES_PER_DAY: float = 2.0   # TEST VALUE — 移速估（淺啟發，delay 有界）
# ★工期單一真相源（2026-08-25）：舊 `BUILD_DAYS_EST = 3.0` 是手抄的一個「大概三天」——
#   它其實只在 pop≈10 時才對，pop 少一半就要兩倍時間。改讀 `OutpostSystem.build_eta_days`。
const DISCOUNT_BASE: float = 0.5        # TEST VALUE — 折現率基值（人格/絕境調）

# delay 估（淺啟發有界）：移動天數（target hex dist÷移速）+ build/settle 工期。純狀態零 randf。
static func _estimate_delay_days(team: TeamData, to_task: Dictionary) -> float:
	var days: float = 0.0
	var target = to_task.get("target", Vector2i(-1, -1))
	if team != null and target is Vector2i and target != Vector2i(-1, -1) and target != team.tile_pos:
		days += float(FactionAISystem._hex_dist(team.tile_pos, target)) / MOVE_TILES_PER_DAY   # ★perf cut1 A：static（免 per-candidate .new() alloc）
	var task: String = String(to_task.get("task", ""))
	# ★A1:founding(build_type)/facility 委派亦含 build 工期（雖不發 TASK_BUILD，仍派子隊施工）。
	if task == TeamData.TASK_BUILD or task == TeamData.TASK_SETTLE \
			or to_task.has("build_type") or to_task.has("facility"):
		# 代表性工期＝一級民用據點的 person-ticks，除以【這支隊自己的人力】（同一把尺）
		days += OutpostSystem.build_eta_days(
			int(OutpostSystem.BUILD_TICKS["civilian"][0]), team.population if team != null else 1)
	return days

# ★人格折現率 rate（WHAT §6「人格=折現率」，權重非 gate）：絕境→高(短視,遠 candidate 折趨零不走遠路)/
# 慎重耐心高→低(遠視肯投遠利)。純狀態零 randf。
static func _discount_rate(ctx: DecisionContext) -> float:
	var desperation: float = clampf(1.0 - ctx.food_days / DecisionTerms.DESPERATION_DAYS, 0.0, 1.0)   # food→0→1(絕境)
	var caution: float = float(ctx.leader_values.get("慎重", 0.5))   # 遠視(rate 降;極慎重=純遠視 rate→0)
	return maxf(DISCOUNT_BASE * (desperation + 1.0 - caution), 0.0)   # 中性有 baseline 折現;絕境高;極慎重趨 0

# ★must-fix① util 護欄（HOW §8，reviewer S2/S6 回歸點）+ S6 折現：
# util = payoff × dev_coeff(絕境→0) × discount(delay,人格 rate)，clamp<survival。★折現乘法(≤1)只變小非變大→護欄不破。
static func _candidate_util(payoff: float, ctx: DecisionContext, delay_days: float = 0.0) -> float:
	# dev_urgency_coeff：鏡射 consistency_coeff 對「發展/遠層」壓制——food_days→0（絕境）→ 0（遠慾望歸零讓 survival 奪 argmax）。
	var dev_coeff: float = clampf(ctx.food_days / DecisionTerms.DESPERATION_DAYS, 0.0, 1.0)
	# ★S6 折現:discount=1/(1+rate×delay)（delay=0→1 近/即時不折;delay 大+絕境 rate 高→趨零不走遠路）。遞減有界。
	var discount: float = 1.0 / (1.0 + _discount_rate(ctx) * maxf(delay_days, 0.0))
	# clamp 上界 GOAL_UTIL_CAP < SURVIVAL_BOOST_MAX：硬保證 < 絕境 survival-boosted static util（折現只讓 util 更小=護欄更穩）。
	return clampf(payoff * dev_coeff * discount, 0.0, GOAL_UTIL_CAP)
