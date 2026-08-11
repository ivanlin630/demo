extends SceneTree

# iii 絕境排序 TDD（spec 2026-08-11 HOW）：靶1 herald catastrophe-hedge + 靶2 defect consequence-pricing。
# 命門乙雙向 genuine 非 crank：hedge bounded(低 severity→0 非 flat)、consequence 連續(走 food_days 無 if-branch)。
# ②必附 machine-demonstrate：dump hedge 對 severity 曲線證 bounded 非 offset。

const EventFactionDefect = preload("res://scripts/simulation/events/event_faction_defect.gd")

var _fail: int = 0
func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

func _initialize() -> void:
	print("=== 靶1 herald catastrophe-hedge（bounded、machine-demonstrate）===")
	var pmult: float = 1.0
	# ①bounded：低 severity（<HEDGE_ONSET）→ hedge==0（非 flat always-ask offset）。
	_ok(FactionAISystem.herald_hedge(0.0, pmult) == 0.0, "severity=0 → hedge=0")
	_ok(FactionAISystem.herald_hedge(0.3, pmult) == 0.0, "severity=0.3(<onset) → hedge=0（非 flat offset）")
	_ok(FactionAISystem.herald_hedge(FactionAISystem.HEDGE_ONSET, pmult) == 0.0, "severity=HEDGE_ONSET → hedge=0（onset 起算）")
	# 高 severity → hedge>0 且單調遞增（proximity scale）。
	_ok(FactionAISystem.herald_hedge(1.0, pmult) > 0.0, "severity=1 → hedge>0")
	# ★machine-demonstrate：dump hedge 對 severity 曲線 + 驗單調遞增（bounded 非 offset）。
	print("  --- hedge-vs-severity 曲線（pmult=1.0）machine-demonstrate ---")
	var sev_pts := [0.0, 0.2, 0.4, 0.5, 0.55, 0.6, 0.7, 0.8, 0.9, 1.0]
	var prev: float = -1.0
	var mono := true
	for s in sev_pts:
		var h: float = FactionAISystem.herald_hedge(s, pmult)
		print("    severity=%.2f  hedge=%.5f" % [s, h])
		if h < prev - 1e-9: mono = false
		prev = h
	_ok(mono, "hedge 對 severity 單調非遞減（proximity scale、bounded 非 flat offset）")
	# 人格 modulate：pmult 高→hedge 高、pmult 0→hedge 0（非死常數 boost）。
	_ok(FactionAISystem.herald_hedge(1.0, 1.5) > FactionAISystem.herald_hedge(1.0, 0.5), "hedge 隨 pmult 人格 modulate（驕傲晚/務實早）")
	_ok(FactionAISystem.herald_hedge(1.0, 0.0) == 0.0, "pmult=0 → hedge=0（人格全壓、非硬 boost）")
	# ★razor-thin near-miss 翻：baseline mini<0（-0.004 級）+ hedge → mini>0（求援 fire）。
	var sev: float = 0.9
	var mini_before: float = sev * pmult * FactionAISystem.INFO_RELIEF_EXPECT - FactionAISystem.INFO_ANON_COST
	# baseline mini_before 於高 severity 其實已 >0；razor near-miss 語意=pmult 低壓到 ~0。用低 pmult 造 near-miss。
	var pm_razor: float = FactionAISystem.INFO_ANON_COST / (sev * FactionAISystem.INFO_RELIEF_EXPECT) - 0.002   # 讓 mini_before≈-0.004 級
	var mb: float = sev * pm_razor * FactionAISystem.INFO_RELIEF_EXPECT - FactionAISystem.INFO_ANON_COST
	var ma: float = mb + FactionAISystem.herald_hedge(sev, pm_razor)
	print("  razor near-miss: mini_before=%.5f  mini_after=%.5f (pmult=%.4f)" % [mb, ma, pm_razor])
	_ok(mb < 0.0 and ma > 0.0, "razor-thin near-miss（mini<0）+ hedge → mini>0（求援 fire）")

	print("=== 靶2 defect consequence-pricing（連續、無 branch、anti-crank）===")
	var D: float = DecisionTerms.DESPERATION_DAYS
	# 吃飽（food_days>=DESPERATION）→ starve_frac=0 → consequence=0（野心叛 util 不變）。
	_ok(EventFactionDefect.defect_consequence(D) == 0.0, "food_days=DESPERATION → consequence=0（吃飽野心叛不變）")
	_ok(EventFactionDefect.defect_consequence(D * 2.0) == 0.0, "food_days=2×DESPERATION → consequence=0（clampf、吃很飽仍 0）")
	# 餓（food_days→0）→ consequence 最大。
	_ok(EventFactionDefect.defect_consequence(0.0) > 0.0, "food_days=0 → consequence>0（餓叛壓）")
	# ★連續（走 food_days 連續函式、無 if-starving branch）：多點嚴格單調遞減。
	print("  --- consequence-vs-food_days 曲線（連續證）---")
	var fd_pts := [0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0]
	var pc: float = 999.0
	var strict_mono := true
	for fd in fd_pts:
		var c: float = EventFactionDefect.defect_consequence(fd)
		print("    food_days=%.2f  consequence=%.5f" % [fd, c])
		if fd < D and c >= pc: strict_mono = false   # 未吃飽段嚴格遞減
		pc = c
	_ok(strict_mono, "consequence 對 food_days 未飽段嚴格遞減（連續走 food_days、無 if-branch）")
	# ★anti-crank：絕望-abandoned 餓隊 distress×loyalty 仍壓過 consequence 照叛（genuine 保留）。
	var distress: float = 1.0; var loyalty: float = 1.0; var stay: float = 0.0
	var util_abandoned: float = distress * loyalty - stay - EventFactionDefect.defect_consequence(0.0)
	_ok(util_abandoned > 0.0, "絕望-abandoned 餓隊（distress×loyalty=1、stay=0）util>0 照叛（非刪叛離）")
	# 吃飽野心叛（starve_frac=0）util 不變照 fire。
	var util_fed_before: float = 0.6 * 0.6 - 0.0
	var util_fed_after: float = 0.6 * 0.6 - 0.0 - EventFactionDefect.defect_consequence(D)
	_ok(util_fed_before == util_fed_after, "吃飽野心叛 consequence=0 → util 不變照 fire（餓叛≠野心叛 state-emergent）")

	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()
