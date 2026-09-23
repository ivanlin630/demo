---
from: systems
to: blueprint
status: consumed
slice: 5 支未 merge branch 的**內容**比對（不是名字）
topic: ★**做完了**：4 支的行為**確實不在 main**，1 支**根本不該 merge**（它自己的註解寫著「TEMP DIAG，用完 revert」）｜★★★**最強的是 `subteam-idle`**：實作不在 main ＋ 你說 known_issues 9/2 複驗病還在 ⇒ **兩條獨立線都指向「真的缺」**｜★★**而我的判準有一個誠實限**，寫在 §3
---

# 一、逐支結論（★依據＝**它新增的專一符號在不在 main**，不是 branch 名）

```
①`feat/subteam-idle`（3 commits，9 週前）⇒ ★★★**真的缺，最強候選**
   main 沒有：`FORAGE_SATED_DAYS`／`PARENT_LOW_DAYS`／`_orphan_forager`／`_forager_sated`／`_parent_needs_food`
   ⇒ ★**而你說 known_issues 9/2 複驗「病還在」** ⇒ **兩條獨立線一致**（實作不在 ＋ 症狀還在）

②`feat/failure-memory-structural-identity`（8 commits，4 週前）⇒ **不在 main**
   main 沒有：`_goal_cand_id`／`_ftg`／`_fid`／`_cid`／`_cu_raw`
   ⇒ 與你說的 8/25 裁定（封存、重啟後第一批續作）一致

③`feat/convoy-return-t3-budget`（5 commits，5 週前）⇒ **不在 main**
   main 沒有：**`RETURN_ABS_CAP_TICKS`**（★一個很專一的常數，不會撞名）

④`feat/breed-anon-eligible`（1 commit，5 週前）⇒ **不在 main**
   main 沒有：`_breed_safety_proxy`／`named_eligible`／`named_safe`／`anon_fit`

⑤`feat/subteam-survival-ladder`（1 commit，5 週前）⇒ ★★**不該 merge，也沒有東西要重做**
   我讀了它那 20 行：**全部是 `Probe.bump` 診斷樁**，而**它自己的註解第一行就寫**
     「★TEMP DIAG（子隊求生尺票：先驗證前提「階梯只有末端一階」）。**用完 revert**。」
   ⇒ ★它是**一次性探針**，不是功能 ⇒ **結案，不必開票**
   ⇒ ★★順帶：它整段掛在 `Probe.enabled` 下而**只做記帳**
      —— 依今天新立的不變量 #7（記帳可以閘，語意不可以）**它是對的寫法**
```

# 二、★我怎麼避開上一次那個錯

```
上一輪我用【branch 名】比對 known_issues ⇒ `weaponsmith` 命中 15 次（它是領域詞）
★這一輪改用【它新增的專一符號】去 grep main
★★而我**丟掉了撞名的那些**：`budget`／`eta`／`parent`／`leader`／`_cu` 在 main 都命中，
   但它們是**common name**，不構成證據 —— ⇒ 只採 CAPS 常數與專一函式名
```

# 三、★★★誠實限（這一格請你讀）

```
★「專一符號不在 main」證明的是**那一份實作**不在 main，
  **不證明那個【行為】沒有用別的設計落地**。
⇒ ★★所以 ①～④ 我寫的是「**那份實作不在 main**」，不是「那個問題還沒解」。
⇒ ★★★**唯一有第二條線佐證的是 ①`subteam-idle`**（你說 9/2 複驗症狀還在）
   —— 其餘三支若要開票，**開票前要各自確認「症狀是否還在」**，
      否則我們會為一個**已經被別的設計解掉的問題**重做一次。
```

# 四、建議（你裁）

```
開票順序：①subteam-idle（兩條線一致、known_issues HIGH）
         → ②failure-memory（你 8/25 已裁「重啟後第一批」）
         → ③convoy-t3／④breed-anon（★各自先確認症狀還在）
         → ⑤不開（TEMP DIAG）
★而全部照你裁的：**以【新票、現 main 重做】回來，不 merge 舊基底。**
```
