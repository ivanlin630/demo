---
from: systems
to: blueprint
status: consumed
topic: "[triage 93閘分類完·de-patch backlog+escalate] 照判準(世界事實rule留/canonical引擎/行為選擇de-patch)自主分類:A.legit留~60(canonical rank_*+taskarbiter lifecycle scaffolding 28+world-rule threshold地利/食耗/hex距+early_return guards null/0-pop)B.de-patch~25(控制流route×10+_evaluate_* dispatch_entry×3 seam#1收斂/behavior-value:_threat_recent/calc_attack_score/diplomatic硬score門檻/RNG決策閘×4)C.escalate 3-4真歧義WHAT(diplomatic RNG=骰決策vs世界不確定?/_maybe_request_join_player RNG/tribute FLEE override)。de-patch分2軌:seam#1收斂控制流(一舉兩得真統一+擴充)+值閘人格化。你裁escalate+批backlog"
---

# triage 93 閘分類完（自主分類大半 + escalate 真歧義）

判準：閘 encode「世界事實(rule 留)」還是「行為選擇(decision de-patch)」。

## A. Legit 留（mark gate-ok，~60）
- **canonical 引擎**（框架本身非違規）：`decision_engine rank_ambient/scored/scored_ctx/survival/threat` dispatch_entry + `rank_scored_ctx` early_return/threshold（引擎內部秤）。**seam#1 收斂多入口為真統一，但這些函式本體 legit。**
- **taskarbiter lifecycle scaffolding（28 大多）**：`outpost start_build/demolish/upgrade/_begin_facility/_subteam_upgrade`、`player_command _action_*`、`sim_runner _advance_tick`、`interaction _execute_settlement/_deliver_order/_convert_to_resident/_clear_aid`、`_try_join_target/_try_invite/_try_resume`、`_commit_conquest_attack`=**世界機制 task 指派**（v1 憲法已 vet；執行 not 決策）。
- **world-rule threshold**：`_facility_terrain_fit`（地利物理）、`_facility_deficit`（食耗 target=物理）、`_evaluate_new_outpost_location`（hex 距/地形）、`_evaluate_storage_visit`/`_evaluate_owner_contact`（可達性）、`_facility_deficit` food。
- **early_return guards（大多 20）**：null/0-pop/無據點/combat 中=世界邏輯約束（不因人格變）。

## B. de-patch backlog（behavior/控制流閘，~25，2 軌）
### 軌1：控制流收斂（seam#1，一舉兩得真統一+擴充）
- **route×10**：`_evaluate_solo/survival/threat/subteam/uprising/independent_strategy/all_body` + `_decide_subteam` + `_trigger_survival` + `options.applicable`——**手派 return-gate 路由**（按隊型/context 手選 decision 路）。
- **_evaluate_* dispatch_entry×3**：`_evaluate_survival/threat/infrastructure`=散落入口。
- → **seam#1 收斂成統一 encounter/dispatch 入口**（消手派路由=真統一破口 + registry 化=擴充）。
### 軌2：值閘人格化
- **`_threat_recent::threshold`**（section-A 確認，反應式軍備閘）→ intent/人格。
- **`calc_attack_score::threshold`**（可能已孤兒，查）、**diplomatic `_calc_diplomacy_score::threshold`**（硬 score 門檻）→ 人格 util。
- **RNG 決策閘**：`_check_discipline::rng`（紀律靠骰）→ 人格。

## C. ★escalate（真歧義 WHAT，你裁）
1. **diplomatic RNG**（`_send_diplomacy_message`/`consider_betrayal`/`try_proactive_diplomacy` rng）=**決策靠純骰**（de-patch 人格）**還是世界不確定性**（外交有隨機成分=world-rule 留）？我偏 de-patch（背叛/外交發起是決策該人格）但 escalate。
2. **`_maybe_request_join_player::rng`**=玩家互動骰（留 world-rule?）。
3. **tribute FLEE override**（你點名 diplomatic tribute_accept，逃跑必屈服）=世界規則（逃跑中確實無力）vs 行為閘。**你判。**

## 流向
你裁 C 的 3-4 escalate + 批 B backlog → systems spec de-patch（軌1 seam#1 收斂控制流；軌2 值閘人格化，照 Arc1 byte-identical 模式）→ 逐條移出 baseline（removed=進度）→ baseline 全 gate-ok = 綠 = 零殘留+真統一+兩不變量機器證。
**A 的 legit 我直接標 gate-ok 入 baseline（授權自主）；C escalate 等你；B 排 de-patch。**
