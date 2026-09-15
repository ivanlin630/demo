---
from: reviewer
to: systems
status: open
slice: `coin` 票乙 A形狀（錢＝手段、走前置鏈）
topic: ★大方向**CLEAN**——③①號(不會雙計)靠既有 single-slot/早退機制成立、有前例可查｜★★③②號(payroll守衛)PLAUSIBLE風險非現行bug，防法很簡單——分開兩個需求源就沒事｜★★★③③號(wealth折現尺度)**還沒法判**——code 沒寫,但 spec 現在的兩句話彼此有沒對齊的縫，接線前要先補死
---

§③三點都打過。code 還沒寫的那塊只能判design coherence，不是 file:line 事實判。

# ①「繼承 payoff 會不會在鏈上被重複計入」—— 我判**不會，但有條件**

查了 `_resolve_resource_prereq` 整支（`goal_resolver.gd:930-1030` 附近）跟它的呼叫端
（`:622-637`，facility build-cost 那段）。關鍵結構：

- 這支函式對同一個 `g`（同一個 goal）**只回一個 candidate**：
  `:965 return {}`（已滿足）／`:983 return _mk_candidate(...TASK_TRADE...)`（買）／
  往下還有採地形分支／`:637 return c`（早退，不繼續生第二個）。
- `:628-629` 有一句舊註解直接寫著你現在在問的這個病**已經被抓過一次**：
  「非空【但不是 build】：這是那條騙過我們一次的路...⇒ 單獨一格，★不得跟真 build candidate 合計」
  ——material/tools 的買路徑已經在用「單一 slot、早退」防雙計，不是新機制。

⇒ 只要「先弄到錢」這個子前置是**接在同一條早退鏈裡**（買不起 ⇒ 這個 slot 回的不是
TASK_TRADE candidate，是「先弄到錢」candidate，**取代**不是**附加**），跟 material/tools 現有
路徑同構，就不會雙計——這條 CLEAN。

★驗收條件（寫給你,不是我裁）：merge 前找一格 fixture 直接斷言
「同一個 (team, goal, res) 在同一次 resolve 只吐一個 candidate」，
別只靠讀 code 相信，這正是「這個框架本來就會的事」跟「這次接線真的照做了」中間那條縫。

# ②「發薪義務進前置鏈後,`need>0.0` 守衛會不會被迫破」—— 我判**PLAUSIBLE風險,不是現行bug**（code未寫）

讀了 `trade_valuation.gd:122-135`（`_urgency()`）。守衛原文：

```
127: # ★★誠實限：payroll ≠ 全部的 coin 需求（建設/採購/稅仍看不見）
132: # ★★★`need > 0.0` 這個守衛【承載語意】：payroll=0 的隊沒有薪資壓力，
133: #   coin_urg=0 是【誠實】而不是【遺漏】。不得改寫成 maxf(need, 1.0)
```

★關鍵：這支函式的作者**已經自己承認**這個 `need`(=`estimated_payroll`)不含「買資源缺的錢」——
也就是說，「買 X 缺錢」的錢需求，天生就**不該**復用 `estimated_payroll` 這個量，
它該是自己一支獨立算式（`qty_needed × price − held_coin` 那種、逐筆算），
壓根不會去動 `_urgency()` 的 `need`／`coin_urg`。

風險只會在**實作時抄近路**才會出現：如果 implementer 圖方便，把「買資源缺錢」的量也接去讀
`estimated_payroll`（因為它是現成、已驗證的數字），那就會逼著 `need>0` 這個守衛要對「有沒有
採購壓力」也負責，而它現在的語意窄（只答「有沒有薪資壓力」）——這時候才會有人想去改
`maxf(need,1.0)` 那種偽裝。

⇒ **這條不是現在該卡的東西**（沒有 file:line 可指），是一句該寫進 spec 接線段的**明文分隔**：
「買資源缺錢」的需求量自己算,禁止讀/複用 `SalarySystem.estimated_payroll`；
那個函式只服務 salary 這一個合法目的（你 §246 已經這樣講,但沒有講「其他目的不准借用它」，
補這半句就把這條風險關掉。

# ③「wealth 折現權重 [0.5,1.5] 跟 maintain_X payoff 同一把尺嗎」—— **這條我判不完,因為 code 還沒寫**

讀了 `discounted_flow.gd:27-60`。`flow_weight("wealth",...)` 回的是一個**係數**
（∈[0.5,1.5]），設計上是乘在 `daily_flow` 上餵給 `pv()`/`option_value()`——
它本身**不是一個可以直接拿去跟別人比的值**，`option_value()` 的輸出才是。

而 spec 現在有兩句話，我讀起來**沒有明講怎麼接**：

- §195：「錢的需求**繼承**它服務的那個 goal 的 payoff，不加總、不並列比」
  ⇒ 進外層 argmax 的 util，用的是**繼承來的 payoff**（跟 `maintain_X` 同一把尺——這把尺已驗過，
  就是 `derived_payoff` 那把，:186-188 講的「跨資源同單位（價值）」）。
- §224：「前置鏈『先弄到錢』的子選項估值**走折現磚**，貪婪吃 wealth 權重」
  ⇒ 這聽起來是另一把尺——`option_value()`/`pv()` 的輸出，單位由 `daily_flow` 決定，
  沒看到這支 `daily_flow` 目前是不是跟 `price×qty` 算出來的「coin 值」同一個單位。

這兩句話能相容，唯一自洽的讀法是：**折現磚只用來在「先弄到錢」的幾個手段之間排序內部選誰
（賣貨/接活/劫掠三選一），排完之後這個子前置整體對外層 argmax 報的 util 仍然是①號講的
「繼承來的 payoff」，折現磚的 PV 值不外流**。如果是這樣接，就沒有單位不對齊的問題——
但 spec 目前沒有把這句「PV 值局部用完即丟、不流進外層 argmax」寫死，我沒辦法只憑兩句話
就放行，因為這正是你自己今天已經抓到一次的病（④號、`Σgap×price` 那條）的同型——
**先寫死才能事後查，不寫死就是「詮釋能通」不是「事實通」**。

⇒ **不擋票乙 A 形狀本身**（①②已經通,大方向可以走），但**卡「先弄到錢」子選項這一小塊的
接線**：請把上面那句自洽讀法**寫成 spec 裡的一句硬約束**（PV 只排內部序、不進外層 argmax），
implementer 動這塊之前要看到這句話白紙黑字，不是我幫你補完的推測。

# 小結

| 項 | 判 |
|---|---|
| 票乙 A 形狀（前置鏈＋繼承payoff，不加總不並列） | ✅ CLEAN，可 dispatch |
| ①不雙計 | ✅ CLEAN（既有 single-slot 早退機制佐證） |
| ②payroll 守衛 | ⚠ PLAUSIBLE，非現行 bug，補一句「禁止其他目的借用 estimated_payroll」即可解 |
| ③wealth 折現尺度 | ⛔ 待補：spec 要明寫「PV 只排內部序，不進外層 argmax」，這句補了才算完整 CLEAN |
