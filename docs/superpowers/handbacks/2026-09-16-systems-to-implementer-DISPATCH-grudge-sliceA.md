---
from: systems
to: implementer
status: open
slice: 恩怨帳 切片A ｜ **DISPATCH（開工）**
topic: ★**spec**：`docs/superpowers/specs/2026-09-16-grudge-ledger-sliceA-HOW.md`（審查已過，我照他抓到的兩點改完：跨線門檻反解、第二軸訂正）｜★★**這一票的核心不是加功能，是【接上兩個世界一直在寫、而沒有人聽得懂的名字】**：勒索寫的是 `special_taxed`、求救不應寫的是 `rejected_aid`，**兩個都不在任何 match 裡** ⇒ 落進 `_` ⇒ 零邊零標量零 goal｜★★★**而我欠你一句交代**：審查回來之後我沒有立刻派工，**是我自己造的斷點**——沒有人在等我，我卻把它當成「等複核」
---

# ① 工作清單（spec §2，逐項）
```
\u2460 `relation_graph.gd`：`add_edge` 的 `maxf` ⇒ **飽和疊加 1-(1-a)(1-b)** ＋ 新增 `consume_edge` ＋ `intensity_to`
\u2461 `npc_ai_system.gd`：三個 match 與 `FEUD_SEVERITY` 的 `"extorted"` ⇒ **`"special_taxed"`**（★改名不加鍵）
                        三個 match 加 **`"rejected_aid"`**（feud 側，severity **0.325** TEST VALUE）
\u2462 `trade_valuation.gd`：`ask_price` 加**選填**尾參數 `buyer_leader_id: int = -1`（★`-1` ⇒ 逐字等同今天）
                        恩怨乘數 W = clamp(0.15 + 義氣×0.30 − 慎重×0.30, 0, 1)
\u2463 `reaction_system.gd`：`_score_defect(p, _t)` ⇒ 用 `t.leader_id` 讀兩條邊（feud ↑走／gratitude ↓走）
\u2464 `npc_ai_system.gd:176`：砍 `0.003` 常數
\u2465 報恩／和解被收下 ⇒ 呼 `consume_edge`（★**只有這兩個事件**；被動與無不消耗）
\u2466 tap：`grudge.form.<type>` / `grudge.stack` / `grudge.consume.<reason>` / `trade.grudge_markup` / `defect.grudge_term`
```

# ② ★兩個常數的來源（**不是挑的，別改成「好看的數」**）
```
**0.325** ＝ 表內相鄰兩值 **0.30（勒索）與 0.35（劫掠）的中點** —— WHAT 要求「從表內既有值推，不手填」
**W** 由不等式反解：0.30×W_mid ≤ 0.05（最弱的怨×中庸人格不該秒殺交易）
                  1.00×W_mid > 0.05（深仇×中庸該能跨線）⇒ W_mid ∈ (0.05, 0.167] ⇒ 取 0.15
★**第二軸是【慎重】不是好戰** ⇒ ★★**必須開新常數名**，
  **不得沿用 `FEUD_HONOR_W`／`FEUD_BELLIGERENCE_W`**（那兩顆是為「好戰」校準的）。
```

# ③ 驗收（spec §3 七格，★**每格都要能紅**）
★**格3 多一條硬要求**：印**撮合時的 `ask_base / bid`（h 的分布）** ——
**沒有它，跑出來的數字分不清【機制錯】與【這批交易本來就沒餘裕】。**
★★**格4**：`buyer_leader_id = -1` ⇒ **索價逐字等同舊值**（★這是預設路徑沒被動到的證明）。
★★★**格7**：`rejected_aid` 三個寫入點各發生一次 ⇒ 各出現一條 feud 邊（**守的就是「名字沒接上」那個病**）。

# ④ ★不在本票（寫出來讓「沒做」可被看見）
`vendetta_target` 三硬門檻／勾銷／人格淡忘／求助對象讀者／廢 `p.relations` 標量／`_views_as_foe` 的 `strongest` 缺陷
⇒ **全部切片B**。★**而 `_views_as_foe` 要排 B 的第一項**：本票讓 feud 邊變多 ⇒ **它的既有缺陷影響面積被我們放大了**。
