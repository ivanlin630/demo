extends SceneTree

# null-belief-flee 凍結根治 TDD（spec 2026-07-20-nullbelief-flee-release）。
# root：FLEE flee_from_pos=威脅 belief 位；positionless→(-1,-1)→movement 無 target+continue（沒人 release）
#       →卡 task=逃跑 凍結餓死（team75/4/13）。
# 修 A（applicability-gate，primary）：FLEE(survival option) applicable 僅當 ctx.threat_pos!=(-1,-1)
#       （鏡射 _flee_threat_pos）→ positionless 不選 FLEE → 落次佳覓食/defend。
# 修 B（movement backstop，冗餘）：FLEE+flee_from_pos=(-1,-1)→release 非 continue-freeze。
# 不回退 live-track（無座標=轉覓食，非偷讀 live）。

var _fail: int = 0

func _initialize() -> void:
	_test_positionless_flee_not_applicable()   # ① 修A：威脅無座標→FLEE not applicable
	_test_positioned_flee_applicable()         # ② 修A：威脅有座標→FLEE applicable（不誤傷 coherent flee）
	_test_movement_backstop_releases()         # ③ 修B：FLEE+positionless→movement release 非 freeze
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

# ① 修A：威脅 positionless（threat_pos=-1）→ survival(FLEE) option not applicable
func _test_positionless_flee_not_applicable() -> void:
	print("--- ①修A 威脅無座標→FLEE not applicable ---")
	var ctx := DecisionContext.new()
	ctx.threat_pos = Vector2i(-1, -1)   # 威脅存在感有但無 belief 座標
	var app: bool = DecisionOptions.REGISTRY["survival"]["applicable"].call(ctx)
	_ok(not app, "threat_pos=(-1,-1) → FLEE not applicable（不選中卡死，落次佳覓食）")

# ② 修A：威脅有座標 → FLEE applicable（coherent flee 不誤傷）
func _test_positioned_flee_applicable() -> void:
	print("--- ②修A 威脅有座標→FLEE applicable（不誤傷）---")
	var ctx := DecisionContext.new()
	ctx.threat_pos = Vector2i(3, 3)   # 威脅有 belief 座標→可算逃向
	var app: bool = DecisionOptions.REGISTRY["survival"]["applicable"].call(ctx)
	_ok(app, "threat_pos=(3,3) → FLEE applicable（正常逃，coherent flee 不誤傷）")

# ③ 修B：FLEE+flee_from_pos=(-1,-1) → movement release（非 continue-freeze 卡逃跑餓死）
func _test_movement_backstop_releases() -> void:
	print("--- ③修B movement backstop：FLEE positionless→release ---")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	var t := TeamData.new()
	t.team_id = 75; t.tile_pos = Vector2i(4, 4)
	t.current_task = TeamData.TASK_FLEE
	t.flee_from_pos = Vector2i(-1, -1)   # 威脅無座標（belief 過期成 positionless 的 timing 邊角）
	t.combat_target = -1
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", 5)
	state.teams[75] = t
	MovementSystem.new().process(state, [75])
	_ok(t.current_task == TeamData.TASK_IDLE, "FLEE+flee_from_pos=(-1,-1) → release→IDLE（非卡逃跑 freeze，got '%s')" % t.current_task)
