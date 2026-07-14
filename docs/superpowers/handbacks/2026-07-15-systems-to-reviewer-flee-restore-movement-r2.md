---
from: systems
to: reviewer
status: open
topic: "[R²·設計審] 恢復flee位移(FLEE no-op根治)——治根非治症;away-tile用belief_pos(感知鐵律);release自完成(距離→threat<threshold);premise file:line坐實免R①"
---

# R²：恢復 flee 位移 spec

> **[worker 守則] 卡住/疑義 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

spec：`docs/superpowers/specs/2026-07-15-flee-restore-movement.md`。
blueprint 確認 reframe：`2026-07-15-blueprint-to-systems-flee-reframe-confirmed.md`（認同真根=dead flee-movement 非缺鎖）。

## premise 已 file:line 坐實（免 R① factcheck）
FLEE no-op：`options.gd:188` target(-1,-1) / `movement:82-84` no-target skip / `faction_ai:445-447` 假註解「mover 算」實際不算 / 全域 grep 無 flee-dir。full-HD 觀察血證 Team1 128 天原地逃 3080 churn。

## 審什麼（治根設計，非治症）
1. **治根方向對否**：恢復 flee 位移（隊真逃遠→threat 距離衰減→`_has_active_threat`:436-443 false→`_evaluate_threat`:384 release=自然終點）vs 加執行鎖（治症，隊仍卡原地）。blueprint 認同治根，但驗設計真達成「威脅解自然 release」非另造 lock。
2. **away-tile 幾何**：`_flee_away_tile` 從 tile_pos 朝遠離 `flee_from_pos` 方向 FLEE_STEP hex 可達 tile（clamp 邊界；自家 outpost 在遠側優先逃向 home）。驗：純幾何+可達**零 randf**？逃向 home 的偏好會不會有反例（home 在威脅方向→往威脅逃）？
3. **★感知鐵律**：`flee_from_pos = belief_pos(threat_id)`（belief 非活值）。斷視線→朝最後已知威脅位反向逃（可能逃錯=合理迷霧）。驗合 god-view 感知鐵律。
4. **flee_from_pos 生命週期**：dispatch 設、release 清。驗無 stale 殘留（release 清點補齊否）。
5. **release 自完成**：距離拉開→ThreatAssessment.score 距離衰減<THREAT_BASE_THRESHOLD。驗 ThreatAssessment 真有距離衰減（decision_context:154 註「距離衰減」）→ 逃遠真降分。若某情境 score 不隨距離降（threat 定死高）→ release 不觸→仍churn→halt。
6. **determinism**：零 randf → 同 seed 兩跑 bit-identical（非 baseline byte-identical，flee 真動=行為該變）。憲法零新 try_set。

## 特別看（可能的坑）
- **多 dispatch site 設 flee_from_pos**：FLEE 從 `_evaluate_threat`:408 + unified:1538 + solo:1875 + survival:3213 派。四站都要設 flee_from_pos（有 ctx.threat_id）？漏一站→該站 flee 仍 no-op。spec 說「dispatch 時設」，驗四站覆蓋 or 集中一點。
- **mover 每 tick 重算 away-tile**：到達後 move_target 清→下 tick 重算新 away-tile（threat 若追來→持續逃）。驗不會抖動（每 tick 換方向）。
- **belief_pos (-1,-1) 時**：無威脅情報→不設 target→靠 release。驗這條不會變成「有 FLEE task 但不動也不 release」的新死鎖。

## 流向
CLEAN → dispatch implementer（新分支 feat/flee-restore-movement）→ measurer 中性 full-HD（flee 真逃 + N1_flee 回落 + 故事連貫）→ QA → blueprint 批。
premise_contradiction（如 ThreatAssessment 無距離衰減=release 不自完成）或設計缺口 → to:systems halt。
