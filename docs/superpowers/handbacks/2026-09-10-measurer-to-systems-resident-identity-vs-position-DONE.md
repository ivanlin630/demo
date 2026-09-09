---
from: measurer
to: systems
status: consumed
slice: 居民——身分vs位置拆解
topic: ★交件+撤回：推翻我上一卷「這個世界沒有村莊」的結論——村莊(TAG_PRODUCE)健康成長day10=2→day60=22隊,真相是【居民持續不在家】(day60不在家13隊>在家9隊),決策層問題非造層問題｜★④累計settle/convert=0/0不可信(driver_ledger溢出丟棄277萬筆),別引用
---

# 交件

```
.measure.json：docs/process/verdicts/resident-identity-vs-position.measure.json
raw log：docs/measurements/2026-09-10-resident-identity-vs-position.txt
床：scripts/debug/resident_identity_vs_position_bed.gd
窗：warring_states/seed=1337/60天，5次快照(同上一卷可比)
★中途撞過一次系統OOM(非GODOT_TIMEOUT，driver_ledger cap 500000太貪心)，
  降到20000後重跑成功——這個教訓已commit記在床檔頭。
```

# ★★★推翻上一卷結論

```
day10 身分①=2  在家②=0  不在家③=2
day20 身分①=4  在家②=1  不在家③=3
day30 身分①=6  在家②=2  不在家③=4
day45 身分①=14 在家②=8  不在家③=6
day60 身分①=22 在家②=9  不在家③=13  ★不在家已超過在家
```

⇒ 村莊(TAG_PRODUCE身分)健康成長到22隊，不是『沒有村莊那一層』。真相是
【居民持續不在家】——你判讀出口②猜對了：村莊存在，居民不在家=決策層問題
(為什麼生產隊一直被派出門)，不是造層問題。

★我上一卷『這個世界沒有村莊』『隊絕大多數在移動作戰極少定居』的結論在此撤回，
被本卷①身分健康成長的實測直接推翻。.measure.json的supersedes欄已記錄。

# ④累計授予/移除——不可信，別引用

```
settle=0 convert_resident=0 uprising_exile=0
但driver_ledger累計丟棄筆數=2777058(cap=20000，60天窗×全部tags變動塞爆)
①身分隊數2→22本身就證明『變成居民』發生過很多次⇒這個0是被丟棄造成的假象。
要真的量④需要換方法(不透過driver_ledger)，見.measure.json honest_limits③。
```

順帶：在家比例day45(57%)→day60(41%)不升反降，如實記錄不深究成因。
