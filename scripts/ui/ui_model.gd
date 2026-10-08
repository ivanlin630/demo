class_name UiModel
# ══ 友善度 F6（spec 2026-10-07 round5-friendliness-convergence §F6）：資料 → 【區塊資料】 ══════════════════════
# ★終端與將來的 GUI 都只吃這裡產生的區塊資料；排版（TextUiView／text_ui_main 的字串層）只負責畫
# ★F1–F4 的規則寫在這一層（排好序、折好疊、篩好鍵），排版層不再判斷
# ★純函式、不讀 state、不耗 RNG：吃引擎回來的動作信封（PlayerApiMapper.map_available_action 那一份）
#
# 一筆動作列（區塊資料）：
#   {id, label, enabled, reason, hint, hint_label, group, key, opens_submenu}
#   ·reason：三種產生者收成一欄（目標動作 disabled_reason／自家隊 precheck_* 的 reason／打聽 DISABLED_REASON）
#   ·hint：能解除這個條件的動作 id（引擎給；指不出 ⇒ ""）
#   ·key：這一項的鍵（靜態：不因排序或折疊改變；不變量 #10）

# ★動作清單的組別：藍圖已定的 GUI 四組（時間／移動／對選中目標／自家隊）——終端照同一順序
const GROUPS: Array = ["時間", "移動", "對選中目標", "自家隊"]

const FOLD_HEAD: String = "另有 "
const FOLD_TAIL: String = " 個暫時不能做（按 ? 展開看原因）"


static func action_row(raw: Dictionary, group: String, key: String) -> Dictionary:
	var hint: String = String(raw.get("hint", ""))
	return {
		"id": String(raw.get("action_id", "")),
		"label": String(raw.get("label", raw.get("action_id", ""))),
		"enabled": bool(raw.get("enabled", true)),
		"reason": String(raw.get("disabled_reason", raw.get("reason", ""))),
		"hint": hint,
		"hint_label": PlayerApiMapper.action_label(hint) if hint != "" else "",
		"group": group,
		"key": key,
		"opens_submenu": bool(raw.get("opens_submenu", false)),
	}


# ★F2：能做的排前（穩定：同一側照原順序）、不可的折疊；展開時不可的照原順序接在後面
static func fold(rows: Array, expanded: bool) -> Dictionary:
	var shown: Array = []
	var hidden: Array = []
	for r in rows:
		if bool(r["enabled"]):
			shown.append(r)
		else:
			hidden.append(r)
	if expanded:
		shown.append_array(hidden)
	return {"shown": shown, "folded": 0 if expanded else hidden.size(), "disabled": hidden.size()}


static func fold_line(n: int) -> String:
	return FOLD_HEAD + str(n) + FOLD_TAIL


# ★F3：拒絕句＝主詞＋原因＋（有則）下一步
static func refusal_text(row: Dictionary) -> String:
	var out: String = "%s不行：%s" % [row["label"], row["reason"]]
	if String(row.get("hint_label", "")) != "":
		out += "；可以先做 %s" % row["hint_label"]
	return out


# ★F1：首屏三行「你現在能做的」——來源＝動作清單同一份資料（不另寫建議邏輯）
#   排序規則：有強制事件 ⇒ 回應排第一；否則推進鍵第一；其餘依動作清單序挑可做的
#   ★每行一鍵一句：自家隊動作要先開互動面板 ⇒ 那一鍵就是互動鍵，句子說出開了之後按哪一個
static func first_three(forced_message: String, open_key: String, advance_key: String, advance_label: String,
		self_rows: Array, fallback: Array = []) -> Array:
	var out: Array = []
	if forced_message != "":
		out.append({"key": open_key, "text": "回應：%s" % forced_message})
	else:
		out.append({"key": advance_key, "text": advance_label})
	for r in self_rows:
		if out.size() >= 3:
			break
		if bool(r["enabled"]):
			out.append({"key": open_key, "text": "互動 ▸ [%s]%s" % [r["key"], r["label"]]})
	if out.size() < 3 and forced_message != "":
		out.append({"key": advance_key, "text": advance_label})
	# ★可做的動作不到兩個 ⇒ 用呼叫端給的後備鍵補滿三行（仍是當下按得到的鍵）
	for f in fallback:
		if out.size() >= 3:
			break
		out.append(f)
	return out
