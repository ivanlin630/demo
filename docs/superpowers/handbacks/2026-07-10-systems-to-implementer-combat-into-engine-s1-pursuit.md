---
from: systems
to: implementer
status: consumed
topic: combat-into-engine S1——追擊放血人格化（de-patch 固定 5%→殘忍/貪婪 秤）→ measurer 量三端不打亂
---

# 實作工單：combat-into-engine S1 追擊放血人格化

spec：`docs/superpowers/specs/2026-07-10-combat-into-engine.md` §S1（arc 已 blueprint scope signoff）。
worktree：開新 `feat/combat-s1-pursuit`（基於最新 main=`bacc8f7` 之後，先確認 `git -C <main> log`）。★spawn 前 main 已 push？否則 stale base（[[feedback_worktree_stale_base]]）——**main 尚未 push origin**（見下），worktree 用 local main。

## 改什麼（1 函數 + 4 常數 + 探針）
`npc_combat_system.gd:544 _apply_pursuit`——固定 `PURSUIT_RATE(0.05)` 放血率改隨勝方領袖 **殘忍/貪婪** 秤。中性(0.5/0.5)→factor≈1.0 **保 5% mean baseline**（純人格重分配非全面膨脹）。
1. 4 新常數（TEST VALUE）：`PURSUIT_CRUELTY_W=1.2`/`PURSUIT_GREED_W=0.6`/`PURSUIT_FACTOR_MIN=0.0`/`PURSUIT_FACTOR_MAX=2.5`。
2. `_apply_pursuit` 內 `pursuit_loss` 算法（`winner.pop>=loser.pop*2` reachability gate **保留不動**）：
```gdscript
	var w_leader: PersonData = state.persons.get(winner.leader_id)
	var factor: float = 1.0
	if w_leader != null:
		var cruelty: float = float(w_leader.values.get("殘忍", 0.5))
		var greed: float   = float(w_leader.values.get("貪婪", 0.5))
		factor = clampf(1.0 + (cruelty - 0.5) * PURSUIT_CRUELTY_W + (greed - 0.5) * PURSUIT_GREED_W, PURSUIT_FACTOR_MIN, PURSUIT_FACTOR_MAX)
	var pursuit_loss: int = maxi(int(float(loser.population) * PURSUIT_RATE * factor), 0)
	# 探針：追擊放血人格集中度（勝方領袖殘忍/貪婪加權）
	if Probe.enabled:
		Probe.bump("pursuit.n")
		Probe.add_amount("pursuit.loss_sum", float(pursuit_loss))
		if w_leader != null:
			Probe.add_amount("pursuit.cruelty_sum", float(w_leader.values.get("殘忍", 0.5)))
			Probe.add_amount("pursuit.greed_sum", float(w_leader.values.get("貪婪", 0.5)))
```
3. `warring_harness.gd` PROBE_KEYS +`pursuit.n`；AMOUNT_KEYS +`pursuit.loss_sum`/`pursuit.cruelty_sum`/`pursuit.greed_sum`。

## ★機制事實（別誤判驗收）
`_apply_pursuit` 在 `_end_combat`/`_force_retreat` 內 = **combat 結束後放血**，**不重入殲滅檢查**。∴ S1 **不直接動 `end_annihilation`**（三端在 combat 內決）。S1 動的是放血量分布 + 潰逃隊後續 `extinct.*`/attrition。

## 閘 + handback
- `--import`/multi-sanity(coin_eq/invariant=0)/constitution 綠。determinism：pursuit_loss 確定性（無新 randf），同 seed 兩跑一致。
- handback **to:measurer**：跑 organic full_probe（大窗，樣本夠）量：①放血人格分配（cruelty_sum/n 高→factor>1）②**三端不打亂**（end_annihilation/mortal_flee/capture ≈ baseline，預期 annih 幾乎不動）③extinct/attrition 分布（殘忍窮追是否升）。→ measurer to:blueprint 判（殘忍軍閥暴虐湧現 vs 打亂三端）。
- **若三端被打亂** → 標明 to:systems（調 PURSUIT_*_W 或 FACTOR_MAX 上限）。
