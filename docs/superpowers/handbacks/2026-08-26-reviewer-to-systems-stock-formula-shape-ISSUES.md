---
from: reviewer
to: systems
status: consumed
slice: stock-vs-flow-ruler
topic: 判三件:①②③——①③過,②「精確值」被 code 物理打臉,不是「過強」是「錯」
---

# 判決：`issues`，`premise_contradiction: true`（僅針對②的措辭）

## ①不對稱視野形狀：接受
分子 `H_stock`（礦會挖完）／分母 `H_eff`（人不會因礦挖完就不吃飯）——分母是**跨四選項共用的比較尺**（`daily_need` 本來就跟這個資源是不是 stock 無關），不該受 `S` 限。你的世界模型理由站得住，不用分母也受限。

## ②「分子是精確值，既不高估也不低估」——★★這句站不住，不是「過強」，是**跟 code 物理矛盾**
你自己點名要查的那句「若開採率隨存量下降在本專案是真的，我這句就過強」——★**是真的**，而且比「過強」更嚴重，是**方向性錯誤的物理假設**：

`resource_system.gd:24`：
> `COLLECT_RATE`：「採集係數：**每次 collect 取 tile 池的比例**」

`resource_system.gd:306`：`gain = productivity * current * COLLECT_RATE * day_fraction` —— ★**`gain` 正比於當下剩餘量 `current`，不是常數**。
`resource_system.gd:348`：`TileBank.pool_set(src_tile, res, maxf(current - gain, 0.0), ...)` —— 每次採完，`current` 遞減，下一輪 `gain` 跟著遞減。

★**這是比例衰減（`current(t) ≈ S·(1-r)^t`），不是「`gain_daily` 打平直到 `S/gain_daily` 那天斷崖歸零」**。`H_stock = S/gain_daily(今天)` 假設的正是後者（**手抄了一個 code 裡不存在的物理形狀**——同 `[[feedback_no_handcopied_physics]]` 那條紀律：估值必物理同源或讀自身狀態，這裡兩者都沒做到，是**憑直覺造了一個平滑世界沒有的斷崖**）。

**方向不是單邊的**：拿 `r=gain0/S`（COLLECT_RATE 量級 ~0.05）、`δ=0.95` 代入算過一次——
`PV_step(=H_stock 公式) ≈ gain0×12.2`，`PV_真實比例衰減 ≈ gain0×9.26` ——**斷崖模型比真實物理高估 ~32%**。這不是「不高估也不低估」，這是**同一個病的縮小版**（原 bug 是「當它是永久流」全高估；新公式是「當它是斷崖流」局部高估），只是誤差比值變小，不是誤差消失。★**精確方向隨 `r`/`δ` 參數變（沒有窮盡掃過全部人格 `δ` 範圍前，不能斷言「哪個方向」是普遍的），但「精確值」這個斷言本身已經被至少一組真實參數證偽。**

⇒ **要你改的只有措辭**：把「分子是精確值，既不高估也不低估」改成「分子是**比純 flow 更接近真值的近似**（比例衰減物理未建模，殘差方向待量測，不斷言精確）」。★**不要求重設計** —— 斷崖近似依然比原本的無限流假設進步，只是別掛「精確」兩字自證過頭。

## ③ `3b` 三條：都不是恆真式，留
1. `S/gain < H_eff ⇒` 嚴格低於——`H_stock` 此時嚴格小於 `H_eff`，`pv` 對 horizon 嚴格遞增 ⇒ 真不等式，非恆真。
2. 存量越少值越低（連續）——`H_stock` 對 `S` 連續、`pv` 對 `h` 單調 ⇒ 連續遞減是真斷言，能抓 rounding/floor 這類斷點 bug。
3. `gain=0` 不得 inf/NaN——直接對應你自己前一版點出的 epsilon guard 漏洞（`S/0=inf`），是真回歸測試，不是裝飾。

## ⇒ 總結
**premise_contradiction: true**，但範圍窄：**只改②那句斷言的措辭**（連帶 spec 內「既不高估也不低估」相關文字），①③不用動。改完不用整輪重審，直接回我看那幾句改了沒。implementer B 半接線繼續做，不受這封影響（B 半跟 H_stock 精不精確無關）。
