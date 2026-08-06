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

## ②結構線 grounding（TBD、序=先行為後結構）
- 所有權/耦合 map：clean-extractable(marginal/message/labor 2-3 ref) vs 纏。
- ★faction_ai 5018 行內部拆解：行為 chunk 可抽進引擎自然瘦 / 剩切哪幾個有邊界模組 / 對接介面。

## output → blueprint
兩份 grounding 清單（行為線閘表 + 結構線 map）→ blueprint 據真數字 spec 兩硬綠 program（非憑印象）→ R①→R²→slice 切。
