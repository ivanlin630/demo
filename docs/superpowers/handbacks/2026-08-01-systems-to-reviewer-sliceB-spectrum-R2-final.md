---
from: systems
to: reviewer
status: consumed
topic: "[R²(終稿)甲SLICE B統一光譜·blueprint裁擴B-only→統一光譜(給免費/賣居民人格定價/賣外),spec定稿·premise §0b三項全PROVEN(grep坐實:TradeValuation定價+coin結算interaction:806-807/838-839,居民持coin member_tax faction_ai:2521,intra-faction無gate只擋self-trade interaction:731)·★blueprint指定硬檢=grep四約束鎖統一非補丁:①候選非特判branch(grep無if kind==distribute繞argmax)②連續weigh非if greed>X硬gate(grep util/price無階梯gate)③價格人格導出連續值modulation現成local_value非新定價機制(grep無新price常數/class)④復用現成convoy+貿易市場非新market/order class·兩旋鈕:price_factor=clamp((0.5+greed)/(0.5+honor))×local_value/util=relief(honor放大)+coin(greed放大)·dev-verify三人格湧現(仁君/苛捐/拋棄)+連續掃greed非階梯+coin守恆·CLEAN→dispatch隔離branch;前輪R²已CLEAN B-only,此審光譜擴增部(價格factor+賣居民settle)"
---

# R²（終稿）甲 SLICE B 統一光譜 — blueprint 指定 grep 硬檢

spec 定稿：`docs/superpowers/specs/2026-08-01-logistics-slice-B-lord-distribution-policy-HOW.md`

**變更**：blueprint 裁 B-only→**統一光譜**（給免費/賣居民人格定價/賣外，一 argmax 一脊椎人格 weigh）。你前輪已 CLEAN B-only seam；此審**光譜擴增部**（價格 factor + 賣居民 settle）+ blueprint 指定的 grep 硬檢。

## premise §0b 三項全 PROVEN（我 grep 坐實、非信斷言）
- 貿易市場有價格+coin 結算：`TradeValuation.ask_price/local_value`、coin 轉 interaction:806-807/838-839。
- 居民持 coin：team.resources["coin"]←member_tax(faction_ai:2521)←salary。
- intra-faction 貿易無 gate：只擋 self-trade(interaction:731)、領主掛賣同勢力居民可買。

## ★blueprint 指定硬檢＝grep 四約束（鎖統一非補丁）
| # | 約束 | grep 硬檢 |
|---|---|---|
| ① | 候選非特判 branch | grep 無 `if kind=="distribute"` 在 dispatch/決策層繞 argmax |
| ② | 連續 weigh 非硬 gate | grep util/price 路無 `if greed >`/`if honor >` 階梯 gate、只連續乘除 |
| ③ | 價格人格導出連續值、modulation 現成 `local_value` 非新定價機制 | grep 無新 price 常數表/定價 class；`_price_factor` 連續映射 |
| ④ | 復用現成 convoy+貿易市場非新 market/order class | DELIVER 走現成 `_market_visitor_sell`+`TradeValuation`+coin 轉；grep 無新 class |

## 兩連續旋鈕（審是否真連續無 gate）
- **price_factor** = `clamp((0.5+greed)/(0.5+honor), 0, CAP)` × `local_value`（honor→0 免費、neutral→1、greed→markup）。
- **util** = `relief(deficit×(0.3+honor)) + coin(price_factor×local_value×affordable×(0.3+greed))`。競 argmax 對 sell-external。

## dev-verify（§3）審夠嗎
三人格湧現（仁君免費 fed / 苛捐價高居民買不夠 unrest↑ + 領主抽 coin / 拋棄全賣外 defection）+ **掃 greed 0→1 連續變非階梯**（WEIGH 證據）+ coin 守恆。

**CLEAN → 我 dispatch 隔離 branch。有洞 → 回 `to:systems`。** 乙 join measure 並行在飛。
