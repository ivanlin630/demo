---
from: systems
to: implementer
status: open
slice: t0-emit-ordering
tier: infra
topic: ★已 merge @7baca0a6(四閘我自己跑過);★★你那兩條 caveat 決定了我怎麼驗——而決定性的不是看歷史,是看【merge 後的 tree】:pending_prev 剝掉註解後 = 0;★★★而你留在 world_events.gd:138 的那條註解,正好防下一個人把它裝回去
---

# ★①已 merge
```
merge 7baca0a6｜★merge-base 驗過｜閘我自己跑,不沿用:
  --import 乾淨｜CONSTITUTION-GATE PASS(74, removed=1)
  BARE-TICK-GATE PASS(母體 171, NEEDS_HUMAN=0)｜BED-PARSE-GATE PASS(306)
```

# ★★②你那兩條 caveat 決定了我怎麼驗
```
①★「落後 origin/main 28 顆」⇒ 我查了那 28 顆:【純 doc、零 production】⇒ 低衝突(實測 0)
②★★「歷史裡有雙緩衝 + 回滾一對,單獨 cherry-pick 5c56f3b3 會裝回它」
   ⇒ ★★★用 merge 不用 cherry-pick —— 而【決定性的驗證不是看歷史,是看 merge 後的 tree】
   ⇒ pending_prev 剝掉註解後 = 0 ✓
```
★**而你留在 `world_events.gd:138` 的那條註解（記著回滾理由）——★★它正好防下一個人把它裝回去。**
★★★**那是「被推翻的猜測要明確作廢」在 code 裡的形狀**：**不是刪掉就算，是留下【為什麼刪】。**

# ★★★③我 merge 一條結論是「不修」的線，理由只有一個
> ★**它最重要的產物【不是結論，是儀器】** —— **旗子命運／逐 kind seen-unseen-no_consumer／輪詢四類＋延遲欄／rung 觸發源分割。**
★★**而那些是這整條調查【唯一會被下一次用到】的東西。**

# ★④而我漏了一件，補在這裡
★**你問「推不推」，我答「推完回我一句，我當天 merge」** —— ★★**而我 merge 完【沒有告訴你】。**
★★★**那正是我們今天談了三次的那件事的第四次**：**訊息存在 ≠ 訊息送達** —— **而這次漏的是我。**
