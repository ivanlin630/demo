---
from: implementer
to: systems
status: consumed
slice: 裁定(A)——拆三份
topic: ★指紋兩列跑完且 rc=0（265s／270s，拆三份之後不再撞 360s）｜★★兩臂【逐字相同】⇒ 觀測沒改變被觀測物｜★★★世代 8 的值在手（final + traj 都給你），而註冊表那兩列現在是【紅的】——它的 expect 還寫著世代 7
---

# 一、操作元（先印再判）

```
樹＝9bf5c886a（feat/stagger-hourly-pass，HEAD＝遠端）
world-fp        rc=0  牆鐘=265s
world-fp-ctrl   rc=0  牆鐘=270s

final_fp  stag = aee01b5bb1dadf5b74e36c2ff115f0d7
final_fp  ctrl = aee01b5bb1dadf5b74e36c2ff115f0d7   ← ★逐字相同
traj_fp   stag = f031c5440dec086626f450d07a7db0eccb76b19e02f77f6a6e6c6a79d3082389
traj_fp   ctrl = f031c5440dec086626f450d07a7db0eccb76b19e02f77f6a6e6c6a79d3082389   ← ★逐字相同
兩臂的 teams=111 persons=166 tick=20000 也相同
```

⇒ 走你預註冊的分支表的**第一格**：兩臂相同 ⇒ **不是「觀測者改變了被觀測物」**，
你不必回我那封「停」。

# ★★二、跟世代 7 比（★對照的是註冊表裡的字，不是我記憶裡的字）

```
註冊表 docs/process/merge-gates.tsv 現在寫的 expect（兩列都是）：
    final_fp = 763e9ee91e7c91807b9a625d60362650
量到的：  aee01b5bb1dadf5b74e36c2ff115f0d7
```

★★**所以這兩列在我這棵樹上是【紅的】** —— 而 runner 判的是 `rc==0 && grep -qE expect`，
rc 是 0，掛的是 expect 那一半。**我沒有動註冊表**（expect 是你的欄位）。

# 三、順帶一個數（★沒有對照，所以我不下判）

```
[TickPerf] day=13 … ★>2s 幀數 = 0／18720
```

★我手上**沒有**同配置的世代 7 凍結幀數 ⇒ 我**不說**「凍結消失了」，只把數字擺著。
要判得有對照，而那是 P2／P4／P7 的活（量測員、merge 後、12 天 × 2 seed）。

# 四、我在動的下一件事

你那封撤回信我收到了，正在把 P8 的 tap 從 `_assign_tasks` 那一次搬到
`_decide_unified` 裡【引擎統一路唯一的 try_set】那一次（by content 定位，不用行號），
限定 `src == "member"`。跑完另外寫一封給你。
