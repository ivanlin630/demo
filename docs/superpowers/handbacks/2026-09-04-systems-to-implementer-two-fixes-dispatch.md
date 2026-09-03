---
from: systems
to: implementer
status: open
slice: 兩個小修（#2 crisis 絕對餓／#4 生育截斷懸崖）—— ★R² issues 已吸收，可以做
topic: ★①真值來源【改掉】:不是 `team.resources.food`,是 `ResourceSystem.effective_food`(既有 accessor,已含「私產＋自家糧倉公庫」,註解自述「決策讀者一律經此」)——★★我原本要用 raw 那個,而那正是今天施主線踩過的 WS-1 坑;★★★②reviewer 撿到第二個 cap(`:295` 執行端 0.25、用 `maxi(1,…)`),我裁【不在本刀範圍】並寫明理由:那不是同一條規則——一個是「該不該想生」(連續),一個是「這次生幾個」(離散人頭)
---

# ★①#2 crisis 補絕對餓（★真值來源已訂正）
```gdscript
# faction_ai_system.gd:_decision_crisis（現有三判準：pop 崩跌／flow DEEP／flow GRADUAL）
# ★加這一條（★★用既有 accessor，不用 raw resources）：
if ResourceSystem.effective_food(state, team) <= 0.0:
    return true
```
★**為什麼不是 `team.resources.get("food")`**：★★**那是團私產，不含自家糧倉公庫** ——
★★★**而今天施主線那顆 -75.6% 就是同一個坑**（`effective_food` 的註解自述「**決策讀者一律經此**」）。
★**注意**：`_decision_crisis(_state, team)` 的第一個參數目前是 `_state`（未用）⇒ **要改回 `state`**（它現在要用了）。

# ★★②#4 生育截斷懸崖（★改接線不改數值）
```gdscript
# reaction_system.gd:229（_score_breed，scoring 層）
- var minor_cap: int = int(t.population * 0.2)
- var base: float = 0.4 if (safe and fed and t.minor_population < minor_cap) else 0.0
+ var base: float = 0.4 if (safe and fed and float(t.minor_population) < float(t.population) * 0.2) else 0.0
```
★**不是 `maxi(1, int(...))`**：★★**那是把懸崖往左挪一格（0 換成 1），而病是【截斷本身】。**
★★★**用戶生育定案要的是「無絕對懸崖」。**

# ★★★③第二個 cap：**不在本刀範圍**（★reviewer 問的，我明著答）
```
`reaction_system.gd:295`（`_tick_breed` 執行端）：`maxi(1, int(team.population * 0.25))`
★我裁【不改】，理由：★★它與 :229 不是同一條規則 ——
   :229 ＝「**該不該想生**」（scoring，連續量，截斷會製造懸崖）
   :295 ＝「**這次生幾個**」（execution，離散人頭，★★★整數是【對的】：不能生 0.4 個小孩）
   ⇒ 而 `maxi(1,…)` 在那裡保證【至少一個完整的人】，不是懸崖
★而 0.2 vs 0.25 兩個比例【為什麼不同】我沒有答案 ⇒ ★★列為觀察，不在本刀動它
```

# ④驗收（★blueprint 定的那條是硬的）
```
★#2：**新 fire 的隊【逐隊】dump** ⇒ 必須全部落在【真絕對餓】（`effective_food <= 0`）——★★不是看總數
   ★★★而 blueprint 的話照抄：「更常 fire 不是平衡問題，是真相問題；怕多 fire ＝ 怕真相」
★#4：pop ≤ 4 的隊 `_score_breed` 不再恆 0（★母體：pop ≤ 4 且 safe/fed 的隊×tick，母體與命中同印）
★★兩件都要 `merge-gates` 全綠（★現在是 15 支，你 branch 記得先 merge main）
```
