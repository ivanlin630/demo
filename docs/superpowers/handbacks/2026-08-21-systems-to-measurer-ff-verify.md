---
from: systems
to: measurer
slice: failure-feedback
status: consumed
topic: "[量測·失敗反饋 Phase 0 獨立驗證(branch feat/failure-feedback @167d6922,★等 implementer 同步 main 後才有 specimen 血緣修)·要驗的主張:order.placed 357→356、filled 3→3、abandoned 290→290【完全沒動】、failure.recorded 169、failure.suppressed.買單 64、decision.opt_chosen.買糧 36→29(−19%)·★這張票的重點不是『有沒有變好』而是【並排讀】:只看 abandoned 會判『機制沒效』,只看 suppressed 會判『有效』,並排才看得出折價作用在另一個地方(掛單是機械層不經 util)、GATE-B 填單率 0.8% 一點沒被碰到·★我特別要一個數字:failure.suppressed 的 64 次裡,有多少次【當下該隊確實有 買糧 option 且沒選】vs 多少次是【本來就不會選】——區分『真的抑制了行為』與『抑制了不存在的行為』(前者是機制生效,後者是 tap 在自我安慰)·長跑前寫 .busy.measurer beacon;帶 commit+日期+重跑指令"
---

# 量測：失敗反饋 Phase 0 獨立驗證

**branch** `feat/failure-feedback` @ **`167d6922`**。
★ **等 implementer 把 main 同步進去**（specimen 血緣修在 main）**再產 specimen**；聚合數字可以先跑。

## 要驗的主張（30 天 / peaceful_economy / seed 1337）
`order.placed` 357→356、`filled` **3→3**、**`abandoned` 290→290（完全沒動）**、
`failure.recorded.* = 169`、**`failure.suppressed.買單 = 64`**（最深折價 0.595）、
`decision.opt_chosen.買糧` **36→29（−19%）**。

## ★這張票的重點不是「有沒有變好」，是【並排讀】
- 只看 `abandoned` → 會判「**機制沒效**」
- 只看 `suppressed` → 會判「**有效、有在抑制**」
- **並排才看得出真相**：折價**作用在另一個地方**（掛單是機械層、不經 util），
  **GATE-B 填單率 `3/357 = 0.8%` 一點沒被碰到**。

## ★我特別要一個數字
`failure.suppressed` 的 **64 次**裡：
- 有多少次是「**當下該隊確實有 `買糧` option、而且沒選它**」＝**真的抑制了行為**
- 有多少次是「**本來就不會選**」＝**抑制了一個不存在的行為**（那 tap 就是在自我安慰）

★ 這個區分很重要：`opt_chosen 36→29` 只證明**總量下降**，不證明**下降的那 7 次就是被折價擋掉的**。

長跑前寫 `.busy.measurer` beacon；回報帶 **commit ＋ 日期 ＋ 重跑指令**。
