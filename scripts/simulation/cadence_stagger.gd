class_name CadenceStagger

# ★★★cadence 錯峰（spec 2026-08-27 cadence-stagger）——【單一真值】：所有 cadence 排程都呼這一支。
#
# ★病（實測）：`next = current_tick + CADENCE` 一律固定 ⇒ ★同時起跑的隊【永遠同批到期】
#   ⇒ ambition 每 ~100 tick 爆一次（105~110 隊同批）、order 每 ~120 tick 一次
#   ⇒ burst tick dt 中位數 14.9M vs non-burst 4.2M ＝ 3.5×。
#
# ★★兩層偏移，缺一不可：
#   ①**打散**：offset 由 `team_id` 經【混合函式】導出（★不直接 `%`）⇒ 相位與 id 順序無關。
#   ②**輪轉**：offset 逐 cycle 變化 ⇒ 長期沒有人固定排在前面。
#   ★★★只做①不夠（R² 的理由）：**就算 hash 完全打散，只要 offset 是【固定終身】的，
#     「誰抽到好位置」會【隨時間複利成優勢】** —— 早想的隊先搶資源，優勢滾雪球。
#     ①防「起手不公平」，②防「起手公平但機制自己把它變不公平」。
#
# ★★★★三個最容易做錯的（spec 點名）：
#   ①`cycle_index` 必須是 `current_tick` 的【純函式】—— ★禁另存遞增計數器
#     （存檔／重播／多執行緒都要跟著同步一個新變數，而它遲早會不同步）。
#   ②★wrap 邊界必須 clamp：`offset` 在 `C−1 → 0` 那次輪轉，差值是 `−(C−1)`
#     ⇒ ★★同隊相鄰思考間隔會【塌成 1 tick】。★★★wrap 是模數輪轉的內在性質，
#     換公式消不掉 —— 只能【夾住後果】：`next >= last_eval + MIN_GAP`。
#   ③`MIN_GAP` 由 `cadence` 導出（`/2`），★不得手抄一個新的魔術常數。
#
# ★★禁 RNG：偏移不得用 `randf()/randi_range()`（血證：濾鏈含 RNG 副作用曾讓 pointwise dirty）。
#   本檔零 RNG —— 全部是整數算術，同 `(tick, team_id, cadence)` 恆得同一個答案。

# ★MIN_GAP 的除數：由 cadence 導出，不是獨立旋鈕（★改它等於改「最短思考間隔佔一個週期的比例」）。
const MIN_GAP_DIVISOR: int = 2

# ★整數混合（★零 RNG、純函式）：讓 offset 與 team_id 的【順序】無關 ——
#   直接 `team_id % cadence` 會讓 id 相鄰的隊相位也相鄰，而 id 常常就是生成順序。
static func _mix(a: int, b: int) -> int:
	var h: int = a * 0x9E3779B1 + b * 0x85EBCA6B
	h = (h ^ (h >> 15)) * 0x2545F491
	h = h ^ (h >> 13)
	return absi(h)

# ★★★下一次評估的 tick。★同 (current_tick, team_id, cadence) 恆回同一個值（純函式、可重播）。
#   `last_eval_tick` ＝ 本次評估發生的 tick（呼叫端就是剛評估完，所以傳 `current_tick`）。
static func next_tick(current_tick: int, last_eval_tick: int, team_id: int, cadence: int) -> int:
	if cadence <= 0:
		return current_tick + 1   # ★退化保護：cadence 非法時不製造無限迴圈（不靜默吞掉）
	# ①`cycle_index` 是 `current_tick` 的純函式 —— 沒有任何持久計數器
	var cycle_index: int = current_tick / cadence
	# ①打散 ＋ ②輪轉：offset 同時吃 team_id 與 cycle_index
	var offset: int = _mix(team_id, cycle_index) % cadence
	var candidate: int = (cycle_index + 1) * cadence + offset
	# ★候選必須真的在未來（offset 讓它落在下一個週期內，但退化 cadence 下仍保險）
	if candidate <= current_tick:
		candidate = current_tick + 1
	# ②wrap clamp：夾住「相鄰思考塌成 1 tick」的後果
	var min_gap: int = maxi(1, cadence / MIN_GAP_DIVISOR)
	return maxi(candidate, last_eval_tick + min_gap)

# ★給測試／床用：把 MIN_GAP 的導出方式暴露出來，★免得驗收端自己再抄一份 `cadence / 2`
#   （兩份會各自漂，而漂掉的那次不會有症狀）。
static func min_gap_of(cadence: int) -> int:
	return maxi(1, cadence / MIN_GAP_DIVISOR)
