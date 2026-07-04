# Hand Back: 框架驗證套件（framework-validation）

branch: `feat/framework-validation`（未 merge，待主 session）

## 實作摘要

- `scripts/debug/headless_test.gd`：加 `_test_tc2_survival_input` + `_test_tc5_economy_intel`（註冊於 TC7 後）。TC3 = print SKIP（卡他域）。
- `scripts/debug/framework_validation.gd`（新）：SceneTree harness，每魂一最小場景 → setup → 觸發 → 斷言 probe>0 或印 [DORMANT]。彙整 PASS/DORMANT 報表。
- `docs/known_issues.md`：加「框架驗證套件」段（Part2 全 PASS + dormant-in-default backlog 各魂初判）。

與 spec 差異：無語意放寬。S2b 場景按 plan 授權「調 fixture 使驅力明確」修正（見下）。S4 未新增 probe（`g3.ambush` 既存於 `Probe.ambush_check`，直接複用）。

## Task 1：TC2 / TC5（headless 行為測）

- **TC2 survival-input OK（選=覓食）**：糧 0 隊 → survival-class（覓食）util 壓過貿易，survival 是「輸入贏」非硬閘。
- **TC3 SKIP**：feud→脫軌攻擊需引擎攻擊 option（他域，未決）—— 統一決策引擎切片目前無「攻擊」option（DecisionOptions.REGISTRY 無），故 TC3 無法在引擎層斷言，照 plan print SKIP。
- **TC5 economy-intel OK**：有貨+arb 情報→貿易；無貨無 arb→不撲空式貿易（貿易不入候選）。
- 驗證確認：`_mk_merchant_team(s, vals, has_arb, food)` 簽名 + `DecisionContext.has_arb`（= `OrderSystem.best_arbitrage_order` 非空，來源 team_known order msg）對齊，fixture 未調即過。

## Task 2：Part 2 魂觸發場景（全 7 魂 PASS）

| 魂 | probe | 場景 | 結果 |
|---|---|---|---|
| S1 立國 | `g2.faction_found` | faction 未立國 + ≥2 member + leader 統領.7/野心.9 + readiness 1.0 | **PASS=1** |
| S2a feud | `g2.feud_formed` | `NpcAiSystem.form_feud(victim, perp, 0.8, 0)`（betrayal 等價） | **PASS=1** |
| S2b vendetta | `g2.vendetta_trigger` | 好戰.9/慎重.2 leader + feud≥.6 + 弱小舊仇 | **PASS=1** |
| S3 scout | `g3.scout_dispatch` | FORCE+rung擴張 + attack_score.68 + 慎重.7 + 單低 cred relay claim（uncertainty 高） | **PASS=1** |
| S4 ambush | `g3.ambush` | belief armed_est 2 << 真 pop20×0.5 → `Probe.ambush_check` 判誤導 | **PASS=1** |
| S5 mint | `g1.mint` | tile mint_level1 + 居民 PRODUCE 隊 + ore_gold 100 → `OutpostSystem.tick_all` | **PASS=1** |
| S6 經濟閉環 | `g1.order_fulfilled` | 賣家 sell 單 + 商隊買家 co-locate 市集 → `_resolve_market` settle | **PASS=1** |

**全 7 魂可觸發 = 6 子系統魂 plumbing 無 code-level dormancy。**

### S2b vendetta 診斷（曾兩度 0 → 修 fixture，非語意放寬）

`vendetta_target` gate 全過（回 foe team_id），但 `_evaluate_threat` 先把 avenger 設成 `迎戰`(DEFEND)@PRIO_THREAT(70) → vendetta@PRIO_VENDETTA(55) try_set 被擋。這是 invariant「威脅優先於私仇」的設計優先序，非 dormancy。修正使驅力明確：
- (1) `avenger.known_reputations[foe]=1.0`（公開口碑佳 → hostility=0）；
- (2) avenger pop 30 vs foe pop 3（power_ratio<1 → 弱敵 ThreatAssessment score < 門檻）。
弱小舊仇不構成現役威脅 → 不觸 threat → idle → vendetta@55 設得進。語意正確（vendetta = 強隊追殺已不構成威脅的舊仇）。

### S4 ambush probe — 未新增（既存複用）

plan 指示「grep ambush probe；無則於 ambush_system 加 `Probe.bump("g3.ambush")`」。grep 結果：`g3.ambush` **已存在** —— `Probe.ambush_check(state, atk, def)`（`scripts/debug/probe_stats.gd:31`）計算 belief 低估後 bump，由 `encounter_system.gd:1275`（敗方=攻方時）呼。直接複用，**未改 ambush_system**（避免冗餘 probe）。

## Task 3：2 年 world_sim + 全回歸

- **world_sim 2yr**：`=== world_sim DONE ===`、不變量違反累計=0。
- **預設 2yr 魂 fire 計數**（單 run 快照，非確定性）：
  - fire：`g2.faction_found=1`、`g2.feud_formed=3`、`g1.order_fulfilled=4`、`g1.shortage_buy=2466`、`g1.order_placed=3970`、`g3.trust_up=2617`/`trust_down=1136`、`g2.ambition_promote=66`/`demote=63` 等。
  - **0（dormant-in-default）**：`g2.vendetta_trigger`、`g3.scout_dispatch/converge/timeout`、`g1.mint`、`g3.ambush`。harness 證可 fire → 觸發鏈正確、自然條件罕見（詳 known_issues 各魂初判）。
- **全回歸 headless**：`=== DONE ===`、0 assert、0 SCRIPT ERROR、投靠守恆整合 OK（coin_eq=0）、InvariantAudit population/faction/subteam 全 OK。

## dormant-in-default backlog（記入 docs/known_issues.md）

魂在預設世界 0、harness PASS → 觸發鏈正確但自然條件罕見。各魂初判已記 known_issues「框架驗證套件」段：
- **vendetta**：threat@70 系統性擋 vendetta@55（設計），自然只在「強隊對弱小舊仇」觸發 → 罕見。
- **scout**：需 FORCE+rung+不確定 belief+慎重 leader 同時，預設多親見高 cred 或莽者 → 罕見。
- **mint**：**最可能真缺口** —— 預設 config 疑無金/銀礦 tile + 無 AI 蓋鑄幣廠路徑 → 供給端空。接 G1a 鑄幣 arc。
- **ambush**：純觀測探針，需「攻方低估 belief 且戰敗」事件，該 run 未出現。

## 連動風險

- `scripts/debug/headless_test.gd`：僅新增 2 測試 + 註冊，無改既有測試 / 遊戲 state。**無已知連動風險**。
- `scripts/debug/framework_validation.gd`：純新 debug 腳本（`Probe.enabled` 自管，結尾關閉），不被任何生產路徑引用。**無已知連動風險**。
- 未碰任何 `scripts/simulation/*`（守恆/行為零變）。

## 待主 session 確認

1. **S5 mint dormant-in-default = 最可能的真 backlog**：建議排查預設 `config/world_sim.json` 是否生成金/銀礦 tile + AI 是否有蓋鑄幣廠評估路徑。若皆無 → 鑄幣魂在預設世界永遠空轉（plumbing 對但無供給）。歸 G1a 鑄幣 arc。
2. **TC3 他域**：統一決策引擎切片缺「攻擊」option → feud→脫軌攻擊無法在引擎層斷言。若要 TC3 落地 = 引擎加攻擊 option（他域，需 brainstorm→spec）。
3. world_sim 魂計數非確定性，上述 0/非0 為單 run；harness 為確定性證據。
