extends SceneTree

# ★★★⑨ 貨幣創世的世界讀數（驗收 ①③④⑤）——★一跑收齊。
#
# ★驗收④【coin 月週轉 ＝ 成交額 ÷ 存量】是【k 的唯一合法證據】——
#   ★★而 6912 vs 手寫 7000 只差 1.3% 這件事【不得頂替它】：
#     ★★★兩個估計若共用方法，吻合是【必然】不是【證據】（手寫的 7000 也可能是同樣直覺估的）。
#
# 用法：MG_DAYS（default 90）／MG_SEED（default 1337）／MG_CONFIG（default peaceful_economy）
#       ★MG_HANDWRITTEN=1 ⇒ 驗收⑤鑑別力：把推導改回手寫 7000 的近似（總量固定 7000）

# ★手寫批的總量：config/peaceful_economy.json 12 隊 800×6 + 300×2 + 1000×1 + 200×3 = 7000
const HANDWRITTEN_TOTAL: float = 7000.0

var _fail: int = 0
func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

func _initialize() -> void:
	_run()
	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()

# ★★★全池普查――直接用既有的 `CoinAudit.total()`（coin_audit.gd:9，六池）。
#   ★血證 2026-09-07：我自己寫了一支只數【team.resources.coin + person.coin】的普查（兩池），
#     漏了 anon_treasury（薪資就是進這裡）／tile.public_storage.coin／tile.abandoned_coin／offmap_extinct_coin。
#   ★★於是我看到 −90 日 −1210.61，而我把它報成【coin 在消失】。
#   ★★★而它是【兩個普查的差】――守恆律的量必須用守恆律自己的普查，
#     另寫一支「差不多的」普查 = 把自己的盲點當成世界的缺陷。
func _coin_total(state: WorldState) -> float:
	return CoinAudit.total(state)

func _run() -> void:
	var days: int = int(OS.get_environment("MG_DAYS")) if OS.has_environment("MG_DAYS") else 90
	var world_seed: int = int(OS.get_environment("MG_SEED")) if OS.has_environment("MG_SEED") else 1337
	var cfg: String = OS.get_environment("MG_CONFIG") if OS.has_environment("MG_CONFIG") else "peaceful_economy"
	print("=== money_genesis_bed: config=%s seed=%d days=%d ===" % [cfg, world_seed, days])
	seed(world_seed)
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg)
	config["seed"] = world_seed
	var state: WorldState = MeasureBedHelper.arm_and_setup(config)
	# ★★★驗收⑤ 鑑別力：MG_HANDWRITTEN=1 ⇒ 把 coin 換回【手寫 7000】。
	#   ★血證 2026-09-07：本檔檔頭從一開始就寫著這個旗標，而【全庫沒有任何 code 讀它】――
	#     兩邊輸出逐字相同，只差 TickPerf 的耗時數字。
	#   ★★也就是說：驗收⑤【從來不可測】，而檔頭看起來像它可測。
	#   ★★★而它被抓到的唯一原因是我真的跑了那個對照並比對。
	if OS.has_environment("MG_HANDWRITTEN") and OS.get_environment("MG_HANDWRITTEN") == "1":
		var cur: float = 0.0
		for _tid in state.teams:
			cur += float(state.teams[_tid].resources.get("coin", 0))
		if cur > 0.0:
			var scale: float = HANDWRITTEN_TOTAL / cur
			for _tid2 in state.teams:
				var t2: TeamData = state.teams[_tid2]
				t2.resources["coin"] = float(t2.resources.get("coin", 0)) * scale
		print("[MG] ★鑑別力模式：已把隊伍 coin 總量縮放回手寫值 %.1f（原 %.1f）" % [HANDWRITTEN_TOTAL, cur])
	var start_coin: float = _coin_total(state)
	var derived: float = Probe.amount("genesis.coin_total")
	var given: float = Probe.amount("genesis.coin_given")
	# ★鑑別力模式下，實發要讀【縮放後的真實存量】，不能繼續讀 genesis 的 tap（那是推導側的數）
	if OS.has_environment("MG_HANDWRITTEN") and OS.get_environment("MG_HANDWRITTEN") == "1":
		given = 0.0
		for _tid3 in state.teams:
			given += float(state.teams[_tid3].resources.get("coin", 0))

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
	print("  月週轉 = 流量 ÷ 存量 ÷ 月數 = %.4f 次/月" % (flow / maxf(start_coin, 0.001) / maxf(months, 0.001)))
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
		# ★★★舊版寫死「這棵樹上沒有這個儀器」――而那只是【其中一個成因】。
		#   ★血證 2026-09-07：MG_DAYS=0 跑 0 tick 時它照樣印那句，而樹上【有】那個 tap。
		#   ⇒ ★★預寫的解釋綁定了一個成因，而任何產生同樣症狀的成因都會觸發它。
		if not Probe.counts.has("valuation.priced") and not Probe.counts.has("valuation.price_zero"):
			print("  ★母體 0：這棵樹上找不到 valuation.* 的任何 tap ⇒ 【儀器不在】")
		else:
			print("  ★母體 0，而儀器【在】⇒ 這一輪真的沒有任何估價發生（例：days=0）")
	else:
		print("  估價次數 = %d ｜ 全物資平均價 = %.3f" % [priced, Probe.amount("valuation.price_sum") / float(priced)])
		print("     ★★★而【全物資平均價】答不了本格要問的問題：BASE_PRICE 從 food 2.0 到 weapon 77.0，")
		print("        把它們平均成一個數 = 把【不同單位的東西】相加。★它會隨【交易組成】飄，")
		print("        而那與【物價漂移】是兩件事。★★下面改用【無量綱比值】逐物資印：")
	print("")
	# ★直接量【每種物資的 local_value ÷ BASE_PRICE】――無量綱，可以跨物資比較。
	#   1.0 = 持平；>1 = 缺（估值高於基準）；<1 = 過剩；0 = ⑥拆 clamp 後的深過剩。
	var lines: Array = []
	for res in TradeValuation.BASE_PRICE.keys():
		var base: float = float(TradeValuation.BASE_PRICE[res])
		if base <= 0.0: continue
		var sum_r: float = 0.0
		var n_r: int = 0
		for tid_r in state.teams:   # gate-ok: 觀測用全量普查（不進決策）
			sum_r += TradeValuation.local_value(state.teams[tid_r], res, state)
			n_r += 1
		if n_r == 0: continue
		lines.append("%s=%.2f" % [res, (sum_r / float(n_r)) / base])
	print("     逐物資 local_value/BASE_PRICE（全隊均值，母體 %d 隊）：" % state.teams.size())
	print("       " + " ｜ ".join(lines))
	print("=== money_genesis_bed DONE ===")
