---
from: systems
to: reviewer
slice: convoy-return-t3-budget
status: consumed
topic: "[R② 審設計(小 delta,本體已在 convoy spec §6)·問題:T3『elapsed > 3×ETA 就放棄』這條兜底,被 _stamp_return_eta 每次 rehome 重算(faction_ai:814)給重置 ⇒ 母隊持續移動時 T3 永不觸發=兜底被它要限制的機制自己重置·裁定:放棄預算錨在【進入 RETURN 那一刻】,rehome 只更新路徑目標不重置預算·★我要你優先打的【新失效模式】:錨死預算會不會讓『長但健康的追逐』被誤殺?——實測那趟追逐 1000 tick≈4.2 日、rehome 7 次、每次重算 ETA 74~171 不等;若錨在進 RETURN 那刻的 ETA(當時可能只算到近距離的家),3×ETA 可能【小於】一趟正常尾隨的耗時 ⇒ porter 在還會成功的情況下提前轉獨立隊、貨滯留·我想不出乾淨的替代錨(用 max(初始ETA, 當前ETA) 又等於沒錨),所以這題我沒有預設答案,要你判·★另附:T1 是 inert-by-construction(faction_ai:761-762 + :2753-2756 = 沒有任何路徑對 CONVOY porter 呼 try_set),本刀順帶訂正 task_arbiter 那段宣稱『被 routine 搶班』的誤導註解,該行本身保留"
---

# R②：T3 放棄預算錨定（小 delta）

**本體已寫在** `docs/superpowers/specs/2026-08-21-convoy-return-closure-HOW.md` **§6**。

## 問題
T3 的「`elapsed > 3 × ETA` 就放棄」是**兜底**，但 `_stamp_return_eta` **每次 rehome 都重算**（`faction_ai:814`）
⇒ **追逐期間門檻每次被重置** ⇒ **母隊持續移動時 T3 永不觸發**。
**兜底被它要限制的那個機制自己重置。**

## 裁定（待你審）
**放棄預算錨在「進入 RETURN 的那一刻」；rehome 只更新路徑目標，不得重置預算。**
通則：**兜底要錨在承諾開始，不是錨在最近一次調整。**

## ★我要你優先打的：這個修法自己的新失效模式
**錨死預算會不會讓「長但健康的追逐」被誤殺？**

實測那趟：追逐 **1000 tick ≈ 4.2 日**、**rehome 7 次**、每次重算的 ETA 在 **74～171** 之間跳。
若錨在**進入 RETURN 那一刻**的 ETA（**當時母隊可能就在附近，ETA 很小**），
**`3 × ETA` 有可能小於一趟正常尾隨的總耗時** ⇒ **porter 在還會成功的情況下提前轉獨立隊、貨滯留**。
—— 那會把一個「慢但會到」的情境，變成「乾脆不到」。

★ **我想不出乾淨的替代錨**：
- 用 `max(初始 ETA, 當前 ETA)` ⇒ **等於沒錨**（母隊越跑越遠就越寬容）
- 用「累計已走距離 vs 直線距離」的比值 ⇒ 尾隨時比值恆為 1 附近，抓不到
- 用 rehome 次數上限 ⇒ 又回到我剛否決的「加絕對常數」

**這題我沒有預設答案，要你判。** 如果你也認為錨死有真實誤殺風險，
我傾向**先只做「不重置」但把倍率從 3 放寬**，並在 gate 裡放一條**證偽誤殺**的量測
（`stranded(timeout)` 事件裡，有多少筆當時 porter 其實距母隊 ≤2 格）。

## 附帶（同刀處理）
**T1 是 inert-by-construction**（`faction_ai:761-762` 子隊不進 `_evaluate_solo`；`:2753-2756` 對 CONVOY 直接早退
⇒ **沒有任何路徑會對 CONVOY porter 呼 `try_set`**）。
本刀順帶**訂正 `task_arbiter.gd` 那段宣稱「漏列的實測代價＝被 routine 搶班」的誤導註解**（**該行本身保留**）。
