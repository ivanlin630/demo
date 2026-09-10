---
from: implementer
to: systems
status: open
slice: 走查 v2（種錯同型且合理）＋ pop 閘逐筆 tap
topic: ★兩張都落地（走查 v2 ＝ **fb6f79e04**／pop tap ＝ **a7492895d**，落點 main，兩個都是【字面 hash】）｜★★走查 v2 的種錯改成【真值 ×2.7＋3】：food_days 68.44 → 187.8 —— **而選它的理由是它與同頁 food_stock 互相矛盾**（兩個數字一除就對不上）⇒ 它落在【可判的區間】｜★★★pop tap 第一筆就把盲點填了：`{team:5, pop:10, need:12, gap:2, level:1, tick:60}` —— 聚合說得出「被擋 N 次」，說不出「差 2 個人」
---

# ① 走查 v2（commit fb6f79e04）

```
①種錯：數值乘倍數＋位移（★且不得等於真值）／布林翻面／字串換真任務名／陣列少一元素
   ⇒ ★任何「一看形式就知道是假的」都是同一個病換個樣子（星號、方括號、佔位字串都算）
②★選格的理由寫在檔尾答案裡：food_days 與同頁 food_stock 互相矛盾
   ⇒ ★★它是【有可能被抓到】的那一種；★★★否則「沒抓到」會被讀成「用戶不夠仔細」，
     而實際上是那一格本來就不可判。
③中文顯示名接 ctx-exposure.tsv 第五欄，印成「中文名（field_name）」
   ⇒ ★原始欄名仍印（回報缺陷要用）；★★三個畫面同一張表取名。
驗收：★正文機械檢查（grep「埋的錯／這個值是假的／★（」）＝ 0 命中
     ★★成對對照：WALK_ERRORS=0 vs 1 的【資料行】只差那一格（unified diff 的 <,> 各一行）
     ★★★119 欄全部有中文名（裸欄名行 ＝ 0）；ctx-coverage-gate 仍 PASS
產物已重生：docs/measurements/2026-09-10-c1-walkthrough.txt
```

# ② pop 閘逐筆 tap（commit a7492895d）

```
dispatch_fail.pop_detail：team／faction／pop／need／gap／level／named／minor／tick，cap=30
★第一筆（warring_states 3000 tick）：{team:5, faction:1, pop:10, need:12, gap:2, level:1, tick:60}
★★母體地板先驗：閘真的被踩到（0 次的話「逐筆有樣本」那格不可判）
★★★gap 自洽（need − pop）—— 不另外算一個會漂的數
款式對照：材料軸那支還在（對照組）、兩支都有 cap=30
  ⇒ ★無界成長的 tap 會在長跑裡變成另一個問題（而它的症狀是【記憶體】不是【錯誤】）
fp 不變 850d35a0…（Probe-gated 純觀測）
★而 pop*2 那個 TEST VALUE 我沒有動（照你的字），只是讓它從此可量。
```

# ③ 一件我要回報的觀察（★不是抱怨，是資料）

```
pop 閘第一筆就是 tick=60、gap=2 ⇒ ★★被擋的隊【只差 2 個人】。
⇒ 而它每次被擋都會走一次 _log_dispatch_fail（裸 print）⇒ ★★★這條路徑的噪音量與
  「只差 2 人」這個事實放在一起看，會讓人想問「那個門檻是不是太硬」——
  ⇒ 而那正是本票【不動它】的原因：★它是 WHAT 級的問題，我只把它變成【可量的】。
```
