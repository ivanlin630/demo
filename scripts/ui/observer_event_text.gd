# scripts/ui/observer_event_text.gd — 事件人話 formatter（UI 層）。
# type→中文模板，填 leader 人名/隊名/數字（帶單位）；probe 味 description UI 層改寫，
# 已人話者直用；未知 type fallback description。read-only。
class_name ObserverEventText

const RES_NAMES: Dictionary = {
	"food": "糧食", "material": "木料", "coin": "錢", "goods": "貨品", "gem": "寶石",
	"ore_iron": "鐵礦", "ore_steel": "鋼", "ore_gold": "金礦", "ore_silver": "銀礦",
	"weapon_melee_low": "粗製近戰武器", "weapon_melee_high": "精製近戰武器",
	"weapon_ranged_low": "粗製遠程武器", "weapon_ranged_high": "精製遠程武器",
	"mounts": "馬匹", "wagons": "貨車", "arrows": "箭矢", "medicine": "藥品",
	"tools": "工具", "armor_low": "粗製甲", "armor_high": "精製甲",
}

static func stamp(msg: MessageData) -> String:
	var month: int = msg.origin_tick / WorldState.TICKS_PER_MONTH + 1
	var day: int = (msg.origin_tick % WorldState.TICKS_PER_MONTH) / WorldState.TICKS_PER_DAY + 1
	return "[月%d日%d]" % [month, day]

static func render(state: WorldState, msg: MessageData) -> String:
	return "%s %s" % [stamp(msg), _body(state, msg)]

# 隊過濾 match 集：origin_team_id + params 內 team id 欄
static func related_teams(msg: MessageData) -> Array:
	var ids: Dictionary = {msg.origin_team_id: true}
	for k in ["origin", "target", "loser", "origin_team"]:
		if msg.params.has(k) and str(msg.params[k]).is_valid_int():
			ids[int(str(msg.params[k]))] = true
	return ids.keys()

static func _tl(state: WorldState, raw) -> String:
	return ObserverQueryApi.team_label(state, int(str(raw)))

static func _body(state: WorldState, msg: MessageData) -> String:
	var p: Dictionary = msg.params
	var org = p.get("origin", msg.origin_team_id)
	match msg.type:
		"combat_start":
			return "%s 向 %s 宣戰" % [_tl(state, org), _tl(state, p.get("target", -1))]
		"combat_end":
			return "%s 擊潰 %s" % [_tl(state, org), _tl(state, p.get("loser", -1))]
		"subjugate":
			var fl: String = ObserverQueryApi.faction_label(state, int(str(p.get("faction", "-1"))))
			if fl == "":
				return "%s 收服 %s" % [_tl(state, org), _tl(state, p.get("loser", -1))]
			return "%s 收服 %s，納入%s" % [_tl(state, org), _tl(state, p.get("loser", -1)), fl]
		"captives_taken":
			return "%s 俘獲 %s 部眾 %d 人" % [_tl(state, org), _tl(state, p.get("loser", -1)), int(p.get("count", 0))]
		"assim_complete":
			return "%s 同化俘虜 %d 人，收為己用" % [_tl(state, org), int(p.get("count", 0))]
		"revolt":
			return "%s 俘虜暴動：%d 人脫離（鎮壓亡 %d 人）" % [_tl(state, org), int(p.get("total", 0)), int(p.get("slain", 0))]
		"flee":
			if String(p.get("reason", "")) == "released":
				return "%s 無力供養，釋放俘虜 %d 人" % [_tl(state, org), int(p.get("count", 0))]
			return "%s 俘虜 %d 人趁隙逃亡" % [_tl(state, org), int(p.get("count", 0))]
		"faction_establish":
			var nm: String = String(p.get("name", ""))
			if nm == "":
				return "%s 立國" % _tl(state, org)
			return "%s 立國，號「%s」" % [_tl(state, org), nm]
		"faction_defect":
			return "%s 脫離所屬勢力" % _tl(state, org)
		"outpost_built":
			return "%s 在(%s,%s)建成%s" % [_tl(state, org), str(p.get("x", "?")), str(p.get("y", "?")), String(p.get("name", "據點"))]
		"extortion":
			return "%s 向 %s 強收過路費" % [_tl(state, org), _tl(state, p.get("target", -1))]
		"tribute":
			return "%s 向 %s 徵收（稅率 %s）" % [_tl(state, org), _tl(state, p.get("target", -1)), str(p.get("rate", "?"))]
		"diplomacy":
			return "%s 與 %s 締盟" % [_tl(state, org), _tl(state, p.get("target", -1))]
		"order_delivered":
			return "%s 傳令 %s：%s" % [_tl(state, org), _tl(state, p.get("target", -1)), str(p.get("task", "?"))]
		"aid_given":
			return "%s 援助 %s %s 糧" % [_tl(state, org), _tl(state, p.get("target", -1)), str(p.get("amount", "?"))]
		"aid_refused":
			return "%s 拒絕援助 %s" % [_tl(state, org), _tl(state, p.get("target", -1))]
		"trade_done":
			return "%s 完成一筆貿易" % _tl(state, org)
		"famine_warning":
			return "%s 轄地歉收，糧食吃緊" % _tl(state, org)
		"split":
			return "%s 內部分裂，出走者自立" % _tl(state, org)
		"replace":
			return "%s 領袖遭替換" % _tl(state, org)
		"order_buy", "order_sell":
			var res_n: String = RES_NAMES.get(String(p.get("res", "")), String(p.get("res", "?")))
			var verb: String = "收購" if msg.type == "order_buy" else "出售"
			return "%s 張貼%s%s×%d 訂單" % [_tl(state, org), verb, res_n, int(p.get("qty", 0))]
		_:
			return msg.description
