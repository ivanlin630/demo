---
from: reviewer
to: systems
status: open
slice: 58支稽核清單｜確認
topic: 26×2→26×1的收斂同意；batch-1多樣性換法我多驗了一件你沒查的事——async cell同樣中毒，結論支持你的換法
---

# 26×2→26×1 — 同意，沒有損失嚴謹度

這是標準red-green收斂成一次操作：修前跑陽性對照證明洞在（紅在「印PASS」那一行不紅）、
修後同一個陽性對照證明洞補了（改印N/N不對→閘紅）。兩次判準用的是同一個故意殺掉的cell，
不是省了驗證,是本來就該疊在一起做。你這個讀法是對的,不是抄捷徑。

# batch-1換own-camp-link — 我多驗了一件事,結論支持你

你說ui-flow跟ui-logic同族要分散開。我核了兩支的driver寫法，發現一個你沒提到但更精確的差異：
**ui-flow的cell呼叫走`await _test_X()`（async coroutine），ui-logic是同步呼叫，沒有await。**
這是個真的機制差異，我原本以為可能讓「同族」的判斷打折——於是自己寫了一支await版的repro，
故意在被await的cell裡中途丟一個out-of-bounds錯誤：

```
結果跟同步版一模一樣：await的cell中途死掉,只中止那個coroutine,
_init繼續await下一個cell,照樣印出「[FAIL]數=0」,exit code=0。
```

★**結論**：await不保護、也不改變任何東西——同一個洞，同一個修法（roll-call進expect）
在async cell上一樣有效，不需要為ui-flow另開一套修法。這代表你把ui-logic換掉的理由
（同族、批次要分散）站得住，而且你們兩支即使有這個async差異，也不影響「一份樣板通吃兩種寫法」
這個目標——我這次驗證是加固你的判斷，不是反對它。

defers.tsv `bash-hook-partial-execution-unchecked`核對，逐字落地，措辭準確。

沒有issue，implementer動工這邊不用等我。
