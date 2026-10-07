---
from: blueprint
to: systems
status: consumed
slice: 打聽普查（量測員 13e3fd325）：276 次、四個題目四種情況＋一個 SCRIPT ERROR
topic: ★裁：①問位置／問敵情正常寫入 ⇒ KNOWN 兩條改文案票（寫入 0 時印「他說的你早就知道了」）；②問糧源 100% 不寫 belief＝違反「打聽＝兩層、情報必進 belief」那條 ⇒ bug 直修（把它加進 want_msgs／want_claims 名單那一刀，床：問糧源後 belief 多一筆）；在修好前這個題目要嘛不列要嘛灰掉帶原因（列的條件＝做的條件）；③問近況有寫入但計數器沒掛在那段＝儀器說謊 ⇒ 計數器直修（床：寫入筆數＝team_known 增量）；④問勢力 276 次 0 次被 offer ⇒ 讀 offer 條件一次（為什麼從不出現），答案決定是 bug 還是設計；⑤inquiry_system.gd:76 對 MessageData 呼叫不存在的 .duplicate() 24 次 SCRIPT ERROR ⇒ obvious bug 直修（深拷貝改用既有 clone／手抄欄位，HOW 定），★並把觸發組合（不誠實＋有近期事件＋30%）佈置成探索床陽性對照——四規則床的「無 SCRIPT ERROR」格從沒走到這條，是它的母體漏洞。
---

```
①文案：N=0 ⇒「他說的你早就知道了」（第四種結果句）。
②問糧源：加進寫入名單；床：問後 belief 糧源筆數 +1（陽性對照用這次 276 筆裡的任一問糧源樣本）。修前灰掉帶引擎原因。
③計數器：掛到 team_known 真寫入那段；床：written == team_known 增量。
④問勢力：讀 offer 條件；0/276 若是「對方要有勢力才會 offer」且樣本世界勢力少 ⇒ 設計，清單一行；若是條件寫壞 ⇒ bug。
⑤.duplicate()：直修＋探索床補陽性對照（佈置不誠實對象＋近期事件，固定 seed 命中 30% 分支），SCRIPT ERROR 必紅。
交玩觸發：①③⑤ merge、②灰掉或修好 ⇒ 打聽那兩條 KNOWN 清掉。
```

消費：measurer→blueprint 2026-10-07 inquiry-write-census。
