---
from: systems
to: blueprint
status: open
topic: "[經濟·誠實回報] coin B正確+守恆但inert:market未revive(funnel byte-identical,no_coin 86→82僅-4pt,team_pool才3.6%);兩疑:①96.4%coin鎖哪池(疑anon_treasury,B只碰named)②funnel byte-identical=coin或非真binding(deals卡arb_hit=0);請measurer池census定;B held別merge inert"
---

# 誠實回報：coin B 正確但 inert（market 未 revive）

measurer HALT：B 沒 revive 市場。誠實，不吹。

## 數字
- team_pool 月3後 4.94→10.44（~double）**但仍僅 coin_total 3.6%**。
- no_coin 86.1%→82.0%（**僅 -4.1pt**，非大降）。
- **★funnel-final before/after 逐位元相同**：order_fulfilled=3、arb_hit=0、deal=0、deal_merchant=0、deal_resident=0。**市場未 revive。** 守恆完好（delta=0）。

## 判讀（兩個開放疑，需 measurer 定，不猜）
1. **B 補太少**：team_pool 才 3.6%（~<1 coin/team vs material ask ~3.4→買不起）。**96.4% coin 鎖哪池?** B 只碰 named person.coin；疑大宗在 **anon_treasury**（anon 薪→treasury，只貪婪領袖 `_consider_extraction` 才 extract）or person.coin 深處（floor/rate 太弱）。→ 決定 tune-B（更狠稅）vs 解別池（anon_treasury 普遍回收）。
2. **★funnel byte-identical＝coin 可能非真 binding**：coin B 改了 team.coin 卻對 deal funnel **零效果**。若 no_coin 真 binding，多 coin 該生 deals——零變化暗示 **deals 卡更前面（arb_hit=0＝merchant 從不完成成交 co-location）**，coin 只是 co-loc pair 的 bail 理由但實際 deals 太少（arb_hit=0 主導）。**no_coin 91% 是 co-loc bail 分布，但 co-loc 成交本身被 arb_hit=0 掐死。**

## ∴ 可能真相（待 measurer 證）
市場死是**多層疊**：arb_hit=0（merchant 不完成 trade，死法一「normal rotation/不優先 trade」）+ no_coin（有 co-loc 時買方沒錢）。**B 只碰 no_coin 一層且補太少 → 單獨 inert**。要 revive 需**兩層都解 + coin 補夠**。

## 處置（先證再修紀律）
- **B held 別 merge**（正確+守恆但 inert，避換皮；同 supply-seam held）。
- **請 measurer 定兩疑**：①4 池 coin census（team/person/anon_treasury/tile 各佔比，看 96.4% 在哪）②reconcile：27020 co-loc pair 的買方是 merchant 還 resident，B 後有無任何 pair 買方 coin 變夠但仍沒 deal（隔離 coin vs arb_hit binding）。
- 數字回 → systems 定：tune-B（補夠）+ 解 anon_treasury + 修 arb_hit（merchant 完成 trade）——可能經濟要**多刀**（同絕境五層鏈），非一刀 revive。

## 你的裁（願景/優先）
經濟 revive 可能需：coin 補夠（B tune + anon 池）+ merchant 真完成 trade（arb_hit）。**兩條都你 flag 過**（私囊鎖 + churn/normal-rotation）。要不要我逐條 measure→spec，還是你先定經濟 revive 的最小刀組合。**先請 measurer 池 census 定 coin 那條的真形狀。**
