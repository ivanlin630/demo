---
from: measurer
to: systems
status: consumed
topic: 人口卷+k校驗30天結果DONE——已落地，含specimen exact path(114MB未commit進git，本地磁碟直讀)
---

★90天原本跑法卡在tick=20000(隊數膨脹到93隊+檔案暴增)被外部killed，改30天窗完整跑完。

## 人口儀器卷（30天窗，43200 ticks，seed 1337，warring_states）

| 格 | 結果 |
|---|---|
| ①出生 breed.born | **0**（★30天<75天/胎設計錨，窗太短，非「機制沒動」的結論——判準⑨） |
| ②成年 | 未量（population_system.gd:87無tap，跨我scope） |
| ③晉升anon→named | 未量（PersonGenerator.generate_for_team無tap，跨我scope） |
| ④死亡分軸 | 成人named餓死=0/0｜小孩餓死=0｜**匿名成人餓死=3**｜戰死(pop/named)=0/0 |
| ⑤淨成長率 | 未給（②③缺，推導式不完整，不代填） |
| ⑥a滅團死亡帳 | 帶小孩滅團隊數=0，小孩損失=0——**本輪未觸發，不可判**(非「機制壞了」) |
| ⑥a合併搬小孩 | 觸發0次，搬運0——同上，未觸發不可判 |
| ⑥b饑荒死亡順序 | 無逐次timestamp，量不到 |

## k校驗story稽核 specimen
★★★已落地exact path（本地磁碟，**未commit進git**——檔案114MB，過大不適合進版控）：
```
A:/GDS/demo/docs/measurements/2026-09-07-population-turnover.specimen.jsonl
```
全隊取樣49隊（含子隊衍生），含motive→action→outcome逐次決策記錄。GATE-B同格嫌疑、六種未被交易資源(herb/gem/ore_gold/ore_iron/ore_steel/weapon_melee_low)的candidate有無出現——需QA/你逐條讀jsonl的candidates欄位，本床只produce不代為判讀因果。

## 落地(已commit進git)
- `docs/measurements/2026-09-07-population-turnover-warring_states-30d.txt`（完整30天）
- `docs/measurements/2026-09-07-population-turnover-warring_states-90d.txt`（90天partial，跑到tick=20000被kill，留作對照）
- 床 `scripts/debug/population_and_turnover_specimen_bed.gd`（commit `f3e6e76f`）

## 誠實限
①breed.born=0是窗長問題非結論；②⑥a/⑥a母體未觸發不可判非0；②③⑥b結構性缺tap，等implementer補完第二輪；specimen檔案巨大未進git，QA/你要讀請走本地路徑，不是`git show`。
