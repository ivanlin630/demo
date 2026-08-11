# iii 絕境排序底查 measure-HOW（死亡螺旋 per-option util dump、兩 mispricing 定位）

**status**: measure-spec（底查、量測員執行；核心=既有機制純讀 + 補 pure-read 值 taps 填觀測 gap）。
**用戶**: 拍 A（2026-08-11）iii 絕境排序 arc 開跑。measure-first 底查（禁靜態斷言、dump per-option util 再開藥、[[feedback_measure_peroption_util_before_decision_claim]]）。
**genuine 命門**: 目標=兩 util 校正成**反映真實期望值（可逆性/後果）**、非 boost 求援逼 fire（[[feedback_genuine_value_not_crank]] 乙教訓雙向：不刪 genuine desperation-defection）。

---

## 底查問題（blueprint 定）
死亡螺旋床（seed8181 Team2 或同型餓死隊）逐決策點 dump per-option util，定位兩 mispricing + 確認真 lever vs 第三因。

## ★grounding（systems code-read、兩 mispricing code-visible 待 dump 確認）
- **①求援 mini-util**（`_try_herald_side:1994`）：`need_severity × P(help) × INFO_RELIEF_EXPECT(2.4) − INFO_ANON_COST(0.8)` × `_help_pmult`（傲慢↓/務實↑）。★疑=**無「可逆性/留勢力低成本」因子**（競爭 raw 期望紓困、早期 need 不夠→util 低）→ day23 太低。
- **②叛離 defect_util**（`event_faction_defect`）：`distress_pressure × loyalty_deficit − stay_benefit`（unrest≥20 gate）。★疑=**無 price factionless→relief 不可達→死 後果**（隊 starvation-state 未 factored 進「叛離後果」）→ day25 fire 通往死。

## ★量什麼（兩 util 軌跡 + terms + per-option 橫排）
死亡螺旋 day18-28 race 窗口（focus）、逐日 Team2：
1. **求援 mini-util 軌跡** + 分解 terms：`need_severity`（runway/food 缺口）/ `P(help)`（施助者可達）/ `INFO_RELIEF_EXPECT` / `INFO_ANON_COST` / `_help_pmult`（人格）。→ day23 為何太低：真 low（還沒絕境=genuine）還是缺可逆-低成本因子（mispricing）？
2. **叛離 defect_util 軌跡** + 分解 terms：`distress_pressure` / `loyalty_deficit` / `stay_benefit`。→ day25 fire 時：有無 factored「叛離後果=factionless→relief 不可達→死」（現公式無此項=mispricing）？
3. **per-option util 橫排**（Team2 在 decide tick）：求援 vs 叛離 vs 逃（遷移找糧/覓食）vs 撐（survival/停留）——整條螺旋誰贏誰輸、確認兩 mispricing 是**真 lever** vs 第三因（e.g. 逃早該 fire 但沒？撐 util 異常？）。

## ★觀測 tap 補（pure-read、填觀測 gap、觀測鐵律 §全量暫態可觀測性）
現 gap：求援 mini-util 值未 tap（只 severity_positive fire、對比 distribute/migrant.mini_util:1678/1714 有值）；defect_util 值+terms 未 tap（只 cohesion.defect_fire）。→ 補：
- `Probe.note("help.mini_util", util)` + 分項（mirror 既有 distribute/migrant.mini_util 範式=填 herald 觀測 gap、permanent-worthy）。
- `Probe.note("cohesion.defect_util", defect_util)` + `distress_pressure`/`loyalty_deficit`/`stay_benefit` 分項。
- ★純讀零 RNG 零行為變（Probe.note 觀測、[[feedback_observer_no_global_rng]]）；量測員可 env-gated 診斷版跑（ANON_TRACE 前例）或提議 permanent 補（herald mini_util gap 值得永久填）。

## ★分類判準（genuine 命門）
- **求援 too-low**：(a) genuine（還沒絕境、severity 真低=正確、非 mispricing）vs (b) mispricing（絕境了但缺可逆-低成本因子→util 該高沒高）。
- **叛離 mispriced**：(a) 有 price 後果但仍 fire（genuine desperation-defection、iii 該保）vs (b) 無 price 後果（餓叛通往死卻不知=該加 consequence 項）。
- ★**驗差異能否從 state 湧現**：「餓叛→通往死=util 該低」「野心叛吃飽→util 該高」——兩情境 defect_util 差異是否已從 state（starvation vs ambition）湧現，還是死常數不分？

## output（→ blueprint）
兩 util 軌跡 + terms 分解 + per-option 橫排 → 定位 mispricing（哪個/都是/第三因）→ 餵 blueprint spec iii genuine repricing（求援加可逆-低成本真值 / 叛離加後果真值 / proportionate ladder）。
- ★禁靜態斷言：兩 mispricing code-visible 但**由 dump 確認**是真 lever（arc 錯 6 次前科）。
- 序：底查 dump → 附 specimen（長跑）送 QA 故事稽核（餓隊逐決策 motive→util→action）→ blueprint spec iii → R①/R² → build → 驗（餓隊求援先 fire + 絕望才叛 + 餓叛率降 + 故事合理）。地基 KEEP。
