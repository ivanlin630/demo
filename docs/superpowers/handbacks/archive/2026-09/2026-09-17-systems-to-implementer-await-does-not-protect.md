---
from: systems
to: implementer
status: consumed
slice: 閘型床到場點名（第一批 4 支）｜補一條你會撞到的事實
topic: ★**`await` 不保護** —— `ui_flow_test.gd` 的 cell 走 `await _test_X()`（coroutine），而 reviewer **另寫了一支 await 版 repro**：中途丟錯 ⇒ **只中止那個 coroutine，`_init` 繼續 await 下一格、照樣印 `[FAIL] 數 ＝ 0`、exit code ＝ 0**｜★★**所以不要為 `ui-flow` 另開一套修法**，同一份樣板通吃同步與 async｜★★★**而這件事是他【主動去驗】的** —— 我只寫了「兩支同族」，他去查出「一支 async 一支同步」這個真差異，然後**自己寫 repro 把它排除掉**
---

# 一、事實

```
ui_flow_test.gd   ：cell 走 await _test_X()（async coroutine）
ui_logic_test.gd  ：同步呼叫，沒有 await
★reviewer 的 await 版 repro：
   被 await 的 cell 中途丟 out-of-bounds ⇒ 只中止那個 coroutine
   ⇒ _init 繼續 await 下一個 cell ⇒ 照樣印「[FAIL] 數 ＝ 0」⇒ exit code = 0
⇒ ★★跟同步版【一模一樣】
```
★**對你的意義**：`ui-flow` 那支**不需要特別處理** —— 到場點名照原樣加，
★★**而你在做①那次陽性對照時，`await` 的那格也一樣會「死得很安靜」** ⇒ **預期它照印 0，不要以為是自己寫錯了。**

# 二、已落地
```
docs/process/03_implementer.md 要件③ 病灶那一句 ← 加註（★沒有新增行數，implementer 開場仍未超限）
docs/process/detail/03_implementer-cases.md    ← await 版 repro 全文
```

# 三、★他做的那件事我要點名

我信裡只寫「`ui-flow` 與 `ui-logic` 是同一族」。
★**他沒有照收**：去核了兩支的 driver，發現**一個我沒提、而且更精確的差異**（async vs 同步），
★★**然後他沒有停在「這可能讓你的分類打折」** —— 他自己寫了 repro 把這個變數**排除掉**，
再回來說「結論支持你的換法」。
★★★**「我發現一個你沒看到的差異」與「我驗過那個差異不影響結論」是兩件事，而他兩件都做了。**
