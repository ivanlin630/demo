class_name CommitmentFields

# ★「未完成的承諾」的【單一真相】（convoy-return-task-authority v2，systems 裁 2026-08-25）。
#
# ★病：persist hold 原本讀 `team.current_task in PROGRESSIVE_HOLD_TASKS` ——
#   那是**代理**，不是事實。`TaskArbiter.release()` 把 `current_task` 清成 IDLE
#   ⇒ 任何肯先 release 的 caller 都能無條件通過 hold（`task_arbiter:163` 自己文件化了這條通道）。
#   ⇒ ★hold 改讀【事實】：這支隊身上有沒有「已經開始、還沒結束」的東西。
#
# ★★為什麼不是手工白名單（systems §M 自糾）：
#   原本要列 `corvee_site` / `construction_team_id` / convoy 未結案 三個訊號 ——
#   那又是一張人工表，漏一個就靜默失效。
#   ⇒ 改成**機械稽核**（同 `estimator-lineage-scan.sh` 形狀）：
#     `.claude/hooks/commitment-field-scan.sh` 從 `team_data.gd` **自動抽出候選欄位**，
#     每一個都必須出現在下面的 `READS` 或 `NOT_COMMITMENT`（且附理由）。
#     ★**新增承諾類欄位而沒分類 ⇒ 掃描紅。** 覆蓋是構造性的，不靠誰記得列全。

# ★hold 真的會讀的欄位（每一筆註明「怎麼判未完成」）。
const READS: Array = [
	"corvee_site",        # 自己起的工地：tile 仍 construction_ticks_left>0 且 construction_team_id==自己
	"task_extra_data",    # convoy_phase（OUTBOUND/DELIVER/RETURN 皆為在途未結案）
	"order_target_id",    # 母隊/領主下的指派（護衛/任務對象），對象還在＝任務未了
]

# ★明確判定【不是】未完成承諾的欄位 + 理由（缺理由等於沒分類）。
const NOT_COMMITMENT: Dictionary = {
	"move_target": "只是「有目的地」，任何 task 都會有 ⇒ 拿它當承諾會讓 hold 變成全域黏鎖",
	"expand_site_cached": "cadence 快取（評估結果），不是已開始的工作",
	"consolidate_target_cache": "同上：節流快取",
	"absorb_target_cache": "同上：節流快取",
	"prosperity_target_id": "追擊目標會每 tick 依 intel 刷新，是意圖不是已投入的工程",
	"combat_target": "戰鬥鎖已由 try_set 第一道 guard 絕對處理，不需再進承諾判準",
	"social_target": "社交對象是本次互動的參數，resolver 當場結案",
	"goal_state": "長期目標＝慾望層，尚未開始的不算承諾（開始了會落到上面三個之一）",
	"survival_committed_option": "survival 層自有 stall-detector 與 cooldown（_detect_survival_stall），重複納管會兩套",
	"crisis_released_task": "那是「剛被釋放」的記錄，語意與承諾相反",
	"player_commanded_task": "玩家命令走 PRIO_PLAYER，優先序層處理，不經承諾判準",
	"solo_task_last": "承諾慣性的加分項（決策層），不是仲裁層的事實",
	"previous_task": "回復用的備份欄，不代表工作已開始",
	"plan_phase": "計畫層階段標籤，不綁定具體已開始的工作",
	"pending_proposal": "等對方回覆的提案，未開始執行",
	"pending_owner_change_tick": "偵測緩衝倒數，與本隊承諾無關",
	"current_task": "★它【就是】被 release 清掉的那個代理 —— v2 的整個重點是不再靠它當判準",
	"commit_stall_site": "stall-detector 的 baseline 綁在哪個工地（偵測器自己的記帳），承諾事實在 tile 上不在這欄",
	"commit_stall_target": "同 commit_stall_site：stall-detector 在 episode 起點快照的【目標】，偵測器自己的記帳，承諾事實在 tile 上不在這欄",
	"order_task": "上級指派的【型別標籤】；判未完成看的是對象還在不在（order_target_id 已在 READS）",
}

# ★回傳這支隊【未完成的承諾】：{} ＝ 沒有。
#   `progress` ＝ 越大越接近完成（供 stall-detector 用同一支 `stall_verdict`：上升＝有進展）。
# ★「我的工地」的【單一定義】（2026-08-25）：`corvee_site` 優先，否則腳下。
#   ★這段原本在 `persist_strength._build_tile`，而 `unfinished()` 當時只看 `corvee_site`
#   ⇒ 兩處對「我的工地」有兩個定義，窄的那個看不到「沒經過 commit-hook 就在蓋」的隊
#   ⇒ 那種隊的承諾對 hold 與 stall-detector 【完全隱形】。收斂成一份，persist 改呼這裡。
static func build_tile(state: WorldState, team: TeamData) -> HexTileData:
	if team.corvee_site != Vector2i(-1, -1):
		var ct: HexTileData = state.world.tiles.get(team.corvee_site.x * 1000 + team.corvee_site.y)
		if ct != null and ct.construction_team_id == team.team_id and ct.construction_ticks_left > 0:
			return ct   # 自己未完 corvee 工地（離開仍認得）
	return state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)

static func unfinished(state: WorldState, team: TeamData) -> Dictionary:
	if state == null or team == null:
		return {}
	# ①自己的工地 —— 讀 tile 的真實進度，不是讀 task 欄位。
	#   ★用共用的 `build_tile()`（corvee_site 優先、否則腳下）：
	#   只看 corvee_site 的話，「沒經過 commit-hook 就在蓋」的隊會完全隱形。
	var t: HexTileData = build_tile(state, team)
	if t != null and t.construction_team_id == team.team_id and t.construction_ticks_left > 0:
		var total: int = OutpostSystem.construction_ticks_total(t)
		return {"kind": "construction", "site": "%d,%d" % [t.tile_pos.x, t.tile_pos.y], "measurable": true, "progress": float(maxi(total - t.construction_ticks_left, 0)),
			"tick": t.construction_started_tick}
	# ②convoy 在途（任何 phase 都是未結案：貨還在身上或人還沒歸建）
	var phase: String = String(team.task_extra_data.get("convoy_phase", ""))
	if phase != "":
		var home = team.task_extra_data.get("home_pos", null)
		var prog: float = 0.0
		if home is Vector2i and home != Vector2i(-1, -1):
			prog = -float(FactionAISystem._hex_dist(team.tile_pos, home))   # 越近家越大（負距離）
		return {"kind": "convoy", "site": "convoy", "measurable": true, "progress": prog,
			"tick": int(team.task_extra_data.get("return_start_tick", team.task_start_tick))}
	# ③上級指派且對象還在
	if team.order_target_id != -1 and state.teams.has(team.order_target_id):
		# ★`order` 沒有進度事實可讀（上級指派只有「對象還在」這個布林）
		#   ⇒ measurable:false ★沒有事實就【不給判決】，不是把「量不到」當成「沒進展」。
		#   血證：沒有這欄時，stall-detector 對 order 每 cadence 判 STALLED ⇒ 652 次假觸發。
		return {"kind": "order", "site": str(team.order_target_id), "measurable": false, "progress": 0.0, "tick": team.task_start_tick}
	return {}

static func has_unfinished(state: WorldState, team: TeamData) -> bool:
	return not unfinished(state, team).is_empty()

# ★這個 task 是不是【服務同一個承諾】——若是，hold 不該擋它。
#   ★理由：hold 護的是承諾，不是 task 欄位。「先 release 再 set 回同一件事」是【復工】，
#   不是搶班；擋它會把 zombie 工地永遠鎖在 zombie 狀態（正是要修的反面）。
#   ⇒ 這條就是 §N 說的「①正當退場被誤擋」在仲裁層的防線。
static func serves(kind: String, new_task: String) -> bool:
	match kind:
		"construction":
			return new_task in [TeamData.TASK_BUILD, TeamData.TASK_CONSTRUCT,
				TeamData.TASK_UPGRADE, TeamData.TASK_EXPAND, TeamData.TASK_SETTLE]
		"convoy":
			return new_task == TeamData.TASK_CONVOY
		"order":
			return true   # 上級指派：由 order_task 決定型別，仲裁層不再二次判
	return false
