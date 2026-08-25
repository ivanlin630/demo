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

# ★★結構身分 key（磚 2026-08-25，blueprint 定 / systems 裁 (B)）：
#   舊的 `OPTION_FAIL_KEY` 人工表【已刪】。它不只是懶人表，是「記錄側講依賴、決策側講動作」
#   這兩種語彙之間的橋；橋既然改放在【記錄側】（下令時自帶身分），表就沒有存在理由。
#
#   key ＝ `(結構身分 id, 目標 id)`：
#     • 靜態 option  ⇒ id ＝ option 名（`買糧`／`買料`…），目標多半為空 ⇒ 退化成 `(id, ∅)`
#     • goal candidate ⇒ id ＝ `goal_type:frontier_kind`（★由結構欄位組出，不反解 label），目標 ＝ 該動作的目標
#   ⇒ ★覆蓋是【構造性】的：每個動作天生有身分，沒有表可漏。
#   ⛔ 先做 exact-pair；★類級泛化（折掉所有同類）**不預做** —— 過度泛化 ＝ 懲罰擴散、反傷探索。
static func key(structural_id: String, target: String = "-") -> String:
	return "%s|%s" % [structural_id, target if target != "" else "-"]

# ★★失敗三分類（blueprint 裁 2026-08-25，形式＝【反饋分流】不是 key 增維 —— key 維持 (結構id, target)）：
#   ①前提型（缺料/缺人/付不起 ＝ 計畫好、世界沒備妥）⇒ ★不折價，記 `blocked_by`
#   ②執行型（真試真敗）                              ⇒ 折價 exact-pair（＝下面的 record）
#   ③失效型（目標消失/不可行）                        ⇒ T0（record_invalidation，既有不動）
#   ★型別是 fail【擲出點】的一次性結構標注（code 結構），不是另一張要平行維護的表。
#   ★原設計本來就有「失效升 T0／劣勢只折價」的二分；這次只是把它下沉到折價端，語意一致。
#
# ★前提型：不寫 recent_failures（不折價），只記「被什麼擋住」＋留 tap。
static func record_blocked(state: WorldState, team: TeamData, structural_id: String,
	target: String, blocker: String) -> void:
	if team == null or structural_id == "":
		# ★假設不靜默：【無身分可記】本身就是一個要量的事實。
		#   血證：`_dispatch_builder` 進入 28 次、資源不足 28 次，`blocked_total` 卻是 0
		#   —— 差別全部在這一行默默 return。
		if Probe.enabled and team != null: Probe.bump("failure.blocked_no_identity")
		return
	var k: String = key(structural_id, target)
	team.blocked_by[k] = {"blocker": blocker, "tick": state.world.current_tick}
	if Probe.enabled:
		Probe.bump("failure.blocked." + blocker)
		Probe.bump("failure.blocked_total")
		Probe.bump_sample("failure.blocked", {"team": team.team_id, "key": k,
			"blocker": blocker, "tick": state.world.current_tick}, 40)

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
		# ★★過渡窗 tap（reviewer 建議、systems 採納 2026-08-25）：
		#   我們接受「舊 key 記憶斷代」的理由是【一輪就換完】—— ★那是一個假設。
		#   依「假設不靜默」：假設要能自己喊出來，不能靠相信。
		#   ⇒ 記【新 key 空間的條目數】與【首次命中】：長期停在 0/極低 ＝ 新 key 根本沒被寫入
		#     ＝ 我們做出了第三個「恆 1.0」的機制（前兩隻：OPTION_FAIL_KEY 只接 2 個、exact-pair 命中率）。
		Probe.bump("failure.entries_written")
		Probe.note("failure.entries_max", float(team.recent_failures.size()))
		Probe.bump_sample("failure.first_hit", {"tick": now, "team": team.team_id,
			"key": k, "reason": reason}, 1)   # cap 1 ⇒ first-N 正好給【第一次】
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

# ★決策引擎【唯一】入口（§4：一套記憶、一個查詢入口——不准 candidate 用新的、option 用舊的）。
#   查的就是這個動作自己的結構身分，不再經任何對照表。
static func mult_for(state: WorldState, team: TeamData, structural_id: String, target: String = "") -> float:
	if team == null or team.recent_failures.is_empty() or structural_id == "":
		return 1.0
	return mult(state, team, structural_id, target)
