extends SceneTree
# @bed-kind: invariant
# slice: 觀測雜訊決定性化（窗 #2）—— spec: docs/superpowers/specs/2026-09-22-deterministic-observation-noise-HOW.md
#
# ★★★這幾格要【一起判】—— 單看任何一格都可能被騙過（spec §3 明句）：
#   ★2-a 對【不隨輸入變】的壞實作是【平凡通過】（任何輸入都同值 ⇒ 同 tick 同 pair 當然同值）
#   ★★所以 2-h（同 tick 不同 pair 不得全同）與 2-d'（短 lag 不得重複）是 2-a 的配對格
#   ★★★而 2-f（世界會變一次）不在這支床裡：它需要【修法前】的樹，見 world_fp_snapshot_bed.gd
#
# ★誠實限：
#   ①本床驗的是【雜訊函式本身】與【它有沒有耗 global RNG】；
#     「決策因此變得自洽」這件事本床【不驗】—— 那是 2-f 與世界跑的事。
#   ②2-b 用的是「呼叫前後 global RNG 的下一個取值是否相同」——
#     ★它證明的是【這條路上沒有抽】，不是【全世界沒有抽】。

var _fail: int = 0
var _cells: Array = []
const EXPECT_CELLS: int = 6   # ★常數期望；少跑一格就對不上

func _initialize() -> void:
	_run()
	print("[DETNOISE] 到場點名 %d／%d" % [_cells.size(), EXPECT_CELLS])
	if _cells.size() != EXPECT_CELLS:
		push_error("[FAIL] 到場點名 %d／%d —— 有格沒跑完" % [_cells.size(), EXPECT_CELLS])
		_fail += 1
	print("=== deterministic_observation_noise DONE（fail=%d｜到場點名 %d／%d）===" % [
		_fail, _cells.size(), EXPECT_CELLS])
	quit(1 if _fail > 0 else 0)

func _run() -> void:
	print("=== 決定性觀測雜訊：驗收床 ===")

	# ── ★跨語言釘值：證明 GDScript 的 64 位環繞與設計時的假設【一致】 ──
	#   ★★這三個值是設計階段用另一個語言的鏡像算出來的（Python，逐位元同式）。
	#     若 GDScript 的乘法環繞／位移語意與假設不同 ⇒ ★這一格會紅，
	#     而不是【安靜地給出另一種分佈】。
	var pinned: Array = [
		[0, 0, 0, 143255255356412],
		[1, 2, 3, 1347482596624011],
		[123456, 7, 11, 5597920077883298],
	]
	var pin_ok: int = 0
	for row in pinned:
		var got: int = int(PathSystem.observation_noise01(row[0], row[1], row[2]) * 9007199254740992.0)
		if got == int(row[3]): pin_ok += 1
		else: push_error("[FAIL][釘值] (%d,%d,%d) 期望 raw53=%d 實得 %d" % [row[0], row[1], row[2], row[3], got])
	print("[DETNOISE] 跨語言釘值 %d／3" % pin_ok)
	if pin_ok != 3: _fail += 1
	_cells.append("pinned")

	# ── 2-a：同 tick ＋ 同 pair ⇒ 逐字相同 ──
	var a1: float = PathSystem.observation_noise01(4242, 5, 9)
	var a2: float = PathSystem.observation_noise01(4242, 5, 9)
	print("[DETNOISE] 2-a 同 tick 同 pair 兩次：%.17f vs %.17f" % [a1, a2])
	if a1 != a2:
		push_error("[FAIL] 2-a 同 tick 同 pair 兩次不同 ⇒ 病沒解到")
		_fail += 1
	_cells.append("2-a")

	# ── 2-b：這條路上不耗 global RNG ──
	#   ★做法：同一個 seed 下，「不呼叫」與「呼叫 500 次」之後的下一個 randf() 必須相同。
	seed(777)
	var ctrl: float = randf()
	seed(777)
	for i in range(500):
		PathSystem.observation_noise01(i, i % 7, i % 13)
	var after: float = randf()
	print("[DETNOISE] 2-b 對照 randf=%.17f｜呼叫 500 次後 randf=%.17f" % [ctrl, after])
	if ctrl != after:
		push_error("[FAIL] 2-b 雜訊函式仍在耗 global RNG（500 次呼叫改變了序列）")
		_fail += 1
	_cells.append("2-b")

	# ── 2-d'：短 lag 精確不重複（逐點斷言，不是機率檢定）──
	var lags: Array = [1, 2, 3, 5, 8]
	var dup: int = 0
	var checked: int = 0
	for k in lags:
		for t in range(0, 4000):
			checked += 1
			if PathSystem.observation_noise01(t, 3, 7) == PathSystem.observation_noise01(t + int(k), 3, 7):
				dup += 1
				if dup <= 3: push_error("[FAIL] 2-d' tick=%d 與 tick+%d 同值" % [t, int(k)])
	print("[DETNOISE] 2-d' 母體 %d 組（5 個 lag × 4000 tick）｜相等 %d 組" % [checked, dup])
	if dup > 0: _fail += 1
	_cells.append("2-d'")

	# ── 2-h：同一 tick 內、不同 pair 不得全相同（母體要印）──
	#   ★這一格擋的是「雜湊只吃 tick」那種退化 —— 而那種實作會讓 2-a【平凡通過】。
	var seen: Dictionary = {}
	var pairs: int = 0
	for oa in range(40):
		for tb in range(40):
			if oa == tb: continue
			pairs += 1
			seen[PathSystem.observation_noise01(31337, oa, tb)] = true
	print("[DETNOISE] 2-h 同一 tick：%d 個 pair ⇒ %d 個相異值" % [pairs, seen.size()])
	if seen.size() <= 1:
		push_error("[FAIL] 2-h 同一 tick 內所有 pair 同值 ⇒ 雜湊沒吃 pair")
		_fail += 1
	_cells.append("2-h")

	# ── 2-d：分佈健檢 ＋ 不得隨 team_id 單調 ──
	var xs: Array = []
	for t in range(200):
		for oa in range(12):
			for tb in range(12):
				if oa != tb: xs.append(PathSystem.observation_noise01(t, oa, tb))
	xs.sort()
	var n: int = xs.size()
	var sum_v: float = 0.0
	for v in xs: sum_v += float(v)
	print("[DETNOISE] 2-d n=%d min=%.4f p25=%.4f med=%.4f p75=%.4f max=%.4f mean=%.4f" % [
		n, float(xs[0]), float(xs[n / 4]), float(xs[n / 2]), float(xs[3 * n / 4]), float(xs[n - 1]), sum_v / float(n)])
	# 單調性：固定 tick／observer，target_id 遞增 50 步，數上升步數（單調 ⇒ 0 或 49）
	var ups: int = 0
	var prev: float = PathSystem.observation_noise01(500, 2, 0)
	for b in range(1, 50):
		var cur: float = PathSystem.observation_noise01(500, 2, b)
		if cur > prev: ups += 1
		prev = cur
	print("[DETNOISE] 2-d 單調檢查：target_id 遞增 50 步中上升 %d 步（單調＝0 或 49）" % ups)
	if ups == 0 or ups == 49:
		push_error("[FAIL] 2-d 值隨 team_id 單調 ⇒ 結構性偏差，雜湊選錯")
		_fail += 1
	if sum_v / float(n) < 0.45 or sum_v / float(n) > 0.55:
		push_error("[FAIL] 2-d 平均 %.4f 偏離 0.5 太多 ⇒ 分佈不均" % (sum_v / float(n)))
		_fail += 1
	_cells.append("2-d")
