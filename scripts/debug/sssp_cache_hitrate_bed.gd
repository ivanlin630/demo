extends SceneTree
# @bed-kind: diagnostic
# slice: 驗收①（先量再改）：_sssp_cache 的命中率
#
# ★spec 明文：**若命中率其實很高 ⇒ 本票前提就錯了，停下來回報，不要硬改。**
# ★★推論（本床要驗）：from ＝ 隊【當下的位置】，而隊每 tick 都在動 ⇒ key 每次都新 ⇒ 命中率 ≈ 0。
# env：SC_TICKS（預設 20000）／SC_CONFIG（預設 warring_states）

func _initialize() -> void:
	var ticks: int = int(OS.get_environment("SC_TICKS")) if OS.has_environment("SC_TICKS") else 20000
	var cfg: String = OS.get_environment("SC_CONFIG") if OS.has_environment("SC_CONFIG") else "warring_states"
	print("=== _sssp_cache 命中率（%d tick ＝ %.1f 遊戲天，%s）===" % [
		ticks, float(ticks) / float(WorldState.TICKS_PER_DAY), cfg])
	Probe.arm()
	seed(4242)
	var st := WorldState.new()
	GameSetup.setup(st, GameSetup.load_config("res://config/%s.json" % cfg))
	st.player_id = -1
	var runner := SimRunner.new()
	for i in range(ticks):
		runner.advance_tick(st, Vector2i(-1, -1))
	var hit: int = int(Probe.counts.get("sssp.hit", 0))
	var miss: int = int(Probe.counts.get("sssp.miss", 0))
	var elig: int = 0
	for tid in st.teams:
		var t: TeamData = st.teams[tid]
		if t.beast_kind == "" and t.parent_team_id == -1 and t.faction_id == -1:
			elig += 1
	var total: int = hit + miss
	print("命中 %d／未命中 %d（共 %d 次 catch_cost）⇒ ★命中率 %.1f%%" % [
		hit, miss, total, 100.0 * float(hit) / maxf(1.0, float(total))])
	print("★★全圖 Dijkstra 次數 ＝ 未命中次數 ＝ %d（%.1f 次／tick）" % [miss, float(miss) / float(ticks)])
	print("★★★世界規模：隊 %d／走 solo 這條路的合格 N ＝ %d（★spec 要 N≥130，本窗到不了 ⇒ 誠實標明）" % [
		st.teams.size(), elig])
	if total == 0:
		print("★【不可判】：一次都沒呼叫到 catch_cost（母體地板）")
	elif float(hit) / float(total) > 0.5:
		print("★★★【前提錯了】命中率 > 50% ⇒ 本票不該硬改，停下來回報（spec 驗收①）")
	else:
		print("★前提成立：命中率低 ⇒ 快取【看起來在運作，實際上救不了】")
	print("=== DONE === SECTIONS=1/1 FAILS=0")
	quit()
