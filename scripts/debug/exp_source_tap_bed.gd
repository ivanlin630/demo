extends SceneTree
# @bed-kind: acceptance
# slice: add_exp 的 source tap（exp 流量逐來源）
#
# 驗收：①四個產線 source 各自可分辨（不合併兩個 combat）
#   ②「呼叫了但給 0」與「沒呼叫」分得開（exp.add.zero.*）
#   ③★被丟掉的 exp 看得見（菁英/無此 tier 的 early-return）——它跟「沒人給」長得一樣
#   ④source 是必填：沒傳會【編不過】（結構檢查：簽名無預設值）

var _fails: int = 0
var _sections: int = 0
const EXPECT_SECTIONS: int = 4

func _initialize() -> void:
	print("=== EXP SOURCE TAP ===")
	_test_sources_distinguishable()
	_test_zero_vs_absent()
	_test_dropped_visible()
	_test_source_required()
	if _sections != EXPECT_SECTIONS:
		_fails += 1
		push_error("[FAIL] 只跑完 %d/%d 段 —— 中途崩掉" % [_sections, EXPECT_SECTIONS])
	print("=== DONE === SECTIONS=%d/%d FAILS=%d" % [_sections, EXPECT_SECTIONS, _fails])
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_fails += 1
		push_error("[FAIL] " + msg)

func _mk() -> TeamData:
	var t := TeamData.new()
	t.team_id = 3
	AnonTierSystem.add_anon(t, "平民", 10)
	AnonTierSystem.add_anon(t, "新兵", 5)
	return t

func _test_sources_distinguishable() -> void:
	print("-- ① 四個 source 各自可分辨 --")
	Probe.reset()
	Probe.enabled = true
	var t := _mk()
	AnonTierSystem.add_exp(t, "平民", 10.0, "combat_survivor_winner")
	AnonTierSystem.add_exp(t, "平民", 4.0, "combat_survivor_loser")
	AnonTierSystem.add_exp(t, "平民", 7.0, "train_npc")
	AnonTierSystem.add_exp(t, "新兵", 3.0, "train_player")
	var missing: Array = []
	for src in ["combat_survivor_winner", "combat_survivor_loser", "train_npc", "train_player"]:
		var n: int = int(Probe.counts.get("exp.add." + src, 0))
		print("    %-24s 次數 %d" % [src, n])
		if n == 0:
			missing.append(src)
	_ok(missing.is_empty(), "①四個 source 都有計數（缺 %s）" % [str(missing)])
	# ★成對對照：贏家與敗方【沒有】被合成同一格（合起來就答不出「贏了才有用嗎」）
	_ok(int(Probe.counts.get("exp.add.combat_survivor_winner", 0)) == 1
		and int(Probe.counts.get("exp.add.combat_survivor_loser", 0)) == 1,
		"①兩個 combat 分開計（各 1 次，沒有被合併）")
	_sections += 1

func _test_zero_vs_absent() -> void:
	print("-- ② 「呼叫了但給 0」vs「沒呼叫」--")
	Probe.reset()
	Probe.enabled = true
	var t := _mk()
	AnonTierSystem.add_exp(t, "平民", 0.0, "train_npc")
	var zero_n: int = int(Probe.counts.get("exp.add.zero.train_npc", 0))
	var norm_n: int = int(Probe.counts.get("exp.add.train_npc", 0))
	print("    給 0 一次 ⇒ zero=%d｜一般計數=%d｜（沒呼叫過的 train_player：zero=%d 一般=%d）" % [
		zero_n, norm_n, int(Probe.counts.get("exp.add.zero.train_player", 0)),
		int(Probe.counts.get("exp.add.train_player", 0))])
	_ok(zero_n == 1 and norm_n == 0, "②給 0 記在 zero 格、不混進一般計數")
	_ok(int(Probe.counts.get("exp.add.zero.train_player", 0)) == 0,
		"②沒呼叫過的 source 兩格都是 0 ⇒ 【零來源】與【給了 0】分得開")
	_sections += 1

func _test_dropped_visible() -> void:
	print("-- ③ 被丟掉的 exp 要看得見 --")
	Probe.reset()
	Probe.enabled = true
	var t := _mk()
	AnonTierSystem.add_exp(t, "菁英", 50.0, "train_npc")          # 無下一階 ⇒ 丟掉
	# ★★★而「無此 tier」那條在【產線結構上不可達】：`team_data.gd:327` 的 anon_exp
	#   預先塞好 平民/新兵/老兵 三鍵，而 菁英 在上一條就 return 了
	#   ⇒ 這裡要【人工把鍵拿掉】才測得到 tap 本身會不會動。
	#   ★這件事我回報 systems：它是「drop 點不會 fire」而不是「drop 點靜默」——
	#     兩者都讓計數恆 0，而修法相反（一個該刪，一個該接）。
	t.anon_exp.erase("老兵")
	AnonTierSystem.add_exp(t, "老兵", 50.0, "combat_survivor_winner")  # 鍵被拿掉 ⇒ 丟掉
	var d1: int = int(Probe.counts.get("exp.add.dropped.elite.train_npc", 0))
	var d2: int = int(Probe.counts.get("exp.add.dropped.no_tier.combat_survivor_winner", 0))
	print("    菁英丟棄 %d｜無此 tier 丟棄 %d" % [d1, d2])
	_ok(d1 == 1 and d2 == 1,
		"③兩條 early-return 的 tap 都會動（否則那份 exp 消失了，而它跟「沒人給」長得一樣）")
	print("    ★誠實限：no_tier 那條在【產線】不可達（anon_exp 預先塞好三鍵）"
		+ " ⇒ 它的計數恆 0 是【不會 fire】不是【沒發生】")
	Probe.enabled = false
	_sections += 1

func _test_source_required() -> void:
	print("-- ④ source 是必填（沒有預設值）--")
	var f := FileAccess.open("res://scripts/simulation/anon_tier_system.gd", FileAccess.READ)
	if f == null:
		_fails += 1
		push_error("[FAIL] 讀不到 anon_tier_system.gd")
		_sections += 1
		return
	var src: String = f.get_as_text()
	f.close()
	var i: int = src.find("static func add_exp(")
	var line: String = src.substr(i, src.find("\n", i) - i) if i != -1 else ""
	print("    簽名：%s" % line)
	_ok(line.contains("source: String") and not line.contains("source: String ="),
		"④source 沒有預設值 —— 有預設值就會被忘記傳，而忘記的那一版看起來仍然正常")
	_sections += 1
