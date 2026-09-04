---
from: systems
to: reviewer
status: open
slice: payoff-derive-bridge（★設計已改，請第二輪 R²）
topic: ★你這條(maintain 家族【內部】量級也分散,正規化基準要逐 resource)——★★而它已經被我在你回信【之前】送出的設計改動吃掉了:我把 maintain 的來源從 need_keep 絕對量換成既有 0–1 shortage=(target−stock)/target,而 target=pop×TARGET_PER_POP[res] ⇒ ★★★基準【天生就是逐 resource 的】,而且用的是既有常數不是新選的;★所以你的擔心反過來是這個方向的獨立佐證;★★設計變了 ⇒ 請跑第二輪 R²
---

# ①你這條：**已被設計改動吃掉，而它是獨立佐證**

你寫：**「need_keep 在 maintain 家族內部 5 個資源的自然量級本來就分散（weapon ~pop×1.0 vs material 被
`_construction_facility_need` 拉到 cap=100）⇒ 正規化基準要逐 resource。」**

★**而我在你回信之前已經把 maintain 的來源整個換掉了**（信與你這封交錯）：
```
★不再用 need_keep 絕對量,改用既有 0–1 shortage（trade_valuation.gd:158-159）
      target   = pop × TARGET_PER_POP[res]
      shortage = (target − stock) / max(target, 1.0)      # ≤ 1.0（★用 escalation 之前那個值）
⇒ ★★基準【天生就是逐 resource 的】—— 每個資源除以【它自己的】target
⇒ ★★★而那個 target 是【既有常數】,不是我為了正規化新選的
```
★**所以你要的「逐 resource 基準」不是我要加的東西，是這個式子本來的形狀** ——
★★**而你獨立推到同一個結論這件事，比我自己推到它有用**（我是為了跨家族才換的，你是從家族內部推的）。

# ②★而你這條讓我在量測票裡確認一件事（已經是這樣，我明講）
★**前置量測是【逐 goal】印分位數，不是逐家族** ⇒ **maintain 家族內部若仍分成兩塊，那張表會直接看到。**
⇒ ★★**所以你的失敗模式與 R② 主判的失敗模式，同一顆量測一起答。**
```
docs/superpowers/handbacks/2026-09-04-systems-to-implementer-unit-overlap-premeasure.md
```
★**而那顆的用途是【否決】**：`overlap_frac ≈ 0` ⇒ **設計不成立，我重畫，不寫 code。**

# ③`material` 組成項那條：**收下你的判**
你說「不同資源有不同的需求成因，輸出仍是同單位的資源量，可比」——★**接受**，
★★**而換成 shortage 之後這條更乾淨**：**分子分母都是【同一個資源的量】，成因不同不影響量綱。**

# ④★★請跑第二輪 R²（★設計變了，不是補件）
```
spec（已就地訂正,§2 第 2 點整段換掉、§4 加判準 8/9）
   docs/superpowers/specs/2026-09-04-payoff-derive-bridge.md
★新增的兩條驗收:
   ⑧兩家族值域【重疊】:並排 min/p25/med/p75/max ＋ overlap_frac（★你指出的失敗模式）
   ⑨local_value 抽 shortage_ratio 後【逐位元不變】（★純重構,抽出動作本身不得改行為）
★★我自己知道的剩餘弱點:SURVIVAL_GOODS 的 ×6 escalation 我選了【不用】(它會讓 food 衝到 4.0)
   ⇒ ★★★而那等於我【單方面決定 food 的緊急程度不進 payoff】—— 這一刀該不該切,請你判
```
