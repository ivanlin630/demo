class_name FailureMemory

# ★執行失敗反饋機制 Phase 0（用戶立法〈執行失敗反饋鐵律〉、HOW spec 2026-08-21）。
# 法條：「執行失敗＝事件，必反饋決策層，禁靜默丟棄；同一原因禁無記憶反覆撞。」
#
# ★形狀（A1 五族照抄此形，故此處是「通用機制」不是單點修）：
#   ①記憶掛【隊層】`TeamData.recent_failures`（非 leader p.memory：那條 FIFO 與人際記憶共用、已知會被擠掉）
#   ②折價＝【連續乘數】（非硬 cooldown）：乘進既有 util，不新增 term 線（同 §4c site_bias 掛法）
#   ③freshness 線性衰減、過期歸零；count 連撞加深但【有上限】→ 不會永久封殺
#   ④★FLOOR：折價【絕不絕對否決】（同 §4c QUALITY_FLOOR 精神）→ 絕境仍可壓過折價再試
#   ⑤失效（計畫已不可行）→ 記憶 + T0 喚醒重想；劣勢（這次不划算）→ 只折價
#
# ★TTL 由 caller 給【相對錨定】值（例：掛單＝ORDER_LIFETIME、convoy＝回程 ETA），
#   不在此處發明全域絕對天數常數（守時間包 §2 規約）。
#
# ★可觀測（spec §2(b)，接全量暫態可觀測性不變量）：
#   `failure.recorded.<reason>` ＝ 失敗真的被記下；`failure.suppressed.<option>` ＝ 折價真的生效。
#   ★沒有後者，就會把「大家都放棄了」誤讀成「症狀解決了」——用反饋消滅症狀≠消滅病。

const FLOOR: float = 0.25          # TEST VALUE — 折價下限（絕不歸零、絕境仍可翻盤）
# ★INTENSITY × COUNT_CAP 刻意 < 1−FLOOR：count 上限先咬住（0.2×3 → 0.4），FLOOR 才是真正的
# 「永不歸零」安全網而非同一條線；兩個機制若重合，count 上限就是裝飾。
const INTENSITY: float = 0.2       # TEST VALUE — 單次新鮮失敗的折價強度
const COUNT_CAP: int = 3           # TEST VALUE — count_factor 上限（連撞加深到此為止）

# ★接線表（A1 五族照抄的地方就是這張表）：決策 option → 它依賴的那件事的失敗 key。
# 例：「買糧」依賴的是【food 買單真的被填】；買單一再到期沒人送 → 下輪別再一頭撞市場。
# 未列的 option ＝ 無折價（1.0），故本機制對其餘 option 零行為。
const OPTION_FAIL_KEY: Dictionary = {
	"買糧": ["買單", "food"],
	"買料": ["買單", "material"],
}

static func key(option: String, target: String = "-") -> String:
	return "%s|%s" % [option, target if target != "" else "-"]

# 劣勢：這次不划算、計畫仍成立 → 只折價（不喚醒）。
static func record(state: WorldState, team: TeamData, option: String, target: String,
		ttl_ticks: int, reason: String) -> void:
	if team == null or ttl_ticks <= 0:
		return
	var k: String = key(option, target)
	var now: int = state.world.current_tick
	var e: Dictionary = team.recent_failures.get(k, {})
	var prev_count: int = int(e.get("count", 0))
	# 過期的舊筆不累加（同因但已隔太久＝重新開始，非永久累積）
	if not e.is_empty() and now - int(e.get("tick", now)) > int(e.get("ttl", ttl_ticks)):
		prev_count = 0
	team.recent_failures[k] = {"tick": now, "count": prev_count + 1, "ttl": ttl_ticks}
	prune(state, team)
	if Probe.enabled:
		Probe.bump("failure.recorded." + reason)
		Probe.bump_sample("failure.recorded", {
			"team": team.team_id, "key": k, "reason": reason,
			"count": prev_count + 1, "tick": now,
		}, 16)

# 失效：當前計畫已不可行（路不通／目標消失／仲裁拒絕已承諾任務）→ 記憶 + T0 喚醒該隊【當 tick】重想。
# ★kind 已在 WorldEvents.FUNC_KINDS 登記（否則 T0 對帳守衛看不到這個新來源）。
static func record_invalidation(state: WorldState, team: TeamData, option: String, target: String,
		ttl_ticks: int, reason: String) -> void:
	record(state, team, option, target, ttl_ticks, reason)
	WorldEvents.emit(state, "plan_invalidated", [team.team_id])
	if Probe.enabled:
		Probe.bump("failure.invalidated." + reason)

# 折價乘數 ∈[FLOOR,1.0]：乘進既有 util。無記憶→1.0（零成本、零行為）。
static func mult(state: WorldState, team: TeamData, option: String, target: String = "-") -> float:
	if team == null or team.recent_failures.is_empty():
		return 1.0
	var e: Dictionary = team.recent_failures.get(key(option, target), {})
	if e.is_empty():
		return 1.0
	var ttl: int = int(e.get("ttl", 0))
	if ttl <= 0:
		return 1.0
	var age: int = state.world.current_tick - int(e.get("tick", 0))
	var freshness: float = clampf(1.0 - float(age) / float(ttl), 0.0, 1.0)   # 線性衰減、過期歸零
	if freshness <= 0.0:
		return 1.0
	var count_factor: float = float(mini(int(e.get("count", 1)), COUNT_CAP))   # 連撞加深、有上限
	var m: float = clampf(1.0 - INTENSITY * count_factor * freshness, FLOOR, 1.0)
	if m < 1.0 and Probe.enabled:
		Probe.bump("failure.suppressed." + option)
		Probe.note("failure.suppressed_depth", 1.0 - m)
	return m

# bounded：過期項讀寫時順手清（不無界成長）。
static func prune(state: WorldState, team: TeamData) -> void:
	if team.recent_failures.is_empty():
		return
	var now: int = state.world.current_tick
	var dead: Array = []
	for k in team.recent_failures:
		var e: Dictionary = team.recent_failures[k]
		if now - int(e.get("tick", now)) > int(e.get("ttl", 0)):
			dead.append(k)
	for k in dead:
		team.recent_failures.erase(k)
	if Probe.enabled and not dead.is_empty():
		Probe.bump("failure.pruned")

# 決策引擎唯一入口：option 名 → 查接線表 → 折價乘數（未接線 option 恆 1.0＝零行為）。
static func mult_for_option(state: WorldState, team: TeamData, option: String) -> float:
	if team == null or team.recent_failures.is_empty():
		return 1.0
	var m = OPTION_FAIL_KEY.get(option)
	if m == null:
		return 1.0
	return mult(state, team, String(m[0]), String(m[1]))
