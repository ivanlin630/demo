extends SceneTree
# @bed-kind: invariant
# ══ 終端 E2E 床（狀態驅動）：從畫面挑動作、按它印的鍵、驗世界真的照那句話變了 ══════════════════════
# spec：`docs/superpowers/specs/2026-10-06-terminal-e2e-state-driven-HOW.md`
#
# ★本檔目前只有**解析器**＋它的自驗（R² 回來之前先做的、不依賴架構裁定的那一件）
#
# ══ 解析器：畫面上的**三個**鍵位空間（spec 原文寫兩個；實測三個）══════════════════════════════════
#   (i)  目標動作：`─ 動作（` 區塊的 ` [n] 標籤 ▸（不可：原因）`（TextUiView.action_block；ACTION_DIGITS 靜態綁 id）
#   (ii) 強制事件回應：`   [A] 標籤`（text_ui_main 手刻；不變量 #10「按 A 做 B」的血證空間）
#   (iii) 自家隊動作：互動面板 `── 自家隊動作（N 項）` 底下 `[n]標籤` 與 `[n]標籤（不可）`（同一行多個、兩個空白分隔）
#   ★判哪個空間「現在吃數字鍵」：標題帶 `數字鍵在這一側` 的那一側

var _errors: int = 0


func _initialize() -> void:
	print("=== terminal_e2e：解析器自驗 ===")
	_p0_parser()
	print("\n=== terminal_e2e DONE === errors: %d" % _errors)
	quit(1 if _errors > 0 else 0)


func _check(msg: String, cond: bool) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_errors += 1
		push_error("[FAIL] " + msg)


# 回 {"self": [...], "self_active": bool, "targets_active": bool, "actions": [...], "forced": [...]}
#   每一項 {"space": "self"|"action"|"forced", "key": String, "label": String, "enabled": bool}
static func parse_screen(screen: String) -> Dictionary:
	var out: Dictionary = {"self": [], "actions": [], "forced": [], "self_active": false, "targets_active": false}
	var lines: PackedStringArray = screen.split("\n")
	var region: String = ""
	var re_self := RegEx.new()
	re_self.compile("\\[(\\d)\\]([^\\[]+?)(?=\\s{2,}\\[|\\s*$)")
	var re_act := RegEx.new()
	re_act.compile("^ \\[(\\d)\\] (.+?)\\s*(▸)?\\s*(（不可：.*）)?\\s*$")
	var re_forced := RegEx.new()
	re_forced.compile("^\\s{3}\\[([A-Z])\\] (.+?)\\s*$")
	for l in lines:
		if l.begins_with("── 自家隊動作"):
			region = "self"
			out["self_active"] = l.contains("數字鍵在這一側")
			continue
		if l.begins_with("── 可互動目標"):
			region = "targets"
			out["targets_active"] = l.contains("數字鍵在這一側")
			continue
		if l.begins_with("─ 動作（"):
			region = "action"
			continue
		# 其他區塊標題（`─ 事件（`、`── 互動 ──`、`── [T/Esc]關閉 ──`…）⇒ 離開目前區塊
		if l.begins_with("─ ") or l.begins_with("── "):
			region = ""
			continue
		var mf := re_forced.search(l)
		if mf != null:
			out["forced"].append({"space": "forced", "key": mf.get_string(1), "label": mf.get_string(2), "enabled": true})
			continue
		if region == "self":
			for m in re_self.search_all(l):
				var lab: String = m.get_string(2).strip_edges()
				var en: bool = not lab.ends_with("（不可）")
				out["self"].append({"space": "self", "key": m.get_string(1),
					"label": lab.trim_suffix("（不可）"), "enabled": en})
		elif region == "action":
			var ma := re_act.search(l)
			if ma != null:
				out["actions"].append({"space": "action", "key": ma.get_string(1), "label": ma.get_string(2).strip_edges(),
					"enabled": ma.get_string(4) == ""})
	return out


func _p0_parser() -> void:
	print("\n── P0 解析器（三個鍵位空間）──")
	var self_screen: String = "\n".join([
		"第 1 天 00:00 ｜ Team15（人口 10） ｜ 家：（無） ｜ 糧撐 6.3 天 ｜ 威脅：（無） ｜ 待執行 1 道",
		"─ 面板（接管畫面）──────",
		"── 互動 ──",
		"⚠ Team3 要求你繳貢",
		"   拒絕會惡化關係",
		"   [A] 接受",
		"   [B] 拒絕",
		"── 自家隊動作（10 項） 數字鍵在這一側 ──",
		"[1]紮營（不可）  [2]確認打聽（不可）  [3]建立勢力",
		"[4]狩獵（不可）  [5]獵猛獸（不可）  [6]放棄戰利品（不可）",
		"[7]拔擢匿名→記名  [8]收編敗者（不可）  [9]收割戰利品（不可）",
		"第 1/2 頁 [,]上 [.]下",
		"── 可互動目標 （按 [Tab] 切過來） ──",
		"（無可互動目標）",
		"── [T/Esc]關閉 ──",
		"─ 動作（2／3 可做，未綁鍵 0）──────",
		" [1] 貿易 ▸",
		" [2] 提議結盟 ",
		" [6] 攻擊 （不可：不在同格）",
		"─ 事件（最近 8 條）──────",
		" 結果：",
	])
	var p: Dictionary = parse_screen(self_screen)
	print("   自家隊 %d 項（可做 %s）｜目標動作 %s｜強制 %s｜數字鍵在自家隊 ＝ %s" % [(p["self"] as Array).size(),
		str((p["self"] as Array).filter(func(x): return x["enabled"]).map(func(x): return x["key"] + x["label"])),
		str((p["actions"] as Array).map(func(x): return [x["key"], x["label"], x["enabled"]])),
		str((p["forced"] as Array).map(func(x): return x["key"] + x["label"])), str(p["self_active"])])
	_check("P0 自家隊 9 項、可做的是 [3]建立勢力 與 [7]拔擢匿名→記名",
		(p["self"] as Array).size() == 9 and (p["self"] as Array).filter(func(x): return x["enabled"]).map(func(x): return x["key"]) == ["3", "7"])
	_check("P0 自家隊那一側吃數字鍵", bool(p["self_active"]) and not bool(p["targets_active"]))
	_check("P0 強制事件兩個字母鍵 [A]接受 [B]拒絕",
		(p["forced"] as Array).map(func(x): return x["key"] + x["label"]) == ["A接受", "B拒絕"])
	_check("P0 目標動作 3 列：[1]貿易 可、[2]提議結盟 可、[6]攻擊 不可",
		(p["actions"] as Array).map(func(x): return [x["key"], x["label"], x["enabled"]]) == [["1", "貿易", true], ["2", "提議結盟", true], ["6", "攻擊", false]])
	# ★反向：沒有任何鍵位的畫面 ⇒ 三個空間都空（解析器不能憑空生出項目）
	var empty: Dictionary = parse_screen("第 1 天 00:00 ｜ …\n─ 動作（0／0 可做，未綁鍵 0）──\n （沒有可做的動作）\n 結果：")
	_check("P0【反向】空畫面 ⇒ 三個空間都是 0",
		(empty["self"] as Array).is_empty() and (empty["actions"] as Array).is_empty() and (empty["forced"] as Array).is_empty())
