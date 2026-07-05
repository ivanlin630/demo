extends SceneTree

# ★ 序3 rung_task 融合驗（核心交付）。融合非刪：rung_task 查表撕除後，
#   archetype/rung 當 weight 驅動 option → repertoire 該出現還出現。鏡射 solo_dissolution_check 風格。
#   repertoire（融合驗錨，spec §5）：
#     - FORCE-累積(有兵) → rank 含「訓練」可達（idle 情境浮現）
#     - TRADE-archetype   → 貿易
#     - SETTLE-累積        → 生產
#     - SETTLE-擴張        → 建設
#     - FORCE-擴張          → 讓位 prosperity（訓練 magnitude 不搶攻擊/prosperity；擴張階仍練但不壓緊急）
# 任一破 = 融合失敗。

var _fails: int = 0

func _initialize() -> void:
	_check_repertoire()
	if _fails == 0:
		print("[rung-dissolution] ALL PASS")
	else:
		print("[rung-dissolution] FAIL count=%d" % _fails)
	quit()

# ── 手構 ctx（deterministic，繞世界 setup）。leader_values + archetype/rung/情境欄位直填 ──
func _ctx(vals: Dictionary) -> DecisionContext:
	var c := DecisionContext.new()
	c.leader_values = vals
	c.food_days = 14.0          # 吃飽（survival_pressure=0，不誤壓）
	c.population = 20           # > FORAGE_VIABLE_POP → 覓食不 applicable
	c.threat_threshold = 999.0  # 無威脅：threat repertoire 不 applicable
	return c

func _opts(c: DecisionContext) -> Array:
	var out: Array = []
	for e in DecisionEngine.rank_scored_ctx(c): out.append(e["opt"])
	return out

func _first(c: DecisionContext) -> String:
	var r: Array = DecisionEngine.rank_scored_ctx(c)
	return r[0]["opt"] if not r.is_empty() else "<空>"

func _expect_first(label: String, c: DecisionContext, expected: String) -> void:
	var got: String = _first(c)
	if got != expected:
		_fails += 1
		print("[FAIL] %s 預期 rank[0]=%s 得 %s (ranked=%s)" % [label, expected, got, str(_opts(c))])
	else:
		print("[repertoire] %s → rank[0]=%s OK" % [label, got])

func _expect_reachable(label: String, c: DecisionContext, opt: String) -> void:
	var opts: Array = _opts(c)
	if opt in opts:
		print("[repertoire] %s → 「%s」可達 OK (ranked=%s)" % [label, opt, str(opts)])
	else:
		_fails += 1
		print("[FAIL] %s：「%s」不可達（ranked=%s）" % [label, opt, str(opts)])

func _check_repertoire() -> void:
	print("--- §5 repertoire (rung/archetype → option 融合) ---")

	# 1) FORCE-累積(有兵)：ambient_train_drive 開 + has_trainable → 訓練 可達且 idle 情境浮現。
	#    無其他驅力（吃飽/無威脅/無 prey/無 outpost/無 faction）→ 訓練=唯一 ambient option → rank[0]。
	var c1 := _ctx({"好戰": 0.8, "野心": 0.7})
	c1.archetype = AmbitionLadder.ARCHETYPE_FORCE
	c1.rung = AmbitionLadder.RUNG_ACCUMULATE
	c1.has_trainable = true
	c1.ambient_train_drive = 0.5
	_expect_reachable("FORCE-累積(有兵)", c1, "訓練")
	_expect_first("FORCE-累積(有兵) idle 浮現", c1, "訓練")

	# 2) TRADE-archetype：貪婪高 + 市場（有貨+套利+商隊）→ 貿易（既有 option 覆蓋 rung_task TRADE mapping）。
	var c2 := _ctx({"貪婪": 0.9})
	c2.archetype = AmbitionLadder.ARCHETYPE_TRADE
	c2.rung = AmbitionLadder.RUNG_ACCUMULATE
	c2.has_goods = true; c2.has_arb = true; c2.is_merchant = true
	_expect_first("TRADE-累積", c2, "貿易")

	# 3) SETTLE-累積：野心高 + own outpost + 階梯缺口 → 生產（ambition_drive 推生產）。
	var c3 := _ctx({"野心": 0.9, "慎重": 0.5})
	c3.archetype = AmbitionLadder.ARCHETYPE_SETTLE
	c3.rung = AmbitionLadder.RUNG_ACCUMULATE
	c3.has_own_outpost = true; c3.ambition_gap = 3
	_expect_first("SETTLE-累積", c3, "生產")

	# 4) SETTLE-擴張：野心高 + 無 own outpost + 階梯缺口 → 建設（bootstrap 蓋新據點；生產需 own_outpost 不 applicable）。
	var c4 := _ctx({"野心": 0.9, "慎重": 0.5})
	c4.archetype = AmbitionLadder.ARCHETYPE_SETTLE
	c4.rung = AmbitionLadder.RUNG_EXPAND
	c4.has_own_outpost = false; c4.ambition_gap = 3
	_expect_first("SETTLE-擴張", c4, "建設")

	# 5) FORCE-擴張：練兵 ambient 開，但有 prey + 征服 intent + 有戰兵 → 攻擊/掠奪 壓過訓練（讓位緊急/prosperity）。
	#    證 ambient_train_drive 低 magnitude：不搶緊急決策。訓練仍可達（repertoire 保），但非 rank[0]。
	var c5 := _ctx({"好戰": 0.9, "野心": 0.9, "殘忍": 0.6})
	c5.archetype = AmbitionLadder.ARCHETYPE_FORCE
	c5.rung = AmbitionLadder.RUNG_EXPAND
	c5.has_trainable = true; c5.ambient_train_drive = 0.5
	c5.self_armed_ratio = 0.6; c5.has_weak_prey = true
	c5.intent = "征服"; c5.intent_target = 1
	_expect_reachable("FORCE-擴張", c5, "訓練")   # 練兵仍在 repertoire
	var top5: String = _first(c5)
	if top5 == "訓練":
		_fails += 1
		print("[FAIL] FORCE-擴張：訓練 壓過緊急決策（rank[0]=訓練，ambient magnitude 太高；ranked=%s）" % str(_opts(c5)))
	else:
		print("[repertoire] FORCE-擴張 讓位緊急 → rank[0]=%s（訓練不搶）OK" % top5)
