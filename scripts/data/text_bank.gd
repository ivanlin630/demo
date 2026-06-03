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

	# ── 副官建議（情境分析） ─────────────────────────────────────
	"advisor_assess_enemy": {
		"accurate_strong":     "敵方兵強（{enemy_pop}人），不宜正面，建議{action}",
		"accurate_weak":       "敵方兵寡（{enemy_pop}人），可以出擊",
		"wrong_underestimate": "敵方不多，問題不大",
		"wrong_overestimate":  "敵方恐怕難纏，小心",
		"biased_attack":       "強敵又如何，打！",
		"biased_retreat":      "哪怕弱敵，謹慎些好",
	},
	"advisor_diplomatic": {
		"accurate_hostile":  "對方心存敵意，外交恐怕無效",
		"accurate_friendly": "對方似乎願意合作",
		"wrong_read":        "對方看起來可以談談",
		"biased_war":        "管他外交，先打",
		"biased_peace":      "還是先談談吧",
	},
	"advisor_resources": {
		"accurate_critical":  "糧草撐不過{days}天，需立即處置",
		"accurate_stable":    "資源充裕，暫無憂慮",
		"wrong_optimistic":   "糧草沒問題，夠用",
		"wrong_pessimistic":  "物資快不夠了",
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

static func fmt(type: String, variant: String, params: Dictionary = {}) -> String:
	var tmpl: String = TEMPLATES.get(type, {}).get(variant, "Team{origin} 有動靜")
	return tmpl.format(params)
