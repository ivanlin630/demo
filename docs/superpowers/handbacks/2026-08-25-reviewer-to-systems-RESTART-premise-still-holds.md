---
from: reviewer
to: systems
status: open
slice: stock-vs-flow-ruler
topic: 確認結果——HOLD 期間兩動作都沒讓 spec 前提失效，可直接 dispatch
---

# 確認結果：**沒有**，直接 dispatch

查三點：

1. **`discounted_flow.gd` 行號原封不動**：`horizon_eff` 41-45、epsilon guard :44、`pv` 48-52 ——spec 引用的坐標跟現在 code 逐行對得上，沒漂移。
2. **`SHAPE_TABLE` 仍 4 個 stock 成員**（`ore_iron`/`ore_gold`/`ore_silver`/`gem`，`acquisition_paths.gd:49-53`）不變，驗收①的非零地板還是 4。
3. **`goal_resolver.gd:576-579`**——acquisition-paths-wire-in merge 後 stock 分支現狀：只 `Probe.bump("means_end.stock_seen."+res)`，**不生 candidate**。註解原文：
   > ★stock 形狀【不進價值比較】（systems 裁）：只發 tap，不生 candidate。拿流的尺量存量會系統性高估。

   這正是 stock-vs-flow-ruler 要修的病，是**系統性裁**（=在等這票補），不是 spec 沒預期到。
   目前 `stock_utility` 呼叫端＝0（vs `SHAPE_TABLE` 地板 4），跟 spec 驗收①自己設計的 falsifier「呼叫端若是 0…會立刻對不上 4 vs 0 ⇒ 紅」分毫不差——**ticket 範圍隱含 implementer 也要碰 `goal_resolver.gd:578` 那條 `elif`（把 skip 換成真 call）**，spec「修法」段沒明寫這步，但驗收①已經把它鎖死，不算漏項，implementer 動工前留意即可。

**doc 瘦身（invariants 659→184）**：spec 本身沒引用 invariants.md 條文號，無受影響引用。

⇒ **兩件事都沒讓 spec 任何前提失效，直接 dispatch implementer，不重跑整輪 R²。**
