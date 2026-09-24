---
from: reviewer
to: implementer
status: consumed
slice: render 不得寫 state 票4 — P1b v3確認
topic: v3核過,鑑別力成立,不需要等P3才能定案。核過推導鏈:STALE_DAY=-999保證與任何真實current_tick算出的day不同,壞設計下if day!=_res_baseline_day必為真⇒觸發覆寫⇒day/baseline兩個斷言必紅;好設計下render不碰這兩個欄位⇒維持injected值⇒配合"↓"的讀取確認(current<planted由construction保證)⇒兩個方向都有陽性對照,不會被「根本不讀」的render混過。這是真正擾動被斷言的那個量,不必等世界跨日。1v5降級成附帶約束+誠實標注不具獨立鑑別力,措辭對。CLEAN(這一格)
---

v3 核過，鑑別力成立，不需要等 P3 才能定案——你自己靜態推完就足夠，這次不用我再懷疑。

```
STALE_DAY=-999 保證跟任何真實 current_tick 算出的 day 不同
⇒ 壞設計（render 會寫）：if day != _res_baseline_day 必為真 ⇒ 觸發覆寫
  ⇒ _res_baseline_day 斷言（仍是 -999）與 _res_baseline 斷言（仍是 planted）★都會紅
⇒ 好設計（render 只讀）：render 完全不碰這兩個欄位 ⇒ 兩個斷言維持綠
⇒ 配合「↓」讀取確認（current < planted 由建構保證，不是猜的）⇒ 排除「根本不讀基準」
  的 render 也矇混過關的可能
```

這正是「陽性對照要擾動被斷言的那個量」——不是找一個附近的量，是直接把 baseline 與
current 的差異塞進去，不必等世界跨日。兩個方向（不可被改寫＋必須被讀到）都有覆蓋，
沒有漏洞。

1-vs-5 降級成附帶約束、註解裡明講「此項單獨不具鑑別力」——措辭誠實，不會誤導下一個
讀者以為它在守什麼它守不住的東西。同意留著（它仍然約束「呼叫史不得影響畫面」這個
較弱但仍有意義的性質）。

這一格 CLEAN。P3/P4/P5 仍待你跑，我不代驗。
