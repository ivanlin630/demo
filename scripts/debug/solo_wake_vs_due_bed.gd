extends SceneTree
# @bed-kind: diagnostic
# slice: `solo_think` 為什麼集中在 pass tick —— ★到期(due) vs 事件喚醒(woke)，逐 tick 類別
#
# ★★★背景（既有卷面）：`_step6b1_solo_think` 在 `% NEAR_CADENCE` 閘【外面】、每 tick 都跑，
#   相位也走 CadenceStagger ⇒ 到期時間本該散在 60 個 tick 上。
#   ★而量到的是：solo_think 的時間 **≥96% 落在 pass tick 上**
#     （pass 129.1M us｜而【全部】非 pass tick 的總時間上限只有 5.3M us）。
# ★★這一床不解釋，只把【誰讓它跑起來】數清楚：due_only／woke_only／both／skip × pass／nonpass。
# ★★★母體完整：tap 掛在 `continue` 之前 ⇒ skip 也有數 ⇒ 比率有分母。
#
# env：SW_DAYS（預設 12）／SW_SEED（預設 1337）／SW_CONFIG（預設 warring_states）

func _initialize() -> void:
	var days: int = int(OS.get_environment("SW_DAYS")) if OS.has_environment("SW_DAYS") else 12
	var sd: int = int(OS.get_environment("SW_SEED")) if OS.has_environment("SW_SEED") else 1337
	var cfg: String = OS.get_environment("SW_CONFIG") if OS.has_environment("SW_CONFIG") else "warring_states"
	print("=== solo_think：到期 vs 事件喚醒（days=%d seed=%d config=%s）===" % [days, sd, cfg])
	var fail: int = 0
	var cells: int = 0

	seed(sd)
	Probe.reset(); Probe.arm()
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg)
	var runner := SimRunner.new()
	for _t in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(st, Vector2i(-1, -1))

	var kinds: Array = ["due_only", "woke_only", "both", "skip"]
	var tot: Dictionary = {"pass": 0, "nonpass": 0}
	print("\n[SW] %-12s %14s %14s %12s" % ["類別", "pass tick", "非 pass tick", "pass 佔比"])
	for k in kinds:
		var a: int = int(Probe.counts.get("solo.fire.%s.pass" % k, 0))
		var b: int = int(Probe.counts.get("solo.fire.%s.nonpass" % k, 0))
		tot["pass"] = int(tot["pass"]) + a
		tot["nonpass"] = int(tot["nonpass"]) + b
		print("[SW] %-12s %14d %14d %11.2f%%" % [String(k), a, b, 100.0 * float(a) / float(maxi(a + b, 1))])
	print("[SW] %-12s %14d %14d ← ★母體（含 skip ⇒ 比率有分母）" % ["合計", int(tot["pass"]), int(tot["nonpass"])])
	if int(tot["pass"]) + int(tot["nonpass"]) == 0:
		push_error("[SW][不可判] 母體 0 ⇒ tap 沒接上（不是世界沒跑 solo_think）")
		quit(2)
		return
	cells += 1

	# ★真正跑起來的（排除 skip）＝ due_only + woke_only + both
	var fp: int = 0
	var fn: int = 0
	for k2 in ["due_only", "woke_only", "both"]:
		fp += int(Probe.counts.get("solo.fire.%s.pass" % k2, 0))
		fn += int(Probe.counts.get("solo.fire.%s.nonpass" % k2, 0))
	print("\n[SW] ★真正往下跑思考的次數：pass %d ／ 非 pass %d ⇒ pass 佔 %.2f%%" % [
		fp, fn, 100.0 * float(fp) / float(maxi(fp + fn, 1))])
	print("[SW]   ★★對照：pass tick 只佔全部 tick 的 %.2f%%（1／%d）" % [
		100.0 / float(SimRunner.NEAR_CADENCE), SimRunner.NEAR_CADENCE])
	print("[SW]   ★★★若兩者接近 ⇒ 沒有集中；若 pass 佔比遠高 ⇒ 集中,而【誰造成的】看上表")
	cells += 1

	# ★喚醒來源（★清單從 Probe.counts 現場掃，不手抄）
	var srcs: Dictionary = {}
	for key in Probe.counts.keys():
		var s2: String = String(key)
		if not s2.begins_with("solo.wake.src."): continue
		var rest: String = s2.substr("solo.wake.src.".length())
		var pc: String = "pass" if rest.ends_with(".pass") else "nonpass"
		var nm: String = rest.substr(0, rest.length() - (pc.length() + 1))
		if not srcs.has(nm): srcs[nm] = {"pass": 0, "nonpass": 0}
		srcs[nm][pc] = int(srcs[nm][pc]) + int(Probe.counts[key])
	var sk: Array = srcs.keys()
	# ★攤平成單一鍵再排序：★★GDScript 的 lambda 不吃跨行運算式（我第一版就是這樣 parse error）
	var stot: Dictionary = {}
	for s4 in srcs: stot[s4] = int(srcs[s4]["pass"]) + int(srcs[s4]["nonpass"])
	sk.sort_custom(func(a2, b2): return int(stot[a2]) > int(stot[b2]))
	print("
[SW] pending_source 的回傳值（★★★它【不是】語意來源:world_events.gd:100 恆回 cur）（現場掃 ⇒ %d 種）" % sk.size())
	print("[SW] %-28s %12s %12s %11s" % ["來源", "pass", "非 pass", "pass 佔比"])
	for s3 in sk:
		var a3: int = int(srcs[s3]["pass"])
		var b3: int = int(srcs[s3]["nonpass"])
		print("[SW] %-28s %12d %12d %10.2f%%" % [String(s3), a3, b3,
			100.0 * float(a3) / float(maxi(a3 + b3, 1))])
	if sk.is_empty():
		print("[SW] ★沒有任何喚醒來源被記到 ⇒ ★★`_woke` 從來沒有為真（那也是一個答案）")
	cells += 1
	cells += 1

	# ── ★★★真正的「誰叫醒的」：emit 端的 kind（`t0.emit.<kind>` 早就在數,我只補了 pass 這一維）──
	#   ★`pending_source` 回 "cur" 只說「它在集合裡」,說不出【誰放進去的】
	#     ⇒ ★★要答「pass 產生事件」這個假設,必須看 emit 端。
	var ek: Dictionary = {}
	for key2 in Probe.counts.keys():
		var s5: String = String(key2)
		if not s5.begins_with("t0.emit."): continue
		var pc2: String = ""
		if s5.ends_with(".pass"): pc2 = "pass"
		elif s5.ends_with(".nonpass"): pc2 = "nonpass"
		else: continue
		var kd: String = s5.substr(8, s5.length() - 8 - (pc2.length() + 1))
		if not ek.has(kd): ek[kd] = {"pass": 0, "nonpass": 0}
		ek[kd][pc2] = int(ek[kd][pc2]) + int(Probe.counts[key2])
	var ekk: Array = ek.keys()
	var ektot: Dictionary = {}
	for k5 in ek: ektot[k5] = int(ek[k5]["pass"]) + int(ek[k5]["nonpass"])
	ekk.sort_custom(func(a5, b5): return int(ektot[a5]) > int(ektot[b5]))
	print("
[SW] ★★★emit 端：哪一種事件、落在哪一類 tick（%d 種）" % ekk.size())
	print("[SW] %-30s %12s %12s %11s" % ["事件 kind", "pass", "非 pass", "pass 佔比"])
	for k6 in ekk:
		var ap: int = int(ek[k6]["pass"])
		var an: int = int(ek[k6]["nonpass"])
		print("[SW] %-30s %12d %12d %10.2f%%" % [String(k6), ap, an,
			100.0 * float(ap) / float(maxi(ap + an, 1))])
	if ekk.is_empty():
		push_error("[SW][不可判] emit 端一筆都沒有 ⇒ tap 沒接上(不是世界沒發事件)")
		fail += 1

	print("\n[誠實限] ①本床只數【次數】不數時間 ⇒ 「哪一類比較貴」要配相位卷面一起看")
	print("[誠實限] ②`skip` ＝ 該 tick 檢查過但不跑；它在母體裡,不在「真正跑」那一欄")
	print("=== solo_wake_vs_due DONE（fail=%d｜到場點名 %d／4）===" % [fail, cells])
	if cells != 4:
		push_error("[FAIL] 到場點名 %d／4 ⇒ 有格沒跑到" % cells)
		fail += 1
	quit(1 if fail > 0 else 0)
