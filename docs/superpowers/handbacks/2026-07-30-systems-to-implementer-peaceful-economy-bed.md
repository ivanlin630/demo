---
from: systems
to: implementer
status: open
topic: "[實作·和平經濟觀測床(measure-first Step0)·spec=2026-07-30-peaceful-economy-bed-HOW.md(R²v2 CLEAN)·零sim-code改:①新config/peaceful_economy.json(explicit seeded 好戰=0全隊 faction_id=-1 radius~8 有unowned forest tile)+②薄peaceful_economy_bed.gd(呼WarringHarness.run+印4問報告+逐隊月故事,零RNG可加@observe-pure)·★①/③established隊(非森林outpost level≥1+缺料設施需求_facility_deficit≥CONSTRUCTION_DESIRE_MIN+build-cost含material→need_keep(material)>0)material≈0真缺 forest tile在SEEK_TILE_RANGE=LIVE·★★fixture-liveness斷言t0每①隊need_keep(material)>0+有forest tile否則FAIL拒開工·②料足低設施upgrade·④food下坡runway] 和平經濟床。①/③established+缺料設施need_keep>0=LIVE。liveness斷言機械防死fixture。零sim改。"
branch: feat/peaceful-economy-bed
---

# 實作：和平經濟觀測床（measure-first Step0）

R²v2 CLEAN。**零 sim-code 改**（純 config + 讀-print bed，零行為變/零 RNG）。measure-first Step0：量 economy 是否 fire→blueprint 裁分支。

## spec
`docs/superpowers/specs/2026-07-30-peaceful-economy-bed-HOW.md`（讀它，R²v2 版）。

## scope
1. **`config/peaceful_economy.json`**（explicit、固定 seed、radius~8、resource_richness 5、`好戰:0.0` 全 leader、`faction_id:-1` 全獨立、~12 隊、**確保有 unowned forest tile**）。4 類缺口（§2）：
   - **①founding（×3 established 缺料傍林）**：**非森林 outpost（plains/mountain）level≥1 + 缺料設施需求**（`_facility_deficit≥CONSTRUCTION_DESIRE_MIN`、該格可建、build-cost 含 material）→ `need_keep(material)>0`；`material≈0`、`coin 充`、unowned forest tile 在 `SEEK_TILE_RANGE` 內腳下非 forest。★**不用 fresh 無 outpost 隊**（need_keep(material)≡0 死路）。
   - **②develop（×3 料足低設施）**：`material+tools+coin 充`、`outpost level 1`→upgrade 活分支。
   - **③trade（×3 互補+商隊）**：food 富/料窮 ⇄ 料富/food 窮 + 商隊。★**料窮側須有 outpost+缺料設施需求**（否則 material 軸啞）。
   - **④runway（×2-3 食物下坡）**：food 中等、burn>當地 regen（貧地形）→runway 下坡。
   - 沿 `econ_bed.json`（林業村/平原糧鎮/商隊皆有 outpost）延伸，`慎重≈0.7/野心≈0.3/好戰=0`。
2. **`peaceful_economy_bed.gd`**（薄、`# @observe-pure` marker、零 RNG）：呼 `WarringHarness.run(seed, ~6mo ticks, "res://config/peaceful_economy.json")` + 印 **4 問報告**（§3 probe key）+ **逐隊月故事**（task/resources/gap-status，模 `econ_bed_diagnose.gd:_line`）。

## ★★TDD（fixture-liveness 機械防死 fixture）
- **★t0 斷言**：**每 ①隊 `NeedOracle.need_keep(material)>0`**（+③料窮側）——否則 FAIL 拒開工（fixture 因果死路防護，R² 教訓）。+ 斷言 ①隊有 unowned forest tile 在 `SEEK_TILE_RANGE` 內（founding 靶存在）。
- config 載入 sanity（GameSetup.setup 無錯、~12 隊、有 unowned forest tile）。
- bed headless 0-new、~6mo 無崩、4 問 probe 子集印出、逐隊月故事印出。
- ★bed 零 RNG（純讀+print，@observe-pure marker → observability_gate ③ 掃過不 FAIL）。

## 4 問 tap（全已在 WarringHarness PROBE_KEYS，dump reuse）
1. founding：`indep.found_*`/`indep.gate_*`/`construct.start`/`construct.complete_build`/`worldgen.build_outpost`（gate funnel 分動機無 vs 卡 gate）。
2. develop：`construct.complete_upgrade_facility/upgrade_level`。
3. trade：`trade.deal*`/`g1.order_placed/fulfilled`/`g1.shortage_buy/food_buy/seek_market`/TASK_TRADE。
4. runway：`foodflow.update`/`bridge.no_go_food/topup`/`persist.hold`。

## 交付
handback `to:systems` → R²（實作：liveness 斷言真擋死 fixture、bed 零 RNG、4 問 dump 齊）→ **measurer 跑 → 產 4 問數（★落地 docs/measurements 標 exact path 驗存在）→ 回 blueprint 裁分支（續 runway / pivot economy）**。★execution-verified：4 問看 target 真 fire、gate funnel 分動機無 vs 卡 gate。
