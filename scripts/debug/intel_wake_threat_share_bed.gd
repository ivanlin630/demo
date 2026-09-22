extends SceneTree
# @bed-kind: diagnostic
# slice: DIAG 票 §4 第 0 步 —— ★量 `intel_arrived` 裡的【威脅佔比 f】
#
# ★★★我【不定義威脅】：定義是 systems 的欄。本床印【定義無關的交叉表】，
#   f ＝ systems 挑哪些格子加總 ÷ 全部。★若我自己先挑一組，f 就變成我選的數字。
# ★★感知鐵律（票 §3）：分類只讀【觀察者自己的】信念與位置 ——
#   判準句「如果這隊其實被騙了，這個分類會不會跟著錯？」⇒ **會**（它讀的是 belief，不是真值）。
#   ★而既有的 `ThreatAssessment.score()` 吃 `other: TeamData` ＝ god-view ⇒ 本 tap 沒有用它。
# ★★★母體對齊：emit 只在 `fields.has("tile_pos")` 且（首見 or 位置變）時發生
#   ⇒ **5386 次全部是位置情報** ⇒ 威脅不可能用「欄位型別」切，只能用距離／敵意切。
#
# env：IW_DAYS（預設 12）／IW_SEED（預設 1337）／IW_CONFIG（預設 warring_states）

func _initialize() -> void:
	var days: int = int(OS.get_environment("IW_DAYS")) if OS.has_environment("IW_DAYS") else 12
	var sd: int = int(OS.get_environment("IW_SEED")) if OS.has_environment("IW_SEED") else 1337
	var cfg: String = OS.get_environment("IW_CONFIG") if OS.has_environment("IW_CONFIG") else "warring_states"
	print("=== intel_arrived 的威脅佔比 f（days=%d seed=%d config=%s）===" % [days, sd, cfg])
	var fail: int = 0
	var cells: int = 0

	seed(sd)
	Probe.reset(); Probe.arm()
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg)
	var runner := SimRunner.new()
	for _t in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(st, Vector2i(-1, -1))

	var all: int = int(Probe.counts.get("intelwake.f.all", 0))
	var emit_all: int = int(Probe.counts.get("t0.emit.intel_arrived", 0))
	print("\n[IW] ★母體：tap 記到 %d 次｜既有 `t0.emit.intel_arrived` ＝ %d 次" % [all, emit_all])
	print("[IW]   ★★兩個數字必須相等（同一個 emit 點）⇒ %s" % ("一致 ✔" if all == emit_all else "★不一致 ✘"))
	if all != emit_all:
		push_error("[IW][FAIL] tap 母體 %d ≠ emit 母體 %d ⇒ 我的 tap 與 emit 不是同一個母體" % [all, emit_all])
		fail += 1
	if all == 0:
		push_error("[IW][不可判] 母體 0 ⇒ tap 沒接上（不是世界沒有情報）")
		quit(2)
		return
	cells += 1

	_axis("距離帶（觀察者自己的位置 vs 剛學到的目標位置）", "intelwake.f.dist.",
		["d0", "d1", "d2_3", "d4_6", "d7p"], all)
	_axis("敵意（觀察者的 known_reputations，★belief 非真值）", "intelwake.f.rep.",
		["hostile", "nonhostile"], all)
	_axis("種類", "intelwake.f.kind.", ["first_seen", "moved"], all)
	cells += 1

	print("\n[IW] ★★★交叉表（敵意 × 距離）—— ★f 由 systems 挑格子加總，我不挑")
	print("[IW] %-12s %10s %10s %10s %10s %10s %10s" % ["敵意", "d0", "d1", "d2_3", "d4_6", "d7p", "小計"])
	for h in ["hostile", "nonhostile"]:
		var row: String = ""
		var sub: int = 0
		for d in ["d0", "d1", "d2_3", "d4_6", "d7p"]:
			var v: int = int(Probe.counts.get("intelwake.f.x." + h + "." + d, 0))
			sub += v
			row += "%10d " % v
		print("[IW] %-12s %s%10d" % [h, row, sub])
	cells += 1

	# ★把「f 若這樣定」的幾個候選值一次印出來 —— ★★它們是【候選】不是【我的選擇】
	var hostile_all: int = int(Probe.counts.get("intelwake.f.rep.hostile", 0))
	var near3: int = 0
	var host_near3: int = 0
	for d2 in ["d0", "d1", "d2_3"]:
		near3 += int(Probe.counts.get("intelwake.f.dist." + d2, 0))
		host_near3 += int(Probe.counts.get("intelwake.f.x.hostile." + d2, 0))
	print("\n[IW] ★候選 f（★★三個都印，★★★systems 挑哪一個是 systems 的事）：")
	print("[IW]   f(敵意)            = %.4f（%d／%d）" % [float(hostile_all) / float(all), hostile_all, all])
	print("[IW]   f(距離≤3)          = %.4f（%d／%d）" % [float(near3) / float(all), near3, all])
	print("[IW]   f(敵意 且 距離≤3)  = %.4f（%d／%d）" % [float(host_near3) / float(all), host_near3, all])
	print("[IW]   ★票 §4 的門檻：**f > 0.6 ⇒ 回報不做**（而哪個 f 才算數，是定義問題不是量測問題）")
	cells += 1

	print("\n[誠實限] ①本床不判威脅,只給維度；★定義換一個,f 就換一個")
	print("[誠實限] ②距離用【觀察者剛學到的位置】算 ⇒ 若情報是舊的/被扭曲的,這裡也跟著錯（★那是對的）")
	print("[誠實限] ③母體＝emit 次數,不是【被喚醒的隊數】（一次 emit 只一個 subject,但隊可能已在 pending）")
	print("=== intel_wake_threat_share DONE（fail=%d｜到場點名 %d／4）===" % [fail, cells])
	if cells != 4:
		push_error("[FAIL] 到場點名 %d／4 ⇒ 有格沒跑到" % cells)
		fail += 1
	quit(1 if fail > 0 else 0)

func _axis(title: String, prefix: String, keys: Array, total: int) -> void:
	print("\n[IW] %s" % title)
	var sum: int = 0
	for k in keys:
		var v: int = int(Probe.counts.get(prefix + String(k), 0))
		sum += v
		print("[IW]   %-12s %10d  %6.2f%%" % [String(k), v, 100.0 * float(v) / float(maxi(total, 1))])
	print("[IW]   %-12s %10d  ← ★軸小計必須等於母體 %d ⇒ %s" % [
		"小計", sum, total, "✔" if sum == total else "★✘（有值落在我列的格子之外）"])
