extends SceneTree
# @observe-pure
# ★★★A#14 驗收③④：**觀測不得改變被觀測物**（systems 2026-09-02）
#   ①tracer 開 / 關，跑同一個世界 ⇒ ★三把尺三跑必須逐位元相同
#   ②★而【不要只用 state_fingerprint】：它排除 ephemeral/cadence 欄，對這類污染 structurally 瞎眼
#   ③★★所以三把一起報：fp（決策/生命週期）＋ ephemeral（快取/排程）＋ ★★★full（反射掃全部屬性）

func _run_once(tracer_on: bool, days: int) -> Dictionary:
	var state := MeasureBedHelper.arm_and_setup("res://config/peaceful_economy.json", true)
	seed(1337)
	SpecimenTracer.reset()
	if tracer_on:
		var ids: Array = state.teams.keys(); ids.sort()
		state.specimen_team_ids = [int(ids[0])] if not ids.is_empty() else []
		SpecimenTracer.enabled = true
	var runner := SimRunner.new()
	for d in range(days):
		for _t in range(WorldState.TICKS_PER_DAY):
			runner.advance_tick(state, Vector2i(-1, -1))
	return {
		"fp": StateFingerprint.compute(state),
		"eph": EphemeralStateHash.compute(state),
		"full": FullStateHash.compute(state),
		"entries": SpecimenTracer.entries.size(),
		"deaths": SpecimenTracer.death_count,
	}

func _init() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 10
	print("=== A#14 觀測純度（tracer on/off × 三把尺）｜days=%d ===" % days)
	print(EphemeralStateHash.note())
	print(FullStateHash.note())
	var off1 := _run_once(false, days)
	var on1  := _run_once(true,  days)
	var off2 := _run_once(false, days)
	var fail := 0
	for k in ["fp", "eph", "full"]:
		var same_off: bool = off1[k] == off2[k]
		var on_matches: bool = on1[k] == off1[k]
		print("  %-5s  off=%s  on=%s  off2=%s" % [k, String(off1[k]).substr(0,10),
			String(on1[k]).substr(0,10), String(off2[k]).substr(0,10)])
		if not same_off:
			fail += 1; print("    ★FAIL 決定性本身就破了（off 兩跑不同）⇒ ★★這時 on/off 比較【沒有意義】")
		elif not on_matches:
			fail += 1; print("    ★★★FAIL 開 tracer 改變了世界（這一把尺看得到）")
		else:
			print("    PASS 三跑一致")
	print("  tracer on：entries=%d deaths=%d（★證 tracer 真的在跑，不是被關著才「無污染」）"
		% [on1["entries"], on1["deaths"]])
	if int(on1["entries"]) == 0:
		fail += 1
		print("    ★FAIL tracer 開著卻 0 筆 ⇒ 上面的「無污染」是【假綠】（它根本沒動）")
	print("ALL PASS" if fail == 0 else "FAILS=%d" % fail)
	quit()
