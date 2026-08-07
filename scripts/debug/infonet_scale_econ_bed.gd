extends SceneTree

# [measurer持久fixture 2026-08-07] 規模經濟力底查(measure-first,code零改純讀)。
# spec:docs/superpowers/specs/2026-08-07-scale-economy-baseline-measure-HOW.md
# CONCENTRATED(1大據點pop24) vs DISPERSED(4小據點pop6×4,同總量)——同seed同ticks,
# reuse WarringHarness.run(config-agnostic)+自建generic per-scenario淨值帳dump
# (labor pool/manufacture output/convoy負擔/facility level distribution)。
# Tier1短跑(~3月)快看gradient方向。

const SEED: int = 8181
const MONTHS: int = 3
const CONCENTRATED_CONFIG := "res://config/infonet_scale_econ_concentrated.json"
const DISPERSED_CONFIG := "res://config/infonet_scale_econ_dispersed.json"

func _initialize() -> void:
	var ticks: int = WorldState.TICKS_PER_MONTH * MONTHS
	print("=== 規模經濟力底查(Tier1,seed=%d %d月) ===" % [SEED, ticks / WorldState.TICKS_PER_MONTH])

	print("\n########## CONCENTRATED(1大據點pop24) ##########")
	var rc: Dictionary = WarringHarness.run(SEED, ticks, CONCENTRATED_CONFIG)
	_report("CONCENTRATED", rc)

	print("\n########## DISPERSED(4小據點pop6×4) ##########")
	var rd: Dictionary = WarringHarness.run(SEED, ticks, DISPERSED_CONFIG)
	_report("DISPERSED", rd)

	print("\n───────── 淨值 gradient 對照 ─────────")
	_compare(rc, rd)

	var dump: Dictionary = {
		"diagnostic": "規模經濟力底查(concentrated vs dispersed, ex-ante見spec)",
		"concentrated": _extract(rc), "dispersed": _extract(rd),
	}
	var f := FileAccess.open("res://docs/measurements/2026-08-07-infonet-scale-econ-baseline.json", FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(dump, "  ")); f.close()
		print("\n[dump] → res://docs/measurements/2026-08-07-infonet-scale-econ-baseline.json")
	print("=== DONE ===")
	quit()

func _report(label: String, result: Dictionary) -> void:
	if result.is_empty():
		print("[FAIL] %s WarringHarness.run 回空" % label); return
	var p: Dictionary = result.get("probe", {})
	var pa: Dictionary = result.get("probe_amounts", {})
	print("final: teams=%d pop=%d attrition=%.1f%%" % [
		int(result.get("final", {}).get("teams", 0)), int(result.get("end_pop", 0)),
		float(result.get("attrition_pct", 0.0))])
	print("★好處側(A)：manufacture.fired=%d manufacture.noop_no_worker=%d manufacture.noop_no_material=%d manufacture.noop_no_facility=%d" % [
		int(p.get("manufacture.fired", 0)), int(p.get("manufacture.noop_no_worker", 0)),
		int(p.get("manufacture.noop_no_material", 0)), int(p.get("manufacture.noop_no_facility", 0))])
	print("construct.complete_upgrade_facility=%d construct.complete_upgrade_level=%d" % [
		int(p.get("construct.complete_upgrade_facility", 0)), int(p.get("construct.complete_upgrade_level", 0))])
	print("★運輸摩擦側(B)：convoy.dispatch=%d convoy.deliver=%d convoy.deliver_settled=%d convoy.return=%d" % [
		int(p.get("convoy.dispatch", 0)), int(p.get("convoy.deliver", 0)),
		int(p.get("convoy.deliver_settled", 0)), int(p.get("convoy.return", 0))])
	print("cargo_out=%.1f cargo_delivered=%.1f" % [
		float(pa.get("convoy.cargo_out", 0.0)), float(pa.get("convoy.cargo_delivered", 0.0))])
	print("trade.deal=%d g1.order_placed=%d g1.order_fulfilled=%d" % [
		int(p.get("trade.deal", 0)), int(p.get("g1.order_placed", 0)), int(p.get("g1.order_fulfilled", 0))])

func _extract(result: Dictionary) -> Dictionary:
	var p: Dictionary = result.get("probe", {})
	var pa: Dictionary = result.get("probe_amounts", {})
	return {
		"end_pop": result.get("end_pop", 0), "attrition_pct": result.get("attrition_pct", 0.0),
		"manufacture.fired": p.get("manufacture.fired", 0),
		"manufacture.noop_no_worker": p.get("manufacture.noop_no_worker", 0),
		"construct.complete_upgrade_facility": p.get("construct.complete_upgrade_facility", 0),
		"convoy.dispatch": p.get("convoy.dispatch", 0), "convoy.deliver_settled": p.get("convoy.deliver_settled", 0),
		"convoy.cargo_out": pa.get("convoy.cargo_out", 0.0), "convoy.cargo_delivered": pa.get("convoy.cargo_delivered", 0.0),
		"trade.deal": p.get("trade.deal", 0), "g1.order_fulfilled": p.get("g1.order_fulfilled", 0),
	}

func _compare(rc: Dictionary, rd: Dictionary) -> void:
	var ec: Dictionary = _extract(rc); var ed: Dictionary = _extract(rd)
	for k in ec:
		print("  %s: concentrated=%s dispersed=%s" % [k, str(ec[k]), str(ed[k])])
