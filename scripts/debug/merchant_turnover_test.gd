extends SceneTree
# @bed-kind: invariant
# 商人持貨機會成本 ＝【當下可得的最佳套利 gain】——四格驗收（systems spec 2026-09-08）
#
# ★母體鐵則：一律用 ambition_archetype == ARCHETYPE_TRADE，禁用 TAG_MERCHANT。
#   R² 量過：warring_states.json 是 random 模式、商隊字面 0 處
#   ⇒ 用 TAG 當閘在【正在量的那個世界】就是啞的：閘綠、床綠、世界毫無變化。
#   ⇒ 第④格就是專門擋這個。

var _fail: int = 0

func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else:
		print("  [FAIL] %s" % m)
		_fail += 1

func _mk_merchant(state: WorldState, tid: int) -> TeamData:
	var t := TeamData.new()
	t.team_id = tid
	t.ambition_archetype = AmbitionLadder.ARCHETYPE_TRADE
	var ldr := PersonData.new(); ldr.id = tid * 100; ldr.team_id = tid
	ldr.values = {"貪婪": 0.5, "義氣": 0.5, "信義": 0.5, "慎重": 0.5}
	state.persons[ldr.id] = ldr
	t.leader_id = ldr.id
	var m := PersonData.new(); m.id = tid * 100 + 1; m.team_id = tid
	state.persons[m.id] = m
	t.named_members = [m.id]
	t.tile_pos = Vector2i(3, 3)
	# ★手上有貨（分母）＋ 足糧足幣（把食物項與 coin 項壓成 0，隔離 turnover 項）
	t.resources = {"coin": 100000.0, "food": 100000.0, "material": 20.0}
	state.teams[tid] = t
	return t

func _seed_sell_order(state: WorldState, to_tid: int, res: String, qty: int, price: float) -> void:
	var msg := MessageData.new()
	msg.type = "order_sell"
	msg.is_distorted = false
	msg.params = {"res": res, "qty": qty, "origin_team": 999, "origin_pos": Vector2i(3, 3),
		"order_id": 1, "price": price}
	var arr: Array = state.team_known.get(to_tid, [])
	arr.append(msg)
	state.team_known[to_tid] = arr

func _initialize() -> void:
	print("=== merchant_turnover: 四格 ===")
	# ★★★一律用【真世界 + 跑一天】：
	#   手工組的 WorldState 裡 `local_value` 恆為 0（它要讀 tile/庫存脆絡）
	#   ⇒ 分母 0 ⇒ turnover 永遠不會 fire，而那是【fixture 的性質】不是世界的。
	#   ★★而 archetype 也是開跑後才指派（day0 全部 ""）⇒ 兩個理由都指向同一件事：
	#   【母體要在它可能存在的時刻量】。
	var w: WorldState = MeasureBedHelper.arm_and_setup("res://config/warring_states.json")
	var r := SimRunner.new()
	for _t in range(WorldState.TICKS_PER_DAY):
		r.advance_tick(w, Vector2i(-1, -1))

	# ── ④ 母體非空（★先跑：沒它，前三格可以全綠而世界毫無變化）──
	print("  ── ④ 母體非空 ──")
	var n_trade: int = 0
	var n_tag: int = 0
	var pick: TeamData = null
	for tid in w.teams:
		var tt: TeamData = w.teams[tid]
		if tt.tags.has(TeamData.TAG_MERCHANT): n_tag += 1
		if tt.ambition_archetype != AmbitionLadder.ARCHETYPE_TRADE: continue
		n_trade += 1
		if pick != null: continue
		for res in tt.resources:
			if String(res) != "coin" and float(tt.resources[res]) > 0.0 				and TradeValuation.local_value(tt, String(res), w) > 0.0:
				pick = tt
				break
	print("     ARCHETYPE_TRADE=%d 支｜TAG_MERCHANT=%d 支（共 %d 支隊）" % [n_trade, n_tag, w.teams.size()])
	_ok(n_trade > 0, "★ARCHETYPE_TRADE 母體非空 ―― 這一項在真世界裡真的會生效")
	_ok(pick != null, "★★找得到【手上有非 coin 貨且估值>0】的商隊（分母母體）")
	if pick == null:
		print("=== DONE === %d FAIL（★母體不存在 ⇒ ①②③【不可判】，不假裝成綠）" % (_fail + 1))
		quit()
		return

	# ── 基準：非商隊的 urgency（食物/coin 兩項）──────────
	#   ★不能用【埋單前的商隊 urgency】當基準：這個世界在埋單前
	#   就已經有 gain>0，那個值裡本來就含 turnover 項。
	var keep0: String = pick.ambition_archetype
	pick.ambition_archetype = "農業"
	var u_base: float = TradeValuation._urgency(pick, w)
	pick.ambition_archetype = keep0
	print("  ── 基準（非商隊，只有食物/coin 項）= %.4f ──" % u_base)

	# ── ② 市場死寂：★真的造出來（清掉該隊的已知訂單）─────
	#   ★★我第一版對②寫了 `_ok(true, ...)` ―― 一格【免費綠】，
	#   而這個世界在埋單前 gain 已經是 4.42，根本不是死寂。
	var known_keep: Array = w.team_known.get(pick.team_id, [])
	w.team_known[pick.team_id] = []
	var arb_dead: Dictionary = OrderSystem.new().best_arbitrage_order(w, pick)
	var u_dead: float = TradeValuation._urgency(pick, w)
	w.team_known[pick.team_id] = known_keep
	print("  ── ② 市場死寂（已知訂單清空）：arb=%s｜urgency=%.4f ──" % [str(arb_dead), u_dead])
	_ok(arb_dead.is_empty(), "★死寂真的造出來了（arb 為空）")
	_ok(is_equal_approx(u_dead, u_base), "★★② gain=0 ⇒ turnover 項不貢獻（回到基準 %.4f）" % u_base)

	# ── ① 埋一張肥單 ⇒ turnover 項抬高 urgency ───────
	print("  ── ① 商人 ∧ 當下有肥單 ──")
	var res0: String = ""
	for res in pick.resources:
		if String(res) != "coin" and TradeValuation.local_value(pick, String(res), w) > 0.0:
			res0 = String(res); break
	_seed_sell_order(w, pick.team_id, res0, 20, 0.01)
	var u_after: float = TradeValuation._urgency(pick, w)
	var arb1: Dictionary = OrderSystem.new().best_arbitrage_order(w, pick)
	print("     埋 %s 單價 0.01×20｜arb.gain=%.4f｜urgency=%.4f" % [res0, float(arb1.get("gain", 0.0)), u_after])
	_ok(float(arb1.get("gain", 0.0)) > 0.0, "★母體：肥單真的被看到了（gain > 0）")
	_ok(u_after > u_base, "★turnover 項抬高急迫度（基準 %.4f → %.4f）" % [u_base, u_after])

	# ── ③ 分岔可見：同一支隊、同一張單，只改 archetype ──
	print("  ── ③ 分岔可見（★唯一差別是 ambition_archetype）──")
	pick.ambition_archetype = "農業"
	var u_farm: float = TradeValuation._urgency(pick, w)
	pick.ambition_archetype = keep0
	print("     商隊=%.4f｜非商隊=%.4f｜基準=%.4f" % [u_after, u_farm, u_base])
	_ok(u_after != u_farm, "★兩型可分辨")
	_ok(is_equal_approx(u_farm, u_base), "★★非商隊回到基準 ⇒ 差額確實來自 turnover 項")

	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()
