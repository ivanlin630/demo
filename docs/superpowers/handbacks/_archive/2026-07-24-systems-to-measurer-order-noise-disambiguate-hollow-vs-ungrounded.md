---
from: systems
to: measurer
status: consumed
topic: "[低優先·order-noise disambiguate·arb_kill_nostock 42k-84k(上個 material-supply run 已抓)per-res 拆解+cross-ref production→hollow-economy(訂單找沒隊產的 res)vs ungrounded(res 存在但掛單沒 grounded)·可能不用新 run 用既有 run 數據] blueprint 裁 arb_kill_nostock 42k-84k(全 res,巨大)可能是空經濟症狀(訂單找不存在的 material/goods,因沒隊產)非純掛單 discipline gap,要 disambiguate(連 material-supply root)。問:killed-nostock 量**按 res 拆**——被殺最多的是哪些 res?那些 res **有沒有隊在產/採**(cross-ref production/harvest 量)?→(a)若集中在沒隊產的 res(material/goods 因沒 forest outpost→沒供給)=**hollow-economy 症狀**(訂單找不存在的貨)=material-supply root 的下游現象,root 修好自然消(非獨立掛單 bug)(b)若是有隊產但掛單沒對到 stock=**ungrounded 掛單**=獨立 order-layer discipline gap 要修。★可能不用新 run,上個 material-supply run(a728fe90 seed42/1337)的 arb_kill_nostock 已抓,按 res 拆+對 production 即可。低優先(keystone spec 在飛,這不擋)。→回 to:systems。"
branch: main (a728fe90)
---

# order-noise disambiguate：hollow-economy vs ungrounded（低優先，另案）

blueprint 裁 **arb_kill_nostock 42k-84k**（全 res，巨大）可能是**空經濟症狀**（訂單找不存在的 material/goods，因沒隊產）非純掛單 discipline gap → disambiguate（連 material-supply root）。

## 問
1. killed-nostock 量**按 res 拆**——被殺最多的是哪些 res？
2. 那些 res **有沒有隊在產/採**（cross-ref production/harvest 量）？

## 判讀
- **(a) 集中在沒隊產的 res**（material/goods 因沒 forest outpost → 無供給）= **hollow-economy 症狀** = material-supply root 的下游現象，root 修好自然消（**非獨立掛單 bug**）。
- **(b) 有隊產但掛單沒對到 stock** = **ungrounded 掛單** = 獨立 order-layer discipline gap 要修。

## 成本
- **可能不用新 run**：上個 material-supply run（a728fe90，seed42/1337）的 arb_kill_nostock 已抓，按 res 拆 + 對 production 即可。
- **低優先**（keystone spec 在飛，這不擋）。→ 回 `to:systems`。
