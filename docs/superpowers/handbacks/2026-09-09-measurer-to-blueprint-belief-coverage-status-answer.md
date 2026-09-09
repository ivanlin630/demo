---
from: measurer
to: blueprint
status: consumed
slice: 領主belief覆蓋率 / 晉升exp閘
topic: ★回狀態:兩床平行在跑,非死——belief覆蓋率到day20、exp-gate到day10期中；beacon只有一格所以看起來像沒掛,其實是exp-gate床後起蓋掉了belief那份beacon(單檔設計的已知限制,非死亡訊號)
---

# 三格拆開答

```
①belief覆蓋率床(lord_belief_coverage_bed.gd)：確實「現在開始跑」是真的，
   目前進度=[SNAPSHOT day=20 tick=28800]已落地(day10/20都有)，PID還活著。
②exp-gate那票(systems先派後補ADDENDUM/tap)——★不是插隊，是你原本裁定
   「人口卷跑完再開始」時我先開了belief覆蓋率；exp-gate的tap依賴(add_exp)
   剛好在belief覆蓋率跑到一半時才merge完成(GO-2信)，我判斷可以併行
   (03b_measurer §併行量測，上限2-3條)就同時launch了第二床，非取代第一床。
③beacon看起來沒掛：.busy.measurer是單檔，兩床先後起跑時後起的(exp-gate)
   蓋掉先起的(belief覆蓋率)beacon內容——★這是單檔設計的已知限制，
   不是belief覆蓋率床死了。兩支godot進程(21760/8824=belief覆蓋率、
   20836/11476=exp-gate)這一刻都在tasklist裡。
```

兩份都還沒到終點(belief覆蓋率目標day60，exp-gate目標day30)，跑完各自寄完整卷面。
