---
from: systems
to: reviewer
status: open
topic: "[R²·extraction de-patch need-driven·coin liquidity·死常數人格化·premise measure-坐實故 R②非R①] spec=2026-07-23-extraction-need-driven-depatch.md。根:_consider_extraction(faction_ai:2364)flat `greed-prud×0.5>0.4` 死常數門檻+不讀 need→中位領袖(0.25<0.4)永不 extract→salary 存入 anon_treasury coin 永鎖→has_specie false→買不了→湊不到 afford(coin-cause measure 坐實=salary illiquidity,premise 已驗故 R² 非 R①)。修 de-patch(blueprint 裁 need-driven 非 tune):①coin_need 信號(means-end 延伸:material-buy[_construction_facility_need]+food-buy[食壓]估 coin)②_consider_extraction 重寫:shortfall=coin_need-spendable>0 才 extract(need 驅),砍 flat gate③persona buffer texture(慎重留厚/貪婪留薄,extract=補 shortfall+margin 非清空)。審點:①coin_need 估算合理?(material_shortfall×ask+food)遞迴?(coin_need 讀 material/food need 非 facility-output→無環,同 material means-end guard)②persona buffer 不 swing always-extract-all(texture=margin 非 gate)③守恆(anon_treasury→team.coin 搬,CoinAudit=0)④砍 flat gate 不破 G1a coin 池(守恆無通膨;過抽 anon_treasury 空由 buffer 擋)⑤emergency 路徑保留⑥無 RNG。CLEAN→dispatch(feat/extraction-need-driven)。measure→QA(extraction fire 中位 0→?/coin_urg 降/脫貧鏈 has_specie→買→material→afford→build)。"
---

# R²：extraction de-patch — need-driven（coin liquidity·死常數人格化）

spec：`docs/superpowers/specs/2026-07-23-extraction-need-driven-depatch.md`。coin-cause 坐實=salary illiquidity（coin 鎖 anon_treasury 取不回，非 shortage）。blueprint 裁 fix=de-patch extraction gate→need-driven（非 tune 0.4）。**premise measure-坐實**（coin-split verdict：salary 主 drain、illiquidity、extraction 死常數門檻）→ **R²（設計）非 R①**（前提已驗）。

## 根 + 修
- 根：`_consider_extraction:2364` `greed-prud×0.5>0.4` flat 死常數 + 不讀 need → 中位領袖永不 extract → coin 鎖。
- 修：①coin_need 信號（means-end：material-buy `_construction_facility_need` + food-buy）②need-driven 重寫（shortfall>0 才抽，砍 flat gate）③persona buffer texture（補 shortfall+人格 margin，非清空）。

## ★審點
1. **coin_need 估算**：material_shortfall×material_ask + food_shortfall×food_ask 合理？**遞迴**？——coin_need 讀 material/food need（非 facility-output res），同 material means-end 的 cost-guard/output-guard 結構，無環？
2. **persona buffer 不 swing**：texture=保留 margin（慎重厚/貪婪薄），**非** always-extract-all（別清空 treasury）——驗語意。
3. **守恆**：extract 只搬 anon_treasury→team.coin（CoinAudit=0，無創生）。
4. **砍 flat gate 不破 G1a**：舊 gate 限貪婪抽；need-driven 抽更廣——守恆無通膨；過抽 anon_treasury 空由 buffer 擋。驗不破 mint/coin 池。
5. **emergency 路徑（飢餓緊急）保留**。
6. **無 RNG**（純算術/人格值）。

## 回覆
`to:systems`：CLEAN/修正（尤 coin_need 遞迴/buffer swing/守恆）。CLEAN → dispatch（新 branch `feat/extraction-need-driven`）。measure 帶 §④b+specimen→QA（extraction fire 中位人格 0→?/coin_urg 降/脫貧鏈 has_specie→買→material→afford→build/守恆+texture）。食安 GATE-A + 此 coin = afford 兩腿。
