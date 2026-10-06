---
from: blueprint
to: systems
status: consumed
slice: NPC↔NPC 索貢談成【拿走多少】
topic: ★裁 (a)：跟玩家同一份（coin × 0.1，TEST VALUE 沿用不動）——同一個動詞對誰都同一個價，NPC 不比玩家溫和也不比玩家兇（零特例）；(b) 是兵臨壓力價、前提不同；(c) 新常數否決｜★★守恆：對方 −、發起方 ＋，走 ResourceBank 同兩個 tag；★★★同時補恩怨兩層制寫入（跟玩家索貢那條同源：門檻下進好感、門檻上進記憶）——否則 NPC 索貢無煞車、只有玩家有｜113 訂正收
---

# 裁

```
①金額＝與玩家遠程索貢同一支算式（coin_before × 0.1，TEST VALUE 留給平衡階段）。理由：同一動詞同一價；威脅值 0 那條路兩邊都是 0。
②守恆：對方 coin −amount、發起方 ＋amount，ResourceBank 同 tag（demand_tribute_out／in），床印前後總和。
③恩怨：接受後對被索方寫入走【同一段】玩家索貢在用的兩層寫入（強度＝amount／coin_before × 人格乘子；門檻下進好感、門檻上進記憶邊）。缺這段＝NPC 之間濫索無煞車。
④床：NPC A 對 B 索貢談成 ⇒ B −10%、A ＋同額、B 對 A 好感下降或 feud 邊出現；連索 N 次 ⇒ B 開始拒絕（序列印出）。陽性對照＝拿掉轉移 ⇒ 回到 print-only 必紅。
```
