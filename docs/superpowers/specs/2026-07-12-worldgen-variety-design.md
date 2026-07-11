# world-gen variety — 設計（blueprint WHAT）

> 2026-07-12 brainstorm 定案。blueprint 願景層（WHAT/意圖/約束）。HOW（評分公式/範圍 TEST VALUE/scatter 演算法）交 systems。動機=用戶 GUI 親驗：據點太規則 + 每 seed 同。

## 一句話
讓每 seed 開局世界更有變化（據點布局/數量/勢力格局隨 seed 甩），治「據點固定 key-order 布局＝規則且每 seed 相同」。世界質感 + 量測效度（多 seed 真測不同地緣）。

## 現況（characterize 坐實）
- **已隨 seed 變**：地形（`world_generator:62 _random_terrain(rng)`）、tile 資源、隊數、次要隊位置、獨立據點佔用、人格。
- **固定（真兇）**：據點位置（`pick_start_positions:180` 按 tile key 順序貪婪＝規則且每 seed 同）、據點數量（config `total_count`）、地圖 grid（config radius）。
- ∴ 聚落永遠坐同幾個 tile、無視變動的地形 → 看起來規則。

## 設計

### 1. 據點布局（核心）— 資源/戰略加權 seeded 散布
取代 `pick_start_positions` key-order 貪婪：
- 每 tile 按**資源價值 + 戰略因子**（近礦/肥沃/水/隘口）評分。
- **seeded 隨機挑高分 tile**，守最低間距。
- → 據點落在「有價值的地」（民用近肥沃、軍事近礦＝聚落有道理）、每 seed 不同、貼變動的地形/資源。

### 2. 據點數量 — 隨 seed 變 + ★硬上限留空地
- seeded 落在範圍內（TEST VALUE，如 8–14）→ 開局密度每 seed 變。
- **★硬上限壓在「容量 × 某比例」以下，永遠留大片空地**——不是「≤ 地圖容量」。
- **理由（量測效度）**：留可建空間 → 「隊蓋新據點」（play-time 行為）之後量得到（空地冒據點＝乾淨訊號）；別讓開局飽和淹掉 build-outpost 訊號。

### 3. 勢力數 + 領土 — 隨 seed 變
- 勢力數 seeded 範圍（TEST VALUE，如 2–4）、領土 share 甩 → 政治格局每 seed 不同。

## 性格：放野變異（用戶裁 B）
接受失衡世界（獨霸/群雄/稀疏＝不同開局劇本，沙盒「自己說故事」更豐富）。戲劇性失衡 OK，非平衡護欄。

## 結構地板（防「跑不動」，非平衡）
- ≥1 勢力、≥ 幾支隊（sim 有東西跑）。
- 據點數 ≤ 硬上限（留空地，見 §2）、不重疊同格、間距守。
- 除此全放野：勢力數/據點數/領土/獨立隊多寡/誰獨大 都讓 seed 甩。

## 約束
1. **per-seed determinism 必守**：全走既有 `config.seed` rng，同 seed 完全可重現（否則回歸 diff 廢）。是「seed 間變什麼」的選擇，非加隨機。
2. **地形不動**（已 seeded）。
3. **基線一次性位移**：改世界生成後所有現有 seeded 回歸基線變（同 seed 世界不同了）→ 一次性預期重置、之後重 baseline。用戶已確認可接受。
4. **量測變數控制**：世界更變異利多 seed robustness；除錯隔離走控制場景床（不靠 organic 多 seed confound）。兩端不衝突（床自建世界）。

## 不做（YAGNI）
- 平衡護欄（放野是刻意的）。
- 地形改（已 seeded）。
- 玩家面。

## 交 systems 的 HOW
- 據點評分公式（資源價值 + 戰略因子權重）、scatter 演算法（seeded 挑高分 + 間距）。
- 三維範圍 TEST VALUE（據點數含硬上限比例、勢力數、領土 share）。
- 結構地板實作（能跑保證）。
- 重 baseline 程序（seeded_warring_bed 基線重生）。

## 驗收
- **世界質感**：GUI 跑幾個 seed，據點布局有機（非規則）、每 seed 明顯不同、聚落貼地形/資源。
- **放野**：seed 間看得到獨霸/群雄/稀疏等不同格局。
- **能跑**：每 seed 結構地板守（sim 不空轉/不 crash）、留空地（build-outpost 可驗）。
- **determinism**：同 seed 完全可重現（headless 自比 byte-identical）、framework/coin/憲法閘綠。
