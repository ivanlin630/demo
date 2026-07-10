---
from: systems
to: implementer
status: open
topic: [S1 rev3] pursuit 改絕對 straggler-kill——棄 pop-%/累積器，殘忍scaled小整數
---

# 工單：S1 pursuit rev3（絕對 straggler-kill）

blueprint 停機制修補（`blueprint-to-systems-s1-pursuit-absolute-model`）：rev1(截斷)→0、rev2(累積器)→0 兩次零效。真根=`5%×小pop` 本質恆~0（organic 全小隊）、pop-% 錯模型。**改絕對小整數**。

## 改（spec `specs/2026-07-10-combat-into-engine.md §S1 rev3`，取代 rev1/rev2）
`_apply_pursuit`（`npc_combat_system.gd:544`）：**棄 `int(pop*rate*factor)` 和 `_pursuit_carry` 累積器**，改絕對 straggler-kill。
```gdscript
# 新常數（TEST VALUE，measurer 校準）
const PURSUIT_CRUELTY_K: float = 2.0
const PURSUIT_GREED_K:   float = 0.8
const PURSUIT_KILL_CAP:  int   = 3
# _apply_pursuit 內（reachability gate winner.pop>=loser.pop*2 保留不動）：
var w_leader: PersonData = state.persons.get(winner.leader_id)
var straggler_kill: int = 0
if w_leader != null:
	var cruelty: float = float(w_leader.values.get("殘忍", 0.5))
	var greed: float   = float(w_leader.values.get("貪婪", 0.5))
	straggler_kill = clampi(int(round(cruelty * PURSUIT_CRUELTY_K + greed * PURSUIT_GREED_K)), 0, PURSUIT_KILL_CAP)
var pursuit_loss: int = mini(straggler_kill, loser.population)
if pursuit_loss > 0:
	_apply_casualties(state, loser_id, pursuit_loss)
	if Probe.enabled:
		Probe.bump("pursuit.n"); Probe.add_amount("pursuit.loss_sum", float(pursuit_loss))
		Probe.add_amount("pursuit.cruelty_sum", float(w_leader.values.get("殘忍", 0.5)) if w_leader else 0.5)
		Probe.add_amount("pursuit.greed_sum", float(w_leader.values.get("貪婪", 0.5)) if w_leader else 0.5)
```
- 量級：慈悲→0、中性→1、軍閥→3（CAP）。scale 無關（小隊也見血）、bounded、人格 gated。
- **★`_pursuit_carry` 撤**（若 rev2 已寫進 worktree→移除，絕對整數無跨事件狀態=無 erase 顧慮）。
- **★`_cas_carry`（§D4）erase 債仍要補**（見 `combat-s1-erase-amend` 工單，那個獨立仍有效——`_cas_carry` 是真累積器需顯式 erase）。

## gate
- `--import`/multi-sanity/constitution 綠、determinism（無 randf）。
- handback **to:measurer**：`pursuit.loss_sum>0`、放血集中高殘忍 pursuer、三端 delta≤噪音（絕對小整數不打亂逃83%主端）、無暴漲。
- **merge 閘=reviewer② 對實際 diff CLEAN + measurer 三端（blueprint 判「軍閥見血+逃為主+人格集中」達標）**。
