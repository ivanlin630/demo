class_name StrategicAiSystem

# ★S3 搬入 T3：【勢力戰略】字面上就是戰略層。
const STRATEGIC_INTERVAL:      int = DecisionTier.C_STRATEGIC
# ★S3 搬入 T3：【結盟傾向】是對外關係的大方向，不是一天內會翻來翻去的事。
const ALLIANCE_CHECK_INTERVAL: int = DecisionTier.C_ALLIANCE_CHECK
const BREAKOUT_DIST: int = 2     # 原 5，縮為 2（radius 小地圖友善）
const ENCIRCLE_DIST: int = 1     # 原 2，縮為 1
const BREAKOUT_NEAREST_THRESHOLD: int = 3   # 鄰敵 > 此距不觸發 breakout

var _last_goal_sig: Dictionary = {}   # { faction_id: "type_target" } diff print 用

static func _is_valid_tile(state: WorldState, pos: Vector2i) -> bool:
    return state.world.tiles.has(pos.x * 1000 + pos.y)

static func _nearest_valid_tile(state: WorldState, target: Vector2i, fallback: Vector2i) -> Vector2i:
    if _is_valid_tile(state, target): return target
    # 從 target 往 fallback 方向找最近 in-map tile
    var dir: Vector2i = fallback - target
    var step: Vector2i = Vector2i(sign(dir.x), sign(dir.y))
    if step == Vector2i.ZERO: return fallback
    var cur: Vector2i = target
    for _i in range(20):
        cur = cur + step
        if _is_valid_tile(state, cur): return cur
    return fallback

func tick(state: WorldState, faction: FactionData) -> void:
    # ★S3：`% == 0` → 錯峰排程（同 GOAL）—— 而這一支是【早退式】，排程要在 return 之前做完。
    if faction.strategic_eval_next_tick == 0:
        faction.strategic_eval_next_tick = CadenceStagger.next_tick(
            state.world.current_tick, state.world.current_tick, faction.faction_id, STRATEGIC_INTERVAL)
    # ★★★S4b T0：事件瞬醒短路（形狀照抄 faction_ai `_should_reeval`）。
    #   ★這支是【早退式】⇒ 短路寫成「兩個都不成立才 return」。
    var _strat_due: bool = state.world.current_tick >= faction.strategic_eval_next_tick
    DecisionTier.mark_gate("STRATEGIC", state.world.current_tick)
    var _strat_src: String = WorldEvents.pending_source_faction(state, faction)
    var _strat_woke: bool = _strat_src != ""
    if not (_strat_due or _strat_woke): return
    DecisionTier.tap_wake("STRATEGIC", faction.faction_id, state.world.current_tick, _strat_src, _strat_due)
    var _poll_pure: bool = _strat_due and not _strat_woke
    var _sel_before: String = _goal_sig(faction)
    if _strat_due:
        faction.strategic_eval_next_tick = CadenceStagger.next_tick(
            state.world.current_tick, state.world.current_tick, faction.faction_id, STRATEGIC_INTERVAL)
    if Probe.enabled: Probe.bump_sample("tier.fire", {"k": "STRATEGIC", "team": faction.faction_id if faction != null else -1, "tick": state.world.current_tick}, 6000)
    _update_faction_goals(state, faction)
    DecisionTier.tap_poll_outcome("STRATEGIC", faction.faction_id, state.world.current_tick,
        _sel_before, _goal_sig(faction), _poll_pure)
    if faction.strategic_goals.size() > 0:
        var top: Dictionary = faction.strategic_goals[0]
        match top["type"]:
            "expand":
                _assign_encirclement(state, faction, top["target_id"])
    for tid in faction.member_team_ids:
        var t: TeamData = state.teams.get(tid)
        if t: _assign_breakout(state, t)
    # ★S3：`% == 0` → 錯峰排程（同 GOAL）—— 範圍從剛性變散開就是搬完的證據。
    if faction.alliance_eval_next_tick == 0:
        faction.alliance_eval_next_tick = CadenceStagger.next_tick(
            state.world.current_tick, state.world.current_tick, faction.faction_id, ALLIANCE_CHECK_INTERVAL)
    # ★S4b T0：事件瞬醒短路（同上）。
    var _alli_due: bool = state.world.current_tick >= faction.alliance_eval_next_tick
    DecisionTier.mark_gate("ALLIANCE", state.world.current_tick)
    var _alli_src: String = WorldEvents.pending_source_faction(state, faction)
    var _alli_woke: bool = _alli_src != ""
    if _alli_due or _alli_woke:
        # ★ALLIANCE 沒有 tap_poll_outcome：它的「選擇」不落在任何可比較的持久欄位上
        #   （_evaluate_alliance_need 的產出是一次性動作）。★床要把它印成【量不到】不是 0。
        DecisionTier.tap_wake("ALLIANCE", faction.faction_id, state.world.current_tick, _alli_src, _alli_due)
        if _alli_due:
            faction.alliance_eval_next_tick = CadenceStagger.next_tick(
                state.world.current_tick, state.world.current_tick, faction.faction_id, ALLIANCE_CHECK_INTERVAL)
        if Probe.enabled: Probe.bump_sample("tier.fire", {"k": "ALLIANCE", "team": faction.faction_id if faction != null else -1, "tick": state.world.current_tick}, 6000)
        _evaluate_alliance_need(state, faction)

# ★選擇簽章：戰略層【選出來的東西】＝ 目標清單的 (型別, 目標) 序列。
#   ★取全部不只取第一條：換掉第二順位也是【選擇變了】。
func _goal_sig(faction: FactionData) -> String:
    var parts: Array = []
    for g in faction.strategic_goals:
        parts.append("%s:%s" % [String(g.get("type", "")), str(g.get("target_id", -1))])
    return "|".join(PackedStringArray(parts))

func _update_faction_goals(state: WorldState, faction: FactionData) -> void:
    # F-D3：strategic_ai 降為**空間 affordance 層**——讀統一 intent(commander _select_intent 單一源，
    # 已由 faction_ai.evaluate_all 先於本 tick 設 f.intent)，映射空間 goal(encirclement/trade_net/defend)。
    # 不再自產 intent(舊 rung/archetype 計分 = 第2 producer，已移除)。單一 intent source。
    faction.strategic_goals.clear()
    var leader_team: TeamData = state.teams.get(faction.leader_team_id)
    if leader_team == null: return
    var faction_leader: PersonData = state.persons.get(leader_team.leader_id)
    if faction_leader == null: return
    var v := faction_leader.values

    var it: String = String(faction.intent.get("type", "")) if faction.intent is Dictionary else ""
    var it_target: int = int(faction.intent.get("target_id", -1)) if faction.intent is Dictionary else -1

    # 征服/擴張 → expand(空間包圍)：target 讀統一 intent，缺則就近獨立鄰
    if it == "征服" or it == "擴張":
        var tgt_id: int = it_target
        if tgt_id == -1: tgt_id = _nearest_independent(state, leader_team)
        if tgt_id != -1:
            faction.strategic_goals.append({ "type": "expand", "target_id": tgt_id,
                "priority": 0.5 + float(v.get("野心", 0.5)) * 0.5 })

    # defend：有弱 member = 純空間支援 affordance(保護弱者，非 intent producer)
    if faction.member_team_ids.size() > 1:
        var weakest_id: int = _find_weakest_member(state, faction)
        if weakest_id != -1 and weakest_id != faction.leader_team_id:
            faction.strategic_goals.append({ "type": "defend", "target_id": weakest_id,
                "priority": 0.7 })

    # 序8 灰項溶入：致富 → trade_net dispatch 撕除（_dispatch_trade_net 繞引擎 try_set，6月零派發=冗餘死路）。
    # 致富 faction 商隊成員改走引擎 _decide_unified（貿易/買糧/囤貨 option 承接交易，融合驗 greylist_dissolution_check）。
    # strategic_goal "trade_net" 唯一消費者=已刪的 _dispatch_trade_net → goal append 一併清（無其他消費）。

    faction.strategic_goals.sort_custom(func(a, b): return a["priority"] > b["priority"])
    if faction.strategic_goals.size() > 0:
        # diff print：首要目標變化才印（壓 log spam）
        var top_sig: String = "%s_%d" % [faction.strategic_goals[0]["type"],
            faction.strategic_goals[0]["target_id"]]
        if _last_goal_sig.get(faction.faction_id, "") != top_sig:
            _last_goal_sig[faction.faction_id] = top_sig
            print("[StrategicAI] Faction%d 首要目標: %s target=%d" % [
                faction.faction_id, faction.strategic_goals[0]["type"], faction.strategic_goals[0]["target_id"]])
    # 若無 expand goal，清除所有包圍指派（目標可能已消滅）
    var has_expand: bool = false
    for g in faction.strategic_goals:
        if g["type"] == "expand":
            has_expand = true
            break
    if not has_expand:
        for tid in faction.member_team_ids:
            var t: TeamData = state.teams.get(tid)
            if t:
                for key in t.strategic_assignments.keys():
                    if key != -1:
                        t.strategic_assignments.erase(key)

func _nearest_independent(state: WorldState, from_team: TeamData) -> int:
    var best_id: int = -1; var best_d: int = 999
    for tid in state.team_discovered.get(from_team.team_id, []):
        if not state.teams.has(tid): continue
        var t: TeamData = state.teams[tid]
        if t.faction_id != -1 or t.team_id == from_team.team_id: continue
        var d: int = _hex_dist(from_team.tile_pos, t.tile_pos)
        if d < best_d: best_d = d; best_id = tid
    return best_id

# ★★★簽名【拿掉 fallback 參數】（god-view 真違規③修法，2026-09-02）：
#   ★病（reviewer 親驗）：唯一呼叫端傳的是【敵方的 live 真實人口】當 fallback ——
#     而同檔 :250 self_pop 走 `_faction_total_pop`（fallback 用【自己】的 live pop，對象是自己人＝legit）
#   ⇒ ★★同一個寫法，一個對自己（合法）一個對敵人（違憲）：★★★複製時漏改了【觀察對象】
#   ⇒ 修法照 Fix A 的前例做成【型別防線】：★把 fallback 參數拿掉，
#     ★★這支函式從此【收不到任何外部值】⇒ 想拿 live 當退路也傳不進來。
#   ★無 belief ⇒ 回 -1，由呼叫端決定（★而呼叫端的決定寫在它自己那裡，不藏在這裡）。
func _get_pop_est(state: WorldState, obs_id: int, tgt_id: int) -> int:
    var _b: Dictionary = BeliefSystem.best_estimate(state, obs_id, tgt_id)
    return int(_b.get("population_est", -1)) if not _b.is_empty() else -1

func _find_weakest_member(state: WorldState, faction: FactionData) -> int:
    var weakest_id: int = -1; var weakest_pop: int = 9999
    for tid in faction.member_team_ids:
        # T-02：從 faction_snapshot 讀人口；無快照 = 9999（視為強健，不優先支援）
        var pop: int = faction.known_member_states.get(tid, {}).get("population", 9999)
        if pop < weakest_pop:
            weakest_pop = pop; weakest_id = tid
    return weakest_id

func _hex_dist(a: Vector2i, b: Vector2i) -> int:
    var dx := b.x - a.x; var dy := b.y - a.y
    return (abs(dx) + abs(dx + dy) + abs(dy)) / 2

func _assign_encirclement(state: WorldState, faction: FactionData,
        target_id: int) -> void:
    var target: TeamData = state.teams.get(target_id)
    if target == null: return
    var member_teams: Array = []
    for tid in faction.member_team_ids:
        var t: TeamData = state.teams.get(tid)
        if t: member_teams.append(t)
    # clear stale encirclement assignments before re-assigning
    for t in member_teams:
        t.strategic_assignments.clear()
    var dirs: Array = [
        Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1),
        Vector2i(0, -1), Vector2i(1, -1), Vector2i(-1, 1),
    ]
    # T-02：用 leader 的 team_intel 取目標最後已知位置
    var leader_id: int = faction.leader_team_id
    var target_pos: Vector2i = BeliefSystem.best_estimate(state, leader_id, target_id).get("tile_pos", Vector2i(-1, -1))
    # F1 感知鐵律：缺 belief → sentinel (-1,-1)（禁默認 live）。無 belief 位 → 不包圍（座標算術不能用 -1）；
    # assignments 已 clear(:131)，直接 return 不設 sa_pos。
    if target_pos == Vector2i(-1, -1):
        return
    # S9 建造/升級/擴建子隊豁免：正前往施工目標，不得被包圍戰略覆蓋 move_target
    var _BUILDER_TASKS_SA: Array = [TeamData.TASK_CONSTRUCT, TeamData.TASK_BUILD,
        TeamData.TASK_UPGRADE, TeamData.TASK_EXPAND]
    for i in range(member_teams.size()):
        var t: TeamData = member_teams[i]
        if t.current_task in FactionAISystem.SURVIVAL_TASKS:
            continue
        if t.current_task in _BUILDER_TASKS_SA:
            continue   # S9 施工子隊不參與包圍
        var dir: Vector2i = dirs[i % dirs.size()]
        var sa_pos: Vector2i = target_pos + dir * ENCIRCLE_DIST
        sa_pos = _nearest_valid_tile(state, sa_pos, target_pos)
        t.strategic_assignments[target_id] = sa_pos
        Probe.bump("strat.encircle_assigned")   # D0 characterization

func _assign_breakout(state: WorldState, self_team: TeamData) -> void:
    if self_team.current_task in FactionAISystem.SURVIVAL_TASKS:
        self_team.strategic_assignments.erase(-1)
        return
    # E5 感知鐵律：突圍讀 belief last-seen 敵位（非 live god-view；敵脫視野→照最後見位算逃向=合理，同 threat evasion）。
    var enemy_bpos: Array = []   # [Vector2i] believed 敵位（無 belief 者略過，不納突圍計算）
    for tid in state.team_discovered.get(self_team.team_id, []):
        var t: TeamData = state.teams.get(tid)
        if t == null: continue
        if t.faction_id == -1 or t.faction_id == self_team.faction_id:
            continue
        var bp: Vector2i = BeliefSystem.belief_pos(state, self_team.team_id, tid)
        if bp == Vector2i(-1, -1): continue   # 無 belief 位 → 不納入突圍
        enemy_bpos.append(bp)
    if enemy_bpos.size() < 2:
        self_team.strategic_assignments.erase(-1)
        return
    # 鄰敵 > BREAKOUT_NEAREST_THRESHOLD hex 不觸發 breakout（看遠敵不必恐慌）
    var nearest_dist: int = 9999
    for bp in enemy_bpos:
        var d: int = _hex_dist(self_team.tile_pos, bp)
        if d < nearest_dist: nearest_dist = d
    if nearest_dist > BREAKOUT_NEAREST_THRESHOLD:
        self_team.strategic_assignments.erase(-1)
        return
    var best_dir: Vector2i = _find_escape_dir(self_team.tile_pos, enemy_bpos)
    var sa_pos: Vector2i = self_team.tile_pos + best_dir * BREAKOUT_DIST
    sa_pos = _nearest_valid_tile(state, sa_pos, self_team.tile_pos)
    self_team.strategic_assignments[-1] = sa_pos
    Probe.bump("strat.breakout_assigned")   # D0 characterization

func _find_escape_dir(origin: Vector2i, enemy_positions: Array) -> Vector2i:
    var dirs: Array = [
        Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1),
        Vector2i(0, -1), Vector2i(1, -1), Vector2i(-1, 1),
    ]
    var best_dir: Vector2i = dirs[0]; var best_score: float = -99.0
    for d in dirs:
        var score: float = 0.0
        for ev_pos in enemy_positions:   # E5：belief last-seen 敵位（非 live tile_pos）
            var ev: Vector2i = ev_pos - origin
            score -= float(d.x * ev.x + d.y * ev.y)
        if score > best_score: best_score = score; best_dir = d
    return best_dir

func _evaluate_alliance_need(state: WorldState, faction: FactionData) -> void:
    var self_pop: int = _faction_total_pop(state, faction)
    var threat_map: Dictionary = {}
    var seen: Dictionary = {}  # tid → obs_id（記錄是哪個 member 看到的）
    for mid in faction.member_team_ids:
        for tid in state.team_discovered.get(mid, []):
            seen[tid] = mid
    for tid in seen:
        var t: TeamData = state.teams.get(tid)
        if t == null: continue
        if t.faction_id == faction.faction_id or t.faction_id == -1: continue
        # T-02：讀目擊者 member 的 team_intel 估算值
        var obs_id: int = seen[tid]
        var pop_est: int = _get_pop_est(state, obs_id, tid)
        if pop_est < 0:   # gate-ok: 這不是行為門檻，是【belief 缺席哨兵】——-1 是本函式自己約定的「無情報」值，不是一個可調的閾
            # ★沒有 belief ⇒ ★★這一隊【不進威脅帳】——你不會被一個你毫無情報的東西威脅到。
            #   ★★★沿用引擎既有先例（`find_prosperity_prey`：`if not has_belief: continue`），
            #     不是新政策；★而它可見：非 0 代表這個窗裡有多少敵隊是「看得到但估不出」。
            if Probe.enabled: Probe.bump("alliance.threat_skip_nobelief")
            continue
        threat_map[t.faction_id] = threat_map.get(t.faction_id, 0) + pop_est
    for fid in threat_map:
        if threat_map[fid] > self_pop * 1.5:
            print("[StrategicAI] Faction%d 受威脅，尋求結盟" % faction.faction_id)
            break

func _faction_total_pop(state: WorldState, faction: FactionData) -> int:
    var total: int = 0
    for tid in faction.member_team_ids:
        # T-02：從快照讀人口；無快照 fallback = 直讀（自己的隊伍應有快照）
        var t: TeamData = state.teams.get(tid)
        var snap_pop: int = faction.known_member_states.get(tid, {}).get("population", -1)
        if snap_pop >= 0:
            total += snap_pop
        elif t:
            total += t.population
    return total

# 序8 灰項溶入：_dispatch_trade_net（idle 商隊 → try_set TASK_TRADE 繞引擎）已撕除
# （憲法溶入 arc 末張，8 違憲全溶完）。致富交易改走引擎 _decide_unified（貿易/買糧/囤貨 option）。
# 下方 _find_trade_partner / _tile_has_resident 為純查詢 scaffolding（無 TaskArbiter 呼叫，非違憲），
# 仍供 headless_test 覆蓋；god-view fallback 去留另歸 C 類 finder dedup（FI handback 已標）。
# 回 { "team_id": int, "outpost_pos": Vector2i } 或空 dict 表無
# ★★★god-view 真違規④修法（2026-09-02）：baseline :76 的 inline 註解【自己承認】是待修的 leak
#   （"CANDIDATE-LEAK: partner discovered 但 outpost pos 讀 live(半漏,待 R²+follow-up)"）
#   ⇒ ★★★「標記存在 ≠ 判過合法」——它從來不是核可，是「看過、知道有問題、先放著」。
# ★修法照 A#27 Fix B 的同一個形狀（★不發明新的）：★★換【列舉起點】不是換欄位
#   ①候選母體：`team_discovered` → `BeliefSystem.known_targets`（我知道的東西）
#   ②outpost 位置：★不再掃 `state.world.tiles` 全圖，改掃 `state.team_tile_known`（belief tile store）
#   ⇒ ★而 harvest 要先跑，否則 store 恆空、恆回 {} ＝【假關閉】（看起來像修好了）
func _find_trade_partner(state: WorldState, trader: TeamData) -> Dictionary:
    BeliefSystem.harvest_tile_known(state, trader)
    var _known_tiles: Dictionary = state.team_tile_known.get(trader.team_id, {})
    for tid in BeliefSystem.known_targets(state, trader.team_id):
        if tid == trader.team_id: continue
        var t: TeamData = state.teams.get(tid)
        if t == null: continue
        if t.faction_id != -1 and t.faction_id == trader.faction_id: continue
        # W2: 對方有 outpost = 可交易（move_target 指 outpost tile，採購也可，不需對方有貨）
        # ★只掃【我知道的 tile】—— 不知道的據點對我不存在
        for tile_id in _known_tiles:
            var tile: HexTileData = state.world.tiles.get(tile_id)
            if tile == null: continue
            if tile.outpost_owner != tid: continue
            # W2 修正：tile 上要有居民團（村長）才派 — trader 到了才有人成交
            if not _tile_has_resident(state, tile): continue
            return { "team_id": tid, "outpost_pos": tile.tile_pos }
    if Probe.enabled: Probe.bump("trade.partner_none")
    return {}

func _tile_has_resident(state: WorldState, tile: HexTileData) -> bool:
    for rid in state.teams:
        var r: TeamData = state.teams[rid]
        if r.tile_pos != tile.tile_pos: continue
        if "生產" in r.tags: return true
    return false
