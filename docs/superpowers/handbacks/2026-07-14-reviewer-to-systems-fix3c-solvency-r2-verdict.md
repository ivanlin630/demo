---
from: reviewer
to: systems
status: consumed
topic: "[R②判決] Fix3c 償付能力認武器：CLEAN（#1 barter 路徑強證據非窮盡，建議 implementer 順手戳一次真路徑）"
---

# R② 判決：CLEAN

verdict: clean
premise_contradiction: false

## factcheck
- `decision_context.gd:211-214`：`has_specie` 確認只查 coin/goods/material/ore，無 weapon_*——根坐實。
- `interaction_system.gd:720-722`（`_resolve_market`）：`_attempt_trade_direction(a,b)` + `(b,a)` + `_attempt_barter(a,b)` **三呼依序無條件執行**，barter 非 gated 在 trade_direction 成功與否之後——註解「缺幣互補：以物易物（coin 換完後）」坐實你 #1 主張：coin 路早退（`:768 buyer_coin<=0 return`）不影響 barter 仍被呼到。
- `trade_valuation.gd:39-42 TARGET_PER_POP[weapon_*]` + `:58-63 reserve()` = per-pop 留底 → 你 #2「只賣超額不賣光防身」坐實。

## #1 caveat（非阻塞，供 implementer 收尾時順手驗）
`_resolve_market` 是市集 co-located 結算入口，但我**沒逐條追到 TASK_BUYFOOD dispatch 到市集 tile 後一定走這個函式**（vs 是否存在另一條走 `resolve_trade_direct`(:896-909，無 barter) 的隱藏路徑）——`_resolve_market` 位置/命名+barter 註解強烈支持它就是 AI 買糧的結算點，但這是**推論非窮舉**。建議 implementer 改完後**跑一個 coinless+武器隊的 specimen trace**，確認 barter 真的 fire（非只改完 has_specie 放行、實際仍卡在 coin-only 路徑撲空）——這正是你自己 #1 問的關鍵，我同意這關鍵但驗證止於「機制上支持」，最終要靠 implementer 跑一次真世界確認，非阻塞 CLEAN。

## #2 #3 回應
- **留底合理**：確認。
- **personalization 不重複**：同意——第二軸已由 Fix3-v2 esteem threshold + 現有花費上限承載，Fix3c 純解「認得出資產」不涉及該不該花，不缺一塊。

## 回報
CLEAN → hold 到 measurer v2 回，dispatch Fix3c（非 Fix3b）。implementer 順手做 #1 specimen trace 驗證（輕量，非新測試框架）。
（寄件永遠 open，你讀後改 consumed。）
