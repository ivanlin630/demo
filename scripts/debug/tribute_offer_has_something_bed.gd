extends SceneTree
# @bed-kind: invariant
# slice: 用戶第二手 ④（spec 2026-10-07 absorb-at-cap-cap-shown-feed-order-tribute-offer）——沒錢不提進貢
#
# ★用戶試玩：對方來「要向你進貢」，按收下 ⇒「Team N 要進貢，但它身上沒有錢可以給」
#   ⇒ 列的條件 ≠ 做的條件：提案端（決策選項「求和」，order_task＝tribute_offer）不看自己有沒有東西可給，
#     收下那一端（DiplomaticAiSystem.apply_tribute_transfer）只轉 coin
# ⇒ 判準與轉帳讀【同一支】金額函式（DiplomaticAiSystem.tribute_amount），不另寫一份門檻
#
# P1 判定：佈置受威脅、未在冷卻的隊 ⇒ coin＝0 時「求和」不列；coin＞0 時列（正對照）
# P2 母體：seed 1337 跑 10 天，每一次某隊的 order_task 變成 tribute_offer 的那一刻，那隊 coin 必須 > 0
#   ★母體地板：這 10 天裡真的有人提過（否則 P2 是空集合的綠）
#
# ★誠實限：P2 讀的是「order_task 被設上那一 tick 結束時」的 coin（同一 tick 先決策後結算，coin 可能在決策後才變）
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/tribute_offer_has_something_bed.gd

const SEED: int = 1337
const DAYS: int = 10
var _errors: int = 0


func _check(msg: String, cond: bool) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_errors += 1
		push_error("[FAIL] " + msg)


func _initialize() -> void:
	print("=== tribute_offer_has_something：沒有東西可給就不提進貢 ===")
	_p1_applicable()
	_p2_population()
	print("\n=== tribute_offer_has_something DONE === errors: %d" % _errors)
	quit(1 if _errors > 0 else 0)


# ★修前這個欄位不存在 ⇒ 用 set() 寫（不存在時靜默不寫）⇒ 修前 coin＝0 那一格紅在格上，不讓整支床 parse 失敗
func _ctx(coin_ok: bool) -> DecisionContext:
	var c := DecisionContext.new()
	c.threat_react = 1.0
	c.threat_threshold = 0.0
	c.threat_id = 1
	c.pacify_target_on_cooldown = false
	c.set("has_tribute_to_give", coin_ok)
	return c


func _p1_applicable() -> void:
	print("\n── P1 受威脅、未冷卻：coin＝0 ⇒「求和」不列；coin＞0 ⇒ 列 ──")
	var app: Callable = DecisionOptions.REGISTRY["求和"]["applicable"]
	var broke: bool = bool(app.call(_ctx(false)))
	var rich: bool = bool(app.call(_ctx(true)))
	print("   coin＝0 ⇒ 列 %s｜coin＞0 ⇒ 列 %s" % [str(broke), str(rich)])
	_check("P1 沒有東西可給 ⇒「求和」（tribute_offer）不列", not broke)
	_check("P1【正對照】有錢 ⇒ 照列（不是把求和整個關掉）", rich)


func _p2_population() -> void:
	print("\n── P2 母體：seed %d、%d 天，每一次提出進貢的那一刻，提案隊 coin > 0 ──" % [SEED, DAYS])
	seed(SEED)
	var ws: WorldState = MeasureBedHelper.arm_and_setup("res://config/default.json", false)
	var runner := SimRunner.new()
	var prev: Dictionary = {}
	var n: int = 0
	var bad: Array = []
	for _i in range(DAYS * WorldState.TICKS_PER_DAY):
		runner.advance_tick(ws, Vector2i(-1, -1))
		for tid in ws.teams.keys():
			var t: TeamData = ws.teams[tid]
			var now_offer: bool = t.order_task == TeamData.TASK_TRIBUTE_OFFER
			if now_offer and not bool(prev.get(tid, false)):
				n += 1
				var coin: float = float(t.resources.get("coin", 0.0))
				if coin <= 0.0 and bad.size() < 10:
					bad.append("tick=%d Team%d coin=%.1f" % [ws.world.current_tick, int(tid), coin])
			prev[tid] = now_offer
	print("   提出進貢 %d 次｜沒錢就提的：%s" % [n, str(bad)])
	_check("★P2 母體地板：%d 天裡真的有人提過進貢（%d 次）" % [DAYS, n], n > 0)
	_check("P2 每一次提出進貢，提案隊身上有錢（沒錢就提的 %d 筆）" % bad.size(), bad.is_empty())
