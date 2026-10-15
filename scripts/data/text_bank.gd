class_name TextBank

const TEMPLATES: Dictionary = {
	# ── 事件消息 ────────────────────────────────────────────────
	"subjugate": {
		"honest":        "Team{origin} 主服 Team{loser}，加入勢力{faction}",
		"unintentional": "聽說 Team{origin} 附近有收編，細節不清",
		"malicious":     "Team{origin} 被 Team{loser} 吞併（失真）",
		"vague":         "Team{origin} 附近勢力有變動",
	},
	"battle": {
		"honest":        "Team{origin} 在({x},{y})擊敗 Team{loser}",
		"unintentional": "Team{origin} 附近({x},{y})好像打起來了",
		"malicious":     "Team{origin} 在({x},{y})遭受重創（失真）",
		"vague":         "({x},{y})附近有衝突",
	},
	"betrayal": {
		"honest":        "Team{origin} 背叛了 Team{ally}",
		"unintentional": "Team{origin} 跟盟友鬧翻了",
		"malicious":     "Team{ally} 主動驅逐了 Team{origin}（失真）",
		"vague":         "Team{origin} 的盟約破裂",
	},
	"faction_establish": {
		"honest":        "Team{origin} 正式立國，號{name}",
		"unintentional": "Team{origin} 好像建了個組織",
		"vague":         "Team{origin} 有政治動作",
	},
	"diplomacy": {
		"honest":        "Team{origin} 與 Team{target} 締盟",
		"vague":         "Team{origin} 在談判",
	},
	"tribute": {
		"honest":        "Team{origin} 向 Team{target} 徵收（rate={rate}）",
		"vague":         "Team{origin} 在徵收資源",
	},
	"outpost_built": {
		"honest":        "Team{origin} 在({x},{y})建成{name}",
		"vague":         "Team{origin} 在({x},{y})有建設完工",
	},
	"order_delivered": {
		"honest":        "Team{origin} 傳令 Team{target} → task={task}",
		"vague":         "Team{origin} 發出指令",
	},
	"famine_warning": {
		"default":       "Team{origin} 轄地歉收（收成率 {harvest}）",
		"honest":        "({x},{y})附近歉收，糧食緊張",
		"vague":         "某地糧食不足",
	},

	# ── 副官台詞（情境通知） ─────────────────────────────────────
	"advisor_food_critical": {
		"default":   "主公，糧草告急，需速作安排",
		"blunt":     "沒糧了，快處理",
		"formal":    "啟稟主公，存糧已達危急水位，懇請早作因應",
		"sarcastic": "啊，又沒糧了，真是驚喜",
	},
	"advisor_enemy_approaching": {
		"default": "主公，有敵軍靠近",
		"blunt":   "來敵了，準備",
		"formal":  "稟報，偵查發現敵方兵馬向我方接近",
	},
	"advisor_faction_betrayed": {
		"default": "主公，盟友背叛了我們",
		"blunt":   "被賣了",
		"bitter":  "果然，信人者死",
	},

	# ── UI 文字 ─────────────────────────────────────────────────
	"ui_action_build_outpost":    { "label": "建造據點",  "desc": "在當格建造據點，需消耗資源" },
	"ui_action_dispatch_subteam": { "label": "派遣子隊",  "desc": "分出子隊執行任務" },
	"ui_action_recall_subteam":   { "label": "召回子隊",  "desc": "派信使子隊傳達撤回令" },
	"ui_action_gather_intel":     { "label": "打聽消息",  "desc": "向對方詢問情報" },
	"ui_inquiry_ask_team_location":  { "label": "附近有哪些人？", "desc": "詢問 NPC 知道的隊伍位置" },
	"ui_inquiry_ask_food_source":    { "label": "哪裡有糧食？",   "desc": "詢問食物資源地點" },
	"ui_inquiry_ask_enemy_movement": { "label": "敵方動向？",     "desc": "詢問最近的敵對隊伍" },
	"ui_inquiry_ask_recent_events":  { "label": "最近有什麼事？", "desc": "詢問最近事件消息" },
	"ui_inquiry_ask_faction_status": { "label": "勢力現況？",     "desc": "詢問勢力相關情報" },
}

# ── 外置文本（spec 2026-10-15-advisor-reads-belief-and-text-externalization-pilot §2a）──────────
# 每行 `鍵<TAB>變體<TAB>句`，# 開頭為註解。第一次查時讀進 static 快取；外置過的鍵從 TEMPLATES 刪掉。
#   ★同一 (鍵,變體) 在檔裡與 TEMPLATES 同時存在 ⇒ push_error（第二份真相）
#   ★其餘五檔搬的時候把檔名加進 EXTERNAL_FILES，text_keys_bed 同一支床就涵蓋
const EXTERNAL_FILES: Array = ["res://data/text/advisor.tsv", "res://data/text/names.tsv"]
const FALLBACK_SENTENCE: String = "Team{origin} 有動靜"
static var _ext: Dictionary = {}          # 鍵 → {變體 → 句}
static var _ext_src: Dictionary = {}      # 鍵 → 檔名（床對帳用）
static var _ext_loaded: bool = false
# ★測試旗（只在床開；production 預設關）：記每一次落到預設句、每一個被取用的 (鍵,變體)
static var record: bool = false
static var fallbacks: Array = []
static var used: Dictionary = {}

# ★跨 run：外置快取重讀（檔可能被改過）；床的取用紀錄清空（CrossRunReset 登記）
static func _reset_cross_run() -> Dictionary:
	var cleared: Dictionary = {}
	if not used.is_empty(): cleared["TextBank.used"] = used.size()
	if not fallbacks.is_empty(): cleared["TextBank.fallbacks"] = fallbacks.size()
	used.clear()
	fallbacks.clear()
	_ext.clear()
	_ext_src.clear()
	_ext_loaded = false
	return {"checked": 1, "cleared": cleared}

static func _ensure_loaded() -> void:
	if _ext_loaded:
		return
	_ext_loaded = true
	for path in EXTERNAL_FILES:
		var f := FileAccess.open(String(path), FileAccess.READ)
		if f == null:
			push_error("[TextBank] 讀不到外置文本 %s" % path)
			continue
		while not f.eof_reached():
			var line: String = f.get_line()
			if line.strip_edges() == "" or line.begins_with("#"):
				continue
			var cols: PackedStringArray = line.split(String.chr(9))
			if cols.size() < 3:
				push_error("[TextBank] %s 這一行不是 鍵<TAB>變體<TAB>句：%s" % [path, line])
				continue
			var k: String = cols[0]
			var v: String = cols[1]
			if TEMPLATES.has(k) and (TEMPLATES[k] as Dictionary).has(v):
				push_error("[TextBank] (%s,%s) 同時在 %s 與 TEMPLATES ⇒ 第二份真相" % [k, v, path])
			if not _ext.has(k):
				_ext[k] = {}
			_ext[k][v] = cols[2]
			_ext_src[k] = String(path)

static func external() -> Dictionary:
	_ensure_loaded()
	return _ext

static func external_source(key: String) -> String:
	_ensure_loaded()
	return String(_ext_src.get(key, ""))

# 查句（不 format）：外置表 → TEMPLATES → ""（查不到）
static func lookup(type: String, variant: String) -> String:
	_ensure_loaded()
	if _ext.has(type) and (_ext[type] as Dictionary).has(variant):
		if record: used["%s|%s" % [type, variant]] = true
		return String(_ext[type][variant])
	if TEMPLATES.has(type) and (TEMPLATES[type] as Dictionary).has(variant):
		if record: used["%s|%s" % [type, variant]] = true
		return String(TEMPLATES[type][variant])
	if record: fallbacks.append("%s|%s" % [type, variant])
	return ""

static func has_text(type: String, variant: String) -> bool:
	_ensure_loaded()
	return (_ext.has(type) and (_ext[type] as Dictionary).has(variant)) 		or (TEMPLATES.has(type) and (TEMPLATES[type] as Dictionary).has(variant))

static func fmt(type: String, variant: String, params: Dictionary = {}) -> String:
	var tmpl: String = lookup(type, variant)
	if tmpl == "" and not has_text(type, variant):
		tmpl = FALLBACK_SENTENCE
	return tmpl.format(params)

# 資源鍵 → 玩家畫面顯示名（names.tsv，唯一一張表）；查不到回原鍵（終端自驗 (d) 會咬）
static func res_name(key: String, variant: String = "full") -> String:
	var s: String = lookup("res." + key, variant)
	return s if s != "" else key
