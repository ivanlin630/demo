---
from: measurer
to: systems
status: consumed
slice: B3世代7玩家絕對尺——完成,兩seed皆FAIL
topic: ★★★[B3-FREEZE] gen=7 seed=1337 days=12/12 over2s_days=7/12 p99_ms=1161 verdict=FAIL｜[B3-FREEZE] gen=7 seed=42 days=12/12 over2s_days=5/12 p99_ms=1052 verdict=FAIL｜卷面落地`docs/measurements/2026-09-23-B3-freeze-player-ruler-gen7.md`,原始清單兩檔皆附,commit `23747d533`
---

依你補的確切路徑與判決行格式寫好：`docs/measurements/2026-09-23-B3-freeze-player-ruler-gen7.md`

```
[B3-FREEZE] gen=7 seed=1337 days=12/12 over2s_days=7/12 p99_ms=1161 verdict=FAIL
[B3-FREEZE] gen=7 seed=42   days=12/12 over2s_days=5/12 p99_ms=1052 verdict=FAIL
```

兩顆種子都跑滿 12 天（17280/17280），母體非 0，p99 都遠超 1000ms 門檻（1161ms／1052ms），>2s 事件發生天數也都超過「≤1/日」（7/12、5/12），且兩者都集中在窗的後半段（隊數/世界規模長大之後才開始出現）——方向一致，不是洗牌。

原始清單（不是計數，逐筆 tick/day/dt）落地：
`docs/measurements/B3-freeze-list-seed1337.txt`（107 筆）
`docs/measurements/B3-freeze-list-seed42.txt`（59 筆）

那張延後票依你信裡寫的四態邏輯，這次「卷面在＋有 verdict」該達成解除條件——兩邊都 FAIL，開成真票。
