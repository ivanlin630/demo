# scripts/ui/team_ui_helper.gd
# Static helpers for team member inspector UI (three-column layout).
class_name TeamUiHelper
extends Node

const COL_WIDTH: int = 26  # characters per column

# Pad or truncate string to exactly `width` chars.
static func _pad(s: String, width: int) -> String:
	if s.length() >= width:
		return s.substr(0, width)
	var out: String = s
	while out.length() < width:
		out += " "
	return out

# Combine three padded columns into one row string.
static func _cols(c1: String, c2: String, c3: String) -> String:
	return _pad(c1, COL_WIDTH) + _pad(c2, COL_WIDTH) + _pad(c3, COL_WIDTH)

# Divider row.
static func _divider() -> String:
	return "=".repeat(COL_WIDTH * 3)

# HP bar: "████░░  72/180"
static func _hp_bar(current: float, maximum: float, bar_len: int = 10) -> String:
	if maximum <= 0.0:
		return "?/??"
	var ratio: float = clampf(current / maximum, 0.0, 1.0)
	var filled: int = int(ratio * bar_len)
	var empty: int  = bar_len - filled
	var bar: String = "█".repeat(filled) + "░".repeat(empty)
	return "%s %d/%d" % [bar, int(current), int(maximum)]

# Body parts condensed: e.g. "頭:重 胸:健 右臂:健 左臂:健 右腿:健 左腿:健"
static func _body_summary(body_parts: Dictionary) -> String:
	var slot_names: Dictionary = {
		"head": "頭", "torso": "胸",
		"right_arm": "右臂", "left_arm": "左臂",
		"right_leg": "右腿", "left_leg": "左腿",
	}
	var status_short: Dictionary = {"healthy": "健", "wounded": "傷", "critical": "重", "severed": "截"}
	var parts: Array = []
	for slot in ["head", "torso", "right_arm", "left_arm", "right_leg", "left_leg"]:
		var bp: Dictionary = body_parts.get(slot, {})
		var st: String = status_short.get(bp.get("status", "healthy"), "?")
		parts.append("%s:%s" % [slot_names.get(slot, slot), st])
	return " ".join(parts)

# Equipment condensed: slot → grade (show only non-empty slots)
static func _equip_summary(equipped: Dictionary) -> Array:
	var slot_labels: Dictionary = {
		"hand_1": "主手", "hand_2": "副手",
		"head": "頭甲", "torso": "胸甲",
		"right_arm": "右臂甲", "left_arm": "左臂甲",
		"right_leg": "右腿甲", "left_leg": "左腿甲",
	}
	var lines: Array = []
	for slot in slot_labels:
		var grade: String = equipped.get(slot, {}).get("grade", "")
		if not grade.is_empty():
			lines.append("  %s: %s" % [slot_labels[slot], grade])
	if lines.is_empty():
		lines.append("  （無裝備）")
	return lines

# Top three values/skills by score.
static func _top3_dict(d: Dictionary) -> Array:
	var entries: Array = []
	for k in d:
		entries.append({"key": k, "value": float(d[k])})
	entries.sort_custom(func(a, b): return a["value"] > b["value"])
	var top: Array = entries.slice(0, mini(3, entries.size()))
	var result: Array = []
	for e in top:
		result.append("%s:%.2f" % [e["key"], e["value"]])
	return result

# ── Public API ──────────────────────────────────────────────────────────────

# Three-column header row for the member list.
static func render_header(team_name: String, tick: int) -> Array:
	return [
		_divider(),
		_cols("成員列表 — %s" % team_name, "Tick:%d" % tick, ""),
		_divider(),
	]

# One summary row per member (used in member list column).
# Returns a short single-line string.
static func render_member_list_row(member: Dictionary, col_width: int = COL_WIDTH) -> String:
	var role_tag: String = "[隊長]" if member.get("role", "") == "leader" else "[成員]"
	var name: String     = member.get("name", "?")
	var hp_c: float      = member.get("hp_current", 0.0)
	var hp_m: float      = member.get("hp_max", 1.0)
	var hp_pct: int      = int(clampf(hp_c / maxf(hp_m, 1.0), 0.0, 1.0) * 100)
	var stress: int      = int(member.get("stress", 0.0) * 100)
	return _pad("%s %s HP:%d%% 壓:%d%%" % [role_tag, name, hp_pct, stress], col_width)

# Detail panel for health submode.
static func render_health_detail(member: Dictionary) -> Array:
	var lines: Array = []
	lines.append("── 健康 ──")
	lines.append(_hp_bar(member.get("hp_current", 0.0), member.get("hp_max", 1.0)))
	lines.append("壓力:%.2f  恐懼:%.2f  忠誠:%.2f" % [
		member.get("stress", 0.0),
		member.get("fear", 0.0),
		member.get("loyalty", 1.0),
	])
	lines.append(_body_summary(member.get("body_parts", {})))
	return lines

# Detail panel for equipment submode.
static func render_equipment_detail(member: Dictionary) -> Array:
	var lines: Array = []
	lines.append("── 裝備 ──")
	lines.append_array(_equip_summary(member.get("equipped", {})))
	lines.append("── 背包 ──")
	var inv: Array = member.get("inventory", [])
	if inv.is_empty():
		lines.append("  （空）")
	else:
		for item in inv:
			lines.append("  %s ×%d" % [item.get("grade", "?"), item.get("qty", 0)])
	return lines

# Detail panel for stats submode (attributes + values + top skills).
static func render_stats_detail(member: Dictionary) -> Array:
	var lines: Array = []
	lines.append("── 屬性 ──")
	var attrs: Dictionary = member.get("attributes", {})
	for attr in attrs:
		lines.append("  %s: %.2f" % [attr, float(attrs[attr])])
	lines.append("── 前3技能 ──")
	for s in _top3_dict(member.get("skills", {})):
		lines.append("  " + s)
	lines.append("── 前3價值觀 ──")
	for v in _top3_dict(member.get("values", {})):
		lines.append("  " + v)
	return lines

# Quick card: one-glance overview (default submode).
static func render_quick_card(member: Dictionary) -> Array:
	var lines: Array = []
	lines.append("── 快覽 ──")
	lines.append("姓名: %s  身份: %s" % [member.get("name", "?"), member.get("role", "?")])
	lines.append(_hp_bar(member.get("hp_current", 0.0), member.get("hp_max", 1.0)))
	lines.append("壓力:%.2f  恐懼:%.2f  忠誠:%.2f" % [
		member.get("stress", 0.0),
		member.get("fear", 0.0),
		member.get("loyalty", 1.0),
	])
	var top_vals: Array = _top3_dict(member.get("values", {}))
	lines.append("價值觀: " + ", ".join(top_vals))
	var top_skills: Array = _top3_dict(member.get("skills", {}))
	lines.append("技能: " + ", ".join(top_skills))
	return lines

# Build the full three-column member mode string.
# left_col: list of member rows; right_col: detail panel lines for selected member.
static func render_three_columns(
		members_detail: Array,
		selection: int,
		detail_lines: Array,
		team_stats: Dictionary,
		team_name: String,
		tick: int) -> String:

	var out: Array = []
	out.append_array(render_header(team_name, tick))

	# Column 1: member list; Column 2: detail
	var list_rows: Array = []
	for i in range(members_detail.size()):
		var m: Dictionary = members_detail[i]
		var prefix: String = "▶ " if i == selection else "  "
		list_rows.append(prefix + render_member_list_row(m, COL_WIDTH - 2))

	var max_rows: int = maxi(list_rows.size(), detail_lines.size())
	for row_i in range(max_rows):
		var left: String  = list_rows[row_i] if row_i < list_rows.size() else ""
		var right: String = detail_lines[row_i] if row_i < detail_lines.size() else ""
		out.append(_pad(left, COL_WIDTH) + right)

	out.append("─".repeat(COL_WIDTH * 2))
	var ts_food: int      = team_stats.get("food_qty", 0)
	var ts_weight: float  = team_stats.get("carry_weight", 0.0)
	var ts_cap: float     = team_stats.get("carry_capacity", 1.0)
	var ts_count: int     = team_stats.get("member_count", 0)
	out.append("總人數:%d  食物:%d  負重:%.1f/%.1f" % [ts_count, ts_food, ts_weight, ts_cap])
	out.append("[W/S]選人 [1]快覽 [2]健康 [3]裝備 [4]能力 [P/Esc]關閉")
	return "\n".join(out)
