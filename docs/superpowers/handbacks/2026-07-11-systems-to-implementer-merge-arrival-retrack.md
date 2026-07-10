---
from: systems
to: implementer
status: consumed
topic: [seam 修 A] MERGE/JOIN 到達重追蹤——比照 ESCORT 每 tick refresh move_target(治靜態快照追不上移動 absorber)
---

# seam 修 A：MERGE/JOIN 到達重追蹤（治 pair_seen=0）

漏斗+我複核確認（movement `:42-49` ESCORT-only re-track、MERGE 用靜態快照）：**TASK_MERGE 到達硬牆真根 = movement re-track 只 TASK_ESCORT，MERGE/JOIN 用 dispatch 時靜態 move_target → absorber（活躍大隊）移走 → merger 走空 tile → pair_seen=0**。你漏斗證得漂亮，方向據 pair_seen=0（到達層）定，非 resolver 層。

## 改（movement re-track loop `:37-49` 擴 MERGE+JOIN，鏡射 ESCORT）
```gdscript
	for tid in team_ids:
		if not state.teams.has(tid): continue
		var team: TeamData = state.teams[tid]
		# 追蹤：ESCORT/MERGE(order_target)/JOIN(social_target) 每 tick 追目標現位（靜態快照追不上活躍大隊）
		var tgt_id: int = -1
		if team.current_task == TeamData.TASK_ESCORT or team.current_task == TeamData.TASK_MERGE:
			tgt_id = team.order_target_id
		elif team.current_task == TeamData.TASK_JOIN:
			tgt_id = team.social_target
		if tgt_id == -1: continue
		var target: TeamData = state.teams.get(tgt_id)
		if target == null:
			TaskArbiter.release(team)   # 目標消失 → 任務結束
			team.order_target_id = -1
		else:
			team.move_target = target.tile_pos
```
- ESCORT 行為不變（併入同 loop）。MERGE/JOIN 現追移動 absorber/host。determinism 保（純追位、無 randf）。
- BEG 暫不納（短程 aid，先看 MERGE/JOIN；需要再擴）。

## 驗（漏斗逐站，你探針留著）
- **`merge.pair_seen` 0→>0**（TASK_MERGE 隊真到達 absorber）→ resolver/`_try_merge` 觸 → **`merge_accept>0`**（整隊合併真發生=S-A 核心）。
- JOIN 到達應更穩（join.resolve 升）。
- 三端/戰鬥不退化、determinism/融合閘/憲法綠。
- 若 **pair_seen>0 但 accept 仍低** → 看 `_try_merge`/`_absorber_accepts` 內部（那才是「到了被拒」）或 churn(B)，回報。

## 併走
- 這是 movement seam 改（systems owner）→ merge 前 reviewer 對 diff R②（框內）。
- **C（priority 張力 29 set_fail：食壓驅併 vs survival-sticky 互斥）我另 flag blueprint（consolidate 語意=絕境併 vs 預防性併，可能調 priority 或食壓窗）**——非本修，A 先治 24 set_ok 的到達。
- worktree @f7f7d6d 接著改（combat 豁免+漏斗探針保留）。
