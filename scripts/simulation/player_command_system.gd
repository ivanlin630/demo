# scripts/simulation/player_command_system.gd
class_name PlayerCommandSystem

const RECRUIT_COST_ANON:  float = 50.0   # TEST VALUE
const RECRUIT_COST_NAMED: float = 150.0  # TEST VALUE
const JOIN_ONBOARD_MEAL:  float = 0.8    # 一餐 ≈ FOOD_PER_PERSON_PER_DAY/3 (TEST VALUE)
const TRAIN_COST_COIN: float = 30.0      # TEST VALUE — 一次訓練 coin（守恆:餉銀入公庫,非 sink）
const TRAIN_EXP_GAIN:  float = 20.0      # TEST VALUE — 一次訓練給最低非菁英 tier 的 exp
# ★S6 phase2：紮營工期常數退場 —— 改讀工期唯一入口 OutpostSystem.build_person_hours("camp")
#   ★★不留常數：留著它就得有人維護「它等於錨×⅓」這個同步關係，而沒有人會維護。
const CAMP_FOOD_CAP:    float = 40.0     # TEST VALUE — 紮營只抬 food cap（regen 產糧）,不送即時糧
const AID_GIVE_DEFAULT: float = 5.0      # TEST VALUE — forced aid_request give 預設量（一餐量,免新增數值輸入 UI）

# 投降抽成清單：30% 轉移給受降方（含武備 — 半繳械投降）
const SURRENDER_TRANSFER_RES: Array = [
	"food", "coin", "goods",
	"weapon_melee_low", "weapon_melee_high",
	"weapon_ranged_low", "weapon_ranged_high",
	"armor_low", "armor_high",
]

var _interaction: InteractionSystem = InteractionSystem.new()
var _diplomatic:  DiplomaticAiSystem = DiplomaticAiSystem.new()
var _encounter:   EncounterSystem    = EncounterSystem.new()
var _subteam:     SubteamSystem      = SubteamSystem.new()
var _action_registry: Dictionary = {}

# ── 主動互動 ────────────────────────────────────────────────

# ★★★全列版（spec 2026-09-30「動作全列＋原因」）：對 `TEAM_TARGET_ACTIONS` 的每一個名字
#   回一列 `{action_id, enabled, disabled_reason}` —— ★**原因與判斷在同一個回傳裡**
#   （沿用 `_colocation_gate` 已在用的形狀：不回 bool，回那句人話）。
#   ★★而它是【那些條件的唯一持有者】：`get_available_actions` 變成衍生檢視，
#     而 `player_query_api` 的三處停用列（pop 1.5 倍／readiness 0.7／coin）已整段刪掉
#     —— 那三處是同一組條件的第二份，而兩邊各改一次就會出現
#     「選單說可以、handler 說不行」。★P7 就是那一格的守衛。
#   ★★★母體邊界：本支只涵蓋【團隊目標動作】那一類（22 個信封呼叫點裡的 4 個：
#     `player_query_api.gd:296` 那條啟用路徑與原本 :319／:336／:355 三處停用路徑）。
#     格動作／自家隊動作／庫存那四處【不在本支】—— 它們沒有來源常數或界線不可機械讀，
#     已就地具名登 defer（見那兩個標記）。
#   ★具名排除的語意：清單裡的名字是「**尚未實裝此機制**」（藍圖④）——
#     不是「現在不能做」⇒ 列出來設 false 會讓玩家等一個不存在的東西。
# ★★★【`recruit` 為什麼在列上】—— systems 裁 2026-10-01（血證由 implementer 提，systems 逐處核過）：
#   藍圖④原本要求「STUB 的泛用 `recruit` 不列」，而照字面做完之後 `ui_flow` 立刻紅一格：
#     `scripts/debug/ui_flow_test.gd:340`「team 行動清單含 recruit」
#   ⇒ 開檔追下去：`text_ui_main.gd:1497` 的 `elif action_id == "recruit":` 只呼
#     `query_recruit_menu()` ⇒ 它是**招募子選單的開啟點**，而那個子選單是
#     `recruit_named`（記名招募）在**活的文字介面**裡的唯一入口（`:2670`）。
#     ★另外兩處（`main.gd:124`／`popup_layer.gd`）在那棵**死的圖形樹**上。
#   ⇒ ★★★真因不是 (a)／(b) 哪個好，是**前提只講了一半**：這個 id 有【兩個身分】
#     —— 引擎側是沒實裝的動詞（`:158 "recruit": _action_recruit` 只回菜單），
#     UI 側是子選單入口。「不列」殺掉後者，「列成可執行動作」讓玩家打到前者。
#   ⇒ ★裁：`recruit` **留在清單上**，而它的身分宣告在下面的 `SUBMENU_OPENERS`（第三類）
#     —— ★不是就地標記：一個就地標記本質上是一份長度 1 的手抄名單。
#   ⇒ ★★`STUB_NOT_IMPLEMENTED` 維持【機制接電 ＋ 清單暫空】：內容等「展開層有自己的
#     機械來源」之後才會有成員（systems 已登 defer，錨在那行標記上）。
#   ⇒ ★★★而我**沒有**為了讓床綠而去改 `ui_flow` 那一格的斷言：那一格是對的，
#     它抓到的是一個真實後果。改它才是弱化。
const STUB_NOT_IMPLEMENTED: Array = []   # ★清單暫空是【裁定】不是忘了（見上）；機制已接電：一有名字就會生效

# ★★★【第三類：子選單入口】—— submenu-entry-not-an-action（systems 裁 2026-10-01）
#   一個 `action_id` 可以有【兩個身分】：引擎側是一個動詞，UI 側是**開啟下一層畫面的那一格**。
#   ★這一類的 `enabled` **沒有意義**：按下去是【換一層畫面】不是【發生一件事】
#     ⇒ 它永遠「可做」、原因永遠是空的 —— ★★而那不是一個豁免，**是它的語意**。
#     真正的可不可做在【下一層】：記名候選各自帶價（`recruit_named`）、
#     打聽選項各自有條件（`InquirySystem.get_options`）。
#   ★★★為什麼是【宣告在一處】而不是就地標記：就地標記本質上是一份長度 1 的手抄名單
#     ⇒ 同族的第二個成員會沒有人管（2026-10-01 的實例：`gather_intel` 與 `recruit`
#     形狀完全一樣，而只有後者被討論過）。`opens_submenu` 這一欄**從這個常數導出**。
#   ★★而「回 payload」**不能**當判準（systems 量過：本檔 `"payload"` 有 11 處，
#     其中至少五處明顯改世界）⇒ 那個字面只編碼了判準的前半句，漏掉了「且不改世界」。
#     ⇒ 所以守衛不是靜態 grep，是**行為**：床對每一個宣告過的入口斷言【呼它前後世界不變】，
#       並**反向掃**所有回 payload 而沒有宣告的 handler（不改世界 ⇒ 漏宣告 ⇒ 紅並指名）。
const SUBMENU_OPENERS: Array = ["recruit", "gather_intel"]

func get_action_availability(state: WorldState, target_id: int) -> Array:
	var out: Array = []
	var pt: TeamData  = _get_player_team(state)
	var tgt: TeamData = state.teams.get(target_id)
	for name in TEAM_TARGET_ACTIONS:
		var act: String = String(name)
		if STUB_NOT_IMPLEMENTED.has(act):
			# ★尚未實裝此機制（不是停用）⇒ 不列。
			#   ★★原本這裡寫「母體 11 → 10」—— 那是一個**會過期的現況**
			#     （母體是 12 了，而 `STUB_NOT_IMPLEMENTED` 現在是空的 ⇒ 12 → 12）
			#     ⇒ 改成不帶數字：**列出的 ＝ 母體 − 具名排除**，而那兩個數由床印在卷面上。
			continue
		var ok: bool = true
		var why: String = ""
		if pt == null or tgt == null:
			ok = false
			why = "沒有可操作的隊伍或目標"
		elif SUBMENU_OPENERS.has(act):
			pass   # ★第三類：入口的 `enabled` 沒有意義（語意寫在 `SUBMENU_OPENERS` 那裡）
		else:
			match act:
				"ignore", "attack", "beg":
					pass   # 無條件（beg 的需求由 `_resolve_aid_request` 自決）
				"trade":
					if not _can_trade(state, pt, tgt):
						ok = false
						why = "雙方都沒有可交易的錢"
				"propose_alliance":
					if TeamData.same_faction(tgt, pt):   # S1：兩支無勢力的隊不是同勢力
						ok = false
						why = "對方已經和你同一個勢力"
				"demand_tribute":
					if pt.population <= int(tgt.population * 1.5):
						ok = false
						why = "人口不足（需超過對方 1.5 倍；你 %d、對方 %d）" % [
							pt.population, tgt.population]
				"extort":
					if pt.readiness < 0.7:
						ok = false
						why = "準備值不足（需 ≥ 0.7，現為 %.1f）" % pt.readiness
				"recruit_anon":
					var coin_a: float = float(pt.resources.get("coin", 0))
					if coin_a < RECRUIT_COST_ANON:
						ok = false
						why = "金幣不足（需 %d，現 %d）" % [int(RECRUIT_COST_ANON), int(coin_a)]
					elif not _target_has_anon(tgt):
						ok = false
						why = "對方沒有可招募的無名之人"
				"invite_settle":
					if not _can_invite_settle(state, pt, tgt):
						ok = false
						why = "你不在自家據點上，無法邀請對方定居"
				"offer_surrender":
					# ★原因【不在這裡寫】：讀共用前置檢查回的那句話
					#   ⇒ 同一條規則一份字面，而「原因」與「判斷」仍在同一個回傳裡。
					var enc_r: Dictionary = refuse_if_not_in_encounter(state)
					if not enc_r.is_empty():
						ok = false
						why = String(enc_r.get("msg", ""))
				_:
					ok = false
					why = "（未知動作：%s）" % act
		out.append({
			"action_id": act,
			"label": PlayerApiMapper.action_label(act),   # ★唯一一份中文表（systems 裁④）
			"enabled": ok,
			"disabled_reason": why,
			"opens_submenu": SUBMENU_OPENERS.has(act),    # ★從宣告導出，不是第二份名單
		})
	return out

# 查詢對 target_id 可用的行動 —— ★**衍生檢視**（spec §2②）：
#   它現在是「全列版裡 enabled 的那些名字」，而順序沿用 `TEAM_TARGET_ACTIONS` 的宣告順序。
#   ★★5 個既有呼叫端一個都不用改 ⇒ 「一個真相一份」是結構性的，不是紀律性的。
#   ★★★而檔頭原本那段手寫註解表（「attack → 永遠可選／demand_tribute → pop > 1.5×…」）
#     **已刪掉**（spec §2④）：留著它就是同一組規則的第二份，
#     而第二份表會在下一次改條件時安靜地說謊。真判斷在全列版的 match 裡。
#   ★誠實限（與 spec P4 的字面有一處衝突，我照藍圖④做並回報）：
#     舊版會在 coin 足夠時列出泛用 `recruit`，而全列版把它具名排除
#     ⇒ 本支的回傳與舊版**只差那一個名字**，不是逐字相同。
func get_available_actions(state: WorldState, target_id: int) -> Array[String]:
	var actions: Array[String] = []
	for row in get_action_availability(state, target_id):
		if bool(row.get("enabled", false)):
			actions.append(String(row.get("action_id", "")))
	return actions

# UI 覆蓋審計用：回傳全 registry action id（_test_action_ui_coverage 驗每個都有 UI 路徑）
func get_registered_actions() -> Array:
	if _action_registry.is_empty():
		_setup_registry()
	return _action_registry.keys()

# recruit_anon 前提：★★★目標【真的有匿名】—— 不是「人夠多」。
#   ★原本寫 `tgt.population > 1`，那是【代理量】：它問的是「人夠多嗎」，
#     而要問的是「有匿名可以搬嗎」⇒ 對方【全具名】時它照樣回 true
#     ⇒ 玩家被扣 50 coin、搬 0 個人、而畫面印「招募成功」（2026-09-25 用戶回報）。
#   ★★改問 `AnonTierSystem.total_pop()`（＝ anon_cohorts 的總量）——
#     ★★★而不是自己算「人口減具名數」：那會是第二份真相，
#       而兩份真相今天已經咬過我們好幾次（同 (丁) 被否決的理由）。
func _target_has_anon(tgt: TeamData) -> bool:
	return AnonTierSystem.total_pop(tgt) > 0

# invite_settle 前提：玩家腳下為自家 outpost（_action_invite_settle 需 settle_pos 指向自家 outpost）
func _can_invite_settle(state: WorldState, pt: TeamData, tgt: TeamData) -> bool:
	if tgt == null:
		return false
	var tile: HexTileData = state.world.tiles.get(pt.tile_pos.x * 1000 + pt.tile_pos.y)
	return tile != null and tile.outpost_level > 0 and tile.outpost_owner == pt.team_id

# ── Registry 初始化 ───────────────────────────────────────────

func _setup_registry() -> void:
	_action_registry = {
		"trade":                  _action_trade,
		"propose_alliance":       _action_propose_alliance,
		"demand_tribute":         _action_demand_tribute,
		"attack":                 _action_attack,
		"extort":                 _action_extort,
		"recruit":                _action_recruit,
		"recruit_anon":           _action_recruit_anon,
		"take_loot":              _action_take_loot,
		"leave_loot":             _action_leave_loot,
		"establish_faction":      _action_establish_faction_cmd,
		"refresh_targets":        _action_refresh_targets,
		# ★【已退場 2026-10-01】「直接成交」那條路線的 registry 列已刪（藍圖裁 (乙)）——
		#   ★★連別名鍵一起刪（藍圖 `9381f77f5` 逐字同意）：留成別名鍵的話
		#     第三桶還是 1，而裁定要的是它變空。
		#   ★★★而這幾行**刻意不寫那些已退場的函式名**：退場票的 P1／P2 是
		#     `grep -rn <名字> scripts/` ＝ 0，而一段**描述它們**的註解與一處
		#     **使用它們**的 code 在文字上同形 ⇒ 寫進去會把那條地板咬紅。
		#     ⇒ 要查它們叫什麼：看退場票的 spec（§3 的指名清單）。
		"submit_trade_offer":     _action_submit_trade_offer,
		"cancel_trade":           _action_cancel_trade,
		"set_tribute_rate":       _action_set_tribute_rate,
		"set_armed_anon_ratio":   _action_set_armed_ratio,
		"build_outpost":          _action_build_outpost,
		"upgrade_outpost":        _action_upgrade_outpost,
		"upgrade_farming":        _action_upgrade_farming,
		"upgrade_manufacturing":  _action_upgrade_manufacturing,
		"build_facility":         _action_build_facility,
		"demolish_outpost":       _action_demolish_outpost,
		"abandon_outpost":        _action_abandon_outpost,
		"dispatch_subteam":       _action_dispatch_subteam,
		"order_subteam":          _action_order_subteam,
		"recall_subteam":         _action_recall_subteam,
		"subjugate_enemy":        _action_subjugate_enemy,
		"leave_faction":          _action_leave_faction,
		"betray_faction":         _action_betray_faction,
		"disband_faction":        _action_disband_faction,
		"offer_surrender":        _action_offer_surrender,
		"surrender_in_encounter": _action_surrender_in_encounter,
		"accept_encounter":        _action_accept_encounter,
		"surrender_pre_encounter": _action_surrender_pre_encounter,
		"set_faction_goal":       _action_set_faction_goal,
		"order_faction_member":   _action_order_faction_member,
		"clear_member_order":     _action_clear_member_order,
		"gather_intel":           _action_gather_intel,
		"beg":                    _action_beg,
		"confirm_gather_intel":   _action_confirm_gather_intel,
		"respond_aid_request":    _action_respond_aid_request,
		"invite_settle":          _action_invite_settle,
		"choose_heir":            _action_choose_heir,
		"extract_treasury":       _action_extract_treasury,
		"withdraw_from_storage":  _action_withdraw_from_storage,
		"deposit_to_storage":     _action_deposit_to_storage,
		"hunt":                   _action_hunt,
		"hunt_beast":             _action_hunt_beast,
		"train":                  _action_train,
		"camp":                   _action_camp,
		"promote_anon":           _action_promote_anon,
		"rest":                   _action_rest,
	}

# 執行玩家主動行動
# 返回 { "ok": bool, "msg": String }
func execute_action(state: WorldState, target_id: int, action: String) -> Dictionary:
	var pt: TeamData = _get_player_team(state)
	var pt_id: int   = _get_player_team_id(state)
	# H: choose_heir 在玩家 person 已死時觸發，pt 必為 null，需在 null 守衛前處理
	if action == "choose_heir":
		if _action_registry.is_empty():
			_setup_registry()
		return _action_registry["choose_heir"].call(state, target_id, pt, pt_id)
	if pt == null:
		return { "ok": false, "msg": "找不到玩家 team" }
	if action == "ignore":
		state.player_pending_targets.erase(target_id)
		return { "ok": true, "msg": "忽略" }
	if _action_registry.is_empty():
		_setup_registry()
	if not _action_registry.has(action):
		return { "ok": false, "msg": "未知行動: %s" % action }
	# ★★★同格閘（spec 2026-09-30）：這條不變量原本只有【兩處】執法 ——
	#   NPC 側 `diplomatic_ai_system.gd:138`、玩家【畫面】側 `refresh_colocation_targets`
	#   ⇒ 而第三條管道（直呼 API／agent）**一處都沒有** ⇒ 可對任意隊隔空索貢／提案／勒索。
	#   ★而那不是「畫面守得不夠嚴」，是【守在錯的層】：畫面是一條管道，
	#     而不變量是世界的性質 ⇒ 守畫面等於只對我們自己走的那條路執法，
	#     ★★而缺陷從來躲在我們不走的管道。
	# ★★★判準錨在【動作的契約】，不是【這次傳進來的數字】（systems 訂正 2026-09-30）：
	#   我第一版寫「若 `state.teams.get(target_id)` 非 null 就要同格」——
	#   ★而 `target_id` 只是個 int，自家隊動作【只是慣例上】傳 -1，沒有東西強制它
	#   ⇒ 走程式介面呼 `execute_action(state, 5, "hunt")` ⇒ `teams.get(5)` 非 null
	#     ⇒ **hunt 會被誤判成「對方不在你的格上」**
	#   ⇒ ★★而那個誤判的方向是【擋掉合法動作】，症狀是「某些自家隊動作偶爾莫名被拒」
	#     —— **比洞更難查**。
	#   ⇒ ★★★所以條件是「action ∈ 團體目標動詞集合」，而那個集合有單一來源：
	#     `get_available_actions` 回的那些 ⇒ 見 `TEAM_TARGET_ACTIONS` 的檔頭。
	#   ★既有兩支自己也查（`_action_beg`／`_action_invite_settle`）⇒ 雙查同答案，無害；
	#     ★★不把它們拆掉：那兩處的措辭是它們自己領域的話（「需同格才能乞討」）。
	var _far: Dictionary = _colocation_gate(state, action, target_id, pt)
	if not _far.is_empty():
		return _far
	return _action_registry[action].call(state, target_id, pt, pt_id)

# ★★★【團體目標動詞】＝ 契約上 target 指的是【別隊】的那些動作。
#   ★單一來源是 `get_available_actions`（本檔 :39）—— 它就是「對一支別隊可以做什麼」那份清單。
#   ★★而這個 const 是它的【鏡子】不是第二份真相：床有一格做異源比對
#     （抽 `get_available_actions` 裡所有 `actions.append("…")` 的字面 ⇒ 集合必須相等）
#     ⇒ 有人往那支函式加一個新動詞而忘了這裡，那一格會紅。
#   ★★★`ignore` 留在清單裡是因為它【契約上】也是對別隊的動作（它清的是對那支隊的 pending）；
#     而它在 `execute_action` 更上面就 early-return ⇒ 實際走不到這一閘。列著是為了讓
#     異源比對的兩邊【同一個定義域】—— 把它剔掉會讓集合相等那一格永遠差一個。
# ══ ★★★★★【動作形狀宣告表】ACTION_SHAPE（spec 2026-10-01 §3①）═══════════════
# 它回答一個 `_action_registry` 沒有回答的問題：**這個動作要什麼 target**。
#   ·`"none"` ＝ 不吃目標（自家隊／腳下那格）   ·`"team"` ＝ 要一支別隊
#   ·`"tile"` ＝ 要一格座標
#
# ★★★★★【`listed` 的語意 —— 寫死，不准漂】（systems 裁 (甲) 2026-10-01）：
#   `listed == true` ＝ **這個動作出現在【自家隊動作區】那一屏**。
#   ★★它**不是**「它能不能做」—— 能不能做 ＝ `enabled` ＋ `disabled_reason`，那是**另一個維度**。
#   ★★★而它**不是一個新的呈現決定**：這個分別**產品裡已經存在**，
#     只是今天**只隱含在「哪些 emit 點存在」裡** ——
#     `listed == false` 的那些是從【子模式面板】進去的，實例（systems 開檔核過）：
#       `build_facility`     → `text_ui_main.gd:2169`（`_handle_outpost_mode`）
#       `deposit_to_storage` → `:2374`（`_handle_storage_mode`）
#       `order_subteam`      → `:2510`（`_handle_subteam_mode`）
#   ⇒ 所以 `listed` 是**把一個已經存在的事實宣告出來**，而那正是本票 §2 那句話的本體：
#     **邊界沒有被宣告，所以它只能被手抄**。
#   ⇒ ★而「哪一屏都進不去」那一類**不靠紀律發現**：床的第三條反向掃
#     （`listed == false` 的那些必須在某個 `_handle_*_mode` 的函式體裡出現）
#     會把它們**逐名印在卷面上**，而那份名單是要拿去問藍圖的 —— 不是在這裡決定。
#
# ★★★★★★【誠實限 —— 這一段是給下一個人的，不是裝飾】（spec §4b 逐字）：
#   本表宣告 **51 個 registry key ＋ 3 個具名豁免** 的 `target`，
#   而本票**不保證每一個宣告都對**。它保證的是兩件【可機械驗】的事：
#     ①**每一個 registry key 都有人宣告過** —— 反向掃，漏一個紅並指名
#       （`available_actions_bed` 的 P1；新增 handler 的人會被擋下來）
#     ②~~**`target=="team"` 那一類 ＝ `TEAM_TARGET_ACTIONS`** —— P1c 異源交叉~~
#       ★★★【2026-10-01 這一條反過來了，而原文劃掉留著】：`TEAM_TARGET_ACTIONS`
#         現在是**本表的衍生檢視**（見下面那段 `static var`）⇒ 拿它回來跟本表比
#         就是**同源 ⇒ 恆真**。★所以守的人換成 `available_actions_bed` 的 **P17**：
#         衍生集合 vs **外部期望**（`SPEC_TEAM_TARGET_TOTAL` ＋ `SPEC_TEAM_TARGET_NAMES`
#         那份**刻意手抄**的逐名清單）—— ★而「為什麼它刻意不是衍生物」寫在它旁邊。
#       ⇒ ★★所以本表的 `target == "team"` 這一欄**現在是權威**，不再是「要跟誰對上」：
#         把一支的 `target` 從 `"team"` 改掉 ⇒ 它直接從 `TEAM_TARGET_ACTIONS` 消失
#         ⇒ 接住它的是 P17（與外部期望的差集）＋ `colocation_gate_bed` 的 `SPEC_TEAM_TARGET_TOTAL`。
#   ★★而**行為上真的被驗到的只有 11 個**（`target=="none"` 那一類，本票的消費者：
#     P2／P2b／P3）⇒ **其餘 40 個的 `target` 是【宣告】**，
#     它的正確性要靠**各自的消費者出現時咬出來**。
#   ⇒ ★★★下一個人看到一張 54 列的表，會以為那 54 列都被驗過。
#     而「**以為被驗過的宣告**」比「沒有宣告」更貴：**它會被下游當前提**。
#
# ★★【三個具名豁免】（它們不在 `_action_registry` 裡，而反向掃要認得它們）：
#   ·`ignore`      —— 它在 `execute_action` 更上面就 return（同格閘那支床的
#                     `SPEC_EARLY_RETURN_EXEMPT` 就是它）
#   ·`cancel_move` ／ `move_to` —— 它們是**一格 dispatch 動詞**（不走 registry）
#   ★★★而 `ignore` 這一個是 **P1c（今天的 P17）逼出來的**：spec §3① 只點名了
#     `cancel_move`／`move_to` 兩個豁免，而 `target=="team"` 的集合要等於那 12 個
#     （含 `ignore`）⇒ 少了它那一格必紅。⇒ **spec 的豁免清單是 2，實際是 3**（已回報）。
#
# ★而本表的初版文字是**產生**出來的（從 registry 的 key ＋ 當時那份手抄的 team 清單），
#   ~~★★但那不讓 P1c 變成恆真：產完之後兩邊是兩份各自獨立的字面~~
#   ★★★【2026-10-01】那個「分家」的狀態**結束了** —— 不是因為它變回同源，
#     而是因為**第二份清單被刪掉**：現在只有本表一份資料，
#     而「外部期望」搬到床裡（`SPEC_TEAM_TARGET_NAMES`）⇒ 它在**另一個檔、另一個作者的手**
#     ⇒ ★那才是異源的意思（不是「曾經分開寫過」，是**現在有人能單獨把其中一邊改壞**）。
# ★（原本這裡有一段「某個動作為什麼判成 `"none"`」的理由 —— 那一列已於 2026-10-01 退場，
#   理由隨它一起走。形狀上的教訓留在別處：**追委派要追到底**，
#   因為一支 handler 可能把 target 轉給另一支而那一支底線前綴不用它。）
# ══ ★★★★★【這張表的列序 ＝ 玩家在【自家隊動作區】看到的上下順序】═══════════════
#   ⇒ **為了查表好讀而重排這幾列 ＝ 改了玩家畫面。**
# （systems 裁 2026-10-01：「一條【按位置記住】的規矩，它的邊界要寫在那個位置上」）
# ★怎麼來的：`TEAM_TARGET_ACTIONS` 是本表 `target == "team"` 的衍生檢視，而**它不 `sort()`**
#   ⇒ 用本表的**插入順序** ⇒ 全列版（`get_action_availability`）的列序 ＝ 這裡的列序。
# ★★【2026-10-01 這一刀改掉過一次玩家畫面，而它被記錄下來】：舊的手抄 `const` 是
#   **語意分組**（`ignore, attack, trade, propose_alliance, …`），本表是**字母序**
#   ⇒ 玩家列序從語意分組變成字母序（systems 裁：不花錢保住舊順序，因為玩家介面正在
#   換終端 REPL，版面與順序在那張票重新決定 ⇒ 順序的決定權在那張票的 §8）。
# ★★★若日後要回到語意分組：**重排下面那 12 列**，★**不要加第二份順序清單**
#   （那正是這一刀殺掉的東西）。
# ══ ★★★`effect` 欄（終端 E2E spec 2026-10-06 §3）：這個動作**說它會改世界的哪一塊** ══════════════════════
# ★E2E 床讀這一欄判「說到沒做到」（結果句說成功 ⇒ 這一塊在 A−B 差異裡必須非空）
#   ⇒ ★單一來源：床**不另抄一份**；畫面上出現過而沒有 effect 的動作 ⇒ 床紅並指名
# ★自家隊動作 10 個（`listed: true`）＋目標動作 9 個（見下）；每一個逐支開 handler 核過它**寫了什麼**（不從動作名推）：
#   camp                 task            `_action_camp`:748 → TaskArbiter.try_set(TASK_BUILD @腳下)；工程之後才開
#   confirm_gather_intel belief          `_action_confirm_gather_intel`:1351 → InquirySystem.resolve_inquiry 寫 belief claim
#                                        （★不是 none_expected：打聽會改附身隊的 belief ⇒ E2E 加讀 query_memory_panel）
#   establish_faction    faction         `_action_establish_faction_cmd`:948 → establish_faction(:1970) 建勢力
#   hunt                 resources_self  `_action_hunt`:677 → HuntSystem.hunt_small_game（hunt_system.gd:9）自家食物
#   hunt_beast           encounter       `_action_hunt_beast`:687 → tile predator_density −1、建野獸隊、init_encounter
#   leave_loot           encounter_result `_action_leave_loot`:936 → state.last_encounter_result = {}
#   promote_anon         roster          `_action_promote_anon`:734 → PersonGenerator ＋ add_member（anon → named）
#   subjugate_enemy      roster_other    `_action_subjugate_enemy`:1137 → InteractionSystem.subjugate_team（收編敗者）
#   take_loot            resources_both  `_action_take_loot`:917 → ResourceBank.remove(敗者) ＋ add(玩家)
#   train                resources_self  `_action_train`:703 → coin −TRAIN_COST_COIN（可能升階）
# ★★母體改裁（systems 2026-10-07，spec 58e41cfee）：不是「10 個 listed」，是**畫面上綁了鍵、按得到的所有動作**
#   ⇒ 目標動作（`─ 動作（` 區、ACTION_DIGITS 綁鍵）9 個也填；未綁鍵的 3 個（乞討／忽略／投降請和）不填（按不到）
#   attack               encounter       `_action_attack`:862 → _encounter.init_encounter ＋ player_hostile_teams
#   trade                menu            `_action_trade`:802 → 只寫 player_state.pending_trade_target、回 requires_preview（開交易子選單）
#   propose_alliance     faction         `_action_propose_alliance`:811 → accept 時 create_faction ＋ _form_alliance
#   demand_tribute       resources_both  `_action_demand_tribute`:827 → accept 時 DiplomaticAiSystem.apply_tribute_accept（對方 coin → 玩家）
#   extort               resources_both  `_action_extort`:873 → InteractionSystem.resolve_extortion_direct（interaction_system.gd:1471）搬資源
#   recruit              menu            `_action_recruit`:883 → 逐字「Always return a menu — never auto-execute」
#   recruit_anon         roster_other    `_action_recruit_anon`:911 → _recruit_anon_internal（:1859）AnonTierSystem.transfer_proportional(對方→玩家)
#   gather_intel         belief          `_action_gather_intel`:1338 → 回選題子選單；★effect 掛在選題後那道 confirm_gather_intel（走法要走完子選單）
#   invite_settle        roster_other    `_action_invite_settle`:1725 → accept 時 InteractionSystem._execute_settlement（interaction_system.gd:1703）改對方 tile／faction
#   menu ＝ 這道令只打開一個子選單、不改世界 ⇒ 紅二不適用、紅三適用
const ACTION_SHAPE: Dictionary = {
	"abandon_outpost":         {"target": "none", "listed": false},
	"accept_encounter":        {"target": "none", "listed": false},
	"attack":                  {"target": "team", "listed": false, "effect": "encounter"},
	"beg":                     {"target": "team", "listed": false},
	"betray_faction":          {"target": "none", "listed": false},
	"build_facility":          {"target": "none", "listed": false},
	"build_outpost":           {"target": "none", "listed": false},
	"camp":                    {"target": "none", "listed": true, "effect": "task"},
	"cancel_move":             {"target": "none", "listed": false},  # ★具名豁免：不在 `_action_registry`（它是一格 dispatch 動詞）
	#   ★★★`listed: true → false`（systems 裁 2026-10-01）—— ★**不要改回 true**：
	#     `listed` 的語意逐字是「出現在【自家隊動作區】那一屏」⇒ **畫面就是這個欄位的定義**，
	#     而 `text_ui_main.gd:1841` 逐字把它濾掉（`if aid == "move_to" or aid == "cancel_move": continue`）
	#     ⇒ 兩邊不一致時**錯的是宣告**。
	#   ★而「讓畫面跟上宣告」被否決：它**已經有專鍵**（`text_ui_main.gd:1832` 逐字
	#     「`move_to`／`cancel_move` 有專鍵」）⇒ 多印一列 ＝ 同一動作**兩個入口**
	#     ＝ 剛花兩張票消滅的那個形狀。
	#   ★★而這一改**不改變玩家能做什麼、也不改畫面** —— 它只讓宣告說實話（HOW 不是呈現決定）。
	#   ★★★而「宣告與畫面今天沒有任何一格在比」那個缺口，由 `ui_flow_test` 的
	#     P33 補上（異源：宣告表 vs **render 出來的畫面**，不是 `_interact_action_split()` 的回傳）。
	"cancel_trade":            {"target": "none", "listed": false},
	"choose_heir":             {"target": "none", "listed": false},
	"clear_member_order":      {"target": "none", "listed": false},
	"confirm_gather_intel":    {"target": "none", "listed": true, "effect": "belief"},
	"demand_tribute":          {"target": "team", "listed": false, "effect": "resources_both"},
	"demolish_outpost":        {"target": "none", "listed": false},
	"deposit_to_storage":      {"target": "none", "listed": false},
	"disband_faction":         {"target": "none", "listed": false},
	"dispatch_subteam":        {"target": "none", "listed": false},
	"establish_faction":       {"target": "none", "listed": true, "effect": "faction"},
	"extort":                  {"target": "team", "listed": false, "effect": "resources_both"},
	"extract_treasury":        {"target": "none", "listed": false},
	"gather_intel":            {"target": "team", "listed": false, "effect": "belief"},
	"hunt":                    {"target": "none", "listed": true, "effect": "resources_self"},
	"hunt_beast":              {"target": "none", "listed": true, "effect": "encounter"},
	"ignore":                  {"target": "team", "listed": false},   # ★具名豁免：不在 `_action_registry`（它在 `execute_action` 更上面就 return）
	"invite_settle":           {"target": "team", "listed": false, "effect": "roster_other"},
	"leave_faction":           {"target": "none", "listed": false},
	"leave_loot":              {"target": "none", "listed": true, "effect": "encounter_result"},
	"move_to":                 {"target": "tile", "listed": false},   # ★具名豁免：不在 `_action_registry`（它是一格 dispatch 動詞）
	"offer_surrender":         {"target": "team", "listed": false},
	"order_faction_member":    {"target": "none", "listed": false},
	"order_subteam":           {"target": "none", "listed": false},
	"promote_anon":            {"target": "none", "listed": true, "effect": "roster"},
	"rest":                    {"target": "none", "listed": true, "effect": "task"},   # 票 T：`_action_rest` → TaskArbiter.try_set(TASK_REST @原地)
	"propose_alliance":        {"target": "team", "listed": false, "effect": "faction"},
	"recall_subteam":          {"target": "none", "listed": false},
	"recruit":                 {"target": "team", "listed": false, "effect": "menu"},
	"recruit_anon":            {"target": "team", "listed": false, "effect": "roster_other"},
	"refresh_targets":         {"target": "none", "listed": false},
	"respond_aid_request":     {"target": "none", "listed": false},
	"set_armed_anon_ratio":    {"target": "none", "listed": false},
	"set_faction_goal":        {"target": "none", "listed": false},
	"set_tribute_rate":        {"target": "none", "listed": false},
	"subjugate_enemy":         {"target": "none", "listed": true, "effect": "roster_other"},
	"submit_trade_offer":      {"target": "none", "listed": false},
	"surrender_in_encounter":  {"target": "none", "listed": false},
	"surrender_pre_encounter": {"target": "none", "listed": false},
	"take_loot":               {"target": "none", "listed": true, "effect": "resources_both"},
	"trade":                   {"target": "team", "listed": false, "effect": "menu"},
	"train":                   {"target": "none", "listed": true, "effect": "resources_self"},
	"upgrade_farming":         {"target": "none", "listed": false},
	"upgrade_manufacturing":   {"target": "none", "listed": false},
	"upgrade_outpost":         {"target": "none", "listed": false},
	"withdraw_from_storage":   {"target": "none", "listed": false},
}

# ══ ★★★★★【`TEAM_TARGET_ACTIONS` 現在是 `ACTION_SHAPE` 的【衍生檢視】】═══════════
# （spec `2026-10-01-team-target-actions-becomes-a-derived-view-HOW.md`，2026-10-01）
# ★它原本是一份**手抄的 dict 字面**，與 `ACTION_SHAPE` 並存 ⇒ 兩份真相。
#   而過渡期的保護是一條**異源**交叉斷言（`ACTION_SHAPE` 的 team 集合 ＝ 這份清單）。
# ★★收成衍生物之後那條斷言會變成**同源** ⇒ 它**必須被換掉不是留著**
#   （留著就是本專案最常見的那個病：比較的兩邊同源 ⇒ 恆真，而卷面長相是綠）。
#   ⇒ 換成什麼：見 `available_actions_bed` 的 P17（衍生集合 vs **外部期望**）。
# ★★★為什麼是 `static var` 而不是 `const`：GDScript 的 `const` 不能用迴圈從另一個 `const`
#   導出 ⇒ 只能在類別載入時算一次。★它因此是**可寫的**（`const` 不是）——
#   而「沒有人會去 append 它」不是保證，所以那件事由床看著（P1：全庫手抄 dict 字面 ＝ 0 處）。
# ★★★★而**三支守衛的錨**（`available_actions_bed`／`colocation_gate_bed`／本檔同格閘的
#   第一條件）仍然引用**這個名字** —— 它們不需要改，因為名字沒變、而它的**來源**變了。
#   ⇒ 那正是這一刀的重點：**名字留著、第二份清單消失**。
static var TEAM_TARGET_ACTIONS: Array = _derive_team_target_actions()

# 從 `ACTION_SHAPE` 導出 `target == "team"` 的那些 id。
# ★★★★★【順序 ＝ `ACTION_SHAPE` 的宣告順序，而**那是玩家看得到的東西**】——
#   這個陣列的順序就是全列版（`get_action_availability`）的**列序**，而列序就是
#   玩家在自家隊動作區看到的上下順序 ⇒ ★它不是內部細節。
# ★★【這一刀改變了它，而 spec 沒有講】（2026-10-01，已回報 systems）：
#   舊的手抄 `const` 是**語意分組**（`ignore, attack, trade, propose_alliance, …`）；
#   `ACTION_SHAPE` 是**字母序**（它那樣排是為了查表好讀）⇒ 收成衍生檢視之後列序變成字母序。
# ★★★而處置是**不要在這裡 `sort()`**：用 `ACTION_SHAPE` 的**插入順序**。
#   兩者今天的輸出**一模一樣**（那張表本來就是字母序排的）——
#   差別在**誰擁有那個順序**：`sort()` 會把順序藏進這支函式（那時要改列序得改 code），
#   插入順序則讓**那張表自己**擁有它（要改列序 ＝ 重排那張表的那幾列，一處宣告）。
#   ⇒ ★這正是本票的形狀：**一個真相一份**，而順序也是一個真相。
static func _derive_team_target_actions() -> Array:
	var out: Array = []
	for k in ACTION_SHAPE.keys():
		if String((ACTION_SHAPE[k] as Dictionary).get("target", "")) == "team":
			out.append(String(k))
	return out

# ══ ★★★★★【純查詢前置檢查】——「能不能做」只有一份（spec 2026-10-01 §3②）═══════
# 每一個 `target=="none" and listed` 的動作各一支，回 `{"ok": bool, "reason": String}`。
# ★★兩個消費者，而「同一份」是**結構性的**不是紀律性的：
#   ·`_action_<x>` 的既有前置檢查**改呼它**（人話搬進來，原地只留呼叫）
#   ·全列版的迴圈**也呼它** ⇒ `enabled`／`disabled_reason` 從這裡來
# ★★★**禁止**在查詢面重寫任何條件字面（`TRAIN_COST_COIN`／`_check_distance`／
#   `outpost_level`…）—— 那一條與第一張票的 P7 同形，而 P7 已經有血證會紅。
#
# ★★★★【三處 handler 與查詢面原本條件【不同】，而我照 spec 裁「handler 權威」，
#   例外逐一寫出來】（2026-10-01 實測，三處都是 (甲) 那個病的本體）：
#   ①`camp`：查詢面**複製了 4 個條件**（`outpost_level`／`outpost_owner`／`terrain`／
#     `_check_distance`），而 handler 有**5 句人話**。⇒ 收成一份，人話全部來自 handler。
#   ②`confirm_gather_intel`：handler 檢「參數遺漏」（npc 存在 ＋ choice 非空），
#     查詢面檢 `pending_intel_target`。★**這兩個不是重複**：前者是「參數完整嗎」（執行時），
#     後者是「有沒有待確認的事」（前置）⇒ 前置檢查用後者，而 handler 那一句**留著**
#     （它守的是另一件事）。★★措辭用藍圖裁定給的那句（「沒有待確認的打聽」）。
#   ③`leave_loot`：handler **完全沒有條件**（永遠成功），而查詢面把它 gate 在戰利品那一組
#     ⇒ 照藍圖裁定（「情境四動作不可做時列出＋引擎給的原因」）它**需要一個條件**
#     ⇒ 我用與 `take_loot` 同一個（有沒有剛結束的戰鬥），措辭用藍圖給的那句。
#     ★而這是本票唯一**新增**一個條件的地方 —— 它是從裁定推出來的，不是我發明的。
func precheck_cancel_move(_state: WorldState, pt: TeamData) -> Dictionary:
	# ★`cancel_move` 沒有 `_action_*` handler（它是一格 dispatch 動詞）
	#   ⇒ 本支的唯一消費者是全列版；措辭由 spec §3④ 給。
	if pt == null or pt.move_target == Vector2i(-1, -1):
		return { "ok": false, "reason": "目前沒有移動目標" }
	return { "ok": true, "reason": "" }

func precheck_establish_faction(_state: WorldState, pt: TeamData) -> Dictionary:
	if pt == null:
		return { "ok": false, "reason": "找不到玩家隊伍" }
	if pt.faction_id != -1:
		# ★措辭用 handler 既有那句（更具體：它帶勢力 id）
		#   ⇒ 本票新造的措辭因此只剩【兩句】（`leave_loot`／`confirm_gather_intel`）。
		return { "ok": false, "reason": "已屬勢力%d" % pt.faction_id }
	return { "ok": true, "reason": "" }

func precheck_take_loot(state: WorldState, _pt: TeamData) -> Dictionary:
	var res: Dictionary = state.last_encounter_result
	if res.is_empty() or int(res.get("winner_id", -1)) != _get_player_team_id(state):
		# ★措辭用 handler 既有那句（spec §3②「handler 那句人話搬進去」）——
		#   藍圖裁定裡的「你沒有剛結束的戰鬥」是**例**不是指定，而既有那句更具體。
		return { "ok": false, "reason": "無可收取戰利品" }
	return { "ok": true, "reason": "" }

func precheck_leave_loot(state: WorldState, pt: TeamData) -> Dictionary:
	# ★★【條件共用、措辭各自】：條件直接呼 `precheck_take_loot`（不抄第二份），
	#   而原因是它自己的一句 —— ★那一句是**本票唯一新造的措辭之一**
	#   （handler 原本完全沒有條件 ⇒ 沒有人話可搬；它是從藍圖裁定
	#   「情境四動作不可做時列出＋原因」推出來的，不是我發明一個規則）。
	var r: Dictionary = precheck_take_loot(state, pt)
	if bool(r.get("ok", false)):
		return r
	return { "ok": false, "reason": "無可放棄的戰利品" }

func precheck_subjugate_enemy(state: WorldState, _pt: TeamData) -> Dictionary:
	var res: Dictionary = state.last_encounter_result
	if res.is_empty() or not bool(res.get("can_subjugate", false)):
		return { "ok": false, "reason": "無可收編的敗者" }
	return { "ok": true, "reason": "" }

func precheck_confirm_gather_intel(state: WorldState, _pt: TeamData) -> Dictionary:
	if not state.player_state.has("pending_intel_target"):
		# ★本票第二句新造的措辭 —— 而它是**藍圖裁定逐字給的那一句**
		#   （handler 的「參數遺漏」答的是另一個問題：參數完整嗎）。
		return { "ok": false, "reason": "沒有待確認的打聽" }
	return { "ok": true, "reason": "" }

func precheck_hunt(state: WorldState, pt: TeamData) -> Dictionary:
	if pt == null:
		return { "ok": false, "reason": "找不到玩家隊伍" }
	var tile: HexTileData = state.world.tiles.get(pt.tile_pos.x * 1000 + pt.tile_pos.y)
	if tile == null or int(tile.resources.get("wild_game", 0)) <= 0:
		return { "ok": false, "reason": "此地無獵物" }
	return { "ok": true, "reason": "" }

func precheck_hunt_beast(state: WorldState, pt: TeamData) -> Dictionary:
	if pt == null:
		return { "ok": false, "reason": "找不到玩家隊伍" }
	var tile: HexTileData = state.world.tiles.get(pt.tile_pos.x * 1000 + pt.tile_pos.y)
	if tile == null or int(tile.resources.get("predator_density", 0)) <= 0:
		return { "ok": false, "reason": "此地無猛獸可獵" }
	return { "ok": true, "reason": "" }

func precheck_camp(state: WorldState, pt: TeamData) -> Dictionary:
	# ★五句人話全部**搬自 handler**（原地只留呼叫）⇒ 查詢面不再重寫那 4 個條件
	var camp_type: String = str(state.player_state.get("build_type", "civilian"))
	if camp_type not in ["civilian", "military"]:
		return { "ok": false, "reason": "無效紮營類型" }
	if pt == null:
		return { "ok": false, "reason": "找不到玩家隊伍" }
	var tile: HexTileData = state.world.tiles.get(pt.tile_pos.x * 1000 + pt.tile_pos.y)
	if tile == null:
		return { "ok": false, "reason": "格子不存在" }
	if tile.outpost_level != 0 or tile.outpost_owner != -1:
		return { "ok": false, "reason": "此地已有據點" }
	if tile.terrain == "mountain":
		return { "ok": false, "reason": "山地無法紮營" }
	if not OutpostSystem.new()._check_distance(state, tile.tile_pos, camp_type):
		return { "ok": false, "reason": "離既有據點太近,無法紮營" }
	return { "ok": true, "reason": "" }

func precheck_train(state: WorldState, pt: TeamData) -> Dictionary:
	if pt == null:
		return { "ok": false, "reason": "找不到玩家隊伍" }
	if AnonTierSystem.total_pop(pt) <= 0:
		return { "ok": false, "reason": "無匿名人口可訓練" }
	if float(pt.resources.get("coin", 0)) < TRAIN_COST_COIN:
		# ★★那個數字從常數來（查詢面不准再寫一次 `TRAIN_COST_COIN`）——
		#   P3a 的行為證就是擾動這個常數之後**原因裡的數字要跟著變**。
		return { "ok": false, "reason": "coin 不足訓練（需 %.0f）" % TRAIN_COST_COIN }
	return { "ok": true, "reason": "" }

func precheck_promote_anon(_state: WorldState, pt: TeamData) -> Dictionary:
	if pt == null:
		return { "ok": false, "reason": "找不到玩家隊伍" }
	if AnonTierSystem.total_pop(pt) <= 0:
		return { "ok": false, "reason": "無匿名兵可拔擢" }
	return { "ok": true, "reason": "" }

# ★票 T：玩家「休息」—— 前置只問「累不累」（不累休息沒有東西可回復，說出來而不是吞掉）
func precheck_rest(_state: WorldState, pt: TeamData) -> Dictionary:
	if pt == null:
		return { "ok": false, "reason": "找不到玩家隊伍" }
	if pt.fatigue <= 0.0:
		return { "ok": false, "reason": "隊伍不累，不需要休息" }
	return { "ok": true, "reason": "" }

# ★★★★★【前置檢查的派發表】—— 全列版的迴圈靠它，而**床用它做第四條反向掃**：
#   每一個 `target=="none" and listed` 的動作都要在這裡有一支 ⇒ 漏一個紅並指名。
func _precheck_for(action: String) -> Callable:
	match action:
		"cancel_move":           return precheck_cancel_move
		"establish_faction":     return precheck_establish_faction
		"take_loot":             return precheck_take_loot
		"leave_loot":            return precheck_leave_loot
		"subjugate_enemy":       return precheck_subjugate_enemy
		"confirm_gather_intel":  return precheck_confirm_gather_intel
		"hunt":                  return precheck_hunt
		"hunt_beast":            return precheck_hunt_beast
		"camp":                  return precheck_camp
		"train":                 return precheck_train
		"promote_anon":          return precheck_promote_anon
		"rest":                  return precheck_rest
	return Callable()

# 同格閘的本體。★回空字典 ＝ 放行（★不回 bool：呼叫端要的是【那句人話】，
#   而把訊息與判斷放在同一個回傳裡，下一個人就不會另寫一份措辭）。
func _colocation_gate(state: WorldState, action: String, target_id: int, pt: TeamData) -> Dictionary:
	if not TEAM_TARGET_ACTIONS.has(action):
		return {}   # ★★契約上 target 不是別隊（自家隊動作／tile 動作）⇒ 本閘無關
	return refuse_if_not_colocated(state, target_id, pt)

# 距離檢查【本體】。★★★它與上面那支的分工：
#   ·`_colocation_gate` ＝【動詞閘】那個入口（`execute_action` 那條路，target 是 int 且
#     動詞決定契約）
#   ·本支 ＝ 那個入口用的判斷，而**第二個入口直接呼它**：
#     `_recruit_named_internal`（`execute_action_with_target` 那條路）的契約是
#     **靜態已知的**——它永遠是「向另一支隊買一個記名成員」⇒ 不需要問動詞。
#   ★★這個分工是 R² 擋件擋出來的（systems 裁 2026-09-30）：
#     我原本照用「吃 Dictionary 那條不在爆炸半徑內」這個結論而**沒有自己核**，
#     ⇒ ★★★而那句話的錯法是【拿入口當母體】：不變量的母體是
#       「哪些動作跟別隊發生作用」，不是「它從哪個函式進來」。
# ★★★【在遭遇中】那一閘的本體（systems 裁 2026-10-01 (b)）——
#   ★形狀沿用 `refuse_if_not_colocated`：**回空字典 ＝ 放行**／回 {ok,msg} ＝ 拒絕
#     ⇒ 訊息與判斷在**同一個回傳**（不回 bool），下一個人就不會另寫一份措辭。
#   ★★為什麼是【抽共用】而不是「兩邊措辭對齊」：對齊還是兩份字面，
#     而這張票正在數的就是「同一條規則有幾份」⇒ 在這張票裡新造第二份會與本票動機衝突。
#     ⇒ 措辭**逐字沿用既有那一句**（「非戰鬥中」），一個字都不新造。
#   ★★★而它有三個消費者，這是它存在的理由（不是「以後可能會用到」）：
#     ·`_action_offer_surrender`（本票補上的那一支）
#     ·`_action_surrender_in_encounter`（原本自己寫那一行的那一支）
#     ·`get_action_availability` 的 `offer_surrender` 那一臂（★`disabled_reason` 讀它回的 msg
#       ⇒ 全列版**不自己寫文案**，而「原因」與「判斷」仍然是同一個回傳）
func refuse_if_not_in_encounter(state: WorldState) -> Dictionary:
	if not state.encounter_active:
		return { "ok": false, "msg": "非戰鬥中" }
	return {}

func refuse_if_not_colocated(state: WorldState, target_id: int, pt: TeamData) -> Dictionary:
	if pt == null:
		return {}   # ★沒有玩家隊 ⇒ 這一閘沒有主詞；null 由既有的守衛負責回話
	var tgt: TeamData = state.teams.get(target_id)
	if tgt == null:
		return {}   # ★目標不存在 ⇒ 由各 handler 自己回話（不搶它的措辭）
	if tgt.team_id == pt.team_id:
		return {}   # ★對自己 ⇒ 永遠同格
	if pt.tile_pos != tgt.tile_pos:
		# ★人話（spec §2②）：玩家要看得懂【為什麼不行】，而不是一個錯碼。
		return { "ok": false, "msg": "對方不在你的格上" }
	return {}

# ── Action Handlers ───────────────────────────────────────────

func _action_hunt(state: WorldState, _target: int, pt: TeamData, _pt_id: int) -> Dictionary:
	# ★前置檢查【只有一份】（spec §3②）：條件與人話都在 `precheck_hunt()` 裡，
	#   原地只留呼叫 —— 全列版的迴圈呼的是同一支。
	var pre_h: Dictionary = precheck_hunt(state, pt)
	if not bool(pre_h.get("ok", false)):
		return { "ok": false, "msg": String(pre_h.get("reason", "")) }
	var tile: HexTileData = state.world.tiles.get(pt.tile_pos.x * 1000 + pt.tile_pos.y)
	var r: Dictionary = HuntSystem.new().hunt_small_game(state, pt, tile, true)
	return { "ok": true, "msg": r.get("msg", "") }

func _action_hunt_beast(state: WorldState, _target: int, pt: TeamData, pt_id: int) -> Dictionary:
	# ★前置檢查【只有一份】（spec §3②）：條件與人話都在 `precheck_hunt_beast()` 裡，
	#   原地只留呼叫 —— 全列版的迴圈呼的是同一支。
	var pre_hb: Dictionary = precheck_hunt_beast(state, pt)
	if not bool(pre_hb.get("ok", false)):
		return { "ok": false, "msg": String(pre_hb.get("reason", "")) }
	var tile: HexTileData = state.world.tiles.get(pt.tile_pos.x * 1000 + pt.tile_pos.y)
	# 依地形選獸級（簡版：山→bear、其餘→boar）。TEST VALUE，待 2b-2 量測調整。
	var kind: String = "bear" if tile.terrain == "mountain" else "boar"
	tile.resources["predator_density"] = int(tile.resources["predator_density"]) - 1   # 枯竭
	var bid: int = BeastSystem.new().build_beast_team(state, kind, pt.tile_pos)
	_encounter.init_encounter(state, pt_id, bid, "normal")
	return { "ok": true, "msg": "發起獵 %s" % kind, "requires_preview": false }

# 訓練/晉升：一次性花 coin → 給最低非菁英 tier 一批 exp → 立即嘗試升階（reuse AnonTierSystem,玩家版比 NPC 完整）
# coin 守恆：訓練餉銀入自隊公庫(anon_treasury),不蒸發（對齊 try_promote「訓練餉銀入公庫」）。
func _action_train(state: WorldState, _target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	# ★前置檢查【只有一份】（spec §3②）：條件與人話都在 `precheck_train()` 裡，
	#   原地只留呼叫 —— 全列版的迴圈呼的是同一支。
	var pre_t: Dictionary = precheck_train(state, pt)
	if not bool(pre_t.get("ok", false)):
		return { "ok": false, "msg": String(pre_t.get("reason", "")) }
	ResourceBank.add(pt, "coin", -TRAIN_COST_COIN, "player_train")
	AnonTreasuryBank.deposit(pt, TRAIN_COST_COIN, "train_salary")   # 守恆：餉銀入公庫,不蒸發（coin_eq 不破）
	var target_tier: String = ""
	for tier in AnonTierSystem.TIER_ORDER:
		if tier == AnonCohort.TIER_ELITE: break
		if int(pt.anon_tiers.get(tier, 0)) > 0:
			target_tier = tier; break
	if target_tier == "":
		return { "ok": true, "msg": "訓練（-%.0f coin,無可升階對象）" % TRAIN_COST_COIN }
	AnonTierSystem.add_exp(pt, target_tier, TRAIN_EXP_GAIN, "train_player")
	var promoted: int = 0
	for tier in AnonTierSystem.TIER_ORDER:
		if tier == AnonCohort.TIER_ELITE: break
		var n: int = int(pt.anon_tiers.get(tier, 0))
		if n > 0:
			promoted += AnonTierSystem.try_promote(state, pt, tier, n)
	var msg: String = "訓練（-%.0f coin → %s +exp" % [TRAIN_COST_COIN, target_tier]
	if promoted > 0:
		msg += "，升階 %d 人" % promoted
	msg += "）"
	return { "ok": true, "msg": msg, "payload": {"promoted": promoted} }

# 拔擢匿名→記名（對稱性）：玩家版走與 NPC 同一條路徑 PersonGenerator.generate_for_team
# （已含「從 anon 桶移除 1 + treasury×3 bonus + 加 state.persons」）。command 只負責 append named_members。
# population getter 自動守恆：anon-1 / named+1,總 pop 不變。NPC 缺 named 時自動拔擢,玩家無對應 → 全 anon 隊永遠卡(無法派子隊/任命),此 command 補上。
func _action_promote_anon(state: WorldState, _target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	# ★前置檢查【只有一份】（spec §3②）：條件與人話都在 `precheck_promote_anon()` 裡，
	#   原地只留呼叫 —— 全列版的迴圈呼的是同一支。
	var pre_pa: Dictionary = precheck_promote_anon(state, pt)
	if not bool(pre_pa.get("ok", false)):
		return { "ok": false, "msg": String(pre_pa.get("reason", "")) }
	var p: PersonData = PersonGenerator.generate_for_team(state, pt, "member")
	if p == null:
		return { "ok": false, "msg": "拔擢失敗（無可拔擢 anon）" }
	state.add_member(pt, p.id)   # 拔擢 anon→named（leader 不變,新增 named 成員）
	return { "ok": true, "msg": "拔擢 %s 為記名成員" % p.person_name }

# ★票 T（spec 2026-10-06 ticket-t-fatigue §1③）：玩家下令休息 ⇒ 原地停下（TASK_REST）
#   ⇒ 疲勞分類落「不耗力」⇒ 回復；★不移動（move_target 清空）——休息就是停下來
func _action_rest(state: WorldState, _target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var pre_r: Dictionary = precheck_rest(state, pt)
	if not bool(pre_r.get("ok", false)):
		return { "ok": false, "msg": String(pre_r.get("reason", "")) }
	if not TaskArbiter.try_set(state, pt, TeamData.TASK_REST, Vector2i(-1, -1), TaskArbiter.PRIO_PLAYER, "player_rest"):
		return { "ok": false, "msg": "現在停不下來（有更急的事）" }
	return { "ok": true, "msg": "原地休息（疲勞 %d%%）" % int(round(pt.fatigue * 100.0)) }

# 紮營（Y 版,生存落腳）：免材料 + 無即時糧（只抬 cap）+ 距離 spacing + 限時施工。
# 玩家發起的限時建造令（設玩家隊 task=建設,PRIO_PLAYER）→ construction 推進 → 完工釋放回 idle。
func _action_camp(state: WorldState, _target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	# ★前置檢查【只有一份】（spec §3②）：條件與人話都在 `precheck_camp()` 裡，
	#   原地只留呼叫 —— 全列版的迴圈呼的是同一支。
	#   ★★而本支是 (甲) 那個病最清楚的實例：查詢面原本**複製了 4 個條件**
	#     （`outpost_level`／`outpost_owner`／`terrain`／`_check_distance`），
	#     而這裡有**5 句人話** ⇒ 現在只有一份。
	var pre_c: Dictionary = precheck_camp(state, pt)
	if not bool(pre_c.get("ok", false)):
		return { "ok": false, "msg": String(pre_c.get("reason", "")) }
	var camp_type: String = str(state.player_state.get("build_type", "civilian"))
	var tile: HexTileData = state.world.tiles.get(pt.tile_pos.x * 1000 + pt.tile_pos.y)
	var os := OutpostSystem.new()
	# ★同 faction_ai 的紮根：記下實付工量，讓 construction_ticks_total 分得出兩種 crude_camp
	tile.construction_target = { "action": "crude_camp", "type": camp_type, "level": 1, "owner": pt.team_id,
		"person_hours": OutpostSystem.build_person_hours("camp") }
	tile.construction_ticks_left = OutpostSystem.build_person_hours("camp")
	tile.construction_started_tick = -1
	TaskArbiter.try_set(state, pt, TeamData.TASK_BUILD, pt.tile_pos, TaskArbiter.PRIO_PLAYER, "player_camp")
	return { "ok": true, "msg": "開始紮營 %s（%d 人時,免材料）" % [camp_type, OutpostSystem.build_person_hours("camp")] }

func _action_extract_treasury(state: WorldState, _target: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var ratio: float = float(state.player_state.get("extract_ratio", 0.0))
	if ratio <= 0.0 or ratio > 1.0:
		return { "ok": false, "msg": "徵用比例必須在 0 與 1 之間" }
	CoinTreasury.extract_treasury(state, pt, ratio, "玩家主動")
	return { "ok": true, "msg": "徵用 %.0f%%" % (ratio * 100) }

func _action_withdraw_from_storage(state: WorldState, _target: int, pt: TeamData, pt_id: int) -> Dictionary:
	var res: String = state.player_state.get("storage_res", "")
	var amount: float = float(state.player_state.get("storage_amount", 0.0))
	if res == "" or amount <= 0: return { "ok": false, "msg": "未指定資源或數量" }
	var tile: HexTileData = state.world.tiles.get(pt.tile_pos.x * 1000 + pt.tile_pos.y)
	if tile == null or tile.outpost_owner != pt_id: return { "ok": false, "msg": "非自家 outpost" }
	var stored: float = float(tile.public_storage.get(res, 0))
	if stored < amount: return { "ok": false, "msg": "公庫不足" }
	TileBank.set_amt(tile, res, stored - amount, "player_withdraw_storage")   # ★單寫者（值不變）
	ResourceBank.add(pt, res, amount, "withdraw_storage")
	return { "ok": true, "msg": "取 %s × %.0f" % [res, amount] }

func _action_deposit_to_storage(state: WorldState, _target: int, pt: TeamData, pt_id: int) -> Dictionary:
	var res: String = state.player_state.get("storage_res", "")
	var amount: float = float(state.player_state.get("storage_amount", 0.0))
	if res == "" or amount <= 0: return { "ok": false, "msg": "未指定資源或數量" }
	var tile: HexTileData = state.world.tiles.get(pt.tile_pos.x * 1000 + pt.tile_pos.y)
	if tile == null or tile.outpost_owner != pt_id: return { "ok": false, "msg": "非自家 outpost" }
	var have: float = float(pt.resources.get(res, 0))
	if have < amount: return { "ok": false, "msg": "team 資源不足" }
	var cap: float = OutpostSystem.new()._get_storage_cap(tile, res)
	var stored: float = float(tile.public_storage.get(res, 0))
	if stored + amount > cap: return { "ok": false, "msg": "公庫已滿" }
	TileBank.set_amt(tile, res, stored + amount, "player_deposit_storage")   # ★單寫者（值不變；cap 已在上面自行檢查過）
	ResourceBank.set_amt(pt, res, have - amount, "deposit_storage")
	return { "ok": true, "msg": "存 %s × %.0f" % [res, amount] }

func _action_trade(state: WorldState, target_id: int, _pt: TeamData, _pt_id: int) -> Dictionary:
	var tgt: TeamData = state.teams.get(target_id)
	if tgt == null:
		state.player_pending_targets.erase(target_id)
		return { "ok": false, "msg": "目標不存在" }
	state.player_state["pending_trade_target"] = target_id
	return { "ok": true, "msg": "等待確認",
			 "requires_preview": true, "preview_target_id": target_id }

func _action_propose_alliance(state: WorldState, target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	var tgt: TeamData = state.teams.get(target_id)
	if tgt == null:
		return { "ok": false, "msg": "目標不存在" }
	var resp: String = _diplomatic.handle_diplomacy_message(state, tgt, pt, "propose_alliance")
	if resp == "accept":
		if pt.faction_id == -1 and tgt.faction_id == -1:
			state.create_faction(pt_id)
		_diplomatic._form_alliance(state, pt, tgt)
		print("[PlayerCmd] 同盟成立，勢力%d" % pt.faction_id)
	state.player_pending_targets.erase(target_id)
	# ★玩家面字串零英文識別字（⑤ 那張票的不變量）：`resp` 是引擎的 id（accept／refuse／reject）
	#   ⇒ 不能直接印給玩家。★中文來自唯一生產者 `PlayerApiMapper`，不在這裡寫第二份。
	return { "ok": resp == "accept",
		"msg": "外交結果：%s" % PlayerApiMapper.diplomacy_reply_label(resp) }

func _action_demand_tribute(state: WorldState, target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var tgt: TeamData = state.teams.get(target_id)
	if tgt == null:
		return { "ok": false, "msg": "目標不存在" }
	var resp: String = _diplomatic.handle_diplomacy_message(state, tgt, pt, "demand_tribute")
	state.player_pending_targets.erase(target_id)
	if resp == "accept":
		# ★★★改呼共用解算點（spec 2026-09-30 §6①）：金額與恩怨兩件事都在那一支裡，
		#   而 NPC↔NPC 那條路呼的是**同一支** ⇒ 一個真相只存一份。
		#   ★係數的字面從這裡消失（它現在是 `DiplomaticAiSystem.TRIBUTE_TAKE_RATIO`）
		#     —— 床的靜態證就在驗這件事：這一行不得出現 0.1 的字面。
		var coin_before: float = float(tgt.resources.get("coin", 0))
		var amount: float = DiplomaticAiSystem.apply_tribute_accept(state, tgt, pt)
		# ★★★濫按索貢的煞車（用戶裁的兩層關係帳）：被索方的領袖記一次 "tributed"
		#   ⇒ 好感層 -intensity×0.5（煞車本體）；記憶層要過 FEUD_MIN 0.30 才寫 feud 邊，
		#     而 intensity＝拿走幾成＝0.1 × 人格乘子（上界 1.3）⇒ **小索貢不寫邊是正確行為**。
		#   ★寫入點放在【執行端】不放在秤裡：秤（`tribute_accept`）會被評估路徑多次呼叫，
		#     而「真的被拿走了」只發生在這裡。
		#   ★★`coin_before <= 0` 不寫：拿走 0 不是一件被記得住的事，而 0/0 也算不出比例。
		# ★恩怨那一段已經搬進共用解算點（`DiplomaticAiSystem.apply_tribute_accept`）
		#   ⇒ 這裡不再有第二份；NPC↔NPC 那條路因此**自動**也有煞車（藍圖要的那一句）。
		print("[PlayerCmd] 索貢成功 Team%d→玩家 %.0f coin" % [target_id, amount])
		return { "ok": true, "msg": "索貢成功（獲得%.0f coin）" % amount }
	else:
		UnrestBank.add(tgt, 2, "player")
		var leader_p: PersonData = state.persons.get(tgt.leader_id)
		if leader_p:
			leader_p.memory.append({
				"event_id": state.world.current_tick,
				"intensity": "significant",
				"reaction": "tribute_refused"
			})
		print("[PlayerCmd] 索貢遭拒 Team%d unrest+2" % target_id)
		return { "ok": false, "msg": "索貢遭拒，關係惡化" }

func _action_attack(state: WorldState, target_id: int, _pt: TeamData, pt_id: int) -> Dictionary:
	var tgt: TeamData = state.teams.get(target_id)
	if tgt == null:
		return { "ok": false, "msg": "目標不存在" }
	_encounter.init_encounter(state, pt_id, target_id, "normal")
	if not state.player_hostile_teams.has(target_id):
		state.player_hostile_teams.append(target_id)
	state.player_pending_targets.erase(target_id)
	print("[PlayerCmd] 玩家發起攻擊 Team%d → Team%d" % [pt_id, target_id])
	return { "ok": true, "msg": "發起攻擊" }

func _action_extort(state: WorldState, target_id: int, _pt: TeamData, pt_id: int) -> Dictionary:
	var extort_result := _interaction.resolve_extortion_direct(state, pt_id, target_id)
	state.player_pending_targets.erase(target_id)
	if not extort_result.get("accepted", true):
		var tgt2: TeamData = state.teams.get(target_id)
		if tgt2:
			UnrestBank.add(tgt2, 1, "player")
		print("[PlayerCmd] 勒索遭拒 Team%d unrest+1" % target_id)
	# ★accepted 照傳（handler 契約：ok＝指令有執行、accepted＝對方答應）—— 舊版丟掉它 ⇒ 被拒的勒索在結果句上讀起來是成功
	return { "ok": extort_result.get("ok", false), "msg": extort_result.get("msg", ""),
		"accepted": bool(extort_result.get("accepted", true)) }

func _action_recruit(state: WorldState, target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	# Always return a menu — never auto-execute. Player must call recruit_anon or recruit_named.
	var tgt: TeamData = state.teams.get(target_id)
	if tgt == null:
		state.player_pending_targets.erase(target_id)
		return { "ok": false, "msg": "目標不存在" }
	var willing: Array = []
	for pid in tgt.named_members:
		if pid == tgt.leader_id: continue
		var person: PersonData = state.persons.get(pid)
		if person and person.loyalty < 0.4:
			willing.append(pid)
	var coin: float      = float(pt.resources.get("coin", 0))
	var anon_ok: bool    = coin >= RECRUIT_COST_ANON and tgt.population > 1
	var willing_dto: Array = []
	if not willing.is_empty():
		willing_dto = PlayerApiMapper.map_willing_members(state, willing)
	return { "ok": true, "msg": "選擇招募方式",
			 "payload": {
				 "has_willing_named":   not willing.is_empty(),
				 "willing_members":     willing_dto,
				 "anon_available":      anon_ok,
				 "anon_cost":           int(RECRUIT_COST_ANON),
				 "named_cost":          int(RECRUIT_COST_NAMED),
				 "target_team_id":      target_id
			 }}


func _action_recruit_anon(state: WorldState, target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var tgt3: TeamData = state.teams.get(target_id)
	if tgt3 == null:
		return { "ok": false, "msg": "目標不存在" }
	return _recruit_anon_internal(state, pt, tgt3, target_id)

func _action_take_loot(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	# ★前置檢查【只有一份】（spec §3②）：條件與人話都在 `precheck_take_loot()` 裡，
	#   原地只留呼叫 —— 全列版的迴圈呼的是同一支。
	var pre_tl: Dictionary = precheck_take_loot(state, pt)
	if not bool(pre_tl.get("ok", false)):
		return { "ok": false, "msg": String(pre_tl.get("reason", "")) }
	var res: Dictionary = state.last_encounter_result
	var loot: Dictionary = res.get("loot_pool", {})
	var loser_team: TeamData = state.teams.get(res.get("loser_id", -1))
	for rk in loot:
		var amount: float = float(loot[rk])
		if loser_team != null:
			ResourceBank.remove(loser_team, rk, amount, "collect_loot_out")
		ResourceBank.add(pt, rk, amount, "collect_loot_in")
	state.last_encounter_result = {}
	print("[PlayerCmd] 收取戰利品: %s" % str(loot))
	return { "ok": true, "msg": "收取戰利品成功",
			 "payload": {"refresh_required": true} }

func _action_leave_loot(state: WorldState, _target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	# ★前置檢查【只有一份】（spec §3②）：條件與人話都在 `precheck_leave_loot()` 裡，
	#   原地只留呼叫 —— 全列版的迴圈呼的是同一支。
	#   ★★而這一支原本【完全沒有條件】（永遠成功）⇒ 本票給了它一個
	#     （理由在 `precheck_leave_loot` 旁邊：藍圖裁「不可做時列出＋原因」）
	#     ⇒ 這是一個**行為改變**：在沒有剛結束的戰鬥時呼它，現在會被拒絕。
	var pre_ll: Dictionary = precheck_leave_loot(state, pt)
	if not bool(pre_ll.get("ok", false)):
		return { "ok": false, "msg": String(pre_ll.get("reason", "")) }
	state.last_encounter_result = {}
	return { "ok": true, "msg": "放棄戰利品" }

func _action_establish_faction_cmd(state: WorldState, _target_id: int, _pt: TeamData, _pt_id: int) -> Dictionary:
	return establish_faction(state)

func _action_refresh_targets(state: WorldState, _target_id: int, _pt: TeamData, _pt_id: int) -> Dictionary:
	refresh_colocation_targets(state)
	return { "ok": true, "msg": "互動目標已更新" }

# ★★★★★【已退場 2026-10-01】「不配對、照預覽價直接成交」那條路線 ——
#   藍圖裁 (乙)：世界裡沒有這個機制，只有一條**玩家專用捷徑**，而活介面進不去。
#   ★能力沒有少：出價那一路（`submit_trade_offer`）一行沒動，活介面直接 emit 它
#     （`text_ui_main.gd:2719`）⇒ 刪掉的是**那個鍵**不是那個能力。
#   ★★連帶**三支**一起走（遞移閉包數到「新增的零呼叫點集合為空」才停 ——
#     而第三支是 systems 自己漏掉、我核出來的：它唯一的呼叫點在第二支的函式體裡）。
#   ★★★那三支叫什麼**刻意不寫在這裡**：P1／P2 的地板是 `grep -rn <名字> scripts/` ＝ 0，
#     而描述它們與使用它們在文字上同形 ⇒ 名單在退場票 spec 的 §3。

func _action_submit_trade_offer(state: WorldState, _target_id: int, _pt: TeamData, pt_id: int) -> Dictionary:
	var tid: int          = int(state.player_state.get("pending_trade_target", -1))
	var offer: Dictionary = state.player_state.get("trade_offer", {})
	if tid < 0 or offer.is_empty():
		return { "ok": false, "msg": "無待送出的出價" }
	if not state.teams.has(tid):
		return { "ok": false, "msg": "目標隊伍不存在" }
	var result := PlayerTradeSystem.new().execute_offer(state, pt_id, tid, offer)
	if result.get("ok", false):
		state.player_pending_targets.erase(tid)
		state.player_state.erase("pending_trade_target")
		state.player_state.erase("trade_offer")
	return result

func _action_cancel_trade(state: WorldState, _target_id: int, _pt: TeamData, _pt_id: int) -> Dictionary:
	var tid3: int = int(state.player_state.get("pending_trade_target", -1))
	if tid3 >= 0:
		state.player_pending_targets.erase(tid3)
	state.player_state.erase("pending_trade_target")
	return { "ok": true, "msg": "取消貿易" }

func _action_set_tribute_rate(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	var rate: float = float(state.player_state.get("tribute_rate_input", 0.1))
	rate = clampf(rate, 0.0, 1.0)
	if pt.faction_id == -1:
		return { "ok": false, "msg": "玩家不在勢力中" }
	var f_tr: FactionData = state.factions.get(pt.faction_id)
	if f_tr == null:
		return { "ok": false, "msg": "勢力不存在" }
	if f_tr.leader_team_id != pt_id:
		return { "ok": false, "msg": "只有 leader 可設定徵收率" }
	f_tr.tribute_rate = rate
	print("[PlayerCmd] set_tribute_rate → %.2f" % rate)
	return { "ok": true, "msg": "徵收率設為 %.0f%%" % (rate * 100) }

# U18：設自隊匿名武裝比例（none-target，比照 set_tribute_rate）
func _action_set_armed_ratio(state: WorldState, _target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var r: float = clampf(float(state.player_state.get("armed_ratio_input", pt.armed_anon_ratio)), 0.0, 1.0)
	pt.armed_anon_ratio = r
	print("[PlayerCmd] set_armed_anon_ratio → %.2f" % r)
	return { "ok": true, "msg": "武裝比例設為 %.0f%%" % (r * 100.0) }

func _action_build_outpost(state: WorldState, _target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var outpost_type: String = str(state.player_state.get("build_type", "civilian"))
	if outpost_type not in ["civilian", "military"]:
		return { "ok": false, "msg": "無效據點類型" }
	var _os := OutpostSystem.new()
	var ok: bool = _os.start_build(state, pt, outpost_type, 1)
	if not ok:
		return { "ok": false, "msg": "無法建造（資源不足或距離限制）" }
	print("[PlayerCmd] build_outpost type=%s" % outpost_type)
	return { "ok": true, "msg": "開始建造 %s" % outpost_type }

func _action_upgrade_outpost(state: WorldState, _target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var _os2 := OutpostSystem.new()
	var ok2: bool = _os2.start_upgrade_level(state, pt)
	if not ok2:
		return { "ok": false, "msg": "無法升級（不是你的據點或已滿級）" }
	return { "ok": true, "msg": "開始升級據點" }

func _action_upgrade_farming(state: WorldState, _target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var _os3 := OutpostSystem.new()
	var ok3: bool = _os3.start_upgrade_farming(state, pt)
	if not ok3:
		return { "ok": false, "msg": "無法升級農地（不是民用據點或已滿級）" }
	return { "ok": true, "msg": "開始升級農業" }

func _action_upgrade_manufacturing(state: WorldState, _target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var _os4 := OutpostSystem.new()
	var ok4: bool = _os4.start_upgrade_manufacturing(state, pt)
	if not ok4:
		return { "ok": false, "msg": "無法升級製造（條件不符）" }
	return { "ok": true, "msg": "開始升級製造" }

# 統一設施擴建入口：依 player_state["facility_type"] 走通用 start_upgrade_facility
func _action_build_facility(state: WorldState, _target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var facility: String = str(state.player_state.get("facility_type", "farming"))
	if facility == "manufacturing":
		facility = "workshop"   # 舊指令別名
	if not OutpostSystem.FACILITY_DEF.has(facility):
		return { "ok": false, "msg": "未知 facility: %s" % facility }
	var _os := OutpostSystem.new()
	var ok: bool = _os.start_upgrade_facility(state, pt, facility)
	if not ok:
		return { "ok": false, "msg": "無法擴建%s（條件不符）" % PlayerApiMapper.facility_label(facility) }
	return { "ok": true, "msg": "開始擴建%s" % PlayerApiMapper.facility_label(facility) }

func _action_demolish_outpost(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	var _os5 := OutpostSystem.new()
	var tile_id5: int = pt.tile_pos.x * 1000 + pt.tile_pos.y
	var tile5: HexTileData = state.world.tiles.get(tile_id5)
	if tile5 == null:
		return { "ok": false, "msg": "格子不存在" }
	if tile5.construction_ticks_left > 0 and tile5.outpost_level == 0:
		tile5.construction_team_id   = -1
		tile5.construction_ticks_left = 0
		tile5.construction_target     = {}
		TaskArbiter.release(pt)
		return { "ok": true, "msg": "取消施工" }
	if not _os5._has_control(state, pt_id, tile5):
		return { "ok": false, "msg": "無支配權，無法拆除" }
	var ok5: bool = _os5.demolish_with_control(state, pt)
	if not ok5:
		return { "ok": false, "msg": "無法拆除" }
	return { "ok": true, "msg": "開始拆除據點" }

func _action_abandon_outpost(state: WorldState, _target_id: int, _pt: TeamData, pt_id: int) -> Dictionary:
	var pos_arr: Array = state.player_state.get("abandon_pos", [-1, -1])
	var pos := Vector2i(int(pos_arr[0]), int(pos_arr[1]))
	if pos.x < 0:
		return { "ok": false, "msg": "未指定據點位置" }
	var tile: HexTileData = state.world.tiles.get(pos.x * 1000 + pos.y)
	if tile == null or tile.outpost_level == 0:
		return { "ok": false, "msg": "目標無 outpost" }
	if tile.outpost_owner != pt_id:
		return { "ok": false, "msg": "非自家 outpost" }
	OutpostOwnerBank.set_owner(tile, -1, "abandon")
	return { "ok": true, "msg": "已棄置 outpost (%d,%d)" % [pos.x, pos.y] }

func _action_dispatch_subteam(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	var sub_leader_id: int = int(state.player_state.get("sub_leader_id", -1))
	var pop_count: int     = int(state.player_state.get("sub_pop_count", 1))
	var task: String       = str(state.player_state.get("sub_task", TeamData.TASK_IDLE))
	var tq: int = int(state.player_state.get("sub_move_q", -1))
	var tr: int = int(state.player_state.get("sub_move_r", -1))
	var move_tgt: Vector2i = Vector2i(tq, tr)
	if sub_leader_id == -1 or not state.persons.has(sub_leader_id):
		return { "ok": false, "msg": "未指定子隊統領" }
	if pop_count < 1 or pop_count >= pt.population:
		return { "ok": false, "msg": "人數不合法（1 ~ population-1）" }
	var sub_id: int = SubteamSystem.new().dispatch(state, pt_id, sub_leader_id, pop_count, task, move_tgt)
	if sub_id == -1:
		return { "ok": false, "msg": "派遣失敗" }
	return { "ok": true, "msg": "派出子隊 Team%d" % sub_id, "sub_id": sub_id }

func _action_order_subteam(state: WorldState, _target_id: int, _pt: TeamData, pt_id: int) -> Dictionary:
	var sub_id2: int   = int(state.player_state.get("order_sub_id", -1))
	var new_task: String = str(state.player_state.get("sub_new_task", TeamData.TASK_IDLE))
	var nq: int = int(state.player_state.get("sub_new_move_q", -1))
	var nr: int = int(state.player_state.get("sub_new_move_r", -1))
	var sub2: TeamData = state.teams.get(sub_id2)
	if sub2 == null or sub2.parent_team_id != pt_id:
		return { "ok": false, "msg": "目標不是玩家子隊" }
	if new_task == TeamData.TASK_IDLE:
		TaskArbiter.release(sub2)
		sub2.move_target = Vector2i(nq, nr)
	elif not TaskArbiter.try_set(state, sub2, new_task, Vector2i(nq, nr),
			TaskArbiter.PRIO_PLAYER, "player_order"):
		return { "ok": false, "msg": "Team%d 正忙（更高優先任務 %s）" % [sub_id2, sub2.current_task] }
	print("[PlayerCmd] order_subteam Team%d → task=%s move=(%d,%d)" % [sub_id2, new_task, nq, nr])
	return { "ok": true, "msg": "已下令 Team%d" % sub_id2 }

func _action_recall_subteam(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	var recall_sub_id: int = int(state.player_state.get("recall_sub_id", -1))
	var recall_sub: TeamData = state.teams.get(recall_sub_id)
	if recall_sub == null or recall_sub.parent_team_id != pt_id:
		return { "ok": false, "msg": "目標不是玩家子隊" }
	if pt.population < 2:
		return { "ok": false, "msg": "人數不足以派信使" }
	var herald_leader_id: int = -1
	for pid in pt.named_members:
		if pid != pt.leader_id:
			herald_leader_id = pid
			break
	if herald_leader_id == -1:
		return { "ok": false, "msg": "無可用的信使人選" }
	var herald_id: int = SubteamSystem.new().dispatch(
		state, pt_id, herald_leader_id, 1, TeamData.TASK_HERALD,
		recall_sub.tile_pos, recall_sub_id, TeamData.TASK_MERGE)
	if herald_id == -1:
		return { "ok": false, "msg": "派信使失敗" }
	return { "ok": true, "msg": "信使已出發至 Team%d" % recall_sub_id }

func _action_subjugate_enemy(state: WorldState, _target_id: int, _pt: TeamData, pt_id: int) -> Dictionary:
	# ★前置檢查【只有一份】（spec §3②）：條件與人話都在 `precheck_subjugate_enemy()` 裡，
	#   原地只留呼叫 —— 全列版的迴圈呼的是同一支。
	var pre_se: Dictionary = precheck_subjugate_enemy(state, _pt)
	if not bool(pre_se.get("ok", false)):
		return { "ok": false, "msg": String(pre_se.get("reason", "")) }
	var result: Dictionary = state.last_encounter_result
	var loser_id: int = int(result.get("loser_id", -1))
	var loser: TeamData = state.teams.get(loser_id)
	if loser == null:
		return { "ok": false, "msg": "敗者已消滅" }
	_interaction.subjugate_team(state, pt_id, loser_id)
	state.last_encounter_result["can_subjugate"] = false
	return { "ok": true, "msg": "收編 Team%d" % loser_id }

func _action_leave_faction(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	if pt.faction_id == -1:
		return { "ok": false, "msg": "玩家不在勢力中" }
	var fid3: int = pt.faction_id
	var f3: FactionData = state.factions.get(fid3)
	if f3 == null:
		return { "ok": false, "msg": "勢力不存在" }
	if f3.leader_team_id == pt_id:
		return { "ok": false, "msg": "請改用「解散勢力」（領袖不能普通離開）" }
	state.clear_team_faction(pt, WorldState.LEAVE_PLAYER)   # 玩家離開 faction（雙向同步）
	var leader_team3: TeamData = state.teams.get(f3.leader_team_id)
	if leader_team3 != null:
		var leader_p3: PersonData = state.persons.get(leader_team3.leader_id)
		if leader_p3:
			LoyaltyBank.adjust(leader_p3, -0.15, "faction_leave")
	print("[PlayerCmd] 玩家離開勢力%d" % fid3)
	return { "ok": true, "msg": "已離開勢力" }

func _action_betray_faction(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	if pt.faction_id == -1:
		return { "ok": false, "msg": "玩家不在勢力中" }
	var fid4: int = pt.faction_id
	var f4: FactionData = state.factions.get(fid4)
	if f4 == null:
		return { "ok": false, "msg": "勢力不存在" }
	for tid4 in f4.member_team_ids:
		if tid4 == pt_id: continue
		if not state.player_hostile_teams.has(tid4):
			state.player_hostile_teams.append(tid4)
	state.clear_team_faction(pt, WorldState.LEAVE_PLAYER_BETRAY)   # 玩家背叛離開 faction（雙向同步）
	state.player_state["betrayal_count"] = int(state.player_state.get("betrayal_count", 0)) + 1
	var leader_team4: TeamData = state.teams.get(f4.leader_team_id)
	if leader_team4 != null:
		var leader_p4: PersonData = state.persons.get(leader_team4.leader_id)
		if leader_p4:
			leader_p4.memory.append({
				"type": "betrayal", "subject_id": pt.leader_id,
				"tick": state.world.current_tick, "intensity": 0.9
			})
	print("[PlayerCmd] 玩家背叛勢力%d（betrayal_count=%d）" % [
		fid4, state.player_state["betrayal_count"]])
	return { "ok": true, "msg": "背叛勢力，原成員已敵對" }

func _action_disband_faction(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	if pt.faction_id == -1:
		return { "ok": false, "msg": "玩家不在勢力中" }
	var fid5: int = pt.faction_id
	var f5: FactionData = state.factions.get(fid5)
	if f5 == null:
		return { "ok": false, "msg": "勢力不存在" }
	if f5.leader_team_id != pt_id:
		return { "ok": false, "msg": "只有 leader 可解散勢力" }
	for tid5 in f5.member_team_ids:
		if tid5 == pt_id: continue
		var mt5: TeamData = state.teams.get(tid5)
		if mt5 == null: continue
		var lp5: PersonData = state.persons.get(mt5.leader_id)
		if lp5:
			LoyaltyBank.adjust(lp5, -0.3, "faction_disband")
	state.disband_faction(fid5)
	return { "ok": true, "msg": "勢力已解散" }

# 投降資產轉移：from 隊 30% 指定資源交給 to 隊（收編前戰利品，守恆）
func _transfer_surrender_assets(from: TeamData, to: TeamData) -> void:
	for res in SURRENDER_TRANSFER_RES:
		var amt: float = float(from.resources.get(res, 0)) * 0.3
		ResourceBank.add(from, res, -amt, "surrender_out")
		ResourceBank.add(to, res, amt, "surrender_in")

func _action_offer_surrender(state: WorldState, target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	# ★【在遭遇中】—— 本票補上的那一件（意圖帳 2026-10-01：遠程求和不該存在）。
	#   ★而【同格】那一件**不寫在這裡**：進了 `TEAM_TARGET_ACTIONS` 之後
	#     `_colocation_gate` 自動管它 ⇒ 在這裡再寫一份距離檢查就是第二份。
	var not_enc: Dictionary = refuse_if_not_in_encounter(state)
	if not not_enc.is_empty():
		return not_enc
	var tgt6: TeamData = state.teams.get(target_id)
	if tgt6 == null:
		return { "ok": false, "msg": "目標不存在" }
	var resp6: String = _diplomatic.handle_diplomacy_message(state, tgt6, pt, "offer_surrender")
	state.player_pending_targets.erase(target_id)
	if resp6 == "accept":
		_transfer_surrender_assets(pt, tgt6)
		_interaction.subjugate_team(state, target_id, pt_id)
		print("[PlayerCmd] 玩家投降 Team%d 接受" % target_id)
		return { "ok": true, "msg": "投降被接受，已被收編" }
	else:
		return { "ok": false, "msg": "對方拒絕接受投降" }

func _action_surrender_in_encounter(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	# ★這一行原本就在這裡（它是那句措辭的來源）⇒ 現在改呼共用那一支，
	#   而**回傳逐字不變**（同一個 msg）⇒ 本支的行為不該有任何變化（P5 守它）。
	var not_enc2: Dictionary = refuse_if_not_in_encounter(state)
	if not not_enc2.is_empty():
		return not_enc2
	var enemy_id6: int = state.encounter_defender_id if state.encounter_attacker_id == pt_id \
		else state.encounter_attacker_id
	var enemy6: TeamData = state.teams.get(enemy_id6)
	if enemy6 == null:
		return { "ok": false, "msg": "找不到對手" }
	var resp6b: String = _diplomatic.handle_diplomacy_message(state, enemy6, pt, "offer_surrender")
	if resp6b == "accept":
		_transfer_surrender_assets(pt, enemy6)
		_interaction.subjugate_team(state, enemy_id6, pt_id)
		_encounter.cleanup_encounter(state)
		print("[PlayerCmd] 玩家戰中投降，Team%d 接受" % enemy_id6)
		return { "ok": true, "msg": "投降被接受" }
	else:
		return { "ok": false, "msg": "對方拒絕" }

func _action_accept_encounter(state: WorldState, _target_id: int, _pt: TeamData, _pt_id: int) -> Dictionary:
	var pre: Dictionary = state.player_pre_encounter
	if pre.is_empty():
		return { "ok": false, "msg": "無待處理預備遭遇戰" }
	var atk_id: int = int(pre.get("attacker_id", -1))
	var def_id: int = int(pre.get("defender_id", -1))
	state.player_pre_encounter = {}
	_encounter.init_encounter(state, atk_id, def_id, "normal")
	print("[PlayerCmd] 玩家選擇迎擊，遭遇戰開始 Team%d vs Team%d" % [atk_id, def_id])
	return { "ok": true, "msg": "迎擊！遭遇戰開始" }

func _action_surrender_pre_encounter(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	var pre: Dictionary = state.player_pre_encounter
	if pre.is_empty():
		return { "ok": false, "msg": "無待處理預備遭遇戰" }
	var atk_id: int = int(pre.get("attacker_id", -1))
	var attacker: TeamData = state.teams.get(atk_id)
	if attacker == null:
		state.player_pre_encounter = {}
		return { "ok": false, "msg": "攻擊者不存在" }
	var resp: String = _diplomatic.handle_diplomacy_message(state, attacker, pt, "offer_surrender")
	state.player_pre_encounter = {}
	if resp == "accept":
		_transfer_surrender_assets(pt, attacker)
		_interaction.subjugate_team(state, atk_id, pt_id)
		print("[PlayerCmd] 玩家預備投降，Team%d 接受" % atk_id)
		return { "ok": true, "msg": "投降被接受，已被收編" }
	else:
		# 對方拒絕投降 → 強迫開戰
		_encounter.init_encounter(state, atk_id, pt_id, "normal")
		print("[PlayerCmd] 玩家預備投降遭拒，強制遭遇戰 Team%d vs Team%d" % [atk_id, pt_id])
		return { "ok": false, "msg": "對方拒絕投降，遭遇戰強制開始" }

func _action_set_faction_goal(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	if pt.faction_id == -1:
		return { "ok": false, "msg": "玩家不在勢力中" }
	var goal9: String = str(state.player_state.get("faction_goal_input", ""))
	if goal9 not in ["expand", "defend", "trade_net", ""]:
		return { "ok": false, "msg": "無效目標（expand/defend/trade_net/空字串清除）" }
	var f9: FactionData = state.factions.get(pt.faction_id)
	if f9 == null:
		return { "ok": false, "msg": "勢力不存在" }
	if f9.leader_team_id != pt_id:
		return { "ok": false, "msg": "只有 leader 可設定勢力目標" }
	f9.player_goal_override = goal9
	var msg9: String = "清除指定目標" if goal9.is_empty() else "勢力目標設為 %s" % goal9
	print("[PlayerCmd] set_faction_goal → %s" % goal9)
	return { "ok": true, "msg": msg9 }

func _action_order_faction_member(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	var member_team_id: int   = int(state.player_state.get("order_member_id", -1))
	var m_task: String        = str(state.player_state.get("member_task", ""))
	var member_team: TeamData = state.teams.get(member_team_id)
	if member_team == null:
		return { "ok": false, "msg": "目標成員不存在" }
	if m_task.is_empty():
		return { "ok": false, "msg": "未指定任務" }
	if pt.population < 2:
		return { "ok": false, "msg": "人數不足以派信使" }
	# 從 named_members 選一非 leader 的成員當信使
	var herald_leader_id: int = -1
	for pid in pt.named_members:
		if pid != pt.leader_id:
			herald_leader_id = pid
			break
	if herald_leader_id == -1:
		return { "ok": false, "msg": "無可用的信使人選（需至少一名非隊長的記名成員）" }
	var herald_id: int = _subteam.dispatch(
		state, pt_id, herald_leader_id, 1, TeamData.TASK_HERALD,
		member_team.tile_pos, member_team_id, m_task)
	if herald_id == -1:
		return { "ok": false, "msg": "派信使失敗" }
	state.player_pending_orders[str(member_team_id)] = {"task": m_task, "herald_id": herald_id}
	print("[PlayerCmd] order_faction_member Team%d → herald Team%d 傳達任務: %s" % [member_team_id, herald_id, m_task])
	return { "ok": true, "msg": "信使 Team%d 已出發至 Team%d" % [herald_id, member_team_id] }

func _action_gather_intel(state: WorldState, target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var tgt_gi: TeamData = state.teams.get(target_id)
	if tgt_gi == null:
		return { "ok": false, "msg": "目標不存在" }
	var options: Array = InquirySystem.new().get_options(state, pt, tgt_gi)
	if options.is_empty():
		return { "ok": false, "msg": "無可打聽的情報" }
	return {
		"ok": true,
		"msg": "選擇要打聽的情報",
		"payload": { "inquiry_options": options, "npc_id": target_id }
	}

func _action_confirm_gather_intel(state: WorldState, _target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var npc_id_gi: int     = int(state.player_state.get("gather_intel_npc_id", -1))
	var choice_gi: String  = str(state.player_state.get("gather_intel_choice", ""))
	var npc_gi: TeamData   = state.teams.get(npc_id_gi)
	if npc_gi == null or choice_gi.is_empty():
		return { "ok": false, "msg": "參數遺漏" }
	var result_gi: Dictionary = InquirySystem.new().resolve_inquiry(state, pt, npc_gi, choice_gi)
	# ══════ 打聽 v1（spec 2026-09-25）══════
	# ★★★情報【必進 belief】，而走的是既有那條 relay —— `_exchange_intel()`（單向：我問他）。
	#   ★單向的理由：打聽是「我問他」，不是互換。`message_system.gd:187-188` 那兩行是
	#     【到達】的語意，不是本票的。
	#   ★★而這裡【不另寫一份 claim 組裝碼】：全庫 `record_claim(` 的 production 呼叫點
	#     動工前 4 個、動工後仍是 4 個 —— ★★★出現第五個就是這一票寫錯了。
	# ★`ask_faction_status` 是【刻意的例外】，不寫 belief：它問的是玩家自己的 faction
	#   ＝ self-knowledge，不是別人給的情報（spec §2／§3(D)）。
	var msg_gi: String = "情報獲取"
	var out_gi: Dictionary = {}
	if choice_gi == "ask_faction_status":
		msg_gi = "你確認了自家勢力的狀況"
	else:
		SimMessageSystem.new()._exchange_intel(state, npc_id_gi, _pt_id, choice_gi, out_gi)
		# ★★★三句話要【機械可判】＝三個不同的字串（spec §3(C)，床 grep 它們）：
		#   ①拒答（mode == silent）②答了但他也不知道（零筆寫入）③給了東西
		#   ⇒ ★「他不願多說」與「他也不知道」【必須不同】——
		#     混成一句的話，玩家分不出「關係壞」與「他真的沒情報」，
		#     而那兩件事的處置完全相反（一個要修關係，一個要換人問）。
		var mode_gi: String = String(out_gi.get("mode", ""))
		var wrote_gi: int = int(out_gi.get("written", 0))
		if mode_gi == "silent":
			msg_gi = "他不願多說"
		elif wrote_gi <= 0 and _inquiry_payload_empty(result_gi):
			msg_gi = "他也不知道"
		else:
			msg_gi = "他說了些事情（記下 %d 筆，來自 Team%d）" % [wrote_gi, npc_id_gi]
	print("[PlayerCmd] gather_intel choice=%s mode=%s 寫入=%d 結果筆數=%d" % [
		choice_gi, String(out_gi.get("mode", "n/a")), int(out_gi.get("written", 0)), result_gi.size()])
	return { "ok": true, "msg": msg_gi, "payload": result_gi }

# ★★★「他也不知道」的判準：不能用 `result_gi.is_empty()` ——
#   `resolve_inquiry()` 會回 `{"locations": []}` 這種【有 key 但陣列是空的】形狀
#   ⇒ `is_empty()` 為 false ⇒ 第三句永遠搶在第二句前面（實測 P4 紅）。
#   ★★所以要看【裡面有沒有東西】，不是【有沒有 key】。
func _inquiry_payload_empty(p: Dictionary) -> bool:
	for k in p:
		var v = p[k]
		if v is Array:
			if not (v as Array).is_empty(): return false
		elif v != null:
			return false
	return true

func _action_clear_member_order(state: WorldState, _target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	# player_state 需設定：order_member_id（目標 team）
	var member_id: int = int(state.player_state.get("order_member_id", -1))
	var mt: TeamData = state.teams.get(member_id)
	if mt == null or not TeamData.same_faction(mt, pt):   # S1
		return { "ok": false, "msg": "目標不是同勢力成員" }
	mt.player_commanded_task = ""
	print("[PlayerCmd] clear_member_order Team%d" % member_id)
	return { "ok": true, "msg": "已清除 Team%d 的直接指令" % member_id }

# ── 投靠收留（食物軌整團併入）──────────────────────────────

# 投靠收留：扣 onboarding 食物（MEAL×對方人數，被吃掉=合法消耗）+ 整團併入（reuse merge_teams,守恆）
func _accept_join_request(state: WorldState, from_id: int) -> Dictionary:
	var pt: TeamData = _get_player_team(state)
	var from_team: TeamData = state.teams.get(from_id)
	if pt == null or from_team == null:
		return { "ok": false, "msg": "對象不存在" }
	if pt.tile_pos != from_team.tile_pos:
		return { "ok": false, "msg": "需同格才能收留" }
	# 預估可進人數（受 pop_cap 限,與 merge 部分合併同口徑）
	var leader = state.persons.get(pt.leader_id)
	var cmd: float = float(leader.skills.get("統領", 0.0)) if leader else 0.0
	var capacity: int = FactionAISystem.effective_pop_cap(state, pt) - pt.population
	var will_join: int = mini(from_team.population, maxi(capacity, 0))
	if will_join <= 0:
		return { "ok": false, "msg": "隊伍已滿，無法收留" }
	var cost: float = JOIN_ONBOARD_MEAL * float(will_join)
	if float(pt.resources.get("food", 0)) < cost:
		return { "ok": false, "msg": "食物不足收留（需%.1f）" % cost }
	# 量測實際併入（撞 cap 沒進來的不餵、不報）→ 食物按 delta 扣,守恆與 msg 與實際一致
	var pop_before: int = pt.population
	SubteamSystem.new().merge_teams(state, pt.team_id, from_id)         # 整團併入：pop/named/tier/treasury 守恆
	var joined: int = pt.population - pop_before
	var actual_cost: float = JOIN_ONBOARD_MEAL * float(joined)
	ResourceBank.add(pt, "food", -actual_cost, "join_onboard_meal")   # 餵他們進來：吃掉,食物非守恆
	return { "ok": true, "msg": "收留 %d 人（食物 -%.1f）" % [joined, actual_cost],
		"payload": {"joined": joined, "food_cost": actual_cost} }

# ── 被動回應（NPC 強制非戰互動）────────────────────────────

# 查詢 forced_event 的回應選項
# "diplomacy" → ["accept", "refuse"]
# "extort"    → ["pay", "refuse"]
func get_forced_response_options(state: WorldState) -> Array[String]:
	var fe: Dictionary = state.player_forced_event
	var action: String = fe.get("action", "")
	match action:
		"diplomacy":
			# 動態：雙方獨立 + alliance/surrender → 加入/自立；否則 accept/refuse
			var from_team: TeamData = state.teams.get(fe.get("from_id", -1))
			var pp: PersonData = state.persons.get(state.player_id)
			var player_team: TeamData = state.teams.get(pp.team_id) if pp != null else null
			var both_independent: bool = from_team != null and player_team != null \
				and from_team.faction_id == -1 and player_team.faction_id == -1 \
				and fe.get("proposal", "") in ["alliance", "surrender"]
			if both_independent:
				return ["accept_join", "accept_lead", "refuse"] as Array[String]
			return ["accept", "refuse"] as Array[String]
		"extort":
			return ["pay", "refuse"] as Array[String]
		"join_request":
			return ["accept", "refuse"] as Array[String]
		"aid_request":
			return ["give", "refuse"] as Array[String]
		"choose_heir":
			# N-2: 重查活候選——只回「仍存在且仍在該隊 named_members」的 pid（消 raise→select 窗內死亡 stale）。
			# team 由 fe.team_id 取(權威)：choose_heir 時玩家 person 已死,_get_player_team 可能 null。
			var ids: Array[String] = []
			var pt: TeamData = state.teams.get(int(fe.get("team_id", -1)))
			for pid in fe.get("candidates", []):
				var ip: int = int(pid)
				if state.persons.has(ip) and pt != null and pt.named_members.has(ip):
					ids.append("heir_%d" % ip)
			return ids
	return [] as Array[String]

# 回應強制互動，清除 forced_event
# 返回 { "ok": bool, "msg": String }
func respond_to_forced(state: WorldState, response: String) -> Dictionary:
	var fe: Dictionary = state.player_forced_event
	if fe.is_empty():
		# ★同 ②′：空事件 ⇒ 靜默（headless 直呼這一支的人拿到同一個語意）
		return { "ok": false, "msg": "", "silent": true,
			"code": "forced_response_already_settled" }
	# ★★★選項人話要在【handler 動世界之前】算：`_accept_join_request` 會把人搬過來,
	#   而 join 的 label 是「收留（食物 -X,+N 人）」＝讀 **對方隊的人口** ⇒ 事後算得到 +0 人。
	#   ★實測血證（本輪卷面）：「收留（食物 -0.0,+0 人）」而真實結果是「收留 3 人」。
	var _label_pre: String = PlayerApiMapper.forced_label(String(fe.get("action", "")),
		response, state, fe)
	var result: Dictionary
	match fe.get("action", ""):
		"diplomacy":
			match response:
				"accept", "accept_join":
					result = _accept_diplomacy(state,
						fe.get("from_id", -1), fe.get("proposal", "alliance"))
				"accept_lead":
					result = _accept_diplomacy_as_leader(state, fe.get("from_id", -1))
				"refuse":
					# ★★★★★【拒絕也要收尾】（spec §3③）—— 用戶那句「**接受或拒絕都一樣重提**」
					#   就是這一行缺了收尾的症狀：拒絕只回一句話，而**任務還在**。
					#   ★而這一支是**所有 diplomacy 提案共用**的通用分支
					#     ⇒ 守衛（只對 `tribute_offer` 收尾）在 `settle_tribute_offer` **裡面**
					#     ⇒ ★★這裡不寫 `if`：三個呼叫端各寫一份 `if` 會漂，而漂掉的那一份是靜默的。
					#   ★★★而 R² 提過「多半無害」那個說法 —— **我們沒有用它**：
					#     守衛是真的加了（在那一支裡），而**一個沒有被逐情境驗過的 no-op，
					#     它的理由就是編的**。
					var _settled: bool = DiplomaticAiSystem.settle_tribute_offer(
						state, state.teams.get(int(fe.get("from_id", -1))),
						_get_player_team_id(state))
					result = { "ok": true, "msg": "婉拒 Team%d 的提案" % int(fe.get("from_id", -1)) \
						if _settled else "拒絕外交提案" }
				_:
					result = { "ok": false, "msg": "未知回應: %s" % response }
		"extort":
			if response == "pay":
				result = _pay_extortion(state, fe.get("from_id", -1))
			else:
				result = { "ok": true, "msg": "拒絕勒索" }
		"join_request":
			if response == "accept":
				result = _accept_join_request(state, fe.get("from_id", -1))
			else:
				result = { "ok": true, "msg": "婉拒收留" }
		"aid_request":
			if response == "give":
				state.player_state["aid_response"] = { "give_amount": AID_GIVE_DEFAULT }
			else:
				state.player_state["aid_response"] = { "refuse": true }
			result = _action_respond_aid_request(state, -1, _get_player_team(state), _get_player_team_id(state))
		"choose_heir":
			# N-2: 重查活候選——消 raise→select 窗內死亡 stale，避免永久 leaderless。
			var live: Array[String] = get_forced_response_options(state)
			if live.is_empty():
				# 全候選已死 → 終局（mirror leader-death 無繼承）；fall through 清 forced。
				# team 由 fe.team_id 取(權威),勿靠可能已失效的 _get_player_team。
				var dead_team: TeamData = state.teams.get(int(fe.get("team_id", -1)))
				if dead_team != null:
					EventSystem.new().handle_player_succession(state, dead_team)
				elif state.player_id != -1:
					state.game_over = true
					state.game_over_reason = "玩家絕後（隊已滅,無繼承人）"
				# ★無玩家（player_id==-1）→ 不設 game_over（觀察者世界永不凍結；同 event_system 守衛）
				result = { "ok": true, "msg": "無人可繼承,終局" }
			elif not live.has(response):
				# 單一 stale（選了已死候選）→ 不清 forced,讓玩家重選
				return { "ok": false, "msg": "繼承人已不可用,請重選" }
			else:
				var hid: int = int(response.trim_prefix("heir_"))
				state.player_state["heir_id"] = hid
				result = _action_choose_heir(state, -1, _get_player_team(state), _get_player_team_id(state))
		_:
			result = { "ok": false, "msg": "未知強制事件類型" }
	# ★★★生命週期第二點（spec 2026-09-29 #7③）：回應結果進玩家事件流＋終端。
	#   ★位置刻意在【清除之前】—— `fe` 還活著,否則 from_id／proposal 全部是預設值。
	#   ★★結果那一段用 `result.msg`（handler 自己回的話）＝零第二份真相。
	var _ptid_fe: int = state.get_player_team_id()
	if _ptid_fe != -1:
		var _fe_action: String = String(fe.get("action", ""))
		var _info_fe: Dictionary = {
			"from_id": int(fe.get("from_id", -1)),
			"action": _fe_action,
			"proposal": String(fe.get("proposal", "")),
			"response": response,
			"response_label": _label_pre,
			"ok": bool(result.get("ok", false)),
			"msg": String(result.get("msg", "")),
		}
		WorldEvents.emit(state, "forced_event_resolved", [_ptid_fe], false, _info_fe)
		print("[PlayerCmd] forced_event 回應: %s" % WorldEvents.describe(state,
			"forced_event_resolved", [_ptid_fe], _info_fe))
	state.player_forced_event = {}
	state.player_forced_event_id = ""
	# ★★★決定 vs 結果要【分開講】（spec 2026-09-30 §2①，藍圖那一族的第二個實例）：
	#   handler 失敗時回的是【世界的結果】（例：「隊伍已滿，無法收留」），
	#   而玩家按的是【接受】⇒ 兩件事都真，但混成一句話之後玩家讀成「我按的沒生效」。
	#   ⇒ 這裡把它拆成兩半：我的決定（`_label_pre`＝選項自己的 label，零第二份真相）
	#     ＋ 世界的結果（handler 的 msg）。
	#   ★★而「沒有生效」這一句要留著：它回答玩家真正在問的那個問題。
	#   ★★★不做的事：不動 handler 的 msg（那是世界的話）、不新增一張中文表
	#     —— `_label_pre` 已經是那個唯一來源（`PlayerApiMapper.forced_label`）。
	if not bool(result.get("ok", false)) and not bool(result.get("silent", false)):
		var _why: String = String(result.get("msg", ""))
		if _why != "" and _label_pre != "":
			result["msg"] = "你選了「%s」，但%s ⇒ 沒有生效" % [_label_pre, _why]
	return result

func resolve_forced_response(state: WorldState, interaction_id: String, response_id: String) -> Dictionary:
	# ★★★②′（spec §7，2026-09-30）：對一個【已經不存在】的強制事件回應 ⇒ **靜默 no-op**。
	#   ★為什麼需要這條而不是「天然 no-op 就夠了」：#8 的咽喉只設 `_ticks_remaining=1`，
	#     真正的 tick 在【下一幀】的 `_process` 才跑 ⇒ 按第一次之後、下一幀之前，
	#     `_cached_snapshot` 還顯示面板 ⇒ 第二次按會【再入列一道】
	#     ⇒ 兩道同一顆 tick 被消費：第一道成功、第二道撞到空事件。
	#   ★★而它【不違反「拒絕禁靜默」】：那條守的是「玩家分不出被拒絕與沒吃到鍵」，
	#     而這裡玩家【已經看到第一次的結果句了】—— 第二句是同一件事的第二次回音
	#     （同 P15 那條「同一條指令的回音 ≤ 2 次」）。★★★用戶逐字：
	#     「我按 T 跳出表單後 還是寫我拒絕事件」—— 那一句就是這條要消掉的東西。
	#   ★code 仍然具名（不是 missing）⇒ `command_log` 留得住審計軌跡，只是不印給玩家。
	if state.player_forced_event.is_empty():
		return {"ok": false, "code": "forced_response_already_settled",
			"msg": "", "silent": true}
	# ★而【id 不符】那一支刻意**不靜默**：那是對【另一個】事件的回應，玩家該知道。
	if interaction_id != "" and interaction_id != state.player_forced_event_id:
		return {"ok": false, "code": "forced_response_missing", "msg": "interaction expired or wrong id"}
	var valid: Array[String] = get_forced_response_options(state)
	if not valid.has(response_id):
		return {"ok": false, "code": "forced_response_invalid", "msg": "invalid response_id: %s" % response_id}
	return respond_to_forced(state, response_id)

# ── 清除 pending ─────────────────────────────────────────────

# 玩家 team 格子改變時呼叫（SimRunner 負責呼叫）
# player_forced_event 不清除（NPC 外交/勒索不因移動取消）
func clear_pending_targets(state: WorldState) -> void:
	state.player_pending_targets.clear()
	state.player_state.erase("pending_trade_target")

# 玩家主動按下互動鍵（T）時呼叫：掃描同格 NPC，加入 pending_targets
# 讓 ignore 後仍可再次主動觸發互動
func refresh_colocation_targets(state: WorldState) -> void:
	var pt: TeamData = _get_player_team(state)
	if pt == null:
		return
	for other_id in state.teams:
		if other_id == pt.team_id:
			continue
		# ★寫入端①（群乙）：待刪除的隊不得進玩家的互動對象清單
		if not state.can_be_player_target(other_id):
			continue
		var other: TeamData = state.teams[other_id]
		if other.tile_pos != pt.tile_pos:
			continue
		if other.combat_target != -1:
			continue
		if not state.player_pending_targets.has(other_id):
			state.player_pending_targets.append(other_id)

func _action_respond_aid_request(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	var fe: Dictionary = state.player_forced_event
	if fe.is_empty() or fe.get("action", "") != "aid_request":
		return { "ok": false, "msg": "沒有待回應的乞食" }
	var beggar_id: int = int(fe.get("from_id", -1))
	var beggar: TeamData = state.teams.get(beggar_id)
	if beggar == null:
		state.player_forced_event = {}
		state.player_forced_event_id = ""
		return { "ok": false, "msg": "beggar 不存在" }
	var b_leader: PersonData = state.persons.get(beggar.leader_id)
	var response: Dictionary = state.player_state.get("aid_response", {})
	var msg_sys := SimMessageSystem.new()
	var npc_ai  := NpcAiSystem.new()
	if response.get("refuse", false):
		msg_sys.emit_message(state, "aid_refused",
			"玩家拒絕援助 Team%d" % beggar_id, pt,
			{ "origin": str(pt_id), "target": str(beggar_id) })
		beggar.update_reputation(pt_id, -0.1)
		if b_leader: npc_ai.write_memory(b_leader, "rejected_aid", pt_id,
			state.world.current_tick, 0.5)
		# ★同一個語意事件（乞食被拒），只是拒的人是玩家 —— 三個寫入點都要記，否則
		#   「被誰拒絕」會決定「有沒有學到」。
		FailureMemory.record(state, beggar, "乞食", str(pt_id),
			FailureMemory.AID_REFUSED_TTL_TICKS, "aid_refused_player")
	else:
		var amt: float = float(response.get("give_amount", 0.0))
		var actual: float = minf(amt, float(pt.resources.get("food", 0)))
		if actual <= 0.0:
			msg_sys.emit_message(state, "aid_refused",
				"玩家無餘糧援助 Team%d" % beggar_id, pt,
				{ "origin": str(pt_id), "target": str(beggar_id) })
		else:
			ResourceBank.add(pt, "food", -actual, "player_aid_out")
			ResourceBank.add(beggar, "food", actual, "player_aid_in")
			msg_sys.emit_message(state, "aid_given",
				"玩家援助 Team%d %.0f 食物" % [beggar_id, actual], pt,
				{ "origin": str(pt_id), "target": str(beggar_id),
				  "amount": "%.0f" % actual })
			beggar.update_reputation(pt_id, 0.15)
			if b_leader: npc_ai.write_memory(b_leader, "benefactor", pt_id,
				state.world.current_tick, clampf(actual / 50.0, 0.1, 1.0))
	state.clear_social_target(beggar)   # BEG 現走 social_target（非 combat_target）
	if beggar.previous_task != "" and beggar.previous_task != TeamData.TASK_IDLE:
		# release-first + move_target 存/還（同 interaction _clear_aid_task；release 清 -1，resume 需原目的地）。
		var saved: Vector2i = beggar.move_target
		TaskArbiter.release(beggar)
		TaskArbiter.try_set(state, beggar, beggar.previous_task, saved, TaskArbiter.PRIO_DISPATCH, "beggar_restore")
	else:
		TaskArbiter.release(beggar)
	beggar.previous_task = ""
	state.player_forced_event = {}
	state.player_forced_event_id = ""
	state.player_state.erase("aid_response")
	return { "ok": true, "msg": "已處理" }

func _action_choose_heir(state: WorldState, _target: int, _pt: TeamData, _pt_id: int) -> Dictionary:
	var fe: Dictionary = state.player_forced_event
	if fe.get("action", "") != "choose_heir":
		return { "ok": false, "msg": "無待選繼承人事件" }
	var heir_id: int = int(state.player_state.get("heir_id", -1))
	if heir_id == -1:
		return { "ok": false, "msg": "未選繼承人" }
	if not fe.get("candidates", []).has(heir_id):
		return { "ok": false, "msg": "非合法候選" }
	var team_id: int = int(fe.get("team_id", -1))
	var team: TeamData = state.teams.get(team_id)
	var heir: PersonData = state.persons.get(heir_id)
	if team == null or heir == null:
		return { "ok": false, "msg": "team/person 失效" }
	# ★★★改走 chokepoint（spec 2026-09-30）：這三行原本是【手寫一份 set_leader】，
	#   而它漏掉最關鍵的那一件 —— `p.team_id = team.team_id`（強制回指本隊）。
	#   ⇒ 當繼承人原本的 team_id 與 fe["team_id"] 不同時，那個人就變成
	#     「team_id 指向 48 而 48 的 roster 裡沒有他」＝ InvariantAudit 的 P127。
	#   ★抓到它的是死輸入探索床（L3:choose_heir 那一步），不是任何人讀這三行。
	#   ★★`old_leader_action` 給預設的 "none"：這條路的舊 leader 是【已死的玩家】
	#     ⇒ chokepoint 檔頭逐字寫「已死/已他處理 ⇒ none」。
	state.set_leader(team, heir_id)
	state.player_id = heir_id
	state.player_forced_event = {}
	state.player_forced_event_id = ""
	state.player_state.erase("heir_id")
	print("[Heir] %s 繼任玩家 (Team%d)" % [heir.person_name, team_id])
	return { "ok": true, "msg": "%s 繼任" % heir.person_name }

func _action_invite_settle(state: WorldState, target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	var tgt: TeamData = state.teams.get(target_id)
	if tgt == null: return { "ok": false, "msg": "目標不存在" }
	var pos_arr: Array = state.player_state.get("settle_pos", [-1, -1])
	var target_pos: Vector2i = Vector2i(int(pos_arr[0]), int(pos_arr[1]))
	if target_pos == Vector2i(-1, -1):
		target_pos = pt.tile_pos   # 互動選單路徑未設 settle_pos → 預設玩家腳下 outpost（emit gate 已保證站在自家 outpost）
	var tile: HexTileData = state.world.tiles.get(target_pos.x * 1000 + target_pos.y)
	if tile == null or tile.outpost_level == 0 or tile.outpost_owner != pt_id:
		return { "ok": false, "msg": "那一格不是你自己的據點" }
	# 評估接受
	var resp: String = _diplomatic.handle_diplomacy_message(state, tgt, pt, "invite_settle")
	if resp == "accept":
		_interaction._execute_settlement(state, target_id, target_pos, pt.faction_id)
		return { "ok": true, "msg": "Team%d 接受邀請" % target_id }
	return { "ok": true, "msg": "Team%d 拒絕邀請" % target_id, "accepted": false }

func _action_beg(state: WorldState, target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	var tgt: TeamData = state.teams.get(target_id)
	if tgt == null: return { "ok": false, "msg": "目標不存在" }
	if pt.tile_pos != tgt.tile_pos: return { "ok": false, "msg": "需同格才能乞討" }
	# 玩家當乞丐:reuse _resolve_aid_request（NPC 依 honor/rep/greed 自決;給糧守恆轉移;重複乞討 annoyance 自限）
	var r: Dictionary = _interaction._resolve_aid_request(state, pt_id, target_id)
	if r.get("accepted", false):
		return { "ok": true, "msg": "Team%d 施捨食物 %.0f" % [target_id, float(r.get("amount", 0))] }
	return { "ok": true, "msg": "Team%d 不予施捨（%s）" % [target_id, r.get("msg", "拒絕")], "accepted": false }

# ── 內部 helper ──────────────────────────────────────────────

func _get_player_team(state: WorldState) -> TeamData:
	var p: PersonData = state.persons.get(state.player_id)
	if p == null:
		return null
	return state.teams.get(p.team_id)

func _get_player_team_id(state: WorldState) -> int:
	return state.get_player_team_id()

func _can_trade(state: WorldState, pt: TeamData, tgt: TeamData) -> bool:
	# 雙方任一有 coin 即可嘗試貿易（細節由直接成交那一路的結算（★已於 2026-10-01 退場） 判定）
	return float(pt.resources.get("coin", 0)) > 0.0 \
		or float(tgt.resources.get("coin", 0)) > 0.0

func _accept_diplomacy(state: WorldState, from_id: int, proposal: String) -> Dictionary:
	var from_team: TeamData = state.teams.get(from_id)
	var pt: TeamData = _get_player_team(state)
	if from_team == null or pt == null:
		return { "ok": false, "msg": "隊伍不存在" }
	match proposal:
		# ★★★`propose_alliance` 是 `diplomatic_ai_system.gd:146` 真的會寫的那個字串，
		#   而它的語意與 `"alliance"` 完全相同 ⇒ 同一支 arm。
		#   ★★這是【同一個病灶的第二次】：下面那支 arm 的註解記著第一次
		#     （`demand_tribute` 原只認 `tribute`）⇒ 只加第三個字串等於等第三次
		#     ⇒ 所以本票同時加一格【異源比對】（寄件端字串集合 A ＼ handler 認得的 B ＝ 指名豁免）
		#     ⇒ 下一個人加新提案而忘了 handler，那一格會紅。
		"alliance", "surrender", "propose_alliance":
			# 雙方皆獨立時 _form_alliance 無效，需先建立勢力
			if from_team.faction_id == -1 and pt.faction_id == -1:
				state.create_faction(from_id)   # NPC 為領袖
			_diplomatic._form_alliance(state, from_team, pt)
			return { "ok": true, "msg": "接受同盟，加入勢力%d" % from_team.faction_id }
		"tribute", "demand_tribute":   # _send_diplomacy_message 寫 "demand_tribute"（原只認 "tribute" → 未知提案類型 bug）
			return _pay_extortion(state, from_id)
		# ★★★`propose_trade`：**走 NPC↔NPC 那一段【同一份 code】**（藍圖裁 (b)，spec 2026-09-30）。
		#   ★為什麼不呼 `handle_diplomacy_message`：那一支會重跑 `score > 0.4`
		#     ⇒ 而玩家的決定是【玩家按的】⇒ 重跑那把秤＝把玩家的決定交還給 AI。
		#   ★★為什麼不在這裡複製那兩行：一個真相只存一份，複製的那份會漂
		#     ⇒ 係數（0.05）留在 `DiplomaticAiSystem` 裡，**本檔不得出現它的字面**，
		#       也不得出現 `update_reputation(`（床 P2(b) 用 grep 斷言這兩件）。
		#   ★★★而它【只寫 team 名聲，一個字都不多】：裁定寫「名聲／好感」而
		#     NPC 那一支 code 只做 `known_reputations`（team 名聲）⇒ 玩家多拿一個
		#     person 好感就是【NPC 得不到的效果】＝特例，違反這條裁定自己的原則。
		"propose_trade":
			DiplomaticAiSystem.apply_trade_accept(pt, from_team)
			return { "ok": true, "msg": "與 Team%d 談成通商（名聲互有加分）" % from_id }
		# ══ ★★★★★★【接受 ＝ 收貢】（spec §3①，2026-10-01）═══════════════════════
		#   ★用戶實測：按接受 ⇒ 畫面印「**未知提案類型：tribute_offer**」⇒ 兩小時後再問一次。
		#   ★★而金額**不新算也不抄常數** —— 呼 `apply_tribute_transfer`，
		#     它吃 **payer 自己的 coin**（`coin_before * TRIBUTE_TAKE_RATIO`）
		#     ⇒ ★「金額用 NPC 側自己算的那一份」本來就成立，而**本檔不得出現那個常數的字面**
		#       （同本檔既有那條紀律）。
		#   ★★★方向：`payer` ＝ **來進貢的那一隊**（`from_team`）、`taker` ＝ **玩家隊**
		#     —— 反過來就是用戶看到的那個更糟的版本（倒付錢）。
		#   ★★★★而它呼的是 `apply_tribute_transfer` **不是** `apply_tribute_accept`：
		#     後者會連帶寫 `"tributed"` 記憶，而那筆記憶走**結仇邊**
		#     ⇒ 「NPC 主動送我東西，然後它對我結仇」＝方向是反的（藍圖裁 (甲) 不寫關係）。
		"tribute_offer":
			var amount: float = DiplomaticAiSystem.apply_tribute_transfer(state, from_team, pt)
			# ★收尾（三件）—— 不然任務還在，兩小時後它再提一次
			DiplomaticAiSystem.settle_tribute_offer(state, from_team, _get_player_team_id(state))
			if amount <= 0.0:
				# ★對方其實沒有錢 ⇒ **說出來**，不要回一句「收下了」然後什麼都沒進帳
				#   （「收到 0」與「沒收到」在玩家那裡是兩句不同的話）
				return { "ok": true,
					"msg": "Team%d 要進貢，但它身上沒有錢可以給" % from_id }
			return { "ok": true,
				"msg": "收下 Team%d 的貢品（+%.0f 錢）" % [from_id, amount] }
	# ★★★注意這裡【以前沒有】`tribute_offer`，而那**曾經**是刻意的（原文留在下面）：
	#   它的語意是【對方要給你進貢】（`TeamData.TASK_TRIBUTE_OFFER`，由 `interaction_system`
	#   經 `npc.order_task` 寫進 proposal）⇒ 若把它併進上面那支 `"tribute"` arm，
	#   會走 `_pay_extortion` ⇒ ★**變成玩家付錢給來進貢的人**。
	#   ⇒ ★★「把所有字串都加進 match」是一個【看起來像修好】的錯，而它比現在的 bug 更糟：
	#     現在是收不到貢品，改壞之後是倒付錢。
	# ══ ★★★★★★【而那個裁定只做對了一半 —— 2026-10-01 補完】═════════════════════
	#   ★它擋住了**錯的改法**（併進 `"tribute"` arm ⇒ 倒付），而**沒有開「正確的那一半」的票**
	#   ⇒ 留給玩家的是：**永遠收不到貢品 ＋ 畫面印一句內部錯誤 ＋ 每兩小時再問一次**。
	#   ⇒ ★★判準（寫給下一個人）：**裁「不做 X」的同時要開「正確的那一半」的票** ——
	#     否則一個**刻意的空缺**會長成玩家面的缺陷，而它的卷面長相是
	#     「**這裡有一段很有道理的註解**」。
	#   ⇒ ★★★正確的那一半就在上面那支 `"tribute_offer"` arm（它呼轉帳那一半，不呼 `_pay_extortion`）
	#     ⇒ 而守「不倒付」的那一格**照舊有效**（它斷言按接受之後玩家 coin 不得減少）。
	#   ⇒ ★★★守它的是 `forced_event_panel_bed` 那一格（按接受之後玩家 coin 不得減少），
	#     負對照就是「故意併進去 ⇒ coin 減少 ⇒ 紅」（systems 裁 2026-09-30）。
	return { "ok": false, "msg": "未知提案類型：%s" % proposal }

func _accept_diplomacy_as_leader(state: WorldState, from_id: int) -> Dictionary:
	var from_team: TeamData = state.teams.get(from_id)
	var pt: TeamData = _get_player_team(state)
	var pt_id: int   = _get_player_team_id(state)
	if from_team == null or pt == null:
		return { "ok": false, "msg": "隊伍不存在" }
	if pt.faction_id == -1:
		state.create_faction(pt_id)
	_diplomatic._form_alliance(state, pt, from_team)
	return { "ok": true, "msg": "自立後接納 Team%d，勢力%d" % [from_id, pt.faction_id] }

func _pay_extortion(state: WorldState, from_id: int) -> Dictionary:
	# 轉移資源給 from_id（金額由 _resolve_extortion 計算）
	var pt_id: int = _get_player_team_id(state)
	if pt_id == -1:
		return { "ok": false, "msg": "找不到玩家 team" }
	_interaction.resolve_extortion_direct(state, from_id, pt_id)
	return { "ok": true, "msg": "支付勒索" }

func _recruit_anon_internal(state: WorldState, pt: TeamData,
		tgt: TeamData, target_id: int) -> Dictionary:
	var pt_id: int  = _get_player_team_id(state)
	var coin: float = float(pt.resources.get("coin", 0))
	if coin < RECRUIT_COST_ANON:
		state.player_pending_targets.erase(target_id)
		return { "ok": false, "msg": "金幣不足（需%d）" % int(RECRUIT_COST_ANON) }
	# ★★★不變量：**收費與交付必須成對**（systems 裁 2026-09-25）。
	#   ★原本這裡問 `tgt.population <= 1` —— 又是那個代理量 ⇒ 全具名的目標過得去，
	#     然後扣錢、搬 0 人、印「招募成功」。
	#   ★★改問【真的有沒有匿名】，而且【先搬再收費】：
	#     ⇒ 搬 0 人就不會走到收費那一行 —— 那比「收了再退」強，因為它不需要退款路徑。
	#   ★★★而 `share` 必須用【搬之前】的人數算 ⇒ 它排在 transfer 之前。
	var avail_anon: int = AnonTierSystem.total_pop(tgt)
	if avail_anon <= 0:
		state.player_pending_targets.erase(target_id)
		return { "ok": false, "msg": "對方沒有可招募的無名之人（全是具名成員）" }
	# 被招募 anon 帶走在原團的 treasury 份額（★用搬之前的人數算）
	var tgt_named: int = tgt.named_members.size() + (1 if tgt.leader_id != -1 else 0)
	var tgt_anon: int = maxi(tgt.population - tgt_named, 1)
	var share: float = minf(tgt.anon_treasury / float(tgt_anon), tgt.anon_treasury)
	# ★先搬，看真的搬了幾個 —— ★★`transfer_proportional` 回的是【逐 tier 的搬運量】，
	#   而原本【沒有人看那個回傳值】（那是這個缺陷的第二層）。
	var moved: Dictionary = AnonTierSystem.transfer_proportional(tgt, pt, 1)
	var moved_n: int = 0
	for _t in moved:
		moved_n += int(moved[_t])
	if moved_n <= 0:
		# ★★★拒絕禁靜默：說得出原因，而且【一毛都不收】
		state.player_pending_targets.erase(target_id)
		return { "ok": false, "msg": "招募失敗：一個人都沒搬過來（未收費）" }
	ResourceBank.set_amt(pt, "coin", coin - RECRUIT_COST_ANON, "recruit_anon_pay")
	# 守恆：買人付給對方，coin 不蒸發
	ResourceBank.add(tgt, "coin", RECRUIT_COST_ANON, "recruit_anon_receive")
	AnonTreasuryBank.transfer(tgt, pt, share, "recruit_share")
	state.player_pending_targets.erase(target_id)
	# ★事件流（spec #4）：★人數用 `moved_n` ＝【真的搬過來的】那個數
	#   —— 不是 `share`（那是搬之前算的期望值）。招募那張票的教訓：報告的字要與事實相符。
	WorldEvents.emit(state, "member_joined", [pt_id], false, {"n": moved_n})
	print("[Recruit] 匿名 Team%d←%d, 招到 %d 人, 花%.0f coin, 新人口=%d" % [
		pt_id, target_id, moved_n, RECRUIT_COST_ANON, pt.population])
	# ★把 moved 印出來 —— ★★玩家從此分辨得出「招到 0 人」與「沒招成」，
	#   而今天這兩者在畫面上是【同一句話】。
	return { "ok": true, "msg": "招到 %d 人（花費%d coin，新人口%d）" % [
		moved_n, int(RECRUIT_COST_ANON), pt.population],
		"payload": {"has_willing_named": false, "refresh_required": true, "moved": moved_n} }

# ── 查詢 API（Phase 1 新增） ─────────────────────────

func get_player_team(state: WorldState) -> TeamData:
	var p: PersonData = state.persons.get(state.player_id)
	if p == null: return null
	return state.teams.get(p.team_id)

func get_player_person(state: WorldState) -> PersonData:
	return state.persons.get(state.player_id)

func inspect_team(state: WorldState, team_id: int) -> Dictionary:
	var t: TeamData = state.teams.get(team_id)
	if t == null: return {}
	var leader: PersonData = state.persons.get(t.leader_id)
	var members: Array = []
	for pid in t.named_members:
		var p: PersonData = state.persons.get(pid)
		if p:
			members.append({
				"id": p.id, "name": p.person_name, "role": p.role,
				"loyalty": p.loyalty, "fatigue": p.stress
			})
	var leader_info: Dictionary = {}
	if leader:
		leader_info = { "id": leader.id, "name": leader.person_name }
	return {
		"team_id": t.team_id, "tile_pos": t.tile_pos, "population": t.population,
		"fatigue": t.fatigue, "current_task": t.current_task,
		"faction_id": t.faction_id, "tags": t.tags,
		"leader": leader_info, "named_members": members,
		"resources": t.resources
	}

func inspect_member(state: WorldState, person_id: int) -> Dictionary:
	var p: PersonData = state.persons.get(person_id)
	if p == null: return {}
	return {
		"id": p.id, "name": p.person_name, "role": p.role,
		"team_id": p.team_id, "age": p.age,
		"loyalty": p.loyalty, "stress": p.stress, "fear": p.fear,
		"values": p.values, "attributes": p.attributes, "skills": p.skills,
		"equipment": p.equipment
	}

func move_to(state: WorldState, target_pos: Vector2i) -> Dictionary:
	var pt: TeamData = get_player_team(state)
	if pt == null:
		return { "ok": false, "msg": "玩家 team 不存在" }
	var key: int = target_pos.x * 1000 + target_pos.y
	if not state.world.tiles.has(key):
		return { "ok": false, "msg": "目標格不在地圖內" }
	if pt.tile_pos == target_pos:
		return { "ok": true, "msg": "已在目標格" }
	pt.move_target = target_pos
	return { "ok": true, "msg": "設定目標 (%d,%d)" % [target_pos.x, target_pos.y] }

func cancel_move(state: WorldState) -> Dictionary:
	var pt: TeamData = get_player_team(state)
	if pt == null:
		return { "ok": false, "msg": "玩家 team 不存在" }
	pt.move_target = Vector2i(-1, -1)
	state.player_state.erase("pending_trade_target")
	return { "ok": true, "msg": "取消移動" }

func establish_faction(state: WorldState) -> Dictionary:
	var pt: TeamData = _get_player_team(state)
	var pt_id: int   = _get_player_team_id(state)
	if pt == null:
		return { "ok": false, "code": "no_controlled_team",
				 "message": "找不到玩家隊伍", "payload": {} }
	# ★前置檢查只有一份（spec §3②）：條件與人話在 `precheck_establish_faction()` 裡。
	#   ★★本支的回傳是 `{ok, code, message, payload}` 形狀（不是 `msg`）⇒ `code` 留在這裡，
	#     而 `message` 讀共用那支回的 `reason` ⇒ 一句話一份。
	var pre_ef: Dictionary = precheck_establish_faction(state, pt)
	if not bool(pre_ef.get("ok", false)):
		return { "ok": false, "code": "action_unavailable",
				 "message": String(pre_ef.get("reason", "")), "payload": {} }
	state.create_faction(pt_id)
	print("[PlayerCmd] 玩家建立勢力%d" % pt.faction_id)
	return { "ok": true, "code": "ok",
			 "message": "建立勢力%d" % pt.faction_id,
			 "payload": {"action_id": "establish_faction", "refresh_required": true} }

# execute_action variant that passes full target dict (for "member" kind actions)
func execute_action_with_target(state: WorldState, action: String, target: Dictionary) -> Dictionary:
	var pt: TeamData = _get_player_team(state)
	var pt_id: int   = _get_player_team_id(state)
	if pt == null:
		return { "ok": false, "msg": "找不到玩家 team" }
	match action:
		"recruit_named":
			var from_team_id: int = target.get("team_id", -1)
			var person_id: int    = target.get("member_id", -1)
			return _recruit_named_internal(state, pt, from_team_id, person_id)
		"set_member_salary":
			return _action_set_member_salary(state, target, pt)
		"equip_member":
			return _action_equip_member(state, target, pt)
		"unequip_member":
			return _action_unequip_member(state, target, pt)
	return { "ok": false, "msg": "不支援 member 目標的行動: %s" % action }

# S9：玩家調自隊名成員薪資。amount 經 player_state["salary_input"] 暫存。
func _action_set_member_salary(state: WorldState, target: Dictionary, pt: TeamData) -> Dictionary:
	var mid: int = int(target.get("member_id", -1))
	var m: PersonData = state.persons.get(mid)
	if m == null or not pt.named_members.has(mid):
		return { "ok": false, "msg": "非自隊成員" }
	var amt: float = float(state.player_state.get("salary_input", m.salary))
	m.salary = maxf(amt, 0.0)
	print("[PlayerCmd] set_member_salary P%d → %.0f" % [mid, m.salary])
	return { "ok": true, "msg": "%s 薪資設為 %.0f" % [m.person_name, m.salary] }

# U13b：從自隊武器池裝備名成員 slot（扣 team 資源；原槽位裝備還回池）。
func _action_equip_member(state: WorldState, target: Dictionary, pt: TeamData) -> Dictionary:
	var mid: int    = int(target.get("member_id", -1))
	var slot: String  = String(target.get("slot_id", ""))
	var grade: String = String(target.get("item_grade", ""))
	var m: PersonData = state.persons.get(mid)
	if m == null or not pt.named_members.has(mid):
		return { "ok": false, "msg": "非自隊成員" }
	if slot == "" or grade == "" or int(pt.resources.get(grade, 0)) <= 0:
		return { "ok": false, "msg": "無此裝備" }
	# 先卸原槽（pool 裝備還回池）
	var cur: Dictionary = m.equipment.get(slot, {})
	if cur.get("type", "none") == "pool" and cur.get("grade", "") != "":
		ResourceBank.add(pt, cur["grade"], 1, "equip_swap_return")
	ResourceBank.add(pt, grade, -1, "equip_swap_take")
	m.equipment[slot] = { "type": "pool", "grade": grade }
	if ItemAttributes.is_2h(grade):
		m.equipment["hand_2"] = { "type": "2h_ref" }
	print("[PlayerCmd] equip_member P%d slot=%s grade=%s" % [mid, slot, grade])
	return { "ok": true, "msg": "%s 裝備 %s" % [m.person_name, grade] }

# U13b：卸下名成員 slot 裝備，還回 team 武器池。
func _action_unequip_member(state: WorldState, target: Dictionary, pt: TeamData) -> Dictionary:
	var mid: int   = int(target.get("member_id", -1))
	var slot: String = String(target.get("slot_id", ""))
	var m: PersonData = state.persons.get(mid)
	if m == null or not pt.named_members.has(mid):
		return { "ok": false, "msg": "非自隊成員" }
	var cur: Dictionary = m.equipment.get(slot, {})
	if cur.get("type", "none") == "pool" and cur.get("grade", "") != "":
		pt.resources[cur["grade"]] = int(pt.resources.get(cur["grade"], 0)) + 1
		if ItemAttributes.is_2h(cur["grade"]):
			m.equipment["hand_2"] = { "type": "none", "grade": "" }
	m.equipment[slot] = { "type": "none", "grade": "" }
	print("[PlayerCmd] unequip_member P%d slot=%s" % [mid, slot])
	return { "ok": true, "msg": "%s 卸下 %s" % [m.person_name, slot] }

func _recruit_named_internal(state: WorldState, pt: TeamData,
		from_team_id: int, person_id: int) -> Dictionary:
	var tgt4: TeamData    = state.teams.get(from_team_id)
	var p: PersonData     = state.persons.get(person_id)
	if tgt4 == null or p == null or p.team_id != from_team_id:
		return { "ok": false, "msg": "成員不存在或已離隊" }
	# ★★★第三個管道的同格閘（R² 擋件、systems 裁 2026-09-30 納入本票）：
	#   這條路的 `from_team_id` 直接來自 target dict（任意值）⇒ 走程式介面
	#   可以【隔空向任意隊買走一個記名成員】——而它比隔空索貢更重。
	# ★位置在【第一個寫入之前】，而那不是風格：這條路有**四個寫入**
	#   （玩家付錢／對方收錢／人離原隊／人入玩家隊）
	#   ⇒ ★★半途擋下來比沒擋更糟（人離了原隊而沒入玩家隊＝憑空消失）
	#   ⇒ 所以閘必須在第一個 `ResourceBank` 呼叫之前。
	# ★而它排在【存在檢查之後、金幣檢查之前】：id 亂傳要先聽到「成員不存在」，
	#   而不同格的人不該先被告知「金幣不足」（那句會把他引去湊錢）。
	var _far_r: Dictionary = refuse_if_not_colocated(state, from_team_id, pt)
	if not _far_r.is_empty():
		return _far_r
	var coin: float = float(pt.resources.get("coin", 0))
	if coin < RECRUIT_COST_NAMED:
		return { "ok": false, "msg": "金幣不足（named 需%d）" % int(RECRUIT_COST_NAMED) }
	# 轉移
	var pt_id: int = _get_player_team_id(state)
	ResourceBank.set_amt(pt, "coin", coin - RECRUIT_COST_NAMED, "recruit_named_pay")
	# 守恆：買人付給對方，coin 不蒸發
	ResourceBank.add(tgt4, "coin", RECRUIT_COST_NAMED, "recruit_named_receive")
	state.remove_member(tgt4, person_id, false)   # 出原隊 roster（team_id 由 add 設 pt）
	LoyaltyBank.set_baseline(p, 0.5, "recruit")
	state.add_member(pt, person_id)               # 入玩家隊 + team_id=pt

	state.player_pending_targets.erase(from_team_id)
	print("[Recruit] Named P%d (%s) Team%d→%d" % [
		person_id, p.person_name, from_team_id, pt_id])
	return { "ok": true, "msg": "招募 %s 成功（花費%d coin）" % [
		p.person_name, int(RECRUIT_COST_NAMED)],
		"payload": {"refresh_required": true} }
