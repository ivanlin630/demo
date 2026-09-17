extends SceneTree

# ★★★driver ledger 丟棄可見性（blueprint 守衛令 2026-09-05，全量觀測法）
#   ★病：`WorldState.record_driver` 的 `pop_front` 【安靜地】丟舊列 ——
#     而下游從 ledger 讀出來的「0 筆」是【缺席宣稱】⇒ 0 可能是【被丟掉】不是【沒發生】。
#   ★★這支是那個守衛的【陽性對照】：把 cap 調小 ⇒ dropped 必須非 0；還原 ⇒ 必須是 0。
#   ★★★沒有這支，那個計數器本身就是「裝好但沒接電」的下一個例子。

var _fail: int = 0
const EXPECTED_CELLS: Array = ["_test_no_drop_when_under_cap", "_test_drop_counted_when_over_cap", "_test_clear_does_not_erase_evidence", "_test_cross_run_reset_zeroes_it"]

# ★★★【到場點名 ＋ 陽性對照】（systems 派工；樣板同 `constitution_gate` 第一批）——
#   ★病：GDScript 的執行期錯誤**只中止那一支 func**（coroutine 也一樣，`await` 不保護）⇒
#     床照樣跑到最後、照樣印通過橫幅，而 runner 只看 exit code 與 expect ⇒ **兩者都通過**。
#   ★★修法：每一格【自己的最後一行】打卡，末尾對名單，**少一格就把橫幅變成 FAIL**。
#   ★★★用法必須是 `_selftest_gate("格名").noop()` —— 死亡要發生在【那一格自己的 frame】裡
#     （★血證：放進被呼叫的 helper 裡 ⇒ 中止的是 helper、那一格照樣跑完 ⇒ 會誤判成「這裡沒有洞」）。
var _cells_ran: Array = []

func _cell(name: String) -> void:
	if not _cells_ran.has(name):
		_cells_ran.append(name)

func noop() -> void:
	pass

func _selftest_gate(cell: String) -> Object:
	if OS.get_environment("BED_SELFTEST_DIE") != cell:
		return self
	print("[SELFTEST] ★故意讓 `%s` 這一格在中途死掉" % cell)
	return null

func _roll_call_missing() -> Array:
	var missing: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(c): missing.append(c)
	if not missing.is_empty():
		print("[roll-call] ❌ ★**有格沒有跑完**：%s —— 執行期錯誤會靜默中止一支 func，而那看起來像綠" % str(missing))
	return missing

func _initialize() -> void:
	_test_no_drop_when_under_cap()
	_test_drop_counted_when_over_cap()
	_test_clear_does_not_erase_evidence()
	_test_cross_run_reset_zeroes_it()
	var _miss: Array = _roll_call_missing()
	var _suffix: String = "｜到場點名 %d／%d" % [_cells_ran.size(), EXPECTED_CELLS.size()]
	if _fail == 0 and _miss.is_empty(): print("=== DONE === ALL PASS%s" % _suffix)
	else: print("=== DONE === %d FAIL%s" % [_fail + _miss.size(), _suffix])
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
	_selftest_gate("_test_no_drop_when_under_cap").noop()
	_arm(64)
	_write(64)
	_ok(WorldState.driver_ledger.size() == 64, "未超上限：ledger 有 64 列（實得 %d）" % WorldState.driver_ledger.size())
	_ok(WorldState.driver_ledger_dropped == 0,
		"★未超上限 ⇒ dropped == 0（實得 %d）—— ★★這條是【陰性對照】：沒有它，「恆常非 0」也會讓下面那條綠"
			% WorldState.driver_ledger_dropped)
	_cell("_test_no_drop_when_under_cap")

func _test_drop_counted_when_over_cap() -> void:
	_selftest_gate("_test_drop_counted_when_over_cap").noop()
	_arm(8)
	_write(100)
	_ok(WorldState.driver_ledger.size() == 8, "超上限：ledger 停在 cap=8（實得 %d）" % WorldState.driver_ledger.size())
	_ok(WorldState.driver_ledger_dropped == 92,
		"★★★陽性對照：寫 100 列、cap 8 ⇒ dropped == 92（實得 %d）—— ★而【數字要對】不是「非 0 就好」："
			% WorldState.driver_ledger_dropped)
	print("        ★「非 0 就好」對【少算】完全不敏感，而少算正是這個計數器唯一會壞的方式。")
	_cell("_test_drop_counted_when_over_cap")

func _test_clear_does_not_erase_evidence() -> void:
	_selftest_gate("_test_clear_does_not_erase_evidence").noop()
	_arm(8)
	_write(100)
	var before: int = WorldState.driver_ledger_dropped
	WorldState.clear_driver_ledger()
	_ok(WorldState.driver_ledger.is_empty(), "clear 之後 ledger 空")
	_ok(WorldState.driver_ledger_dropped == before,
		"★clear【不清】dropped（%d → %d）—— ★★它是「這個 process 曾經丟過」的證據；"
			% [before, WorldState.driver_ledger_dropped])
	print("        ★★★跟著清掉的話，「清過之後的 0 筆」會【再一次】無法分辨是沒發生還是被丟掉。")
	_cell("_test_clear_does_not_erase_evidence")

func _test_cross_run_reset_zeroes_it() -> void:
	_selftest_gate("_test_cross_run_reset_zeroes_it").noop()
	_arm(8)
	_write(100)
	var rep: Dictionary = WorldState._reset_cross_run()
	_ok(WorldState.driver_ledger_dropped == 0,
		"★跨 run 重置歸零（實得 %d）—— 那是唯一該歸零的邊界" % WorldState.driver_ledger_dropped)
	_ok(rep.get("cleared", {}).has("WorldState.driver_ledger_dropped"),
		"★★而重置要【回報】它清掉了什麼（非零才報）—— 靜默歸零就是這整件事的病本身")
	WorldState.driver_ledger_enabled = false
	WorldState.driver_ledger_cap = 4096
	_cell("_test_cross_run_reset_zeroes_it")
