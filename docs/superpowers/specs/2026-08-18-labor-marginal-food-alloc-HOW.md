# labor-slice：食物工位邊際分配 + 估算器 coherence（HOW / systems）

status: DRAFT→R²（2026-08-18）
owner: systems（HOW）← FUY (iii) 結構墊底 CONFIRMED + blueprint 邊際方向裁定 + 估算器 mandatory 裁定
溯源：FUY per-team 定案 (iii) 結構墊底（farming_level 1→flabor0.267/2→0.103/3→0.067 單調斷崖=發展農田反被懲罰）→ equal-need-weight 機制結構性餓死進步者。blueprint 邊際分配=正解 + 估算器 coherence mandatory（打包一 slice 免中間態不一致）。

## §0 命門（HOW 守）
- **★fp intended-change**（分配+估算器行為變、非 byte-identical）；標注 fp。
- **感知鐵律全 self-knowledge**：per-labor yield 讀 own-tile（own farming_level/own productivity/own harvest）、估算器讀 own-state（own-tile/own-farming/own-labor）、**無 god-view**。
- **★禁優先序常數/禁 crank**：邊際分配靠**真 per-labor yield**（farm 發展好自然贏野採=湧現非規則）；yields 從既有真公式（非發明 boost）。
- **guns-vs-butter 保**：動員後只算未動員勞力（labor_system:43 既有）不動。
- **守恆保**：farm_yield chokepoint（農業a）不動。

## §1 現況（grounded）
- **分配**（labor_system:45-93）：`demand gather:food=K_GATHER(5)` 固定、`farm=farming_level×K_FARM(5)` 隨 level 長；need-weight 兩者**相等**（皆 `need_keep+demand("food")`、:103==:115）；比例分配 capped-by-demand → gather 小桶先 cap 讓配額、farm 大桶恒填不滿=結構墊底。
- **per-labor yield 可算**：gather:food=`productivity×COLLECT_RATE`(resource:295)、farm=`farming_level×FARM_UNIT_YIELD×harvest_factor`(農業a)。
- **估算器 stale**：`food_flow._sustainable_inflow:46-47` `farming_bonus=1+farming_level×0.5` 乘入 inflow=OLD gather-boost（農業a 移除的 :289 同式）；`MarginalEconomy._inflow_est` 鏡射。

## §2 Task（TDD、每 task 跑 headless 驗）
### T1：食物工位邊際分配（同資源內按 per-labor yield 分、跨資源留 need-weight）
- **識別食物工位組**：`gather:food` + `farm`（同產 food）。
- **★分配法**：食物組**合併 need-weight=food_need**（對跨資源 food-vs-material 不變）、**組內按 per-labor yield 比例分**：
  - gather:food share = food_need × `yield_g/(yield_g+yield_f)`；farm share = food_need × `yield_f/(yield_g+yield_f)`。
  - `yield_g=productivity×COLLECT_RATE`（own-tile）、`yield_f=farming_level×FARM_UNIT_YIELD×harvest_factor`（own-tile）。
  - → farm 發展好（高 farming_level→高 yield_f）自然拿多、野採低產 tile 讓位=**湧現非優先序常數**。
- **cross-resource（food vs material vs mfg）留原 need-weight**（不動）。demand-cap/溢出串聯機制保留。
- **★純算術零 randf**（determinism、yields 從既有公式）。
- **TDD**：①食物組內 gather:food/farm 按 per-labor yield 比例分（非 equal-split）②farm 高 level→拿多份（level↑→farm flabor↑=治斷崖）③cross-resource food-vs-material 比例不變（食物組合併 weight=food_need）④未發展團（farming_level=0 無 farm 工位）gather 照舊。

### T2：估算器 coherence（食物物理新形狀、mandatory）
- **`food_flow._sustainable_inflow`**：移 `farming_bonus=1+farming_level×0.5` gather-boost、改**加項 farm_yield 貢獻**：`inflow = wild_gather_sustainable + farm_yield_contribution`。
  - `farm_yield_contribution = farming_level × FARM_UNIT_YIELD × harvest_factor × expected_farm_labor_fill`（★**勞力飽和因子**=labor-starved 時 ROI 誠實變低、治「投資報酬騙人」老雷；expected_fill 從 own-tile labor_alloc[farm].fill 或估）。全 self-knowledge。
- **`MarginalEconomy._inflow_est`**：鏡射同步（est-based struct、VillageEstimate 帶 farming_level+labor 估）→ camp_marginal/facility_roi 誠實反映 labor-starved farm ROI。
- **★一致**：估算器新物理 == T1 分配用的 per-labor yield 同源（allocation 用物理、estimator 建模同物理=coherence）。
- **TDD**：①_sustainable_inflow 移 farming_bonus 加 farm_yield 貢獻含勞力飽和 ②facility_roi(farming) 誠實（labor-starved→ROI 低、非舊 boost 假高）③estimator==allocation 同 per-labor 物理源 ④self-knowledge 無 god-view（VillageEstimate est-based 防線守）。

## §3 gate（measurer bounded、綠才 merge）
1. **★治斷崖**：發展 farm 團 flabor 隨 level **回正相關**（level↑→farm flabor↑、非現 0.267→0.067 負斷崖）。
2. **未發展團 gather 照舊**（farming_level=0 無變）。
3. **guns-vs-butter 動員照抽**（未動員勞力才算、動員→產掉）。
4. **估算器誠實**：facility_roi(farming) labor-starved 時 ROI 低（非舊 boost 假高）；camp_marginal 反映新物理。
5. **cross-resource 不亂**：food-vs-material-vs-mfg 比例合理（食物組合併 weight 保）。
6. determinism byte-identical（純算術零 randf）；constitution 綠；守恆稽核含 farm_yield 照關；**fp intended-change 標注**。

## §4 界外
- FARM_UNIT_YIELD/K_FARM 絕對量級 tune=12mo 大考 story-A（本 slice 治分配結構、非常數 tune）。
- ①pop 假說（大團 vs 小團）=warring config 另驗（本 slice 治結構、pop-emergence 正交）。

序：R² 審此 HOW（★邊際分配非優先序常數+估算器 coherence self-knowledge+cross-resource 不亂）→ CLEAN → dispatch（base post-農業b 或現 main）→ gate → merge。地基 KEEP。
