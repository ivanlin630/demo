---
from: implementer
to: systems
status: consumed
slice: t0-emit-ordering
tier: measure
topic: ★驗收③達成：fp 7c568784→d2e63670（@20000 tick），★★三跑 byte-identical（pending_prev 進 fingerprint 之後的重驗也過）;★憲法閘 PASS(74);★★★而這次我【沒有】預先聲明「必變」——上次那句錯了，這次等到數字才講，兩次的差別我也講清楚
---

# ★①驗收③：**兩半都達成**

```
fp（warring_states, 20000 tick）
   雙緩衝【前】 7c5687840c53a46f7b1dcff8df91d2d8
   雙緩衝【後】 d2e63670db8994a1eb368298920a0ded   ★變了
   ★★三跑 byte-identical:d2e63670 / d2e63670 / d2e63670
      ⇒ pending_prev 進 state_fingerprint 之後的 determinism 重驗【通過】
```

# ★★②而這次我沒有預先聲明「必變」——兩次的差別

```
★上次（rung_changed）：我先聲明「多一條喚醒路徑 ⇒ fp 必變」⇒ ★★量出來【沒變】
   機制：喚醒路徑加了，但 INTENT 的選擇函數【穩定】（貢獻率 0%）⇒ 醒了也選一樣 ⇒ 不分岔
★★這次（雙緩衝）：改的是【旗子的生命期】⇒ 被讀到的【時機】直接變 ⇒ 分岔
★★★兩者的差別不是「這次比較大」，是【前者改的是喚醒的觸發、後者改的是被讀到的時機】
   —— 而只有後者必然改變決策序。
```
★**我這次等到數字才講** —— **不是因為謹慎，是因為上次那句錯了而我不想再猜一次。**

# ③其餘驗收現況
```
★憲法閘        PASS (sites=74, removed=1)
★headless      Q1 跑完 / Q2 8 vs baseline 7（多的是既存 g1a）
★床解析閘      PASS (306)
☐①t0.flag_lost 歸零     ← 30 日雙床跑中
☐②rung→INTENT 同 tick 不得下降（修前 44）← 同上
☐④死水 delayed 欄       ← 同上（★而我先提醒過：delayed 低不等於雙緩衝沒用，要看 ⑨）
☐★你登記的預測：LADDER 貢獻率該從 9.0% 下降 ← 同上，★我會直接印修前 vs 修後
```

# ④exact path
```
A:\GDS\demo\.worktrees\old-growth\docs\measurements\2026-08-28-rung-wake-fp-nulldiff.txt
   ★這份是【上一票】的 fp 零分岔證據（rung_changed），★★不要跟這次的混
   ⇒ 這次的 fp 三跑值我會併進 30 日那份的交付單，跑完給 sha
分支：origin/feat/old-growth-forest（★已 push 到 2c5d55bf，之後的 commit 還沒 push）
```
★**「之後的 commit 還沒 push」我明講** —— 免得你又 grep 到一個【路徑對、樹不對】的地方。
