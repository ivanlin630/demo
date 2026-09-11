extends SceneTree
# @bed-kind: acceptance
# slice: 攻擊的【機會＋需要】項（HOW spec 2026-09-12-attack-opportunity-drive）
#
# ★母體與「一趟」的定義：
#   ·§A【成對對照】＝ **合成 ctx**（不跑世界）⇒ 方向性判準，零雜訊、零母體問題
#   ·§B【分布】＝ 一段短窗模擬裡**每一次攻擊 option 被評分**（`attack.util.*` 計數 ＋ 非零樣本）
# ★★而 §A 與 §B 是兩個母體：★★★方向性用合成、佔比與分布用世界 —— 不混。
# env：AO_TICKS（預設 4320 ＝ 3 天；★機器吃緊時縮窗，數字照樣可判方向）／AO_SEED（1337）

var _fails: int = 0

func _initialize() -> void:
	_run(); quit(0 if _fails == 0 else 1)

func _ok(c: bool, m: String) -> void:
	if c: print("  [OK] %s" % m)
	else:
		_fails += 1
		push_error("[FAIL] %s" % m)

func _mk(loot: float, food_days: float, odds: float, vals: Dictionary) -> DecisionContext:
	var c := DecisionContext.new()
	c.attack_target_id = 7          # ★門已開（本票不動門）
	c.attack_loot_est = loot
	c.attack_win_odds = odds
	c.food_days = food_days
	c.desperation_entry_threshold = DecisionTerms.DESPERATION_DAYS
	c.leader_values = vals
	return c

func _run() -> void:
	print("=== 攻擊【機會＋需要】驗收 ===")
	var neutral: Dictionary = {"好戰": 0.5, "貪婪": 0.5, "慎重": 0.5}
	# ── §A 成對對照（★兩格都要跑：只驗一邊證明不了秤在讀資產）──
	var fat: float = DecisionTerms.eval("attack_opportunity", _mk(3.0, 20.0, 1.0, neutral), "攻擊")
	var poor: float = DecisionTerms.eval("attack_opportunity", _mk(0.0, 20.0, 1.0, neutral), "攻擊")
	print("★§A 方向性：肥而弱 util=%.3f｜窮而弱 util=%.3f" % [fat, poor])
	_ok(fat > poor, "③-a **肥的目標分數高於窮的**（秤真的在讀 belief 資產）")
	_ok(poor >= 0.0 and poor < fat, "③-b 窮的目標分數**不為負且更低**（★不是把所有目標都推高）")
	# ★★而「餓」那一半也要成對：同樣窮的目標，餓的隊應該更想搶
	var hungry: float = DecisionTerms.eval("attack_opportunity", _mk(0.0, 1.0, 1.0, neutral), "攻擊")
	print("★§A 需要：窮目標＋自己餓 util=%.3f（vs 吃飽 %.3f）" % [hungry, poor])
	_ok(hungry > poor, "③-c **自己餓時分數更高**（需要那一半有接上）")
	# ★★★無牙 ⇒ 整項 0（★「打不贏就別打」是既有接地，不是新規矩）
	var toothless: float = DecisionTerms.eval("attack_opportunity", _mk(3.0, 1.0, 0.0, neutral), "攻擊")
	_ok(absf(toothless) < 0.0005, "③-d **無牙（贏率 0）⇒ 整項 0**（不是壓低，是 0）")
	# ★人格 MODULATE：好戰高 ⇒ 更高；慎重高 ⇒ 更低（★同一個【真值】被調製，不是加常數）
	var martial: float = DecisionTerms.eval("attack_opportunity", _mk(3.0, 20.0, 1.0,
		{"好戰": 0.9, "貪婪": 0.5, "慎重": 0.5}), "攻擊")
	var cautious: float = DecisionTerms.eval("attack_opportunity", _mk(3.0, 20.0, 1.0,
		{"好戰": 0.5, "貪婪": 0.5, "慎重": 0.9}), "攻擊")
	print("★人格：好戰 0.9 ⇒ %.3f｜中性 ⇒ %.3f｜慎重 0.9 ⇒ %.3f" % [martial, fat, cautious])
	_ok(martial > fat and cautious < fat, "★人格 MODULATE 真值（好戰↑／慎重↓），非 boost 常數")

	# ── §B 世界側：佔比與分布 ──
	var ticks: int = int(OS.get_environment("AO_TICKS")) if OS.has_environment("AO_TICKS") else 4320
	var seed_val: int = int(OS.get_environment("AO_SEED")) if OS.has_environment("AO_SEED") else 1337
	seed(seed_val)
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/warring_states.json")
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)
	for _t in range(ticks):
		runner.advance_tick(st, no_player)
	var z: int = int(Probe.counts.get("attack.cmp.zero_final", 0))
	var nz: int = int(Probe.counts.get("attack.cmp.nonzero_final", 0))
	print("")
	print("★①攻擊 util：零 %d／非零 %d（母體 %d ＝ 每一次攻擊被評分；窗 %d tick／seed %d）" % [
		z, nz, z + nz, ticks, seed_val])
	_ok(nz > 0, "①**非零不再是 0 次**（★病因是四項全授權 ⇒ 沒授權時恆 0）")
	# ②分布活著：非零值的變異不得為 0（★全部同一個數也叫非零，而那是另一個常數）
	var vals: Array = []
	for r in Probe.samples.get("attack.nonzero_util", []): vals.append(float(r["u"]))
	if vals.size() >= 2:
		var m: float = 0.0
		for v in vals: m += float(v)
		m /= float(vals.size())
		var varsum: float = 0.0
		for v in vals: varsum += (float(v) - m) * (float(v) - m)
		var sd: float = sqrt(varsum / float(vals.size()))
		print("★②非零 util 分布：n=%d mean=%.3f sd=%.3f min=%.3f max=%.3f" % [
			vals.size(), m, sd, vals.min(), vals.max()])
		_ok(sd > 0.0001, "②**分布活著（sd > 0）**★★『有非零值』不算過——全同一個數是另一個常數")
	else:
		print("★②非零樣本 %d 筆 ⇒ **不可判**（不是綠）" % vals.size())
	# ④授權群 vs 無授權群
	var ua_z: int = int(Probe.counts.get("attack.util.unauthed.zero", 0))
	var ua_nz: int = int(Probe.counts.get("attack.util.unauthed.nonzero", 0))
	var a_z: int = int(Probe.counts.get("attack.util.authed.zero", 0))
	var a_nz: int = int(Probe.counts.get("attack.util.authed.nonzero", 0))
	print("★④授權群 零%d／非零%d｜**無授權群 零%d／非零%d**" % [a_z, a_nz, ua_z, ua_nz])
	if ua_z + ua_nz == 0:
		print("   ★無授權群母體 0 ⇒ **不可判**（不是綠）")
	else:
		_ok(ua_nz > 0, "④**無授權群 util 不再全為 0**（★★否則『加成』偷偷變回『唯一來源』）")
	# ⑦tier 分桶（★觀察，不是目標；禁為了它好看而調權重）
	var t_row: Dictionary = {}
	for k in Probe.counts:
		var ks: String = String(k)
		if ks.begins_with("attack.util.tier") and ks.ends_with(".nonzero"):
			t_row[ks.replace("attack.util.", "").replace(".nonzero", "")] = int(Probe.counts[k])
	print("★⑦非零 util 的 belief tier 分桶：%s" % str(t_row))
	print("   ★這一格是【觀察】不是【目標】——★★不准為了讓它好看而調 tier 權重（禁 crank）")
	print("★fp = %s" % StateFingerprint.compute(st))
	print("=== DONE === SECTIONS=1/1 FAILS=%d" % _fails)
	print("[TEST-SUITE-COMPLETE]")
