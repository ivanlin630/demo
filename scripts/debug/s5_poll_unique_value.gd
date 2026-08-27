extends SceneTree
# @observe-pure
# ★★★輪詢的【獨特貢獻率】（blueprint 判準，systems 轉述時寫死了邊界）：
#   分母 = 【純 cadence 觸發】的重評次數（事件喚醒的不算 —— 要量的是【輪詢】的貢獻）
#   分子 = 其中【選出來的東西變了】的次數（★不是「跑了」，也不是「分數變了」）
#   第三類 = 【維持原選擇】（可能是「確認承諾」的貢獻，★獨立成欄，不併進分子）
#   ③成因 = 分子那批的 before→after 原文（★這一欄【就是】待補 T0 kind 的候選池）
#   ④延遲 = 那些【沒改變】的，若當時不跑，下一次事件喚醒在多久之後
#
# ★★★④為什麼非有不可（systems 加的，理由我照抄）：
#   「這次沒改變」≠「不跑也沒差」—— 改變可能只是【還沒到】，
#   而砍掉輪詢會讓它【晚很久】才發生。沒有這一欄，≈0 會被讀成「可以砍」，
#   ★而真相可能是「可以砍，但反應延遲會從小時級變成天級」。
#
# ★★★★⑤是我自己加的一欄，動機是【我自己驗收的盲點】：
#   S4b 的 210 格把 burst 注在 advance_tick【之前】⇒ 那些格子永遠看得到 pending。
#   ★它證的是【閘會不會醒】，★★不是【真 emit 站有沒有趕在消費者那一 pass 之前】。
#   而 pending_rethink 是【tick 結尾清空】⇒ 在消費者 pass【之後】才 emit 的，
#   ★★★會在被讀到前就被清掉。⇒ 這一欄把 t0.emit_at 跟 poll.eventwake 對接，
#   問「真 emit 到底叫醒了誰」。★這一欄可能會推翻 S4b 的一部分結論，那也要照印。
#
# ★判準（systems 寫死，我不改）：
#   ①分母 = 0 ⇒ 停，回報「這張床上輪詢根本沒觸發過」——不拿 0/0 當「≈0」
#   ②分子/分母 ≈ 0 且 ④延遲【小】 ⇒ 冗餘，可退場
#   ③分子 > 0 ⇒ 不退，③那欄的清單交 systems
#   ④分子 ≈ 0 但 ④延遲【大】 ⇒ 第三種結論：輪詢是【兜底的時效保證】

const SUPPORTS: Array = ["GOAL", "LADDER", "STRATEGIC", "ALLIANCE", "BETRAY",
	"INFRA", "FACTION_UPDATE", "INDEP_INFRA", "INTENT"]

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "warring_states"
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 30
	var ticks: int = days * WorldState.TICKS_PER_DAY
	seed(1337)
	var state := WorldState.new()
	GameSetup.setup(state, GameSetup.load_config("res://config/%s.json" % cfg))
	var guard: String = "none"
	if state.player_id != -1:
		guard = "stripped"
		state.player_id = -1
		state.player_forced_event = {}
		state.player_forced_event_id = ""
		state.player_pending_targets = []
		state.player_hostile_teams = []
		state.player_pre_encounter = {}
		state.player_state = {}
	Probe.reset(); Probe.enabled = true
	var runner := SimRunner.new()
	var stopped_at: int = -1
	var stop_reason: String = ""
	for _t in range(ticks):
		var r: String = runner.advance_tick(state, Vector2i(-1, -1))
		if stopped_at == -1 and (r == "game_over" or r == "awaiting_heir"):
			stopped_at = state.world.current_tick; stop_reason = r
	var eff: int = stopped_at if stopped_at != -1 else ticks

	var out: Array = []
	out.append("# 輪詢獨特貢獻率｜cfg=%s days=%d ticks=%d 有效窗=%d" % [cfg, days, ticks, eff])
	print("\n=== s5_poll_unique_value ｜cfg=%s days=%d ===" % [cfg, days])

	# ── ①②③：分母 / 分子 / 第三類 ──
	print("\n① 分母（純 cadence 觸發）｜② 分子（選擇變了）｜第三類（維持原選擇）")
	print("   %-16s %10s %10s %10s %12s" % ["支別", "分母", "改變", "維持", "貢獻率"])
	out.append("## ①②③ 支別|分母(cadence)|改變|維持|貢獻率|備註")
	var tot_denom: int = 0
	var tot_num: int = 0
	for k in SUPPORTS:
		var denom: int = int(Probe.counts.get("reeval.cadence." + k, 0))
		tot_denom += denom
		if not DecisionTier.poll_measurable(k):
			# ★量不到 ≠ 0：0 會被讀成「輪詢對它沒貢獻」，而真相是【沒有儀器】。
			print("   %-16s %10d %10s %10s %12s" % [k, denom, "量不到", "量不到", "—"])
			out.append("%s|%d|NOT_MEASURABLE|NOT_MEASURABLE|—|選擇不落在可比較的持久欄位上(產出是一次性動作)" % [k, denom])
			continue
		var ch: int = int(Probe.counts.get("poll.changed." + k, 0))
		var sm: int = int(Probe.counts.get("poll.same." + k, 0))
		tot_num += ch
		var seen: int = ch + sm
		var rate: String = "%.1f%%" % (100.0 * float(ch) / float(seen)) if seen > 0 else "n/a"
		var note: String = ""
		if seen != denom:
			# ★對帳：比對過的次數應該 = 分母。不等就是有一條路沒被比到，要講出來。
			note = "★對帳不符：比對過 %d ≠ 分母 %d" % [seen, denom]
		print("   %-16s %10d %10d %10d %12s %s" % [k, denom, ch, sm, rate, note])
		out.append("%s|%d|%d|%d|%s|%s" % [k, denom, ch, sm, rate, note])

	if tot_denom == 0:
		print("\n★★★停：分母 = 0 —— 這張床上輪詢【根本沒觸發過】。")
		print("   ⇒ 不拿 0/0 當「貢獻率 ≈ 0」（判準①，systems 寫死）。")
		out.append("# ★★★停：分母=0，這張床上輪詢根本沒觸發過（判準①）")
		_land(out, cfg)
		return

	# ── ③成因：分子那批的 before→after 原文 ──
	var chs: Array = Probe.samples.get("poll.changed", [])
	print("\n③ 成因池（分子逐筆 before→after）｜母體 %d 樣本 %d%s"
		% [tot_num, chs.size(), "  ★★撞 cap ⇒ 前 N 筆不是全部" if chs.size() >= 20000 else ""])
	out.append("#")
	out.append("## ③ 成因池｜母體 %d 樣本 %d" % [tot_num, chs.size()])
	var by_pair: Dictionary = {}
	for row in chs:
		var key: String = "%s｜%s → %s" % [String(row["k"]), String(row["b"]), String(row["f"])]
		by_pair[key] = int(by_pair.get(key, 0)) + 1
	var pkeys: Array = by_pair.keys()
	pkeys.sort_custom(func(a, b): return int(by_pair[a]) > int(by_pair[b]))
	for i in range(mini(pkeys.size(), 40)):
		print("   %5d × %s" % [int(by_pair[pkeys[i]]), String(pkeys[i])])
	for pk in pkeys:
		out.append("cause|%d|%s" % [int(by_pair[pk]), String(pk)])
	if pkeys.size() > 40:
		print("   …另 %d 種（全部在落地檔）" % (pkeys.size() - 40))

	# ── ④延遲：沒改變的那些，下一次事件喚醒在多久之後 ──
	var waketab: Dictionary = {}   # "k#actor" -> Array[tick]（升冪，樣本天然升冪）
	for w in Probe.samples.get("poll.eventwake", []):
		var wk: String = String(w["k"]) + "#" + str(w["a"])
		if not waketab.has(wk): waketab[wk] = []
		(waketab[wk] as Array).append(int(w["t"]))
	var sames: Array = Probe.samples.get("poll.same", [])
	print("\n④ 延遲欄：那些【沒改變】的，若當時不跑，下一次事件喚醒在多久之後")
	print("   %-16s %8s %10s %10s %10s %10s" % ["支別", "樣本", "中位", "平均", "最大", "★之後再也沒醒"])
	out.append("#")
	out.append("## ④ 延遲｜支別|樣本|中位|平均|最大|之後再也沒醒")
	var per: Dictionary = {}
	var never: Dictionary = {}
	for sm2 in sames:
		var k2: String = String(sm2["k"])
		var key2: String = k2 + "#" + str(sm2["a"])
		var t0: int = int(sm2["t"])
		var nxt: int = -1
		for tv in (waketab.get(key2, []) as Array):
			if int(tv) > t0: nxt = int(tv); break
		if not per.has(k2): per[k2] = []; never[k2] = 0
		if nxt == -1:
			never[k2] = int(never[k2]) + 1
		else:
			(per[k2] as Array).append(nxt - t0)
	for k3 in SUPPORTS:
		if not per.has(k3): continue
		var arr: Array = per[k3]
		arr.sort()
		var nv: int = int(never.get(k3, 0))
		if arr.is_empty():
			print("   %-16s %8d %10s %10s %10s %10d" % [k3, nv, "—", "—", "—", nv])
			out.append("%s|%d|—|—|—|%d" % [k3, nv, nv])
			continue
		var sum: int = 0
		for v in arr: sum += int(v)
		var med: int = int(arr[arr.size() / 2])
		var mean: float = float(sum) / float(arr.size())
		print("   %-16s %8d %10d %10.1f %10d %10d" % [k3, arr.size(), med, mean, int(arr[-1]), nv])
		out.append("%s|%d|%d|%.1f|%d|%d" % [k3, arr.size(), med, mean, int(arr[-1]), nv])
	print("   ★單位是 tick（%d tick = 1 日）" % WorldState.TICKS_PER_DAY)
	out.append("# 單位 tick；%d tick = 1 日" % WorldState.TICKS_PER_DAY)

	# ── ⑤已移除：它跟 ⑦ 問的是同一件事，而 ⑦ 是精確的 ──
	#   ★舊 ⑤ 的 join 只比對 "T<隊>"，而勢力層五支的 actor 是勢力
	#     ⇒ 它會把【勢力醒了】算成 miss，把落空率吐高。
	#   ★★而我今天已經被【兩個儀器答同一問】咬過一次（⑦ 與 ⑥ 打架）——
	#     ★★★留著一個較鬆的版本只會讓人引到錯的那個數字，所以直接拆掉。

	# ── ⑥ rung_changed → INTENT 的【精確】驗收欄（#3 那票的行為證據）──
	#   ★用 rung_changed_at 帶下來的 faction_id 做 join，★★不是拿 team id 去猜 faction。
	#   ★★★三分：同 tick 醒 / 之後才醒（幾 tick）/ 從此沒醒過 —— 三個是不同結論，不准合併。
	var rcs: Array = Probe.samples.get("rung_changed_at", [])
	var same_tick: int = 0
	var later: Array = []
	var never_woke: int = 0
	var no_faction: int = 0
	for rc in rcs:
		var fid: int = int(rc["f"])
		if fid == -1:
			no_faction += 1      # ★獨立隊沒有勢力 ⇒ INTENT 這一支對它不存在（不是「沒醒」）
			continue
		var t0b: int = int(rc["t"])
		var lst: Array = waketab.get("INTENT#F" + str(fid), [])
		var hit: int = -1
		for tv2 in lst:
			if int(tv2) == t0b:
				hit = 0
				break
			if int(tv2) > t0b:
				hit = int(tv2) - t0b
				break
		if hit == 0:
			same_tick += 1
		elif hit > 0:
			later.append(hit)
		else:
			never_woke += 1
	print("\n⑥ rung_changed → INTENT（★驗收：rung 變動的當 tick，INTENT 有沒有被喚醒）")
	print("   rung 變動 %d 次（樣本 %d）｜其中獨立隊無勢力 %d 次（★INTENT 對它不存在，非『沒醒』）"
		% [int(Probe.counts.get("g2.ambition_promote", 0)) + int(Probe.counts.get("g2.ambition_demote", 0)),
		   rcs.size(), no_faction])
	print("   ★同 tick 醒 = %d ／ 之後才醒 = %d ／ 從此沒醒過 = %d ｜合計 %d"
		% [same_tick, later.size(), never_woke, same_tick + later.size() + never_woke])
	if not later.is_empty():
		later.sort()
		var ls: int = 0
		for v2 in later:
			ls += int(v2)
		print("   之後才醒的延遲：中位 %d ／ 平均 %.1f ／ 最大 %d tick"
			% [int(later[later.size() / 2]), float(ls) / float(later.size()), int(later[-1])])
	out.append("#")
	out.append("## ⑥ rung_changed → INTENT｜同tick=%d|之後才醒=%d|從此沒醒=%d|獨立隊無勢力=%d|樣本=%d"
		% [same_tick, later.size(), never_woke, no_faction, rcs.size()])

	# ── ⑦ 逐 kind × 逐支：這一發 emit 【有沒有真的被看到】（★結果導向的精確 join）──
	#   seen        該支在【同一 tick】為【對應 actor】因事件醒過 ⇒ 這顆 pending 真的被讀到
	#   unseen      消費者存在，但整個 tick 沒有為它醒 ⇒ ★這顆在 tick 末被清掉＝【消失】不是延遲
	#   no_consumer 這一支對這個主體隊不存在（獨立隊沒有勢力層／無領袖不評野心階）
	#
	# ★★★第一版我用「這支這 tick 的閘評估過了沒有」來判，★那是【錯的】：
	#   `_run_systems` 一個 tick 會跑兩次（near 60 tick 的 pass ＋ far 600 tick 的 pass），
	#   而 `_evaluate_all_body` 的勢力／隊迴圈【不吃 team_ids】⇒ 同 tick 會被全掃兩遍。
	#   ⇒ ★★「已評估過」不等於「不會再評估」——那個定義會把「後來又看到了」記成「輸掉順序」。
	#   ★★★是兩個儀器互相打架把它抓出來的（那版說 INTENT 100% 輸、⑥ 說同 tick 醒 6/6，
	#     不可能同時成立 ⇒ 去查，錯的是我新加的那個，不是 ⑥）。
	#
	# ★★歸因界限（寫在這裡，不藏）：pending_rethink 是【每隊一個布林】、不記是誰標的
	#   ⇒ 同一 tick 同一隊有兩個 kind emit 時，兩個都會被記成 seen，★無法歸因給其中一個。
	#     ⇒ 「seen」要讀成【這一發沒有落空】，不是【這一發是喚醒的原因】。
	var wake_key: Dictionary = {}
	for w3 in Probe.samples.get("poll.eventwake", []):
		wake_key[String(w3["k"]) + "#" + String(w3["a"]) + "|" + str(w3["t"])] = true
	var ctxs: Array = Probe.samples.get("t0.emit_ctx", [])
	var per_kind: Dictionary = {}
	var per_sup: Dictionary = {}
	for c2 in ctxs:
		var kn3: String = String(c2["k"])
		var tk: int = int(c2["t"])
		for sk3 in DecisionTier.SUPPORT_KEYS:
			var s3: String = String(sk3)
			var b3: String
			if not _consumer_ok(s3, int(c2["fid"]), int(c2["leader"])):
				b3 = "no_consumer"
			else:
				var akey: String = ("T" + str(c2["team"])) if DecisionTier.actor_scope(s3) == "T" else ("F" + str(c2["fid"]))
				b3 = "seen" if wake_key.has(s3 + "#" + akey + "|" + str(tk)) else "unseen"
			if not per_kind.has(kn3):
				per_kind[kn3] = {"seen": 0, "unseen": 0, "no_consumer": 0}
			if not per_sup.has(s3):
				per_sup[s3] = {"seen": 0, "unseen": 0, "no_consumer": 0}
			(per_kind[kn3] as Dictionary)[b3] = int((per_kind[kn3] as Dictionary)[b3]) + 1
			(per_sup[s3] as Dictionary)[b3] = int((per_sup[s3] as Dictionary)[b3]) + 1
	print("\n⑦ emit 有沒有被看到（★分母排除 no_consumer —— 那些不是落空，是這一支對它不存在）")
	print("   %-24s %8s %8s %12s %10s" % ["kind", "seen", "unseen", "no_consumer", "落空率"])
	out.append("#")
	out.append("## ⑦ emit 被看到與否｜kind|seen|unseen|no_consumer|落空率(unseen/(seen+unseen))")
	out.append("# ★歸因界限：pending 是每隊一個布林、不記誰標的 ⇒ 同 tick 同隊多 kind 都記 seen，無法歸因")
	var kns2: Array = per_kind.keys()
	kns2.sort()
	for kn4 in kns2:
		var d4: Dictionary = per_kind[kn4]
		var sn: int = int(d4["seen"])
		var un: int = int(d4["unseen"])
		var nc4: int = int(d4["no_consumer"])
		var dn: int = sn + un
		var mr: String = "%.1f%%" % (100.0 * float(un) / float(dn)) if dn > 0 else "n/a"
		print("   %-24s %8d %8d %12d %10s" % [String(kn4), sn, un, nc4, mr])
		out.append("seen|%s|%d|%d|%d|%s" % [String(kn4), sn, un, nc4, mr])
	print("\n   ── 逐支彙總（誰最常落空）──")
	out.append("#")
	out.append("## ⑦b 逐支彙總｜支別|seen|unseen|no_consumer|落空率")
	for sk4 in SUPPORTS:
		if not per_sup.has(sk4):
			continue
		var d5: Dictionary = per_sup[sk4]
		var sn5: int = int(d5["seen"])
		var un5: int = int(d5["unseen"])
		var nc5: int = int(d5["no_consumer"])
		var dn5: int = sn5 + un5
		var mr5: String = "%.1f%%" % (100.0 * float(un5) / float(dn5)) if dn5 > 0 else "n/a"
		print("   %-16s seen=%-8d unseen=%-8d no_consumer=%-8d 落空率=%s" % [sk4, sn5, un5, nc5, mr5])
		out.append("seenS|%s|%d|%d|%d|%s" % [sk4, sn5, un5, nc5, mr5])
	print("   ★母體 vs 樣本：t0.emit_ctx %d 筆（cap 40000）%s"
		% [ctxs.size(), "  ★★撞 cap ⇒ 前 N 筆不是全部" if ctxs.size() >= 40000 else ""])
	out.append("# t0.emit_ctx 樣本 %d（cap 40000）" % ctxs.size())

	print("\n[BedSelfCheck] observer_guard=%s  first_nonadvance=%s  effective_window=%d/%d ticks"
		% [guard, ("%d(%s)" % [stopped_at, stop_reason]) if stopped_at != -1 else "none", eff, ticks])
	out.append("# [BedSelfCheck] observer_guard=%s first_nonadvance=%s effective_window=%d/%d"
		% [guard, ("%d(%s)" % [stopped_at, stop_reason]) if stopped_at != -1 else "none", eff, ticks])
	_land(out, cfg)

# ★消費者判定用【emit 當下的快照】(fid/leader)，不是跑完之後的狀態 ——
#   30 日內隊會換勢力、領袖會死，拿收尾狀態回頭判會把當時存在的消費者判成不存在。
func _consumer_ok(k: String, fid: int, leader: int) -> bool:
	if k == "INDEP_INFRA":
		return fid == -1
	if k == "LADDER":
		return leader != -1
	if k == "GOAL":
		return true
	return fid != -1

func _land(out: Array, cfg: String) -> void:
	var path: String = OS.get_environment("POLL_OUT") if OS.has_environment("POLL_OUT") \
		else "docs/measurements/2026-08-28-poll-unique-value-%s.txt" % cfg
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f != null:
		f.store_string("\n".join(PackedStringArray(out)) + "\n"); f.close()
		print("\n落地：%s" % path)
	print("=== s5_poll_unique_value DONE ===")
