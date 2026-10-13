extends SceneTree
# @bed-kind: diagnostic
# 附身隊後續 甲「殘單量測」（spec 2026-10-13-possessed-team-followups-HOW §甲）：
#   附身那一刻，隊上已有的 AI 單扣住了多少東西 ⇒ 任一資源 >20% ⇒ 改成附身時撤；≤20% ⇒ 不撤
#   ①開局附身（GameSetup 那一刻）：玩家隊的殘單數與押貨
#   ②中途附身的代理：同一世界第 5／10／20／30 天，對【每一支非玩家真隊】算「若此刻附身它」：
#      殘單數、各單貨量、押貨（market_escrow，owner_team＝該隊）÷（隊上持有＋押貨），food 另比 effective_food
#   ★只有寄賣（站在別隊據點掛賣單）才押貨；自家櫃檯與買單不扣東西 ⇒ 扣住比例只算押貨
#   ★誠實限：遭遇以 draw 結束（同乙量測）；中途附身用「每一支隊都當候選」代理，不是玩家真的會挑的那支
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/possessed_residual_orders_census.gd
#   env PRO_SEEDS（預設 "1337"）

const CHECK_DAYS: Array = [5, 10, 20, 30]
const LINE: float = 0.20

func _initialize() -> void:
	var seeds: Array = []
	for s in OS.get_environment("PRO_SEEDS").split(",", false):
		seeds.append(int(s))
	if seeds.is_empty():
		seeds = [1337]
	print("=== possessed_residual_orders_census：附身那一刻被 AI 單扣住的比例（線 %.0f%%）===" % (LINE * 100.0))
	var worst: float = 0.0
	for sd in seeds:
		worst = maxf(worst, _run(int(sd)))
	print("=== possessed_residual_orders_census DONE === 全部樣本最大扣住比例 %.1f%%（>%.0f%% ⇒ 附身時撤）" % [worst * 100.0, LINE * 100.0])
	quit(0)


func _escrow_of(st: WorldState, tid: int) -> Dictionary:
	var out: Dictionary = {}
	for k in st.world.tiles:   # gate-ok: 量測床全量母體
		var tile: HexTileData = st.world.tiles[k]
		for oid in tile.market_escrow:
			var e: Dictionary = tile.market_escrow[oid]
			if int(e.get("owner_team", -1)) == tid:
				var r: String = String(e.get("res", ""))
				out[r] = float(out.get(r, 0.0)) + float(e.get("qty", 0.0))
	return out


# 回 [比例最大值, 說明字串]
func _held_share(st: WorldState, t: TeamData) -> Array:
	var esc: Dictionary = _escrow_of(st, t.team_id)
	var mx: float = 0.0
	var parts: Array = []
	for r in esc:
		var q: float = float(esc[r])
		var denom: float = float(t.resources.get(r, 0.0)) + q
		if r == "food":
			denom = maxf(ResourceSystem.effective_food(st, t) + q, denom)
		var share: float = q / denom if denom > 0.0 else 0.0
		mx = maxf(mx, share)
		parts.append("%s %.0f/%.0f=%.0f%%" % [r, q, denom, share * 100.0])
	return [mx, ", ".join(parts)]


func _run(sd: int) -> float:
	seed(sd)
	var st := WorldState.new()
	GameSetup.setup(st, GameSetup.load_config("res://config/default.json"))
	var ptid: int = st.get_player_team_id()
	var pt: TeamData = st.teams[ptid]
	var h0: Array = _held_share(st, pt)
	print("\n── seed %d ──" % sd)
	print("   ①開局附身：玩家隊 T%d 殘單 %d 張｜押貨扣住最大 %.1f%% %s" % [ptid, pt.active_orders.size(), float(h0[0]) * 100.0, String(h0[1])])
	var worst: float = float(h0[0])
	var runner := SimRunner.new()
	var start: int = st.world.current_tick
	var enc: int = 0
	for day in CHECK_DAYS:
		while st.world.current_tick - start < int(day) * WorldState.TICKS_PER_DAY:
			var p: TeamData = st.teams.get(st.get_player_team_id())
			var res: String = runner.advance_tick(st, p.tile_pos if p != null else Vector2i(-1, -1))
			if st.encounter_active:
				enc += 1
				runner._encounter_system.resolve_encounter_end(st, "draw")
			if res == "awaiting_heir":
				print("   ★玩家戰死凍結於 tick %d ⇒ 之後的天數不量" % st.world.current_tick)
				return worst
		var n_team: int = 0
		var n_with: int = 0
		var n_orders: int = 0
		var n_esc_team: int = 0
		var over: Array = []
		var day_max: float = 0.0
		var day_max_desc: String = ""
		for tid in st.teams:
			var t: TeamData = st.teams[tid]
			if int(tid) == st.get_player_team_id() or t.leader_id == -1 or t.beast_kind != "":
				continue
			n_team += 1
			if t.active_orders.is_empty():
				continue
			n_with += 1
			n_orders += t.active_orders.size()
			var h: Array = _held_share(st, t)
			if String(h[1]) != "":
				n_esc_team += 1
			if float(h[0]) > day_max:
				day_max = float(h[0])
				day_max_desc = "T%d：%s｜單 %s" % [int(tid), String(h[1]), str(t.active_orders.map(func(o): return "%s %s×%d" % [o["kind"], o["res"], int(o["qty_remaining"])]))]
			if float(h[0]) > LINE:
				over.append(int(tid))
		worst = maxf(worst, day_max)
		print("   ②第 %d 天：候選隊 %d｜有殘單 %d（共 %d 張）｜有押貨 %d｜超過 %.0f%% 線 %d 隊 %s" % [int(day), n_team, n_with, n_orders,
			n_esc_team, LINE * 100.0, over.size(), str(over)])
		print("      最大扣住 %.1f%%：%s" % [day_max * 100.0, day_max_desc if day_max_desc != "" else "（沒有任何押貨）"])
	print("   遭遇 draw %d 次" % enc)
	return worst
