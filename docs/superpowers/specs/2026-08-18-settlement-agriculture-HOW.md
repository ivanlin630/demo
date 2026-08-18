# settlement 農業：農田獨立生產線 + ⑥ 據點結構放大器（HOW / systems）

status: DRAFT→R²（2026-08-18）
owner: systems（HOW）← settlement design §3 + mechanism-intents「農田」row（獨立產糧不經野地池）+ ⑥ 人口 ruling（領導唯一準則+據點結構放大器、基數一起 tune）
溯源：S2b MERGED（L0→L1 工期）→ 農業歸位（§3）+ 據點放大器（⑥）。**★grounded drift 發現**：`farm_yield` chokepoint **全樹 0 處**（窮盡 grep no-head、intent 龍頭未建）；farming 產糧**只 `resource_system:289 gain*=(1+farming_level×0.5)`=gather-gain 乘數**（drift：現 farming_level 只 boost 野地池採集、非獨立線）=mechanism-intents「農田=獨立產糧不經野地池」的 **code 與表不符**（意圖帳權威→正位）。

## §0 命門（HOW 守）
- **★drift 正位（意圖帳權威）**：農田現況（gather 乘數）≠意圖（獨立生產線）→ 本 slice 正位。**farming_level 從 gather-乘數改為驅動獨立農田產出線**（野地池採集與農田生產**互不相干**=雙源）。
- **★禁 crank / genuine value**：farming 產出=真物理（等級×單位×勞力工位×季節）、labor 從勞力池抽（guns-vs-butter 自動、[[project_size_matter_arc]] 勞力池共讀）；**farming_level 升級走既有 construction spine**（投資=真工期真料、非白灌）。
- **守恆=可溯源**：farm_yield 走 chokepoint（`TileBank.deposit(...,"farm_yield")` 同 ResourceBank reason 慣例、守恆稽核含農業）。**resource 分類學入 invariants**（零生成 礦寶 / 自然再生 野味藥草野馬 / 生產類 食物 / 木材=採集加速）。
- **感知鐵律不動**：農業=自家據點自家勞力自家糧倉（own-state self-knowledge、非 god-view）。
- **★據點放大器禁死常數 pop 曲線**：⑥ pop-cap 放大器=據點發展的結構函數（level/設施）、非查表死曲線。

## §1 現況（grounded 窮盡）
- `farming_level` 40 處/11 檔；**唯一產糧用法=`resource_system:289 gain*=(1+farming_level×0.5)`**（gather 乘數 drift）。
- `farm_yield` chokepoint=**0 處**（未建、本 slice 建）。
- pop_cap=`team_data:48 pop_cap_from_leadership`（clampi 49×min(skill/0.8,1)+1、**領導唯一**、無據點放大）。
- 勞力池 `LaborSystem`（採集+製造共讀 allocator、[[project_size_matter_arc]] 勞力池）；farming 工位=新 demand 源接此。
- 既有 construction spine（`_tick_construction`/`_complete_construction` upgrade_facility 分支）=farming_level 升級複用。

## §2 Slice 拆分

### 農業a：農田獨立生產線 + drift 正位（§3 核心）
- **獨立產出**：新 farm-production 每日 cadence——`農田產出 = farming_level × UNIT_YIELD × farm_labor工位 × harvest_factor(季節)` → **deposit 自家糧倉、tag `farm_yield`**（TileBank chokepoint 守恆）。
- **★drift 正位**：`resource_system:289` gather 乘數**移除**（farming_level 不再 boost 野地池採集）；野地池採集（既有 harvest）與農田生產**雙源獨立**。
- **要勞力**：farm_labor 工位=勞力池新 demand（`LaborSystem` 接、與 gather:food/material/mfg 競爭=guns-vs-butter 自動）。
- **吃季節**：`harvest_factor(season)` 調制（季節機制若無則 TEST VALUE 佔位、記 backlog）。
- **farm_yield chokepoint**：`TileBank.deposit(tile,"food",amt,"farm_yield")`；守恆稽核（InvariantAudit）含農業源。
- **TDD**：①農田產出獨立入糧倉標 farm_yield（守恆帳平）②farming_level 不再 boost gather（:289 移除、gather 純野地池）③farm_labor 抽勞力池（gather 掉=guns-vs-butter）④harvest_factor 季節調制⑤無 farming_level→產出 0（無田不產）。

### 農業b：⑥ 據點結構放大器 pop-cap（人口 ruling）
- **pop-cap 放大（★乘法、R² 建議定案）**：`effective_pop_cap = pop_cap_from_leadership(領導基數) × 據點結構放大器(outpost_level/設施發展)`——**乘法非加法**（R² 建議：MarginalEconomy._inflow_est `outpost_mult×pop_mult×farming_bonus×…` 乘性合成先例；乘法讓「好領主+好據點」複合放大、「爛領主+好據點」不靠據點單撐到好領主承載量=語意符「據點是領導力**放大器**」⑥ ruling 字面）→ **居民團據點發展→承載更多**（size 靠據點 genuine、非死曲線）。**基數(領導)+放大器一起 tune**（⑥ 明示）。**★L0 不放大 auto**：L0 `outpost_level=0`→放大器天然=1（S2a camp_level 獨立 flag 已確保 L0 無 outpost_level>0、結構自動成立、零額外 code）。
- **★禁死常數 pop 曲線**：放大器=據點 level/設施的結構函數（發展越高承載越大=genuine 投資回報）、非查表。
- **感知鐵律**：讀自家據點自家 level（self-knowledge）。
- **TDD**：①據點 level↑→effective_pop_cap↑（放大器生效）②領導基數仍為底（無據點=領導帽、L0 不放大=界線守 S2a）③overflow（pop>effective_cap）走既有 check_overflow_for_team④基數+放大器 tune 後合理量級（不爆不塌）。

## §3 gate（measurer bounded、綠才 merge）
1. **雙源獨立**：農田生產+野地池採集互不相干（farming_level 不再 boost gather、農田獨立入倉標 farm_yield）。
2. **守恆可溯源**：farm_yield chokepoint tagged、守恆稽核含農業、GRAND 帳平。
3. **guns-vs-butter**：farm_labor 抽勞力→gather 掉（勞力池競爭真發生）。
4. **據點放大器 genuine**：據點發展→pop-cap↑（size matter via 據點、非死曲線、L0 不放大）。
5. **★★量化食物帳（R² 必查項、大改命門、農業a 硬 gate）**：drift 正位（移除 :289 gather 乘數 + 新增獨立農田線）**前後聚合對比**——measurer 量**全樹 food production 總量 + team food-security 分布**，**驗淨效應無意外暴衝/塌陷**（★`UNIT_YIELD` 量級須校準得 **≈ 被移除的 `×(1+farming_level×0.5)` 乘數量級**：拍太低→淨食物驟降 mass-starve、拍太高→糧食經濟被削弱失意義）。非只驗「兩系統概念獨立」、要驗**總量級守住**。
6. determinism byte-identical（農業純算術+既有 chokepoint、無新 RNG）；constitution 綠；**禁 crank（R² 命門）**。fp intended-change（drift 正位+新生產線=行為變大）。

## §4 界外
- §4 戰略蓋點決策（含 §4 de-scaffold L0→L1 折入引擎 hard gate）=農業後 next。
- 季節機制完整（若 harvest_factor 佔位）=backlog。植林/軍事選址=next arc。

序：R² 審此 HOW（drift 正位健全性+禁 crank+守恆+據點放大器非死曲線）→ CLEAN → 農業a plan → dispatch（base post-S2b main）→ gate → merge → 農業b → §4。地基 KEEP。
