---
from: systems
to: reviewer
status: open
slice: merchant-turnover-cost
topic: ★R² 審 HOW spec：商人持貨機會成本 ＝ 當下可得的最佳套利 gain（非歷史版）｜★★請優先打兩處:①我的常數自由正規化(gain/holding_value)是不是真的無因次且語意對 ②母體鐵則(ARCHETYPE_TRADE 不得用 TAG_MERCHANT)我查到的證據夠不夠硬
---

# 送審
```
spec  docs/superpowers/specs/2026-09-08-merchant-turnover-cost-HOW.md
前情  premise-correction（best_score 算了就丟／無套利歷史）已送 blueprint 並獲核可改用「當下 gain」
```

# ★請優先打的兩處

```
①★★常數自由的正規化：turnover_urg = clamp(arb_gain / (local_value(seller,res)*qty), 0, 1)
   ⇒ 我宣稱它【無因次、同源、零新常數】。★請你查：
     (a) 兩邊真的是同一種單位嗎（gain 是 (mine−ask)×qty；holding 是 local_value×qty）？
     (b) 語意對嗎——「我放棄的套利值不值我手上這批貨」？
     (c) 有沒有一種情形會讓它【恆為 0 或恆為 1】（我最怕的是恆 0＝靜默無效）。

②★★★母體鐵則：我要求用 ambition_archetype == ARCHETYPE_TRADE，禁用 TAG_MERCHANT。
   證據：decision_context.gd:325 用 TAG_MERCHANT ／ defers token
        `genesis-merchant-weight-empty-population` 仍掛（random-mode 0 隊）
        ／ interaction_system.gd:852 註解記著「R²#7：ARCHETYPE_TRADE 分流」
   ⇒ ★請你確認【那個 token 描述的情況現在仍然成立】——
     若 TAG_MERCHANT 在現行 config 下其實非空，我的鐵則就是多餘的限制。
     （★我沒有量現行世界的 TAG_MERCHANT 隊數，這是我的未驗前提。）
```

# 我複驗過的
```
order_system.gd:447/505/527/530  best_score 算了但不在回傳 dict
decision_context.gd:259          c.has_arb 只留布林
production 的 arb history/turnover ⇒ 0 處
```
