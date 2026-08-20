---
from: systems
to: implementer
slice: convoy-return-conservation
status: open
topic: "[QA 判決兩個技術問題(先查不修,同上次診斷票規格)·①porter_22 的 task 在【運輸→紮營→貿易→逃跑→覓食】反覆橫跳,move_target 也亂跳不單調收斂——★但你上次坐實過『CONVOY 子隊直接早退、不進任何決策路徑』,兩者矛盾;我的假說是【convoy 每 tick 把 task 設回運輸,而 survival reaction 每 tick 又搶走】=手不聽腦同族的每-tick 拉鋸,請用 tap 坐實或推翻(別直接修)·②specimen 覆蓋【同一 team_id 第 2 趟以後常在最精華段斷掉】(porter12 第二趟 stop@8160 食物剩 0.83 仍在游走、porter22 stop@18000 仍在移動中);黏著式修了『掉出範圍』,但這是另一種斷法,同樣要先查根因·★QA 這輪能判全靠 merge log 補位,他自己說『下次不一定這麼幸運』——所以②要根治不是再打一個補丁"
---

# QA 判決帶出的兩個技術問題（**先查不修**，同上次診斷票規格）

## ① porter_22 的 task 橫跳 vs「CONVOY 不進決策」——**兩者矛盾**
QA 讀到 porter_22 的 `task` 在 **`運輸→紮營→貿易→逃跑→覓食`** 之間反覆橫跳、
`move_target` 也亂跳**不單調收斂**（`rehome_n` 5 天衝到 5）。

★ **但你上次已經坐實**：`faction_ai:2753-2756` **CONVOY 子隊直接早退、不進任何決策路徑**
（specimen 佐證 porter_12 追逐窗 **decision 0**）。**兩者矛盾。**

**我的假說**（要你坐實或**推翻**）：
> **convoy 每 tick 把 task 設回 `運輸`，而 survival reaction 每 tick 又把它搶走** ＝ **每-tick 拉鋸**。

那會是**「手不聽腦」同族**：兩個系統各自都「正確」，合起來變成震盪。
★ **用 tap 坐實**（誰在哪個 tick 寫了 task、寫成什麼），**別直接修**——
上次你先分「(a) 沒走仲裁 vs (b) 走了沒守住」才定位到真根因，這次同規格。

## ② specimen 覆蓋：**同一 `team_id` 第 2 趟以後常在最精華段斷掉**
- porter_12 **第二趟** stop@`tick8160`，食物剩 **0.83**、仍在游走
- porter_22 stop@`tick18000`，**仍在朝 `[14,7]` 移動中**

**黏著式修的是「掉出範圍」，但這是另一種斷法** —— 同樣**要先查根因**。
★ QA 這輪能判**全靠 merge log 補位**，他自己說「**下次不一定這麼幸運**」
⇒ **②要根治，不是再打一個補丁。**

（兩題**一輪查完**、只產答案。要不要修、怎麼修，我拿到答案再裁。）
