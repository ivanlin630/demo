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
- **新薄 `peaceful_economy_bed.gd`**：呼 WarringHarness.run + 印 4 問格式報告 + 逐隊月故事（QA 稽核）。★零 sim **邏輯**改。**★★訂正（2026-07-30 gate 抓）：bed 是 runner/harness（seed+跑自己世界，同 WarringHarness.run:52-55 seed），`seed()` 是合法世界設置非觀測擾動 → bed **不是** `@observe-pure`**（pure-observe marker 只給「觀測既有 sim 的嵌入式 helper」如 specimen_dump_helper/tracer/probe_stats；runner bed 貼 marker 會被 observability_gate ③ 正確 FAIL on `seed(`）。bed 的 determinism 由 seed() 保證（reproducible），非由「零 RNG」。**category 教訓：measurement BED（driver）≠ observe-HELPER（嵌入式 tap）；只後者 @observe-pure。**
- **★設計選擇（HOW，我定，透明報 blueprint 可否決）**：**sharp hand-authored fixture**（每隊一個「明顯該做 X」的設定）而非 random-mode 全規模「和平旗世界」。理由：(a)零 sim-code 改（random 需改 person_generator archetype 生成=touch determinism）(b)**最決斷**——隊明顯該 found（material=0+料源在旁+有 means）卻不 found＝動機機器壞、難以「碰巧沒隊想 found」搪塞。organic 全規模留 follow-up（若 blueprint 要「warring 世界減戰爭」的 confound-clean 版）。

## 2. peaceful_economy.json 設計（sharp 診斷案，~12 隊）
explicit mode、固定 seed、radius ~8、resource_richness 5（確保有 unowned forest tile＝founding 靶）、`好戰:0.0` 全 leader、`faction_id:-1` 全獨立（無戰爭誘因、無 faction 征服層）。4 類 sharp 缺口各對一問：
- **①founding 測（×3「established 缺料傍林」，★R² 修：established 非 fresh）**：**已有一個非森林 outpost（plains/mountain）level≥1 + 一個缺料設施需求**（該格可建的 facility、`_facility_deficit ≥ CONSTRUCTION_DESIRE_MIN`、build-cost 含 material）→ `need_keep(material)>0`；`material≈0`（真缺）、`coin 充`、**unowned forest tile 在 SEEK_TILE_RANGE 內、腳下非 forest**。→ goal_resolver 活分支：`need_keep(material)>0` 且 holding<need → 試買（有市場→買候選）+ 試採@forest（無自家 forest outpost → **生 founding delegate candidate**，:206-219）。**LIVE 決策：found forest vs 買 vs 不動**——測哪個 fire（都不 fire 才有診斷力）。★**不用 fresh 無 outpost 隊**（`need_keep(material)≡0` bootstrap gap＝holding 0 vs 9999 決策同狀態＝因果死路、不 fire 是 code 可預判必然非經驗問題，known_issues「material-need bootstrap gap」已坐實）。
- **②develop 測（×3「料足低設施」）**：`material+tools+coin 充`、`outpost level 1`→`_find_own_outpost` 成功→`_construction_facility_need` 正常量非 0→該 upgrade facility/level（R² 核乾淨）。
- **③trade 測（×3「互補缺口+商隊」，★R² 修：料窮側須有 outpost）**：food 富/料窮 ⇄ 料富/food 窮 配對 + 一商隊（coin+goods+商業 skill）。★**料窮側須已有 outpost + 缺料設施需求**（否則踩 ①同雷 `need_keep(material)=0`→無「買 material」候選→material 軸啞）；food 軸乾淨（`_self_use(food)>0` 非 outpost-gated、買糧候選正常）。→該 trade 補缺口。
- **④runway 測（×2-3「食物下坡」）**：food stock 中等、burn>當地 regen（貧地形）→runway 下坡→該觸 persist/bridge/maintain_food/founding-elsewhere（food 軸乾淨、R² 核）。
- 沿 econ_bed.json 既有設計（林業村/平原糧鎮/商隊，皆有 outpost）延伸，同款 `慎重≈0.7/野心≈0.3/好戰=0`。
- **★code-provable 已知（非本 bed 測，known_issues 記）**：fresh 無 outpost 隊的「缺料→立國」動機**不存在**（need_keep(material)≡0 bootstrap gap）；fresh settle-motive 走 settle_fit（means-end 三段①，已知 flat）。本 bed ①測的是 **established 隊 secondary-founding**（need_keep>0 的 live 分支）＝A1「founding 從不 dispatch」真對應場景（warring 隊本有 outpost）。

## 3. Step1：量 4 問（tap 全已在 PROBE_KEYS，reuse WarringHarness dump）
1. **founding dispatch 嗎**：`indep.found_ally/subjugate/timeout`、`indep.gate_ambitious/fail_pop/fail_food/fail_busy/fail_nopath/path_ok`、`construct.start`、`construct.complete_build`、`worldgen.build_outpost`。★gate funnel 揭「卡在哪關」（動機無 vs 有動機卡 gate）。
2. **發展嗎**：`construct.complete_upgrade_facility/upgrade_level`、`construct.start`（task=upgrade）。
3. **貿易/對缺口反應嗎**：`trade.deal/deal_market/deal_merchant/barter_deal`、`g1.order_placed/fulfilled`、`g1.shortage_buy/food_buy/seek_market/market_arrive`、TASK_TRADE fire（逐隊）。
4. **runway 機制 fire 嗎**：`foodflow.update`（每日算次數）、`bridge.no_go_food/topup`、`persist.hold`。★這幾個在真經濟脈絡 fire 否＝A/B1/C 機制驗（banked infra 真活否）。
- 全接 tap、逐 tick 可讀（WarringHarness `probe`/`probe_samples` 子集）+ bed 逐隊月故事（task/resources/gap-status）撐 QA 故事稽核。

## 4. Step2：資料分支（blueprint 裁，我只供數）
- **economy 有發生 + runway fire** → runway 沒錯、只測錯條件 → 續 runway、改用和平床驗。
- **economy 不發生**（**live 案**：established 隊 need_keep>0 卻不 found/develop/trade）→ 動機機器壞/沒接＝material/經濟 arc 真內容 → pivot。
- ★我不預設結論、不設閾值（「多少算 fire」blueprint 判）。gate funnel 分清「動機無」vs「有動機卡 gate」（後者 de-patch 補丁閘方向、前者 means-end 動機層）。
- **★honest（R² 教訓）**：**part 的答案已 code-provable、非本 bed 經驗測**——fresh 無 outpost 隊的 material-founding 動機**結構性不存在**（need_keep(material)≡0 bootstrap gap，known_issues 記）。本 bed 只測 **live 案**（established secondary-founding / develop / trade / runway）。∴ pivot 論證須分：(a) code-provable 已知缺口（bootstrap gap + settle_fit flat）＝已是 means-end 全系統 backlog 內容 (b) live 案也失敗＝額外經驗證據。**不能用死 fixture 的必然「不 fire」偽裝成經驗證據支撐 pivot**（那正是 measure-first 要避免的訊號理論式 pivot 的反面陷阱）。

## 5. LOD 註（4 問皆 team-strategic）
WarringHarness all-far（anchor -1,-1）跑：**team-strategic 決策（found/build/trade/runway）all-far 照跑**（warring 床 all-far 仍產 indep.found_*/construct.* 佐證）。person-level breeding（econ_bed_diagnose 用 anchor 帶近區）**非本 4 問範圍**（near-LOD follow-up 若要 person 經濟）。

## 6. 憲法對齊
- 零 sim 邏輯改（純 config + 讀-print bed）＝零行為變、determinism 不受影響。bed 是 runner（seed 跑自己世界）＝**不 @observe-pure**（seed() 合法、marker 會被 gate 正確 FAIL）；determinism 由 seeded 保證（explicit+固定 seed 可重現）。pure-observe helper（specimen_dump_helper/tracer/probe_stats）才 @observe-pure。

## 7. TDD + 驗
- config 載入 sanity（GameSetup.setup 無錯、~12 隊起、有 unowned forest tile）。
- **★★fixture-liveness 斷言（機械防死 fixture，R² 教訓）**：bed/test 在 t0 斷言**每個 ①隊 `NeedOracle.need_keep(material)>0`**（+ ③料窮側同）——否則 fixture 因果死路（自變量無因果連結、不 fire 是必然非經驗）→ **FAIL 拒開工**。這條把「fixture 是否 live」變成機器可驗，防再出「material≈0 但 need_keep≡0」的預判死局。同理斷言 ①隊有 unowned forest tile 在 SEEK_TILE_RANGE 內（founding 靶存在）。
- bed 跑 headless 0-new、~6mo 無崩、4 問 probe 子集印出、逐隊月故事印出。
- ★bed 是 runner（seed 跑世界）＝**不 @observe-pure**；determinism 由 seeded 保證（observability_gate ③ 對 bed 不該 FAIL＝bed 無 marker 不被掃）。

## 8. 交付
→ R²（★異質：sharp-fixture vs organic 選擇合理否/缺口設計真驅動 4 行為否/tap 覆蓋 4 問齊否/bed 零 RNG/LOD all-far 對 team 決策足否）→ implementer（config + 薄 bed）→ **measurer 跑 → 產 4 問數（落地 docs/measurements 標 path）→ 回 blueprint 裁分支**。★execution-verified：4 問看 target 真 fire（gate funnel 分動機無 vs 卡 gate）。
