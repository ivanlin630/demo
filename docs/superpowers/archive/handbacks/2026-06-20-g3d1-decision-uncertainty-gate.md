# Hand Back: G3d-1 決策讀 uncertainty + 風險 gate

branch：`feat/g3d1-decision-uncertainty-gate`

## 實作摘要

攻擊性決策從「只讀 best_estimate 單值」→ 讀 (best 值 + uncertainty)，按 `個性慎重 × uncertainty` 風險調節。莽者吃假情報誘殺、慎重者面對矛盾情報先按兵。belief 層（G3b/c）首度有決策後果。

- `scripts/simulation/belief_system.gd`：加 `GATE_CONF_LOW=0.0`/`GATE_CONF_HIGH=0.6`（TEST VALUE）+ static `confident_enough(state, observer, target, caution) -> bool`（`confidence=1-uncertainty`，`threshold=lerp(LOW,HIGH,慎重)`）。
- `scripts/simulation/faction_ai_system.gd`：
  - `_evaluate_prosperity_attack`：prey 鎖定前 gate（leader 慎重），fail→`return`（本 tick 不 commit，下次 cadence 重評）。
  - survival loot（`_trigger_survival` 遠 outpost + 殘忍 → `_find_weakest_prey`）：commit 前 gate，fail→**fall-through** 落回其他絕境路徑（回家/覓食），不凍結餓團。
- `scripts/simulation/diplomatic_ai_system.gd`：`try_proactive_diplomacy` demand_tribute（求貢）commit 前 gate，fail→`continue` 換對象。結盟/求和不 gate。
- `scripts/debug/headless_test.gd`：加 `_test_confidence_gate`/`_test_faction_attack_gate`/`_test_diplomacy_hostile_gate`（gate 過/擋/不凍結三態）。**對齊既有兩個無-belief 攻擊測試**（`_test_evaluate_prosperity_trigger`、survival loot Task5）補親見 claim（無 belief→uncertainty=1→gate 擋；補親見→過）。
- `docs/invariants.md`、`docs/progress.md`、`docs/known_issues.md`：G3d-1 段 + G3d-2 待辦 + 告知藍圖（威脅延後）。

回歸：headless 全綠（confidence/attack/diplomacy gate OK + DONE）、0 assert fail、coin_eq=0、InvariantAudit 0、200 Tick sim **仍有 ProsperityAttack/SurvivalLoot（gate 不凍結 AI）**。

### 與 plan 的差異
- 接入面判定：plan 列候選 commit（169/274/535/2123）。實際只 gate **169 prosperity attack** + **2123 survival loot**；**跳過 274（threat DEFEND=防禦,極性反→G3d-2）、535（vendetta=私仇 G2d 確定性脫軌）**——依分支語義「belief-弱→主動攻」判定，符合 plan §鎖定設計決策。
- plan 回歸閘寫 1000 Tick；本 repo headless harness 實際跑 200 Tick sim（沿用既有 harness，未改 tick 數）。

## 連動風險

- `diplomatic_ai_system`：demand_tribute 現受 gate。既有外交 proactive 測試若有無-belief demand 場景會被擋——回歸 0 fail，未發現破口；但**生產中 demander 對目標常無 belief（未偵查）→ uncertainty=1 → 慎重者幾乎不主動求貢**。是預期行為（不確定不欺敵），但可能顯著降低主動求貢頻率，藍圖平衡 pass 觀察。
- `faction_ai` survival loot fall-through：gate 擋下時落回 RETURN_HOME/覓食。若某絕境團對唯一 prey 持高 uncertainty 且回家路也斷 → 可能繞別路徑；headless 200 Tick 未見凍結，但極端場景值得 balance watch。
- `BeliefSystem.uncertainty` 單 claim = `1-credibility`：親見 cred=1.0→uncertainty=0 恆過 gate。若 G3c-2 觀察吃技能讓低技能親見 cred 仍 1.0 但**值錯**→慎重者深信錯值照衝（gate 不擋，因 cred 高 uncertainty 低）。這是設計一致（深信的錯值），非 bug，但與「誘殺」疊加可能放大。記 known_issues watch 範疇。

## 待主 session 確認

- **告知藍圖（progress/known_issues 已註）**：WHAT §8「威脅(防禦)」uncertainty-gate 延 **G3d-2**，因防禦極性與攻擊 commit 相反（不確定威脅→更該警戒/查證，非按兵）→ 與 scout 主動查證一併設計較一致。請藍圖確認此延後 OK。
- **GATE_CONF_HIGH=0.6** = 慎重者需 uncertainty≤0.4 才動，TEST VALUE 未平衡。
- 建議後續（G3d-2）：scout 主動查證迴路（不確定→派斥候→親見壓謊→才動，加速慎重者；G3c-2 裁決級識破觸發查證在此接）+ 威脅 uncertainty-gate + team_known 謠言 claim 化。
