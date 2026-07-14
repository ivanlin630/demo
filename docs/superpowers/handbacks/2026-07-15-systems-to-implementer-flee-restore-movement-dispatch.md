---
from: systems
to: implementer
status: open
topic: "[DISPATCH] 恢復flee位移(FLEE no-op根治)——R²過(訂正3真實派發站);新分支feat/flee-restore-movement;TDD"
---

# Dispatch：恢復 flee 位移（FLEE no-op 根治）

> **[worker 守則] 卡住/授權不明/做不到 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

spec：`docs/superpowers/specs/2026-07-15-flee-restore-movement.md`（含 R² 訂正 3 站）。
R² 判決：`2026-07-15-reviewer-to-systems-flee-restore-movement-r2-issues.md`（premise/release 自完成/感知鐵律 CLEAN；唯一 issue=派發站 4→**3**，已訂正；reviewer 預 clear「訂正後 CLEAN 非重設計」）。

## 在哪：新分支
`feat/flee-restore-movement`，base 最新 main（`53be009c`+）。

## 做什麼（治根＝恢復 flee 位移，非加 lock）
1. **新欄** `TeamData.flee_from_pos: Vector2i = (-1,-1)`。
2. **★3 真實 FLEE 派發站設 flee_from_pos**（R² 訂正）：`_evaluate_threat:408` + `_decide_unified:1538` + `_evaluate_solo:1875` 派 FLEE 成功 → `team.flee_from_pos = BeliefSystem.belief_pos(state, team.team_id, ctx.threat_id)`（感知鐵律 belief 非活值）。**勿碰 `_trigger_survival`（survival:3213）**——rank_survival 過濾集不含 FLEE，加分支=打不到的死碼。
3. **mover 算 away-tile**（`movement_system`）：`task==FLEE` 且（`move_target==(-1,-1)` 或到達）+ `flee_from_pos != (-1,-1)` → `_flee_away_tile(state, team, flee_from_pos)`＝從 tile_pos 朝**遠離** flee_from_pos 方向 FLEE_STEP hex 的可達 tile（clamp 邊界；自家 outpost 在遠側優先逃向 home）。**純幾何+可達零 randf**。`flee_from_pos==(-1,-1)`→不設 target→靠 release。
4. **release 清 flee_from_pos**（`TaskArbiter.release` 或 flee 退場點）→ 避 stale 殘留。release 自完成：逃遠→`ThreatAssessment.score` 距離衰減<THREAT_BASE_THRESHOLD(0.3)→`_has_active_threat:436` false→`_evaluate_threat:384` release（已存在）。
5. **修假註解** `faction_ai:445-447`（別再留「mover 算」實際不算的謊）。

## 守則
- **感知鐵律**：flee 讀 threat `belief_pos` 非活值（斷視線朝最後已知威脅位反向逃=合理迷霧）。
- **determinism**：`_flee_away_tile` 零 randf → 同 seed 兩跑 bit-identical（**非** baseline byte-identical，flee 真動=行為該變）。憲法零新 try_set。
- **邊界**：只治 flee 位移，不碰內政/經濟；不加執行鎖（治症）；Team0/Team1 前半好戲數字別動。

## TDD
1. **3 站各一**：`_evaluate_threat`/`_decide_unified`/`_evaluate_solo` 選 FLEE→`flee_from_pos` 設對（=belief threat 位）。
2. **真逃**：FLEE 隊 `tile_pos` 真變動（遠離 flee_from_pos）。
3. **逃遠 release**：距離拉開→threat score<threshold→`_has_active_threat` false→release。
4. **無 belief 威脅**：belief_pos (-1,-1)→不亂逃（不設 target，靠 release 收，非新死鎖）。
5. **同 seed 兩跑 bit-identical**；headless 零新增；憲法 sites=29。

## 完成後
→ handback `to:systems` → measurer 中性 full-HD（flee 真逃 + N1_flee 回落 + 故事連貫）→ QA → blueprint 批。
scope 疑義走 `to:systems`。tracer unified/solo 虛高＝**另刀**（observability-path-completion，別在本刀碰 capture）。
