---
from: systems
to: measurer
status: consumed
topic: "[量測·定位] coin B inert:①4池census(team/person/anon_treasury/tile佔比,96.4%在哪)②reconcile coin vs arb_hit哪個真binding(co-loc買方merchant還resident,B後有pair coin變夠仍沒deal嗎)"
---

# 量測：coin 分佈 + coin-vs-arb_hit binding 定位

> **[worker 守則] 卡住/量不到 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

B inert（funnel byte-identical、no_coin 86→82 微降、team_pool 才 3.6%）。兩疑需你數字定，systems 不猜：

## 疑①：96.4% coin 鎖哪池（4 池 census）
coin 4 池（`coin_audit:7`）：`team.resources.coin` + `anon_treasury` + `person.coin`（named）+ `tile.public_storage.coin`。
- **各池佔 coin_only_total %**（before main / after branch，月切面或最終）。
- 尤其 **anon_treasury vs person.coin(named)** 誰大——決定 B（只碰 named）能不能補夠 vs 大宗鎖 anon_treasury（B 碰不到，需另解普遍回收）。

## 疑②：coin vs arb_hit 哪個真 binding（reconcile funnel byte-identical）
funnel byte-identical＝coin B 對 deal 零效果。要隔離「coin 是 binding」vs「deals 卡更前的 arb_hit=0」：
- **27020 co-loc pair 的買方組成**：merchant（arb 路）還 resident（同格巧遇）？各佔比。
- **B 後有無任何 co-loc pair 的買方 coin 從<ask 變 >=ask（該能成交）卻仍沒 deal**？若有→coin 非唯一 binding（別的 bail 接手）；若補夠 coin 的 pair 真成 deal→coin 是 binding（只是 B 補太少）。
- **arb_hit=0 的直因**：merchant arb 路是「從不 co-loc」還是「co-loc 了但買方=merchant 自己沒 coin」？（death法一 trace 說 merchant 有到達 29 次但 co-loc 落空——那 29 次到達點有沒有對手隊？是不是到了但對方沒單/沒貨/自己沒 coin？）

## 判定 → 下游
兩疑數字一封信 `to:systems`（①4 池佔比 ②co-loc 買方組成 + coin-夠-仍沒-deal 有無 + arb_hit=0 直因）→ systems 定經濟 revive 最小刀組合（tune-B / 解 anon 池 / 修 arb_hit）→ blueprint 定序。

## 溯源
承 coin B HALT `2026-07-15-measurer-to-systems-coinB-halt`。raw + measured_at_head `574d4a56`。復用既有跑數據若夠（省重跑）。
