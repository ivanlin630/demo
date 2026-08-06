# 框架收尾 grounding audit（systems、measure-first、非盲改）

status: IN-PROGRESS（行為線 batch1 done、續行為線+結構線）
owner: systems（HOW）→ blueprint 據真數字 spec 兩硬綠 program
date: 2026-08-06
溯源：復甦 arc 收官 → 用戶排序 A 觸發框架收尾兩硬綠大工程。★blueprint kickoff：grounding audit 非盲改（roadmap l.356「剩項先 R①-verify 真缺否」、oracle 稽核 over-count 3 次前科）→ 逐條 re-grep 實證 still-live 非假設 stale。

## ①行為線 grounding：§殲滅清單 A 殘留非框架閘 re-verify
**格式**：條目 | still-live? | 閘型(硬門檻/override/RNG/god-view) | de-patch 靶 or 已修

| 條目 | file:line | still-live? | 閘型 | 判定 |
|---|---|---|---|---|
| `_threat_recent` 硬 gate | faction_ai:4385 | ❌ | (硬門檻) | **已修**：「取代反應式 _threat_recent 硬 gate、純人格+狀態零 randf」（roadmap 序4 done）。stale。 |
| `has_food_market` 全圖掃 | decision_context:304 / faction_ai:2957 `_nearest_market_outpost` | ❌ | (god-view) | **已修**：讀 `state.team_market_known`（`_harvest_market_known`=vision 半徑親見+relay）=belief-gated 非全圖掃。god-view Slice C 已建 market-discovery belief store。stale。 |
| diplomatic betrayal RNG | diplomatic_ai:325 | ⚠️ legit | (RNG) | **legit tie-break**（非殘留）：driver≥HARD→deterministic、僅門檻邊界(MIN..HARD)小 stochastic tie-break（invariants 已祝 blessed）。**但未 inline gate-ok 標**（machine-gate 覆蓋待確認）。 |
| 創世全知 all-pairs | game_setup:592-621 | ❌ | (god-view) | **已修**：god-view Slice B「創世知識 seed(②proximity+③parent 非全知)取代舊 all-pairs 全知」、`omniscient_discovery` default false（僅純機制 test）。stale。 |
| PathSystem/threat 位置 leak | threat_assessment:24-27/36 | ❌ | (god-view) | **已修（細查订正、我 batch1 誤 flag TBD-live）**：`score` 位置 belief-gated（:24-27 not-visible-this-tick→belief_pos→positionless→0）、`_approach_score` observe_velocity visible gate、`_power_ratio` belief pop_est fallback self_pop。Slice D fold 已解。★**我差點 over-count D=正犯 oracle 同錯、re-verify 抓住**。stale。 |
| tribute override | diplomatic:16-38 `tribute_accept` | ❌ | (override) | **已修**：F-I2 統一屈服公式（3 caller LOOT/demand_tribute/player 單 owner、W_POWER/HONOR/SURVIVAL/FEAR/FLEE 人格加權、de-patch 閘5 done）。stale。 |
| 覓食 FORAGE_VIABLE_POP | options.gd:52-53 | ⚠️ live | (硬門檻) | ★**genuine 候選=照妖鏡族（§5 死常數人格化 backlog、非 god-view）**：`pop<=FORAGE_VIABLE_POP` 硬 pop-gate。屬 applicability physical-viability（大群不能覓食）介於 world-mechanic vs death-constant→§5 審。 |

★★**行為線 grounding 收斂結論**：
- **前 6 條全 stale/已修**（含 D 我誤 flag、re-verify 訂正）→ §殲滅清單 A **god-view 項多已解**（has_food_market belief 化/創世全知 seeded/D 位置 belief-gated/threat stats belief）。
- ★**constitution_gate v2 已抓全閘型**（非 blueprint 假設「只抓 1 閘型」=stale）：detectors=taskarbiter+值閘(threshold/override/rng)+god-view(gv_teamstate/gv_mapscan)+控制流(route/dispatch/early_return)、type 分布 9 型 **75 sites baselined 過閘 removed=0**=**零殘留 largely machine-proven**。
- ★**genuine 殘留工作 ≠ 盲 de-patch 清單**、而是：**審 75 baselined threshold/gate-ok sites 有無死常數該人格化**（§5 照妖鏡族：FORAGE_VIABLE_POP/DESPERATION applicable 等硬門檻—gate 現標 legit world-mechanic、須逐一判 physical-viability[留] vs death-constant[§5 人格化]）。
- diplomatic:325 RNG legit tie-break（blessed、未 inline gate-ok 標=machine-gate 標記 follow-up 小項）。

### ①行為線 TODO（收束）
- 逐一過 75 baselined `threshold`-type sites → 分 physical-viability(留)/death-constant(§5 人格化靶)。此=零殘留硬綠的 genuine 剩工（非盲改清單）。
- diplomatic:325 補 gate-ok 標（小）。

## ②結構線 grounding（faction_ai 5018 行 = 209 func / ~25 section 拆解）
section map（grep `^func`/`# ──` 實掃）→ ~8 行為域：

### (A) 先行為抽引擎（decision chunks → DecisionEngine 自然瘦、序優先）
| chunk | 行區 | 現況 | 抽法 |
|---|---|---|---|
| 統一戰略 scorer + 意圖選擇 + 目標評估 | 895-1311 | 部分已走 rank_scored/_decide_unified | 收剩餘散 scorer 進引擎（decision→util term） |
| D 被動威脅反應 | 374-518 | 部分已 rank_scored threat（threat-oracle arc） | 剩 scaffolding 保、decision 已抽 |
| 獨立/子團/獨立 Team 自主 AI | 1169-1311/2435-2920 | 走 _decide_unified/rank_scored | 驗 filtered-subset 真統一（seam#1 結論：各編碼語意需逐驗） |

### (B) 後結構切邊界模組（lifecycle/dispatch chunks、序後）
| 候選模組 | 行區(~) | 內聚性 | 對接介面 |
|---|---|---|---|
| **基建/設施 lifecycle** | 3126-4352(~1200) | 高（設施需求/選址/建設 dispatch/公庫料） | tile/outpost state + build task |
| **side-dispatch 家族**（求援/偵察/移民/投資/遷村令+遷村執行端） | 1662-2142(~480) | 高（info_side_dispatch + lord-side 家族 + R3 compound） | belief/letter/convoy/subteam |
| **公庫徵用/領存** | 3173-3396(~220) | 高（extraction lifecycle） | resource/TileBank |
| **outpost 居民派駐** | 142-305/519-642(~280) | 中（派駐 AI） | outpost/resident |
| **envoy 外交** | 1312-1661(~350) | 高（信使外交 helpers） | diplomatic/letter |

### (C) orchestration/scaffolding（留 faction_ai 核）
- `evaluate_all` 主循環（643-869）= tick 編排（+phase timing）。Tag 權限（870）。輔助函數（2921-3125）。

### 所有權/耦合 map
- **clean-extractable**（少 ref、可先）：`MarginalEconomy`（剛建、純算術、~R1-R3 caller）/message/labor（2-3 ref）。
- **entangled 核**：`faction_ai_system.gd`（實測引用 35 系統/62 系統共讀 WorldState）= 大雜燴、須先(A)抽 decision 瘦身再(B)切模組。

## ★★grounding 總結論（→ blueprint spec 兩硬綠 program）
1. **①零殘留硬綠 largely machine-proven**（constitution_gate v2 @75 過閘、god-view 多已修）→ genuine 剩工=**審 75 baselined threshold sites 死常數（§5 照妖鏡人格化）** 非盲 de-patch stale 清單。
2. **②可擴充硬綠 = 結構線主戰場**：faction_ai 5018 行拆解 = (A)先抽 decision chunks 進引擎瘦身 → (B)切 5 邊界模組（基建/side-dispatch/公庫/outpost-residency/envoy）。clean-extractable(marginal/message/labor)可平行先動。
3. 序=先行為(A)後結構(B)（反序白工）。R3 lord-fix 已預演 god-view 殲滅精神。

## output → blueprint
兩份 grounding 清單（行為線閘表 + 結構線 map）→ blueprint 據真數字 spec 兩硬綠 program（非憑印象）→ R①→R²→slice 切。
