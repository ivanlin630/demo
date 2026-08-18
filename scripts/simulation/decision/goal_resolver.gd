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
	var frontier_memo: Dictionary = {}   # ★perf cut1 B：call-scoped terrain-tile memo（team.tile_pos 當下固定、同 terrain 多 goal 免重掃全圖）；返回即棄禁跨 tick
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
				cand = _resolve_resource_prereq(state, team, ctx, g, gt, payoff, prereq, frontier_memo)   # S2 買 + S3 採@地形
			elif kind == GoalRegistry.PREREQ_LOCATION:
				cand = _resolve_location_prereq(state, team, ctx, g, gt, payoff, prereq, frontier_memo)   # S3 定位型
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
# ★資源→採集地形（material←forest 核心缺口鏈，arc 原始動機）。S3 只 material；他 res 採集地形=後續。
const RES_HARVEST_TERRAIN: Dictionary = {"material": "forest"}

static func _resolve_resource_prereq(state: WorldState, team: TeamData, ctx: DecisionContext,
		g: Dictionary, gt: String, payoff: float, prereq: Dictionary, memo: Dictionary = {}) -> Dictionary:
	var res: String = String(prereq.get("res", ""))
	var lv: Dictionary = TradeValuation.leader_vals(state, team)
	# 組件 E 泛化：qty 走通用 need_keep（任 res）。
	if ResourceSystem.effective_holding(state, team, res) >= NeedOracle.need_keep(state, team, res, lv):
		return {}   # 前置滿
	# ── 取得手段 1：買（S2，市場取得不需定位；belief-gated）──
	if ctx.has_specie:
		var mp: Vector2i = FactionAISystem.new()._nearest_market_outpost_with(state, team, res)
		if mp != Vector2i(-1, -1):
			return _mk_candidate(team, g, gt, GoalRegistry.PREREQ_RESOURCE, payoff, ctx, {"task": TeamData.TASK_TRADE, "target": mp})
	# ── 取得手段 2：採@地形（S3，買不到→定位取得）★material 缺口鏈：需該地形 outpost 採。
	# ★湧現閉環：缺料→(a)移動到 forest→(b)到了建 outpost→own.terrain==forest→採 satisfied。
	if RES_HARVEST_TERRAIN.has(res):
		var terrain: String = String(RES_HARVEST_TERRAIN[res])
		var own: Vector2i = FactionAISystem.new()._find_own_outpost(state, team)
		var own_tile: HexTileData = state.world.tiles.get(own.x * 1000 + own.y) if own != Vector2i(-1, -1) else null
		if own_tile != null and own_tile.terrain == terrain:
			return {}   # ★閉環完成:已有該地形 outpost → 採 satisfied（既有 harvest 供給）
		# ★A1 founding：缺料+無該地形 outpost → 派子隊到最近該地形 tile 建 civilian outpost（複用 _dispatch_builder consumer）。
		# 移除舊 in-place TASK_BUILD + TASK_MIGRATE frontier（TASK_BUILD 無 consumer=死路;founding 本質派子隊,合 WHAT §4）。
		var pos: Vector2i = find_nearest_terrain_tile(state, team, terrain, SEEK_TILE_RANGE, memo)   # 純地形=公共地理（★cut1 B call-scoped memo）
		# ★A1 裁③：remote forest founding（異格）→ 派子隊（子隊真移動→抵達→建，正常）。
		# ★裁② guard：pos == team.tile_pos（隊已站該地形）= same-tile founding，無母隊就地 outpost-build 路 → 靜默（followup）。
		if pos != Vector2i(-1, -1) and pos != team.tile_pos:
			return _mk_delegate_candidate(team, g, gt, GoalRegistry.PREREQ_LOCATION, payoff, ctx,
				{"build_type": "civilian", "target": pos})
	return {}   # S3 無取得手段（產=S4 設施 / same-tile founding=followup）

# ★S3 定位型前置 handler（組件 C）：{kind:location, terrain, control?}。查隊在/有滿足 tile，未滿→tile frontier candidate。
static func _resolve_location_prereq(state: WorldState, team: TeamData, ctx: DecisionContext,
		g: Dictionary, gt: String, payoff: float, prereq: Dictionary, memo: Dictionary = {}) -> Dictionary:
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
		pos = find_nearest_terrain_tile(state, team, terrain, SEEK_TILE_RANGE, memo)   # ★cut1 B call-scoped memo
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
static func find_nearest_terrain_tile(state: WorldState, team: TeamData, terrain: String, max_range: int, memo: Dictionary = {}) -> Vector2i:
	# ★perf cut1 B：call-scoped memo（frontier_candidates 傳入 local Dict、team.tile_pos 當下固定→同 team 多 goal
	#   查同 (terrain,max_range) 全圖只掃 1 次、後續命中）。byte-identical by construction（deterministic 同輸出）。
	#   ★嚴格 call-scoped⊂tick：memo 為 frontier local、返回即棄、禁跨 tick cache。default {} → 無 memo 獨立呼點照原掃。
	var mkey: String = terrain + ":" + str(max_range)
	if memo.has(mkey):
		return memo[mkey]
	var best: Vector2i = Vector2i(-1, -1)
	var best_d: int = 1 << 30
	var best_id: int = 1 << 30
	for tid in state.world.tiles:   # gate-ok: 地理=公共知識（terrain 靜態物理地理非動態所有權，比照 constitution_gate:41 市集地理先例）
		var t: HexTileData = state.world.tiles[tid]
		if t == null or (terrain != "" and t.terrain != terrain):
			continue
		var d: int = FactionAISystem._hex_dist(team.tile_pos, t.tile_pos)   # ★perf cut1 A：static（免 fai alloc）
		if d > max_range:
			continue   # belief-reachable bounded（非全知 PathSystem）
		if d < best_d or (d == best_d and int(tid) < best_id):
			best_d = d; best_id = int(tid); best = t.tile_pos
	memo[mkey] = best
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
const BUILD_DAYS_EST: float = 3.0       # TEST VALUE — build/settle 工期估（淺啟發，非讀細 BUILD_TICKS）
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
		days += BUILD_DAYS_EST
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
