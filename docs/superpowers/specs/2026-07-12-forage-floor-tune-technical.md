# 苟活地板 tune + wild_game regen（技術 spec）

> WHAT = 用戶裁定（blueprint `forage-floor-tune-spec`，R² CLEAN）。急性餓死崩（月1-3 45% 死）真根：苟活地板（覓食 subsistence latch）是 1.5 天 hand-to-mouth 零韌性 + passive hunt 0.08 太低 + wild_game 枯竭不 regen。兩常數皆 feature 引入 placeholder TEST VALUE，從未 balance。**tune 現有常數 + 補 wild_game regen（非新機制，反冗餘已擋新建）。**

## 真根（反冗餘確認）
苟活地板**已存在**（`_evaluate_survival`→`rank_survival` PRIO_SURVIVAL forage + `_forage_subsist_buffer` latch）。問題=三脆點：latch 1.5 天太薄 / passive 0.08 refill 太差 / wild_game 枯竭不再生。

## 改（三項，全 tune 現有）

### §1 FORAGE_FLOOR_DAYS 1.5 → 5（TEST，A/B 5 vs 7）
`resource_system.gd:7`。latch cap = `pop × 0.8 × FORAGE_FLOOR_DAYS`：
- 1.5 天 → 5 天：覓食隊食物 latch 從 pop×1.2 → pop×4.0，**韌性 margin 吸收 hunt 波動**（一次空手不見底）。
- **★balance 守門（保設計意圖）**：floor 仍 << 建國 7 天盈餘門（`FOUND_FOOD_SURPLUS_DAYS=7`）→ **覓食保命但仍不足以建國/成長** → farming/貿易對「成長」仍必要（苟活≠繁榮不變）。5 天 < 7 天保此界；7 天檔逼近建國門要 A/B 看會否誤開成長路。

### §2 PASSIVE_BASE_CHANCE 0.08 → 0.30（TEST）
`hunt_system.gd:6`。passive 覓食命中 0.08→0.30（仍 < ACTIVE 0.4，保主動狩獵優勢語意）。降連續空手率 → latch 填得滿。只碰 passive 分支（reviewer 確認不碰 active 路徑）。

### §3 wild_game regen（複用 regenerate_tiles，防採乾失效）
`resource_system.gd regenerate_tiles:79`——現況 regen food/material，無 wild_game 分支（獵物採乾不再生）。**加 wild_game regen 分支**（同款 pattern：rate + `TileBank.pool_set` + `resource_cap` 上限夾）：
```gdscript
# regenerate_tiles 內，food/material regen 後加：
var wg_cap: float = float(tile.resource_cap.get("wild_game", 0))
if wg_cap > 0.0:
    var wg_cur: float = float(tile.resources.get("wild_game", 0))
    if wg_cur < wg_cap:
        var wg_regen: float = WILD_GAME_REGEN_PER_DAY * day_fraction
        TileBank.pool_set(tile, "wild_game",
            minf(wg_cur + wg_regen, wg_cap), "regen_wildgame")
```
- 常數 `const WILD_GAME_REGEN_PER_DAY: float = 0.15`（TEST VALUE）——獵物繁殖慢補（月級補回被獵的，非秒補）。上限夾 `resource_cap["wild_game"]`（world_gen:123 設的初始值）→ **不破稀有度不變量**（不憑空超初始）。
- **零 randf**（deterministic rate），守 determinism。

## §4 balance 意圖（保「苟活≠繁榮」）
三改目標 = **急性窗不再大量餓死（苟活真苟住）**，但**不讓覓食成為成長路徑**（保 farming/貿易對繁榮的必要）：
- floor 5 天 < 建國 7 天盈餘門 → 覓食隊活著但攢不出建國盈餘 → farming/貿易仍是成長唯一路。
- floor「超額不 bank」機制不動（latch 仍封頂，只是封得高一點）。
- ∴ established 起得來要靠 farming de-patch（已 merged 中期路）+ 苟活撐過急性窗，兩者互補。

## determinism + baseline
- §1/§2 純常數,§3 zero-randf regen → 同 seed 仍 byte-identical。
- **★baseline 位移（非 regression）**：行為改動（食物流變→存活變→established 變）。measurer 標「forage-floor tune 位移」重生 baseline（比照 world-gen 先例）。

## 驗收法（measurer，A/B）
1. **A/B FORAGE_FLOOR_DAYS 5 vs 7**（+passive 0.30 + wild_game regen 皆同）：default.json 12mo——月1-3 attrition 降幅（目標 45%→顯著降）、終局 pop、established 是否 >0。挑「苟活住但不誤開成長」的檔。
2. **急性窗解**：86-96% 開局負流 → 覓食隊食物流轉正/持平（不再耗到死）。
3. **★balance 驗**：覓食隊 pop **不因覓食而成長**（farming_level=0 隊 pop 平/緩降,非爆長）——確認苟活≠繁榮守住。
4. **established 鏈**：attrition 降 → pop 攢得起 8（A門）→ leader 活得久累積統領（B2）→ **established 是否終於 >0**（一修多解驗證）。誠實：若 A門/B2 仍卡則標「急性窗解但 established 需下游補」。
5. **determinism** byte-identical + baseline 位移標記。**融合閘**綠。

## 流程
- spec → **R²**（審常數改乾淨/wild_game regen 複用正確/balance 守 5<7門/determinism）→ CLEAN → implementer 疊 worktree `feat/forage-floor-tune`。
- measurer A/B corroborate + 全驗收。
- established 調查鏈第五輪（攻上游急性崩，理論一修多解鬆四層門）。
