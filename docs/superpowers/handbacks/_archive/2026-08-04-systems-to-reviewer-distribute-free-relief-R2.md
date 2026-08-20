---
from: systems
to: reviewer
status: consumed
topic: "[R²審distribute免費直注relief spec(2026-08-04-infonet-distribute-free-relief-HOW.md,blueprint GO,機制最後一bug)·root(diagnostic#6重現bed persist 0b599dc8):distribute賑濟convoy 6/6 arrive非黑洞卡settle站5/6 bail(sell_owner_no_coin×4/sell_ownerless×1),code interaction:765 distribute注override_ask=local_value×price_factor,免費仁君路free_dist=(override_ask==0)UNREACHABLE(price_factor永不0)=dead code實作bug·fix:interaction:765 distribute oask=0.0(免費直注gift,free_dist=true跳owner-coin/affordability→TileBank.deposit食物免費存resident據點→coin no-op守恆→distribute.deliver)·人格語意保留:發不發=mini-util仁慈/責任(_try_distribute_side不動),送了=免費(不再對餓子民定價)·ownerless 1/6小edge順手(owner==null distribute允許deposit到tile非bail,複雜則tracking)·★審點:①免費gift非crank(發賑濟決策=mini-util人格不動,免費=修dead-code路非藉機讓distribute過,本病=餓子民被定價非util低)②coin守恆(bid=0→coin雙向no-op)③人格語意保留(仁慈/責任gate該不該送,greed低不派=正確emergent)④economy不爆(food_surplus守reserve,convoy cargo語意不變)⑤de-patch非增殖(改一行override_ask啟用既有free_dist dead路非新機制)·CLEAN→build→re-measure症1端到端(distribute.deliver 5/6→6/6+food_delivered顯著>1+糧真到resident runway回升)→糧到仍不足救=economy-balance follow-up→QA"
---

# R² 審 distribute 免費直注 relief（blueprint GO、機制最後一 bug）

**spec**：`docs/superpowers/specs/2026-08-04-infonet-distribute-free-relief-HOW.md`
**root（diagnostic #6 重現、bed persist 0b599dc8）**：distribute 賑濟 convoy 6/6 arrive（非黑洞）、卡 settle 站、5/6 bail（`sell_owner_no_coin×4/sell_ownerless×1`）。`interaction:765` distribute 注 `override_ask=local_value×price_factor`、**免費仁君路 `free_dist=(override_ask==0)` UNREACHABLE**（price_factor 永不 0）=dead code 實作 bug。
**WHAT 裁**：blueprint GO——distribute=gift 直注。

## 一句話修法
`interaction:765` distribute `oask=0.0`（免費直注）→ 啟用既有 `free_dist` 路（跳 owner-coin bail → `TileBank.deposit` 食物免費存 resident 據點 → coin no-op 守恆 → `distribute.deliver`）。

## ★審點（R² refute checklist）
1. **免費 gift 非 crank**（[[feedback_genuine_value_not_crank]]）：**發賑濟決策=mini-util 仁慈/責任**（`_try_distribute_side` 不動）；免費=**修 dead-code 免費路**（SLICE B 本設計但 price_factor 永不 0 使其不可達）、**非藉機讓 distribute 過**。本病=**餓子民被定價**（荒謬）、非 util 太低。確認非 crank。
2. **coin 守恆**：`bid=0` → `ResourceBank.add(visitor/owner, coin, ±0)` = coin 雙向 no-op。確認守恆維持。
3. **人格語意保留**：仁慈/責任 gate「該不該送」（低仁君不派=正確 emergent）；送了=免費 gift。確認 mini-util 人格未動。
4. **economy 不爆**：`sellable` 已扣 reserve（convoy cargo 語意不變）、food_surplus 守。確認。
5. **de-patch 非增殖**：改一行 override_ask（啟用既有 free_dist dead 路）、非新機制。

## 邊界
- **ownerless 1/6 小 edge**：`:854 owner==null` 前置 bail、free_dist 前——distribute 到 ownerless 據點仍 bail。順手允許 deposit 到 tile（複雜則標 tracking、1/6 小、override_ask=0 已解 4/6 主體）。確認此 edge 處理合理。

**CLEAN → 回 systems → build（續 `feat/info-network-whole`）→ re-measure 症1 端到端（`config/infonet_whole.json` persist bed、`distribute.deliver 5/6→6/6` + `food_delivered` 顯著 >1 + ★糧真到 resident runway 回升）→ QA 故事稽核（回溯三因果+whole、verdict ref）→ blueprint 判 arc-done vs economy-balance follow-up → 推用戶驗收。** 卡/BLOCKER → 報 `to:systems`。
