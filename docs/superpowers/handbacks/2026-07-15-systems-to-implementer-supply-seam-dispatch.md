---
from: systems
to: implementer
status: consumed
topic: "[DISPATCH] 供給seam修統一effective_holding accessor——R²過(Fix3訂正:賣+買短缺兩讀點一併);新分支feat/supply-seam-effective-holding;TDD守恆"
---

# Dispatch：供給 seam 修（統一 effective_holding accessor）

> **[worker 守則] 卡住/授權不明/做不到 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

spec：`docs/superpowers/specs/2026-07-15-supply-seam-effective-holding.md`（含 R² 訂正 Fix3 賣+買兩讀點）。
R² 判決：`2026-07-15-reviewer-to-systems-supply-seam-r2-issues.md`（accessor/守恆/food統一/施工隊 gate CLEAN；唯一 issue=Fix3 漏買單短缺讀點 :118，已訂正；reviewer 預 clear「:118 納入後 CLEAN 順手收非新設計」）。

## 在哪：新分支
`feat/supply-seam-effective-holding`，base 最新 main（`a51377f6`+）。

## 做什麼（4 Fix，統一 accessor 家族別再漏）
1. **`ResourceSystem.effective_holding(state, team, res) -> float`** = team.resources[res] + 自家 outpost public_storage[res]（泛化 `effective_food`，保 alias 不破既有 caller）。
2. **`ResourceSystem.spend_holding(state, team, res, qty) -> float`**（★守恆核心）= 先扣 public_storage 餘扣 team.resources（TileBank/ResourceBank chokepoint 走 ledger），不透支（扣到 0 為止），回實際扣量。
3. **★兩對稱讀點一併（R² 訂正）**：
   - `order_system:110` 賣單 `qty = effective_holding(...)`（取代 team.resources.get）。
   - `order_system:118` 買短缺 `if effective_holding(...) >= SHORTAGE_QTY: continue`（取代 team.resources.get）——不誤判短缺亂買倉裡有的貨。
   - `_tick_food_granary_sell` 同 refactor 走 effective_holding（不留兩套）。
4. **settle 扣對 storage**：`_execute_transfer:665` seller `res` 扣 `spend_holding(...)`（貨從 public_storage 出，守恆不賣幽靈貨；settle qty 用 min(order_qty, 實際可扣)）。buyer 收進 team.resources 不動。

## 守則
- **★資源守恆**：spend_holding 扣實際 storage 不透支/不憑空；CoinAudit=0、InvariantAudit=0。
- **只接 storage**，不改產能/價格/regen（產能 seam 修後 measure-first）。施工隊 `is_constructing` gate 保。
- **determinism** 零 randf。

## TDD（★守恆）
1. 定居隊 public_storage 有 goods → effective_holding 看到 → 掛賣單（賣單 fire）。
2. 定居隊 public_storage 有 material → 買短缺不誤判（不亂買已有的貨）。
3. 成交 → seller 從 public_storage 扣（守恆，public_storage 真減，不透支）。
4. 施工隊不賣建材；food 賣單照常。
5. 同 seed 兩跑 bit-identical；CoinAudit/InvariantAudit=0；headless 零新增；憲法 sites=29。

## 完成後
→ handback `to:systems` → measurer 中性 full-HD（★order_fulfilled 回升 + arb_kill_nostock 降 + coin 流 + 守恆 + **掛單噪音修前後對比=驗收#7**）→ QA → blueprint 批。
scope 疑義走 `to:systems`。掛單紀律（grounded-order/dedup/expiry）＝**噪音量測後定 scope，非本刀**（除非量測揭同刀順手）。
