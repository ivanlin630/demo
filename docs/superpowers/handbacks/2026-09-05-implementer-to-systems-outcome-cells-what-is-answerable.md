---
from: implementer
to: systems
status: consumed
slice: ★blueprint 那兩格：①【本輪就答得出來，零新 tap】②【需要 production tap ⇒ 凍結中做不到】
touches: 分析 RERUN-3 三張（跑批 `bkbfyit35` 進行中）
topic: ★★★①結局分布**不必加 tap**:production 已有 `crisis.abs_hunger.team.<id>`(per-team、無 cap)＋卷面已印 `[DonorAftermath]`(每隊 end／pop_end)⇒ ★兩者【交叉】就是「餓過的隊後來怎麼了」,而那正是①要的 ⇒ **我用 RERUN-3 的卷直接算,不重跑不加 tap**;★★②選項有效性(返家補給→家裡真有糧嗎／買糧→真買到嗎)**兩半都要 production tap** ⇒ 凍結中,同上一封,標【答不了】並排在解凍後第一批;★★★而 blueprint 那句我要記下來:【撤回 ≠ 自動變要修】
---

# ★★★①結局分布：**本輪就答得出來，而且零新 tap**
```
★production 已有：`crisis.abs_hunger.team.<id>`（★per-team、★★無 cap 不取樣 ⇒ 相異隊與次數都在）
★★卷面已有：`[DonorAftermath] team=N … end=存活/團滅 … pop_end=K`
⇒ ★★★兩者【交叉】＝「曾經餓到歸零的隊，90 日後怎麼了」—— **那正是①要的**
⇒ ★所以我【不加 tap、不重跑】，用 RERUN-3 的三張直接算
★★而分類我用【卷上已有的欄位】而不是自己發明：
   `死`＝`end≠存活`｜`空殼`＝`存活` 而 `pop_end==0`｜`撿回`＝`存活` 且 `pop_end>=1`
   ⇒ ★★★而「穩定」我【不給】—— 它需要一個判準（幾人算穩定），而那是你/blueprint 的字不是我的
     （★同今天存活四分那一格：我填得出三格，第四格是判準不是儀器）
```

# ★★②選項有效性：兩半都要 production tap ⇒ 凍結中做不到
```
★「返家補給那 30%：家裡真有糧嗎」⇒ 要在【選它的那一刻】讀那個家的存糧 ⇒ production
★★「買糧那 20%：真買到了嗎」⇒ 要追那張單的結局（成交/撲空/沒錢）⇒ production
⇒ ★★★兩半都是世界路徑，而凍結檔還在 ⇒ **我不做**（同上一封的理由，不再自己判斷該不該）
★而形狀我先寫好，解凍後可以直接接：
   ①`restock.home_food_at_choice.{有/無/沒有家}`  ②`buyfood.outcome.{成交/無貨/無錢/逾時}`
   ⇒ ★★兩格都要【互斥且窮盡＋對帳】，而②要與既有 order 漏斗對得起來（不新開一套帳）
```

# ★★★③而 blueprint 那句我要記進來
```
★【撤回 ≠ 自動變要修】—— 我打掉「孤身走去投靠」那個故事之後，
   ★★下一步【不是】「所以要修」，而是【那它們選的那些，work 嗎】
⇒ ★★★這是我今天差點漏掉的一格：**證偽一個解釋，不等於證實了有病**
   —— 而我上一封確實只寫到「不成立」就停了，是 blueprint 補上後半的
```
