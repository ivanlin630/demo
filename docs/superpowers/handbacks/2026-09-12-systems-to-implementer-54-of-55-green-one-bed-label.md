---
from: systems
to: implementer
status: open
slice: 機會＋需要項 ｜ 閘結果
topic: ★**兩批跑完、聯集 55 支**：`1–28` FAIL ＝ `bed-arm`（main 既有）｜`29–55` FAIL ＝ **`bed-kind` 一支**｜★★**就差一行**：`herald_journey_bed.gd` **宣告 diagnostic 卻有判決彙總行**（`attack_opportunity_bed.gd` 已 ok）｜★★★**而這跟上次是同一支床的同一個問題** —— 上次是 `interrupt_premeasure_bed`，你當時的結論是「**它確實在判東西 ⇒ 標 acceptance 比較誠實**」，★**這支也一樣**：相遇四格對帳是你拿來下結論的
---

# ① 現況

```
`1–28`：**實跑 28 支**｜FAIL ＝ `bed-arm`（★main 既有基線紅，不擋）
`29–55`：**實跑 27 支**｜FAIL ＝ **`bed-kind`**
⇒ ★**聯集 55 支，唯一新紅就這一支**。
```

# ② 就差一行

```
`scripts/debug/herald_journey_bed.gd` ⇒ 目前 `@bed-kind: diagnostic`，**但它有判決彙總行**
⇒ ★二選一：**改標 `acceptance`（＋ `slice:`）** 或 **把判決行拿掉**
⇒ ★★**我的意見跟上次一樣**：**它確實在判東西**
  （相遇四格：沒有目標／沒碰到面／碰到了但沒開打／碰到且開打 —— 那張表是我們拿來**否證**
   「相遇 ＝ 單一瓶頸」的證據）⇒ ★★★**標 acceptance 比較誠實。**
```

# ③ ★而這件事第二次發生，我記一句

```
上一次：`interrupt_premeasure_bed` 宣告 diagnostic 而有判決行 ⇒ 你改標 acceptance。
這一次：`herald_journey_bed` 同一個形狀。
⇒ ★**共同原因很合理**：**床一開始真的是診斷用的**，
  而**當它產出的數字被拿去下結論的那一刻，它就變成驗收床了** —— 但**檔頭沒有跟著變**。
⇒ ★★所以這不是「你又忘了」，是**一個床的身分會隨著我們怎麼用它而改變**，
  ★★★而**閘抓的就是【身分與用途脫節】的那一刻** —— 它做對了。
```

# ④ 改完

```
★**你改完告訴我**（不用跑全閘，跑 `bed-kind` 一支即可）⇒ 我重跑那一批 ⇒ merge ⇒ 機器還你。
```
