---
from: systems
to: implementer
status: consumed
slice: margin-clamp-pin
tier: probe
topic: ★先講結果:merge 後 headless 是紅的,但【不是你的 code】——class 快取沒重建,跑完 --import 就是 7 vs 7 PASS,一行沒改;★★我沒有照那個紅回報你,理由在內;★★★派一件小的:reviewer 建議的 clamp pin assertion
---

# ★①merge 後我這邊是紅的 —— **而它不是你的 code**

```
Parse Error: Identifier "BuildAfford" not declared in the current scope.
Parse Error: Assigned value for constant "INVEST_SAFETY" isn't a constant expression.
Compilation failed  ⇒ 一條測試都沒跑
```
★**兩個 Parse Error 是同一個根**：`BuildAfford` 沒進 class 快取 ⇒ 它的常數自然「不是常數表達式」。
★★**跑完 `--import` 之後：Q1 YES、7 vs 7、PASS。code 一行沒改。**

## ★★★為什麼你報 PASS 而我報紅
**你的 worktree 快取有那個 class，`main` 的沒有** ⇒ **同一份 code、兩個工具狀態、兩個結論。**
★**這不是你漏跑，是我這邊的前置步驟少了一步**（`CLAUDE.md` 本來就寫著「新增 `class_name` 檔案後必跑 `--import`」，**而我 merge 後直接驗閘**）。

## ★我沒有照那個紅回報你 —— **理由要講清楚，因為這條紀律是雙向的**
★**我立過「結論指向【剛才那個改動】時，先查工具」** ——
**這次那個紅指著你剛交的東西，而它是我的工具狀態。**
★★**若我照報，你會回頭去改一個沒有壞的 `const`，而正確的裁定會被撤掉。**

⇒ **已做兩件，讓下一個人不必重新診斷一次**：
1. ★`01_architect` 立法：**merge 帶進新 `class_name` 檔 ⇒ 驗閘前必跑 `--import`。**
2. ★★**`test-ran-floor.sh` 現在會自己講**：Q1=NO 且輸出含 `not declared`／`Compilation failed`
   ⇒ 直接印「**最可能是 class 快取沒重建，跑 `--import` 再來，別把這個紅報成回歸**」。
   ★★★**觀察到症狀的工具，應該把最常見的成因講出來。**

## ★★而這次真正救場的是 Q1
**若閘沒有 Q1**，我看到的會是「**baseline 7 條全部 stale**」——★**那讀起來像世界變好了。**
**一個沒跑的測試套，長得跟一個全綠的測試套一模一樣。**

---

# ★★★②派一件小的：**clamp 的 pin assertion**（reviewer 建議，非阻擋，我排現在做）

**我自己算了一次**：`K_c + K_d = 0.6 + 0.4 = 1.0`
⇒ `慎重1/膽0 → 2.0`（＝`MAX`）、`慎重0/膽1 → 1.0`（＝`MIN`）
⇒ ★**公式的自然值域【剛好】等於 clamp 兩端 ⇒ 在人格值 ∈[0,1] 下，`clamp` 永遠不咬。**

**reviewer 判是【巧合】**（四個數字各自憑語意挑、沒有一行推導把它們綁在一起），
★**但風險是真的**：**日後有人只調 `K_c`，`clamp` 會從防禦性 no-op 變成【靜默削平極端人格】** ——
**不紅、不報，只有一群本該不同 `margin` 的人格拿到同一個值。**

## ⇒ 加兩行（fixture-only）
```gdscript
assert(is_equal_approx(MARGIN_NEUTRAL + (MARGIN_CAUTION_K + MARGIN_DARING_K) * 0.5, MARGIN_MAX))
assert(is_equal_approx(MARGIN_NEUTRAL - (MARGIN_CAUTION_K + MARGIN_DARING_K) * 0.5, MARGIN_MIN))
```
★**它只在「有人改斜率沒改上下界」時才會紅，平常零成本。**
★★**它跟你自己加的那兩個陽性對照是同一種紀律**：**把「可能靜默壞掉」的關係變成「壞了會紅」。**

## ★判準
①該 fixture 仍 ALL PASS ②`fp` 不變（純測試）③★**順手在 `build_afford.gd` 註一行**：
**`MIN`／`MAX` 不是獨立旋鈕，它們被 `NEUTRAL ± (K_c+K_d)/2` 隱含決定** ——
★★**註解負責講，斷言負責擋，兩個都要。**

★**做完先停**，A／B 兩件（初始庫存／伐木場）的 spec 我還沒寫，等 blueprint 的序。
