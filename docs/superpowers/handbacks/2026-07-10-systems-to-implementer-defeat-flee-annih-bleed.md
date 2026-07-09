---
from: systems
to: implementer
status: consumed
topic: 敗北逃 殲滅流血 de-patch——傷亡分數累積器（開 mortal-zone 流血→殲滅稀>0）→ 重跑定向床+organic
---

# 實作工單：殲滅流血 de-patch（傷亡分數累積器）

接 worktree `feat/defeat-flee`（@84b9d66，rev2 逃/俘已驗）。spec 新段 `§D4`（`specs/2026-07-09-defeat-model-flee-before-annihilation.md`）。

## 根因（measurer 挖，非猜）
`_resolve_combat_round`（`npc_combat_system.gd:228-229`）：`loss=int(round(eff*str_share*ROUND_CASUALTY_RATE(0.1)))`。絕境隊 eff∈{1,2,3} → 積 ≤`3×1.0×0.1=0.3<0.5` → **恆捨入 0** → mortal zone 零流血 → 殲滅結構不可能（720 場/n_high=80 全 0）。補丁閘型病。

## 改什麼（de-patch = 分數累積器，非機率化捨入）
**1. `start_combat` track init**（`:108-109`）：兩 track dict 各加 `"cas_carry": 0.0`。
```gdscript
_combat_track[atk_id] = {"round": 0, "pop_start": maxi(atk.population - atk.wounded, 1), "cas_carry": 0.0}
_combat_track[def_id] = {"round": 0, "pop_start": maxi(def.population - def.wounded, 1), "cas_carry": 0.0}
```
**2. `_resolve_combat_round` 傷亡段重構**（`:228-244` 整段換）：算 real-valued 傷亡、**flanking 套 real 上（不先 int 截斷）**、經累積器 floor：
```gdscript
	var real_a: float = float(eff_a) * str_b / total * ROUND_CASUALTY_RATE
	var real_b: float = float(eff_b) * str_a / total * ROUND_CASUALTY_RATE
	if eff_a >= eff_b * 3:
		var tactics_b: float = 0.0
		var leader_b: PersonData = state.persons.get(b.leader_id)
		if leader_b != null:
			tactics_b = float(leader_b.skills.get("戰術", 0.0))
		real_b *= (FLANKING_MULT - tactics_b * 0.3)
	if eff_b >= eff_a * 3:
		var tactics_a: float = 0.0
		var leader_a: PersonData = state.persons.get(a.leader_id)
		if leader_a != null:
			tactics_a = float(leader_a.skills.get("戰術", 0.0))
		real_a *= (FLANKING_MULT - tactics_a * 0.3)
	# de-patch：分數傷亡累積器——sub-1.0 傷亡不再 int(round) 截斷成 0（絕境小 pop 恆 0.3<0.5→永不流血→殲滅不可能）。
	# 跨 round carry 分數餘量，floor 取整、留餘量。零新增 randf → seeded determinism 保。
	var loss_a: int = _accum_casualty(id_a, real_a)
	var loss_b: int = _accum_casualty(id_b, real_b)
```
**3. 加 helper**（`_resolve_combat_round` 附近）：
```gdscript
# 分數傷亡累積器（de-patch §D4）：real 傷亡跨 round 累加，floor 取整、餘量留 track。
func _accum_casualty(id: int, real_loss: float) -> int:
	if not _combat_track.has(id):
		return maxi(int(round(real_loss)), 0)   # track 缺（防呆）→ 舊行為
	var carry: float = float(_combat_track[id].get("cas_carry", 0.0)) + maxf(real_loss, 0.0)
	var n: int = int(carry)   # floor（carry≥0）
	_combat_track[id]["cas_carry"] = carry - float(n)
	return n
```

## TDD / 驗（重跑，數字給 measurer 不自判定案）
- `--import`/multi-sanity(coin_eq/invariant=0)/constitution 綠。
- 定向 exercise 床（measurer 那把）：high-courage×被圍格 **annih>0 且非全殺**（flee/rout 仍主端）。
- organic full_probe 3 seed：`end_annihilation` 稀但>0、逃/俘配比不退化、大隊≈baseline。
- determinism：同 seed 兩跑逐事件一致（累積器無 randf，必 PASS）。

## 完後
handback **to:measurer**（重跑定向床+organic 出殲滅端數字→ measurer to:blueprint 判稀度定案）。**若 annih over-fire（非稀）** → 標明 to:systems。
