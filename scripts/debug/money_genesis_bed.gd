extends SceneTree

# ★★★⑨ 貨幣創世的世界讀數（驗收 ①③④⑤）——★一跑收齊。
#
# ★驗收④【coin 月週轉 ＝ 成交額 ÷ 存量】是【k 的唯一合法證據】——
#   ★★而 6912 vs 手寫 7000 只差 1.3% 這件事【不得頂替它】：
#     ★★★兩個估計若共用方法，吻合是【必然】不是【證據】（手寫的 7000 也可能是同樣直覺估的）。
#
# 用法：MG_DAYS（default 90）／MG_SEED（default 1337）／MG_CONFIG（default peaceful_economy）
#       ★MG_HANDWRITTEN=1 ⇒ 驗收⑤鑑別力：把推導改回手寫 7000 的近似（總量固定 7000）

var _fail: int = 0
func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

func _initialize() -> void:
	_run()
	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()

func _coin_total(state: WorldState) -> float:
	var t: float = 0.0
	for tid in state.teams:
		t += float(state.teams[tid].resources.get("coin", 0))
	for pid in state.persons:
		t += float(state.persons[pid].coin)
	return t

func _run() -> void:
	var days: int = int(OS.get_environment("MG_DAYS")) if OS.has_environment("MG_DAYS") else 90
	var world_seed: int = int(OS.get_environment("MG_SEED")) if OS.has_environment("MG_SEED") else 1337
	var cfg: String = OS.get_environment("MG_CONFIG") if OS.has_environment("MG_CONFIG") else "peaceful_economy"
	print("=== money_genesis_bed: config=%s seed=%d days=%d ===" % [cfg, world_seed, days])
	seed(world_seed)
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg)
	config["seed"] = world_seed
	var state: WorldState = MeasureBedHelper.arm_and_setup(config)
	var start_coin: float = _coin_total(state)
	var derived: float = Probe.amount("genesis.coin_total")
	var given: float = Probe.amount("genesis.coin_given")

	# ── 驗收①：初始總量 ＝ 推導值（★逐項來源已由 GameSetup 印出）──
	print("")
	print("═══ ★驗收①：初始 coin 總量 ═══")
	print("  推導值 = %.2f ｜ 實發 = %.2f ｜ 世界起始總和（含個人私產）= %.2f"
		% [derived, given, start_coin])
	_ok(absf(given - derived) < 0.01, "①實發 == 推導（差 %.4f）" % absf(given - derived))
	print("     ★而【世界起始總和】可能大於實發：個人私產是 worldgen 另外給的 ——")
	print("        ★★這兩個數字【不是同一件事】，混起來會讓對帳看起來壞掉。")

	var runner := SimRunner.new()
	for _d in range(days):
		for _t in range(WorldState.TICKS_PER_DAY):
			runner.advance_tick(state, Vector2i(-1, -1))
		if state.teams.is_empty():
			break
	var end_coin: float = _coin_total(state)
	var minted: float = Probe.amount("mint_coin")

	# ── 驗收②：CoinAudit 守恆 ──
	print("")
	print("═══ ★★驗收②：守恆（既有律，本票不得破它）═══")
	print("  期末 %.2f − 期初 %.2f = %.2f ｜ Σ mint_coin = %.2f" % [end_coin, start_coin, end_coin - start_coin, minted])
	_ok(absf((end_coin - start_coin) - minted) < 1.0,
		"②coin 增量 == 鑄幣量（差 %.2f）" % absf((end_coin - start_coin) - minted))

	# ── 驗收④：★月週轉 ＝ 成交額 ÷ 存量（★k 的唯一合法證據）──
	var flow: float = Probe.amount("coin.flow.abs")
	var months: float = float(days) / 30.0
	print("")
	print("═══ ★★★驗收④：coin 月週轉（★k 的唯一合法證據）═══")
	print("  coin 流量總額（絕對值，全 reason）= %.1f ｜ 筆數 = %d"
		% [flow, int(Probe.counts.get("coin.flow.n", 0))])
	print("  月週轉 = 流量 ÷ 存量 ÷ 月數 = %.2f 次/月" % (flow / maxf(start_coin, 0.001) / maxf(months, 0.001)))
	print("     ★★而【流量 ≠ 成交額】：它含薪資／徵收／鑄幣等所有 coin 移動")
	print("        ⇒ ★★★所以下面逐 reason 拆開 —— 【哪些算成交是讀的人的判斷，儀器不替判讀做選擇】")
	var rows: Array = []
	for k in Probe.amounts.keys():
		var ks: String = String(k)
		if ks.begins_with("coin.flow.by."):
			rows.append("%s=%.0f" % [ks.substr(13), Probe.amount(ks)])
	rows.sort()
	var bank_n: int = int(Probe.counts.get("bank.writes.n", 0))
	var coin_n: int = int(Probe.counts.get("coin.flow.n", 0))
	print("  逐 reason：%s" % ("｜".join(PackedStringArray(rows)) if not rows.is_empty() else "（空）"))
	# ★★★而【空】有兩種意思，★它們印出來一模一樣 ⇒ 用對照格分開：
	if coin_n == 0:
		if bank_n == 0:
			print("     ★★★`coin.flow.n == 0` 且 `bank.writes.n == 0` ⇒【儀器沒開】——")
			print("        ResourceBank 一次都沒被寫過，那不可能是世界的事實。")
		else:
			print("     ★★★`coin.flow.n == 0` 而 `bank.writes.n == %d` ⇒【儀器有開，coin 真的沒動】——" % bank_n)
			print("        ★而在短窗這是【正常的】：薪資每 7 日、鑄幣要有 ore ⇒ 兩天內本來就可能零 coin 流動。")
	else:
		print("     ★對照格：`bank.writes.n = %d`（所有 res 的寫入）｜`coin.flow.n = %d` ⇒ 儀器確實在跑" % [bank_n, coin_n])

	# ── 驗收③：物價漂移（★漂移本身不是失敗，要求的是它被印出來且方向可解釋）──
	print("")
	print("═══ ★驗收③：物價（相對 BASE_PRICE 的實際估值分布）═══")
	var priced: int = int(Probe.counts.get("valuation.priced", 0))
	if priced == 0:
		print("  ★★母體 0 ⇒ 本 branch 沒有 `valuation.priced` tap（它在 ⑩ 那支）——")
		print("     ★★★這格【不是 0，是這棵樹上沒有這個儀器】。⑨⑩ 合流後才量得到。")
	else:
		print("  估價次數 = %d ｜ 平均價 = %.3f" % [priced, Probe.amount("valuation.price_sum") / float(priced)])
	print("")
	print("=== money_genesis_bed DONE ===")
