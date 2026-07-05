extends SceneTree

# 序6 baseline 暫時 bed（Task 0）：量 V2-cmd shadow + 成員 raid 缺。
# WarringHarness.run 內部 Probe.enabled → 跑完 counts 保留。跑後刪除此檔。
func _initialize() -> void:
	WarringHarness.run(1337, 1200)
	var elig: int = int(Probe.counts.get("conq.member_atk_eligible", 0))
	var disp: int = int(Probe.counts.get("conq.member_atk_dispatch", 0))
	var mtrade: int = int(Probe.counts.get("trade.dispatch.member_trade", 0))
	var w_loot: int = int(Probe.counts.get("conq.winner_loot", 0))
	var w_prosp: int = int(Probe.counts.get("conq.winner_prosperity", 0))
	var w_other: int = int(Probe.counts.get("conq.winner_other", 0))
	var w_none: int = int(Probe.counts.get("conq.winner_none", 0))
	var occ: int = int(Probe.counts.get("occupy.dispatch", 0))
	print("=== BASELINE dispatch measure (seed=1337 t=1200) ===")
	print("[V2-cmd shadow] conq.member_atk_eligible=%d conq.member_atk_dispatch=%d (eligible>0 & dispatch≈0 = shadow 確證)" % [elig, disp])
	print("[member raid]   trade.dispatch.member_trade=%d" % mtrade)
	print("[unified winner] loot=%d prosperity=%d other=%d none=%d" % [w_loot, w_prosp, w_other, w_none])
	print("[occupy] occupy.dispatch=%d" % occ)
	quit()
