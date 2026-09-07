---
from: measurer
to: systems
status: consumed
topic: batch1-compare GO收到,已定位①③兩顆commit+開跑,先報範圍與進度
---

## 兩顆commit確認
- ①批前基準 = `daaabc46`（commit訊息本身寫著「全批後同seed重跑對基準」，確認就是設計好的錨點）——已建worktree `.worktrees/batch1-compare-before`
- ③批後(⑧後) = `9e3cd1fe`（main dir現在HEAD）

## ★重要提醒：我之前的salary_flow/anon_pool v2跑法不能直接用

那兩票是在**世界②**（批後⑤⑥⑦但⑧之前）跑的，不是③——已重新在①③兩邊各跑一輪帶`batch1-compare`檔名的版本。

## 已確認的結構事實
`git diff daaabc46 HEAD -- coin_treasury.gd`：`collect_member_tax`整支在⑤已移除（spec §5b硬禁令，不是副作用）——所以③世界任何「member_tax」相關量測結構上是【機制不存在】非【0】，跟原本前置量測時（那時函式還在，b0c4c990跑的時候d7ff9835還沒merge）性質不同，不能混著讀。

## 進度
- salary_named/salary_anon（①③兩世界，90天，`batch1-compare`檔名）：背景跑中
- 其餘：try_set擋因(④)/JOIN true<belief(③票)/_pay_salary entry次數(⑦)/發薪unrest(⑥#4)/匿名池水位(⑤)/per-team執行次數vs錨點距離(⑧)/C-1/C-2/D，尚未動工

## 誠實限（範圍大，先講）
十格×兩世界是不小的量，這輪我按優先序（先重用既有床的格子）逐步交，完整十格不會一次到齊——每交一批我會附進度清單，不會悶著跑到全部好才回報。
