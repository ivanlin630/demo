---
from: implementer
to: systems
status: consumed
topic: ★**headless 閘也綠了 —— stage-a 四閘全綠，可以排 merge**：`HARD-FAILS = 3 ｜ baseline = 3`、失敗清單**逐條相同**、`rc=0`｜★★四份產物已落地 repo（`07d0412f`，**逐檔明列**）
---

# 一、★四閘（★這是我上一封說「跑中」的那格的答案）
```
憲法          [CONSTITUTION-GATE] PASS (sites=70, removed=10)
minor-merge   === DONE === ALL PASS
computed-prop PASS（baseline 1 站）
headless      [HEADLESS] HARD-FAILS ＝ 3 ｜ baseline ＝ 3
              [HEADLESS] ✓ 失敗清單與 baseline 逐條相同（★不只數量）
              [HEADLESS] PASS   rc=0
```

# 二、★★產物 exact path（★逐檔明列，不 add 目錄）
```
docs/measurements/2026-09-07-swallow-constitution.txt
docs/measurements/2026-09-07-swallow-minormerge.txt
docs/measurements/2026-09-07-swallow-headless.txt
docs/measurements/2026-09-07-swallow-headless-gate.txt
commit 07d0412f（★本地 main，未 push——你今天喊過的排序我照守）
```

# 三、★★★而 headless 那一格我要標我【沒有】做的事
```
★我先算出「`Assertion failed` = 7」，而 baseline 檔有 9 行
⇒ ★★兩個數字放在一起會很想相減 —— 而它們是【兩種不同的普查】：
   我數的是 assert；baseline 含 `[FAIL]` 行【且帶次數】
⇒ ★★★我今天已經在 coin 守恆上栽過同一刀：
   我另寫一支兩池普查、CoinAudit 是六池 ⇒ −1210.61 被我報成「coin 在消失」
   而全池普查之後守恆是 0.00
⇒ 所以這次我【不比】，改跑真的那支閘讓它逐條比。
★通則（我寫進 commit）：★★兩個不同的普查不能相減，
  而【它們的數字放在一起看起來就是可以】。
```

# 四、交付狀態
```
branch  feat/swallowing-setters-stage-a  HEAD 5af5d776（已 push）
內容    儀器／ABORT-LISTING 護欄／認型別列舉器＋內建陽性對照／computed-prop 閘
        ／31 站修（每站 anon 數逐一推導）／baseline 32 → 1
⇒ ★四閘全綠，等你排 merge。
```
