extends SceneTree

# 框架收尾 F4 統一註冊表 TDD（spec §HOW-binding INV-1~4 + §3 擴充性稽核）。
# ★byte-identical 純結構（fp 命門另驗）；此驗 accessor 語意保序 + 「加 option 動一處」operational 示範。

var _fail: int = 0
func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

func _initialize() -> void:
	_test_affinity_from_registry()   # INV-1：affinity_of 讀 REGISTRY.affinity、買料/空→UNIFORM 保序
	_test_sets_from_registry()       # INV-2：is_in_set/options_in_set 讀 REGISTRY.sets、guard 非-REGISTRY→false、STAKES 序
	_test_single_point_extensibility() # §3：加 mock option 到 REGISTRY 單一 entry → 3 registry(affinity/sets/set-iter)全反映=動一處
	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()

func _test_affinity_from_registry() -> void:
	print("--- INV-1 affinity_of 讀 REGISTRY ---")
	var forage: Array = NeedHierarchy.affinity_of("覓食")
	var buymat: Array = NeedHierarchy.affinity_of("買料")
	var unknown: Array = NeedHierarchy.affinity_of("")
	_ok(forage == [0.9, 0.1, 0.0, 0.0, 0.0] and buymat == [0.2, 0.2, 0.2, 0.2, 0.2] and unknown == NeedHierarchy._AFFINITY_UNIFORM,
		"affinity_of：覓食=%s(表2 值) / 買料=UNIFORM(INV-1 顯式保序) / 空 opt=UNIFORM(非-REGISTRY fallback)" % str(forage))

func _test_sets_from_registry() -> void:
	print("--- INV-2 is_in_set/options_in_set 讀 REGISTRY ---")
	var forage_surv: bool = DecisionOptions.is_in_set("覓食", "survival")
	var forage_pass: bool = DecisionOptions.is_in_set("覓食", "passive_survival")
	var buymat_surv: bool = DecisionOptions.is_in_set("買料", "survival")   # 買料 不在任何 set
	var nonreg: bool = DecisionOptions.is_in_set("__nonexist__", "survival")  # guard→false
	var stakes: Array = DecisionOptions.options_in_set("stakes")
	_ok(forage_surv and forage_pass and not buymat_surv and not nonreg and stakes == ["攻擊", "徵收", "外交"],
		"is_in_set：覓食∈survival+passive / 買料∉survival / 非-REGISTRY→false(guard) ; options_in_set('stakes')=%s(REGISTRY 插入序保 byte-id)" % str(stakes))

func _test_single_point_extensibility() -> void:
	print("--- §3 加 option 動一處(operational) ---")
	# 加 mock 行為域 option 到 REGISTRY 單一 entry（含 affinity+sets）→ 驗 3 registry 全反映、無他處註冊。
	DecisionOptions.REGISTRY["__mock_ext__"] = {
		"affinity": [0.5, 0.0, 0.0, 0.5, 0.0], "sets": {"survival": true, "ambient": true},
		"terms": [], "applicable": func(_c): return false, "to_task": func(_s, _t): return {},
	}
	var aff_ok: bool = NeedHierarchy.affinity_of("__mock_ext__") == [0.5, 0.0, 0.0, 0.5, 0.0]   # affinity registry 自動反映
	var set_ok: bool = DecisionOptions.is_in_set("__mock_ext__", "survival") and DecisionOptions.is_in_set("__mock_ext__", "ambient")  # set membership 自動反映
	var iter_ok: bool = "__mock_ext__" in DecisionOptions.options_in_set("survival")  # set 迭代自動反映
	DecisionOptions.REGISTRY.erase("__mock_ext__")   # cleanup 免污染後續
	_ok(aff_ok and set_ok and iter_ok,
		"加 mock option 到 REGISTRY 單一 entry → affinity_of + is_in_set×2 + options_in_set 全自動反映(零他處註冊)=②「加 option 動一處」operational")
