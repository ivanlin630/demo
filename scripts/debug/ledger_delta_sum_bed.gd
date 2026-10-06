extends SceneTree
# @bed-kind: invariant
# ══ 帳本守恆：每一個 (實體, 庫, 資源)，Σ(帳本 delta) ＝ 結束值 − 開始值 ═══════════════════════════════
# spec：`docs/superpowers/specs/2026-10-06-ledger-delta-must-sum-to-the-change-HOW.md` §2
#
# ★這一格**不需要知道有哪些寫入口**：任何一個不記帳、或記錯量的寫入口都會讓它紅（掛窄口＝不枚舉）
# ★實體 ＝ 隊（team.resources）／tile 公庫（public_storage，store=public）／tile 自然池（resources，store=pool）／人（person.coin）
# ★母體：開始與結束**都在**的實體（中途生滅的另外印數，不判 —— 新實體的初值不經帳本）
# 格：P1 守恆＋四支寫入口各 ≥1 次（0 次 ⇒ 紅，不准綠著略過）｜P2 ledger 開／關 fp 逐位相同｜P3 丟棄 ＝ 0（每 tick 清帳，印最早一筆 tick）

const CFG: String = "res://config/default.json"
const SEED: int = 1337
const TICKS: int = 3 * WorldState.TICKS_PER_DAY
const P2_TICKS: int = WorldState.TICKS_PER_DAY
const TOL: float = 0.01
const ENTRY_POINTS: Array = ["team_set_amt", "team_clear_all", "tile_set_amt", "tile_pool_set"]

var _errors: int = 0
var _cells_ran: Array = []
const EXPECTED_CELLS: Array = ["P1", "P1b", "P2", "P3"]


func _initialize() -> void:
	print("=== ledger_delta_sum：帳本 delta 加總 ＝ 資源變化 ===")
	_p1_p3()
	_p2_fp_unchanged()
	var missing: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(String(c)):
			missing.append(String(c))
	_check("★到場點名：%d／%d（缺：%s）" % [_cells_ran.size(), EXPECTED_CELLS.size(), str(missing)], missing.is_empty())
	print("\n=== ledger_delta_sum DONE === errors: %d" % _errors)
	quit(1 if _errors > 0 else 0)


func _check(msg: String, cond: bool) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_errors += 1
		push_error("[FAIL] " + msg)


# 實體 → 穩定鍵（帳本存的是物件本身）
static func _ekey(e) -> String:
	if e is TeamData:
		return "T%d" % (e as TeamData).team_id
	if e is HexTileData:
		var p: Vector2i = (e as HexTileData).tile_pos
		return "H%d,%d" % [p.x, p.y]
	if e is PersonData:
		return "P%d" % (e as PersonData).id
	return ""


# 全世界的 (實體鍵|庫|資源) → 值
static func _values(st: WorldState) -> Dictionary:
	var out: Dictionary = {}
	for tid in st.teams:
		var t: TeamData = st.teams[tid]
		for r in t.resources:
			out["%s|team|%s" % [_ekey(t), String(r)]] = float(t.resources[r])
	for k in st.world.tiles:
		var h: HexTileData = st.world.tiles[k]
		for r in h.public_storage:
			out["%s|public|%s" % [_ekey(h), String(r)]] = float(h.public_storage[r])
		for r in h.resources:
			out["%s|pool|%s" % [_ekey(h), String(r)]] = float(h.resources[r])
	for pid in st.persons:
		var p: PersonData = st.persons[pid]
		out["%s|person|coin" % _ekey(p)] = float(p.coin)
	return out


static func _entities(st: WorldState) -> Dictionary:
	var out: Dictionary = {}
	for tid in st.teams:
		out[_ekey(st.teams[tid])] = true
	for k in st.world.tiles:
		out[_ekey(st.world.tiles[k])] = true
	for pid in st.persons:
		out[_ekey(st.persons[pid])] = true
	return out


# 清帳一次：把現有的 resource 條目加進 sums，回最早一筆 tick（沒有 ⇒ -1）
static func _drain(sums: Dictionary) -> int:
	var first: int = -1
	for e in WorldState.driver_ledger:
		var row: Dictionary = e
		if String(row.get("kind", "")) != "resource":
			continue
		var ek: String = _ekey(row.get("entity"))
		if ek == "":
			continue
		var store: String = String(row.get("store", ""))
		if store == "":
			store = "person" if ek.begins_with("P") else "team"
		var key: String = "%s|%s|%s" % [ek, store, String(row.get("field", ""))]
		sums[key] = float(sums.get(key, 0.0)) + float(row.get("delta", 0.0))
		if first == -1:
			first = int(row.get("tick", -1))
	WorldState.clear_driver_ledger()
	return first


func _p1_p3() -> void:
	print("\n── P1 帳本守恆（%d tick ＝ %d 天，default seed %d）──" % [TICKS, TICKS / WorldState.TICKS_PER_DAY, SEED])
	seed(SEED)
	var st: WorldState = MeasureBedHelper.arm_and_setup(CFG, false)
	var runner := SimRunner.new()
	var dropped0: int = WorldState.driver_ledger_dropped
	WorldState.driver_ledger_enabled = true
	WorldState.clear_driver_ledger()
	var v0: Dictionary = _values(st)
	var ents0: Dictionary = _entities(st)
	var sums: Dictionary = {}
	var first_tick: int = -1
	for _i in range(TICKS):
		runner.advance_tick(st, Vector2i(-1, -1))
		var f: int = _drain(sums)
		if first_tick == -1:
			first_tick = f
	WorldState.driver_ledger_enabled = false
	var v1: Dictionary = _values(st)
	var ents1: Dictionary = _entities(st)
	var keys: Dictionary = {}
	for k in v0: keys[k] = true
	for k in v1: keys[k] = true
	for k in sums: keys[k] = true
	var judged: int = 0
	var skipped: int = 0
	var bad: Array = []
	for k in keys:
		var ek: String = String(k).split("|")[0]
		if not (ents0.has(ek) and ents1.has(ek)):
			skipped += 1
			continue
		judged += 1
		var change: float = float(v1.get(k, 0.0)) - float(v0.get(k, 0.0))
		var s: float = float(sums.get(k, 0.0))
		if absf(change - s) > TOL * maxf(1.0, absf(change)):
			bad.append([String(k), change, s])
	var by_store: Dictionary = {}
	for k in keys:
		var store: String = String(k).split("|")[1]
		by_store[store] = int(by_store.get(store, 0)) + 1
	print("   判了 %d 個 (實體,庫,資源)｜中途生滅不判 %d｜各庫：%s" % [judged, skipped, str(by_store)])
	bad.sort_custom(func(a, b): return absf(float(a[1]) - float(a[2])) > absf(float(b[1]) - float(b[2])))
	for b in bad.slice(0, 12):
		print("   ✗ %s：變化 %.3f／帳本 Σ %.3f（差 %.3f）" % [b[0], b[1], b[2], float(b[1]) - float(b[2])])
	var calls: Dictionary = {}
	for ep in ENTRY_POINTS:
		calls[ep] = int(Probe.counts.get("bank.call." + String(ep), 0))
	print("   寫入口被呼次數：%s" % str(calls))
	_check("★母體地板：判過的 (實體,庫,資源) ≥ 1（%d），且四個庫都有（%s）" % [judged, str(by_store.keys())],
		judged >= 1 and by_store.has("team") and by_store.has("public") and by_store.has("pool") and by_store.has("person"))
	for ep in ENTRY_POINTS:
		_check("★母體地板：%s 被呼過（%d 次）—— 0 次 ＝ 那一支沒被驗" % [ep, int(calls[ep])], int(calls[ep]) >= 1)
	_check("★★★P1 每一個 (實體,庫,資源)：Σ帳本 delta ＝ 結束 − 開始（不符 %d）" % bad.size(), bad.is_empty())
	_cells_ran.append("P1")
	_p1b_clear_all_on_living_team(st)
	print("\n── P3 環形緩衝 ──")
	var dropped: int = WorldState.driver_ledger_dropped - dropped0
	print("   每 tick 清帳｜cap %d｜最早一筆 tick %d｜這一段丟棄 %d" % [WorldState.driver_ledger_cap, first_tick, dropped])
	# ★最早一筆的 tick 是 `driver_tick_hint`（不是每 tick 更新的時鐘；實測第一筆印 60）⇒ 只要求它存在
	#   窗在 cap 內的真判準 ＝ 每 tick 清帳之下丟棄 ＝ 0（任何一個 tick 寫超過 cap 都會讓它 > 0）
	_check("P3 窗在 cap 內：丟棄 ＝ 0（%d），且帳本真的有寫（最早一筆 tick %d）" % [dropped, first_tick],
		dropped == 0 and first_tick >= 0)
	_cells_ran.append("P3")


func _p2_fp_unchanged() -> void:
	print("\n── P2 帳本開／關 ⇒ 同 seed 世界 fp 逐位相同（%d tick）──" % P2_TICKS)
	var fps: Array = []
	for on in [false, true]:
		seed(SEED)
		var st: WorldState = MeasureBedHelper.arm_and_setup(CFG, false)
		var runner := SimRunner.new()
		WorldState.driver_ledger_enabled = on
		WorldState.clear_driver_ledger()
		for _i in range(P2_TICKS):
			runner.advance_tick(st, Vector2i(-1, -1))
			if on:
				WorldState.clear_driver_ledger()
		WorldState.driver_ledger_enabled = false
		fps.append(StateFingerprint.compute(st))
	print("   關 %s｜開 %s" % [String(fps[0]).substr(0, 12), String(fps[1]).substr(0, 12)])
	_check("P2 帳本開／關 fp 相同", String(fps[0]) == String(fps[1]))
	_cells_ran.append("P2")


# ══ P1b：clear_all 在**活著的**隊上 ══════════════════════════════════════════════════════════════════
# ★為什麼要佈置（負對照實測）：把 clear_all 的逐資源記帳拿掉 ⇒ P1 照綠 ——
#   自然跑出來的 clear_all（3 天 2 次）都發生在**要消失的隊**上 ⇒ 那支隊開始在、結束不在 ⇒ 被「中途生滅不判」排除
#   ⇒ P1 的「team_clear_all 被呼過」地板是真的，但它驗不到 clear_all 的記帳
# ⇒ 這一格直接對一支活著的隊呼一次（同一個世界、跑完之後），Σ帳本 delta 必須 ＝ −舊值（逐資源）
func _p1b_clear_all_on_living_team(st: WorldState) -> void:
	print("\n── P1b clear_all 在活著的隊上：每一種資源 Σdelta ＝ −舊值 ──")
	var ids: Array = st.teams.keys()
	ids.sort()
	var t: TeamData = null
	for tid in ids:
		var c: TeamData = st.teams[tid]
		var nz: int = 0
		for r in c.resources:
			if float(c.resources[r]) != 0.0:
				nz += 1
		if nz >= 2:
			t = c
			break
	if t == null:
		_check("★P1b 母體地板：找得到一支至少兩種資源非 0 的活隊", false)
		_cells_ran.append("P1b")
		return
	var before: Dictionary = t.resources.duplicate()
	WorldState.driver_ledger_enabled = true
	WorldState.clear_driver_ledger()
	ResourceBank.clear_all(t, "bed_clear_all")
	var sums: Dictionary = {}
	_drain(sums)
	WorldState.driver_ledger_enabled = false
	var bad: Array = []
	var nonzero: int = 0
	for r in before:
		var old: float = float(before[r])
		if old != 0.0:
			nonzero += 1
		var s: float = float(sums.get("%s|team|%s" % [_ekey(t), String(r)], 0.0))
		if absf(s + old) > TOL * maxf(1.0, absf(old)):
			bad.append("%s 舊 %.2f／帳本 Σ %.2f" % [String(r), old, s])
	print("   Team%d：清掉 %d 種（非 0 的 %d 種）｜不符 %s" % [t.team_id, before.size(), nonzero, str(bad)])
	_check("★P1b 母體地板：清掉的資源裡非 0 的 ≥ 2（%d）" % nonzero, nonzero >= 2)
	_check("★★P1b clear_all：每一種資源 Σ帳本 delta ＝ −舊值（不符 %d）" % bad.size(), bad.is_empty())
	_cells_ran.append("P1b")
