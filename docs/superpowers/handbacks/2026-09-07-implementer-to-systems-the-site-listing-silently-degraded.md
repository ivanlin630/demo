---
from: implementer
to: systems
status: consumed
topic: ★★★逐站清單第一版**沒有做到，而它印出了一個看起來像結果的東西**：`population @ (no-stack)` —— `get_stack()` 只在 `--debug` 下有值｜★★修法不是「記得加 --debug」，是**讓儀器在拿不到 stack 時說出【本輪清單無效】**
---

# 一、★發生了什麼
```
我加了 get_stack() 逐站印 ⇒ 跑出來:
   [SETTER-SWALLOWED-SITE] population @ (no-stack)
   [SETTER-SWALLOWED-SITE] wounded    @ (no-stack)
★而我當時的 fallback 字串是 `"(no-stack)"` —— ★★它【長得像一筆資料】
   ⇒ 一個「站」欄位、一個看起來已經填好的值
   ⇒ ★★★而它實際的意思是【這一輪什麼站都沒量到】
⇒ 我加 `--debug` 重跑,同一支床:
   [SETTER-SWALLOWED-SITE] population @ res://scripts/debug/_tmp_swallow_probe.gd:6 _initialize
   ⇒ ★機制是對的,只是【儀器的前提沒有被驗證】
```

# 二、★★修法：**不是「下次記得加 --debug」**
```
★那句話對真假兩種情況一視同仁 —— 而【忘記的時候不會有任何東西響】
⇒ 改成：`if get_stack().is_empty()` ⇒ 印 `★ABORT-LISTING：本輪逐站清單無效` + push_error
   ★★而訊息裡明寫一句:「不得把【沒有站】讀成【沒有發生】」
   （屬性層計數 `swallowed_writes` 【仍然有效】—— 它不依賴 stack）
⇒ ★★★也就是說:儀器要能分辨【它自己壞了】與【被觀測物是空的】,並且【自己講出來】。
★而這正是你今天講過的那條的同一形狀:
  預寫的失敗語意會對真假紅燈【一視同仁地加持說服力】——
  ★★而 `(no-stack)` 是它的孿生兄弟:一個【預寫的成功語意】。
```

# 三、★★★而我要標一件我沒做到的事
```
★我在同一天已經寫過「陽性對照要先做」,而我這支儀器的陽性對照【做了】
   ——`[POSCTRL] 手動寫一次 → {"population": 1}` ✅
★★但我【沒有做陰性對照】:「拿不到 stack 的時候，它會說什麼？」
⇒ ★★★而陽性對照證明的是【它會動】,證明不了【它動的時候講的是真話】
⇒ 這一輪我兩個都排了：
   ①陰性對照＝不加 --debug 跑 ⇒ 必須看到 ABORT-LISTING
   ②真清單＝加 --debug 跑 headless_test
```

# 四、待補（跑完接著報）
```
★headless_test --debug 的逐站清單 —— stage B 真正要的那份
★★而我已經知道它【不會是 52 站】:runtime 子集必然小於靜態站數,
   ⇒ 而那個差距本身就是 stage B 的排序依據（會跑到的先修、不會跑到的一起刪）
```
