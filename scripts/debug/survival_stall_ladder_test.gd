extends SceneTree

# ② 絕境階梯失敗回饋 TDD（spec 2026-07-18-desperation-ladder-failure-feedback v2）。
# 根:SURVIVAL_BOOST 集體等量 order-preserving→卡格 latch(QA 7隊33+天不換序)。
# 修:committed option stall 偵測(relief before/after,禁瞬時)→硬排除 cooldown 換次格(reject_cooldown idiom)+單一 option 豁免。
# 人格用既有 慎重/求生欲(禁虛構 trait)。純 helper 直測。

var _fail: int = 0

func _initialize() -> void:
	_test_stall_verdict()
	_test_patience_factor()
	_test_applicable_exclusion_and_exemption()
	if _fail == 0:
		print("=== DONE === ALL PASS")
	else:
		print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  [PASS] %s" % msg)
	else:
		_fail += 1
		print("  [FAIL] %s" % msg)

# ── S1 stall 判定：before/after relief-magnitude（非瞬時、非比昨日）──
func _test_stall_verdict() -> void:
	print("--- stall_verdict: WAITING/RESOLVING/STALLED ---")
	var stall_ticks := 800   # 判定窗
	var relief_min := 1.0
	# 未到判定窗 → WAITING（不論 relief）
	_ok(DecisionEngine.stall_verdict(0, 2.0, 500, 0.5, stall_ticks, relief_min) == DecisionEngine.STALL_WAITING,
		"tick 差 < stall_ticks → WAITING（不早判）")
	# 到窗 + relief ≥ min（food 從 2.0→3.5，Δ=1.5≥1）→ RESOLVING（X 起作用留它）
	_ok(DecisionEngine.stall_verdict(0, 2.0, 900, 3.5, stall_ticks, relief_min) == DecisionEngine.STALL_RESOLVING,
		"到窗 + relief 足(Δ1.5≥1) → RESOLVING")
	# 到窗 + relief < min（food 2.0→2.3，Δ=0.3<1）→ STALLED（升級）
	_ok(DecisionEngine.stall_verdict(0, 2.0, 900, 2.3, stall_ticks, relief_min) == DecisionEngine.STALL_STALLED,
		"到窗 + relief 不足(Δ0.3<1) → STALLED")
	# 慢產 plateau（food 幾乎不動 2.0→2.0，Δ=0）→ STALLED（flatline 判 stall，非 resolved）
	_ok(DecisionEngine.stall_verdict(0, 2.0, 900, 2.0, stall_ticks, relief_min) == DecisionEngine.STALL_STALLED,
		"plateau Δ0 → STALLED（慢產不足非 resolved）")
	# 比 baseline 非比昨日：food 更低（2.0→1.0，惡化）→ 仍 STALLED（不因「沒更低」誤判，本就比 baseline）
	_ok(DecisionEngine.stall_verdict(0, 2.0, 900, 1.0, stall_ticks, relief_min) == DecisionEngine.STALL_STALLED,
		"food 比 baseline 更低 → STALLED（比 baseline 判準）")

# ── S1 人格：patience_factor 用既有 慎重/求生欲（禁虛構堅忍）──
func _test_patience_factor() -> void:
	print("--- patience_factor: 慎重↑撐久 / 求生欲↑急換（既有 trait）---")
	var neutral := DecisionEngine.stall_patience_factor({"慎重": 0.5, "求生欲": 0.5})
	var cautious := DecisionEngine.stall_patience_factor({"慎重": 0.9, "求生欲": 0.5})
	var reckless := DecisionEngine.stall_patience_factor({"慎重": 0.1, "求生欲": 0.5})
	_ok(cautious > neutral and neutral > reckless, "慎重↑ → patience↑（撐久才換）：%.2f > %.2f > %.2f" % [cautious, neutral, reckless])
	var calm := DecisionEngine.stall_patience_factor({"慎重": 0.5, "求生欲": 0.1})
	var desperate := DecisionEngine.stall_patience_factor({"慎重": 0.5, "求生欲": 0.9})
	_ok(calm > desperate, "求生欲↑ → patience↓（急著換格）：%.2f > %.2f" % [calm, desperate])
	# 無虛構 trait：只讀 慎重/求生欲，缺 key → default 0.5 不崩
	_ok(DecisionEngine.stall_patience_factor({}) > 0.0, "空 values → default 不崩（無虛構堅忍 key）")

# ── EXCLUDE + design-5 單一 option 豁免：★單一源在 applicable()（全 rank 路共用 unified/solo/subteam/survival）──
func _test_applicable_exclusion_and_exemption() -> void:
	print("--- applicable() EXCLUDE + 單一 option 豁免（單一源，含 rank_scored 路）---")
	# 前提：覓食(population≤FORAGE+has_forage_tile) + 乞食(food<DESPERATION+has_aid_target) 皆 applicable
	var c := DecisionContext.new()
	c.population = 5
	c.has_forage_tile = true
	c.food_days = 1.0
	c.has_aid_target = true
	c.leader_values = {}
	var base := DecisionOptions.applicable(c)
	_ok("覓食" in base and "乞食" in base, "前提：覓食+乞食 皆 applicable")
	# EXCLUDE：覓食 stalled + 有次格(乞食) → 排除覓食、留乞食（換格 progression）
	c.survival_stall_active = ["覓食"]
	var ex := DecisionOptions.applicable(c)
	_ok(not ("覓食" in ex) and "乞食" in ex, "覓食 stalled + 有次格 → 排除覓食留乞食（換格）")
	# ★design-5 豁免（單一源 rank_scored 也套）：覓食 唯一 survival(乞食 gate off) + stalled → ride 覓食（不排空 idle-starve）
	var c2 := DecisionContext.new()
	c2.population = 5
	c2.has_forage_tile = true
	c2.has_aid_target = false   # 乞食 off → 覓食 唯一 applicable survival
	c2.leader_values = {}
	c2.survival_stall_active = ["覓食"]
	var exempt := DecisionOptions.applicable(c2)
	_ok("覓食" in exempt, "唯一 survival(覓食) stalled → 豁免 ride（solo/unified 不 idle-starve）")
