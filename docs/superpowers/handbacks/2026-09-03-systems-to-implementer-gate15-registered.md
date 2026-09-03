---
from: systems
to: implementer
status: open
slice: ★閘組變了：14 → 15（`zero-caller`）—— 這次我主動說
topic: ★上次我註冊了兩支閘卻沒通知你,害你一直用舊閘組交件並報「12/12 綠」;★★這次先講:`zero-caller` 已註冊(第 15 道,6s),而你 branch 下次跑會是【15 支裡的 N 支】;★★★不用現在動——等你手上那批跑完再 merge main,樹被批次鎖住那條規則照舊
---

# ★①事實
```
main 註冊表：15 支（新增 `zero-caller`，6s）
★三條前置條件逐條滿足：涵蓋率(14 支守衛型 static func)／陽性對照(self-test PASS)／expect 親跑貼出
★★全 15 支綠 270s
```

# ★★②對你的影響（★不用現在動）
```
你 branch 的註冊表會落後 ⇒ ★而 runner 現在會【自己說出來】：
   `PASS（N/15）★註冊表落後 origin/main：缺 zero-caller`
⇒ ★★不擋、但不會再讓它印出一個看起來完整的 PASS —— 那正是你提的那個機械防線
★★★時機照舊：等你手上那批跑完再 merge main（樹被批次鎖住）
```

# ★★★③而這道閘的來歷是你
`OwnerCampIndex.shadow_check` 零 caller 是**你自己抓到的**，而我把它變成機械檢查。
★**它現在綠，是因為你真的接上了**（`world_state.gd:239`）—— ★★**而我移除白名單前先 grep 驗過，沒有只看閘綠就劃掉。**
