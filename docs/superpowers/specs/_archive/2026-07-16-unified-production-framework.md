# Spec：統一生產/發展框架 v2（de-patch 設施決策入思考層）

> **狀態：R① CLEAN + R² 補裁 5 項額外閘後待 re-R²（2026-07-16）→ CLEAN 才 impl。**
> R② round1：R① 兩致命解法全 CLEAN，但漏裁 v1 異質審同批 5 項額外補丁閘/風險（礦山 override/farming 不拆/survival 特例/govern 雙寫/tap 2 缺口）——已於 §R² 補裁 + S1.3 + S4 逐項裁定（拆/留為規則/de-patch/併入既有 term），對齊藍圖「拆光全部」。
> v1（天真 de-patch：拆 override 讓人格 argmax 選 farming）被 R① 異質手算推翻——普通地力餓隊會蓋工坊餓死（override 是**承重的**）+ means-end 斷鏈（獨立隊永無建設路）。v2 訂正經 R① re-verify CLEAN（reviewer 獨立重算公式全 match、4 訂正結構站得住）。
> **★誠實標記**：本 spec 兩項屬**行為層待 measurer 坐實**（非篤定 emergent）：①urgency 真 sim fire 頻率 ②統一發起真讓 has_facility 成長。impl 後 full-HD 驗。

> 生產 arc（甲）。用戶定：拆光生產/設施補丁閘融框架（引擎+人格），無殘補釘再量。
> **原則（憲法精準版）**：框架管**規則/機制**（不決定），思考=**DecisionEngine+人格**。de-patch=決策**抽出**機制交思考層，非硬邏輯**搬進** code。

## 根（measurer + 靜態稽核 + R① 手算，全坐實）
- **supply-wall-root**：has_facility 恆=1、goods holding 恆=0、`[Manufacture]` 6 次、TASK_MANUFACTURE dispatch 1→11 每 tick 空轉 no-op。
- **A1 恆-hungry override**（`faction_ai:2942-2950`）：hungry early-return farming，跳過 `_facility_score` 人格 argmax。seam：`own_granary_tile`（`resource_system:386-390`）**位置相依**（隊當下不站自家 outpost tile → 回 null → effective_food 退私產≈0 → 誤 hungry）。**★R①：override 是承重的**（補償壞公式 `_facility_score` 防餓死，見下）。
- **A2 製造無 precondition**（`options.gd:71-72` `"生產"` 只查 `has_own_outpost`；死碼 `_can_manufacture:2103-2121` 有正確 has_facility 邏輯但零 caller）→ 無設施選製造 → `manufacturing_system:90-93` `level<=0 continue` no-op。**最擋 surplus。**
- **A3/A4**（`faction_ai:2858-2931`）：infra 固定 if 階梯（升級>擴建>攢公庫強制 GOVERN>蓋新）first-match。
- **★means-end 斷鏈（R① 抓，systems 親驗）**：`_evaluate_infrastructure` 只 `for fid in state.factions`（`faction_ai:662-676`）→ **`faction_id=-1` 獨立定居隊永無設施建造路徑**；「建設」option=TASK_BUILD 只推既有工地。
- **E 製造 no-op 無 tap**（`manufacturing:78-93` 各 continue 無 Probe.bump）→ 違全量暫態可觀測。
- **★核心敘事訂正（R① 手算）**：`_facility_score = terrain × (1+deficit) × personality`，deficit clamp[0,1]（快餓死=略缺=1.0 無量級）。中性人格+餓+鄰森林村：harvest 1.0 → farming 2.30 vs **workshop 4.40**（餓仍蓋工坊）。∴ **拆 override 讓 argmax 自然選 farming ＝假**（除非地力≥~1.91）。

## 規則 vs 思考分層
**機制/規則（flat，世界物理）**：`FACILITY_DEF` cost/ticks/產出、slot cap、`FOOD_PER_PERSON_PER_DAY`(=0.8)、farming/manufacture 產什麼、守恆、**「製造需設施」precondition**。
**決策/思考（引擎+人格）**：建什麼設施、食安 vs 發展、升級/擴建/govern/蓋新、想製造→需設施→去蓋。
**常數分層（★R① 訂正，明文釘死防整串人格化）**：
- **人格化（決策門檻）**：`×7`（安全天視野）、best_score `0.05`、farming deficit target 的視野天數、`GOVERN_MATERIAL_TARGET`。
- **flat（世界物理，禁動）**：`×0.8`=`FOOD_PER_PERSON_PER_DAY`（代謝，「慎重的人比較不餓」荒謬）、facility material cost、build ticks、slot 數。
- **`TARGET_PER_POP` 雙身分分離成兩常數**：manufacturing 配方 sort key（物理）/ workshop deficit target（決策）。

## 交付切片（impl TDD；★序照藍圖：score 修好才拆 override，全程無餓死窗口）

### S1 — 製造 precondition 規則 + no-op tap（A2 + E）
1. **`DecisionContext` 加 `has_manufacturing_facility`**（重用死碼 `_can_manufacture` 設施查邏輯：本格任一 `RECIPE_GROUPS` level>0 + 生產權 owner/同 faction）。
2. **`options.gd:71` `"生產"` applicable 改** `if ctx.has_own_outpost and ctx.has_manufacturing_facility`（補缺規則）。「駐守」維持 `has_own_outpost`。
3. **tap（★R² 補裁：明列全 no-op 路徑，防下一個 tap-gap）**：`manufacturing_system` **每條** no-op continue 各掛 `Probe.bump`：
   - `tile==null or outpost_level==0`（`:78`，據點消失後殘任務空轉）→ `manufacture.noop_no_outpost`。
   - `not _team_works_tile` / `not _has_resident_on_tile`（`:80-84`）→ `manufacture.noop_no_worker`。
   - `level<=0 continue`（`:90-93`，無設施）→ `manufacture.noop_no_facility`（A2 主病）。
   - **★`_run_recipe_group` 原料不足靜默 no-op**（`_can_consume_scaled` 不過→`return ""`，有設施+resident 但 material 不夠每 tick 空轉，跟 A2 同型「病躲很久」）→ `manufacture.noop_no_material`。
   - `options.gd` 生產被 precondition 濾 → `produce.appl_kill_nofacility`。
   **觀測禁耗 RNG/禁污染**（byte-identical、盲點閘③④⑤綠）。

## §R² 補裁：額外補丁閘（★藍圖「拆光全部」，避免打地鼠）
v1 異質框外審同批找到、與 A1-A4 同型的 5 項，逐項裁定寫入（reviewer R² issue）：
1. **礦山強制 civilian override**（`faction_ai:2923-2930`）→ **de-patch（S4）**：`_pick_outpost_type` 人格秤（`:2827-2835`，設計良好）被「含礦→硬改 civilian」蓋掉＝同 A1 病。融「ore 機會」進人格秤（ore→civilian 加分，貪婪/mint-inclined 領袖偏採礦村；好戰可仍選軍鎮防守）→ 移硬 override。決策交人格。
2. **`_lowest_score_facility` 農田不拆排除**（`:2979 if f=="farming": continue`）→ **留為規則（明文宣告）**：糧食生產設施＝**受保護命脈基礎建設**，不為蓋他物拆除（世界規則，非決策補丁）。de-patch 會有「拆糧倉→下 tick 又餓→重蓋」thrash 風險，故留；spec 明文標「rule: 不拆命脈食物設施」非殘留 override。
3. **`_trigger_survival` 蓋農田不被飢餓中斷特例**（`:3250-3258`）→ **留為規則 + 泛化**：「腳下正蓋產糧設施（短工期）→ 建設即自救不中斷（完工才是糧食出路）」＝良 means-end 規則非補丁。條件由硬編 `=="farming"` 泛化為「產糧設施 + 短工期」（principle-consistent；當前僅 farming 符合，功能等價）。
4. **govern 雙寫風險**（`options.gd` 駐守 engine option 已派 govern + infra 層 `faction_ai:2914-2917` A4 又派）→ **de-patch（S4.2 訂正）**：**移除 A4 強制 GOVERN；govern 單一 owner = 引擎既有「駐守」option；infra 層不派/不秤 govern**。避重演 Team10「雙決策生產者互蓋 livelock」（`faction_ai:3122` 前科）。**非新設計 = 避免雙寫。**
5. **tap 缺口 2 處** → 已併入 S1.3（`_run_recipe_group` 原料不足 + `tile==null` 殘任務）。

### S2 — food-security survival-crush 項 + granary seam 修 + 常數分層（★override 留著當安全網）
1. **survival-crush 項**（farming/食物設施 score）：
   ```
   farming_score = terrain_fit × (1 + deficit) × personality × (1 + SURVIVAL_CRUSH × urgency²)
   urgency = clampf((food_security_target(leader.values) - food_days) / food_security_target, 0, 1)
   ```
   - `food_security_target(_lvals)`（`decision/terms.gd`，need_hierarchy.gd:63 已用）**人格調變** → 願景「食安門檻人格化 + 轉折點 textures 戲」（慎重 buffer 大→餓更晚仍發展；大膽→進更薄邊際）。
   - **軟連續**（urgency² 平滑、personality 平滑移轉折點）**非 cliff/binary tier**（cliff=另一種 gate，違原則）。R① 驗 crossover urgency≈0.3 平滑無 thrash。
   - `SURVIVAL_CRUSH`/曲線 = **TEST VALUE**（tune 項，交叉點合理範圍待 measurer）。
2. **granary seam 修**：facility-eval 的 `food_days` 讀**據點局部非位置相依**——本 tile 糧倉（`tile.public_storage` food）+ owner/resident 私產，非 wandering leader positional `effective_food`。**只改 facility-eval reader，不動消耗/survival positional effective_food**（你站哪吃哪對）。
3. **常數分層**（上 §）落地：`×0.8` flat 釘死、`×7` 人格化、`TARGET_PER_POP` 拆兩常數。
4. **★驗收 S2（override 仍在）**：measurer/手算確認餓隊 farming score 主導可耕地（直答 R① 駁表）——**過了才准 S4 拆 override**。

### S3 — means-end 統一建設發起（涵蓋 faction_id=-1）
1. **facility 建造發起統一路徑涵蓋所有據點主**：獨立隊（`faction_id=-1`）對自家 outpost 自評估建設施（同 `_pick_facility` argmax 決策 + 建造 dispatch，**非另開平行路**）。閉合「想 goods→需設施→去蓋」回路。
2. **★待 measurer 坐實**（誠實標）：統一路徑真讓獨立隊 has_facility 成長——impl 後看實際呼叫圖 + full-HD 驗，**非本 spec 篤定**。

### S4 — 移除 A1 override + A3 utility 化 + A4/礦山 de-patch（★S2 驗過才做）
1. **移除 `_pick_facility:2942-2950` hungry early-return**——此時 S2 survival-crush 項已保底餓隊選 farming，override 冗餘。demolish 泛化成「best utility > lowest + 門檻則拆建」全設施通用，**但 farming 受規則保護、不列拆遷候選**（§R² 補裁 2：命脈食物設施不拆）。
2. **A3 utility 化**：`_evaluate_infrastructure` 固定 if 階梯（升級/擴建/蓋新）→ utility 排序（各 score → argmax），退役 first-match ladder。
3. **A4 govern de-patch（★S4.2 訂正，§R² 補裁 4）**：**移除 `2914-2917` 強制 GOVERN；govern 單一 owner = 引擎既有「駐守」option；infra 層不派/不秤 govern**（避 Team10 雙寫 livelock，`faction_ai:3122` 前科）。
4. **礦山強制 civilian de-patch（§R² 補裁 1）**：移除 `2923-2930` 硬 override，融「ore 機會」進 `_pick_outpost_type` 人格秤（`:2827-2835`）——ore→civilian 加分（貪婪/mint-inclined 偏採礦村、好戰可選軍鎮），決策交人格。
5. **規則明文宣告**（§R² 補裁 2/3，非殘留 override）：`_lowest_score_facility` 農田不拆＝rule（命脈設施保護）；`_trigger_survival:3250-3258` 蓋產糧設施不中斷＝rule（means-end 自救），條件泛化「產糧設施+短工期」。

## 非回歸
- **FACILITY_DEF/build 機制純規則不動**。
- **真飢隊 farming 仍贏**（S2 survival-crush 保底；S4 拆 override 前 S2 已驗）——**無餓死窗口**（序保證）。
- **感知鐵律**：facility-eval 本格+鄰格 obs；granary 修只讀**自家**據點糧倉（own data 非 god-view）。
- **A2 precondition 不誤殺**有設施隊製造（`level>0` 分支不動）。
- **觀測不變量**：新 tap 禁耗 RNG/禁污染，on/off byte-identical。
- **獨立隊 means-end 不傷 faction 隊路徑**（統一非取代）。

## 閘
- **R① CLEAN**（premise_contradiction 解，reviewer 獨立重算 + 4 訂正結構站得住）。
- **R② 必過**（spec 設計審）；**異質框外審 v1 已做不需重升**（除非 v2 引入新大框問題）。

## 量測（★整框架 S1-S4 完成後，中性 full-HD）
measurer `--path` branch full-HD：
1. **has_facility 成長**（>1 逐月升）；**含獨立隊**（S3 means-end 坐實）。
2. **goods 產出 >0**（`[Manufacture]` 大增、holding 破 0）；**製造 no-op tap 趨零**（S1）。
3. **surplus 進市場**（sell_no_surplus 大降）、**deals 大幅升**。
4. **★人格分化**（工匠/貪婪建工坊、農夫/慎重續農、好戰建軍事——emergent 差異）。
5. **★urgency 真 fire**（食安隊真有 food_days<target 時刻；granary 修後糧分佈）——**行為層坐實**。
6. **食安無回歸**（餓隊不餓死、farming 保底）。
7. **無殘補釘**（grep A1/A3/A4 硬 gate 全退、無新藏補丁）；**byte-identical 三跑 + 盲點閘綠 + 守恆**。

## 溯源
生產 arc greenlight / 原則 / 靜態稽核 / R① premise_contradiction（異質手算）/ R① re-verify CLEAN（`reviewer-to-systems-production-v2-r1-clean`）/ 藍圖 ratify（獨立隊發展=YES、軟連續非 cliff）。systems 親驗 `faction_ai:662`/`options.gd:71`/`need_hierarchy.gd:63`/`resource_system:386`。
