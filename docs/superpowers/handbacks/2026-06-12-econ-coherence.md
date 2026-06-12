# Hand Back: 經濟一致性修正

## 實作摘要

- `scripts/simulation/manufacturing_system.gd`：
  - `_run_recipe_group`：扣帳改 `in × q`（q = worker_rate × rate = 本 tick 產量），投入隨產量縮放；`_can_consume` 改 `_can_consume_scaled`（門檻 = in × q，原料門檻大幅降低）
  - `RECIPE_GROUPS` 改 per-unit 語意：多數沿用面值；`arrows` 3.0→0.8 mat、工藝品 gem 1.0→0.25 / mat 4.0→1.0（gem 觸媒高效路線）
- `scripts/simulation/interaction_system.gd`：
  - `BASE_PRICE` 全表重算（價 ≥ 原料價值 ×1.2）；補 `herb 3.0` / `mounts 45.0` / `wagons 72.0`
  - `TARGET_PER_POP` 補 `herb 1.0 / mounts 0.2 / wagons 0.2`（最小改法：只改 interaction 這份；manufacturing 那份已有 wagons，且其用途僅成品缺口排序，herb/mounts 非配方產出）
  - `_local_value`：新增 `SURVIVAL_GOODS = [food, medicine]` 不對稱 clamp——短缺 >50% 時 sr 由 0.5→1.0 區間映射 1.0→4.0（stock=0 → 5×）；一般品維持上限 2×；過剩下限 0.5× 不變
- `scripts/debug/headless_test.gd`：
  - 新增 `_test_recipe_input_scaling`（Econ Task1）、`_test_price_covers_input_cost`（Task2a）、`_test_famine_price_spike`（Task2b）
  - 既有 A/B 期配方測試改 per-unit 斷言（workshop/armorsmith/smeltery/wagon/medicine），新增 `_mfg_q` helper
  - `_test_medicine_recipe`「無 herb 不產」段：明確將 herb 歸零（per-unit 後第一次 tick 不再耗盡 herb）

## 與 spec 的差異

- **3 個價格上調**（plan 表內數值低於自身 ×1.2 規則）：`wagons 70→72`（in 59×1.2=70.8）、`weapon_ranged_low 38→39`（32×1.2=38.4）、`weapon_ranged_high 76→77`（64×1.2=76.8）
- `ore_steel 24.0` 恰好等於 in 20×1.2，取 `>=`（含 epsilon）

## 驗證

- headless_test：`=== DONE ===`、無 SCRIPT ERROR、Econ Task1/2a/2b OK
- game_sim_test：`ALL INVARIANTS PASSED (violations=0)`、CoinAudit delta=0.00
- game_sim_multi：4 配置（game_sim_test/tyrant/merchant/warzone）CoinAudit delta 全 0.00（warzone/tyrant 顯示 -0.00 = 浮點累積 <0.005）、無 SCRIPT ERROR
- 單位經濟正：由 Task2a 程式化驗證——每條配方（CRAFT 豁免）產出價 ≥ 原料價值 ×1.2

## 連動風險

- **製造次數對比無法在 sim 中觀測**：baseline（main）與本分支的 game_sim_test / game_sim_multi `[Manufacture]` 次數皆為 0——21600 tick 內幾乎無製造設施建成（FacilityStats 設施總數 0~1，且為 farming）。投入縮放後門檻變低理論上製造更易發生，但需設施先存在。**非本次回歸**，屬場景層問題（faction AI 蓋設施太慢或 sim 長度不足）。
- 武器/工具/馬車大幅漲價（tools 6→20、weapon_melee_high 18→72、wagons 新 72）：NPC 貿易 AI 用 `_local_value` 決策，軍備採購成本上升，可能延後武裝；`MAX_COIN_PER_TRADE 300` 下單筆可購量下降。
- 飢荒 5×：食物短缺團買 food 花費最高 5×，coin 流出加速；對窮團可能形成買不起 → 更餓的循環（設計上合理，但觀察）。
- `_calc_reserve` 用 TARGET_PER_POP——herb/mounts/wagons 補進後，這三項現在有保留量（pop × target），居民團不會即買即賣，行為更保守。

## 待主 session 確認

- 價格表 tune：全部仍為 TEST VALUE 量級，正式平衡期需重調（見 feedback_tick_balance）
- 武器漲價對 faction AI 軍備行為影響需長 sim 觀察
- 建議後續 task：調查為何 21600 tick 內製造設施幾乎不建成（FacilityStats=0），否則製造鏈/per-unit 修正在 sim 中無從發揮
