class_name DecisionTerms

const RESTOCK_DAYS: float = 5.0   # TEST VALUE：商隊糧低於此 → proactive 返家補給(> WARNING 3)
const NON_MERCHANT_TRADE_FACTOR: float = 0.3   # TEST VALUE：非商隊 roam-trade 軟壓(能但很少)
const LOOT_DRIVE_BASE: float = 1.0   # TEST VALUE — loot 驅力基值；× weight(loot 0..1) → loot util ≈ 0..1，危時不碾壓 survival(≥2)
const DESPERATION_DAYS: float = 3.0    # TEST VALUE — 食物低於此才入絕境 option（對齊 WARNING_DAYS）
const DESPERATION_SCALE: float = 1.2   # TEST VALUE — 絕境 drive 量級（對齊 survival-class 域，不碾壓 forage/restock）
const BEG_FLOOR_FACTOR: float = 0.5    # TEST VALUE — 乞食墊底（drive 略低於 join/camp）
const FACTION_DUTY_DRIVE: float = 1.5   # TEST VALUE — 派系協同量級（攻擊/徵收/外交同級；commander-v2 單意圖後成員一次服務一意圖的子命令=無同級矛盾，war-priority LESSER 已 revert）
const DEFECT_AMBITION_K: float = 1.0    # TEST VALUE — 野心折損 faction_duty 權重斜率（脫軌逃閥）
const ATTACK_DRIVE_BASE: float = 0.3    # TEST VALUE — 個人參戰基值；× attack weight(好戰/殘忍)=染色 HOW
const STAKES_DRIVE_BASE: float = 0.3    # TEST VALUE — 徵收/外交 個人 drive 基值（沿用 ATTACK_DRIVE_BASE 值，獨立便調）
const BUYFOOD_DIST_FULL: float = 6.0    # TEST VALUE — 買糧旅費折扣基準距離（≤此距離不折扣，遠則衰減）
const RESTOCK_MIN: float = 10.0         # TEST VALUE — 家糧倉至少這麼多 food 才值得返家補給（空家不返）
const MATERIAL_TRADE_MIN: float = 20.0  # TEST VALUE — material/ore 達此量即視為可換糧籌碼（forest/mountain 特產）
# ── means-end 戰術層（2026-07-01）：intent → 子需求 → option 貢獻打分（mirror FACTION_DUTY_DRIVE）──
const INTENT_FIT_DRIVE: float = 1.5     # TEST VALUE — 意圖反應量級（mirror faction_duty；戰術層 reshape 強度）
const SURPLUS_FOOD_DAYS: float = 7.0    # TEST VALUE — 「有餘糧」門檻（致富→囤貨/貿易 子需求觸發）
const SCARCITY_RAID_MIN: float = 0.55   # TEST VALUE — 匱乏→搶的野心/好戰門檻（防 over-war：溫和窮隊不搶）
# ── 佔村（雙引擎咬合：奪據點→據點產糧養兵，複用 capture+residency）──
const OCCUPY_DRIVE_BASE: float = 1.2    # TEST VALUE — 佔村驅力基值（× occupy weight ≈ 0.4-0.7 → util 略勝 loot，要根據地的狼優先打村）
const OCCUPY_MIN_POP: int = 6           # TEST VALUE — 佔村最低 pop（守得住+夠日後分駐 settler，對齊 _dispatch_subteam_settle pop 需求）
# A2c-1（FA5 折入）：整併驅力（faction-level 機制，非個人 utility → flat 高量級，保真「現行恆 fire」）。
# 量級須 > mundane(生產/駐守/貿易 ≈0.3-0.6) + threat option(備戰/迎戰/求和 ≈0.5-0.9) → 現行 pre-gate
# 「除 survival-sticky 外恆 fire」保真。survival-sticky 由 TaskArbiter priority-gate 保（非 rank_scored 內
# 競秤）：獨立 _trigger_survival 設 PRIO_SURVIVAL(80) task → 整併走 _decide_unified PRIO_DISPATCH(50)
# 寫不進 = 同現行。稀有性/威脅競秤=A2d 深化,A2c-1 不碰(保恆 fire)。
const JOIN_LOW_AMBITION_FLOOR: float = 0.2   # TEST VALUE — 投靠 low-ambition factor 下限（野心滿也留殘值，餓極仍可投靠）
# capability grounding（裁2）：attack/loot eval 疊 self 戰力閘。有效武裝比達此→capability 足(=1)，
# 無牙→0（送死沒人幹，世界事實非 tag-label）。待平衡校。
const VIABLE_ARMED_RATIO: float = 0.3   # TEST VALUE
# 序7 reaction 溶入：team_panic → threat_pressure 疊加權重（潰散→survival util）。
# ★B 照妖鏡：team-state 驅（非全域行為常數），尚可；殘全域標 B 債（該由這隊膽識算，backlog）。
# 校準：max 0.5（team_panic∈[0,1]）遠 < survival_pressure 絕境量級（食0→12）→ panic 不喧賓奪主，
# 真 survival 絕境恆壓過 panic-only FLEE（三源序 survival 80 > panic 70 結構保）。
const PANIC_WEIGHT: float = 0.5   # TEST VALUE / B 債

# 脫軌逃閥因子：忠誠 − 野心溢出折損（loy 高→1，低忠誠高野心→0）。
# faction_duty weight 與 attack_drive drive 共用 = 叛離者既無 duty 亦無個人參戰驅力（「這不是我的仗」）。
static func _duty_factor(loy: float, amb: float) -> float:
	return clampf(loy - maxf(0.0, amb - 0.5) * DEFECT_AMBITION_K, 0.0, 1.0)

# 統一決策引擎：term 函式庫 + w_term 人格映射。
# eval：驅力強度（0..~1.5），term × opt 對應；不適用 opt 回 0。
# weight：leader 人格 → term 權重（分歧來源；bar #4，嚴禁抹平）。
# 全初值 = TEST VALUE（平衡 pass 調）。

static func eval(term: String, ctx: DecisionContext, opt: String) -> float:
	match term:
		"survival_pressure":
			# 重標度：吃飽(≥WARNING 3)→0 不蓋過 trade；糧危陡升量級支配(food2→4/food0→12)。
			if ctx.food_days >= 3.0: return 0.0
			return 4.0 * (3.0 - ctx.food_days)
		"restock_need":
			if opt != "返家補給": return 0.0
			# proactive 回家：~food4 起、量級隨糧降攀升(無上限,壓過覓食使有家偏好回家)。
			return maxf(0.0, 1.5 * (RESTOCK_DAYS - ctx.food_days))
		"threat_pressure":
			# survival(FLEE)=威脅驅動(與 hunger 分離)。序7 reaction 溶入：疊 team_panic（集體潰散=感知威脅放大，
			# 潰散抬 survival util 壓過 leader 勇氣）。★三源序保：panic 疊加 ≤ 真絕境（PANIC_WEIGHT 校，
			# max 0.5 << survival_pressure 量級 12），panic-only FLEE 走主 rank PRIO_DISPATCH(50)/threat 路 70,
			# 皆 < 真 survival-class PRIO_SURVIVAL(80) → 不喧賓奪主。
			return ctx.threat + ctx.team_panic * PANIC_WEIGHT
		"economic_opp":
			if opt != "貿易": return 0.0
			var role: float = 1.0 if ctx.is_merchant else NON_MERCHANT_TRADE_FACTOR
			return (0.8 if ctx.has_goods else 0.2) * (1.0 if ctx.has_arb else 0.3) * role
		"produce_need":
			if opt != "生產": return 0.0
			return 0.3 if ctx.has_goods else 0.6   # 已有貨→低
		"ambition_drive":
			# 階梯缺口 → 爬階靠「做東西」(生產/建設)，非貿易（貿易是賺錢非爬階）。
			# 貿易移出 → 野心 magnitude 不再同步抬貿易，霸主(野心高)與商人(貪婪高)才分得開。
			if opt not in ["生產", "建設"]: return 0.0
			return clampf(float(ctx.ambition_gap) * 0.3, 0.0, 1.0)
		"loot_drive":
			if opt != "掠奪": return 0.0
			if not ctx.has_weak_prey: return 0.0
			# capability grounding：無牙→cap≈0 壓平（送死沒人幹）；武裝足→cap=1。
			var cap: float = clampf(ctx.self_armed_ratio / VIABLE_ARMED_RATIO, 0.0, 1.0)
			return LOOT_DRIVE_BASE * cap   # TEST VALUE
		"occupy_drive":
			# 佔村 = 要根據地：無自家 outpost 的流浪狼最需要（base_need=1），有 outpost 但征服 intent 弱驅（0.3）。
			# 連續 util，與掠奪同 menu 秤 argmax（零新判斷器）。人格染色走 weight("occupy")。
			# 要根據地驅力（純野心 base_need；匱乏→奪產村的 hunger boost 走 intent_fit term，與掠奪 parallel）。
			# 人格染色走 weight("occupy")。無 outpost 流浪狼 base_need=1（最需要），有 outpost 弱驅 0.3。
			if opt != "佔村" or not ctx.has_occupy_target: return 0.0
			return OCCUPY_DRIVE_BASE * (1.0 if not ctx.has_own_outpost else 0.3)
		"join_drive":
			# S-A：has_strong_neighbor 硬 gate 移出 eval → options.gd applicable 前提（食壓驅 join 不限強鄰）。
			if opt != "投靠": return 0.0
			return DESPERATION_SCALE * maxf(0.0, DESPERATION_DAYS - ctx.food_days)
		"camp_drive":
			if opt != "紮營" or not ctx.has_farmable_tile: return 0.0
			return DESPERATION_SCALE * maxf(0.0, DESPERATION_DAYS - ctx.food_days)
		"beg_drive":
			if opt != "乞食" or not ctx.has_aid_target: return 0.0
			return DESPERATION_SCALE * BEG_FLOOR_FACTOR * maxf(0.0, DESPERATION_DAYS - ctx.food_days)
		"buyfood_drive":
			# 餓 + 有市集 + 有錢 → 買糧 drive；旅費折扣（近市集勝遠市集）。無錢=0（乞食真語意）。
			if opt != "買糧" or not ctx.has_food_market or not ctx.has_specie: return 0.0
			var hunger: float = DESPERATION_SCALE * maxf(0.0, DESPERATION_DAYS - ctx.food_days)
			var dist_disc: float = BUYFOOD_DIST_FULL / maxf(float(ctx.food_market_dist), BUYFOOD_DIST_FULL)
			return hunger * dist_disc
		"feud_pull":
			return ctx.strongest_feud if opt == "攻擊" else 0.0
		"faction_duty":
			# 派系 stakes directive 響應（頂層決 WHETHER）；weight 受 loyalty 調=脫軌逃閥。
			match opt:
				"攻擊": return FACTION_DUTY_DRIVE if ("攻擊" in ctx.faction_stakes and ctx.faction_attack_target != -1) else 0.0
				"徵收": return FACTION_DUTY_DRIVE if ("徵收" in ctx.faction_stakes and ctx.faction_tribute_target != -1) else 0.0
				"外交": return FACTION_DUTY_DRIVE if ("外交" in ctx.faction_stakes and ctx.faction_diplo_target != -1) else 0.0
				# A2a 歸建：子隊服從母團權威 = duty 驅（同一 duty/loyalty 機制，零子隊專屬 term）。
				# weight 已 _duty_factor(loyalty,野心)→忠誠子隊歸建 util 高；不忠→塌，掠奪贏。
				"歸建": return FACTION_DUTY_DRIVE if ctx.is_subteam else 0.0
			return 0.0
		"attack_drive":
			# 個人參戰 drive（人格染 HOW）；× attack weight=好戰/殘忍染色。受 loyalty 調=叛離者不參戰。
			if opt != "攻擊" or "攻擊" not in ctx.faction_stakes: return 0.0
			var loy: float = float(ctx.leader_values.get("_loyalty", 0.5))
			var amb: float = float(ctx.leader_values.get("野心", 0.5))
			return ATTACK_DRIVE_BASE * _duty_factor(loy, amb)
		"levy_drive":
			# 徵收個人 drive（貪婪/好戰染 HOW）；受 loyalty 調=叛離者不徵收。
			if opt != "徵收" or "徵收" not in ctx.faction_stakes: return 0.0
			return STAKES_DRIVE_BASE * _duty_factor(float(ctx.leader_values.get("_loyalty", 0.5)), float(ctx.leader_values.get("野心", 0.5)))
		"diplo_drive":
			# 外交個人 drive（義氣/計謀染 HOW）；受 loyalty 調=叛離者不外交。
			if opt != "外交" or "外交" not in ctx.faction_stakes: return 0.0
			return STAKES_DRIVE_BASE * _duty_factor(float(ctx.leader_values.get("_loyalty", 0.5)), float(ctx.leader_values.get("野心", 0.5)))
		"settle_fit":
			# 駐守 = 純知足（settle 主導，無 ambition pull）→ 給高 base，使低野心 leader 選它
			# 而非 建設/生產（後者另含 ambition_drive，野心 leader 才被推上去）。
			match opt:
				"駐守":        return 0.6
				"生產", "建設": return 0.4
				_:             return 0.0
		"intent_fit":
			# means-end 戰術層：team 自己戰略 intent → 子需求 → boost 對應 option（貢獻打分,非 flat）。
			# 人格染色（野心/貪婪/好戰）在 eval baked（mirror attack_drive 法）；weight("intent_fit")=1.0。
			return _intent_fit(ctx, opt)
		# ── 融合 threat（序1 溶入）：4 反應 repertoire（FLEE=survival / 備戰 / 迎戰 / 求和）──
		# 人格染色 baked in eval（mirror intent_fit/attack_drive 法；weight=1.0）。additive personality-dominant
		# 鏡射舊 _dispatch_threat_response scores（threat_react 只作小係數 modifier，非碾壓量級）——
		# 否則 threat_react unbounded(power_ratio 可大)會壓過 survival 絕境 drive。threat 有無由 applicable gate 管。
		"prepare_drive":
			# 備戰 = 純人格（鏡射舊 caution*0.6 + martial*0.3）。
			if opt != "備戰": return 0.0
			return float(ctx.leader_values.get("慎重", 0.5)) * 0.6 + float(ctx.leader_values.get("好戰", 0.5)) * 0.3
		"defend_drive":
			# 迎戰 = 好戰驅動，威脅越大越不敢正面（鏡射舊 martial*0.7 + (1−threat)*0.2）。
			if opt != "迎戰": return 0.0
			return float(ctx.leader_values.get("好戰", 0.5)) * 0.7 + (1.0 - ctx.threat_react) * 0.2
		"pacify_drive":
			# 求和 = 貪婪/信義驅動，好戰者不屑低頭（鏡射舊 greed*0.5 + honor*0.3 − martial*0.3）。
			if opt != "求和": return 0.0
			return float(ctx.leader_values.get("貪婪", 0.5)) * 0.5 + float(ctx.leader_values.get("信義", 0.5)) * 0.3 \
				- float(ctx.leader_values.get("好戰", 0.5)) * 0.3
		"consolidate_drive":
			# A2c-1（FA5 折入）：整併 target 存在才 fire；flat 高量級（faction-level 機制非個人染色）。
			# S-A 併決策統一：整併驅力退 flat → 食壓 scaled（mirror join_drive :91），target 存在才 fire。
			if opt != "整併" or ctx.consolidate_target_id == -1: return 0.0
			return DESPERATION_SCALE * maxf(0.0, DESPERATION_DAYS - ctx.food_days)
		"train_drive":
			# 野心階梯溶入（序3）：FORCE 累積/擴張階練兵 ambient drive（archetype/rung 導出於 ctx）。
			if opt != "訓練": return 0.0
			return ctx.ambient_train_drive
		_:
			return 0.0

# intent_fit：意圖→子需求→option 貢獻。三症狀（致富→貿易/囤貨、征服→攻擊、匱乏→搶）。
# 匱乏→搶獨立於 intent 類別（致富/生存皆可）但 gate（野心/好戰門檻 + 稀有 has_weak_prey）防 over-war。
static func _intent_fit(ctx: DecisionContext, opt: String) -> float:
	var amb: float = float(ctx.leader_values.get("野心", 0.5))
	var greed: float = float(ctx.leader_values.get("貪婪", 0.5))
	var martial: float = float(ctx.leader_values.get("好戰", 0.5))
	# capability grounding（裁2）：攻擊/掠奪 boost 疊 self 戰力閘（無牙→0，武裝足→1）。佔村非純戰(奪據)不閘。
	var cap: float = clampf(ctx.self_armed_ratio / VIABLE_ARMED_RATIO, 0.0, 1.0)
	# ── 匱乏→搶（自平衡關鍵：窮則搶）──：低糧 + 野心/好戰過門檻 + 有弱 prey → 掠奪/攻擊 boost。
	# 溫和窮隊（amb/martial 皆低）→ 0 → 仍走 survival（不全民劫掠潮）。scale 隨飢餓（對齊 desperation 域）。
	if ctx.food_days < DESPERATION_DAYS and (amb >= SCARCITY_RAID_MIN or martial >= SCARCITY_RAID_MIN):
		var hunger: float = maxf(0.0, DESPERATION_DAYS - ctx.food_days)
		if opt == "掠奪" and ctx.has_weak_prey:
			# 搶=既有掠奪 affordance boost（非升級全面攻擊 → 不 over-war）。無牙→cap≈0（餓也搶不動）。
			return INTENT_FIT_DRIVE * hunger * (0.5 + maxf(amb, greed) * 0.5) * cap
		if opt == "佔村" and ctx.has_occupy_target:
			# 佔=奪產村解糧（與掠奪 parallel 同 boost；狼在此秤「搶了就走 vs 佔住」，佔的 base_need edge 在 occupy_drive）。
			return INTENT_FIT_DRIVE * hunger * (0.5 + maxf(amb, martial) * 0.5)
	# ── 意圖類別 reshape ──
	match ctx.intent:
		"致富":
			# 有餘糧 → 囤貨低買高賣子需求 → 貿易 + 囤貨 boost（症狀 a：建設碾貿易 → 貿易勝出）。
			if ctx.food_days >= SURPLUS_FOOD_DAYS and opt in ["貿易", "囤貨"]:
				return INTENT_FIT_DRIVE * (0.5 + greed * 0.5)
		"征服":
			# 削敵→俘虜→守 子需求 → 攻擊 boost（症狀 b：征服真驅乾淨攻擊鏈）。無牙→cap≈0（無牙征服=送死）。
			# 序5 溶入：× readiness factor（沒本錢→趨0=readiness 閘，合憲法「狀態=權重非硬閘」）+ 信義 penalty
			# （對齊舊 cascade attack_score 野心+好戰−信義；高信義者不屑掠人）。readiness_thr_eff 含慎重+hunger_relief。
			if opt == "攻擊" and (ctx.intent_target != -1 or ctx.has_weak_prey):
				var honor: float = float(ctx.leader_values.get("信義", 0.5))
				var conq_person: float = clampf(0.5 + maxf(amb, martial) * 0.5 - honor * 0.4, 0.0, 1.5)
				var readiness_factor: float = clampf(ctx.readiness / maxf(ctx.readiness_thr_eff, 0.01), 0.0, 1.0)
				return INTENT_FIT_DRIVE * conq_person * cap * readiness_factor
	return 0.0

static func weight(term: String, leader_values: Dictionary) -> float:
	var v := leader_values
	match term:
		"survival_pressure": return 1.0   # survival 權重恆高（人人怕死）
		"economic":          return 0.3 + float(v.get("貪婪", 0.5))
		"attack":            return 0.2 + float(v.get("好戰", 0.5)) + float(v.get("殘忍", 0.5)) * 0.3
		# 野心 magnitude → 成長驅力權重；低野心(知足)壓到 0（無爬階拉力），高野心放大。
		# 無 0.2 floor（floor 會讓知足 leader 也被推去成長 → 抹平 TC4/TC7）。
		"ambition":          return clampf(float(v.get("野心", 0.5)) - 0.2, 0.0, 1.0) * 1.5
		"settle":            return float(v.get("義氣", 0.5)) * 0.5 + float(v.get("慎重", 0.5)) * 0.5
		"feud":              return 0.3 + float(v.get("好戰", 0.5)) * 0.5
		"faction_duty":      return _duty_factor(float(v.get("_loyalty", 0.5)), float(v.get("野心", 0.5)))
		"levy":              return 0.2 + float(v.get("貪婪", 0.5)) * 0.5 + float(v.get("好戰", 0.5)) * 0.3
		"diplo":             return 0.2 + float(v.get("義氣", 0.5)) * 0.5 + float(v.get("計謀", 0.5)) * 0.3
		"loot":              return float(v.get("殘忍", 0.5)) * 0.5 \
			+ float(v.get("好戰", 0.5)) * 0.3 + float(v.get("貪婪", 0.5)) * 0.2
		"occupy":            return float(v.get("野心", 0.5)) * 0.5 \
			+ float(v.get("好戰", 0.5)) * 0.3 + float(v.get("統領", 0.0)) * 0.2
		# S-A：+野心負向（野心高者不甘投靠→weight 疊 low-ambition factor；野心低+餓→投靠 util 高）。
		"join":              return (float(v.get("義氣", 0.5)) * 0.4 \
			+ float(v.get("信義", 0.5)) * 0.3 + float(v.get("求生欲", 0.5)) * 0.3) \
			* clampf(1.0 - float(v.get("野心", 0.5)), JOIN_LOW_AMBITION_FLOOR, 1.0)
		"camp":              return float(v.get("野心", 0.5)) * 0.4 \
			+ float(v.get("統領", 0.0)) * 0.3 + float(v.get("求生欲", 0.5)) * 0.3
		"beg":               return float(v.get("求生欲", 0.5))   # 人人可乞，墊底由 drive×BEG_FLOOR 壓低
		"buyfood":           return 1.0 if bool(v.get("_is_merchant", false)) else NON_MERCHANT_TRADE_FACTOR
		"intent_fit":        return 1.0   # 人格染色已在 eval baked（意圖不同→不同人格,故不走 weight 分歧）
		# S-A：整併 weight 退 flat → 人格秤（餓+不稱霸傾向併大）。求生欲主、低野心次。
		"consolidate_drive": return float(v.get("求生欲", 0.5)) * 0.6 + (1.0 - float(v.get("野心", 0.5))) * 0.4
		# ── 融合 threat：人格已 baked 進 eval（additive，鏡射舊 scores）→ weight=1.0（同 intent_fit）──
		"prepare", "defend", "pacify": return 1.0
		# 野心階梯溶入（序3）：練兵傾向=好戰/野心染色（ambient 低 magnitude 由 eval 壓，讓位緊急）。
		"train":             return 0.3 + float(v.get("好戰", 0.5)) * 0.4 + float(v.get("野心", 0.5)) * 0.2
		_:                   return 0.5
