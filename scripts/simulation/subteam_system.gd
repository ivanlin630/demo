class_name SubteamSystem

const MIGRANT_RATION_DAYS: float = 15.0   # ★移民旅途口糧天數（TEST VALUE、DERIVED 供給窗；領主供給、空手 anon 免途中 famine 打斷）

# ★F3 ②結構搬移（純程序、零 logic 改）：subteam-messenger utils 自 faction_ai_system 逐字搬入（instance→static）。
# 介面 static：SubteamSystem.founding_timeout / equip_envoy_mounts / recall_envoy。零反向耦合（全呼外部
# MovementSystem/WorldState/ResourceBank/TaskArbiter/state；不回呼 faction_ai）。
const FOUNDING_TIMEOUT_MULT: float = 6.0
const FOUNDING_TIMEOUT_FLOOR_DAYS: int = 12       # TEST VALUE — 步行信使追移動 target 的收斂下限

static func founding_timeout(dist: int) -> int:
	return maxi(int(float(dist) * float(MovementSystem.BASE_MOVE_TICKS) * FOUNDING_TIMEOUT_MULT),
		FOUNDING_TIMEOUT_FLOOR_DAYS * WorldState.TICKS_PER_DAY)

static func equip_envoy_mounts(state: WorldState, mother: TeamData, envoy: TeamData) -> void:
	var want: int = envoy.population
	var have_envoy: int = int(envoy.resources.get("mounts", 0))
	var need: int = maxi(want - have_envoy, 0)
	if need <= 0:
		return
	var from_mother: int = mini(need, int(mother.resources.get("mounts", 0)))
	if from_mother <= 0:
		return
	ResourceBank.add(mother, "mounts", -from_mother, "envoy_mount_out")
	ResourceBank.add(envoy, "mounts", from_mother, "envoy_mount_in")

# 信使歸隊：釋放 task + 朝母隊移動 → 到母格 try_merge_back（復用 merge）。母隊 pending 靠自身 timeout 清。
static func recall_envoy(state: WorldState, envoy: TeamData) -> void:
	TaskArbiter.release(envoy)   # → IDLE, move_target=-1
	envoy.task_reason = "envoy_recall"
	var parent: TeamData = state.teams.get(envoy.parent_team_id)
	if parent != null:
		envoy.move_target = parent.tile_pos   # 下 tick _decide_subteam 路由回家/併回
	else:
		state.detach_subteam(envoy)            # 母隊已亡 → 脫離成獨立（正常 AI 接手，非 zombie）
		state.remove_tag(envoy, TeamData.TAG_SUBTEAM, "envoy_orphan")

func dispatch(state: WorldState, parent_id: int, sub_leader_id: int,
		pop_count: int, task: String, move_target: Vector2i,
		order_target_id: int = -1, order_task: String = "",
		extra_advisor_ids: Array = []) -> int:
	var parent: TeamData = state.teams.get(parent_id)
	if parent == null:
		return -1
	var sub_leader = state.persons.get(sub_leader_id)
	if sub_leader == null:
		return -1
	if not parent.named_members.has(sub_leader_id):
		return -1
	var cmd: float   = float(sub_leader.skills.get("統領", 0.0))
	var sub_cap: int = TeamData.pop_cap_from_leadership(cmd)
	pop_count = mini(pop_count, sub_cap)
	if parent.population - pop_count < 1:
		pop_count = parent.population - 1
	if pop_count <= 0 and extra_advisor_ids.is_empty():
		return -1
	pop_count = maxi(pop_count, 0)

	var sub := TeamData.new()
	sub.team_id          = state.consume_next_team_id()
	sub.tile_pos         = parent.tile_pos
	sub.current_task     = task   # 新 team 建立豁免：dispatch 出的 task = PRIO_DISPATCH
	sub.task_priority    = TaskArbiter.PRIO_DISPATCH if task != TeamData.TASK_IDLE else 0
	sub.move_target      = move_target
	sub.order_target_id  = order_target_id
	sub.order_task       = order_task
	sub.leader_id        = sub_leader_id
	state.set_readiness(sub, parent.readiness, "subteam_init")
	state.set_team_tags(sub, [TeamData.TAG_SUBTEAM], "subteam_init")

	var frac: float = float(pop_count) / float(parent.population)
	for res in parent.resources:
		var amt: float = float(parent.resources[res]) * frac
		ResourceBank.set_amt(sub, res, amt, "subteam_split_in")
		ResourceBank.add(parent, res, -amt, "subteam_split_out")
	# 公庫 treasury 按比例帶走（sub 新建 treasury=0 → transfer 等價原邏輯，守恆）
	AnonTreasuryBank.transfer(parent, sub, parent.anon_treasury * frac, "subteam_split")

	state.remove_member(parent, sub_leader_id, false)   # 出母 roster；team_id 由下行設 sub
	sub_leader.team_id = sub.team_id
	for aid in extra_advisor_ids:
		if aid == sub_leader_id:
			continue
		if not parent.named_members.has(aid):
			continue
		var advisor = state.persons.get(aid)
		if advisor == null:
			continue
		state.remove_member(parent, aid, false)   # 轉隊：出母（team_id 由 add 設 sub）
		state.add_member(sub, aid)                 # 入子：append + team_id=sub
	# 補搬 anon：pop_count 扣掉已搬的 named（leader + advisors）= 應搬 anon 數
	var named_in_sub: int = sub.named_members.size() + (1 if sub.leader_id != -1 else 0)
	var anon_to_sub: int = maxi(pop_count - named_in_sub, 0)
	AnonTierSystem.transfer_proportional(parent, sub, anon_to_sub)
	state.create_team(sub)   # S9 chokepoint：註冊 + known/discovered init
	state.set_subteam_parent(sub, parent_id)         # 母子關係走入口（雙向同步 subteam_ids）
	state.set_team_faction(sub, parent.faction_id)   # 子隊繼承 parent faction 走入口（雙向同步 member_team_ids）
	print("[Sub] Team%d 派出子隊 Team%d leader=P%d advisors=%s (pop=%d cap=%d task=%s)" % [
		parent_id, sub.team_id, sub_leader_id, str(sub.named_members), pop_count, sub_cap, task])
	return sub.team_id

# ★資訊網 Part2：派 anon 1 人信使（≠subteam，無 named leader）——村莊派個人求救。
# leader_id=-1（無 named；population getter 不計 phantom→pop=anon 1）；只搬 1 anon pop、★零 resource carry
# （R² tracking：餓 resident 任何 res 流失都在乎，信使空手；不沿 dispatch() proportional-split）。gate 母隊 pop>=2。
# ★復甦 R1 移民：從 parent 抽 k anon → 遷徙 subteam 朝 target 村（抵達 _tick_migrant 併入 target=P2 共址即產能）。
# 鏡射 dispatch_anon_messenger（leader_id=-1、空手），差別=k pop、TASK_MIGRATE、reason="migrate"。真成本（人離源村）。
func dispatch_anon_migrants(state: WorldState, parent_id: int, k: int,
		move_target: Vector2i, order_target_id: int) -> int:
	var parent: TeamData = state.teams.get(parent_id)
	if parent == null or k <= 0 or parent.population < 2:
		return -1
	if AnonTierSystem.total_pop(parent) < k:
		return -1   # anon 不夠 k（不掏空）
	var sub := TeamData.new()
	sub.team_id          = state.consume_next_team_id()
	sub.tile_pos         = parent.tile_pos
	sub.current_task     = TeamData.TASK_MIGRATE
	sub.task_priority    = TaskArbiter.PRIO_DISPATCH
	sub.task_reason      = "migrate"
	sub.move_target      = move_target
	sub.order_target_id  = order_target_id
	sub.leader_id        = -1
	sub.task_start_tick  = state.world.current_tick
	sub.task_extra_data  = {"migrant_target": order_target_id}
	state.set_readiness(sub, parent.readiness, "migrant_init")
	state.set_team_tags(sub, [TeamData.TAG_SUBTEAM], "migrant_init")
	AnonTierSystem.transfer_proportional(parent, sub, k)   # 抽 k anon
	# ★旅途口糧（領主供給移民、真成本）：空手 anon 移民必即刻 famine→survival 打斷 MIGRATE/抑制移動→永不抵達。
	#   給足 k 人跨途食糧（RATION_DAYS×每人日耗）→ 途中不餓→不被 survival preempt。領主真扣（來源約束已守留守）。
	var rations: float = float(k) * ResourceSystem.FOOD_PER_PERSON_PER_DAY * MIGRANT_RATION_DAYS
	var paid: float = ResourceBank.remove(parent, "food", rations, "migrant_rations")
	ResourceBank.add(sub, "food", paid, "migrant_rations_in")
	state.create_team(sub)
	state.set_subteam_parent(sub, parent_id)
	state.set_team_faction(sub, parent.faction_id)
	return sub.team_id

func dispatch_anon_messenger(state: WorldState, parent_id: int, task: String, reason: String,
		move_target: Vector2i, order_target_id: int, extra_data: Dictionary) -> int:
	var parent: TeamData = state.teams.get(parent_id)
	if parent == null or parent.population < 2:
		return -1   # 不掏空（同 can_send_herald gate、冗餘守）
	if AnonTierSystem.total_pop(parent) < 1:
		return -1   # 無 anon 可分當信使
	var sub := TeamData.new()
	sub.team_id          = state.consume_next_team_id()
	sub.tile_pos         = parent.tile_pos
	sub.current_task     = task
	sub.task_priority    = TaskArbiter.PRIO_DISPATCH if task != TeamData.TASK_IDLE else 0
	sub.task_reason      = reason
	sub.move_target      = move_target
	sub.order_target_id  = order_target_id
	sub.leader_id        = -1   # ★anon 信使無 named leader（team infra 容 -1；population 不計 phantom）
	sub.task_start_tick  = state.world.current_tick
	sub.task_extra_data  = extra_data
	state.set_readiness(sub, parent.readiness, "anon_msg_init")
	state.set_team_tags(sub, [TeamData.TAG_SUBTEAM], "anon_msg_init")
	# ★empty-handed：只搬 1 anon pop、零 resource transfer（不沿 dispatch() 的 proportional resource split）。
	AnonTierSystem.transfer_proportional(parent, sub, 1)
	state.create_team(sub)
	state.set_subteam_parent(sub, parent_id)
	state.set_team_faction(sub, parent.faction_id)
	return sub.team_id

func try_merge_back(state: WorldState, sub_id: int) -> bool:
	var sub: TeamData = state.teams.get(sub_id)
	if sub == null or sub.parent_team_id == -1:
		return false
	# 移動中施工/升級/擴建 → 不 merge_back（子隊在 parent tile 出發前避免立即被吸回）
	# TASK_BUILD/TASK_SETTLE 已到目標格，讓正常邏輯（到 parent 格才 merge）處理即可
	var _TRANSIT_TASKS: Array = [
		TeamData.TASK_SETTLE, TeamData.TASK_CONSTRUCT,
		TeamData.TASK_UPGRADE, TeamData.TASK_EXPAND,
		TeamData.TASK_MIGRATE,   # ★復甦 R1 bed-root：移民子隊生於 parent(領主)格、未出發即被 merge_back 吸回=vanish→arrived=0；同 SETTLE 在途不吸回（到 target 由 _tick_migrant 併入）
	]
	if sub.current_task in _TRANSIT_TASKS:
		return false
	var parent: TeamData = state.teams.get(sub.parent_team_id)
	if parent == null or parent.tile_pos != sub.tile_pos:
		return false
	# ★後勤 SLICE A convoy.return telemetry：在真 merge 點認 convoy porter（對齊 [Merge] 事件，無論它經 CONVOY 或
	#   被 loop2b release→IDLE 併回路——task_extra_data.convoy_phase 標記 release 不清，故此處統一準確計）。
	if Probe.enabled and sub.task_extra_data.has("convoy_phase"):
		Probe.bump("convoy.return")
	# ★失聯帳本清帳：子隊(scout/convoy)回歸→標母 ledger 對應筆 resolved（team subject by subject_ref、inline 避跨 class 呼叫）。
	for e in parent.dispatch_ledger:
		if not bool(e.get("resolved", false)) and bool(e.get("is_team", false)) and int(e.get("subject_ref", -1)) == sub_id:
			e["resolved"] = true
			break
	_merge_into(state, sub.parent_team_id, sub_id)
	return true

# 按比例搬 resources + anon_treasury 給 absorber；will_empty 時 treasury 全帶走（守恆）
# 呼叫前 caller 應已決定 frac 與 will_empty（absorbed 是否將清空）；population/anon-tier（含 wounded 桶）轉移由 caller 經 transfer_proportional 處理
func _transfer_proportional_assets(absorber: TeamData, absorbed: TeamData, frac: float, will_empty: bool) -> void:
	for res in absorbed.resources:
		var amt: float = float(absorbed.resources.get(res, 0)) * frac
		ResourceBank.add(absorber, res, amt, "merge_share_in")
		ResourceBank.add(absorbed, res, -amt, "merge_share_out")
	AnonTreasuryBank.transfer(absorbed, absorber, absorbed.anon_treasury * frac, "merge_share")
	if will_empty:
		# absorbed 將被 erase → 掃光殘餘 resources（非僅 frac）+ treasury，否則殘餘 coin 隨 erase 漏失。
		# （population getter 後，frac 可能在 leader/named 已搬出時算得=0 → resources 完全沒搬）
		for res in absorbed.resources:
			ResourceBank.add(absorber, res, float(absorbed.resources.get(res, 0)), "merge_absorb_in")
			ResourceBank.set_amt(absorbed, res, 0.0, "merge_absorb_out")
		AnonTreasuryBank.transfer_all(absorbed, absorber, "merge_absorb")

# 滅團清理：統一走 erase_team chokepoint（faction member/known_member_states + registry + 交叉 ref）
func _erase_absorbed_team(state: WorldState, absorbed_id: int) -> void:
	state.erase_team(absorbed_id)

func merge_teams(state: WorldState, absorber_id: int, absorbed_id: int,
		transfer_npc_ids: Array = [], transfer_anon: int = -1) -> void:
	if transfer_npc_ids.is_empty() and transfer_anon == -1:
		_merge_into(state, absorber_id, absorbed_id)
		return
	var absorber: TeamData = state.teams.get(absorber_id)
	var absorbed: TeamData = state.teams.get(absorbed_id)
	if absorber == null or absorbed == null or absorbed.population <= 0:
		return
	var absorber_leader = state.persons.get(absorber.leader_id)
	var absorber_cmd: float = float(absorber_leader.skills.get("統領", 0.0)) if absorber_leader else 0.0
	var absorber_cap: int = FactionAISystem.effective_pop_cap(state, absorber)
	var capacity: int = absorber_cap - absorber.population
	if capacity <= 0:
		print("[Merge] Team%d 容量已滿，無法合併 Team%d" % [absorber_id, absorbed_id])
		return
	var named_cap: int = mini(transfer_npc_ids.size(), capacity)
	var actual_npcs: Array = transfer_npc_ids.slice(0, named_cap)
	# 計算匿民轉移數量
	var named_in_absorbed: int = (1 if absorbed.leader_id != -1 else 0) \
		+ absorbed.named_members.size()
	var anon_pop: int = maxi(absorbed.population - named_in_absorbed, 0)
	var anon_xfer: int
	if transfer_anon == -1:
		if named_in_absorbed > 0:
			anon_xfer = int(round(float(anon_pop) * float(actual_npcs.size()) / float(named_in_absorbed)))
		else:
			anon_xfer = anon_pop
	elif transfer_anon == 0:
		anon_xfer = 0
	else:
		anon_xfer = mini(transfer_anon, anon_pop)
	anon_xfer = mini(anon_xfer, maxi(capacity - actual_npcs.size(), 0))
	anon_xfer = maxi(anon_xfer, 0)
	var total_xfer: int = actual_npcs.size() + anon_xfer
	var frac: float = float(total_xfer) / float(absorbed.population) if absorbed.population > 0 else 0.0
	var absorbed_leader_moved: bool = false
	for pid in actual_npcs:
		var p: PersonData = state.persons.get(pid)
		if p == null or p.team_id != absorbed_id:
			continue
		p.team_id = absorber_id
		if pid == absorbed.leader_id:
			absorbed_leader_moved = true
			absorbed.leader_id = -1
			state.add_member(absorber, pid)   # 入吸收隊（team_id 已於上設 absorber）
		else:
			state.remove_member(absorbed, pid, false)   # 出被吸隊 roster（team_id 已=absorber）
			state.add_member(absorber, pid)             # 入吸收隊
	AnonTierSystem.transfer_proportional(absorbed, absorber, anon_xfer)
	_transfer_proportional_assets(absorber, absorbed, frac, absorbed.population <= 0)
	if absorbed_leader_moved and absorbed.population > 0:
		var es := EventSystem.new()
		es.on_leader_death(state, absorbed)
	if absorbed.population <= 0:
		state.detach_subteam(absorbed)   # 滅團前脫離母關係（雙向同步）
		_erase_absorbed_team(state, absorbed_id)
		print("[Merge] Team%d ← Team%d 完全合併 (absorber_pop=%d)" % [
			absorber_id, absorbed_id, absorber.population])
	else:
		state.set_subteam_parent(absorbed, absorber_id)   # absorbed 成 absorber 子隊走入口（雙向同步）
		TaskArbiter.release(absorbed)
		if not absorbed.tags.has(TeamData.TAG_SUBTEAM):
			state.add_tag(absorbed, TeamData.TAG_SUBTEAM, "partial_merge")
		if total_xfer > 0:
			print("[Merge] Team%d ← Team%d 部分合併 (absorber=%d absorbed=%d)" % [
				absorber_id, absorbed_id, absorber.population, absorbed.population])
		else:
			print("[Merge] Team%d ← Team%d 容量不足，未轉移人員 (absorber=%d)" % [
				absorber_id, absorbed_id, absorber.population])

func _merge_into(state: WorldState, absorber_id: int, absorbed_id: int) -> void:
	var absorber: TeamData = state.teams[absorber_id]
	var absorbed: TeamData = state.teams[absorbed_id]
	var absorber_leader = state.persons.get(absorber.leader_id)
	var absorber_cmd: float = float(absorber_leader.skills.get("統領", 0.0)) if absorber_leader else 0.0
	var absorber_cap: int   = FactionAISystem.effective_pop_cap(state, absorber)
	var capacity: int       = absorber_cap - absorber.population

	# 子隊回歸但母團已滿 → 獨立分團，不重試
	if capacity <= 0 and absorbed.parent_team_id == absorber_id:
		state.detach_subteam(absorbed)   # 脫離母團 → 獨立（雙向同步）
		state.remove_tag(absorbed, TeamData.TAG_SUBTEAM, "merge_full_split")
		print("[Split] Team%d 回歸失敗（母團滿員），獨立為新分團" % absorbed_id)
		return

	# 子隊回歸：歸還 sub_leader 給 parent
	if absorbed.parent_team_id == absorber_id and absorbed.leader_id != -1:
		var sub_leader = state.persons.get(absorbed.leader_id)
		if sub_leader != null:
			state.add_member(absorber, absorbed.leader_id)   # sub_leader 歸還母 roster + team_id
		absorbed.leader_id = -1   # leader 已歸還 absorber → 清空，否則 population getter 仍計 1 phantom leader 擋滅團
	# 歸還 sub.named_members
	if absorbed.parent_team_id == absorber_id:
		for aid in absorbed.named_members:
			if state.persons.get(aid) != null:
				state.add_member(absorber, aid)   # 歸還母 roster + team_id（persons 缺席者原亦跳過）
		absorbed.named_members.clear()             # bulk 出被吸隊 roster（人已轉，team_id 皆=absorber）

	var transfer: int = mini(absorbed.population, capacity)
	var frac: float   = float(transfer) / float(absorbed.population) if absorbed.population > 0 else 0.0
	AnonTierSystem.transfer_proportional(absorbed, absorber,
		roundi(float(AnonTierSystem.total_pop(absorbed)) * frac))
	# named/leader 已搬、anon 已轉 → absorbed.population getter 即剩餘量
	_transfer_proportional_assets(absorber, absorbed, frac, absorbed.population <= 0)
	state.detach_subteam(absorbed)   # 合併後脫離母關係（雙向同步；殘留則獨立、滅團則 erase 前已清母側）
	if absorbed.population <= 0:
		_erase_absorbed_team(state, absorbed_id)
		print("[Merge] Team%d ← Team%d 完全合併 (pop=%d)" % [absorber_id, absorbed_id, absorber.population])
	elif transfer > 0:
		print("[Merge] Team%d ← Team%d 部分合併 (absorber=%d absorbed=%d)" % [
			absorber_id, absorbed_id, absorber.population, absorbed.population])
	else:
		print("[Merge] Team%d ← Team%d 容量不足，未轉移人員 (absorber=%d)" % [
			absorber_id, absorbed_id, absorber.population])

func _pick_subteam_leader(state: WorldState, team: TeamData, task: String) -> int:
	var skill_map: Dictionary = {
		"攻擊": "統領", "掠奪": "統領", "貿易": "商業",
		"外交": "交涉", "生產": "生產", "製造": "製造", "偵查": "偵查"
	}
	var skill: String = skill_map.get(task, "統領")
	var best_id: int = -1
	var best_val: float = -1.0
	for pid in team.named_members:
		var p: PersonData = state.persons.get(pid)
		if p == null: continue
		var v: float = float(p.skills.get(skill, 0.0))
		if v > best_val:
			best_val = v; best_id = pid
	return best_id

