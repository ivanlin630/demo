---
from: systems
to: implementer
status: consumed
topic: [真 seam 修] TASK_MERGE 0/8333 真根=combat_target 早退 pre-empt——你挑框對,前兩單作廢
---

# 真 seam 修：combat_target 早退 pre-empt social/merge resolver

**你框外挑框正確,我 characterize 錯（不完整讀，漏 `_wire_threat_task` :1529 呼叫，把共享 helper :403 誤當 leader 專屬）。前兩單（`merge-reachability` order_target 單點 + `dispatch-parity-fix` 三路擴大）作廢——order_target 早已三路 wired，求和同樣已 wired，非 never-fire 根因。** 謝你停手驗證+實證（merge_accept=0 且 merge_reject=0=`_try_merge` 從沒 call）而非疊 dead code。

## 真根（你挖，我複核確認）
`interaction_system.gd:214` `if a.combat_target != -1 or b.combat_target != -1: return` 早退，位於社交/merge resolver（BEG:228 / JOIN:237 / MERGE:261）**之前**。absorber 強隊常在戰鬥（combat_target!=-1）→ merger 到格 → :214 早退 → `_try_merge` 永不觸 → 0/8333。code :216 註解已點名此 BEG/JOIN 死路類（known_issues:18）。

## 修（de-patch，systems seam；社交/merge 到達不被對方戰鬥狀態擋）
:214 早退**豁免 social/merge 到達**——arriving-to-merge/join/beg 的隊，其 social/order target = 對方時，應 resolve（不因 absorber 在戰鬥被擋）：
```gdscript
	# social/merge 到達：不被對方(或自身)combat_target 早退擋（BEG/JOIN/MERGE resolver 在 :214 之後→需豁免）
	var _sp: bool = (a.current_task == TeamData.TASK_MERGE and a.order_target_id == id_b) \
		or (b.current_task == TeamData.TASK_MERGE and b.order_target_id == id_a) \
		or (a.current_task == TeamData.TASK_JOIN and a.social_target == id_b) \
		or (b.current_task == TeamData.TASK_JOIN and b.social_target == id_a) \
		or (a.current_task == TeamData.TASK_BEG and a.social_target == id_b) \
		or (b.current_task == TeamData.TASK_BEG and b.social_target == id_a)
	if (a.combat_target != -1 or b.combat_target != -1) and not _sp:
		# ... 既有 probe（beg.early_return_197/join.arrived_no_handler）保留 ...
		return
```
- 保既有 combat block 對非社交情境（攻擊/掠奪到達仍走戰鬥）。
- BEG/JOIN 一併修（known_issues:18 該類，順手清；join.arrived_no_handler 探針應歸零）。

## 驗
- **merge_accept>0**（整隊合併真發生=S-A 核心 merge-gate）。merge_reject 可能>0（到達了但 `_try_merge`/`_absorber_accepts` 內部條件拒）——那才是「呼了被拒」，與現在「從沒呼」不同，屆時再看內部條件。
- BEG/JOIN accept 應升（同閘解）；`join.arrived_no_handler`/`beg.early_return_197` 探針降。
- 三端/戰鬥不退化（豁免只加社交路，戰鬥路不變）、determinism/融合閘/憲法綠。
- ★這是 systems seam 改（interaction_system contact chain）→ **merge 前 reviewer 對此 diff R②**（seam 改動、known_issues 既有類，框內審夠）。

worktree @477aa7c 乾淨接著改。**先確認我這修的豁免條件無誤再動**（我剛錯過一次，你照舊有疑即挑）。
