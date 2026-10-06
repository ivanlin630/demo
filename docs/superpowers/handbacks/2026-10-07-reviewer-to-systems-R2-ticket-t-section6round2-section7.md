---
from: reviewer
to: systems
status: open
slice: 票 T §6 第二輪（CLEAN）＋§7 三條疲勞曲線收成一支（ISSUES 一列）
topic: §6② 門檦補上，核對正確＝CLEAN；§7 你優先打的（path/encounter換曲線後有沒有讀者依賴舊曲線形狀）——找到一個真的、可算出數字的衝突：`MIN_STAMINA_TO_DODGE=0.1` 今天剛好卡在舊公式的下限上（f=1.0時stamina=0.1），兩者相等讓「滿疲勞時能不能閃避」今天是**恰好不能**（嚴格大於比較），換成新公式（f=1.0時×0.3）後會變成**能**——這不是接近，是一個會翻面的判定
---

# 0 審了哪棵樹

`origin/main` ＝ `a3917b25f`。

# 1 §6② 第二輪——CLEAN

```
新文字逐字：「★R²打回：真實懲罰是硬門檦sim_runner.gd:956 if team.fatigue>=1.0⇒這一項照搬同一個
條件：fatigue<1.0時＝0；不准用fatigue算漸增近似（世界沒有漸增，秤也不准有）」
⇒ 跟我上封信要求的逐字對上，確認落地正確
```

# 2 §7（你優先打的）——找到一個真的衝突，不是推測

## 數字核對

```
今天（兩處同形）：path_system.gd:191／encounter_system.gd:147,163
  clampf(1.0 - fatigue, 0.1, 1.0)   ← fatigue=1.0 時這個值 ＝ 0.1（卡在floor）
encounter_system.gd:75  const MIN_STAMINA_TO_DODGE: float = 0.1   ← ★跟上面那個floor逐位元組相同
encounter_system.gd:750  if float(unit.get("stamina",0.0)) > MIN_STAMINA_TO_DODGE:
  ⇒ 今天：滿疲勞時 stamina=0.1，判準是嚴格大於(>)0.1 ⇒ 0.1 > 0.1 ＝ **false** ⇒ 滿疲勞的單位【不能】閃避
新公式（移動那條，§7要三處都改用）：f≥1.0 ⇒ ×0.3
  ⇒ 改完：滿疲勞時 stamina=0.3 ⇒ 0.3 > 0.1 ＝ **true** ⇒ 滿疲勞的單位變成【能】閃避
```

## 這不是「形狀換了但沒人在意」，是一個會被玩家感受到的判定翻面

```
★這條依賴今天**剛好**存在：MIN_STAMINA_TO_DODGE跟舊stamina公式的floor用的是同一個數字0.1，
  而且判準是嚴格不等式,讓「滿疲勞」正好落在【不能閃避】那一側——這看起來不太像巧合，更像是
  當初選0.1時就是照著stamina的floor選的（兩個常數同一個數字,同一個檔案,同一個主題）
⇒ §7把三條曲線收成一條之後,滿疲勞單位的stamina floor從0.1變0.3,
  原本「累到完全沒力就躲不開攻擊」的判定,會變成「累到完全沒力還是躲得開」
⇒ 這是一個P12會量到的fp變化,但P12只會告訴你「變了」,不會告訴你「變成什麼意思」——
  這個具體的行為翻轉（滿疲勞的單位從不能閃避變成能閃避）值得在spec裡點名,
  讓implementer知道這是**這次改動的一個真實後果**,不是雜訊
```

## 另一個順手核過，沒事

```
encounter_system.gd:476 `if unit["stamina"] <= 0.05:` ——這個閾值(0.05)比新舊兩個floor(0.1/0.3)
  都低,只能透過戰鬥中的消耗(:740 dodge cost／:806 attack drain)才會被打到,不是從fatigue初始值
  直接可達——新舊公式都不會讓fatigue本身觸發這一行,這一條讀者不受影響
```

## 處置

```
不是不能換曲線（統一是對的方向，禁手抄物理的紀律我支持），是這個翻面要被**看見並確認**：
  要嘛①確認「滿疲勞仍能閃避」是blueprint願意要的結果（WHAT輕量確認，一句話就夠）
  要嘛②若不是,MIN_STAMINA_TO_DODGE要跟著新floor重新校準(不是0.1,是某個高於0.3的值)
  不建議②的那個新值由implementer自己猜——它今天跟stamina floor剛好相等不是巧合，
  改之後也該是「照某個邏輯重新對齊」，不是隨便挑一個數字
```

# 3 判決

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "三處改呼stamina_factor，行為會變，量了就好（P12）",
     "file_line": "encounter_system.gd:75(MIN_STAMINA_TO_DODGE=0.1)／:750(嚴格大於比較)；舊floor 0.1 逐位元組等於它",
     "truth": "滿疲勞單位的閃避判定今天剛好卡在0.1==0.1的false那一側,換成新公式的0.3後會翻成true;這是一個具體、可預期的行為翻轉,不只是『fp會變』,要在spec裡點名並讓blueprint或implementer明確處置，不要留給P12的量測事後才發現"}
  ],
  "note": "§6②第二輪CLEAN，文字逐字對上。§7只這一列，改完或確認完敲sha，我只看這處。" }
```
