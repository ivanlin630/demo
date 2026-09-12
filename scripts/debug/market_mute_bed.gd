extends SceneTree
# @bed-kind: acceptance
# slice: 市場靜音 —— 「13 支 PRODUCE 隊、30 天、零賣出」是哪一種 0
#
# ★母體：**窗末仍存在、且曾經帶 PRODUCE tag 的隊**（★逐日累積首見 —— 不是窗首快照，
#   ★★因為生產隊是【長出來的】；我們在求居那張票上被窗首快照咬過一次）。
# ★★四種 0【互斥且窮盡、可對帳】（★不准有「其他」桶；上一次靠這條逼出了沒想到的類別）：
#   ①**沒想賣**（`mkt.t<id>.post_sell` ＝ 0）
#   ②**想賣但一件都押不到貨**（有 post_sell、而 `escrow_post` ＝ 0）
#   ③**押到貨但沒成交**（有 escrow_post、而 `deal` ＝ 0）★這一格才是「賣不掉」
#   ④**有成交**（≠ 0，不屬於「零賣出」）
# ★★★而「tap 根本不存在」那一種（第四種 0 的原型）**本床先排除**：
#   它印出**全域四站的計數**，★若第一站全域也是 0 ⇒ 那才要回頭查管道。
# env：MM_TICKS（預設 43200 ＝ 30 天）／MM_SEED（1337）／MM_CONFIG（warring_states）

var _fails: int = 0

func _initialize() -> void:
	_run(); quit(0 if _fails == 0 else 1)

func _ok(c: bool, m: String) -> void:
	if c: print("  [OK] %s" % m)
	else:
		_fails += 1
		push_error("[FAIL] %s" % m)

func _run() -> void:
	var ticks: int = int(OS.get_environment("MM_TICKS")) if OS.has_environment("MM_TICKS") else 43200
	var seed_val: int = int(OS.get_environment("MM_SEED")) if OS.has_environment("MM_SEED") else 1337
	var cfg: String = OS.get_environment("MM_CONFIG") if OS.has_environment("MM_CONFIG") else "warring_states"
	print("=== 市場靜音：那個 0 是哪一種（%d tick ＝ %.1f 天｜seed=%d｜%s）===" % [
		ticks, float(ticks) / float(WorldState.TICKS_PER_DAY), seed_val, cfg])
	seed(seed_val)
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)
	var cohort: Dictionary = {}   # ★曾經是 PRODUCE 的隊（逐日累積首見）
	for t in range(ticks):
		runner.advance_tick(st, no_player)
		if st.world.current_tick % WorldState.TICKS_PER_DAY == 0:
			for tid in st.teams:
				if (st.teams[tid] as TeamData).tags.has(TeamData.TAG_PRODUCE):
					cohort[tid] = true
	# ── 全域四站（★先排除「tap 不存在」那一種 0）──
	print("")
	print("★全域四站（★這四個數若第一站是 0 ⇒ 才要回頭查管道通不通電）：")
	print("   ①張貼賣單 trade.post_sell = %d｜（對照：買單 trade.post_buy = %d）" % [
		int(Probe.counts.get("trade.post_sell", 0)), int(Probe.counts.get("trade.post_buy", 0))])
	print("   ②押貨 escrow post/partial = %d／%d｜一件都押不到 = %d" % [
		int(Probe.counts.get("mkt.escrow.post", 0)), int(Probe.counts.get("mkt.escrow.partial", 0)),
		int(Probe.counts.get("mkt.escrow.nothing", 0))])
	print("   ③上板 g1.board_register = %d" % int(Probe.counts.get("g1.board_register", 0)))
	print("   ④成交 trade.deal = %d（市集 %d／巧遇 %d）" % [
		int(Probe.counts.get("trade.deal", 0)), int(Probe.counts.get("trade.deal_market", 0)),
		int(Probe.counts.get("trade.deal", 0)) - int(Probe.counts.get("trade.deal_market", 0))])
	# ── 逐隊四桶（★互斥且窮盡、對帳）──
	var b_no_intent: int = 0
	var b_no_stock: int = 0
	var b_no_deal: int = 0
	var b_dealt: int = 0
	var rows: Array = []
	for tid2 in cohort:
		var _sell: int = int(Probe.counts.get("mkt.t%d.post_sell" % tid2, 0))
		var _esc: int = int(Probe.counts.get("mkt.t%d.escrow_post" % tid2, 0))
		var _deal: int = int(Probe.counts.get("mkt.t%d.deal" % tid2, 0))
		var _b: String = ""
		if _deal > 0: _b = "④有成交"; b_dealt += 1
		elif _esc > 0: _b = "③押到貨但沒成交"; b_no_deal += 1
		elif _sell > 0: _b = "②想賣但押不到貨"; b_no_stock += 1
		else: _b = "①沒想賣"; b_no_intent += 1
		rows.append({"team": tid2, "sell": _sell, "esc": _esc, "deal": _deal, "b": _b})
	var tot: int = cohort.size()
	print("")
	print("★★逐隊四桶（母體 ＝ 曾經帶 PRODUCE tag 的隊 %d 支；★逐日累積首見，非窗首快照）" % tot)
	print("   ①沒想賣 %d｜②想賣但押不到貨 %d｜③押到貨但沒成交 %d｜④有成交 %d" % [
		b_no_intent, b_no_stock, b_no_deal, b_dealt])
	print("   對帳：%d + %d + %d + %d = %d vs 母體 %d ⇒ %s" % [
		b_no_intent, b_no_stock, b_no_deal, b_dealt,
		b_no_intent + b_no_stock + b_no_deal + b_dealt, tot,
		"OK" if b_no_intent + b_no_stock + b_no_deal + b_dealt == tot else "★不符"])
	_ok(b_no_intent + b_no_stock + b_no_deal + b_dealt == tot, "四桶互斥且窮盡（對帳 ＝ 母體）")
	print("   ★★★『沒有人賣』（①②）與『賣不掉』（③）是兩件事 —— 前者是動機、後者是撮合")
	print("   ★逐筆前 20：")
	for r in rows.slice(0, 20):
		print("     team=%d 賣單 %d｜押到貨 %d｜成交 %d ⇒ %s" % [
			int(r["team"]), int(r["sell"]), int(r["esc"]), int(r["deal"]), String(r["b"])])
	# ── ③窗太短那一格（★窗末仍掛著的賣單） ──
	var open_sell: int = 0
	for tid3 in st.teams:
		for o in (st.teams[tid3] as TeamData).active_orders:
			if String(o.get("kind", "")) == "sell": open_sell += 1
	print("★③窗末仍掛著的賣單 = %d（★它們不進上面的分母討論 —— 窗太短是第三種 0）" % open_sell)
	print("★fp = %s" % StateFingerprint.compute(st))
	print("=== DONE === SECTIONS=1/1 FAILS=%d" % _fails)
	print("[TEST-SUITE-COMPLETE]")
