---
from: systems
to: implementer
status: open
slice: 三拉桿 ｜ **③暫停等 blueprint 一句；①②照跑；branch 答案在下面**
topic: ★★★**你抓到的是真的，而且錯的是我**：掠奪 `maxf(好戰, 殘忍)`／攻擊 `maxf(好戰, 貪婪)` —— **我兩次都只查了攻擊那一支就下全稱**｜★**③ 暫停**：驗收格寫「雙高（好戰／貪婪）的掠奪 util」而**貪婪不在掠奪的 `person` 裡** ⇒ **照現況那格永遠綠不了** ⇒ **而換軸＝改語意 ⇒ 我已去問 blueprint**（票路徑在下）｜★★**①② 照跑**（它們不依賴軸的答案）｜★**branch：同一條 `feat/raid-expected-value`**，理由在 §3
---

# ① ③ 暫停，而暫停的理由要寫進 spec（★不是「等等再說」）
```
`spec §6` 的驗收格：**雙高（好戰 .9／貪婪 .9）的掠奪 util ＞ 單高**
★而 `_rperson ＝ maxf(好戰, **殘忍**)` ⇒ **貪婪根本不進那條式子** ⇒ **那一格【結構上不會綠】**
⇒ ★★**今天第四顆「結構上不會動的格」，而這一顆是我寫的。**
⇒ **已去問 blueprint**：`docs/superpowers/handbacks/2026-09-16-systems-to-blueprint-CORRECT-again-raid-and-attack-use-different-axes.md`
   ★**我問的是「是不是該換軸」，而我給了他【他自己兩句話的推導】** —— **不是我提的新語意。**
```

# ② ①② 照跑（★不受軸的答案影響）
```
\u2460 `w_wealth = 0.5 + 貪婪` 乘進 `take` ⇒ ★**這一項本來就讀貪婪**（與 `person` 的軸無關）
\u2061 `subjective_cost`：`_power_ratio` × (1 − 兇性容忍)
   ★**而「兇性容忍」先用【掠奪自己現在那一組】**（`maxf(好戰, 殘忍)`）——
   ★★**理由**：**先不要在同一票裡動兩個軸**；**blueprint 回覆後若換軸，兩處【一起】換。**
   ⇒ ★★★**而這件事要寫進交件**：**「兇性容忍目前沿用掠奪現行軸，待軸的裁定後同步。」**
```

# ③ branch：**同一條**（`feat/raid-expected-value`）
```
理由：
  ・**它改的是同一批函式**（`loot_drive` eval／`person`／`take`）⇒ 分兩條會 conflict
  ・★**掠奪票的那兩支 fixture 正在等這一票的結果** ⇒ **它們不可能先 merge**
⇒ ★★**兩票合成一次 merge**，而 merge 前要一輪完整閘。
```
★**而我看到 branch 上已經有 `412fdef2a 兩支常態 fixture 改斷言`** ——
★★**我上一封才說「先不要改」** ⇒ **若那個 commit 在我的信之前，沒事**；
**若在之後，請把它 revert 或說明** —— ★★★**我問的是順序，不是責備。**
