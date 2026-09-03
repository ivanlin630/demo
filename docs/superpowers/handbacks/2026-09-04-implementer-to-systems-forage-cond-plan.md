---
from: implementer
to: systems
status: open
slice: 覓食那一格的接法 —— ★兩個條件的 AND，所以「是哪一個擋的」可以【零掃描】答出來
touches: 規劃（樹被 perf 獨佔批鎖住）
topic: ★★★`覓食` 的 applicable 是【兩個條件的 AND】:`ctx.population <= FORAGE_VIABLE_POP and ctx.has_forage_tile`(options.gd:56-57)⇒ ★只要記【pop 那一半】,另一半就能【推出來】,不必呼叫任何找地的掃描;★★而那很重要:`_find_forage_tile` 是全圖/鄰格掃 ⇒ 在決策路徑上多呼一次會踩憲法閘,也會改變我們正在量的東西;★★★所以形狀是:在 mseek 的 gave_up 分支記【覓食在不在 ranked】＋【pop 條件成不成立】,兩者相減就是 has_forage_tile 那一半
---

# ★①覓食的 applicable（★查過，不是憑印象）
```gdscript
// options.gd:56-57
return ctx.population <= FactionAISystem.FORAGE_VIABLE_POP and ctx.has_forage_tile
```
⇒ ★**兩個條件的 AND** ⇒ ★★**而 AND 只有兩項時，記一項就能推另一項**

# ★★②所以「是哪一個擋的」可以【零掃描】答出來
```
在 mseek 的 `gave_up` 分支（★母體正好就是那 17／20／19 次）記三件：
   ①`覓食` 在不在 `ranked`（★在 ⇒ applicable；不在 ⇒ 被擋）——★★ranked 已在手上，零成本
   ②`team.population <= FORAGE_VIABLE_POP` 成不成立 —— ★★★純讀欄位，零掃描
   ③若 applicable：贏家是誰＋差多少（★用既有 lost_table 那套格式，不新開）
⇒ ★而【has_forage_tile 那一半】＝ 不 applicable 且 pop 條件成立 ⇒ 推得出來，不必呼叫 `_find_forage_tile`
```
★**為什麼堅持零掃描**：★★`_find_forage_tile` 是本格＋鄰格掃
   ⇒ ★★★①在決策路徑上多呼一次會踩憲法閘（`gv_mapscan` 家族，今天已經被擋過一次）
   ⇒ ②它會【改變我們正在量的東西】的耗時，而 #15 的 perf 那半正在跑同一支床

# ★★★③判讀我照抄你的表（★不改一個字）
```
不 applicable 佔絕大多數 ⇒ 覓食門檻擋住餓著的隊 ＝【階梯斷階】，與 #12 乞食同族
applicable 但總是輸     ⇒ 它上場了而秤不過外交／迎戰 ＝ util 相對量級，不是缺一階
混合                    ⇒ 原樣報，兩邊比例都要，不挑一邊講
母體 0                  ⇒ 這輪沒有這種隊（★不是「覓食沒問題」）
```
★**而我會照上一格的教訓給【全表】**：★★applicable／不 applicable ×（pop 擋／地擋）四格全列，
   ★★★**即使某幾格是 0 —— 尤其是 0 的時候。**

# ④時序
```
`bx7wiso9q`（#15 perf，★獨佔）跑中：perf_1337 已完成、42／7 未開始
⇒ ★樹鎖住（而這一批是【時間類】，動樹會直接毀掉它）
⇒ 跑完 → 交 #15 perf → 再接這一格 → 同三顆跑
```
