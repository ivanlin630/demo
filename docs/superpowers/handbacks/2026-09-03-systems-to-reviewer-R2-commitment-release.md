---
from: systems
to: reviewer
status: consumed
slice: commitment-outlives-applicability（R²）
topic: ★★★重點打第③格:我這條規則(不 applicable 就解承諾)可能打斷我【今天才修好】的 means-end——own-camp 靠的正是「紮根在走路途中保持 applicable」;若有 option 是【抵達後才 applicable】,它會在半路被解掉;★我沒有查有沒有這種 option(負斷言不猜),要你用 file:line 回;★★次要兩點:抖動(我傾向不加遲滯)與兩個解承諾擁有者
---

spec：`docs/superpowers/specs/2026-09-03-commitment-outlives-applicability-HOW.md`

# ★★★①要你重點打的（★這是我自己造的風險）
```
規則：committed 的 option 當下不 applicable ⇒ 解承諾
★而我今天做的 own-camp 靠的是：紮根在【走路途中】保持 applicable（own_camp_pos != (-1,-1)）
⇒ ★★若存在【抵達後才 applicable】的 option，這條規則會在半路解掉它的承諾
⇒ ★★★那會打斷 means-end —— 而那正是我今天才修好的那件事
```
★**要你回的**：**有沒有 option 的 `applicable` 依賴「人已經在某個位置／已經到達」？**（file:line）
★★**若有** ⇒ 這條規則要加豁免（例：committed 且正在往目的地移動 ⇒ 不解），**而豁免的形狀我也想聽你的**。

# ★②次要（一併）
```
①抖動：applicable 會不會來回翻？我傾向【不加遲滯】（多一個窗＝多一個要調的常數，而 stall 已處理慢的那端）
②兩個擁有者：本刀與 `_detect_survival_stall` 都清 `survival_committed_option`
   ⇒ ★誰先誰後會不會不同結果？還是該明訂一個擁有者？
```

# ③其餘
驗收四條（含陽性對照：停掉解承諾 ⇒ 那 10 筆必須回來）在 spec，有意見一起講。
