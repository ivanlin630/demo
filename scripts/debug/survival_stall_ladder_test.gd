extends SceneTree

# ② 絕境階梯失敗回饋 TDD（spec 2026-07-18-desperation-ladder-failure-feedback v2）。
# 根:SURVIVAL_BOOST 集體等量 order-preserving→卡格 latch(QA 7隊33+天不換序)。
# 修:committed option stall 偵測(relief before/after,禁瞬時)→硬排除 cooldown 換次格(reject_cooldown idiom)+單一 option 豁免。
# 人格用既有 慎重/求生欲(禁虛構 trait)。純 helper 直測。

var _fail: int = 0

func _initialize() -> void:
	_test_stall_verdict()
	_test_patience_factor()
	_test_stall_exclusion()
	_test_applicable_single_source()
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

# ── S2 硬排除 + 單一 option 豁免 ──
func _test_stall_exclusion() -> void:
	print("--- apply_stall_exclusion: 排除 cooldown 內 + 單一 option 豁免 ---")
	var tick := 1000
	# 有次格：X cooldown 內、Y 無 → 排除 X 留 Y
	var r1 := DecisionEngine.apply_stall_exclusion(["掠奪", "乞食"], {"掠奪": 1500}, tick)
	_ok(r1 == ["乞食"], "X(掠奪)cooldown 內 + 有次格(乞食) → 排除 X 換格：%s" % str(r1))
	# 單一 option 豁免：只有 X 且 cooldown 內 → 不排除（ride 窮死非 idle-churn）
	var r2 := DecisionEngine.apply_stall_exclusion(["掠奪"], {"掠奪": 1500}, tick)
	_ok(r2 == ["掠奪"], "唯一格 X cooldown 內 → 豁免不排除(ride)：%s" % str(r2))
	# 全 stall 豁免：X,Y 皆 cooldown 內 → 無次格 → 全留（ride，非清空 idle）
	var r3 := DecisionEngine.apply_stall_exclusion(["掠奪", "乞食"], {"掠奪": 1500, "乞食": 1500}, tick)
	_ok(r3 == ["掠奪", "乞食"], "全格 cooldown 內 → 豁免全留(ride 非清空)：%s" % str(r3))
	# cooldown 過期 → 不排除（window expiry）
	var r4 := DecisionEngine.apply_stall_exclusion(["掠奪", "乞食"], {"掠奪": 900}, tick)
	_ok(r4 == ["掠奪", "乞食"], "cooldown 過期(900<1000) → 不排除：%s" % str(r4))
	# 無 cooldown → 原封
	var r5 := DecisionEngine.apply_stall_exclusion(["掠奪", "乞食", "併入"], {}, tick)
	_ok(r5 == ["掠奪", "乞食", "併入"], "無 cooldown → 原封：%s" % str(r5))

# ── EXCLUDE 單一源在 applicable()（全 rank 路共用：unified/solo/subteam 走 rank_scored 自動排除）──
func _test_applicable_single_source() -> void:
	print("--- applicable() 單一源排除 stall survival option（ignore_stall 豁免旗）---")
	# 構 ctx 讓 覓食 applicable（population≤FORAGE_VIABLE_POP + has_forage_tile）
	var c := DecisionContext.new()
	c.population = 5
	c.has_forage_tile = true
	c.leader_values = {}
	var base := DecisionOptions.applicable(c)
	_ok("覓食" in base, "無 stall → 覓食 applicable（前提正確）")
	# survival_stall_active=["覓食"] → 預設排除（unified/solo rank_scored 走此，換次格）
	c.survival_stall_active = ["覓食"]
	var excluded := DecisionOptions.applicable(c)
	_ok(not ("覓食" in excluded), "覓食 in stall_active → applicable() 排除（EXCLUDE 單一源）")
	# ignore_stall=true → 豁免回全（rank_survival 單一 option ride 用）
	var raw := DecisionOptions.applicable(c, true)
	_ok("覓食" in raw, "ignore_stall=true → 覓食 回候選（rank_survival ride 豁免用）")
