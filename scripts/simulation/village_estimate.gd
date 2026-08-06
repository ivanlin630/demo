class_name VillageEstimate
extends RefCounted

# ★復甦路徑 §1.0 god-view 結構防線核心：MarginalEconomy 的唯一輸入面＝純 struct（非 live target team）。
# 逐欄來源（感知鐵律、spec §1.0 表）：
#   terrain/outpost_level/farming_level = 自家村行政/holding 記錄（靜態地理/結構欄、緩變、非 live-tile 讀）
#   pop = belief pop_est（holding 報 / care-scout firsthand、動態走 belief）
#   harvest_factor = NEUTRAL 1.0（季節平均、belief 無季節欄=誠實無知、= §3 底查 Model B baseline）
#   prod_skill = NEUTRAL 0.0（belief 不 carry 技能值、遠村技能未知=保守中性、同 baseline）
# ★結構防線：此物件無 state/team 參照 → MarginalEconomy 拿不到 live 物件 → 結構上不可能 god-view（非道德勸說）。
var terrain: String = "plains"
var outpost_level: int = 1
var farming_level: int = 0
var pop: int = 0
var harvest_factor: float = 1.0   # NEUTRAL
var prod_skill: float = 0.0        # NEUTRAL

# 便利工廠：從自家村行政記錄（結構欄）+ belief pop_est 建 est（harvest/prod_skill 保 NEUTRAL）。
# ★呼叫者負責只餵行政/belief 值、禁餵 live target tile/leader（結構上此 factory 也不吃 state）。
static func make(terrain_: String, outpost_level_: int, farming_level_: int, pop_est: int) -> VillageEstimate:
	var e := VillageEstimate.new()
	e.terrain = terrain_
	e.outpost_level = maxi(outpost_level_, 1)
	e.farming_level = maxi(farming_level_, 0)
	e.pop = maxi(pop_est, 0)
	return e
