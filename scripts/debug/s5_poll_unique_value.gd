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
# ★★★★【首次賦值】獨立成第四桶（不併進分子）—— 30 日實測抓到的假陽性：
#   INTENT 的 8 筆「改變」逐筆看全是 `"" -> X`，而 8 == 勢力數
#   ⇒ 那是 f.intent 初值為空的【第一次填上】，不是【選擇變了】。
#   ★併進分子的話，輪詢貢獻率會虛報成 10.3%%（真值 0%%），
#   ★★而那個數字正好落在「>0 ⇒ 不退場」的判準上 —— ★★★假陽性會直接改變裁決。
#
# ★★★★★⑦ 是我自己加的一欄，動機是【我自己驗收的盲點】：
#   S4b 的覆蓋格把 burst 注在 advance_tick【之前】⇒ 那些格子永遠看得到 pending。
#   ★它證的是【閘會不會醒】，★★不是【真 emit 站有沒有趕在消費者那一 pass 之前】。
#   ⇒ ⑦ 用【結果導向的精確 join】問：seen / unseen / no_consumer。
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

	# ★★★actor 母體：判準①要分【分母=0 因為輪詢沒觸發】與【分母=0 因為根本沒有 actor】。
	#   ★這兩件在輸出上长得一模一樣，而結論完全不同：
	#     前者是【這張床量不到】，後者是【這張床沒有這種東西】。
	#   ★★實例：peaceful_economy 的 config 沒有 factions 鍵、全程也沒形成勢力
	#     ⇒ 勢力層六支的分母 0 是【沒有 actor】。
	#   ★★★讓床自己分，不靠我在交付單裡口頭斷言。
	var n_fac_end: int = state.factions.size()
	var n_indep_end: int = 0
	var n_lead_end: int = 0
	for tid_c in state.teams:
		var t_c: TeamData = state.teams[tid_c]
		if t_c.beast_kind != "":
			continue
		if t_c.faction_id == -1 and t_c.parent_team_id == -1:
			n_indep_end += 1
		if t_c.leader_id != -1:
			n_lead_end += 1
	var actor_have: Dictionary = {
		"GOAL": state.persons.size(), "LADDER": n_lead_end,
		"STRATEGIC": n_fac_end, "ALLIANCE": n_fac_end, "BETRAY": n_fac_end,
		"INFRA": n_fac_end, "FACTION_UPDATE": n_fac_end, "INTENT": n_fac_end,
		"INDEP_INFRA": n_indep_end,
	}

	var out: Array = []
	out.append("# 輪詢獨特貢獻率｜cfg=%s days=%d ticks=%d 有效窗=%d" % [cfg, days, ticks, eff])
	out.append("# actor 母體(收尾)：persons=%d factions=%d 獨立隊=%d 有領袖隊=%d"
		% [state.persons.size(), n_fac_end, n_indep_end, n_lead_end])
	print("actor 母體(收尾)：persons=%d factions=%d 獨立隊=%d 有領袖隊=%d"
		% [state.persons.size(), n_fac_end, n_indep_end, n_lead_end])
	print("\n=== s5_poll_unique_value ｜cfg=%s days=%d ===" % [cfg, days])

	# ── ①②③：分母 / 分子 / 第三類 ──
	print("\n① 分母（純 cadence 觸發）｜② 分子（選擇變了）｜第三類（維持原選擇）")
	print("   %-16s %8s %8s %8s %10s %10s %10s" % ["支別", "分母", "①改變", "②維持", "③首次賦值", "④無選擇產出", "貢獻率"])
	out.append("## ①②③ 支別|分母(cadence)|①改變|②維持|③首次賦值|④無選擇產出|貢獻率|備註")
	out.append("# ★四類互斥且窮盡：①+②+③+④ 必須 == 分母；④ 是殘差，它非 0 就是還有第五種情況")
	out.append("# ★貢獻率的分母 = 改變+維持，【排除首次賦值】——它既不是改變也不是維持")
	var tot_denom: int = 0
	var tot_num: int = 0
	for k in SUPPORTS:
		var denom: int = int(Probe.counts.get("reeval.cadence." + k, 0))
		tot_denom += denom
		if denom == 0:
			# ★判準①：分母 0 不拿來當「貢獻率 ≈ 0」，而且要分兩種。
			var why: String = "NO_ACTOR(這張床沒有這種 actor，數量=0)" if int(actor_have.get(k, 0)) == 0 				else "NEVER_FIRED(有 %d 個 actor，但純 cadence 觸發從未發生)" % int(actor_have.get(k, 0))
			print("   %-16s %8d  ★分母=0 ⇒ %s" % [k, denom, why])
			out.append("%s|0|—|—|—|—|n/a|★分母=0 ⇒ %s" % [k, why])
			continue
		if not DecisionTier.poll_measurable(k):
			# ★量不到 ≠ 0：0 會被讀成「輪詢對它沒貢獻」，而真相是【沒有儀器】。
			print("   %-16s %8d %8s %8s %10s %10s %10s" % [k, denom, "量不到", "量不到", "量不到", "量不到", "—"])
			out.append("%s|%d|NOT_MEASURABLE|NOT_MEASURABLE|NOT_MEASURABLE|NOT_MEASURABLE|—|選擇不落在可比較的持久欄位上(產出是一次性動作)" % [k, denom])
			continue
		var ch: int = int(Probe.counts.get("poll.changed." + k, 0))
		var sm: int = int(Probe.counts.get("poll.same." + k, 0))
		# ★首次賦值獨立成桶：before 是空的那些不是「選擇變了」，是「第一次填上」。
		var fs: int = int(Probe.counts.get("poll.first." + k, 0))
		tot_num += ch
		var seen: int = ch + sm + fs
		# ★分母排除首次賦值：它既不是「改變」也不是「維持」，把它留在分母會把貢獻率壓低。
		var rate: String = "%.1f%%" % (100.0 * float(ch) / float(ch + sm)) if (ch + sm) > 0 else "n/a"
		# ★★★④無選擇產出：該次重評沒有產生可比較的選擇。
		#   ★它是【對帳的殘差】而不是獨立量到的 —— ★★而那正是它的用處：
		#   systems 寫死「四欄加總必須 == 分母，不等就是還有第五種情況沒被列】。
		#   ⇒ ★★★把殘差印出來，它非 0 就是【我的四類不窮盡】的機械證據，不靠人看。
		var nz: int = denom - (ch + sm + fs)
		var note: String = ""
		if nz != 0:
			note = "★★四類不窮盡：殘差 %d（分母 %d ≠ %d+%d+%d）⇒ 還有第五種情況" % [nz, denom, ch, sm, fs]
		print("   %-16s %8d %8d %8d %10d %10d %10s %s" % [k, denom, ch, sm, fs, nz, rate, note])
		out.append("%s|%d|%d|%d|%d|%d|%s|%s" % [k, denom, ch, sm, fs, nz, rate, note])

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

	# ── ⑥b 【延到下一 tick 才被看到】（t0-emit-ordering 的效果量）──
	#   ★這一欄每一筆，在雙緩衝之前都是【消失】不是延遲。
	#   ★★它從 0 變正數是【預期】，不是變差。
	print("
⑥b 四分死水（cadence / event(本 tick) / ★delayed(上一 tick) / both）")
	print("   %-16s %10s %10s %10s %10s %10s" % ["支別", "cadence", "event", "★delayed", "both", "合計"])
	out.append("#")
	out.append("## ⑥b 四分死水｜支別|cadence|event|delayed|both|合計")
	out.append("# ★delayed = 【上一 tick 的 emit，延到這一 tick 才被看到】——雙緩衝之前這些是【消失】")
	for sk5 in SUPPORTS:
		var c_cad: int = int(Probe.counts.get("reeval.cadence." + sk5, 0))
		var c_evt: int = int(Probe.counts.get("reeval.event." + sk5, 0))
		var c_dly: int = int(Probe.counts.get("reeval.delayed." + sk5, 0))
		var c_bth: int = int(Probe.counts.get("reeval.both." + sk5, 0))
		print("   %-16s %10d %10d %10d %10d %10d" % [sk5, c_cad, c_evt, c_dly, c_bth, c_cad + c_evt + c_dly + c_bth])
		out.append("dw4|%s|%d|%d|%d|%d|%d" % [sk5, c_cad, c_evt, c_dly, c_bth, c_cad + c_evt + c_dly + c_bth])

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
				# ★★★可見窗是【兩個 tick】不是一個（t0-emit-ordering 雙緩衝）：
				#   tick N 的 emit ⇒ 本 tick 在 pending_rethink、下一 tick 在 pending_prev。
				#   ★只比對同 tick 的話，「晚到但下一 tick 被看到」會被錯記成 unseen
				#     ⇒ ★★那正是這一票要消滅的那個數字，量錯等於自己把成果藏起來。
				#   ★★★seen_next 獨立成一欄：它【就是】被救回來的那批。
				if wake_key.has(s3 + "#" + akey + "|" + str(tk)):
					b3 = "seen"
				elif wake_key.has(s3 + "#" + akey + "|" + str(tk + 1)):
					b3 = "seen_next"
				else:
					# ★★★systems 改的判準：unseen 拆兩類（互斥且窮盡）
					#   buffer_expired  該支在 2 tick 窗內【有走訪】該 actor 卻沒看到 ⇒ ★必須歸零
					#   not_visited     該支在窗內【根本沒走訪】⇒ ★★不是雙緩衝的責任，
					#                   它是【壽命 < 走訪間隔】的結構事實
					# ★★結構上 buffer_expired 應該恆為 0（窗內任何一次評估都會讀到那兩格），
					#   ★★★但我不用論證交差 —— 印出來，非 0 就是我的結構推論錯了。
					var vis: bool = Probe.counts.has("gate.tick." + s3 + "|" + str(tk)) 						or Probe.counts.has("gate.tick." + s3 + "|" + str(tk + 1))
					b3 = "buffer_expired" if vis else "not_visited"
			if not per_kind.has(kn3):
				per_kind[kn3] = {"seen": 0, "seen_next": 0, "buffer_expired": 0, "not_visited": 0, "no_consumer": 0}
			if not per_sup.has(s3):
				per_sup[s3] = {"seen": 0, "seen_next": 0, "buffer_expired": 0, "not_visited": 0, "no_consumer": 0}
			(per_kind[kn3] as Dictionary)[b3] = int((per_kind[kn3] as Dictionary)[b3]) + 1
			(per_sup[s3] as Dictionary)[b3] = int((per_sup[s3] as Dictionary)[b3]) + 1
	print("\n⑦ emit 有沒有被看到（★分母排除 no_consumer —— 那些不是落空，是這一支對它不存在）")
	print("   %-22s %8s %9s %9s %9s %10s %8s" % ["kind", "seen", "seen_next", "★buf_exp", "not_visited", "no_consumer", "落空率"])
	out.append("#")
	out.append("## ⑦ emit 被看到與否｜kind|seen|unseen|no_consumer|落空率(unseen/(seen+unseen))")
	out.append("# ★歸因界限：pending 是每隊一個布林、不記誰標的 ⇒ 同 tick 同隊多 kind 都記 seen，無法歸因")
	var kns2: Array = per_kind.keys()
	kns2.sort()
	for kn4 in kns2:
		var d4: Dictionary = per_kind[kn4]
		var sn: int = int(d4["seen"])
		var snx: int = int(d4["seen_next"])
		var be: int = int(d4["buffer_expired"])
		var nv: int = int(d4["not_visited"])
		var nc4: int = int(d4["no_consumer"])
		var dn: int = sn + snx + be + nv
		var mr: String = "%.1f%%" % (100.0 * float(be + nv) / float(dn)) if dn > 0 else "n/a"
		print("   %-22s %8d %9d %9d %9d %10d %8s" % [String(kn4), sn, snx, be, nv, nc4, mr])
		out.append("seen|%s|%d|%d|%d|%d|%d|%s" % [String(kn4), sn, snx, be, nv, nc4, mr])
	print("\n   ── 逐支彙總（誰最常落空）──")
	out.append("#")
	out.append("## ⑦b 逐支彙總｜支別|seen|★seen_next|unseen|no_consumer|落空率")
	for sk4 in SUPPORTS:
		if not per_sup.has(sk4):
			continue
		var d5: Dictionary = per_sup[sk4]
		var sn5: int = int(d5["seen"])
		var snx5: int = int(d5["seen_next"])
		var be5: int = int(d5["buffer_expired"])
		var nv5: int = int(d5["not_visited"])
		var nc5: int = int(d5["no_consumer"])
		var dn5: int = sn5 + snx5 + be5 + nv5
		var mr5: String = "%.1f%%" % (100.0 * float(be5 + nv5) / float(dn5)) if dn5 > 0 else "n/a"
		print("   %-16s seen=%-7d next=%-7d ★buf_exp=%-6d not_visited=%-7d no_cons=%-7d 落空=%s"
			% [sk4, sn5, snx5, be5, nv5, nc5, mr5])
		out.append("seenS|%s|%d|%d|%d|%d|%d|%s" % [sk4, sn5, snx5, be5, nv5, nc5, mr5])
	print("   ★母體 vs 樣本：t0.emit_ctx %d 筆（cap 40000）%s"
		% [ctxs.size(), "  ★★撞 cap ⇒ 前 N 筆不是全部" if ctxs.size() >= 40000 else ""])
	out.append("# t0.emit_ctx 樣本 %d（cap 40000）" % ctxs.size())

	# ── ⑧ LADDER 的 rung 變化按【觸發源】分割（systems 的小問題）──
	#   ★他問的字面版本在結構上不可能：那 24 筆【依定義】是純 cadence
	#     （tap_poll_outcome 只在 _due and not _woke 呼叫），而 rung_changed 是那次 fire 的
	#     【結果】不是原因 ⇒ 照字面問會循環。★★這裡答可答的版本。
	#   ★★★分母也印：只看分子的話，「事件那條變得多」有可能只是因為它 fire 得多。
	print("\n⑧ LADDER rung 變化 × 觸發源（★分子分母都印）")
	print("   %-10s %10s %10s %10s" % ["觸發源", "fire 次數", "rung 變了", "變化率"])
	out.append("#")
	out.append("## ⑧ LADDER rung 變化×觸發源｜觸發源|fire|rung變了|變化率")
	out.append("# ★systems 問的字面版本結構上不可能（那批依定義是純 cadence；rung_changed 是 fire 的結果非原因）")
	out.append("# ⇒ 這裡答：所有 rung 變化裡，各觸發源各佔多少")
	var trig_tot: int = 0
	var trig_chg: int = 0
	for tg in ["cadence", "event", "both"]:
		var fr: int = int(Probe.counts.get("rung.fire." + tg, 0))
		var cg: int = int(Probe.counts.get("rung.chg." + tg, 0))
		trig_tot += fr
		trig_chg += cg
		var rr: String = "%.1f%%" % (100.0 * float(cg) / float(fr)) if fr > 0 else "n/a"
		print("   %-10s %10d %10d %10s" % [tg, fr, cg, rr])
		out.append("rungtrig|%s|%d|%d|%s" % [tg, fr, cg, rr])
	print("   %-10s %10d %10d" % ["合計", trig_tot, trig_chg])
	out.append("rungtrig|合計|%d|%d|—" % [trig_tot, trig_chg])

	# ★純 cadence 那批：事件【上一次】醒到同一隊是多久以前？
	#   ★★答的是「事件路徑到底有沒有在動」——若從未醒過，那是另一種結論（事件根本沒到它）。
	var lad_wakes: Dictionary = {}
	for w4 in Probe.samples.get("poll.eventwake", []):
		if String(w4["k"]) != "LADDER":
			continue
		var ak2: String = String(w4["a"])
		if not lad_wakes.has(ak2):
			lad_wakes[ak2] = []
		(lad_wakes[ak2] as Array).append(int(w4["t"]))
	var gaps: Array = []
	var no_prior: int = 0
	for rc2 in Probe.samples.get("rung.chg_at", []):
		if String(rc2["trig"]) != "cadence":
			continue
		var tt: int = int(rc2["t"])
		var prev: int = -1
		for tv3 in (lad_wakes.get("T" + str(rc2["team"]), []) as Array):
			if int(tv3) < tt:
				prev = int(tv3)
			else:
				break
		if prev == -1:
			no_prior += 1
		else:
			gaps.append(tt - prev)
	print("\n   ── 純 cadence 的 rung 變化：事件上一次醒到同一隊是多久以前 ──")
	out.append("#")
	if gaps.is_empty():
		print("   ★樣本 %d 筆【全部】沒有更早的 LADDER 事件喚醒 ⇒ 事件路徑從未醒到它們" % no_prior)
		out.append("## ⑧b 純cadence rung變化｜無更早事件喚醒=%d｜有=0" % no_prior)
	else:
		gaps.sort()
		var gs: int = 0
		for g in gaps:
			gs += int(g)
		print("   樣本 %d ｜中位 %d ｜平均 %.1f ｜最大 %d tick ｜★完全沒有更早事件喚醒的 = %d 筆"
			% [gaps.size(), int(gaps[gaps.size() / 2]), float(gs) / float(gaps.size()), int(gaps[-1]), no_prior])
		out.append("## ⑧b 純cadence rung變化｜樣本=%d|中位=%d|平均=%.1f|最大=%d|無更早事件喚醒=%d"
			% [gaps.size(), int(gaps[gaps.size() / 2]), float(gs) / float(gaps.size()), int(gaps[-1]), no_prior])

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
