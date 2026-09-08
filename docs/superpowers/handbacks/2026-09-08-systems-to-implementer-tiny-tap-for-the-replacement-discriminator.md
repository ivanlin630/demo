---
from: systems
to: implementer
status: open
slice: 經濟窗判別 tap
topic: ★一個很小的 production tap(5 個純量),用來取代三症一根裡【已經斷掉】的那一節｜★★而我刻意【不做分布】:5 個純量就分得開兩個假說,而分布要嘛靠 first-N 取樣(有偏)要嘛要新機制｜★★★同顆請把那個 tap 改名——它現在的名字讓所有人誤讀
---

# 一、★背景（一句）

`trade.arb_kill_zero_gain` 比的是**路過潛在買方的估值 `_mine`** vs **賣單自標價 `_ask`**，
而 measurer ③格的「價差」比的是**兩張掛單張貼者彼此的估值** ⇒ 兩者不是同一件事，
**三症一根的「價差倒掛 → 殺單」那一節沒有橋**（我已對 blueprint 撤回）。

★blueprint 給了替代判別法，而它用的正是殺單**真正**比較的那兩個值：
```
被殺單樣本的 ask 分布 vs mine 分布
  兩邊都趴 0    ⇒ 「全員過剩、誰都不要」——三症一根讀法站住
  ask 高 mine 低 ⇒ 「賣家開價脫離行情」——另一種病,下一刀完全不同
```

# 二、★★做法：5 個純量，**不要做分布**

`order_system.gd:472-474`（現在只有兩個 bump）加：
```gdscript
if Probe.enabled and gain <= 0.0:
    Probe.bump("trade.arb_kill_zero_gain")
    Probe.bump("trade.arb_kill_zero_gain." + String(o["res"]))
    Probe.add_amount("trade.arb_kill.ask_sum", _ask)      # ★÷n ⇒ 平均 ask
    Probe.add_amount("trade.arb_kill.mine_sum", _mine)    # ★÷n ⇒ 平均 mine
    if _mine <= 0.0: Probe.bump("trade.arb_kill.mine_zero")
    if _ask  <= 0.0: Probe.bump("trade.arb_kill.ask_zero")
```
**判別（用既有的 per-res 計數當分母 n）**：
```
mine_zero/n 高 ∧ ask_zero/n 高          ⇒ ★兩邊都趴 0 ⇒ 「全員過剩」站住
mine_zero/n 高 ∧ ask_zero/n 低 ∧ 平均 ask ≫ 平均 mine ⇒ ★★「賣家開價脫離行情」
兩個 share 都在中間                      ⇒ ★★★不可判 ⇒ 【那時才需要分布】,而那時我們會知道為什麼需要
```

## ★★★而我刻意不做分布，理由要留著

```
Probe 的 add_amount 是【累加和】不是分布;
而既有的 instance 機制是 ★first-N cap（probe_stats.gd:104-106）⇒ 取樣有偏,
  而「分布」正是最不能忍受取樣偏差的那種問題。
⇒ 用 5 個純量把問題答掉;真的答不掉時,不可判本身會說話。
（★這跟我今天裁 gatherpure 母體用 fixture 不用長窗口是同一條:
  不要為了一個是非題去建一個會出錯的量測機制。）
```

# 三、★同顆請改名（我裁過的那條：事件要有自己的名字）

```
`trade.arb_kill_zero_gain` ⇒ 讀起來像「因為沒有利得所以殺單」
實際是【某個路過的買方認為賣家開價高於自己的估值】⇒ ★需求側的「不值得買」計數
⇒ 建議 `trade.buyer_reject_priced_too_high`（你有更精準的名字就用你的）
⇒ ★★並在 :469-474 的註解寫死【它比的是誰跟誰】——
   今天有兩個人（我和 measurer）各自被這個名字帶偏過一次。
⇒ ★★★改名要處理既有引用：`ten-zero-gain-reach` token 與 measurer 的床都引到它。
   請一起改，或保留舊 key 一輪並在註解標「舊名待退」。
```

# 四、序

★這是**世界讀數線**上的活（blueprint 已把工程債降到空檔位，而這一格不是工程債），
但它很小。做完寄 measurer，她那一輪重跑會直接用。
