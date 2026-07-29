---
type: spec
owner: systems
topic: 和平經濟觀測床（measure-first Step0）HOW
status: ready-for-R2
---

# HOW spec：和平經濟觀測床（Step0，量 economy 是否 fire）

> **動機**（blueprint/用戶核可 measure-first，2026-07-30）：team14+A1 兩 victim 都 execution-verify 下溶解＝訊號指向「binding constraint 在上游 economy/motivation 非糧食軸」，**但別憑訊號理論式 pivot**——先量掉 confound：「runway 建錯軸」vs「測錯條件（warring 壓掉經濟）」。現況只有 warring 床＝根本觀測不到經濟行為（戰爭吃掉立國/發展時間）。需 **seeded、和平、有缺口驅動**的床看得見經濟，量 4 問，資料裁分支。

## 1. scope（零 sim-code 改，只加 config + 薄 bed）
- **新 `config/peaceful_economy.json`**（主交付）：hand-author explicit、seeded、`好戰=0` 全隊、設計 sharp 經濟缺口。
- **reuse `WarringHarness.run(seed, ticks, config_path)`**（通用 runner，4 問 tap 全已在 `PROBE_KEYS`）跑它。
- **新薄 `peaceful_economy_bed.gd`**：呼 WarringHarness.run + 印 4 問格式報告 + 逐隊月故事（QA 稽核）。★零 sim 邏輯、零 RNG（守 [[feedback_observer_no_global_rng]]，bed 純讀+print）。
- **★設計選擇（HOW，我定，透明報 blueprint 可否決）**：**sharp hand-authored fixture**（每隊一個「明顯該做 X」的設定）而非 random-mode 全規模「和平旗世界」。理由：(a)零 sim-code 改（random 需改 person_generator archetype 生成=touch determinism）(b)**最決斷**——隊明顯該 found（material=0+料源在旁+有 means）卻不 found＝動機機器壞、難以「碰巧沒隊想 found」搪塞。organic 全規模留 follow-up（若 blueprint 要「warring 世界減戰爭」的 confound-clean 版）。

## 2. peaceful_economy.json 設計（sharp 診斷案，~12 隊）
explicit mode、固定 seed、radius ~8、resource_richness 5（確保有 unowned forest tile＝founding 靶）、`好戰:0.0` 全 leader、`faction_id:-1` 全獨立（無戰爭誘因、無 faction 征服層）。4 類 sharp 缺口各對一問：
- **①founding 測（×3「缺料傍林」）**：`material≈0`、`food/coin 充`、`pop 6-8`（有 means dispatch 子隊）、**擺在 unowned forest tile 旁**。經濟邏輯→該 found forest outpost 拿木 或 trade 買料。兩者皆不 fire＝動機壞。
- **②develop 測（×3「料足低設施」）**：`material+tools+coin 充`、`outpost level 1`→該 upgrade facility/level。
- **③trade 測（×3「互補缺口+商隊」）**：food 富/料窮 ⇄ 料富/food 窮 配對 + 一商隊（coin+goods+商業 skill）→該 trade 補缺口。
- **④runway 測（×2-3「食物下坡」）**：food stock 中等、burn>當地 regen（貧地形）→runway 下坡→該觸 persist/bridge/maintain_food/founding-elsewhere。
- 沿 econ_bed.json 既有設計（林業村/平原糧鎮/商隊）延伸，同款 `慎重≈0.7/野心≈0.3/好戰=0`。

## 3. Step1：量 4 問（tap 全已在 PROBE_KEYS，reuse WarringHarness dump）
1. **founding dispatch 嗎**：`indep.found_ally/subjugate/timeout`、`indep.gate_ambitious/fail_pop/fail_food/fail_busy/fail_nopath/path_ok`、`construct.start`、`construct.complete_build`、`worldgen.build_outpost`。★gate funnel 揭「卡在哪關」（動機無 vs 有動機卡 gate）。
2. **發展嗎**：`construct.complete_upgrade_facility/upgrade_level`、`construct.start`（task=upgrade）。
3. **貿易/對缺口反應嗎**：`trade.deal/deal_market/deal_merchant/barter_deal`、`g1.order_placed/fulfilled`、`g1.shortage_buy/food_buy/seek_market/market_arrive`、TASK_TRADE fire（逐隊）。
4. **runway 機制 fire 嗎**：`foodflow.update`（每日算次數）、`bridge.no_go_food/topup`、`persist.hold`。★這幾個在真經濟脈絡 fire 否＝A/B1/C 機制驗（banked infra 真活否）。
- 全接 tap、逐 tick 可讀（WarringHarness `probe`/`probe_samples` 子集）+ bed 逐隊月故事（task/resources/gap-status）撐 QA 故事稽核。

## 4. Step2：資料分支（blueprint 裁，我只供數）
- **economy 有發生 + runway fire** → runway 沒錯、只測錯條件 → 續 runway、改用和平床驗。
- **economy 不發生**（有缺口卻不 found/develop/trade）→ 動機機器壞/沒接＝material/經濟 arc 真內容 → pivot。
- ★我不預設結論、不設閾值（「多少算 fire」blueprint 判）。gate funnel 分清「動機無」vs「有動機卡 gate」（後者 de-patch 補丁閘方向、前者 means-end 動機層）。

## 5. LOD 註（4 問皆 team-strategic）
WarringHarness all-far（anchor -1,-1）跑：**team-strategic 決策（found/build/trade/runway）all-far 照跑**（warring 床 all-far 仍產 indep.found_*/construct.* 佐證）。person-level breeding（econ_bed_diagnose 用 anchor 帶近區）**非本 4 問範圍**（near-LOD follow-up 若要 person 經濟）。

## 6. 憲法對齊
- 零 sim 邏輯改（純 config + 讀-print bed）＝零行為變、determinism 不受影響。bed 零 RNG（[[feedback_observer_no_global_rng]]，可加 `# @observe-pure` marker 納新閘）。seeded 可重現（explicit+固定 seed）。

## 7. TDD + 驗
- config 載入 sanity（GameSetup.setup 無錯、~12 隊起、有 unowned forest tile）。
- bed 跑 headless 0-new、~6mo 無崩、4 問 probe 子集印出、逐隊月故事印出。
- ★bed 零 RNG（specimen/determinism 無關，純讀）。

## 8. 交付
→ R²（★異質：sharp-fixture vs organic 選擇合理否/缺口設計真驅動 4 行為否/tap 覆蓋 4 問齊否/bed 零 RNG/LOD all-far 對 team 決策足否）→ implementer（config + 薄 bed）→ **measurer 跑 → 產 4 問數（落地 docs/measurements 標 path）→ 回 blueprint 裁分支**。★execution-verified：4 問看 target 真 fire（gate funnel 分動機無 vs 卡 gate）。
