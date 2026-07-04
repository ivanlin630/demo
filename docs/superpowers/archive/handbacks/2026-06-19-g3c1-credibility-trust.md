# Hand Back: G3c-1 可信度 + 身份信任 + 類型基準

branch: `feat/g3c1-credibility-trust`（已 push，未 merge，等主 session）

## 實作摘要

claim 可信度從 G3b interim flat 值 → 真公式 `effective_credibility = source_credibility(類型基準 × 身份信任 × 跳數) × 時效衰減`。落地「誰準誰被信、騙子看破後沒人聽」。

改檔（每檔一行）：
- `scripts/simulation/belief_system.gd`：加 const（CRED_BASE/TRUST_FLOOR/BELIEF_HOP_DECAY/CRED_AGE_FULL_DECAY/CRED_TIME_FLOOR/TRUST_DELTA）+ `source_credibility`（寫時 type×trust×hop）+ `_time_decay`/`effective_credibility`（讀時）+ `reconcile_firsthand`（親見比對 relayed ±口碑）；`best_estimate` 改排 effective；`record_claim` 尾段親見自動觸發 reconcile（單一 choke）。
- `scripts/simulation/message_system.gd`：加 `_claim_source_type`（giver 性質分類）；`_exchange_intel` record_claim 改傳真 source_type + cred 走 `source_credibility(...,hop=1)`（修 G3b relay 雙重 HOP debt）。
- `scripts/simulation/vision_system.gd` / `interaction_system.gd`：親見 record cred `1.0` → `source_credibility(...,"親見",obs,0)`（=1.0，走公式一致）。
- `scripts/debug/headless_test.gd`：加 `_test_claim_source_type` / `_test_credibility_formula` / `_test_trust_reconcile`（+ helper `_seed_st_team`/`_find_claim`）。
- docs：`invariants.md`（可信度公式 + 身份信任段）、`g3-info-decision-how-design.md`（G3c 拆 G3c-1/2、trust 邊覆寫 known_reputations）、`known_issues.md`、`progress.md`。

## 與 spec 的差異
- **身份信任 = `TeamData.known_reputations`（非 RelationGraph trust 邊）**：plan 已鎖定此覆寫（claim source = giver team，known_reputations 正是 team→team 動態信任，免 person 邊 dormant）。HOW spec §1/4/6/7 已同步更新記理由，無 doc drift。
- code commit 合併 Task1-3（三 task 改同檔 belief_system/message_system，無法乾淨 git add 分拆）→ 單 feat commit；docs 為 Task4 獨立 commit。功能與測試逐 task 對齊，僅 commit 粒度合併。

## 回歸結果
`=== DONE ===`、無 SCRIPT ERROR、InvariantAudit population/faction/subteam OK、coin_eq 守恆 OK、新 3 測 + 既有 belief 測（multi-claim/intel writers）全綠。未跑 multi drift（無 seed，plan 指定）。

## 連動風險
- `message_system`：relay cred 改公式（hop 只算一次）→ claim.credibility 數值分佈變、best_estimate 排序變。決策接口仍讀 best_estimate 單值面（內部排序變）。**行為非保留為設計預期**（WHAT 可信度真公式），回歸閘 = 不崩+守恆。
- `known_reputations` coupling：兼外交/施捨/勒索口碑。belief 親見查證 ±它 →「騙我者我也少分享」(message `rep2` gate、`_decide_exchange_mode` 連動) = emergent-coherent。**主 session 注意**：若量測顯外交行為被 belief 查證污染失衡，再評估拆專用 trust（interim debt，已記 known_issues）。
- `vision/interaction` 親見 cred 現走 `source_credibility`（=1.0）→ 數值未變，但未來改 CRED_BASE["親見"] 會連動親見可信度。

## 待主 session 確認
- 設計決策：reconcile 比值門檻（[0.7,1.3] 升 / <0.4 或 >2.5 降）、TRUST_DELTA=0.05、CRED_AGE_FULL_DECAY=30天、CRED_TIME_FLOOR=0.2 全 TEST VALUE，待平衡 pass 調。
- 建議後續：G3c-2（技能識破 信假/生疑/裁決 + 觀察吃技能，依賴本層 cred）；G3d（決策讀 uncertainty + scout 主動查證，本層查證僅被動偶遇）；team_known 事件謠言 claim 化。
- known_reputations coupling 量測：建議跑一場 multi 觀察外交 task 佔比是否因 belief 查證偏移（若偏 → 拆專用 trust）。
