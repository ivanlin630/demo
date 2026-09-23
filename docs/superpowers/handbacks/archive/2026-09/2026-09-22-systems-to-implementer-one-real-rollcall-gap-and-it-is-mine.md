---
from: systems
to: implementer
status: consumed
slice: 註冊表衛生（低優先，★排在 memo 之後）
topic: ★**只有一支床真的缺到場點名，而它是我今天自己補註冊的那一支**（`crisis_override_test.gd`）｜★★★**而我原本數出 6 支是假的 backlog**：我的判準只認三個【名字】，而另外 5 支本來就有點名，只是叫 `EXPECT_SECTIONS`｜★★請在 memo 那張票**做完之後**再處理這一支，不急
---

# 一、★先講我自己數錯的那件（因為它比那一支床重要）

```
我的判準：`grep -qE '到場點名|roll_call|_attendance'` ⇒ 數出 **6 支欠點名**
★而其中 5 支本來就有點名，只是叫別的名字：
   const EXPECT_SECTIONS: int = 4          ← 外部釘死的期望
   _sections += 1                           ← 每段結束加一
   print("=== DONE === SECTIONS=%d/%d FAILS=%d")
   ★★而**註冊表的 expect 又把 `4/4` 釘了一次** ⇒ **雙重外部釘死**
   ⇒ 少跑一段 ⇒ 印 `3/4` ⇒ expect 不命中 ⇒ **紅**。★這比我那三個名字強。
⇒ ★★★**真正欠點名的只有 1 支**，而它是我 2026-09-22 自己補註冊的那一支。
   同族：**grep 命中【名字】不命中【意思】** —— 而這次它製造的是**假的 backlog（比實際大 6 倍）**。
⇒ defer 那一列的 met_check 我已經放寬到認 `EXPECT_SECTIONS|SECTIONS=` 這個形態。
```

# 二、★要你補的那一支（`crisis_override_test.gd`，17 格）

```
現況：`_ok()` 累加 `_fail`，結尾 `if _fail == 0: print("=== DONE === ALL PASS")`
★病：GDScript 的中止粒度是【當前那一支 func】⇒ 若某支 `_test_xxx()` 中途炸掉，
   `_run` 照樣往下走、`_fail` 仍是 0 ⇒ **印出 ALL PASS** ⇒ 「沒有失敗」與「沒有執行」在畫面上一模一樣
★★而我今天註冊它之前做的成對驗證（反轉 `_ok` ⇒ 16 FAIL／原檔 ⇒ ALL PASS）
   **只證明了【判決印得出來】，沒有證明【到場的人是全的】** —— 那是兩件事，而我當時沒分開。
```
**要的形狀（★照那 5 支的樣子，不要發明新的）**：
```
const EXPECT_SECTIONS: int = <真實段數>     ★釘死在原始碼裡，★★而不是拿陣列長度自己跟自己比
_sections += 1                               每段結束
print("=== DONE === SECTIONS=%d/%d FAILS=%d" % [_sections, EXPECT_SECTIONS, _fails])
★★★而 `merge-gates.tsv` 那一列的 expect 我會同步改成 `=== DONE === SECTIONS=N/N FAILS=0`
   ⇒ **兩層都釘外部常數**（原始碼一層、註冊表一層）
★陽性對照：把任一段的第一行換成 `return` ⇒ 必須印 `SECTIONS=N-1/N` ⇒ expect 不命中 ⇒ 紅
```

# 三、★優先序

```
**排在 memo 那張票之後**。它不擋任何東西 —— 那支床現在是綠的（我實跑過 ALL PASS，17 格全過），
★只是它的綠**少一層保證**。★★別為了它打斷 memo。
```
