extends SceneTree
# @observe-pure
# ★★★#12「乞食 option 存在而引擎從不選它」——★本票【只 dump 不開藥】。
#
# ★而 dump 的第一問是【不選得對不對】，不是【怎麼讓它被選】：
#   blueprint 明示絕境隊乞食 util 真低【可能是 genuine】 ⇒ ★★禁 crank。
#
# ★★★「乞食 0 次」有【三種】意思，這張表要把它們分開：
#   ①母體 0     —— 根本沒隊進絕境階梯（`beg.rank_calls` = 0）
#   ②不 applicable —— 進了，但乞食連候選都不是（★而這還要再分【哪一道閘擋的】）
#   ③applicable 而輸 —— 是候選、被別人贏走（★★這才是「決策問題」，前兩種不是）
#
# ★母體 systems 指定：進入絕境階梯（survival/desperation 層）的隊 × 該窗全部 tick
#   ⇒ ★★分母＝`rank_survival` 的呼叫次數（那就是「進了階梯」的定義），不是「跑了幾天」。

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 12
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "warring_states"
	var sd: int = int(OS.get_environment("BED_SEED")) if OS.has_environment("BED_SEED") else 1337
	print("=== #12 乞食 per-option dump｜config=%s seed=%d days=%d ===" % [cfg, sd, days])
	var state: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg, true)
	seed(sd)
	print("[CONTROL] Probe.enabled=%s（★false 的話下面整張表都是儀器沒開）" % str(Probe.enabled))
	print("★乞食的 util 由哪些項組成（靜態，直接讀 registry）：%s"
		% str(DecisionOptions.terms_of("乞食")))
	print("★★applicable 的兩道閘：food_days < desperation_entry_threshold 且 has_aid_target")
	var runner := SimRunner.new()
	for d in range(days):
		for _t in range(WorldState.TICKS_PER_DAY):
			runner.advance_tick(state, Vector2i(-1, -1))
		# ★分段吐值：被砍也留得下半份（今天踩過一次「只在最後吐」）
		print("[CP] day=%d 階梯路(母體/候選/贏)=%d/%d/%d ｜ 全pool路=%d/%d/%d" % [
			d + 1,
			int(Probe.counts.get("beg.rank_calls", 0)), int(Probe.counts.get("beg.in_candidates", 0)), int(Probe.counts.get("beg.won", 0)),
			int(Probe.counts.get("begu.rank_calls", 0)), int(Probe.counts.get("begu.in_candidates", 0)), int(Probe.counts.get("begu.won", 0))])

	# ★★★#35 驗收①（systems）：導回後【餓死不該出現】—— ★而若出現，那【不是失敗，是證據】：
	#   代表 `SURVIVAL_CRUSH = 5.0`（TEST VALUE）不夠 ⇒ ★★開【修秤】票，★★★禁回頭開走廊。
	#   ★而 g1a 那支 fixture 的村【根本不餓】（食日 55→120）⇒ 這條驗收在那裡沒被考到，
	#     ★★所以拿這支【真世界】床來考它。
	print("═══ ★#35 驗收①：導回後的自救路與死亡 ═══")
	var _fr: Array = []
	for k9 in Probe.counts.keys():
		if String(k9).begins_with("food_rescue."):
			_fr.append("%s=%d" % [String(k9).substr(12), int(Probe.counts[k9])])
	_fr.sort()
	print("  自救路：%s" % ("｜".join(PackedStringArray(_fr)) if not _fr.is_empty() else "（零）"))
	var _ext: int = 0
	for k10 in Probe.counts.keys():
		if String(k10).begins_with("extinct.team."): _ext += 1
	# ★★★驗收③（systems）：三個桶要分開印，而且加總要跟本刀前對得起來。
	var _rej: int = 0
	var _empA: int = 0
	var _empOther: int = 0
	var _wu: int = 0
	var _wn: int = 0
	var _tb: int = 0
	for k11 in Probe.counts.keys():
		var ks: String = String(k11)
		# ★★★`bump_pt` 會寫【兩把鑰匙】：`event+.day.NNN` 與 `event+.team.<id>`（`probe_stats.gd:82`）
		#   ⇒ ★兩個都數就是【整整多一倍】，而那個數字看起來完全合理。
		#   ★★所以只數 `.team.` 那一家（它是總量、不逐日）。
		if ks.begins_with("wall.reject_cannot_afford") and ks.contains(".team.") and not ks.contains(".res."):
			_rej += int(Probe.counts[k11])
		elif ks.contains(".empty_all_unaffordable") and ks.contains(".team."): _empA += int(Probe.counts[k11])
		elif ks.contains(".team.") and (ks.contains(".empty_no_eligible") or ks.contains(".empty_all_below_threshold") or ks.contains(".empty_slot_full")): _empOther += int(Probe.counts[k11])
		elif ks.ends_with(".win_upgrade"): _wu += int(Probe.counts[k11])
		elif ks.ends_with(".win_new"): _wn += int(Probe.counts[k11])
		elif ks.ends_with(".tiebreak_cheaper"): _tb += int(Probe.counts[k11])
	print("  ★驗收③三桶：reject_cannot_afford=%d｜★★empty_all_unaffordable(新)=%d｜empty 其餘成因=%d"
		% [_rej, _empA, _empOther])
	print("  ★驗收⑤升級 vs 新建：win_upgrade=%d｜win_new=%d｜同分取便宜者 tiebreak_cheaper=%d"
		% [_wu, _wn, _tb])
	var _ws: Array = []
	for k12 in Probe.counts.keys():
		var k12s: String = String(k12)
		if k12s.ends_with(".win_upgrade") or k12s.ends_with(".win_new") or k12s.ends_with(".filtered.unaffordable") or k12s.ends_with(".filtered.max_level"):
			_ws.append("%s=%d" % [k12s.substr(5), int(Probe.counts[k12])])
	_ws.sort()
	print("  ★★逐 site 拆（★★★自救路與基建路是兩個不同的使用者，合起來看會互相掩蓋）：")
	print("     %s" % ("｜".join(PackedStringArray(_ws)) if not _ws.is_empty() else "（零）"))
	print("  ★建設總量（★★跨版本可比：這兩個桶本刀前後都存在）：construct.start=%d｜village.build_fired=%d"
		% [int(Probe.counts.get("construct.start", 0)), int(Probe.counts.get("village.build_fired", 0))])
	print("  真滅團隊數（cleanup_extinct_teams，★★消失≠死，這個桶只收真滅團）= %d" % _ext)
	print("  ★讀法：★★滅團數要跟【修法前同窗】比，單看一邊的絕對值什麼都證不了。")
	_report("beg.", "①絕境階梯路（rank_survival）")
	_report("begu.", "②統一全 pool 路（rank_scored）★★這條不監的話，另一條的命中會被讀成 0")
	print("★誠實限：①單 config／單 seed／%d 日；②★本票純觀測（fp 另跑對照）；③★★母體與命中同印" % days)

func _report(pfx: String, title: String) -> void:
	print("═══ %s ═══" % title)
	var calls: int = int(Probe.counts.get(pfx + "rank_calls", 0))
	var teams_n: int = 0
	for k in Probe.counts.keys():
		if String(k).begins_with(pfx + "rank_team."): teams_n += 1
	var inc: int = int(Probe.counts.get(pfx + "in_candidates", 0))
	var notin: int = int(Probe.counts.get(pfx + "not_in_candidates", 0))
	var won: int = int(Probe.counts.get(pfx + "won", 0))

	print("── ★①母體（★systems 指定：進絕境階梯的隊 × 全部 tick）──")
	print("  rank_survival 呼叫 = %d｜相異隊數 = %d" % [calls, teams_n])
	if calls == 0:
		print("  ★★★母體 = 0 ⇒ 下面全部是 0，而那【不是】「引擎不選乞食」——是【沒隊進階梯】")
		print("     ⇒ 這個窗答不了本題，要換 config／拉長窗（★不是改乞食）")
	print("── ★★②乞食在不在候選裡（★這一格分開了「不選」與「不能選」）──")
	print("  在候選 = %d（%.1f%%）｜不在候選 = %d（%.1f%%）"
		% [inc, 100.0 * float(inc) / maxf(float(calls), 1.0),
		   notin, 100.0 * float(notin) / maxf(float(calls), 1.0)])
	print("  ★不在候選時是【哪一道閘】擋的：")
	print("    食物門檻擋（food_days >= desperation_entry_threshold）= %d"
		% int(Probe.counts.get(pfx + "gate.blocked_by_food_threshold", 0)))
	print("    沒有援助對象（has_aid_target = false，而食物門檻已過）= %d"
		% int(Probe.counts.get(pfx + "gate.blocked_by_no_aid", 0)))
	print("    （參考）食物門檻過 = %d｜有援助對象 = %d"
		% [int(Probe.counts.get(pfx + "gate.food_ok", 0)), int(Probe.counts.get(pfx + "gate.aid_ok", 0))])
	print("── ★★★③是候選的時候，輸給誰、差多少 ──")
	print("  贏 = %d｜輸 = %d" % [won, inc - won])
	var losers: Array = []
	for k2 in Probe.counts.keys():
		if String(k2).begins_with(pfx + "lost_to."):
			losers.append("%s=%d" % [String(k2).substr((pfx + "lost_to.").length()), int(Probe.counts[k2])])
	losers.sort()
	print("  輸給誰：%s" % ("｜".join(PackedStringArray(losers)) if not losers.is_empty() else "（無，因為不是候選或沒輸過）"))
	print("  差距分布：<0.1=%d｜0.1~0.5=%d｜0.5~1=%d｜1~2=%d｜>=2=%d" % [
		int(Probe.counts.get(pfx + "gap.lt0.1", 0)), int(Probe.counts.get(pfx + "gap.0.1to0.5", 0)),
		int(Probe.counts.get(pfx + "gap.0.5to1", 0)), int(Probe.counts.get(pfx + "gap.1to2", 0)),
		int(Probe.counts.get(pfx + "gap.ge2", 0))])
	if inc > 0:
		print("  平均 util：乞食 %.3f ／ 贏家 %.3f"
			% [Probe.amount(pfx + "util_sum") / float(inc), Probe.amount(pfx + "winner_util_sum") / float(inc)])
	print("── ★讀法（★★這張表【不回答】「該不該讓乞食贏」）──")
	print("  ★差距 <0.1 佔多數 ⇒ 它【是個對手】，只是每次差一點")
	print("  ★★差距 >=2 佔多數 ⇒ 它【從來不是對手】，而那可能完全正確（genuine 低價值）")
	print("  ★★★而『贏家贏得有沒有道理』要看贏家是誰：覓食/買糧 贏乞食＝自己有辦法，合理；")
	print("     若贏家是【跟糧食無關的】東西，那才是要往上游查的訊號")
