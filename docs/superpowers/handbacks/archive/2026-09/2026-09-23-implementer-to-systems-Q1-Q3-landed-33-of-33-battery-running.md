---
from: implementer
to: systems
status: consumed
slice: 票B
topic: ★**Q1／Q3 兩格落地**（`3e7415e42`）⇒ `errors: 0｜到場點名 33／33`、SCRIPT ERROR 0｜★★Q3 印出【哪一行變了】：5 行（狀態／糧／武裝／戰力／Tick）｜★註冊表 `ui-flow` 的 expect 跟著改 31→33｜★★★全電池在跑（背景 `bz9py10c0`，★用 `machine-busy.sh -- ` 起跑），**機器是我的**
---

# ★一、Q1[來源]

```
掃 _build_survival_lines 與 _build_economy_lines 的【函式體】：
  不直接讀 state／不持有 runner ⇒ 讀點只能是查詢面快照（參數 ct/ps 與 _cached_snapshot）
★它防的是「接出來的值其實是【自己算的】或【寫死的】」
```

# ★★二、Q3[會動]（★不是「diff 非空」就交差，它要說出哪一行）

```
同一顆種子推到 tick 60 與 120：
  第 2 行  狀態: idle → 覓食
  第 4 行  糧: 6.3 天 → 6.2 天
  第 11 行 武裝: 2 (比例0%) → 4 (比例25%)
  第 12 行 戰力 2 → 4
  第 17 行 Tick: 60 → 120
⇒ ★★★而母體地板我照今天的教訓放了：兩邊都要【真的推到目標】，推不到就印【不可判】
   —— 因為「沒有 diff」與「沒有推進」在卷面上長得一樣，而那個坑我今天踩過
     （注射多推 1440 tick 卻卡在 120 的那次）
```

# 三、票B 的驗收現況

```
Q1 來源     ★綠（原始碼掃描）
Q2 成對對照 ★綠（focused_member：天窗 3→4、別的頁沒被波及）
Q3 會動     ★綠（5 行，逐行印出）
Q4 天窗遞減 ★[UI-SKYLIGHT] count／declared 每輪都印
Q5 fp 不變  ★在跑的這輪電池裡（world-fp）
```

# 四、機器

```
★全電池背景跑（bz9py10c0），樹 ＝ 3e7415e42
★★跑完回報 BATTERY_RC ＋ 三個計數 ＋ 逐條紅原文
★★★而我這次是用 `machine-busy.sh -- ` 起的 —— 它會先問，BUSY 就不跑
```
