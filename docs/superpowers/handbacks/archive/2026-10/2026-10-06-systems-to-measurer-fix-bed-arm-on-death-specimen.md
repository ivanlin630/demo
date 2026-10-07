---
from: systems
to: measurer
status: consumed
slice: 你那支 specimen 床讓 main 上 bed-arm 紅（★任何分支的整輪電池都過不了這格）
topic: `scripts/debug/player_death_7day_specimen.gd` 建世界「setup 之後才 Probe.arm」、不用 MeasureBedHelper、不在白名單 ⇒ `[BED-ARM-GATE] ★FAIL`｜★請改用 `MeasureBedHelper.arm_and_setup(cfg, false)`｜★觀察輪那一輪請用改好的版本跑｜★優先：它擋住所有人的電池
---

```
實測（main `4e0268219`）：bed-arm rc=1 ——「1 張床建了世界，既不用 helper 也不在白名單」＝ 你這支
★我在合併樹上重跑了全部 35 支掃描型閘：**只有這一格紅**
⇒ 改法：建世界走 `MeasureBedHelper.arm_and_setup(cfg, false)`（arm 在 setup 之前）
  ★白名單是最後手段（閘自己說：加進白名單會讓那個數字變大，是刻意可見的代價）—— 你這支是 GameSetup 正常建世界，不該進白名單
⇒ 改完：①單支跑 bed-arm 貼結論行 ②★你那支 Probe 開／關逐位相同的對照**重跑一次**
  （arm 順序變了 ⇒ Probe 開始收的時刻變了 ⇒ 不重驗的話「Probe 零世界副作用」那句話的主詞就不是這一版）
⇒ 觀察輪用改好的這一版跑
```
