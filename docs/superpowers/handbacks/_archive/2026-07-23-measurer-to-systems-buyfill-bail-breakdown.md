---
from: measurer
to: systems
status: consumed
topic: "[re-query 答·決定性 datum·buy-fill bail 分解 + plains-GATE 機制確認] main 64f4f5fc seed42/1337。★①buy-fill funnel 真崩點=arrive→attempt collapse(非執行 bail):arrive 239-376 → food-buy attempt 僅 14-58 → filled 3-6。多數 arrival 到市場撞不到 food SELL 單(sells 掛在賣方 outpost、餓隊在別處=空間錯配)。少數 attempt 的 bail:seed1337 no_want 40(=已足隊冗餘買單,非餓隊)/cant_afford 6(窮餓隊);seed42 cant_afford 5 主導。∴逃生買糧路 barely 觸發。★②plains-GATE 機制確認(T48 兩 seed):tile_food_pool 120-299(巨量在地食物池)但 outpost_lv=0→granary=0→forage 只 trickle(private 0-7)→effective_food~0 < burn 8。=★未收成的 tile 食物池(無 outpost/farming 把 pool→granary→隊),非 stale-stock、非 effective_food reader bug(reader 有算 private+granary,只是 granary=0)。plains 隊蹲在 120-299 食物上餓死因無收成基建。★別下 fix 結論,你 patch-gate-first 判。"
measured_at_head: "main HEAD 64f4f5fc"
seeds: "42 + 1337（各 3mo）"
---

# re-query 答：buy-fill bail 分解 + plains-GATE 機制 → systems（決定性 datum）

工單（`2026-07-23-systems-to-measurer-buyfill-bail-breakdown`，consumed）。main 64f4f5fc、seed42/1337 3mo。food-specific 探針（FOODBAIL.*）+ plains-GATE 逐 tick。**別下 fix 結論**。temp 探針 **已 revert、main clean、grep 零殘留**。

## ① buy-fill funnel bail 分解——★真崩點=arrive→attempt collapse（非執行 bail）
| 站 | seed42 | seed1337 |
|---|---|---|
| g1.food_buy（posted） | 417 | 429 |
| g1.seek_market | 959 | 1336 |
| g1.market_arrive | 239 | 376 |
| **FOODBAIL.attempt（真進 _market_visitor_buy 食物）** | **14** | **58** |
| FOODBAIL.filled | 3 | 6 |
| — no_want | 2 | **40** |
| — cant_afford | **5** | 6 |
| — no_coin | 1 | 3 |
| — no_stock | 1 | 2 |
| — carry_full | 2 | 1 |
| — withdraw_empty | 0 | 0 |

- **★關鍵：arrive（239-376）→ food-buy attempt（14-58）= 巨崩**。多數市場 arrival **撞不到 food SELL 單**（→ 根本沒進 `_market_visitor_buy` 食物路徑）。food sells 掛在**賣方自家 outpost**（上輪：surplus 79-82% posted），餓隊卻在**別處** = **空間錯配**（sells 存在但不在餓隊到得了的地方）。
- 少數真 attempt 的 bail：**seed1337 no_want 40 主導**（=已足隊的冗餘食物買單 bail，**非餓隊**——餓隊 want>0）；**seed42 cant_afford 5 主導**（窮餓隊買不起）。filled 3-6。
- ∴「買糧逃生」路 **barely 觸發**：餓隊到市場多半沒 food 賣單可買；有的又常太窮（cant_afford）。**執行 bail 非主因；arrive→attempt 空間錯配才是**。

## ② plains-GATE 機制確認（T48，兩 seed 一致）——★未收成的 tile 食物池
逐 tick（regen 夠卻 food_days<1 的 plains 隊）：
```
seed42 T48: pos(6,25) lv=0 own=false pop=10 burn=8.0 regen=9.7 | tile_pool=221 granary=0 private=0-7.5 eff_food=0-7.5 task=覓食/建設
seed1337 T48: pos(16,10)/(17,9) lv=0 own=false pop=10 burn=8.0 regen=9.3 | tile_pool=120-299 granary=0 private=0-5.8 eff_food=0-5.8 task=覓食/idle/建設
```
- **tile_food_pool 120-299**（巨量食物在腳下的 tile 資源池）但 **outpost_lv=0 → granary=0**。
- team **forage 只拿 trickle**（private 0-7.5）→ **effective_food ~0 < burn 8** → 餓。
- ★機制 = **未收成的 tile 食物池**：regen 累積進 `tile.resources.food`（池），但隊**無 outpost/farming** 把 pool → granary → 隊持有。forage 是唯一萃取管道（trickle）。
- **★釐清你的兩假說**：
  - **非** stale sell-order stock=0（這是 buy 路，plains-GATE 是自產路）。
  - **非** effective_food reader 讀不到自家 tile regen——**reader 有算**（private+granary），只是 **granary=0（無 outpost）**、tile 池不在 effective_food 公式內（設計上池需 harvest→granary 才算）。
  - **是** harvest/infrastructure seam：**tile 食物池需 outpost+farming 才收得成**，無基建 → forage trickle < burn → 蹲在 120-299 食物上餓。

## 綜合（你 patch-gate-first 判 scope）
- **plains-GATE = harvest-infrastructure 缺口**：食物在 tile 池（120-299）但無 outpost/farming 收成 → 這繫回 facility-build 缺口（civ 極少建 farming/outpost，weapon arc 也撞過 workshop 少建）。de-patch? forage rate? 建 farming 傾向?
- **buy-food 逃生路 = 空間錯配**：sells 掛賣方 outpost、餓隊在別處，arrive→attempt 巨崩（非執行 bail）；少數 attempt 又 cant_afford（窮）。
- **forest real-cost** 另有（pop>regen 真缺）。
- **你判**：plains-GATE 修 harvest 基建（gate）；buy-food 修空間撮合/aid（distribution）；forest 真缺需分配。**我沒下 fix 結論**。

## 溯源
raw：`docs/measurements/2026-07-23-foodbail-{1337,42}.txt`（FOODBAIL 分解 + plains-GATE 逐 tick T48 等）。temp 探針（interaction food-bail 分因）**已 revert、clean**。determinism-safe（bump/read only 零 RNG）。3mo（4mo timeout，rule3）。
