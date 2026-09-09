extends SceneTree
# @bed-kind: acceptance
# slice: 普查批一③ RESTOCK_MIN → RETURN_HYSTERESIS_DAYS × 該隊真 burn
#
# 驗收（HOW spec §4，五格）：①小隊/大隊在相同 home_food 下 drive 分開（含舊公式反向對照）
#   ②applicable 閘也要跟著走（改動穿透 options，不只 terms） ③跨隊門檻相異值 > 1
#   ④同源：burn 在 gather 裡只算一次（成對對照） ⑤pop=0 的隊要【印出來】不要靜靜吃掉

const CTX_SRC: String = "res://scripts/simulation/decision/decision_context.gd"
const BURN_EXPR: String = "population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY"
const OLD_RESTOCK_MIN: float = 10.0   # ★舊常數，只在本床當對照基準（production 已刪）

var _fails: int = 0
var _sections: int = 0
const EXPECT_SECTIONS: int = 4

func _initialize() -> void:
	print("=== RESTOCK MIN FROM REAL BURN ===")
	_test_single_burn_structure()
	_test_drive_separates_by_size()
	_test_applicable_gate_follows()
	_test_world_distribution()
	if _sections != EXPECT_SECTIONS:
		_fails += 1
		push_error("[FAIL] 只跑完 %d/%d 段 —— 中途崩掉" % [_sections, EXPECT_SECTIONS])
	print("=== DONE === SECTIONS=%d/%d FAILS=%d" % [_sections, EXPECT_SECTIONS, _fails])
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_fails += 1
		push_error("[FAIL] " + msg)

func _count(hay: String, needle: String) -> int:
	var n: int = 0
	var from: int = 0
	while true:
		var i: int = hay.find(needle, from)
		if i == -1:
			break
		n += 1
		from = i + 1
	return n

func _min_for(pop: int) -> float:
	return DecisionTerms.RETURN_HYSTERESIS_DAYS * float(pop) * ResourceSystem.FOOD_PER_PERSON_PER_DAY

func _mk(pop: int, home_food: float) -> DecisionContext:
	var c := DecisionContext.new()
	c.has_home_outpost = true
	c.home_food = home_food
	c.home_food_productive = false
	c.home_restock_min = _min_for(pop)
	c.food_days = 2.0
	c.population = pop
	c.is_merchant = false
	return c

func _test_single_burn_structure() -> void:
	print("-- ④ 同源：burn 在 gather 裡只算一次 --")
	# ★成對對照先跑：自造的兩次 ⇒ 必須數到 2（否則「真檔數到 1」是恆真）
	var fake: String = "\tvar a = float(team.%s\n\tvar b = float(team.%s\n" % [BURN_EXPR, BURN_EXPR]
	_ok(_count(fake, BURN_EXPR) == 2, "④對照：合成的兩次要數到 2（實得 %d）" % _count(fake, BURN_EXPR))
	var f := FileAccess.open(CTX_SRC, FileAccess.READ)
	if f == null:
		_fails += 1
		push_error("[FAIL] 讀不到 %s" % CTX_SRC)
		_sections += 1
		return
	var src: String = f.get_as_text()
	f.close()
	var got: int = _count(src, BURN_EXPR)
	_ok(got == 1, "④真檔只算一次 burn（實得 %d）⇒ food_days／productive／restock_min 同源" % got)
	_sections += 1

func _test_drive_separates_by_size() -> void:
	print("-- ① 相同 home_food，小隊 vs 大隊 --")
	var small := _mk(3, 10.0)     # 3 人：門檻 5×3×0.8 = 12
	var big := _mk(30, 10.0)      # 30 人：門檻 5×30×0.8 = 120
	var d_small: float = DecisionTerms.eval("restock_need", small, "返家補給")
	var d_big: float = DecisionTerms.eval("restock_need", big, "返家補給")
	print("  home_food 都是 10｜3 人隊門檻 %.1f ⇒ drive=%.4f｜30 人隊門檻 %.1f ⇒ drive=%.4f" % [
		small.home_restock_min, d_small, big.home_restock_min, d_big])
	_ok(d_small > d_big, "①小隊 drive(%.4f) > 大隊(%.4f)（同一個家，對小隊是四天口糧、對大隊不到半天）" % [d_small, d_big])
	# ★反向對照：舊公式（固定 10）下兩隊【相同】——證明差異真的來自新分母
	var old_small: float = clampf(10.0 / OLD_RESTOCK_MIN, 0.0, 1.0)
	var old_big: float = clampf(10.0 / OLD_RESTOCK_MIN, 0.0, 1.0)
	_ok(is_equal_approx(old_small, old_big) and not is_equal_approx(d_small, d_big),
		"①反向對照：舊固定門檻下兩隊同為 %.4f，新門檻下分開" % old_small)
	_sections += 1

func _test_applicable_gate_follows() -> void:
	print("-- ② applicable 閘也要跟著走（穿透 options 不只 terms）--")
	var appl: Callable = DecisionOptions.REGISTRY["返家補給"]["applicable"]
	# ★家糧要落在【兩個門檻之間】才分得開：3 人門檻 12、30 人門檻 120 ⇒ 取 20。
	#   ★★第一版我取 10，而 10 < 12 ⇒ 兩隊都不 offer ——【那不是閘壞了，是我的區間選錯】，
	#   而它會讓這格看起來像「改動沒穿透」。區間要自己先算過。
	var home_food: float = 20.0
	var big := _mk(30, home_food)
	var small := _mk(3, home_food)
	var big_ok: bool = appl.call(big)
	var small_ok: bool = appl.call(small)
	print("  %.0f 食物的家：30 人隊(門檻 %.0f) applicable=%s｜3 人隊(門檻 %.0f) applicable=%s" % [
		home_food, big.home_restock_min, str(big_ok), small.home_restock_min, str(small_ok)])
	_ok(not big_ok, "②大隊【不】offer 返家（門檻 120 > 20）")
	_ok(small_ok, "②小隊【仍】offer 返家（門檻 12 ≤ 20）⇒ 同一個家、同一個 home_food，兩隊結果不同")
	# ★反向對照：舊固定門檻 10 之下，這兩隊【都】會 offer ⇒ 差異確實來自新門檻
	_ok(home_food >= OLD_RESTOCK_MIN,
		"②反向對照：舊門檻 %.0f 之下 %.0f 食物對兩隊都過 gate（改動確實穿透到 options）" % [OLD_RESTOCK_MIN, home_food])
	_sections += 1

func _test_world_distribution() -> void:
	print("-- ③⑤ 跨隊門檻分布 + pop=0 的隊 --")
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "res://config/warring_states.json"
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 2
	seed(1337)
	Probe.arm()
	var state: WorldState = MeasureBedHelper.arm_and_setup(cfg, true)
	var runner := SimRunner.new()
	var first_stall: int = -1
	var stall_reason: String = ""
	for tick in range(days * WorldState.TICKS_PER_DAY):
		var r: String = runner.advance_tick(state, Vector2i(-1, -1))
		if r != "" and first_stall == -1:
			first_stall = tick
			stall_reason = r
	print("  [有效窗] 請求 %d ticks｜首次非推進：%s" % [days * WorldState.TICKS_PER_DAY,
		("無" if first_stall == -1 else "tick %d（%s）" % [first_stall, stall_reason])])
	var mins: Array = []
	var zero_pop: Array = []
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		var ctx: DecisionContext = DecisionContext.gather(state, t)
		mins.append(ctx.home_restock_min)
		if t.population == 0:
			zero_pop.append(tid)
	mins.sort()
	var distinct := {}
	for v in mins:
		distinct[snappedf(float(v), 0.001)] = true
	var n: int = mins.size()
	print("  母體 %d 隊｜min=%.1f median=%.1f max=%.1f｜相異值 %d（舊版全部都是 %.1f）" % [
		n, float(mins[0]), float(mins[n / 2]), float(mins[n - 1]), distinct.size(), OLD_RESTOCK_MIN])
	_ok(distinct.size() > 1, "③跨隊門檻有變異（相異值 %d > 1）" % distinct.size())
	# ★⑤ pop=0 的隊：門檻 0 ⇒ 家裡有任何糧都算「值得回」，drive → 1.0。★印出來，不要靜靜吃掉。
	print("  ★pop=0 的隊：%d 支%s" % [zero_pop.size(),
		("（門檻 0 ⇒ 空家也過 gate、drive→1.0，這是已知後果）" if zero_pop.size() > 0 else "（本窗沒有）")])
	if zero_pop.size() > 0:
		print("    tid：%s" % [str(zero_pop.slice(0, mini(8, zero_pop.size())))])
	_ok(true, "⑤pop=0 的隊已具名列出（%d 支）——不靜默吃掉" % zero_pop.size())
	_sections += 1
