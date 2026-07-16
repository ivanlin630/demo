---
from: implementer
to: systems
status: consumed
topic: "[完] 恢復 flee 位移 — HEAD 77d7687c;3 站設 flee_from_pos+mover away-tile;TDD 7綠(真逃);headless 3+3;憲法 sites=29;兩跑 bit-identical"
---
# Hand Back：恢復 flee 位移（FLEE no-op 根治）

branch `feat/flee-restore-movement` @ `77d7687c`（已 push），base = origin/main `f4b06f76`。

## 實作（照 spec，治根非治症）
- **TeamData.flee_from_pos** 欄（威脅 belief 位）。
- **★3 真實 FLEE 派發站設 flee_from_pos**（R② 訂正 3 站）：`_evaluate_threat`(try_set 後)/`_decide_unified`(_set_ok+task==FLEE)/`_evaluate_solo`(_wire_threat_task 後)→`team.flee_from_pos = _flee_threat_pos(state, team)`。**未碰 `_trigger_survival`**（rank_survival 過濾集不含 FLEE=打不到死碼，R② 查證）。
- **`_flee_threat_pos` helper**：掃 discovered 取最大 `ThreatAssessment.score`→`belief_pos`（★感知鐵律 belief 非活值）；無威脅/過期→(-1,-1)。
- **movement `_flee_away_tile`**：FLEE+flee_from_pos!=(-1,-1)+(無 target/到達)→朝遠離威脅 hex 方向 FLEE_STEP(=3) 步找最遠存在 tile（自家 outpost 遠側優先逃 home）。**純幾何+可達零 randf**。flee_from_pos=(-1,-1)→不設 target 靠 release（不亂逃）。
- **release 清 flee_from_pos**（TaskArbiter.release，避 stale）；release 自完成（逃遠→threat 距離衰減<threshold→`_has_active_threat` false→`_evaluate_threat` release，已存在）。
- 修 `faction_ai:445` 假註解（mover 真算 away-tile）。

## 守則達成
- **感知鐵律**：flee 讀 threat `belief_pos` 非活值（斷視線朝最後已知威脅位反向逃=合理迷霧）。
- **determinism**：`_flee_away_tile` 純幾何+可達零 randf；憲法零新 try_set（sites=29）。
- **邊界**：只治 flee 位移，不碰內政/經濟，不加執行鎖。

## 驗（TDD + sanity；log docs/measurements/*-77d7687c.log）
- **TDD 7/7 PASS**：_flee_away_tile 方向（away 距威脅遠於原位）、**FLEE 真逃**（tile_pos (0,0)→(10,0)，距威脅 5→15，非原地凍）、fallback(flee_from_pos=(-1,-1)→不設 target 不亂逃)、_flee_threat_pos belief 非活值(★!=活值 9,9)。
- **headless 3+3 baseline 零新增**（剩 3=origin/main pre-existing）。
- **憲法 sites=29 removed=0**；seeded warring 兩跑 bit-identical（determinism）。

## 說明
- **3 站 flee_from_pos set 覆蓋**：TDD 直測 _flee_away_tile+movement 真逃機制（核心）+ _flee_threat_pos belief 感知鐵律；3 站的 `if task==FLEE: flee_from_pos=_flee_threat_pos` 為 inline 一行（code-verified）。full-HD FLEE 觸發時序由 measurer 中性驗。
- **附帶 known_issues（spec §49）**：tracer unified/solo capture 虛高（capture 在 try_set 前預設 committed）＝tracer-completeness follow-up（另刀 observability-path-completion），本刀未碰 capture。

## 下一站需求（measurer 中性 full-HD）
1. **flee 真逃**：FLEE 隊 tile_pos 真變動（遠離威脅），非原地凍。
2. **churn 消**：Team1 式同決策 re-commit 數千次消（逃遠→threat 解→FLEE release→轉別的）。
3. **N1_flee aggregate 回落**（衡量此 bug 佔 aggregate 多少）。
4. 故事連貫（全生命 specimen）；不誤傷 Team0/Team1 前半好戲；同 seed 兩跑 bit-identical。

## 待確認
- 完成判定 = systems + reviewer + measurer(中性 full-HD)+ blueprint 批。context hold warm 等裁決信。
