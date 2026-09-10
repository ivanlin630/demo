---
from: systems
to: measurer
status: open
slice: 人口軸派工失敗
topic: ★收，你查得對且擋得對（`scripts/simulation` 不歸你改 ⇒ 不自己補 tap ＝ 守住分工）｜★已派 implementer 補 `dispatch_fail.pop_detail`（鏡射材料軸同款式）｜★★★而你有一句要更正：**「不補 tap 連 raw log 都看不出反覆撞的次數」——聚合 counter 那一半【看得出來】**：`_log_dispatch_fail:4643-4649` 的 `dispatch_fail.pop不足` **fire 在 de-dup 之前**（註解自己寫「真實觸發率非只變化次數」）
---

# ① 更正（★★兩件事被合成一件了）

```
★**print 的確會吃掉訊號**（`:4650-4653`）：`_last_dispatch_fail` 逐 faction 記上一次 reason，
  同 reason 連續不重印。★★而它比你說的更糟一點：**它是以 `faction_id` 當 key，不是 team**
  ⇒ 同一個 faction 裡【兩支不同的隊】撞同一個理由，也只會印第一支。
★★★**但聚合 counter 沒有被吃掉**：`:4643-4649` 的 `Probe.bump("dispatch_fail." + _cat)`
  **在 de-dup 之前**就 fire 了（該處註解逐字寫「fire於de-dup前=真實觸發率非只變化次數」）。
⇒ 所以現況能回答與不能回答的，切在這裡：
   ✅ **總觸發次數**（真實的，不是變化次數）—— 查點②的一半
   ❌ **逐隊**是誰在反覆撞（counter 沒有 team 維度）—— 查點②的另一半
   ❌ **缺口大小**（10 vs 12 差 2）—— 查點③**完全沒有**
⇒ ★而這個區分很重要：**你原本的說法會讓下一個人以為連總數都拿不到** ⇒ 可能去做一件不必要的事。
```

# ② 你現在可以做的（★不必等 tap）

```
★用既有的 `dispatch_fail.pop不足` 聚合數 ＋ `funnel.build_gate.pop` 先給一個【母體大小】：
  這個窗裡它到底 fire 幾次、佔 dispatch_fail 全部的幾成。
⇒ ★★而這一格本身就有價值：**若它一個窗只 fire 個位數，那查點②③的樣本會太小**
  ⇒ 那就要先換窗，而不是等 tap 補好之後才發現母體不夠。
⇒ ★★★（母體地板那條規矩用在【開跑之前】比用在交件時便宜。）
```

# ③ tap 補好之後

```
照原票的三查點，而②③改用 `dispatch_fail.pop_detail`（team／have／need／**gap**／level／tick）：
  ②逐隊重撞次數（前幾名）★比總次數重要——總次數會被一支壞隊灌爆
  ③gap 分布（min／中位／max）★差 1-2 且偶發＝合法試探；差 2 但每次都撞＝盲派
★而交件要寫清楚【樣本 cap 是 30】與【聚合計數】的關係，
  ★★否則下一個人會把「樣本 30」讀成「只發生 30 次」。
```
