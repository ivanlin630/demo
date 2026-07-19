---
from: implementer
to: measurer
status: consumed
topic: "[② 絕境階梯失敗回饋 done·待 sim measure·seed1337 latch 7隊主靶] committed option stall 偵測(relief before/after magnitude 禁瞬時)→硬排除 cooldown 換次格(reject_cooldown idiom)+單一 option 豁免(無次格 ride 窮死非 idle-churn)。人格 慎重/求生欲(禁虛構 trait)。TDD survival_stall_ladder_test ALL PASS;gate 64 removed=0;headless base(1132bf0c)-vs-mine 逐條 IDENTICAL(0 new)。branch feat/desperation-ladder-feedback@ed2fdff6 off ①-merged local main(1132bf0c)。★seed1337 latch 7隊主靶:卡格→stall→換格 or 無階可爬 ride 窮死;無 idle-churn/ping-pong/新 thrash。is_sim=true+seed1337/42/4201→.qa.json。"
---

# ② 絕境階梯失敗回饋 done（待 sim measure）

## 機制（坐實 main 實況）
main 無 famine-amplifier（`grep famine_severity`=0，① 只 merge priority_for）。真 live 絕境 boost = `SURVIVAL_BOOST_FLOOR/MAX`（集體等量 **order-preserving**）→ 最高 base-weight survival 格恆贏、深餓只集體浮高不換序 → **QA 揭的 7 隊卡單一格 33+天 latch**。
∴ ② = 在既有 SURVIVAL_BOOST 上加**失敗回饋**（唯一產階梯 progression 的機制）。

## 做了什麼
- **S1 stall 偵測**（`decision_engine.gd` 純 helper）：`stall_verdict(committed baseline vs after-N-days food)` — relief≥MIN→RESOLVING、不足/plateau/惡化→STALLED、未到窗→WAITING。**before/after magnitude 非瞬時比昨日**（防單 tick blip 誤 reset + 慢產 plateau 誤判 resolved）。
- **蓋章**：`_trigger_survival:3370` try_set 成功站蓋 **真 option 字串**（分辨掠奪/佔村皆 TASK_ATTACK；non-unified 無 current_option 語意故不讀它）+ tick + food baseline。換新 option 才重蓋，同 option 續承諾則 baseline 保留累積時間。
- **S2 硬排除換格**：stall → `survival_stall_cooldown[opt]=tick+WINDOW` → `rank_survival` 排除 cooldown 內 option → argmax 選次高 base-weight applicable 格。**硬排除非軟降權**（避跟 SURVIVAL_BOOST 2.5+COMMITMENT 0.3 量級混戰）。
- **★單一 option 豁免**：排除後無次格 → 不排除（**ride 窮死=intended fallback，非 release/idle-churn**）。
- **人格**：`STALL_DAYS = STALL_BASE × (慎重 + (1−求生欲))`。既有 trait，**禁虛構堅忍**。慎重↑撐久、求生欲↑急換。
- **ping-pong 防**：window(20 天，> STALL_DAYS) + expiry-on-relief；recover-restarve 邊界重置 baseline。

## 驗（我側）
- TDD `survival_stall_ladder_test.gd` **ALL PASS**（verdict 三態 + plateau=STALLED + baseline-not-yesterday / patience 慎重求生欲雙方向 / 排除+單一 option 豁免+全 stall ride+expiry+過期不排）
- `constitution_gate` PASS（sites=64, removed=0）
- **headless base-vs-mine 逐條 `diff` IDENTICAL**（stash ② 跑 base 1132bf0c = 同 3 pre-existing：Team23 紮營 order=-1 ×2 / 追目標未加入攻擊 goal，0 new）

## ★需你做（sim measure）
branch `feat/desperation-ladder-feedback@ed2fdff6`（off **local main 1132bf0c** = ① 已含）。
- `.measure.json` **`is_sim: true`** + **seed1337 + 42 + 4201**
- QA 出 **`.qa.json` verdict**（gate 強制 sim 缺 QA→FAIL）
- **★seed1337 = latch 7 隊主靶**（QA 原揭）：驗
  - 卡格隊 → committed N 天無 relief → **stall → 換次格**（真攀階梯：紮營 stall→改乞/投靠）
  - **或 無階可爬**（唯一 applicable survival 格）→ **豁免 ride 窮死**（intended，非 idle-churn）
  - **無新 thrash / ping-pong / idle-churn / release-churn**
  - `Probe: survival.stall_exclude` 觸發次數（stall 換格頻率=健康指標）
  - 世界 sustain（不因換格連鎖塌）

## 溯源
dispatch `2026-07-18-systems-to-implementer-desperation-ladder-feedback.md`；spec v2（異質 R² round2 CLEAN）；[[project_desperation_economy]]、[[feedback_symptom_vs_root_retry]]。
