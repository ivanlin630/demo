# 統一勞力池 — 讓 size 在生產上 matter（WHAT / vision）

status: R①-CORRECTED（P1–P4 CLEAN，P5 訂正見下 → reviewer 預核「訂正後 CLEAN」→ 可鎖+dispatch systems）
owner: blueprint（WHAT）→ systems 做 HOW
date: 2026-08-03

## 動機（真根 = CASE B：規模經濟不在 model）

量測定案（`2026-08-02 systems→blueprint CASE-B` handback）：現 world model **不獎勵 size、甚至反獎勵**——
軍力 linear、生產 sublinear+capped、抗風險 proportional、領土 pop-cap+split。∴世界碎成小團是**正確湧現**、
absorb 低 util 是引擎**正確**估算。「有大有小」**無 genuine-value 基礎**：要有大有小，須**先讓 size 真 matter**（加真規模好處、非 crank）。

用戶選定的第一個維度 = **生產**：讓「大」在生產上有真優勢，機制 = **勞力變成有限稀缺資源**。

## 現況前提（★pending R① factcheck，reviewer 逐條驗 file:line + 詮釋）

- **P1** `manufacturing_system.gd:82` — 製造勞力 = `clampf(sqrt(team.population/5), 0.5, 2.0)`；
  `RECIPE_GROUPS` 迴圈裡**每座設施免費並吃同一個 pop_mult**（設施間**不競爭**勞力）。
- **P2** `resource_system.gd:63` — 採集（食/材/原料）用**自己一份** `sqrt(pop/5)` pop_mult，與製造**獨立、互不搶**。
- **P3** `outpost_system.gd:166 _has_resident_on_tile` — 布林閘（有無 PRODUCE-tag 隊在 tile），**非**勞力量級；
  勞力量級 = 動作隊 `team.population`（`manufacturing:82`）。據點**本身無獨立勞力 stat**。
- **P4（詮釋）** 兩套 pop_mult **互不搶**：勞力現為「免費/無限」——每系統各取 team.population，無共享約束。
- **P5（R①訂正·原認定不成立）** `resource_system.gd:63` 的 `sqrt(pop/5)` **不是** tile 承載——它跟 `manufacturing:82` **逐字相同**，是「勞力規模效率遞減」曲線（labor residue），**該一起併入勞力池**。
  tile 真正的生態承載 = `_collect_from_tile`（`resource_system:254-284`）：`gain = productivity × current × COLLECT_RATE(0.05) × day_fraction`，`current`（庫存隨採集遞減）+ regen——**獨立機制、勞力池不碰**。
  → 原「神聖 sqrt 不准動」守憲條款作廢；改由 demand-cap + `current` 遞減承載「大隊一格採食人均遞減」意圖（見 §守憲訂正）。

> R① 判決（`2026-08-03 reviewer→blueprint verdict`）：**P1–P4 CLEAN、P5 不成立但非 halt**（dispatch 已預設「sqrt 非承載則守憲條款改」）→ 訂正後 reviewer 預核 CLEAN。

## 設計（統一勞力池）

### 核心
- **勞力池** = 停在該 tile、帶 `TAG_PRODUCE` 的隊**人口總和**（多隊共址相加）。軍隊（無 PRODUCE tag）不算工。
- **所有生產活動吃同一池**：採集（食/材/原料）+ 每座製造設施 = 一律「吃勞力的工位」。
- 取代 P1/P2 兩套免費 `pop_mult`。**一個共享 allocator，採集+製造都讀它**（統一 seam，不得各搶各的）。

### 工位需求
- 每工位 `demand = 規模 × K`（K = 每級/單位工位要幾手，一個誠實旋鈕；systems 定值+曲線）。
- `demand` 同時是「需求人數」與「有用上限」(demand-cap)：分到 = demand → 飽和；超過 = 浪費、溢到別工位。

### 分配法（★需求加權比例 + demand-cap 封頂 + 溢出串聯）
1. 池 = 共址 PRODUCE 人口。
2. `need_oracle` 給每工位 need 權重（不需要 = 0）。
3. 暫定 `share = 池 × 權重 / Σ權重`。
4. clamp `share ≤ demand`；削下的按權重再分給未封頂者，迭代到穩。
5. 各工位 `fill_ratio = share / demand`；產出 `= min(勞力率, 承載/原料上限)`。

**兩規模自動對**：
- 人手少（Σdemand >> 池）→ 沒人封頂 → **純比例分：每條需要的線都拿一份、都在產**（高 need 多、低 need 少）。
- 人手多（池 >> Σdemand）→ 全封頂 → **全滿速 + 餘力外溢**（採集 surplus/軍事/閒）。

線性 `fill×rate` → 攤薄不罰效率、無浪費。糧不被餓死靠 `need_oracle` **survival 階層天然拉高採食權重**，
**不加 scripted min-floor**（違憲法硬 gate）。

### 頻率解耦（命門）
- 勞力分配 = **常駐 labor-share（站位分派）**，自己一個**較慢 cadence** 重算 + **危機事件觸發即時重算**。
- 各生產活動照**自己頻率**跑時，**乘當前 share**。→ 分配 cadence 與生產 cadence **解耦、零雙算衝突**。
- 接用戶「隨時算太頻繁」：週期重算 + 危機觸發，非每 tick 抖。

### 守憲（P5 訂正版）
- **deterministic**（sorted + 純算術、無 RNG）→ 三跑 byte-identical。
- **tile 生態承載獨立不碰**：`_collect_from_tile` 的 `current/COLLECT_RATE/regen`（`resource_system:254-284`）是承載真載體，勞力池**只改 pop_mult 那一支、不碰庫存數學**。
- **「大隊一格採食人均遞減」= 真設計意圖（用戶），改由兩機制承載**（非舊 sqrt、非「不准動」假前提）：
  ① **採食 demand-cap**——大隊無法對單格無限灌勞力（超 cap 溢走）；② **`current` 庫存遞減**——過採一格 → 庫存掉 → yield 降。systems 設 food demand-cap 保住此意圖，measurement 驗大隊一格仍餓、須鋪多格/供給。
- **無 explicit toggle**；玩家隊 on/off 另循 `player_command_system`、非核心、本 arc 不做。

## 這服務的兩軸（size matter）
- **大隊（領導軸）**：`pop_cap_from_leadership` 拉高 → 大隊 → 勞力容量大 → 餵得動多工位 → 產得多。領導→人→產能，真因果鏈。
- **集團（組織軸）**：多支 PRODUCE 隊共址堆人手 / 多據點鋪設施 → 總產出規模化。接已做好的物流（餵原料）。
- **自洽**：覓食 sublinear → 大隊只有「定居設施據點 + 有糧供給」才產得動；游牧大隊仍餓死 → 大隊 = 定居生產樞紐、非流寇。

## 交 systems 的 HOW（開放）
- K 值 + demand 曲線（按等級加權）。
- 重算 cadence 具體值 + 危機觸發條件。
- labor-share 存哪（team/tile state）+ 共享 allocator seam 位置。
- 採集端（`resource_system`）與製造端（`manufacturing_system`）如何共讀同一 allocator。

## 量測（systems 交 measurer/QA）
- **現況 baseline vs 改後**：大隊/大集團是否**真**產得多於小團（非只搬數字）。
- 世界**沒凍**（雙 seed）、determinism 三跑 byte-identical。
- 大隊一格採食**人均仍遞減**（由 demand-cap + `current` 庫存遞減承載，非 sqrt）；tile 生態承載機制（`_collect_from_tile`）未被勞力池破壞。
- 「人手少但都要生產」情境：小隊多需求時全線比例產、無單工位獨吞。

## 血脈（別再犯）
- **非 crank**：勞力是真經濟投入、閒置設施是真損失；util 因真 yield 升 = 湧現非腳本（守「無意義分數競爭」命門）。
- **unified 非平行 patch**：接既有 team/tag/need_oracle/物流，無新 resident subsystem。
- **R① 教訓（P5）**：別把「還沒設計的效果」用「既有機制不准動」包裝。宣稱某公式是某設計意圖的載體前，先驗**哪個機制**真的承載它——`sqrt(pop/5)` 被誤認成覓食承載，真承載其實是 `current/COLLECT_RATE/regen`。意圖(大隊一格遞減)是真的、機制認定錯了。
- 溯源：`2026-08-02 CASE-B economies-of-scale-absent`（真根定案）；`2026-08-03 reviewer R① verdict`（P5 訂正）。
