# Hand Back: 互動統一 F-I2/I4/I5/I7 + I6（feat/interaction-unification-fi）

> Spec：`docs/superpowers/specs/2026-07-04-interaction-unification-fi-design.md`
> Plan：`docs/superpowers/plans/2026-07-04-interaction-unification-fi.md`
> 狀態：**open**（待系統 session 消化）

## 實作摘要

- `scripts/simulation/diplomatic_ai_system.gd`：**F-I2 單一屈服公式 `tribute_accept`（static）**——belief-gated（aggressor 實力讀 believed pop_est，無估 fallback=self pop=等強保守）；fear/求生欲入公式（防衛方心理恆在）、兵臨壓力=caller `threat` 輸入權重；**F-I5 接線**（consult feud/gratitude 邊，`_edge_intensity_to` reader，不改 RelationGraph 核心）；`demand_tribute` 分支改委派；**F-I6** `tribute_refused` 改走 `write_memory`（type 欄補齊，subject=拒方 leader person id，intensity 0.2 TEST VALUE）。
- `scripts/simulation/interaction_system.gd`：LOOT 勒索判斷 + `resolve_extortion_direct` NPC-refuse 塊全委派 `tribute_accept`（threat=aggressor readiness）；**舊 `_should_pay_tribute` 刪**；**F-I7 `_should_attack` 轉 belief**（無 belief → 保守不攻；believed `armed_est`（退 pop_est）vs 自身真 armed，tier2 偽裝/虛張在此咬）；tier2 欺敵三塊（偽裝平民/虛張聲勢/謊稱勢力）+ `_biggest_established_faction` 移入 DistortionEngine（**寫點 `_write_tier2_intel`/`record_claim` 不動**）。
- `scripts/simulation/distortion_engine.gd`（新）：**F-I4 單一失真引擎**。`distort_message`（訊息內容）/ `distort_intel_entry`（intel 估值）/ `apply_observation_deception`（親見欺敵）。randf 塊各 mode 1:1 移植。
- `scripts/simulation/message_system.gd`：`_distort_content`/`_distort_intel_entry` 刪（改呼 engine）；**dormant 第 4 引擎 `exchange_messages`（零 caller）刪** + 孤兒 `_time_decay_factor` 刪。
- `scripts/debug/headless_test.gd`：+`_test_tribute_unified_edges`（feud 邊 accept→refuse 翻轉）、+`_test_combat_verb_belief_gate`（無情報→保守不攻；誤報強→不攻；誤報弱→攻＝決策跟 belief 走，同 F-I1 deceive pattern）。
- `docs/message.md`（失真引擎統一段）、`docs/known_issues.md`（fork 條目劃線 + RelationGraph dormant types 新條目）。

## C 類證明（退役不並存）

- 三 tribute 公式 → 1：`interaction._should_pay_tribute` ✂、`resolve_extortion_direct` 內嵌分 ✂、`demand_tribute` 內嵌分 ✂ → 全走 `tribute_accept`。
- 三 distortion 引擎 → 1 + dormant 刪：`_distort_content` ✂、`_distort_intel_entry` ✂、tier2 內嵌欺敵塊 ✂、`exchange_messages`（dormant）✂。grep `distort` 生產碼僅剩 DistortionEngine + is_distorted flag 讀寫。
- F-I5 judge 落地無並存：**接線**（見下），無平行讀路徑殘留。

## F-I5 measure + judge 裁決

12k ticks × 2 config（game_sim_test/warzone）edge 統計：feud 2 條（producer `form_feud` 活+consumer `vendetta_target` 已活）、gratitude 6 條（3 cross-team，producer salary kindness/combat aided_in_battle 活、原無 consumer）、protect 0、killed 0。

**裁決＝接線**：feud/gratitude 入 `tribute_accept` 權重項（血仇不屈 -0.3×intensity / 恩義軟化 +0.2×intensity）。graph 保留（feud 已有 vendetta consumer，非空轉）。**killed=零 writer 零 reader（僅註解）、protect=writer-dead chain**（"master" memory 全 codebase 無人寫 → `_write_relation_edge` "master" arm + `salary._has_master_memory` 皆 dead）——salary 在本軌 scope 外未動，已列 known_issues（修向：收徒機制實作時復活 or 刪 type+讀點）。

## 與 spec 的差異 / 實作決策

- 統一公式權重全 TEST VALUE（threshold 0.1、power_r cap 3.0）；fear/survival 放公式內（防衛方心理，非情境），threat 才是 caller 情境輸入。行為量級變化：兵臨（threat>0）比舊遠程公式更易屈服＝設計意圖（威嚇=輸入權重）。
- `_exchange_intel` 訊息迴圈原 unintentional 也走 malicious 級 `_distort_content`（與 `_exchange_one_way` fork 差異）→ 統一後 mode 語意一致（unintentional=鄰格漂移）。
- `demand_tribute` 舊 debug print（score 明細）移除；`[Extort] 拒絕勒索` print 不再帶 score。
- `_should_attack` 無 belief → `false`（invariants G3-E「無估 fallback=不行動」）；實務上 `_try_interact` 開頭雙向 `_write_tier2_intel` → 同格互動時恆有親見 belief，此 gate 只咬直呼路徑。
- F-I6 舊 entry 欄位 `event_id`/`reaction`/`intensity:"minor"`（string）→ 統一 schema `type`/`subject_id`/`tick`/`intensity:0.2`（float）。舊欄位無 reader（grep 證）。

## 回歸證據

- headless：`=== DONE ===`、0 SCRIPT ERROR、僅 1 pre-existing FAIL（弱目標未加入攻擊 goal）、新測 2 條過。
- framework_validation：PASS=7 DORMANT=0（前後一致）。
- coin_eq：game_sim_multi 4 config delta 全 0.00。
- **seeded warring 前後 final 摘要（hash 變=預期，量級不崩）**：
  | seed | baseline（main） | 本軌 |
  |---|---|---|
  | 1337 | teams 45 / factions 8 / est 1 / pop 222 | teams 49 / factions 9 / est 1 / pop 233 |
  | 42 | teams 49 / factions 9 / est 1 / pop 265 | teams 40 / factions 9 / est 1 / pop 236 |
  | 7 | teams 50 / factions 8 / est 0 / pop 405 | teams 50 / factions 8 / est 0 / pop 399 |
- game_sim_multi merchant config 出現 `GameOver 玩家絕後 @tick 849`（main baseline 同 config 無）＝RNG 流改變後 seeded 時間線分岔的正常終局（非崩潰，coin_eq 守恆、無 SCRIPT ERROR）。

## 連動風險

- **屈服率整體上移**（fear/survival/threat 新增正向項，threshold 0.1 未完全抵銷）：LOOT 路徑 extort:combat:noop 分佈會變；`raid.*` probe 有既有量測可追。平衡 pass 時與 TRIBUTE_* 常數一起校。
- **`_should_attack` 保守 gate**：任何未先寫 tier2 的直呼 caller 會恆 false。現有 caller 僅 LOOT 路徑（interact 先寫 belief）→ 無影響；未來新 caller 須知此契約。
- **merge 序**：spec 指定 observer GUI 軌先 merge（其靠同 hash 證明不擾），本軌後 merge 並以當下 main 重驗 seeded finals。
- `known_reputations` 口碑迴路不受動（tribute_refused rep 懲罰照舊）。

## 順盤報告：per-option finder 濾鏈（audit watch，本軌不動手）

finder 23 個（`_find_*`/`find_*`），重複顯著者：
- **★C 類候選：`faction_ai.find_prosperity_prey` vs `faction_ai._find_weakest_prey`**——同「belief 弱者掃描」骨架（has_belief 守衛+armed_est weakness+距離濾），差 richness 項與絕境語境。兩處各自維護濾鏈。
- **C 類候選：`faction_ai._find_trade_target`（team_discovered god-view fallback）vs `strategic_ai._find_trade_partner`**——雙貿易對象 finder；前者 invariants 已標「最終應刪」（訂單系統 fallback）。
- 輕度重複：`_find_strong_neighbor`/`_find_aid_target`/`_find_occupy_target` 各自重寫「候選迭代+belief 守衛+距離濾+argmax」樣板（belief 守衛部分已統一經 BeliefSystem）。可待 DecisionEngine finder helper 收，非急。
- 其餘（encounter 戰術 finder、path、setup-time god-view）域不同，非 fork。

## 待主 session 確認

1. TRIBUTE_* 權重/threshold TEST VALUE 標定（現值保守推導自三舊公式，未跑平衡 pass）。
2. protect/killed dormant types 處置（known_issues 已列；建議收徒/擊殺鏈機制 spec 時裁）。
3. finder 濾鏈兩個 C 類候選是否排軌。
4. merchant seeded 時間線分岔（玩家絕後終局）是否需要 seeded 玩家劇本 harness 追蹤（現無 gate 斷言玩家存活）。
