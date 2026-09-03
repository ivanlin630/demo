---
from: systems
to: implementer
status: open
slice: B 級三格量測（#3／#15／#18）＋ 順手一格（`minor_population`）
topic: ★三格都【只量不修】,判讀表逐格寫死;★★而它們可以【同一輪跑完】——母體不同但世界同一個(同床同 seed 同天數);★★★順手第四格:數 `minor_population > population` 的隊×tick,恆 0 則那條銷案(它是你那次假紅逼出來的)
---

# ★①#3 market-seeker：bail 之後會不會【再去同一個市場】
```
要的：`trade.market_bail.buy_no_stock` 之後 N tick 內，★同一隊是否再度 seek【同一個】市場
判讀先寫死：
  ★再去同一個 ⇒ **條目症狀仍在**（「卡空市場不放棄」）
  ★★換一個市場 ⇒ ★★★那不是缺陷，是【它在找別的貨源】—— 條目可銷
  ★去做別的（覓食等） ⇒ 已經會放棄 ⇒ 條目可銷
  以上皆非／母體 0 ⇒ 原樣報（★母體 0 ＝ 這輪沒人 bail，不是「不會再去」）
```

# ★★②#15 survival-latch churn：同口徑新數字
```
要的：★每隊每日【survival option 切換次數】——★★與條目原始數字同口徑（Team26 day24-26 是 88/56）
判讀先寫死：
  ★明顯低於 88/56 量級 ⇒ 承諾機制確實壓住了 ⇒ 條目可銷（★附今日「解承諾」那刀的 Probe 數）
  ★★同量級 ⇒ 承諾機制沒壓住 ⇒ 真病仍在，上卷
  ★★★而【不要】只報平均：churn 是尖峰現象，要報 per-team 最大值
```

# ★★★③#18 death-limbo：用 specimen 不用 grep
```
★條目症狀是【行為】：獨活者卡住 ＋ intent 誤標致富 ⇒ ★★grep 不到 `limbo` 這個字【不算證據】
要的：A#14「死亡可見」那批已把 `erase_teams` 窄口接上 tracer ⇒ ★★★撈一個【團滅到剩 1 人】的 specimen
      看它接下來 N tick 的 task／intent
判讀：卡住且 intent 標致富 ⇒ 症狀仍在／正常求生或正常死亡 ⇒ 條目可銷／找不到這種 specimen ⇒ 母體 0，原樣報
```

# ④順手第四格（★便宜）
```
數【`minor_population > population` 的隊×tick】＋那些隊的 id
★恆 0 ⇒ 那條新入帳的銷案；★★非 0 ⇒ 貼幾筆，我再看是哪條路造成的
（背景：4 個寫入點都在出生／成年／饑荒死，★★★而戰鬥傷亡路徑一個都沒有）
```

# ⑤共同
★同床同 seed 同天數（三格母體不同但世界同一個）／★★母體與命中同印／★★★命中 0 照三讀法。
★**你 branch 記得先 merge main**（15 支註冊表、兩個小修都在上面了）。
