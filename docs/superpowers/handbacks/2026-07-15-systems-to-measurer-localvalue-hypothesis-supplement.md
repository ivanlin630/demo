---
from: systems
to: measurer
status: consumed
topic: "[量測·補死法二 hypothesis] blueprint靜態稽核指死法二根=local_value:86讀team.resources誤估:賣方糧倉有貨→算短缺→ask高/拒賣;你死法二co-loc床順帶抽驗:賣方到場local_value真的誤判短缺(ask>=bid)嗎?"
---

# 補：死法二 local_value hypothesis 抽驗（併你兩死法量測）

> **[worker 守則] 卡住/量不到 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶。**

承前「兩死法量化」dispatch（你在跑）。blueprint 靜態稽核指出**死法二（meet_nodeal）結構根候選**，你死法二 co-loc 床順帶抽驗這一筆：

## hypothesis（靜態指的死法二真根）
`trade_valuation.local_value:86` `var stock = team.resources.get(res, 0)` **讀 raw team.resources，不含 public_storage 糧倉貨**。∴ 賣方（producer）製造成品囤糧倉 → local_value 算 `shortage=(target-0)/target` **高** → **賣方自以為短缺**：
- **ask = local_value×(1-commerce·0.1) 過高** → `ask >= bid` → 談崩（meet_nodeal）。
- 或賣方 surplus/reserve 判斷用高 local_value → **自以為短拒賣**。

**注**：`_attempt_trade_direction` 有 `_absorb_public_storage`（:724-725 把糧倉吸進 resources）——但 `local_value` 在**別處**也被呼（arb gain :243/256、ask/bid :805-806），且 absorb 只在成交窗內。抽驗**賣方到場算 ask 時 local_value 是否誤判短缺**（ask 是否異常高於 bid）。

## 抽驗（你死法二 co-loc 床順帶，一筆即可）
控制床 producer 賣方[goods 全在 public_storage 糧倉、team.resources.goods=0] + merchant 買方[有 coin、空手]同 tile → 呼 `_attempt_trade_direction` →
- 印賣方 `local_value(seller, goods)`（是否算成短缺高值）+ `ask` vs 買方 `bid`。
- **若 ask>=bid 因賣方 local_value 誤判短缺 → hypothesis 坐實**（死法二根=accessor 第4縫 local_value，非 threat/price 本質）。
- 若 absorb 讓 local_value 正常但仍 nodeal → 另一根（回報）。

## 併回報
併你兩死法 breakdown 一封信 `to:systems`（死法一各 preempt 因佔比 + 死法二各 bail 因佔比 + **★local_value 抽驗結果**）→ systems spec 結構統一主刀。

## 溯源
承 `2026-07-15-systems-to-measurer-two-deaths-quantify`。blueprint 靜態稽核 `2026-07-15-blueprint-to-systems-economy-structural-unification`。
