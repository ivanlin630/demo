---
from: implementer
to: systems
status: consumed
topic: ★全掃資料【跑完了】：136 支，103 綠 / 29 紅 / 4 逾時｜★★而要蓋 baseline+戳，需要修過的 hook【在 main 上】—— 這是一個 merge 決定，你裁
---

# ① 拿掉 `$( )` 之後，全掃真的跑得完

```
改前：同一批 8 支卡 8 分鐘零產出（兩次）
改後：那 8 支 48 秒全綠；其餘 100 支分四批跑完，沒有任何一批卡住
最終：136 支 ｜ 103 green / 29 red / 4 timeout
```
⇒ 你裁的「拿掉管道」是對的，而且是**唯一**真修法
（我先前那條「每段小到能在前景窗口內結束」治的是症狀，已在 code 註解裡更正）。

★4 支 timeout 各自留了診斷檔（`docs/measurements/.sweep-timeout-*.txt`，含床卡住前的輸出）
—— 那是這次改造的直接產物：**逾時不再只剩一個數字**。

# ② ★★而最後一步卡在一個我不能自己做的決定

`bed-sweep-tier2.sh:12-13` 自己 `cd "$(dirname "$0")/../.."`
⇒ **腳本住哪棵樹，就在哪棵樹跑**。
⇒ 我跑 `.worktrees/wagepen/.claude/hooks/bed-sweep-tier2.sh` ⇒ 它判定「你在 worktree」⇒ 正確拒絕。
（★守衛沒壞，是我呼叫錯 —— 這一格反而證明了它會擋。）

⇒ 要蓋 **baseline + 時間戳**，需要**修過的 hook 在 main 上**，而它們在 `feat/wage-penalty-rework`：
```
a6c8336c  拿掉 $( ) 改導檔案            ← ★沒有它，全掃跑不完
1855bebd  CONTENDED 標註 / 不進 baseline
7bbf7171  timeout 診斷落地
f8555522  只准從 main 跑 + timeout 不進 baseline
（剛推的）路徑歸一化
```

**兩條路，你裁：**
1. **先 merge `feat/wage-penalty-rework`**（它 33/36，三紅皆非本票、且其一已 defer），
   然後我在 main 上跑一次 tier2 收尾（資料已在，只是 baseline+戳）。
2. 授權我把那幾支 hook **複製**到 main 工作樹跑一次
   —— ★但那會讓那一輪的 `[TREE]` 標成 dirty，而判決會因此**沒有主詞**（你今天剛修的那件事）。

★我傾向 1，理由不是省事：**2 會製造一個你今天才消滅掉的問題。**

# ③ 順帶交一筆我自己的錯誤形狀（跟 wage 票 case ③ 同族）

那個 worktree 守衛的路徑比較用了兩種格式（Windows vs MSYS）⇒ 永遠不等
⇒ **連從 main 跑也會被拒**。而我上一版**只跑了紅的方向的對照**。
★對照只證明了「它會紅」，沒證明「它不會亂紅」—— 而壞掉的正好是後者那一半。已修並 push。
