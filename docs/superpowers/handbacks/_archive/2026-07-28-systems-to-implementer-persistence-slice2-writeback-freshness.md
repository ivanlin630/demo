---
from: systems
to: implementer
status: consumed
topic: "[實作·持守統一 Slice 2·執行層寫回通路+新鮮度·Slice1 merged(46350a14 gate74 世界不凍過)·spec=2026-07-28-persistence-decision-layer-HOW.md §5·persist_strength隨進度事件更新非只cadence(construction tick/movement抵達重算)·為Slice3執行層try_set門檻式讀準備] Slice 1 決策層 done merged。Slice 2=新鮮度:persist_strength隨進度更新,執行層讀時是當下值。不碰try_set門檻(Slice3)。"
branch: feat/persistence-slice2-writeback-freshness
---

# 實作：持守統一 Slice 2（執行層寫回通路 + 新鮮度）

Slice 1 merged（46350a14，gate 74，世界不凍過）。Slice 2 = **新鮮度**——persist_strength 隨進度事件更新（非只 cadence），為 Slice 3 執行層 try_set 門檻式讀準備。

## spec
`docs/superpowers/specs/2026-07-28-persistence-decision-layer-HOW.md` **§5（兩層寫回通路 + 新鮮度）**。

## Slice 2 scope（新鮮度，不碰 try_set 門檻=Slice 3）
- Slice 1 已有 `team.persist_strength` 欄 + `PersistStrength` helper + 決策層 cadence 算。
- **★問題**：sunk/prospect 是**進度函數**（construction_ticks 減、campaign 行進），但決策層只 cadence（1日）算 → 執行層 Slice 3 讀時可能舊（3 落差點：cadence vs 每 tick、goal cadence、crisis_immunity vs cadence）。
- **修**：persist_strength **隨進度事件更新**（cheap 純算術）：
  - **construction tick 倒數時**（`outpost_system` `_tick_construction` progress）→ 重算施工隊 persist_strength（sunk 升）。
  - **movement 抵達時**（`movement_system` arrival）→ 重算（campaign/trade run 進度）。
  - 其他有進度的 committed 動作同理。
- 確保執行層讀 `team.persist_strength` 時 = **當下進度的值**（Slice 3 門檻式讀新鮮）。

## ★TDD + 驗
- persist_strength 隨進度更新單測（construction tick 減 → persist 升；抵達 → 更新）。
- **★世界不凍回歸**（latch 反例，每 slice 硬驗）：specimen-off seed1337/42 teams/pop churn、attrition 兩者皆活。
- 新鮮度驗（決策層 cadence vs 執行層讀 落差消：進度變後 persist_strength 即時反映）。
- 閘：headless 0-new + gate 74 + determinism 3跑 byte-identical（觀測禁 RNG）。

## 交付
handback `to:systems` → R²（Slice 2）→ merge → Slice 3（try_set 持守-aware 門檻式，§6）。whole-system-first。★execution-verified（persist_strength 真隨進度更新）+ 世界不凍。material PARK。
