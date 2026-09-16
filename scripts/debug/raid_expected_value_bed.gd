extends SceneTree
# @bed-kind: acceptance
# slice: 掠奪走期望價值（HOW spec 2026-09-16-raid-expected-value-HOW.md §3）
#
# ★★★本床驗的是【同一把秤】：掠奪與攻擊用**同一個壓縮函數、同一個 `reference_wealth`**，
#   只有輸入不同（攻擊看最富的 prey、掠奪看最弱的 prey）。
# ★六格每格都要能紅（會紅的那一半寫在各格旁邊）。
# ★★母體：本床是 **fixture 級**（直接造 ctx 呼 `DecisionTerms.eval`）⇒ **不跑世界、不耗 RNG**
#   ⇒ ★★★所以它**答不了「真世界裡會不會 fire」** —— 那一格由長窗床負責，**本床不假裝它答得出**。
#
# ★★【誠實標·來自 spec §2b】：`odds` 兩邊共用同一個**盲**的贏率（只讀自己的武裝比，不讀對手）
#   ⇒ **格3 的「同量級」只能證明【尺】相同，不能證明【值】對** ——
#   ★★★**不要拿格3 綠了當成「贏率也對了」**（那是 `odds-must-read-the-target` 那張票）。

func _initialize() -> void:
	_run(); quit(0 if _fails == 0 else 1)

var _fails: int = 0

func _ok(cond: bool, msg: String) -> void:
	if cond: print("  [OK] %s" % msg)
	else:
		_fails += 1
		push_error("[FAIL] %s" % msg)

# ★fixture ctx：只填本式子讀到的欄位 —— ★★其餘留預設，**免得我不小心把別的機制也餵進來**
func _ctx(rich: float, food_days: float, armed_odds: float, vals: Dictionary) -> DecisionContext:
	var c := DecisionContext.new()
	c.has_weak_prey = true
	c.weak_prey_id = 1
	c.weak_prey_priced = true
	c.weak_prey_richness_est = rich
	c.attack_loot_est = rich                     # ★格3 要「同一個目標」⇒ 兩邊餵同一個身價
	c.reference_wealth = 4157.0                  # ★pop 10 的隊（= 10 × Σ(TARGET_PER_POP×BASE_PRICE)）
	c.food_days = food_days
	c.desperation_entry_threshold = 3.0
	c.attack_win_odds = armed_odds
	c.self_armed_ratio = armed_odds * DecisionTerms.VIABLE_ARMED_RATIO
	c.leader_values = vals
	c.population = 10
	return c

func _run() -> void:
	print("=== 掠奪走期望價值 驗收（fixture 級，不跑世界）===")
	var neutral: Dictionary = {"好戰": 0.5, "殘忍": 0.5, "慎重": 0.5, "貪婪": 0.5}

	# ── 格1：富 prey vs 窮 prey ⇒ util 分化 ──
	var u_rich: float = DecisionTerms.eval("loot_drive", _ctx(4000.0, 10.0, 1.0, neutral), "掠奪")
	var u_poor: float = DecisionTerms.eval("loot_drive", _ctx(100.0, 10.0, 1.0, neutral), "掠奪")
	print("★格1 富 prey util=%.4f｜窮 prey util=%.4f" % [u_rich, u_poor])
	_ok(u_rich > u_poor,
		"格1 富 prey 的掠奪 util **高於**窮 prey（★相同 ⇒ 還是常數驅力，本票沒做到事）")

	# ── 格2：同一 prey，自己餓 vs 不餓 ⇒ util 分化 ──
	var u_hungry: float = DecisionTerms.eval("loot_drive", _ctx(1000.0, 0.5, 1.0, neutral), "掠奪")
	var u_full: float = DecisionTerms.eval("loot_drive", _ctx(1000.0, 10.0, 1.0, neutral), "掠奪")
	print("★格2 餓 util=%.4f｜不餓 util=%.4f" % [u_hungry, u_full])
	_ok(u_hungry > u_full, "格2 **餓的時候更想搶**（★相同 ⇒ need 沒接上）")

	# ── 格3：★同一個目標，掠奪 vs 攻擊 ⇒ **同量級** ──
	#   ★把 need 歸零（food_days 遠大於門檻）⇒ 兩式只剩 (W × 身價項) × odds × person
	#   ⇒ ★★比值 ＝ take/loot ＝ 壓縮後的 `LOOT_RATE` 效果 —— **那正是「同一把秤」的可檢查後果**
	# ★★★第一版這一格紅了，而**紅的是我的 fixture 不是世界**：
	#   `attack_opportunity`（`terms.gd:263`）第一行就是 `if opt != "攻擊" or ctx.attack_target_id == -1: return 0.0`
	#   ⇒ ★我沒填 `attack_target_id` ⇒ 攻擊 util 恆 0 ⇒ 比值爆成 84126。
	#   ★★而我**沒有把那個 0 當成發現** —— **「它不會攻擊」與「我沒給它目標」在一個 0 上長得一樣。**
	var c3: DecisionContext = _ctx(4000.0, 99.0, 1.0, neutral)
	c3.attack_target_id = 1        # ★同一個目標（與 weak_prey_id 同一隻）
	var u_raid: float = DecisionTerms.eval("loot_drive", c3, "掠奪")
	var u_atk: float = DecisionTerms.eval("attack_opportunity", c3, "攻擊")
	var ratio: float = u_raid / maxf(u_atk, 0.000001)
	print("★格3 同一目標：掠奪 util=%.6f｜攻擊 util=%.6f｜比值=%.4f（LOOT_RATE=%.2f）" % [
		u_raid, u_atk, ratio, NpcCombatSystem.LOOT_RATE])
	# ★★★【判準第二次改寫，而兩次都是 systems 自己的判準被推翻】（2026-09-16）：
	#   ★v1：`0.1 < ratio < 1.0` —— 上界 1.0 是我手猜的，且把兩件事綁在一個斷言裡。
	#   ★★v2：拆成「①同量級 ②方向 掠奪 < 攻擊」，理由是「搶只拿一部分、打下來拿整份」。
	#   ★★★**而那個理由本身是錯的**（systems 查 `npc_combat_system._loot_resources`）：
	#     **世界的結算逐字是【任何戰鬥勝方都只拿 `effective_loot` 比例】** ——
	#     ★殲滅與潰逃控地**共用同一個函式** ⇒ **攻擊贏了也只拿 0.3–0.51 倍。**
	#   ⇒ ★★所以攻擊的 loot 項也乘了 `effective_loot_rate` ⇒ **兩邊的即時收穫同源同尺**
	#   ⇒ ★★★**v3 判準：對同一目標、同人格、`need` 都為 0 ⇒ 兩者【逐字相等】。**
	#     ★會紅的那一半：**還有差** ⇒ **還有一條沒有同源的線** ⇒ 回報 systems。
	#     ★★（而「打下來那塊地會持續產出」不在這一項裡：它由**佔村** option 的 `occupy_drive`
	#       走 `DiscountedFlow` 表達 ⇒ 攻擊 option 再算一次就是**算兩次**。）
	_ok(absf(u_raid - u_atk) < 0.0005,
		"格3 **逐字相等**：掠奪 %.6f vs 攻擊 %.6f（差 %.6f）⇒ ★兩邊的 loot 項同源同尺" % [
			u_raid, u_atk, absf(u_raid - u_atk)]
		+ "｜★★★還有差 ⇒ **還有一條沒同源的線，回報 systems**")
	print("   ★★而 `odds` 兩邊共用同一個【盲】的贏率（不讀對手）⇒ **這一格只證明尺相同，不證明值對**。")

	# ── 格4：無牙 ⇒ util ≈ 0 ──
	var u_toothless: float = DecisionTerms.eval("loot_drive", _ctx(4000.0, 0.5, 0.0, neutral), "掠奪")
	print("★格4 無牙 util=%.6f" % u_toothless)
	_ok(absf(u_toothless) < 0.0005,
		"格4 無牙 ⇒ 掠奪 util ≈ 0（★**不是新功能，是不准退步**：舊制的 `cap` 也做得到）")

	# ── 格5：人格只調製，不改三個輸入 ──
	# ★★★【殘忍固定】（systems 裁 2026-09-16：殘忍進 `take`，因為結算端真的多給殘忍者）
	#   ⇒ ★這一格要驗的是「**好戰／慎重**只調製、不漏進世界量」
	#   ⇒ ★★所以**殘忍必須固定** —— 否則它會（正當地）改變 `take`，把這一格變成假紅。
	var warlike: Dictionary = {"好戰": 1.0, "殘忍": 0.5, "慎重": 0.0, "貪婪": 0.5}
	var meek: Dictionary = {"好戰": 0.0, "殘忍": 0.5, "慎重": 1.0, "貪婪": 0.5}
	var u_war: float = DecisionTerms.eval("loot_drive", _ctx(1000.0, 5.0, 1.0, warlike), "掠奪")
	var u_meek: float = DecisionTerms.eval("loot_drive", _ctx(1000.0, 5.0, 1.0, meek), "掠奪")
	print("★格5 好戰殘忍 util=%.4f｜溫和謹慎 util=%.4f" % [u_war, u_meek])
	_ok(u_war > u_meek, "格5-a 人格**有**調製（★兩者相同 ⇒ 人格沒接）")
	# ★★而「只調製」怎麼驗：**兩人格的比值必須是一個【與身價無關】的常數**
	#   ⇒ 換一個身價再算一次，比值不變 ⇒ 人格沒有漏進 take／need／odds。
	var u_war2: float = DecisionTerms.eval("loot_drive", _ctx(200.0, 5.0, 1.0, warlike), "掠奪")
	var u_meek2: float = DecisionTerms.eval("loot_drive", _ctx(200.0, 5.0, 1.0, meek), "掠奪")
	var r1: float = u_war / maxf(u_meek, 0.000001)
	var r2: float = u_war2 / maxf(u_meek2, 0.000001)
	print("   人格比值：身價 1000 時 %.4f｜身價 200 時 %.4f" % [r1, r2])
	_ok(absf(r1 - r2) < 0.001,
		"格5-b **好戰／慎重**的比值與身價無關 ⇒ ★它們只乘在外面（★★殘忍不在這一格：它是物理，見格7）")

	# ── ★★★格7：**能推翻 systems 那個裁定**的一格（他自己要求加的）──
	#   ★裁定是「殘忍要進 take，因為世界真的多給殘忍者」。
	#   ★★若它錯了，錯的樣子是**殘忍被平方**（物理乘一次、偏好再乘一次而兩者同源）
	#   ⇒ ★★★所以這一格比的是：**util 比值 A** vs **結算端比值 B × person 比值** ——
	#     **A ≈ 那個乘積 ⇒ 正常；A ≫ 它 ⇒ 平方了 ⇒ 回報，把 take 那層拿掉。**
	var cruel0: Dictionary = {"好戰": 0.5, "殘忍": 0.0, "慎重": 0.5, "貪婪": 0.5}
	var cruel1: Dictionary = {"好戰": 0.5, "殘忍": 1.0, "慎重": 0.5, "貪婪": 0.5}
	var u_c0: float = DecisionTerms.eval("loot_drive", _ctx(1000.0, 99.0, 1.0, cruel0), "掠奪")
	var u_c1: float = DecisionTerms.eval("loot_drive", _ctx(1000.0, 99.0, 1.0, cruel1), "掠奪")
	var A: float = u_c1 / maxf(u_c0, 0.000001)
	var B: float = NpcCombatSystem.effective_loot_rate(1.0) / NpcCombatSystem.effective_loot_rate(0.0)
	# person ＝ clampf(0.5 + (max(好戰,殘忍) − 0.5) − (慎重 − 0.5)×ATTACK_CAUTION_W, 0, 1.5)
	var p0: float = clampf(0.5 + (maxf(0.5, 0.0) - 0.5) - (0.5 - 0.5) * DecisionTerms.ATTACK_CAUTION_W, 0.0, 1.5)
	var p1: float = clampf(0.5 + (maxf(0.5, 1.0) - 0.5) - (0.5 - 0.5) * DecisionTerms.ATTACK_CAUTION_W, 0.0, 1.5)
	var expected: float = B * (p1 / maxf(p0, 0.000001))
	print("★格7 殘忍 0 vs 1：util 比值 A=%.3f｜結算端比值 B=%.3f｜person 比值=%.3f｜B×person=%.3f" % [
		A, B, p1 / maxf(p0, 0.000001), expected])
	_ok(A > 1.0, "格7-a 殘忍**確實提高**掠奪 util（★否則 take 那層根本沒接上）")
	_ok(A <= expected * 1.05,
		"格7-b **A ≤ B×person**（%.3f ≤ %.3f）⇒ ★殘忍【沒有被平方】" % [A, expected * 1.05]
		+ "｜★★★若這格紅 ⇒ **回報 systems：他裁錯了，`take` 那層要拿掉**")
	print("   ★★而壓縮是次線性 ⇒ A 略小於 B×person 是**預期**的，不是缺陷。")

	# ── 格6：tap 逐筆可 dump ──
	Probe.reset(); Probe.arm()
	DecisionTerms.eval("loot_drive", _ctx(1000.0, 1.0, 0.8, neutral), "掠奪")
	var rows: Array = Probe.samples.get("raid.factors", [])
	print("★格6 `raid.factors` 樣本 %d 筆｜`raid.eval` 母體 %d" % [
		rows.size(), int(Probe.counts.get("raid.eval", 0))])
	var has_all: bool = false
	if rows.size() > 0:
		var r: Dictionary = rows[0]
		has_all = r.has("take") and r.has("need") and r.has("odds") and r.has("util")
		print("   逐筆：%s" % str(r))
	_ok(has_all, "格6 `take／need／odds／util` **逐筆都在**（★缺任一 ⇒ 違「全量暫態可觀測性」）")

	print("")
	print("-- 量測完成；[FAIL] 數 ＝ %d --" % _fails)
