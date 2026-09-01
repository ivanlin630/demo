# @observe-pure
class_name MeasureBedHelper

# ★★★量測床的世界建構入口（measurer 提案 2026-09-01：★「把規則變成沒得選，而非寫在註解裡靠記得」）。
#
# ★病：`Probe.reset(); Probe.enabled = true` 必須在 `GameSetup.setup()` 【之前】，
#   否則建世界那一段的 tap 是【盲的】——而它【不會報錯】，只會少掉一段數字，
#   ★★而「少掉一段」與「那一段沒發生」在輸出上長得一模一樣。
#
# ★★修法不是寫進註解靠人記得，是把順序【寫死在一個呼叫裡】：
#   作者呼叫這支，就自動繼承正確順序，沒得選錯。
#
# ★★★而 helper 一個人不夠 —— 它只約束【呼叫它的】床。
#   增量由 `bed_arm_gate.gd` 擋（母體＝`WorldState.new()` 的呼叫點，不是 `GameSetup.setup()`：
#   建世界必須 new 一個 WorldState，而 setup 只是其中一條路 —— 那才是引擎決定的窄口）。

# cfg：`res://config/xxx.json` 路徑，或已載入的 Dictionary。
# strip_player：拆掉玩家（多數量測床要中性世界，不要玩家 forced_event 干擾）。
static func arm_and_setup(cfg, strip_player: bool = true) -> WorldState:
	# ★順序寫死：arm → setup。★★先後就是這支存在的全部理由。
	#   ★★★Probe.arm() ＝ reset + enabled + 【arm 順序判定】三合一
	#     （判定放在 arm 那一刻，不放在 setup —— production 從不 arm，所以那裡判定＝恆真噪音）。
	Probe.arm()
	var state := WorldState.new()
	var conf: Dictionary = cfg if cfg is Dictionary else GameSetup.load_config(str(cfg))
	GameSetup.setup(state, conf)
	if strip_player:
		_strip_player(state)
	return state

# ★★★手工組世界的那一條路（spec §0 點名的母體缺口）：
#   實測 274 張床建世界、只有 138 張走 GameSetup.setup()，
#   ★另外那批自己 hand-roll `_mk*` / `_build_world` —— 它們【用不到 arm_and_setup】，
#   ★★而它們一樣會踩「先建世界、後 arm」。
#   ⇒ 給它們一支對應的入口：arm 先發生，回一個空 WorldState 讓床自己填。
#   ★★★沒有這一支的話，手工床只有兩條路：不走 helper（閘紅）或進白名單（盲區 +1）——
#     兩條都不對。
static func arm_and_new() -> WorldState:
	Probe.arm()
	var state := WorldState.new()
	state.world = WorldData.new()
	return state

# 玩家拆除：★沿用既有床的做法（player_id = -1 + 清空 forced/pending 欄位）。
#   ★★不是新政策，是把散在各床的同一段收成一處 —— 散著寫的版本已經出現過漏清某欄的情況。
static func _strip_player(state: WorldState) -> void:
	if state.player_id == -1:
		return
	state.player_id = -1
	state.player_forced_event = {}
	state.player_forced_event_id = ""
	state.player_pending_targets = []
	state.player_hostile_teams = []
	state.player_pre_encounter = {}
	state.player_state = {}

# ★給床在結尾自報用：arm 順序有沒有出過問題（★它讀的是不被 reset 清掉的那一欄）。
#   ★★床應該把這個印出來 —— 否則自檢有值而沒人看得到，等於沒有自檢。
static func arm_order_report() -> String:
	if Probe.setup_saw_unarmed == 0:
		return "[ARM-ORDER] OK：setup 執行時 Probe 已 armed（0 次未 armed）"
	return "[ARM-ORDER] ★未 armed 就 setup ×%d ⇒ 那幾段世界的 tap 是盲的｜線索=%s" \
		% [Probe.setup_saw_unarmed, str(Probe.setup_unarmed_sites)]
