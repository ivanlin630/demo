# @observe-pure  ★純讀零寫零 RNG（觀測儀器不擾世界）
class_name EphemeralStateHash

# ★★★專門量【state_fingerprint 排除掉的那一半】的尺（debug 側，★不動 production fp）。
#
# ★動機（systems 2026-09-01）：`state_fingerprint.gd:69` 自述它排除
#   ephemeral 快取（food_runway / persist_strength / food_flow_avg / need_urgency）
#   ＋ cadence 排程欄（*_eval_next_tick）＋ observer/probe
#   ⇒ ★★而那【正是】tracer 污染會落在的那些欄
#   ⇒ ★★★所以「fp 逐位元相同」對這個 bug 類別是【結構性地瞎的】——
#     它不是量不到，是【設計上就不看】。
#
# ★★本尺與 fp 是【互補】不是替代：
#   fp 答「世界的決策/生命週期狀態有沒有變」；本尺答「快取與排程有沒有被碰過」。
#   ⇒ ★★★兩把尺都要報，而且各自的【排除清單】要印在它自己的輸出旁邊。

const QUANT: float = 10000.0   # 同 StateFingerprint：float 量化 1e-4，避浮點格式噪

# ★本尺【涵蓋】什麼（★印在輸出旁邊，不要只寫在這裡）
const COVERS: String = "team{food_runway,persist_strength,food_flow_avg,need_urgency,plan_phase," \
	+ "expand_eval_next_tick,expand_site_cached,consolidate_*_cache,consolidate_eval_next_tick}" \
	+ " ／ tile{labor_alloc,labor_eval_next_tick,idle_employ_cached,idle_employ_next_tick}"

# ★本尺【不涵蓋】什麼（★誠實限：它也是一把有邊界的尺）
const BLIND: String = "★不含 fp 已涵蓋的那半（task/pos/資源/belief…）；" \
	+ "★★也不含【我沒列進 COVERS 的其他快取欄】—— 這是下界不是全集"

static func _q(v: float) -> int:
	return int(round(v * QUANT))

static func compute(state: WorldState) -> String:
	var buf: PackedStringArray = PackedStringArray()
	var tids: Array = state.teams.keys(); tids.sort()
	for tid in tids:
		var t: TeamData = state.teams[tid]
		var nu: PackedStringArray = PackedStringArray()
		for v in t.need_urgency:
			nu.append(str(_q(float(v))))
		buf.append("T%d|fr=%d|ps=%d|ffa=%d|pp=%s|nu=%s|eent=%d|esc=%d,%d|ctc=%d|atc=%d|cent=%d" % [
			int(tid), _q(t.food_runway), _q(t.persist_strength), _q(t.food_flow_avg),
			t.plan_phase, ",".join(nu),
			t.expand_eval_next_tick, t.expand_site_cached.x, t.expand_site_cached.y,
			t.consolidate_target_cache, t.absorb_target_cache, t.consolidate_eval_next_tick])
	var kids: Array = state.world.tiles.keys(); kids.sort()
	for k in kids:
		var tl: HexTileData = state.world.tiles[k]
		var la: PackedStringArray = PackedStringArray()
		var lk: Array = tl.labor_alloc.keys(); lk.sort()
		for key in lk:
			var d: Dictionary = tl.labor_alloc[key]
			la.append("%s:%d/%d/%d" % [str(key), _q(float(d.get("demand", 0.0))),
				_q(float(d.get("share", 0.0))), _q(float(d.get("fill", 0.0)))])
		buf.append("L%d|la=%s|lent=%d|iec=%d|ient=%d" % [
			int(k), ";".join(la), tl.labor_eval_next_tick,
			_q(tl.idle_employ_cached), tl.idle_employ_next_tick])
	return "\n".join(buf).md5_text()

# ★輸出時必附的一行（systems 2026-09-01 立為 invariant）：
#   ★★盲區必須出現在【使用它的當下】——「寫在檔案裡」不夠，因為沒有人回來看。
static func note() -> String:
	return "[EPHEMERAL-HASH] 涵蓋：%s｜%s" % [COVERS, BLIND]
