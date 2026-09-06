---
from: systems
to: implementer
status: consumed
slice: S6-phase2 → S7-reconcile-type3
tier: infra
topic: ★R² CLEAN(issues 小,我已補)⇒ phase2 動工;★★而 reviewer 抓到我請他打的那一點且他是對的:C1 錨在 farming 會【恆真】—— 從「會誤殺」變成「永遠不擋」,已改錨在 SETTLE_PERSON_HOURS;★★★phase2 之後接 S7 新主力:blueprint 裁定改打【同量多源對帳】,而型③(決策端 vs 物理端)是本輪唯一得分的方法
---

# ★①phase2 動工（spec 已 CLEAN：`2026-09-01-S6-phase2-single-source-HOW.md`）
```
★核心：四種來源收成【一個查詢】 OutpostSystem.build_person_hours(kind, level)
       內部 = SETTLE_PERSON_HOURS(720) × 倍數表
★★禁止形狀（明寫在 spec）：保留 A2 那張表、然後「讓它等於 A1」
   ⇒ ★★★那是【同步兩張表】,而同步關係沒有人維護,它只在寫下的那一天成立
   （用戶原話：把 2 改成 5，三個月後又爛。修法形狀＝改接線非改數值）
★CORVEE：L0_TO_L1_CORVEE_DAYS 退場 —— ★★常數不存在,就沒有第二個語意可黏
   ★R② 已窮盡 grep 過它：五個真用點 spec §3 全 covered
```

## ★★②R² 改動兩處（★都是我原本寫錯的）
```
①★C1 求生門檻：★★不得錨在 farming 自己 ⇒ 錨在 SETTLE_PERSON_HOURS × k
   ★★★理由：門檻綁 farming、被比的又常是 farming ⇒ 恆真 ⇒ 從「會誤殺」變成「永遠不擋」
②★驗收②的比較點【pin 死在轉換前的 person_hours 引數】,不是天數結果
   ⇒ ★★比天數的話兩邊量綱不同 ⇒ 這條驗收會【算不出來】(第一種不可達)
```

# ★★★③phase2 之後：S7 新主力 = **同量多源對帳**（blueprint 裁定）
```
★裁定理由是本輪比分：掃描(92 顆)+微分試驗 ⇒ 真漂移產出 0
                     S6 雙軌對帳          ⇒ 真漂移產出 1（CORVEE 6.00×）
★★而漂移的藏身處被定義出來了：【同一個量被兩處宣稱，而各走各的】
```
## 對帳三型，★**先做型③**（本輪唯一得分的那型）
```
型③ 決策端 vs 物理端：★列出所有【估算「X 要多久／要多少」】的函式，
     逐個找它對應的【執行端真正扣減的地方】,比對兩者讀的是不是同一個來源
     ⇒ ★★S6 的血證就是這型：三個決策端讀 A2、執行扣 A1
型① 名 vs 值：常數名字宣稱單位(DAYS/HOURS/TICKS/PER_DAY…) vs 它的實際語意
     ⇒ ★血證 CORVEE_DAYS = 3 而實際 18 天
型② 表 vs code：docs 裡的數值表 vs code 常數
```
★**型③這一票的產出＝一張【估算端 ↔ 執行端】配對表**，每列標「同源／不同源／查不到執行端」。
★★**「查不到執行端」那一格特別重要**：★★★**估算一個沒有執行端的量，就是估算一個不存在的東西。**

# ★④順序與紀律
```
★phase2 先做完（它是 build）;★★型③對帳後做（它是 probe,只盤不修）
★母體先寫死再數（型③的「估算函式」定義寫進落地檔）——★★否則又是「數字隨樣式變」
★★★零命中檢查擴到所有 bucket（註記非 FAIL）併進 phase2 同批,已在 spec §6
```
