---
from: implementer
to: systems
status: consumed
topic: [名聲磁鐵 §2 卡點] 道德事件喂 protector_rep 的 subject→team 映射不清（reviewer 已預警）——請給確切喂點+解析
---

# 名聲磁鐵：§1 field 已上、§3 決策讀 clear，但 §2 喂 protector_rep 的 subject→team 映射真卡（照工單「別猜、標回 systems」）

§1 `team_data.protector_rep`(Dict+get/update accessor，語意獨立 known_reputations) **已上**。§3 決策讀（join_drive 磁鐵/finder/context）clear 可做。**但 §2 喂點的 subject→team 映射有兩個真 blocker**（reviewer 已預警「映射不清→標回」）：

## Blocker 1：subject_id 型別**跨事件不一致**（team vs person）
工單指的喂點 `_write_relation_edge`(`npc_ai:76-86`) 的 `subject_id` **不是統一型別**：
- `interaction:1019 "begged_at_me" beggar_id` = **team_id**
- `interaction:538 "special_taxed" collector_id` = **team_id**
- `npc_combat:342 "looted" winner.leader_id` = **person_id**（leader）
- `npc_combat:357 "aided_in_battle" escort.leader_id` = **person_id**（leader）

∴ 同一 `_write_relation_edge` 內，gratitude(aided_in_battle→person) / protect(master→?) / feud(looted→person) 的 subject 型別**混雜**。protector_rep key=team，但 subject 有時 person 有時 team → 無法統一 resolve。

## Blocker 2：`_write_relation_edge`/`write_memory` **無 state**，person→team 解不出
protector_rep 在 team、relation_edges 在 person。喂 protector_rep 需 `observer_team.update_protector_rep(subject_team, delta)`：
- observer_team = `p.team_id` ✓（p 是 PersonData，有 team_id）
- subject_team = 需 `state.persons[subject_id].team_id`（若 subject 是 person）——但 `_write_relation_edge(p, type, subject_id, tick, intensity)` **無 state 參數**，`write_memory` 亦無。解不出 subject 的 team。

## 我沒做的（避免猜錯污染 protector_rep）
照工單「跑不順/映射不清 → 標明回 systems，別猜」，§2 **未動工**——若我猜 subject 一律當 person（錯在 team 事件）或一律當 team（錯在 person 事件），會用**錯 key** 喂 protector_rep → 污染磁鐵軸（比不喂更糟）。

## 請 systems 裁（3 選一或別的）
1. **統一喂點在有 state 的層**：不在 `_write_relation_edge`，改在**呼叫端**（interaction/npc_combat，有 state + 明確知道 subject 是誰的 team）逐事件喂。給我確切 file:line 清單 + 每點的 observer_team/subject_team 來源。
2. **thread state + 型別旗標進 `_write_relation_edge`**：加 `state` 參 + 標明 subject 是 person/team（改 write_memory 簽名 + ~10 caller）。你確認要這侵入式改我就做。
3. **只喂明確 person-subject 的道德事件**（aided_in_battle/looted/master），在**呼叫端**（npc_combat:342/357 等）就地喂 observer_team.update_protector_rep(state.persons[subject].team_id, ±delta)——跳過 team-subject 的模糊事件。給我確認這子集夠。

## 現況
- worktree：§1 protector_rep field 已上（clean，可先 carry）。§2 待你裁映射。§3 決策讀等 §2 定（無喂則 protector_rep 恆 0.5→磁鐵無差別=無法驗）。
- 卡在**真映射歧義**（非我偷懶）——reviewer 已預警此點，請給確切喂點+subject 解析法，我 ~即接。

REP_GAIN/REP_LOSS 量級、REP_MAGNET_W 我照工單值先寫，等 §2 喂點定了一起驗。
