# Hand Back: G3b multi-claim 儲存

branch: `feat/g3b-multi-claim`（已 push，未 merge）

## 實作摘要

storage flip：`team_intel[obs][tgt]` 單 dict → **Array of claim**（值/源/時效/可信度/失真，多源不覆蓋）。改動全藏 `BeliefSystem` accessor 後（G3a de-risk），決策讀者零動。

- `scripts/simulation/belief_system.gd`：核心重寫。新 `claims`/`record_claim`/`known_targets` + `_coerce`(讀容錯舊 Dict)/`_cap_target`/`_cap_observer`；`best_estimate` 改聚合最高 credibility claim 的 value（tie→新 tick）；`uncertainty` 改 claim 分歧（≥2 用 population_est `(max-min)/max`，單 claim `1-credibility`，無 1.0）。常數 `MAX_CLAIMS_PER_TARGET=4`/`MAX_CLAIMS_PER_OBSERVER=200`（TEST VALUE）。
- `scripts/ui/sim_bridge.gd`：:185 讀走 `best_estimate`。
- `scripts/simulation/inquiry_system.gd`：3 處 key 迭代改 `known_targets`，刪 2 個純迴圈源 `var intel`。
- `scripts/simulation/vision_system.gd` `_write_tier01`：基底取 `best_estimate`、尾改 `record_claim(親見,1.0)`，刪冗餘 obs guard。
- `scripts/simulation/interaction_system.gd` `_write_tier2_intel`：同模式。
- `scripts/simulation/message_system.gd` `_share_intel`：**停 :222-224 confidence-max 覆蓋** → 跨源 append/同源更新；giver source 取 `best_estimate`；偵查識破改標該 source claim `value.is_suspicious`。relay cred interim `(1-HOP_DECAY)*entry.confidence`。
- `scripts/debug/headless_test.gd`：+`_test_belief_multiclaim`（聚合/不覆蓋/分歧/Dict coerce/cap）、+`_test_intel_writers_multiclaim`（兩 giver→receiver 多源不覆蓋）；6 處既有 raw `team_intel.get().get()` 讀斷言遷 `best_estimate`。
- docs：`invariants.md` belief 段擴 multi-claim；`known_issues.md`/`progress.md` G3b ✅ + TEST VALUE。

### 與 plan 的差異
- plan Step1(Task3) 的 writers 測試是 placeholder 註解；實作為可跑 scenario（`_exchange_intel` 兩 giver 同 faction→honest，斷言 receiver 2 claims）。
- 移除 vision/interaction 兩處 `if not has(obs): team_intel[obs]={}` 冗餘 guard（record_claim 自建），符 plan Step6「寫端零直寫」。

## 連動風險
- `message_system._share_intel`：relay credibility 用 interim 公式（雙重 `(1-HOP_DECAY)`：`_distort_intel_entry` 已套一次、record_claim cred 再套一次）。多源時 best_estimate 仍偏向親見(1.0)，行為合理；但 relay 間相對 credibility 偏低。G3c 換正式公式時須一併校。
- `_cap_observer`：>200 claim 時若該 observer 摻舊式 Dict（僅 test 直設可能），`remove_at` 對 Dict 會崩。生產寫端全 Array，實務不觸；G3c 收緊容錯時可移除風險。
- 決策接口未變（仍讀 best_estimate 單值面），但**多源情境下回值會變**（取最高 credibility 而非最後寫入）→ 平衡觀感可能微移，非 bug。

## 待主 session 確認
- TEST VALUE（MAX_CLAIMS_*、uncertainty 分歧欄選 population_est、relay cred interim）待正式平衡 pass 調。
- 建議後續：G3c 可信度 trust 公式 + 技能識破；G3d 決策改讀 uncertainty + 查證迴路；team_known 事件謠言 claim 化。
- 回歸：headless `=== DONE ===`、0 SCRIPT ERROR、0 assert fail、coin_eq 守恆、InvariantAudit 0、1000 tick。未跑 game_sim_multi（無 seed 不可重現，依 memory 規約）。
