extends SceneTree

# ★★★driver ledger 丟棄可見性（blueprint 守衛令 2026-09-05，全量觀測法）
#   ★病：`WorldState.record_driver` 的 `pop_front` 【安靜地】丟舊列 ——
#     而下游從 ledger 讀出來的「0 筆」是【缺席宣稱】⇒ 0 可能是【被丟掉】不是【沒發生】。
#   ★★這支是那個守衛的【陽性對照】：把 cap 調小 ⇒ dropped 必須非 0；還原 ⇒ 必須是 0。
#   ★★★沒有這支，那個計數器本身就是「裝好但沒接電」的下一個例子。

var _fail: int = 0

func _initialize() -> void:
	_test_no_drop_when_under_cap()
	_test_drop_counted_when_over_cap()
	_test_clear_does_not_erase_evidence()
	_test_cross_run_reset_zeroes_it()
	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond: print("  [PASS] %s" % msg)
	else: _fail += 1; print("  [FAIL] %s" % msg)

func _mk_team(tid: int) -> TeamData:
	var t := TeamData.new(); t.team_id = tid; return t

func _write(n: int) -> void:
	var t := _mk_team(7)
	for i in range(n):
		WorldState.record_driver(t, "unrest_turns", 1.0, "salary", "state")

func _arm(cap: int) -> void:
	WorldState._reset_cross_run()
	WorldState.driver_ledger_enabled = true
	WorldState.driver_ledger_cap = cap
	WorldState.clear_driver_ledger()

func _test_no_drop_when_under_cap() -> void:
	_arm(64)
	_write(64)
	_ok(WorldState.driver_ledger.size() == 64, "未超上限：ledger 有 64 列（實得 %d）" % WorldState.driver_ledger.size())
	_ok(WorldState.driver_ledger_dropped == 0,
		"★未超上限 ⇒ dropped == 0（實得 %d）—— ★★這條是【陰性對照】：沒有它，「恆常非 0」也會讓下面那條綠"
			% WorldState.driver_ledger_dropped)

func _test_drop_counted_when_over_cap() -> void:
	_arm(8)
	_write(100)
	_ok(WorldState.driver_ledger.size() == 8, "超上限：ledger 停在 cap=8（實得 %d）" % WorldState.driver_ledger.size())
	_ok(WorldState.driver_ledger_dropped == 92,
		"★★★陽性對照：寫 100 列、cap 8 ⇒ dropped == 92（實得 %d）—— ★而【數字要對】不是「非 0 就好」："
			% WorldState.driver_ledger_dropped)
	print("        ★「非 0 就好」對【少算】完全不敏感，而少算正是這個計數器唯一會壞的方式。")

func _test_clear_does_not_erase_evidence() -> void:
	_arm(8)
	_write(100)
	var before: int = WorldState.driver_ledger_dropped
	WorldState.clear_driver_ledger()
	_ok(WorldState.driver_ledger.is_empty(), "clear 之後 ledger 空")
	_ok(WorldState.driver_ledger_dropped == before,
		"★clear【不清】dropped（%d → %d）—— ★★它是「這個 process 曾經丟過」的證據；"
			% [before, WorldState.driver_ledger_dropped])
	print("        ★★★跟著清掉的話，「清過之後的 0 筆」會【再一次】無法分辨是沒發生還是被丟掉。")

func _test_cross_run_reset_zeroes_it() -> void:
	_arm(8)
	_write(100)
	var rep: Dictionary = WorldState._reset_cross_run()
	_ok(WorldState.driver_ledger_dropped == 0,
		"★跨 run 重置歸零（實得 %d）—— 那是唯一該歸零的邊界" % WorldState.driver_ledger_dropped)
	_ok(rep.get("cleared", {}).has("WorldState.driver_ledger_dropped"),
		"★★而重置要【回報】它清掉了什麼（非零才報）—— 靜默歸零就是這整件事的病本身")
	WorldState.driver_ledger_enabled = false
	WorldState.driver_ledger_cap = 4096
