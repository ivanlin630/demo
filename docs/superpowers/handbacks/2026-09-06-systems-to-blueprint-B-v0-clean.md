---
from: systems
to: blueprint
status: open
slice: B-v0 spec CLEAN（★而它停在同⑨的 token 後面）
topic: ★B-v0 spec R² CLEAN,三條補的已折入;★★而 R² 抓到一個【具體會撞的假設】,我親自讀 order_system.gd:371-400 驗過:settle_orders 是【從副作用反推】(觀察 team 自己 resources 的 delta),而 escrow 是【掛單當下一次扣光】⇒ posting 那一刻存量掉了整單 ⇒ 下一次 settle 會把它判成【整單成交】而一件都沒賣;★★★而它的對稱失敗是【後續真實成交完全偵測不到】—— 兩種都不會報錯、方向相反,所以「看起來合理」救不了它;已立成不變量【兩種記帳方式不能同時管同一張單】;★另兩條:泛型待領資產(kind:coin|goods)採用但【行為級驗收仍分開量】(抽象共用不代表會被同等使用),野外率【分母必須真的印出來】母體空判不可判
---

# ★B-v0：R² CLEAN，三條補的已折入

## ★★而最重要的是他抓到的那個【具體會撞的假設】（★我親自驗過）
```
order_system.gd:371-400 `settle_orders`:pool[res] = resources[res](now) − before[res]
   sell 分支要 avail < 0(自己的存量【減少】)才算成交
★而 escrow 是【掛單當下一次扣光】⇒ posting 那一刻存量就掉了整單的量
⇒ ★★下一次 settle_orders 看到 avail = −qty ⇒ 【整單被判成交】,而一件都還沒賣掉
⇒ ★★★對稱失敗(換個順序):後續【真實成交】完全偵測不到
```
★**兩種失敗都【不會報錯】，而且【方向相反】** —— **所以「看起來合理」救不了它。**
⇒ 已立成不變量（`docs/process/detail/invariants-cases.md`）：
```
【兩種記帳方式不能同時管同一張單】——【從副作用反推】vs【事件權威】
★規則:同一張單只能有一個記帳權威;引入事件權威就必須把該單【明確排除】在 delta 反推之外
★★識別法:問「這張單的數字,有沒有【第二個地方】也會動它?」—— 有 ⇒ 兩者必須有一個是【唯讀的】
```

# ★另兩條
```
①泛型【待領資產】{kind: "coin"|"goods", …} —— 採用(腦欄位一個、option 一個,讀 kind 算價值)
   ⇒ ★★而【行為級驗收仍然分開量】:抽象共用【不代表】它們會被同等使用,而那正是要量的東西
②野外率:【分母必須真的印出來】,不能只印比率;母體為空 ⇒ 判【不可判】不是判紅
   ⇒ ★而 R² 說這【不是留退路,是誠實揭露】—— 我原本自己也不確定,所以交出去判
```

# ★現況（兩張經濟票都停在同一個 token 後面）
```
⑨貨幣創世   CLEAN ｜ token: money-genesis-start
B-v0 市場厚度 CLEAN ｜ token: market-thickness-v0
★兩者 met_check 相同(對比輪的量測檔已產出)⇒ 【同窗換世界】,不會互相打架
★★而在那之前:⑧收口(implementer 手上)→ 批後同 seed 對比 → 兩票同窗動工
```
