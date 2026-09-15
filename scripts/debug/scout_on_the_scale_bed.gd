extends SceneTree
# @bed-kind: acceptance
# slice: 攻擊幣別＋偵查進秤（HOW spec 2026-09-15-attack-currency-and-scout-on-the-scale §驗收）
#
# ★★★五格、三組成對（systems 派工原話）：
#   組一：①低情報目標**不出現**在攻擊候選 ／ ②情報補齊後**出現**（★同一個目標、同一個觀察者）
#   組二：③偵查**會輸** ／ ④早期窗偵查**真的出現過並贏過**
#   組三：⑤先驗被取代的**逐筆**證據（同一目標：全盲 → 有桶號 → 有可定價分項 ⇒ 不再是偵查候選）
#
# ★母體定義（先寫死在檔頭，★★不是看到數字才決定怎麼數）：
#   ·③的母體 ＝ `optpool.cand.偵查` ＝ **候選集裡真的有偵查的那些次 argmax**
#     ★★用【結構事實】篩，不用隊的情報標籤篩 —— 標籤是分類，候選集才是決策當下真的比較過的東西；
#     ★★★否則【生成失敗】會混進【生成後輸掉】，把勝率稀釋或扭曲。
#   ·④的早期窗 ＝ **第 0 天起算的前 SC_EARLY_DAYS 天**（★窗從哪一天起算必須印出來）
#   ·晚窗 ＝ 全窗 − 早窗（同一趟的前綴／後綴，★中途不 reset ⇒ 沒有 reset 的效應不對稱問題）
#
# env：SC_TICKS（預設 43200 ＝ 30 天）／SC_EARLY_DAYS（預設 7）／SC_SEED（預設 1337）／SC_CONFIG

func _initialize() -> void:
	_run(); quit(0 if _fails == 0 else 1)

var _fails: int = 0

func _ok(cond: bool, msg: String) -> void:
	if cond: print("  [OK] %s" % msg)
	else:
		_fails += 1
		push_error("[FAIL] %s" % msg)

# ★具名紅：每一格紅都要說得出【是哪一種紅】（母體 0／判準不成立／對照失效）
func _red(msg: String) -> void:
	_fails += 1
	push_error("[FAIL] %s" % msg)

static func _feasible_has(scan: Dictionary, tid: int) -> bool:
	for f in (scan.get("feasible", []) as Array):
		if int((f as Dictionary).get("id", -1)) == tid: return true
	return false

func _run() -> void:
	var ticks: int = int(OS.get_environment("SC_TICKS")) if OS.has_environment("SC_TICKS") else 43200
	var early_days: int = int(OS.get_environment("SC_EARLY_DAYS")) if OS.has_environment("SC_EARLY_DAYS") else 7
	var seed_val: int = int(OS.get_environment("SC_SEED")) if OS.has_environment("SC_SEED") else 1337
	var cfg: String = OS.get_environment("SC_CONFIG") if OS.has_environment("SC_CONFIG") else "warring_states"
	print("=== 偵查進秤 驗收（%d tick ＝ %.1f 天，%s，seed=%d）===" % [
		ticks, float(ticks) / float(WorldState.TICKS_PER_DAY), cfg, seed_val])

	# ══════════ §A 逐筆 fixture（①②⑤）——★在【它自己的世界】上做，不污染下面那趟 ══════════
	# ★★這三格不靠跑世界，靠【同一個 (觀察者, 目標) 對】在三種情報狀態下各問一次
	#   ⇒ ★★★成對的兩半共用同一個主體 ⇒ 差異只能來自情報，不可能來自「換了一隊」。
	seed(seed_val)
	var fx: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg)
	# ★★★選對的判準要接【掃描自己的排除順序】：`attack_scan` 是
	#   same_faction → no_belief → belief_pos → **unreachable（continue）** → 才輪到 no_priced_belief
	#   ⇒ ★隨便抓一對會先死在 unreachable，而那時【①看起來還是綠的】（不在候選集）
	#   —— ★★而它綠的理由是錯的。所以這裡挑**距離最近**的異派系對。
	var obs: TeamData = null
	var tgt: TeamData = null
	var best_d: int = 1 << 30
	for a in fx.teams.values():
		if a == null or a.leader_id == -1 or fx.persons.get(a.leader_id) == null: continue
		for b in fx.teams.values():
			if b == null or a.team_id == b.team_id: continue
			if a.faction_id != -1 and a.faction_id == b.faction_id: continue
			var d: int = FactionAISystem._hex_dist(a.tile_pos, b.tile_pos)
			if d < best_d:
				best_d = d
				obs = a; tgt = b
	if obs == null or tgt == null:
		_red("§A 母體 0：找不到【有領袖 + 異派系】的隊對 ⇒ ①②⑤ 三格【不可判】，不是綠")
		return
	print("")
	print("★§A 逐筆 fixture：觀察者 Team%d、目標 Team%d（★同一對，只換情報）｜距離 %d 格" % [obs.team_id, tgt.team_id, best_d])

	# 清掉這一對既有的情報，從【全盲】起算
	if fx.team_intel.has(obs.team_id):
		(fx.team_intel[obs.team_id] as Dictionary).erase(tgt.team_id)
	var disc: Array = fx.team_discovered.get(obs.team_id, [])
	if not (tgt.team_id in disc):
		disc.append(tgt.team_id)
		fx.team_discovered[obs.team_id] = disc

	var ldr: PersonData = fx.persons.get(obs.leader_id)

	# ── 狀態1：全盲（只有位置，沒有任何分項、沒有桶號）──
	BeliefSystem.record_claim(fx, obs.team_id, tgt.team_id, obs.team_id, "firsthand",
		{"tile_pos": tgt.tile_pos}, 1.0, false)
	var scan1: Dictionary = FactionAISystem.attack_scan(fx, obs, ldr)
	var in1: bool = _feasible_has(scan1, tgt.team_id)
	var pick1: Dictionary = DecisionContext.pick_recon_target(fx, obs)
	print("      why1=%s" % str(scan1["why"]))   # ★紅了要看得出是哪一道排除擋的
	print("   狀態1【全盲】：進攻擊可行集合=%s｜偵查挑中=%s（blind=%s，value=%.3f）" % [
		str(in1), str(int(pick1["id"]) == tgt.team_id), str(pick1["blind"]), float(pick1["value"])])
	_ok(not in1, "①低情報目標**不出現**在攻擊候選（★而它是【結構排除】不是【算成 0】）")
	_ok(int((scan1["why"] as Dictionary).get("no_priced_belief", 0)) >= 1,
		"①-b 排除理由逐筆記到了 `no_priced_belief`（★查無 ≠ 沒發生）")
	_ok(int(pick1["id"]) == tgt.team_id and bool(pick1["blind"]),
		"⑤-a 全盲那一刻：它是偵查候選，而且用的是**具名先驗**（blind=true）")

	# ── 狀態2：有桶號（resource_scale）—— ★仍然答不出 coin 當量 ──
	BeliefSystem.record_claim(fx, obs.team_id, tgt.team_id, obs.team_id, "firsthand",
		{"tile_pos": tgt.tile_pos, "resource_scale": 2}, 1.0, false)
	var scan2: Dictionary = FactionAISystem.attack_scan(fx, obs, ldr)
	var in2: bool = _feasible_has(scan2, tgt.team_id)
	var pick2: Dictionary = DecisionContext.pick_recon_target(fx, obs)
	print("      why2=%s" % str(scan2["why"]))   # ★紅了要看得出是哪一道排除擋的
	print("   狀態2【只有桶號】：進攻擊可行集合=%s｜偵查挑中=%s（blind=%s，value=%.3f）" % [
		str(in2), str(int(pick2["id"]) == tgt.team_id), str(pick2["blind"]), float(pick2["value"])])
	_ok(not in2, "①-c 只有桶號**仍然**不進攻擊候選（★桶號是分類，不是價）")
	_ok(int(pick2["id"]) == tgt.team_id and not bool(pick2["blind"]),
		"⑤-b 桶號一到手，**先驗就不再參與**（blind 由 true 轉 false）⇒ 守衛③第一段逐筆證據")

	# ── 狀態3：有可定價分項（coin/food/material）──
	BeliefSystem.record_claim(fx, obs.team_id, tgt.team_id, obs.team_id, "firsthand",
		{"tile_pos": tgt.tile_pos, "resource_scale": 2, "coin_est": 300.0,
		"food_est": 120.0, "population_est": float(tgt.population)}, 1.0, false)
	var scan3: Dictionary = FactionAISystem.attack_scan(fx, obs, ldr)
	var in3: bool = _feasible_has(scan3, tgt.team_id)
	var pick3: Dictionary = DecisionContext.pick_recon_target(fx, obs)
	print("      why3=%s" % str(scan3["why"]))   # ★紅了要看得出是哪一道排除擋的
	print("   狀態3【有可定價分項】：進攻擊可行集合=%s｜偵查挑中=%s" % [
		str(in3), str(int(pick3["id"]) == tgt.team_id)])
	_ok(in3, "②情報補齊後**出現**在攻擊候選（★★與①同目標同觀察者 ⇒ 差異只能來自情報）")
	_ok(int(pick3["id"]) != tgt.team_id,
		"⑤-c 真情報到手 ⇒ **它不再是偵查候選** ⇒ 守衛③【先驗必須被取代】逐筆坐實")
	print("   ★★★而②若與①同紅／同綠 ⇒ 判準沒有鑑別力；兩格必須【方向相反】才算成對。")
	_ok(in3 != in1, "②-b 成對檢查：①與②**方向相反**（★否則兩格量的是同一件事）")

	# ══════════ §B 真世界跑一趟（③④）══════════
	Probe.reset()
	Probe.arm()
	seed(seed_val)
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)
	var early_ticks: int = mini(early_days * WorldState.TICKS_PER_DAY, ticks)
	print("")
	print("★§B 真世界：窗**從第 0 天起算**；早窗 ＝ 第 0 天 → 第 %d 天（%d tick）；全窗 %d 天" % [
		early_days, early_ticks, ticks / WorldState.TICKS_PER_DAY])
	print("   ★★（藍圖規則：戰爭類讀數的窗必須蓋過【偵查時代】⇒ 早窗與全窗都印，不只印一個）")
	for _t in range(early_ticks):
		runner.advance_tick(st, no_player)
	var e_cand: int = int(Probe.counts.get("optpool.cand.偵查", 0))
	var e_win: int = int(Probe.counts.get("optpool.win.偵查", 0))
	var e_moth: int = int(Probe.counts.get("optpool.mother", 0))
	var e_acand: int = int(Probe.counts.get("optpool.cand.攻擊", 0))
	var e_awin: int = int(Probe.counts.get("optpool.win.攻擊", 0))
	for _t in range(ticks - early_ticks):
		runner.advance_tick(st, no_player)
	var f_cand: int = int(Probe.counts.get("optpool.cand.偵查", 0))
	var f_win: int = int(Probe.counts.get("optpool.win.偵查", 0))
	var f_moth: int = int(Probe.counts.get("optpool.mother", 0))
	var f_acand: int = int(Probe.counts.get("optpool.cand.攻擊", 0))
	var f_awin: int = int(Probe.counts.get("optpool.win.攻擊", 0))

	print("")
	print("★③④ 母體＝**候選集裡真的有偵查的那些次 argmax**（★不是隊的情報標籤）")
	print("   argmax 總次數：早窗 %d｜全窗 %d" % [e_moth, f_moth])
	print("   偵查：早窗 候選 %d／贏 %d／**輸 %d**｜晚窗 候選 %d／贏 %d／輸 %d｜全窗 候選 %d／贏 %d／輸 %d" % [
		e_cand, e_win, e_cand - e_win,
		f_cand - e_cand, f_win - e_win, (f_cand - e_cand) - (f_win - e_win),
		f_cand, f_win, f_cand - f_win])
	print("   攻擊：早窗 候選 %d／贏 %d｜全窗 候選 %d／贏 %d" % [e_acand, e_awin, f_acand, f_awin])

	if f_cand == 0:
		_red("③④ 母體 0：全窗【沒有任何一次 argmax 的候選集含偵查】⇒ 兩格**不可判**，不是綠"
			+ "（★先查 applicable：recon_target_id 是不是恆 -1）")
	else:
		_ok(f_cand - f_win > 0,
			"③偵查**會輸** —— 全窗有 %d 次它在候選集裡而沒贏（★若 0 ⇒ 100%% 贏 ⇒ 走廊換了個皮）" % [f_cand - f_win])
		_ok(f_win < f_cand,
			"③-b 勝率 %.1f%% < 100%%（★★與上一格是同一件事的兩種寫法，成對自檢）" % [
				100.0 * float(f_win) / maxf(float(f_cand), 1.0)])
	if e_cand == 0:
		_red("④ 早窗母體 0：第 0～%d 天【沒有一次 argmax 含偵查】⇒ **不可判**，不是綠" % early_days)
	else:
		_ok(e_win > 0,
			"④早期窗偵查**真的出現過並贏過**（早窗贏 %d／候選 %d ＝ %.1f%%）" % [
				e_win, e_cand, 100.0 * float(e_win) / maxf(float(e_cand), 1.0)])

	# ── 單位：偵查與攻擊的 util 分布並排（★spec §3：不是只印有沒有 fire）──
	print("")
	print("★單位驗收：偵查與攻擊的 util **同一組桶界**並排（★★fire 率答不出【是不是輸得很慘】）")
	var buckets: Array = ["u0", "gt0", "ge0.05", "ge0.2", "ge0.5", "ge1"]
	for opt in ["偵查", "攻擊"]:
		var row: Array = []
		var tot: int = int(Probe.counts.get("un." + opt, 0))
		for b in buckets:
			row.append("%s=%d" % [b, int(Probe.counts.get("uhist.%s.%s" % [opt, b], 0))])
		var usum: float = float(Probe.amounts.get("usum." + opt, 0.0))   # ★add_amount 落的是 `amounts` 不是 `counts`
		print("   %s：n=%d 平均=%.4f｜%s" % [opt, tot, usum / maxf(float(tot), 1.0), " ".join(row)])
	_ok(int(Probe.counts.get("un.偵查", 0)) > 0 and int(Probe.counts.get("un.攻擊", 0)) > 0,
		"單位-a 兩個分布**都有母體**（★任一邊 n=0 ⇒ 並排沒有意義，不可判）")

	# ── 先驗用了幾次 vs 桶號用了幾次（★守衛③在真世界裡的聚合面）──
	print("   ★先驗 vs 桶號（真世界聚合面）：全盲 %d 次／有桶號 %d 次｜偵查候選產生 %d 次" % [
		int(Probe.counts.get("recon.candidate.blind", 0)),
		int(Probe.counts.get("recon.candidate.bucket", 0)),
		int(Probe.counts.get("recon.candidate", 0))])
	print("   ★★而【聚合面答不出「同一個目標有沒有被取代」】—— 那是 §A ⑤ 的活，兩者不可互相代替。")
	print("   ★攻擊側結構排除：`no_priced_belief` %d 次（★這是①在真世界裡的量）" % [
		int(Probe.counts.get("attack.excluded.no_priced_belief", 0))])

	print("")
	print("-- 量測完成；[FAIL] 數 ＝ %d --" % _fails)
