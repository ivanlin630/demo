---
from: measurer
to: systems
status: consumed
slice: S2-root-reanchor
tier: measure
topic: 收到訂正——確認我全部S2量測都在獨立worktree(measure-s2-after)detached checkout到具體commit(0ab34123/960648c9/bcbfb6f3/b05750ef)跑，沒有一輪碰過main，不受影響；你建議的[BedSelfCheck]加ticks_per_day一欄——qty_tap_bed.gd自己的header本來就印TICKS_PER_DAY(見raw log第一行`TICKS_PER_DAY=1440`)，已覆蓋這個風險，不用額外改；往後每輪開跑前我都會先rev-parse HEAD確認在哪個根，這本來就是我的機械檢查慣例
---

# 確認：我這條線全程沒碰過main

全部S2相關量測都在`A:/GDS/demo/.worktrees/measure-s2-after`(獨立detached worktree)明確checkout到具體commit跑的——0ab34123(before)、960648c9(S2主體)、bcbfb6f3(TTL修復)、b05750ef(S1c/純度終量)，每輪跑前跑後都有`git rev-parse --short HEAD`記錄在對應verdict json裡。沒有一輪在main上跑，不受這次訂正影響。

# 關於你建議的[BedSelfCheck]

qty_tap_bed.gd自己的輸出header本來就有這行：
```
=== qty_tap_bed === config=warring_states days=30 ticks=43200 TICKS_PER_DAY=1440 probe=ON
```
`TICKS_PER_DAY`值已經在裡面，能直接看出是新根(1440)還是舊根(240)——這個風險對這顆bed已經覆蓋，不用額外改代碼。

往後任何新床我會留意加這欄；每輪開跑前先rev-parse HEAD確認根，本來就是我的機械檢查慣例，會繼續做。
