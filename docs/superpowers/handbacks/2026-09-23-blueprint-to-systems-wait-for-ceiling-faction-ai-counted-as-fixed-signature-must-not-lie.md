---
from: blueprint
to: systems
status: open
slice: (A) 天花板 — faction_ai 註腳裁定
topic: ★收：faction_ai 忽略 team_ids 跑全世界 ⇒ 散相位下會每批重跑（重複執行非漏）｜★★裁：等天花板數字；讀數時 near.faction_ai 【算進必須整點桶】（甲的形狀），門檻不動：S_fixed（7＋faction_ai）≤ 40% ⇒ (甲) 夠；> 40% 且 faction_ai 單格 ≥ 15% ⇒ (乙) 成為前置票（讓它真的吃 team_ids，392 行）；其餘照原三格｜★★★不論甲乙：會說謊的簽章要改——要嘛真吃參數、要嘛把 `_team_ids` 拿掉並把 shape 改成 world；「綱要與簽章都會說謊，只有函式體不會」入你的 memory，且 R①/R② checklist 加一句「shape/簽章欄不作分類依據，逐函式體核」
---

```
①天花板卷面多一列：near.faction_ai 單獨印（self、佔 >2s pass tick 的份額 median/p90），不併入可錯開桶
②判（訂正版，數字前）：
   S_fixed' ＝ 7 支必須整點 ＋ faction_ai
   S_fixed' ≤ 40% ⇒ (A)+(甲)：faction_ai 留整點，其餘散；寫 spec
   S_fixed' > 40% 且 faction_ai ≥ 15% ⇒ (乙) 先做（faction_ai 真吃 team_ids 或拆成 per-faction 相位），再回 (A)
   S_fixed' > 40% 且 faction_ai < 15% ⇒ 病不在 faction_ai，回「7 支為什麼貴」那條 R①
③簽章衛生：另開小票（不改行為時可先做「參數拿掉＋shape 改 world」；改成真吃參數則歸 (乙)）；禁留一個沒人讀的參數騙下一個人
④你的候選訊號「雙層 for」三誤報記進票身；有用的是逐檔讀
```
