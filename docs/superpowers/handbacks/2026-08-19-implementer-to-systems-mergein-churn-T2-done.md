---
from: implementer
to: systems
status: consumed
topic: "[T2 done·mergein churn 根修·branch feat/mergein-churn-fix @b107d3b2·base main b223a862·三件定案全照做(JOIN timeout 進既有:838 單源塊/撲空 abort 讀自己 belief/arrival-fail 復用 join_rejected rejection-learning 防換皮)+proximity 不加·TDD 7/7 PASS·constitution PASS 77·determinism byte-identical ×2 fp=86c2fe82(★與 base main 同 fp=a4 warring 1000t 內 JOIN arrival-fail 未觸發、churn dormant 於該窗非無效果)·headless 只見已知 pre-existing FAIL(known_issues:437 ①②⑤⑦)、base 對照跑被環境 reap 未完成→measurer 補 0-new·★churn-rich 長局 re-measure(release 後不重演/team 不暴增/perf 回正)=measurer]"
branch: feat/mergein-churn-fix
commit: b107d3b2
---

# T2 done：committed JOIN 的到達契約（churn arrival-never 止血）

branch `feat/mergein-churn-fix` @ `b107d3b2`（T1 `e1e1940f`/`e1d0c00a` + T2 `b107d3b2`），base main `b223a862`。你的三件定案全照做。

## 做了什麼

| 定案 | 實作 | 位置 |
|---|---|---|
| (1) JOIN timeout **進既有單源塊** | `elif team.current_task == TASK_JOIN` 接在 W2 TRADE 之後、A1a STATION 之前；額度 `JOIN_TIMEOUT(6d) + 殘距×JOIN_TIMEOUT_PER_HEX(12h/hex)`＝鏡射 TRADE 款、TEST VALUE | `faction_ai_system.gd:838` 起（常數 :145-146） |
| (2) 撲空 abort | committed JOIN + 已站上/已清 `move_target` + `BeliefSystem.belief_pos(self, social_target)==(-1,-1)` → release（**讀自己 belief**、非查 host 真位） | 同塊 |
| (3) release 後不重演 | `_release_failed_join`：寫 `join_rejected` memory（**復用** `_resolve_join:1280` 同一機制、零新機制）+ `clear_social_target` + `release` → `decision_context:530 has_acceptable_join_host` 於 cooldown 內不再選此 host | `faction_ai_system.gd:4898` |
| (4) proximity-resolve | **不加**（照你裁定） | — |
| crisis-override | **不動**（你裁定：泛化安全網、與 JOIN timeout 正交） | — |

**★一個實作坑（值得記帳）**：既有 timeout 塊用 `task_priority < PRIO_PLAYER` 當豁免條件，但 **JOIN 走 survival@80 > PLAYER@60** → 用 `<` 整條分支會被跳過（實測 committed JOIN 12 日 age、abort 條件全 true 卻零 fire）。改用 `!= PRIO_PLAYER`（只豁免玩家命令）後正常。TRADE/STATION 因走 @50/@60 所以原寫法沒暴露這個坑。

## 驗證

- **TDD `mergein_join_lifecycle_test.gd` 7/7 PASS**（走 `evaluate_all` 真路徑，非手呼）：
  ① 撲空 abort fire + JOIN 已釋放（task 轉 建設）+ **`join_rejected` memory 已寫** + `social_target` 已清
  ② 追不到的移動 host → `join.timeout` fire
  ③ **不誤傷**：host 靜止可達 → 正常 `join.resolve`、abort/timeout 皆 0
  （測試隊用非深餓糧位＝隔離 crisis-override，讓本契約單獨可驗。）
- **constitution PASS (sites=77, removed=0)**。
- **determinism**：seed1337 warring 1000t **byte-identical ×2** `fp=86c2fe821d61e6cdd016d63c5b5475b0`。零新 randf（`write_memory` 路徑經檢查無 randf/randi）。
- **★fp 誠實說明**：branch fp **與 base main 跑出來完全相同**。原因＝a4 warring 1000t（≈4 天）內 JOIN commit 稀少、arrival-fail 兩出路未觸發 → **churn dormant 於該窗**，不是「修了沒效果」。行為變化要在 churn-rich 長局才現形（見下 measurer 項）。
- **T1 temp trace 已全移**（movement_system / faction_ai / task_arbiter 皆復原）；兩床改讀 production probe（`join.timeout` / `join.abort_ghost` / `join.resolve` / `merge.consolidate_dispatch`）。

## ⚠️ 給 measurer（本 session 環境限制 + gate 歸屬）

1. **headless 0-new**：branch 全跑只出現**已知 pre-existing** 失敗——`FAIL 弱目標未加入攻擊 goal`①、`FAIL Team23 task=建設 order=-1`②（×2）、assert `rung 擴張+武力 未選擴張 intent`⑤、assert `FORCE(任rung)→ambient_train_drive 0.5`⑦（全在 `known_issues.md:437` baseline ①–⑦ 內）。**但 base 對照跑兩次都被環境 reap**（~5300 行處中斷、未跑到 assert 段）→ **0-new 請 measurer 正式判**。
2. **★churn gate（你補的那條）**：`release 後不重演`＝同對隊 `SurvivalMergeIn` 反覆數歸零（非只總數降）+ `join.resolve/commit` 比例回正 + team 不暴增（49→242 病消）+ perf 回正（40-70× 消）→ 需 **churn-rich 長局**（農業b 那種弱隊世界；我這邊 warring 短局 JOIN commit 太稀疏抓不到）。床已備：`scripts/debug/mergein_churn_trace_bed.gd`（env `LW_CONFIG`/`LW_MONTHS`/`PERF_SEED`；**注意 godot-detach 只轉發白名單 env**，`--` user-args 到不了）+ 每 5 日 sidecar 落檔（長跑被 reap 也留 partial）。
3. 兩床用途分工：`mergein_arrival_control_bed.gd`＝只驅動 movement/interaction 的**原病灶對照**（場景 D 仍顯示 arrival-never，證明沒有生命週期塊時的病）；T2 出路由 lifecycle test 驗。

地基 KEEP（resolve 語意/crisis-override/JOIN dispatch 路徑皆未動）。
