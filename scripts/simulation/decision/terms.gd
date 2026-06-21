class_name DecisionTerms

const RESTOCK_DAYS: float = 5.0   # TEST VALUE：商隊糧低於此 → proactive 返家補給(> WARNING 3)

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
			# survival(FLEE)=威脅驅動(與 hunger 分離)；threat 目前 0=休眠,他域遷入補。
			return ctx.threat
		"economic_opp":
			if opt != "貿易": return 0.0
			return (0.8 if ctx.has_goods else 0.2) * (1.0 if ctx.has_arb else 0.3)
		"produce_need":
			if opt != "生產": return 0.0
			return 0.3 if ctx.has_goods else 0.6   # 已有貨→低
		"ambition_drive":
			# 階梯缺口 → 爬階靠「做東西」(生產/建設)，非貿易（貿易是賺錢非爬階）。
			# 貿易移出 → 野心 magnitude 不再同步抬貿易，霸主(野心高)與商人(貪婪高)才分得開。
			if opt not in ["生產", "建設"]: return 0.0
			return clampf(float(ctx.ambition_gap) * 0.3, 0.0, 1.0)
		"feud_pull":
			return ctx.strongest_feud if opt == "攻擊" else 0.0
		"settle_fit":
			# 駐守 = 純知足（settle 主導，無 ambition pull）→ 給高 base，使低野心 leader 選它
			# 而非 建設/生產（後者另含 ambition_drive，野心 leader 才被推上去）。
			match opt:
				"駐守":        return 0.6
				"生產", "建設": return 0.4
				_:             return 0.0
		_:
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
		_:                   return 0.5
