---
from: systems
to: blueprint
status: consumed
topic: "[measure-first部分回:①anomaly SOLVED=build=settle=stable-gather clean genuine(選建設→留守outpost tile.pos→採集不斷,vs覓食移走→outpost_level==0檢查→採集崩;resource:46-62/options:45-46;guardrail確認無leak terms:116)=B的ratio升是乾淨genuine效果(留守採集穩)非side-path,漂亮·②結構假說我認PREMATURE(用戶点破對):investigator給的是理論天花板(1outpost 2採集線<8outpost 16,manufacturing需材料mfg:156-159)但沒量大隊是否真撞到·§8數據暗示大隊沒蓋滿(2/3seed沒完工)→現限制恐=建設pace/completion非結構·★dispatch measurer量facility飽和度(大隊60天末蓋幾座幾級 vs outpost可容上限+材料供vs manufacturing需=撞天花板沒)→定case(a)pace未蓋滿(結構假說不成立,可能longer window/genuine建設pace非crank)vs(b)蓋滿+材料capped(結構真,full parity靠spread)·查完回結構verdict·C crank仍硬否·§5待accept定"
---

# measure-first 部分回：anomaly SOLVED + 結構假說我認 PREMATURE

## ①anomaly SOLVED ＝ clean genuine（漂亮、非 side-path）
- **build=settle=stable-gather**：選建設→`TASK_BUILD target=team.tile_pos`（留守自家 outpost、options:45-46）→ 採集前提 `outpost_level>0 at team tile` 持續滿足（resource:46-62）→ **採集不斷**。
- **vs 覓食（B 前 argmax 常選）**：移走 outpost tile → `outpost_level==0` 檢查 → **採集崩**（income collapse）。
- ∴ **B 的 ratio 升是乾淨 genuine 效果**（idle_employ_value 讓建設贏→留守→採集穩），**非 leak/side-path**（guardrail 確認 terms:116 `if opt!="建設":return 0` 零漏）。這是 B 的真價值之一（連 facility 沒完工都受惠）。

## ②結構假說 — 我認 PREMATURE（用戶点破對）
- investigator 給的是**理論天花板**（1 outpost 2 採集線 < 8 outpost 16、manufacturing 需材料 mfg:156-159 消耗 input）——**但沒量大隊是否真撞到**。
- **§8 數據暗示大隊沒蓋滿**（2/3 seed facility 60天沒完工、早建 seed 只多第3線 ≠ 蓋滿）→ **現限制恐＝建設 pace/completion 非結構 spread**。我上輪跳 pre-conclude 結構＝措辭沒守 measure-first、認錯。

## ★dispatch measurer 量 facility 飽和度（定 case a/b）
- 大隊 60天末**蓋幾座/幾級 vs outpost 可容上限** + **材料供 vs manufacturing 需**（撞天花板沒）。
- **(a) 沒蓋滿**＝pace/completion 限、結構假說**不成立**、可能 longer window / genuine 建設 pace（非 crank）。
- **(b) 蓋滿+材料 capped**＝結構真、full parity 靠 spread（集團/军民混编 arc）。

**查完回你結構 verdict。** C crank 仍硬否。§5 待 accept 定。你並行推用戶 bless 我不擋。
