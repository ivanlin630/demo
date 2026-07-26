---
type: design-inventory
owner: systems
topic: 現有散落「執行持守/commitment/anti-落跑」機制盤點（手統一 general arc design 底稿）
status: draft-for-brainstorm
---

# 盤點：散落「執行持守/commitment/anti-落跑」機制（手統一 general 底稿）

用戶裁乙（2026-07-26）：手統一 general = 下個 arc（執行持守統一）。先產此盤點當設計底稿 → blueprint+用戶 brainstorm。**這是底稿非 spec。** investigator 掃全庫（22 defs，file:line 驗證）+ systems 補 construction latch（branch）+ 共同模型觀察。

## 盤點表（23 機制）

| # | 機制名 | file:line | type | cover 落跑 case | 層 | 扁平vs情境 |
|---|---|---|---|---|---|---|
| 1 | COMMITMENT_BONUS | decision/decision_engine.gd:6 | flat-bonus | task 震盪/反覆換選 | 決策層rank偏置 | flat (0.3) |
| 2 | COMMANDER_COMMITMENT_BONUS | faction_ai:39 | flat-bonus | 戰略意圖(征服/建國)搖擺 | 決策層rank偏置 | flat (0.15) |
| 3 | FOUND_COMMITMENT_BONUS | faction_ai:46 | flat-bonus | 建國意圖每cadence翻車 | 決策層rank偏置 | flat (0.15) |
| 4 | SOLO_COMMITMENT_BONUS | faction_ai:87 | flat-bonus | SoloAI日常task交替 | 決策層rank偏置 | flat (0.15) |
| 5 | SURVIVAL_RECOVER_DAYS | faction_ai:98 | hysteresis | survival task短期反覆釋放 | 決策層rank偏置 | flat (7天) |
| 6 | RETURN_HYSTERESIS_DAYS | decision/terms.gd:4 | hysteresis | 商隊返家過早再離隊 | 決策層rank偏置 | flat (5天) |
| 7 | RESTOCK_DAYS | decision/terms.gd:3 | hysteresis | 商隊返家過度敏感 | 決策層rank偏置 | flat (5天) |
| 8 | SCOUT_TIMEOUT | belief_system.gd:32 | timeout | scout task卡死無收斂 | 執行層task-arb | flat (3天) |
| 9 | TRADE_TIMEOUT | faction_ai:126-129 | timeout | zombie貿易在途卡死 | 執行層task-arb | ★情境 (6天+距離×12h/hex) |
| 10 | FLEE_TIMEOUT | faction_ai:100 | timeout | 永久逃跑卡死 | 執行層task-arb | flat (5天) |
| 11 | STATION_TIMEOUT | faction_ai:137 | timeout | 紮營逾時未完成 | 執行層task-arb | flat (4天) |
| 12 | FOUNDING_TIMEOUT | faction_ai:1308-1310 | timeout | founding in-flight永卡 | 執行層task-arb | ★情境 (距離×6+12天floor) |
| 13 | CONSTRUCT_TRANSIT_TIMEOUT | faction_ai:1724 | timeout | subteam建造在途抵達後未轉BUILD | 執行層task-arb | flat (10天) |
| 14 | CRISIS_IMMUNITY | faction_ai:83 | immunity-window | crisis-released task立刻re-commit | 執行層task-arb | flat (2天) |
| 15 | PRIO_*_hierarchy | task_arbiter.gd:7-14 | priority-preempt-gate | 低優先task被搶 | 執行層task-arb | flat (COMBAT100>SURVIVAL80>THREAT70>PLAYER60>DISPATCH50>AMBIENT10) |
| 16 | combat_lock_absolute | task_arbiter.gd:40-41,114 | immunity-window | 戰鬥中被任意task搶 | 執行層task-arb | flat (戰鬥期絕對鎖) |
| 17 | emergency_respect_guard | task_arbiter.gd:118-119 | guard | 外部低優先stomp emergency | 執行層task-arb | flat (THREAT+以上不被降級) |
| 18 | crisis_released_guard | task_arbiter.gd:45-46,115-116 | guard | 免疫窗內重複委派同task | 執行層task-arb | flat (2天) |
| 19 | survival_committed_stall | faction_ai:3660-3696 | latch | survival_option無進展卡死 | 決策層rank偏置 | ★情境 (8天耐性×人格+relief-delta) |
| 20 | CRISIS_FLOOR_override | faction_ai:76,3645 | latch | committed_task深餓未緩強制release | 執行層task-arb | ★情境 (food<1.5天+6天未緩) |
| 21 | _should_reeval_cadence | faction_ai:1887-1911 | timeout | 決策過頻重評節流 | 決策層rank偏置 | flat (1天,crisis÷4) |
| 22 | SUBTEAM_CADENCE | faction_ai:112 | timeout | 子隊決策過頻節流 | 決策層rank偏置 | flat (1天) |
| 23 | subteam_TASK_BUILD_sticky | faction_ai:1717-1718 | guard | 子隊建設中被召回/紀律 | 執行層task-arb | 絕對 (施工中return) |
| 24 | subteam_CONSTRUCT_guard | faction_ai:1721-1729 | guard+timeout | 子隊在途中斷,抵達逾時才release | 執行層task-arb | flat (10天) |
| 25 | crisis_latched_edge_trigger | faction_ai:1895-1904 | latch | crisis持續期每tick fire節流 | 決策層rank偏置 | flat (entry+持續÷4) |
| 26 | PREEMPT_MARGIN_gate | faction_ai:117 | priority-preempt-gate | 忙碌隊被低威脅誤搶 | 決策層rank偏置 | flat (威脅≥2.0始搶busy) |
| **27** | **construction-commitment latch+resume** | **faction_ai:1887+/2742（branch feat/construction-commitment-latch 5b166eb1，★revert 出 main）** | **latch** | **施工隊被cadence argmax搶去外交+leak後召不回** | **決策層(_should_reeval)+執行層(resume)** | **★情境 (force_reeval繞威脅)** |

（investigator 22 + terms.gd RESTOCK/RETURN 拆開 + systems 補 #27 latch = 全景。）

## ★共同模型觀察（systems 分析，brainstorm 料）

### 兩層分佈
- **決策層 rank 偏置**（12）：bonus（flat 0.15-0.3）、hysteresis（返家/survival 天數）、cadence 節流、survival stall latch。**改「argmax 選什麼」的權重。**
- **執行層 task-arbitration**（10+）：timeout（卡死保險）、guard（emergency stomp 擋）、immunity-window（crisis/combat）、priority-preempt-gate（硬階層）。**改「已 committed task 能不能被換掉」。**

### type 光譜（弱→強持守）
`flat-bonus(0.15)` → `hysteresis(天數)` → `cadence節流` → `timeout(卡死保險)` → `priority-preempt-gate(硬階層)` → `guard(擋stomp)` → `immunity-window(crisis/combat)` → `latch(絕對skip/return)`

### 三大症狀（散補丁的病根）
1. **決策層 bonus 全 flat 0.15**（COMMANDER/FOUND/SOLO 同值）= **不分 commitment 強度/已投入成本**。剛起念 vs 投料開工 vs 半完成 = 同 0.15 → 弱持守（A1 latch 就是補這個：flat bonus 擋不住 argmax，要 skip-reeval 才守得住）。
2. **執行層每 task 類自己一套 timeout/guard**（TRADE/FLEE/STATION/FOUNDING/CONSTRUCT 各一個 *_TIMEOUT + 各自 guard）= bespoke 散補丁，無統一模型。每加新 committed 動作 → 又補一套（A1 construction latch = 第 N 個）。
3. **扁平 vs 情境不一致**：多數 flat 常數，少數情境感知（TRADE/FOUNDING timeout 距離縮放、survival stall 人格×relief、crisis floor food+天）。**情境感知的（19/20/27）是較成熟樣板**；flat 的（1-4 bonus）是最原始。

### 統一「執行持守」候選模型（brainstorm 起點，非定案）
隊 commit 多 tick 動作 → **持守強度 = f(已投入成本/進度, 剩餘完成距離, 中斷機會成本)**，隨進度**累積**（非 flat）→ 只真更高優先危機（combat/survival/threat，走既有 PRIO 階層）能打斷 → 完成/放棄才釋放。一致模型取代 27 個散補丁。
- **決策層**：commitment bonus 從 flat 0.15 → 進度累積（投入越多越黏）。
- **執行層**：統一 committed-task latch（取代各 task bespoke guard/timeout），latch 強度隨進度，PRIO 危機繞（force_reeval 樣板已在 #27）。
- **A1 construction latch（#27）= 這模型的一個 instance**（施工進度累積持守）→ folds 進 general。

## 交付
→ blueprint：此底稿 + 用戶 brainstorm 手統一 general 設計（brainstorm→design→build，像 means-end）。**盤點事實 + 模型觀察分開**——模型是 systems 提議的 brainstorm 起點，非鎖定。
