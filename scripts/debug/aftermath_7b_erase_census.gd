extends SceneTree
# @bed-kind: diagnostic
# slice: 7b 戰後處置過渡（spec 2026-10-16-aftermath-disposition-transition-7b-HOW §驗收 B4／B5）——四條 erase 路有沒有走到、走到時有沒有留下懸空活人
# ★不判綠紅、只印數。兩層 × 3 seed × 30 天（預設 config）：①無玩家世界 ②有玩家世界。
# ★每天收尾掃一次 InvariantAudit，數「懸空」違規（7b §四 新判準）；每個世界末尾印既有計數：
#   滅團＝extinct.team.*（鍵數＝滅了幾隊）、批次＝erase.batches／erase.teams_erased、res.seen／res.npc_massacre／res.npc_force。
#   子隊併回＝「[Merge] 完全合併」行數、獸隊＝「[BeastHunt]」行數：這兩條沒有計數鍵，數本檔輸出（每個世界前後印分隔行，事後 grep 分段）。
# ★掃稽核只讀 state，不耗 RNG、不改被觀測物。

const SEEDS: Array = [1337, 2026, 777]
const DAYS: int = 30

func _initialize() -> void:
	print("=== aftermath_7b_erase census ｜ %d seed × %d 天 × 兩層 ===" % [SEEDS.size(), DAYS])
	for strip in [true, false]:
		for sd in SEEDS:
			print("@@WORLD-BEGIN layer=%s seed=%d" % ["noplayer" if strip else "player", sd])
			seed(sd)
			var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/default.json", strip)
			var runner := SimRunner.new()
			var dangling_days: int = 0
			var dangling_max: int = 0
			var samples: Array = []
			var end_tick: int = st.world.current_tick + DAYS * WorldState.TICKS_PER_DAY
			while st.world.current_tick < end_tick:
				runner.advance_tick(st, Vector2i(-1, -1))
				if st.world.current_tick % WorldState.TICKS_PER_DAY != 0:
					continue
				var v: Array = InvariantAudit.check(st).filter(func(s): return String(s).contains("懸空"))
				if not v.is_empty():
					dangling_days += 1
					dangling_max = maxi(dangling_max, v.size())
					if samples.size() < 5:
						samples.append("day%d:%s" % [st.world.current_tick / WorldState.TICKS_PER_DAY, str(v.slice(0, 3))])
			var ext: int = 0
			for k in Probe.counts.keys():
				if String(k).begins_with("extinct.team."):
					ext += 1
			print("@@WORLD-END layer=%s seed=%d｜tick %d｜懸空：有違規的天 %d、單日最多 %d 筆 %s" % [
				"noplayer" if strip else "player", sd, st.world.current_tick, dangling_days, dangling_max, str(samples)])
			print("   滅團 extinct.team.* 鍵數 %d｜erase.batches=%d erase.teams_erased=%.0f｜res.seen=%d res.npc_massacre=%d res.npc_force=%d" % [
				ext, int(Probe.counts.get("erase.batches", 0)), float(Probe.amounts.get("erase.teams_erased", 0.0)),
				int(Probe.counts.get("res.seen", 0)), int(Probe.counts.get("res.npc_massacre", 0)), int(Probe.counts.get("res.npc_force", 0))])
	print("=== aftermath_7b_erase census DONE ===")
	quit()
