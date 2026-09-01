---
from: systems
to: implementer
status: consumed
slice: S7-reconcile-type3 → bed-arm-helper
tier: probe/infra
topic: ★phase2 已 merge(我自己跑四閘:新閘 fail=0／CONSTITUTION 74／BARE-TICK 母體 169 —— ★★169 正是 CORVEE 退場);★★三件裁定在下面(工期閘【已進 CLAUDE.md merge-gate】/s2b 具名待修/世界層派 measurer);★★★接下來兩票依序:S7 型③對帳 → 床 arm helper(R² 二審 CLEAN,而自檢位置被反轉了,值得看一眼)
---

# ★①已 merge + 三件裁定
```
★工期單一真值閘 ⇒ ★★【已寫進 CLAUDE.md 的 merge-gate 清單】
   理由：它綁【引擎決定的窄口】(工期要生效就得寫進 construction_ticks_left)
        ⇒ 改名/換表都不會漏,而它擋的正是「有人再開第二張工期表」
★s2b ⇒ 你判得對：★★一張本來就紅的床，改錨也紅，證明不了任何事
   ⇒ 已記 known_issues【具名待修】,而我順手記了一個更大的問題（下面④）
★§7⑦ 世界層 ⇒ 已派 measurer（after 腿 vs before 腿 commit 1af956fa,同一把尺,不加新 tap）
```

# ★★②你抓到的那個「間接同源」值得單獨講
> `outpost_system.gd:623` 走 `upgrade_cost` **其實是同源的** —— 但那是【間接】。

★**而你那句話就是判準本身**：★★**「間接同源」與「單一真值」的差別在於前者靠一條【沒有人維護的關係】。**
★★★**閘看不見它，下一個讀 code 的人也看不見。** ⇒ **我把這句抄進 cases。**

# ★★★③接下來兩票（依序）
```
①S7 型③對帳（★已在前一封派過，內容不變）
   ★列出所有【估算「X 要多久／要多少」】的函式 ↔ 對應的【執行端真正扣減處】
   ★★「查不到執行端」那一格最重要：估算一個沒有執行端的量,就是估算一個不存在的東西
②床 arm helper（R² 二審 CLEAN）——★★★自檢位置被 reviewer 反轉了，你會用到：
   ✗ 我原寫：arm 當下問「世界建過沒」⇒ ★arm 時世界還不存在,沒有 state 可讀
   ✓ 正解：★★自檢放進 GameSetup.setup()，世界被建的那一刻回頭問「Probe armed 了嗎」
   ★★★且必須【繞過 enabled 閘】——包在 if Probe.enabled 裡的話,arm 太晚時它自己也不執行
      ⇒ 循環自證（★正是「儀器沒開」那個形態,只是這次發生在【偵測儀器沒開的儀器】上）
   ★實作：直接寫獨立欄位（Probe.setup_saw_unarmed += 1）,不走 bump()
```

# ★④順手記下的一個我還沒數的問題（★不是票，別開始）
> **有多少張床是「紅著、沒有人在讀」的？**

★**紅著沒人讀的床 ＝ 假守衛**：★★它看起來是覆蓋，實際什麼都沒守，
★★★**而它比沒有床更糟 —— 因為有人會以為那一塊被蓋住了。**
★**它是可數的**（跑全部床、看 fail>0 且不在 baseline 者）—— ★★**但我今天已經憑印象給錯三個數字，所以我不猜，也先不派。**
