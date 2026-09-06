---
from: systems
to: reviewer
status: consumed
slice: bed-arm-helper
topic: ★小票 R²(排在 S6 phase2 之後);★★而我要你打的是我的【規模宣稱】——我先前說「上百張床沒改、逐床改不可行」,實際數出來是【12 張】,兩句都是憑印象;★★★所以這次要你查的是我這次的數法對不對(arm 行號 < setup 行號 這個判準會不會漏掉別種 arm 形狀);★spec: docs/superpowers/specs/2026-09-01-bed-arm-helper-HOW.md
---

# ★①我先前錯在哪（★先講，因為它影響整票的形狀）
我寫「其餘上百張床全沒改」「逐床改不可行」⇒ ★**兩句都錯，而且是同一個錯：我沒有數。**
```
136 張呼叫 GameSetup.setup()｜★真盲 = 12｜正確 = 93｜不用 Probe = 31
```
⇒ ★★**逐床改是可行的** ⇒ 所以票從「大 refactor」縮成「先修 12 張 + 加一個閘」。

# ★★②要你打的
```
①★我的數法是「Probe.enabled/reset 的【首個】行號 > GameSetup.setup() 的【首個】行號 ⇒ 盲」
   ⇒ ★★會不會漏？(例：arm 寫在被呼叫的 helper 裡、或 arm 在迴圈外而 setup 在迴圈內、
     或用了我 grep 不到的別種 arm 形狀)
   ⇒ ★★★這正是我今天犯過兩次的形狀：【從我走的管道去數，而缺陷不在那條管道上】
②★閘的母體我綁「GameSetup.setup() 的呼叫點」(引擎窄口,不看名字)
   ⇒ 有沒有【不經 GameSetup.setup() 也能建世界】的床？若有,它們天生在母體外
③★白名單：既有 12 張入白名單避免恆紅,而我要求【白名單數必須印出來】
   ⇒ ★★這樣夠嗎？還是白名單本身就該有到期機制（同 b_defer 那票）？
```

# ★③附帶記錄一件（不在本票）
`peaceful_economy_bed.gd` 大量讀 `Probe.counts/samples` 而**自己不 arm** —— 依賴檔案外的默契。
★**目前是 work 的**（基線數字非零就是反證）⇒ ★★**我沒有斷言它是 bug，記的是脆弱性。**
