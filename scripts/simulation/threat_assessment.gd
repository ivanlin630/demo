class_name ThreatAssessment

# 威脅評估（static 純函數）：限視野 + reputation + intel 估算實力 + 朝我移動 + 距離衰減。
# 認知不等於真實：對方實力用觀察者 team_intel snapshot 估算，非全知。

# ★★★門檻 re-baseline（systems spec 2026-09-02，技能維對稱化的同一刀）：
#   ★舊值 0.3 是在【膨脹的尺】上定的 —— 那把尺把每一個 threat_react 都拉高了，
#     所以 0.3 這個數字本身已經把膨脹吃進去了。尺改回中性之後，門檻必須跟著除。
#   ★★而【改法必須是同源推導】（systems 明令）：除以【實測出來的膨脹係數】，
#     ★★★不是重新手感選一個數字 —— 那等於把手抄物理從 0.3 搬到 threshold 上藏起來。
#
# ★膨脹係數的來歷（兩條腱【獨立】量到同一個數，12 日 seed1337）：
#   warring ：mean(threat_react) 2.9945 → 0.6914  ⇒ 2.9945 / 0.6914 = 4.331
#   peaceful：mean(threat_react) 0.2567 → 0.0593  ⇒ 0.2567 / 0.0593 = 4.329
#   ★★兩個世界、兩個完全不同的母體，算出來差到小數第三位 ⇒ 這不是巧合，
#   ★★★而是【膨脹本來就是一個全域常數倍率】（舊尺：other 固定 0.3／self 實測 0.1）。
const THREAT_INFLATION_MEASURED: float = 4.33   # ★實測值，非手感；來源見上方兩行
# ★★舊值 0.3 保留在式子裡（而不是直接寫 0.0693）：★★★讓下一個人看得到它的血統 ——
#   寫成 0.0693 的話，三個月後沒人知道它是怎麼來的，而那就是下一代的手抄物理。
const THREAT_BASE_THRESHOLD: float = 0.3 / THREAT_INFLATION_MEASURED
const REPUTATION_NEUTRAL: float = 0.5
const POWER_BASELINE: float = 1.0

static func score(state: WorldState, self_team: TeamData,
		other: TeamData) -> float:
	if not state.team_discovered.get(self_team.team_id, []).has(other.team_id):
		return 0.0
	var approach: float = _approach_score(state, self_team, other)
	var rep: float = float(self_team.known_reputations.get(other.team_id,
		REPUTATION_NEUTRAL))
	var hostility: float = clampf(1.0 - rep, 0.0, 1.0)
	var power_ratio: float = _power_ratio(state, self_team, other)
	var raw: float = approach * 1.0 + hostility * 1.0 + (power_ratio - 1.0) * 0.5
	# ★Slice D fold（dist_factor 乘算主導 god-view）：dist 走 belief（position）——本 tick 可見→live 距、
	# 斷視線→belief last-seen 位算距、positionless/過期→dist_factor=0（威脅位置未知=無法算 proximity 威脅→不
	# proximate-threat；合 null-belief-flee「威脅無座標→不 flee」+ 既有「dist≥5 逃出生天→0」）。∴ 威脅評估全 belief。
	var other_pos: Vector2i = other.tile_pos
	if int(BeliefSystem.best_estimate(state, self_team.team_id, other.team_id).get("last_tick", -1)) != state.world.current_tick:
		other_pos = BeliefSystem.belief_pos(state, self_team.team_id, other.team_id)
		if other_pos == Vector2i(-1, -1):
			return 0.0   # positionless 威脅 → dist_factor 0 → 威脅分 0
	var dist: int = _hex_dist(self_team.tile_pos, other_pos)
	# 距離脫離：dist≥5 → factor 0（逃出生天）。原 floor 0.1 → 遠敵永遠算威脅 → 逃跑永不釋放
	var dist_factor: float = clampf(1.0 - float(dist) / 5.0, 0.0, 1.0)
	# ★★★備戰 root-check tap（純觀測，systems／藍圖 2026-09-02）：
	#   ★四份獨立量測、四個不同的病、同一個贏家（備戰）⇒ 先問它的 util 是不是被高估。
	#   ★★而【逐項組成】才分得出高估在哪一項 —— 只看總分的話，
	#     approach 高、hostility 高、power 高、門檻低 四種在輸出上長得一模一樣。
	#   ★★★hostility 的【底】在這裡特別要看：`REPUTATION_NEUTRAL = 0.5` ⇒
	#     一個【什麼也沒做過的陌生隊】hostility 恆為 0.5，而門檻是 0.3+慎重*0.3。
	if Probe.enabled:
		Probe.bump("threat.score_n")
		Probe.add_amount("threat.comp.approach", approach)
		Probe.add_amount("threat.comp.hostility", hostility)
		Probe.add_amount("threat.comp.power_term", (power_ratio - 1.0) * 0.5)
		Probe.add_amount("threat.comp.dist_factor", dist_factor)
		Probe.add_amount("threat.comp.final", maxf(raw * dist_factor, 0.0))
		# ★【沒有任何敌意行為】的那一群：名聲未知（吻合 NEUTRAL）且 approach<=0
		#   ⇒ ★★它們的分數完全來自【陌生人底分】，而這一格是本查的核心候選。
		if is_equal_approx(rep, REPUTATION_NEUTRAL) and approach <= 0.0:
			Probe.bump("threat.stranger_only_n")
			Probe.add_amount("threat.stranger_only_score", maxf(raw * dist_factor, 0.0))
	return maxf(raw * dist_factor, 0.0)

static func _approach_score(state: WorldState, self_team: TeamData,
		other: TeamData) -> float:
	var obs: Dictionary = PathSystem.observe_velocity(state, self_team, other)
	if not obs.get("visible", false): return 0.0
	var dir: Vector2i = obs.get("direction", Vector2i.ZERO)
	if dir == Vector2i.ZERO: return 0.0
	var current_dist: int = _hex_dist(self_team.tile_pos, other.tile_pos)
	var future_pos: Vector2i = other.tile_pos + dir
	var future_dist: int = _hex_dist(self_team.tile_pos, future_pos)
	if current_dist == future_dist: return 0.0
	return clampf(float(current_dist - future_dist), -1.0, 1.0)

static func _power_ratio(state: WorldState, self_team: TeamData,
		other: TeamData) -> float:
	var self_power: float = _team_power(self_team)
	# 對方用 team_intel snapshot（NPC 不全知）
	var intel: Dictionary = BeliefSystem.best_estimate(state, self_team.team_id, other.team_id)
	# ★god-view fix（`process/detail/invariants-cases.md::決策讀 belief 非真值` 的
	#   「無估 fallback ＝保守／不行動，非偷讀真值」那一條）：無 belief fallback 用 self_pop（視對方等強），禁讀 other.population
	#   ★★舊引用寫 `invariants.md:171-173` —— 行號已腐（現在那幾行是別的內容），
	#   ★★★改成 檔::節名（行號跟編輯走、節名跟語意走）。
	# （真值=god-view，破虛張/偽裝）。鏡射 diplomatic _get_pop_est fallback=self_pop 模式。
	var pop_est: int = int(intel.get("population_est", self_team.population))
	# ★★★技能維對稱化（systems spec 2026-09-02，R② 過）：
	#   ★舊寫法：self 用【真實 avg_combat_skill】、other 用【手抄常數 0.3】
	#     ⇒ 兩邊不是同一把尺；而實測全世界 `avg_combat_skill` 都是 0.1
	#     ⇒ ★★每一隊看每一隊都自動 ×3（peaceful 量到 ratio 平均 2.997 ≈ 0.3/0.1，
	#        而同窗 pop_est 5.99 vs self_pop 6.00 —— 人口那一維已經是中性的）。
	#   ★★belief 根本沒有【技能】這個通道（claims 只帶 `population_est`）
	#     ⇒ 技能維【一律】走 fallback ⇒ 照上面那條已核可的通則，以【自己】為先驗。
	#   ★★★這不是新的 WHAT，是【同一條 invariant 的第二次應用】：
	#     人口維已經這樣做（`pop_est` 的 fallback 就是 `self_team.population`）。
	#   ★而【禁把 0.3 改成 0.1】（藍圖明令）—— 那只是把手抄物理換一個數字，
	#     三個月後平均技能一變它又歪了；★★接線才不會。
	var skill_est: float = AnonTierSystem.avg_combat_skill(self_team)
	var other_power: float = float(pop_est) * skill_est
	# ★★★備戰 root-check 第二層 tap（純觀測）：★量到 power 項平均 3.64（warring）之後，
	#   要分得出【是 pop_est 高】還是【self_power 低】—— ★★兩者在比值上長得一模一樣。
	#   ★★★而那個不對稱已經修掉（2026-09-02）⇒ 這組 tap 現在的用途是【驗證修後真的中性】。
	if Probe.enabled:
		Probe.bump("threat.pr_n")
		Probe.add_amount("threat.pr.self_pop", float(self_team.population))
		Probe.add_amount("threat.pr.self_combat", AnonTierSystem.avg_combat_skill(self_team))
		Probe.add_amount("threat.pr.self_power", self_power)
		Probe.add_amount("threat.pr.pop_est", float(pop_est))
		Probe.add_amount("threat.pr.other_power", other_power)
		Probe.add_amount("threat.pr.ratio", other_power / maxf(self_power, 0.1))
		# ★★★分佈（systems 驗收④）：平均 2.997 【乾淨得可疑】—— 平均看不出【集中在單一值】。
		#   ★若修後仍然死守在一個值上 ⇒ ★★還有別的常數在主導，而平均學不出來。
		var _r: float = other_power / maxf(self_power, 0.1)
		var _rb: String = "ge3"
		if _r < 0.5: _rb = "lt0.5"
		elif _r < 0.9: _rb = "0.5to0.9"
		elif _r < 1.1: _rb = "0.9to1.1"      # ★中性帶（修後應該大量落在這裡）
		elif _r < 2.0: _rb = "1.1to2"
		elif _r < 3.0: _rb = "2to3"
		Probe.bump("threat.pr.hist." + _rb)
		# ★fallback（沒有 belief）占多少 —— ★★它決定了上面那個不對稱有多常發生。
		Probe.bump("threat.pr.no_belief" if not intel.has("population_est") else "threat.pr.has_belief")
		# ★★★self 比 0.3 弱的那一群：他們就算面對【同人數的陌生人】也會算出 ratio > 1
		if AnonTierSystem.avg_combat_skill(self_team) < 0.3:
			Probe.bump("threat.pr.self_weaker_than_baseline")
	return other_power / maxf(self_power, 0.1)

static func _team_power(team: TeamData) -> float:
	var combat: float = AnonTierSystem.avg_combat_skill(team)
	return float(team.population) * combat

static func _hex_dist(a: Vector2i, b: Vector2i) -> int:
	var dx: int = b.x - a.x; var dy: int = b.y - a.y
	return (abs(dx) + abs(dx + dy) + abs(dy)) / 2
