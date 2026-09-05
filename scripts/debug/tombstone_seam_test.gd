extends SceneTree

# ★★★墓碑縫的【直接斷言】（spec 2026-09-05-erase-merge-corpse §8③ 驗收）——
#   ★systems 先自檢過的那件事：**把墓碑機制關掉，`live_teams()` 與 `all_teams()` 回傳相同集合**
#     ⇒ ★★任何只驗「沒崩／守恆／determinism」的判準【都會綠】
#   ⇒ ★★★所以必須有一條【直接斷言】：**決策端看不到墓碑，而感知端看得到**。
#
# ★★閘型床兩要件：結尾 `[TEST-SUITE-COMPLETE]` ＋ 失敗走 `push_error`（叫、不停）。
# ★★★而【陽性對照】做在預設參數下：先驗「沒有墓碑時兩者相同」（否則下面的差異可能來自別的東西），
#   再標一支墓碑，驗差異【正好是那一支】。

var _next_id: int = 1
var _fails: int = 0

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	print("=== 墓碑縫：決策端看不到／感知端看得到 ===")
	seed(1337)
	var s := MeasureBedHelper.arm_and_new(); s.player_id = -1
	for i in range(4):
		_mk_team(s, Vector2i(i, 0))

	# ── ★①陰性前提：沒有墓碑時，兩個入口【必須相同】──
	var live0: Array = s.live_teams().duplicate(); live0.sort()
	var all0: Array = s.all_teams().duplicate(); all0.sort()
	print("  ★沒有墓碑時：live=%d ｜ all=%d" % [live0.size(), all0.size()])
	if live0 != all0:
		push_error("[FAIL] 沒有墓碑時兩個入口就已經不同 ⇒ ★下面的差異證明不了墓碑（陰性前提不成立）")
		_fails += 1
	if all0.size() != 4:
		push_error("[FAIL] all_teams() 沒回到全部 4 支（實際 %d）" % all0.size())
		_fails += 1

	# ── ★★②標一支墓碑，驗差異【正好是那一支】──
	var victim: int = int(all0[1])
	s.mark_tombstone(victim, 12345)
	var live1: Array = s.live_teams().duplicate(); live1.sort()
	var all1: Array = s.all_teams().duplicate(); all1.sort()
	print("  ★★標 team=%d 為墓碑後：live=%d ｜ all=%d" % [victim, live1.size(), all1.size()])
	if live1.has(victim):
		push_error("[FAIL] ★決策端【看得到】墓碑 team=%d —— 那正是「隊追著死人跑」的形狀" % victim)
		_fails += 1
	if not all1.has(victim):
		push_error("[FAIL] ★★感知端【看不到】墓碑 team=%d —— ★★★而那會讓【鬼城情報不可能發生】" % victim)
		_fails += 1
	if all1.size() != all0.size():
		push_error("[FAIL] 墓碑【離開了名冊】(all %d → %d) —— 而墓碑的定義是【留在名冊但不參與模擬】"
			% [all0.size(), all1.size()])
		_fails += 1
	if live1.size() != live0.size() - 1:
		push_error("[FAIL] live 少掉的不是【正好一支】(%d → %d)" % [live0.size(), live1.size()])
		_fails += 1

	# ── ★★★③快取失效：標了之後再建一支，live 要跟著長 ──
	var newbie: TeamData = _mk_team(s, Vector2i(9, 0))
	var live2: Array = s.live_teams()
	if not live2.has(newbie.team_id):
		push_error("[FAIL] ★新建的隊沒出現在 live_teams() ⇒ ★★快取沒失效（`_live_epoch` 沒 bump）")
		_fails += 1
	else:
		print("  ★★★快取失效正常：新建 team=%d 立刻出現在 live（%d 支）" % [newbie.team_id, live2.size()])

	print("")
	print("★★★總計 FAIL = %d" % _fails)
	print("[TEST-SUITE-COMPLETE]")

func _mk_team(s: WorldState, pos: Vector2i) -> TeamData:
	var p := PersonData.new(); p.id = _next_id; _next_id += 1
	s.persons[p.id] = p
	var t := TeamData.new(); t.team_id = _next_id; _next_id += 1
	t.leader_id = p.id; p.team_id = t.team_id
	t.tile_pos = pos; t.faction_id = -1; t.parent_team_id = -1
	t.current_task = TeamData.TASK_IDLE
	s.create_team(t)
	return t
