extends SceneTree
# @bed-kind: invariant
# A3′ 普查（spec 2026-10-07-a3prime-claims-settle-when-owner-stands-on-the-market-HOW §2 P1／P5，唯讀、不改世界）
#
# P1 鑑別格：每 tick 末數「待領 amt>0 且 owner 隊正站在那一格」的 (隊, 格) 對 ⇒ 修後恆 0。
#   ★修前先量紅基線；修前也是 0 ⇒ 本格無鑑別力（印「無鑑別力」，回報，不硬過）。
# P5 守恆：帳本 claim_coin／claim_goods 的 delta 總和 ＝ Probe mkt.claim.taken_* 總和；
#   mkt.claim.added.* − mkt.claim.taken_* ＝ 期末仍掛著的 amt。
#
# 世界：①default.json seed 1337 30 天（觀察輪那個）②world-fp 那一趟（warring_states、seed 20260922、player_id=-1、20000 tick）
# ★Probe 會開（arm_and_setup）⇒ 世界不等於 fp 那一趟的逐 tick 軌跡（Probe.enabled 會改世界，修前就這樣）；
#   本普查只比修前修後同一支腳本。
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/a3prime_claim_census.gd

const WORLDS: Array = [
	{"name": "default", "cfg": "res://config/default.json", "seed": 1337, "ticks": 30 * 1440, "strip": false},
	{"name": "fp", "cfg": "res://config/warring_states.json", "seed": 20260922, "ticks": 20000, "strip": true},
]
const EPS: float = 0.001
var _red: int = 0
var _p1_total: int = 0


func _initialize() -> void:
	var sha := ""
	var out: Array = []
	OS.execute("git", ["rev-parse", "--short", "HEAD"], out)
	if out.size() > 0:
		sha = String(out[0]).strip_edges()
	print("[TREE] HEAD=%s" % sha)
	for w in WORLDS:
		_run(w)
	print("\n[A3P] P1 全部世界 (隊,格)-tick 合計 = %d ⇒ %s" % [_p1_total,
		"綠（恆 0）" if _p1_total == 0 else "★紅（修前基線就該是這個；修後不該）"])
	if _p1_total > 0:
		_red += 1
	print("\n=== a3prime_claim_census DONE === errors: %d" % _red)
	quit(0 if _red == 0 else 1)


func _run(w: Dictionary) -> void:
	print("\n########## %s seed=%d ticks=%d ##########" % [w["name"], int(w["seed"]), int(w["ticks"])])
	seed(int(w["seed"]))
	var ws: WorldState = MeasureBedHelper.arm_and_setup(String(w["cfg"]), bool(w["strip"]))
	var runner := SimRunner.new()
	WorldState.driver_ledger_enabled = true
	WorldState.clear_driver_ledger()
	var pair_ticks: int = 0
	var pairs: Dictionary = {}       # "team@tile" → {first, last, n, amt_max}
	var ledger_coin: float = 0.0
	var ledger_goods: float = 0.0
	for _i in range(int(w["ticks"])):
		runner.advance_tick(ws, Vector2i(-1, -1))
		if ws.encounter_active and ws.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(ws, "draw")
		for e in WorldState.driver_ledger:
			var r: String = String(e["reason"])
			if r == "claim_coin":
				ledger_coin += float(e["delta"])
			elif r == "claim_goods":
				ledger_goods += float(e["delta"])
		WorldState.clear_driver_ledger()
		var now: int = ws.world.current_tick
		for tk in ws.world.tiles:
			var tile: HexTileData = ws.world.tiles[tk]
			if tile.pending_claims.is_empty():
				continue
			var seen: Dictionary = {}
			for c in tile.pending_claims:
				var amt: float = float(c.get("amt", 0.0))
				var ot: int = int(c.get("owner_team", -1))
				if amt <= 0.0 or seen.has(ot) or not ws.is_live_team(ot):
					continue
				var t: TeamData = ws.teams[ot]
				if t.tile_pos != tile.tile_pos:
					continue
				seen[ot] = true
				pair_ticks += 1
				var key: String = "%d@%s" % [ot, str(tile.tile_pos)]
				var row: Dictionary = pairs.get(key, {"first": now, "last": now, "n": 0, "amt_max": 0.0,
					"task": String(t.current_task), "kind": String(c.get("kind", ""))})
				row["last"] = now
				row["n"] = int(row["n"]) + 1
				row["amt_max"] = maxf(float(row["amt_max"]), amt)
				pairs[key] = row
	WorldState.driver_ledger_enabled = false
	# 期末仍掛著的
	var left_coin: float = 0.0
	var left_goods: float = 0.0
	for tk2 in ws.world.tiles:
		for c2 in (ws.world.tiles[tk2] as HexTileData).pending_claims:
			if String(c2.get("kind", "")) == "coin":
				left_coin += float(c2.get("amt", 0.0))
			else:
				left_goods += float(c2.get("amt", 0.0))
	var add_coin: float = float(Probe.amounts.get("mkt.claim.added.coin", 0.0))
	var add_goods: float = float(Probe.amounts.get("mkt.claim.added.goods", 0.0))
	var tk_coin: float = float(Probe.amounts.get("mkt.claim.taken_coin", 0.0))
	var tk_goods: float = float(Probe.amounts.get("mkt.claim.taken_goods", 0.0))
	print("P1|%s (隊,格)-tick=%d｜不同 (隊,格)=%d" % [w["name"], pair_ticks, pairs.size()])
	var shown: int = 0
	for k in pairs.keys():
		if shown >= 12:
			break
		var rw: Dictionary = pairs[k]
		print("P1|  %s kind=%s task(首見)=%s tick %d..%d 次數 %d 最大額 %.2f" % [k, rw["kind"], rw["task"],
			int(rw["first"]), int(rw["last"]), int(rw["n"]), float(rw["amt_max"])])
		shown += 1
	_p1_total += pair_ticks
	print("P5|%s opened=%d merged=%d taken=%d（coin %d／goods %d）" % [w["name"], int(Probe.counts.get("mkt.claim.opened", 0)),
		int(Probe.counts.get("mkt.claim.merged", 0)), int(Probe.counts.get("mkt.claim.taken", 0)),
		int(Probe.counts.get("mkt.claim.taken.coin", 0)), int(Probe.counts.get("mkt.claim.taken.goods", 0))])
	print("P5|%s 帳本 claim_coin=%.3f vs taken_coin=%.3f｜claim_goods=%.3f vs taken_goods=%.3f" % [w["name"],
		ledger_coin, tk_coin, ledger_goods, tk_goods])
	print("P5|%s added−taken：coin %.3f−%.3f=%.3f vs 期末 %.3f｜goods %.3f−%.3f=%.3f vs 期末 %.3f" % [w["name"],
		add_coin, tk_coin, add_coin - tk_coin, left_coin, add_goods, tk_goods, add_goods - tk_goods, left_goods])
	var ok5: bool = absf(ledger_coin - tk_coin) < EPS and absf(ledger_goods - tk_goods) < EPS \
		and absf(add_coin - tk_coin - left_coin) < EPS and absf(add_goods - tk_goods - left_goods) < EPS
	print("P5|%s ⇒ %s" % [w["name"], "PASS" if ok5 else "★FAIL"])
	if not ok5:
		_red += 1
