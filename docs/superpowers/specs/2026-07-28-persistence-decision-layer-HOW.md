---
type: spec-draft
owner: systems
topic: 持守統一 decision-layer HOW 架構（R①收窄後子集）
status: draft-骨架（重掃+scope done；公式細節+slice 待 post-compact 完整化+R²）
---

# HOW 架構 spec（draft 骨架）：持守統一 decision-layer

> R① CONTRADICTION 收窄後（blueprint 調 WHAT 2026-07-28）：本 arc = **決策層 flat bonus 家族 → 沉沒成本+人格加權**，progressive-only，危機/階層/FLEE 排除。執行層/跨層共讀 = 獨立 arc（用戶 fork 等 blueprint）。**此檔骨架先記 proceed 進度（blueprint GO 別空等）；公式細節+plan/slice 待 post-compact 完整化（重工別滿 context 跑，means-end 樂觀低估血證）→ R²。**

## 1. scope（重掃坐實，5 核心項）
本 arc subsume 這 5 決策層 commitment/hysteresis 機制（全「committed 情勢未變黏住」=同類 rank 偏置）：
| 機制 | file:line | 現值 | 套的動作 |
|---|---|---|---|
| COMMANDER_COMMITMENT_BONUS | faction_ai:39 (用:910) | flat 0.15 | 戰略意圖(征服/建國) hysteresis |
| FOUND_COMMITMENT_BONUS | faction_ai:46 (用:1244) | flat 0.15 | 建國意圖 hysteresis |
| SOLO_COMMITMENT_BONUS | faction_ai:87 | flat 0.15 | SoloAI 日常 task 慣性 |
| COMMITMENT_BONUS | decision_engine:6 (用:88,173；current_option 寫 faction_ai:1837/1984) | flat 0.3 | 引擎 rank current_option 承諾慣性 |
| survival_committed_stall | faction_ai:3660+ | 情境(8天×人格+relief) | survival option 無進展耐性 |

## 2. 排除（重掃確認，非本 arc）
- **危機/急迫 axis**（反持守/守命，留原樣）：PRIO 階層/combat_lock/emergency_guard/CRISIS_FLOOR_override/SURVIVAL_RECOVER_DAYS。
- **非 commitment**：MERCHANT_TRADE_BONUS(:20 trade 偏好)/TERRAIN_BUILD_BONUS(:2913 地形適性)。
- **非 progressive**：FLEE(開放無終點)/TRADE·FOUNDING 一次性 timeout。
- **27 不齊補**：礦山建造豁免求生(:3451 famine grace，閘地形+資源=危機 axis 排除)。
- **執行層/跨層共讀**：COMMITMENT_BONUS 寫回 + try_set 重寫 + ~29 call site + cadence 新鮮度 = 獨立更大 arc（用戶 fork）。

## 3. 模型（方向，公式細節 post-compact）
**持守強度 = 人格加權(沉沒成本 + 前瞻價值)，取代 flat 0.15/0.3**：
- **沉沒成本**（往回看）：committed 動作已投入/進度越多越黏。**固執/恆心人格權重高**=死硬完成者。
- **前瞻價值**（往前看）：離完成/回報越近 util 越高。**務實/機會人格權重高**=靈活轉換者。
- **人格→沉沒vs前瞻混合比**（哪些 value 偏沉沒/前瞻，如 慎重/固執→沉沒、貪婪/機會→前瞻）= post-compact 定。
- **progressive-only gate**：只套有進度/終點動作（build/upgrade/campaign/戰略意圖有達成度）；開放式（FLEE）不套。

## 4. 憲法對齊
- utility weigh 非 scripted（持守=rank 偏置權重，非寫死 edge）。
- 人格 WEIGH 不 GATE（人格調沉沒/前瞻混合比=權重，非硬類別閘）。
- 非硬鎖（latch 反例，util 偏重永不凍世界）。

## TODO（post-compact 完整化 → R² → plan/slice）
- [ ] 沉沒成本量化（各動作「已投入/進度」怎麼取：construction_ticks 已耗/戰略意圖達成度/…）。
- [ ] 前瞻價值量化（離完成距離）。
- [ ] 人格→混合比 mapping（哪些 value 權重）。
- [ ] progressive-only gate 判準（哪些動作有進度/終點）。
- [ ] 5 項 subsume 接線（統一 helper 算持守強度，5 處 call 改讀它）。
- [ ] 成功判準（隊照人格堅持/轉換、無 thrash、無凍世界）。
- [ ] plan/slice → R²每slice → implementer。
