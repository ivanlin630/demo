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

const FLOOR: float = 0.25          # ★真參數 — 在真實量上劃線＝設計選擇。世界答不出「應該幾天／該折多少」——而答不出就是它該留的證明。
#   （折價下限：絕不歸零、絕境仍可翻盤）
# ★INTENSITY × COUNT_CAP 刻意 < 1−FLOOR：count 上限先咬住（0.2×3 → 0.4），FLOOR 才是真正的
# 「永不歸零」安全網而非同一條線；兩個機制若重合，count 上限就是裝飾。
const INTENSITY: float = 0.2       # ★真參數 — 在真實量上劃線＝設計選擇。世界答不出「應該幾天／該折多少」——而答不出就是它該留的證明。
#   （單次新鮮失敗的折價強度）
const COUNT_CAP: int = 3           # ★真參數 — 在真實量上劃線＝設計選擇。世界答不出「應該幾天／該折多少」——而答不出就是它該留的證明。
#   （count_factor 上限：連撞加深到此為止）

# ★接線表（A1 五族照抄的地方就是這張表）：決策 option → 它依賴的那件事的失敗 key。
# 例：「買糧」依賴的是【food 買單真的被填】；買單一再到期沒人送 → 下輪別再一頭撞市場。
# 未列的 option ＝ 無折價（1.0），故本機制對其餘 option 零行為。
# ★TODO 指向的票（★它必須真的存在——同 .value-key-baseline.tsv 的 born-with 過期紅）
const TODO_TICKET: String = "docs/superpowers/specs/2026-09-09-failure-feedback-structural-enumeration-HOW.md"

const OPTION_FAIL_KEY: Dictionary = {
	"買糧": ["買單", "food"],
	"買料": ["買單", "material"],
	# ★階段 2 第一批（2026-09-09）：乞食被拒。
	#   ★target 走 `ctx:` 前綴＝【決策當下 ctx 裡的那個欄位】——因為施主是逐次決定的，
	#   寫死一個字串會變成「對任何人乞食失敗一次，就對所有人折價」（spec §5② 的「接太粗」）。
	"乞食": ["乞食", "ctx:aid_target_id"],
}

# ★★★缺席清單（階段 1，2026-09-09）：`OPTION_FAIL_KEY` 的【互補且互斥】另一半。
#   ★病：28 個 option 裡只有 2 個有失敗反饋，★★而缺席是【靜默】的——
#   `mult_for_option` 對沒列到的 option 回 1.0，跟「決定它不需要」長得一模一樣。
#   ⇒ 這份表讓每一個「沒有失敗反饋」都變成【有人決定的】而不是【沒人想過的】。
# ★判準（spec §3）：進 OPTION_FAIL_KEY 要三條全成立——
#   ①有一個【執行步驟】會失敗（做不成，不是效果不好）②失敗當下偵測得到 ③重試對同一個目標且會重複。
#   ⇒ 進本表的理由必須指名【哪一條不成立】，或 `TODO:<票路徑>`（★那張票必須真的存在）。
# ★★★而我在填的過程中發現判準少一格：有三個 option【已經有等價的失敗反饋，只是掛在靶地不在 option】
#   （SettlementMemory 的 site_failed → quality_multiplier）⇒ 它們既不是「不需要」也不是「還沒接」。
#   我用 `已有等價機制:` 前綴標它們，並已回報 systems（分類表不完整，不是這幾格不對）。
const NO_FAILURE_FEEDBACK: Dictionary = {
	# ── 該接，等階段 2（三條全成立；理由後面是【它已經存在的失敗訊號】）──
	"貿易": "TODO:%s ── trade.market_bail.<reason>（interaction_system:930 等）可偵測；同一市集重撞" % TODO_TICKET,
	"建設": "TODO:%s ── construction_abandoned 事件（faction_ai_system:6426）；同一工地重試" % TODO_TICKET,
	"自救建田": "TODO:%s ── 同「建設」，走同一條 construction_abandoned" % TODO_TICKET,
	"返家補給": "TODO:%s ── 路不通＝失效（movement_system 的 stuck 偵測）；法條指定這類升 T0" % TODO_TICKET,
	"掠奪": "TODO:%s ── 追不到／被擊退＝做不成，同一 prey 會重撞" % TODO_TICKET,
	"佔村": "TODO:%s ── 佔領被擋＝做不成，同一 village 會重撞" % TODO_TICKET,
	"併入": "TODO:%s ── join_rejected 已寫進 leader memory（interaction_system:1586）" % TODO_TICKET,
	"吸納": "TODO:%s ── 同上另一端（faction_ai_system:6331）" % TODO_TICKET,
	"外交": "TODO:%s ── envoy.reject（interaction_system:582）全庫 152 reject / 6 accept；systems 已判三條全成立" % TODO_TICKET,
	"遷移找糧": "TODO:%s ── 到場沒糧＝只折價、路不通＝失效（法條兩類都在這條路上）" % TODO_TICKET,
	"囤貨": "TODO:%s ── convoy dispatch 的 7 個靜默 return false（法條指定的第一份清單）" % TODO_TICKET,
	"求和": "TODO:%s ── 求和會被拒（diplomatic_ai_system:186 的 reject 路徑）" % TODO_TICKET,
	"歸建": "TODO:%s ── committed 卻不 dispatch 的 drop 點（手不聽腦 mini-arc 的 subteam-idle-latch）" % TODO_TICKET,
	# ── 已有等價機制：失敗反饋存在，只是掛在【靶地】不在 option ──
	"紮營": "已有等價機制: SettlementMemory.quality_multiplier → ctx.camp_site_quality_mult（decision_context:526）",
	"紮根": "已有等價機制: 同上 → ctx.settle_site_quality（decision_context:468）",
	"擴點": "已有等價機制: 同上 → ctx.expand_site_marginal（decision_context:511）",
	# ── 判準不成立（指名是哪一條）──
	"領取": "②不成立: 沒有「領不到」的事件——pending_claims 只有增刪，到場落空不留記號 ⇒ 偵測不到。★補上 miss 記號時這格要改判",
	"生產": "①不成立: 沒有【生產被拒絕】的執行步驟；缺料是產出量的問題（效果不好），由 need/資源層處理",
	"覓食": "①不成立: 採不到＝產量低，不是做不成",
	"survival": "①不成立: 逃跑是做得成的動作；逃不掉是結果不是執行失敗",
	"駐守": "①不成立: 本地治理，沒有會失敗的執行步驟",
	"攻擊": "①不成立: 打得起來就算執行成功，輸贏是結果；★目標消失屬【失效】，走 T0 不走折價",
	"徵收": "①不成立: 本地動作，沒有對手方會拒絕",
	"迎戰": "①不成立: 接戰是做得成的；勝負是結果",
	"訓練": "①不成立: 本地動作，沒有會失敗的執行步驟",
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
static func mult_for_option(state: WorldState, team: TeamData, option: String, ctx = null) -> float:
	# ★把【靜默缺席】變成可數的次數（階段 1）：用途是【排序】——先接被決策最多次的那幾個。
	#   ★★它數的是【決策次數】不是【失敗次數】⇒ 是代理量，不是「損失了多少」。
	# ★★★這段必須在 `recent_failures.is_empty()` 早退【之前】——
	#   第一版寫在早退之後，實測 unmapped 恆為 0：沒有失敗記憶的隊（＝絕大多數，因為
	#   目前只有 2 個 option 會記）根本走不到那一行 ⇒ ★儀器看起來乾淨，其實是瞎的。
	if not OPTION_FAIL_KEY.has(option):
		if Probe.enabled:
			Probe.bump("failure.unmapped." + option)
		return 1.0
	if team == null or team.recent_failures.is_empty():
		return 1.0
	var m = OPTION_FAIL_KEY.get(option)
	if m == null:
		return 1.0
	var tgt: String = String(m[1])
	if tgt.begins_with("ctx:"):
		# ★逐次目標：從決策當下的 ctx 讀。★★沒有 ctx／目標未知（-1）⇒ 不折價（1.0），
		#   而不是退回一個粗粒度 target —— ★★★「不知道對誰」與「對誰都一樣」是兩件事。
		if ctx == null:
			return 1.0
		var field: String = tgt.substr(4)
		var raw = ctx.get(field)
		if raw == null:
			return 1.0
		var tid: int = int(raw)
		if tid == -1:
			return 1.0
		tgt = str(tid)
	return mult(state, team, String(m[0]), tgt)
