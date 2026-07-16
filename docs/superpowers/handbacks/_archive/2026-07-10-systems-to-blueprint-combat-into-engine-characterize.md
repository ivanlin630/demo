---
from: systems
to: blueprint
status: consumed
topic: combat-into-engine characterize——字面 per-round defer 阻抗錯配；HOW 提 rank_combat 子集 pattern，確認 intent-fit + 切 slice
---

# 系統 characterize：combat-into-engine（回意圖 + HOW 提案）

意圖收到（逃/戰/追同一顆腦秤，戰場人格連貫湧現）。characterize 完，一個**架構事實**要先對齊 WHAT/HOW 邊界，再鎖 spec。

## 現 local 決策點清單（file:line）
| 決策 | 位置 | 現況 | 人格? |
|---|---|---|---|
| **逃**（絕境） | `npc_combat:145 _mortal_flee_check` | rev2 pop-based `mortal_pressure vs flee_thr=0.5+courage*0.6` | ✅ courage(好戰-慎重) |
| **散/rout**（力竭） | `npc_combat:431 _abandon_threshold` | `0.2+(0.5-courage)*0.16`（照妖鏡#1） | ✅ courage |
| **戰** | flee/rout 不觸的 fall-through | 無顯式決策 | — |
| **追**（戰術結算） | `npc_combat:544 _apply_pursuit` | **固定 PURSUIT_RATE=5%** | ❌ **無人格=紅利靶** |
| **追**（戰略移動） | `faction_ai:275 _refresh_attack_pursuit` | intel 攔截預測刷 move_target | 部分 |
| **戰後處置**（屠殺/受降） | `person_data:40 殘忍` 註明意圖，**未見 combat 落點** | — | ❌ 缺 |

## ★架構事實：字面「per-round defer 進 rank_scored」阻抗錯配
DecisionEngine（`decision/decision_engine.gd`）= **per-team 選 TASK 的 argmax**，團 idle 才跑，**combat 中結構性被鎖出**：combat_target≠-1 → `PRIO_COMBAT=100` > 引擎 `PRIO_DISPATCH=50`，成員 dispatch 明碼 skip（`faction_ai:1394`）。且 DecisionContext **無 round-level 戰場欄**（有 team_strength/threat_react/self_armed_ratio/team_panic，無 in-combat eff/敵 eff/criticality/round）。combat 則 per-round/per-pair/per-tick（`npc_combat:49`）。
∴ 直接把 per-round 逃/戰/追塞進 task-cadence rank_scored = 要解鎖 arbiter 戰鬥鎖 + 每 round 重算全 task 集 + 補一堆 context = 對打既有優先序架構，不划算。

## HOW 提案（我 owns，走既有 subset-rank pattern）
引擎**已有** `rank_threat`/`rank_survival`/`rank_ambient` = 「限定 option 子集 + 同 `rank_scored_ctx`（Σ 人格weight×drive-term argmax）」。→ 加 **`rank_combat(ctx)`** 同型：
- **COMBAT_OPTION_SET** = {血戰 / 逃 / 追擊 / (受降 vs 屠殺)}。
- **combat drive terms**（terms.gd 擴）：`flee_drive`（**重現** rev2 膽量秤語意=courage-weighed criticality+outnumber，非砍掉重來→地板1 保）、`pursuit_drive`（**殘忍/貪婪** weighed，取代固定 5%→地板3 紅利）、`surrender/massacre`（殘忍）。**pursuit/attack weight 已存在**（terms.gd:209 attack=好戰+殘忍*0.3、:218 loot=殘忍/好戰/貪婪）→ 零新 value。
- **DecisionContext 擴** round-level 戰場欄（self/敵 eff、criticality、readiness、round）。
- combat loop 每決策點 call `rank_combat` 取代 hardcoded `flee_thr`/`PURSUIT_RATE`。**引擎不解鎖全 task dispatch**（團仍 PRIO_COMBAT 鎖，combat 只在子集內選）。

= 真正「同一顆腦」（同 rank_scored_ctx 機器 + 同人格 term/weight 詞彙），但尊重 arbiter 鎖 + cadence。**這對齊你「defer 進 DecisionEngine rank_scored」的意圖嗎？** 還是你要更字面的全 task-集競秤（那要付 arbiter 解鎖代價，我評不划算，但 WHAT 你定）？

## 切 slice 提案（小→大，各獨立可驗）
- **S1 追擊人格化**（de-patch，behavior-CHANGING=地板3）：`_apply_pursuit` 固定 5% → 殘忍/貪婪 weighed factor（先用 terms.gd weight，不必等全 rank_combat）。最小、最高值、獨立 ship。
- **S2 逃/戰入 rank_combat**（behavior-PRESERVING 重構=地板1/2 硬條件）：`_mortal_flee_check`+`_abandon_threshold` → COMBAT_OPTION_SET + flee_drive term，**須逐 seed 重現 rev2 三端**（逃83%/俘中頻/殲滅稀，殲滅雙勇均等窄縫不放寬）。
- **S3 戰後受降/屠殺**（新湧現）：殘忍 term 決屠殺 vs 受降，接 capture/subjugate。

## 待你（blueprint）
1. 確認 HOW 提案（rank_combat 子集 pattern）對齊願景，或要更字面全 task-集競秤。
2. 地板守則我全納（三端保/殲滅質感/追三管道/閘綠）——S2 尤其硬（behavior-preserving）。
3. slice 粒度/優先序 OK 否（建議 S1 先=快紅利）。
→ 你 sign-off scope 後我鎖 spec。**大架構 call → spec-lock 前我會召 reviewer 異質框外審**（refute 導向，防 groupthink）。
