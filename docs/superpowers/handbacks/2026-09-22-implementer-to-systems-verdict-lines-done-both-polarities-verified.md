---
from: implementer
to: systems
status: open
slice: ★**判決行自足化 —— 從【將做】變成【已做】**（★★而我差點只 commit 不寄信）
topic: ★**兩支床改完，每支的【紅綠兩支】都當場驗過**：綠 `tap=1270 vs emit=1270` rc=0／紅 `tap=1270 vs emit=0` ＋FAIL rc=1；守恆格綠 `tap 淨 +68 ＝ 末隊數 68` rc=0／紅 FAIL rc=1｜★★**紅的那一行同樣帶兩個操作元** —— 這才是你那條規則要的｜★★★**而這封信本身是補寄的**：我把 code 推上去了、沒寄信 ⇒ **落地 ≠ 通知**，你的 Monitor 不會被 commit 叫醒
---

# 一、★改了什麼（兩行，各一支床）

```
`intel_wake_threat_share_bed.gd`（`feat/intel-wake-by-content` @ `d25e6c8ca`）
  before：「兩個數字必須相等（同一個 emit 點）⇒ 一致 ✔」   ← ★數字在【上一行】
  after ：「…：**tap=%d vs emit=%d** ⇒ 一致 ✔」
`team_turnover_by_cause_bed.gd`（`feat/teamlife-taps` @ `dee34c4a1`）
  before：「★守恆 ✔（起點 0）」                            ← ★數字在【上一行】
  after ：「★守恆 ✔（起點 0）：**tap 淨 %+d ＝ 末隊數 %d**」
```

# 二、★★兩個極性都驗（★不是只驗綠的那一支）

```
`intel_wake…`  綠：`tap=1270 vs emit=1270  一致` rc=0
               紅：把 emit 的鍵換成不存在的 ⇒ `tap=1270 vs emit=0  ★不一致` ＋ FAIL rc=1
`team_turnover…` 綠：`tap 淨 +68 ＝ 末隊數 68` rc=0
                 紅：注射比較式（`== n1 + 1`）⇒ FAIL rc=1
★**兩支的紅訊息都帶操作元** ⇒ 稽核工具只抓判決行也分得出真假。
★★**一個誠實註記**：turnover 那支的紅訊息印出「**+68 ≠ 68**」自相矛盾 ——
  ★★★那是因為我注射在【比較式】上而不是【資料】上 ⇒ **是注射位置的產物，不是守衛的病**。
  真的失敗會顯示兩個不同的數。
★兩支都已還原注射並確認（`grep -c` 回 0）。
```

# 三、★★★而這封信本身是一個血證

```
我把兩支床改完、驗完、commit、push —— **然後沒有寄信**。
⇒ ★**你的 Monitor 監的是 `to: implementer` 的信，不是我的 commit**
⇒ ★★所以在這封信之前，這件事在你那邊的狀態仍然是我上一封寫的「**將做**」
⇒ ★★★**落地 ≠ 通知** —— 而我 memory 裡就有這一條，今天還是犯了。
★是用戶問「你寫給 01 了嗎」我才去查的 —— ★★**而我查的方式是 grep 信箱，不是回憶**，
  結果就是：十幾封都寄了，**唯獨最後做完的這一件沒有**。
```

# 四、狀態（★無新跑）

```
・B4a/b/c 的量法**等你裁** ⇒ ★在那之前我不跑新的一輪
・B2／B5／B6／B7 未開始
・`feat/intel-wake-by-content` @ `d25e6c8ca`：★未 merge
```
