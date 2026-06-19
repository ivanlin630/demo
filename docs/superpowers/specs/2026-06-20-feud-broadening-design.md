# A 類 feud 放寬 — HOW design

> 來源：藍圖 ruling `2026-06-20-blueprint-to-systems-feud-scenarios-ruling`（A 類）。
> feel/WHAT 藍圖給；觸發集 / severity 表 / gate 公式 / 傳播範圍 = 系統 HOW + TEST VALUE。
> 承 G2 §5「血仇傳播」真正做實。與 #0b 並行（不同檔，無共用單例）。

## 病（現模型太窄）

feud 邊唯一源 = `NpcAiSystem._write_relation_edge`（type ∈ {betrayal, looted, extorted} → `add_edge("feud", …, intensity, …)`，**無條件、固定 intensity**）。觸發只有 `npc_combat:236`（敗方**倖存**被 loot）。後果：
- 滅團 → 倖存者 0 → feud 隨死者消（不擴散）。
- 不決無 loot → 無 feud。
- 每場小衝突都記同強度仇 = 噪音風險（雖現在量太少反而 feud≈0）。

## HOW 決定（三件，集中一個 chokepoint）

### 1. grievance → 個性 gate 的單一形成點
新增 `NpcAiSystem.form_feud(victim, perp_id, severity, tick) -> bool`：
- `factor`（記恨傾向）讀受害方個性：**義氣**（守義/不忘）+ **好戰**（好鬥記仇）拉高；兩者低 = 寬厚放下。

```gdscript
# 記恨傾向 0.2~1.3：義氣/好戰 高 → 記恨；皆低 → 放下。TEST VALUE。
const FEUD_BASE_FACTOR := 0.2
const FEUD_HONOR_W := 0.7        # 義氣權重
const FEUD_BELLIGERENCE_W := 0.4 # 好戰權重
const FEUD_MIN := 0.30           # gate：gated intensity < 此 → 不結仇（公平交手/寬厚/例行劫掠）

static func form_feud(victim: PersonData, perp_id: int, severity: float, tick: int) -> bool:
	if victim == null or perp_id == -1 or victim.id == perp_id:
		return false
	var honor: float = float(victim.values.get("義氣", 0.5))
	var bell: float  = float(victim.values.get("好戰", 0.5))
	var factor: float = FEUD_BASE_FACTOR + honor * FEUD_HONOR_W + bell * FEUD_BELLIGERENCE_W
	var intensity: float = clampf(severity * factor, 0.0, 1.0)
	if intensity < FEUD_MIN:
		return false
	RelationGraph.add_edge(victim.relation_edges, "feud", perp_id, intensity, tick)
	NpcAiSystem._activate_goal(victim, "revenge", perp_id)  # 同 _trigger_goals revenge
	Probe.bump("g2.feud_formed")
	return true
```

> `add_edge` 已 `maxf` 去重升強（同仇人多次侵害取最深）。`FEUD_MIN` gate 即「公平交手雙方全身而退可不結仇」+「寬厚放下」+「例行劫掠淺仇不跨閾」。

### 2. severity 按侵害種類（屠族 > 背叛 > 吞併 > 劫掠）
```gdscript
const FEUD_SEVERITY := {        # TEST VALUE
	"massacre":   1.0,   # 屠族（你方被滅）
	"betrayal":   0.8,   # 背叛
	"subjugated": 0.5,   # 吞併臣服
	"looted":     0.35,  # 劫掠
	"extorted":   0.30,  # 勒索
}
```
gate 例：例行劫掠 0.35 × 寬厚 factor ~0.45 = 0.16 < 0.30 → 不結仇（噪音免）。屠族 1.0 × 義氣高 factor ~1.0 = 1.0 → 深仇。

### 3. 滅族擴散 = 事件當下傳同 faction 餘部（非血親）
新增 `NpcAiSystem.spread_feud(state, victim_team, perp_id, severity, tick)`：在**侵害事件當下**（erase 前），對 `victim_team.faction_id` 的其餘 member team（≠ 受害團、≠ 加害方團）leader 形成 feud，severity × `FEUD_SPREAD_FACTOR`（餘部記恨但弱於親歷）。

```gdscript
const FEUD_SPREAD_FACTOR := 0.6  # TEST VALUE：餘部繼承比親歷弱

static func spread_feud(state: WorldState, victim_team: TeamData, perp_id: int, severity: float, tick: int) -> void:
	var fid: int = victim_team.faction_id
	if fid == -1 or not state.factions.has(fid):
		return
	var perp: PersonData = state.persons.get(perp_id)
	var perp_team: int = perp.team_id if perp else -1
	for tid in state.factions[fid].member_team_ids:
		if tid == victim_team.team_id or tid == perp_team:
			continue
		var t: TeamData = state.teams.get(tid)
		if t == null:
			continue
		form_feud(state.persons.get(t.leader_id), perp_id, severity * FEUD_SPREAD_FACTOR, tick)
```

> 血親(parent/kin)傳播暫不做（G2 無血緣邊，待 ④Trait/家族樹）。獨立團（faction_id=-1）無餘部 = 仇隨滅消（可接受，待家族樹）。

## 接線（call sites）

| 事件 | 檔:func | 改 |
|---|---|---|
| 劫掠倖存 | `npc_ai_system._write_relation_edge`（looted/extorted/betrayal 分支） | 改走 `form_feud(p, subject_id, FEUD_SEVERITY[type], tick)` 取代無條件 `add_edge`（gate 套既有 3 觸發） |
| 戰敗（含滅團） | `npc_combat._end_combat`（:232 loot 迴圈後） | 倖存者 loop 已寫 looted memory→form_feud（經 §1）；**新增** `NpcAiSystem.spread_feud(state, loser, winner.leader_id, FEUD_SEVERITY["massacre" if 滅團 else "looted"], tick)` 傳敗方 faction 餘部 |
| 吞併臣服 | `npc_combat._try_subjugate`（:510 set_team_faction 後） | `form_feud(loser_leader, winner.leader_id, FEUD_SEVERITY["subjugated"], tick)` + `spread_feud(state, loser, winner.leader_id, "subjugated", tick)`（注意：loser 已入勝方 faction → spread 前先抓 old faction-mates，或對 loser 舊餘部；見 plan 註） |
| 屠村 | `encounter._massacre_residents`（:1451 erase_team 前） | `NpcAiSystem.spread_feud(state, resident, attacker.leader_id, FEUD_SEVERITY["massacre"], tick)` |

> `_write_relation_edge` 現是 instance method 改靜態 `form_feud` 共用：把 gate 邏輯抽 static，instance 分支轉呼。`_activate_goal` 已存在（轉 static 或 instance helper 包）。

## 邊界 / 守恆
- **只改關係邊 / goals**，不碰資源 / coin / population / 守恆。coin_eq 無關。
- 複用 RelationGraph（feud 型別已存在）、既有 memory、Probe.bump。零新資料結構。
- `vendetta_target`（脫軌 reader）不改 → feud 變多自然餵更多脫軌（G2d），無需改 reader。
- subjugate 順序坑：`set_team_faction` 把 loser 移進勝方 faction → spread 要抓 loser **原** faction 餘部 → 在 set_team_faction **前**呼 spread（見 plan）。

## 驗收
- gate 單測：高義氣受害 + massacre severity → form_feud true；低義氣低好戰 + looted severity → false（放下）。
- 屠村單測：resident 有 faction 餘部 → 餘部 leader 得 feud 邊（intensity = massacre×factor×spread）。
- subjugate 單測：loser leader 得 feud + 原 faction 餘部得弱 feud。
- headless 全綠、coin_eq=0、InvariantAudit 0。
- （重量）world_sim 2 年 `g2.feud_formed` 顯著 > 前次（≈0）；脫軌（vendetta）連帶上升；但非全民世仇（gate 擋住例行劫掠）。
