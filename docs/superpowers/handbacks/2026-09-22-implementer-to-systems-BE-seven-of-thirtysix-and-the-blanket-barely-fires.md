---
from: implementer
to: systems
status: open
slice: 子隊 blanket 歸建 —— 逐 task 型別（**純量測，只量不判**）
topic: ★★★**36 種 task 裡【實際會抵達】的只有 7 種**（兩顆種子都是 7）｜★★**而最大宗那一種根本沒被 blanket 歸建**：`TASK_EXPAND` 抵達 **1420／1337 次、歸建 0 次** —— 抵達的都在更前面的 `return` 就離開了｜★**合計 arrived 1999／1744，evicted 只有 59／44（≈3%）**｜★**你信裡寫 24 種，我掃到 36 種常數** —— 我沒有把數字對齊成你的，差額原樣呈報
---

# 一、卷面（逐型別，只列非零；含 0 的全 36 行在 raw）

```
seed 1337                        arrived  evicted  ratio
  TASK_EXPAND    擴建               1420        0   0.000   ← ★最大宗,而它一次都沒被歸建
  TASK_SCOUT     偵查                325       54   0.166
  TASK_HERALD    信使                246        0   0.000
  TASK_FORAGE    覓食                  3        3   1.000
  TASK_CONVOY    運輸                  3        0   0.000
  TASK_TRIBUTE   徵收                  1        1   1.000
  TASK_DEFEND    迎戰                  1        1   1.000
  合計 arrived=1999 evicted=59｜★有抵達的型別 7／36

seed 77
  TASK_EXPAND    擴建               1337        0   0.000
  TASK_SCOUT     偵查                274       29   0.106
  TASK_HERALD    信使                108        0   0.000
  TASK_CONVOY    運輸                 10        0   0.000
  TASK_FORAGE    覓食                  9        9   1.000
  TASK_CAMP      紮營                  5        5   1.000
  TASK_DEFEND    迎戰                  1        1   1.000
  合計 arrived=1744 evicted=44｜★有抵達的型別 7／36
```

# 二、★★這一份數字裡最該注意的那一格

```
★整體歸建率只有 ≈3%（59／1999、44／1744）
★★而它不是平均分布的：**EXPAND（最大宗，佔七成以上抵達）一次都沒被歸建**，
   SCOUT 是 10~17%，而 FORAGE／CAMP／TRIBUTE／DEFEND 是 100%（但它們次數都是個位數）
⇒ ★★★所以「那條 blanket 管著 24 種」與「那條 blanket 實際在管什麼」是兩回事：
   **它實際只咬到極少數、且多半是低頻的那幾種。**
```
★**這句是量到的，不是我的裁定** —— 「slice 還是 arc」由你判。

# 三、★量法的三個關鍵（★沒有它們，這些數字會說謊）

```
①**分母放在【所有提早 return 之前】**，不是貼著 blanket
   ⇒ 那條 blanket 是「抵達即歸建」**無條件** ⇒ 貼著放 ⇒ 分子分母同一批 ⇒ **恆 100%**
   ⇒ ★★而差額是真的：EXPAND 抵達 1420、歸建 0 ——它們全在 ESCORT／discipline／settle 那幾條先 return
   ⇒ ★你信裡已經點名這一格，我把它做在【函式開頭】而不是【blanket 前一行】
②**型別清單不手抄**：執行期掃 `team_data.gd` 的 `const TASK_*`
   ⇒ ★手抄的清單不會跟著新 task 長大，而漏掉的那種【連 0 都不會印】
③**母體 0 的型別也印** ＋ 床自帶塌陷守衛（掃到 <10 種 ⇒ 判【不可判】，不是綠）
```

# 四、★你寫 24 種、我掃到 36 種 —— 我沒有把數字對齊成你的

```
`team_data.gd` 的 `const TASK_*` ＝ **36 個**（包含 IDLE／ESCORT／SCOUT／HERALD／EXPAND／CONVOY…）
你信裡列的 24 個裡沒有 SCOUT／HERALD／EXPAND／CONVOY —— ★而那四種正是【實際會抵達】的主力
⇒ ★★所以差額不是無關緊要的尾巴：**你的清單少的那幾種，佔了抵達量的九成以上**
⇒ ★★★可能你數的是「會落到那條 blanket 的子集」而我數的是「全部 task 常數」——
   **兩個都合理，但它們是兩個母體** ⇒ 我原樣呈報，由你決定卷面要用哪一個母體
```

# 五、落地（exact path）

```
卷面：docs/measurements/2026-09-22-BE-blanket-evict-by-task-gen6.txt
raw ：docs/measurements/2026-09-22-BE-be-s1337-gen6.log.gz（★含全 36 行，0 的也在）
      docs/measurements/2026-09-22-BE-be-s77-gen6.log.gz
      docs/measurements/2026-09-22-BE-be-smoke-gen6.log.gz（1 天窗：只有 EXPAND 抵達 40、歸建 0）
分支：feat/blanket-evict-tap（兩顆 tap ＋ 一支 diagnostic 床）——★**尚未 push，等你說要不要進 main**
     （tap 是純記帳；★若你只要數字不要 tap 進 main，我就讓它留在分支）
```

# 六、★誠實限

```
①8 天窗；★更長窗會不會有第 8 種型別抵達，未驗
②`arrived=0` 代表【這一輪沒有子隊帶著它抵達】—— ★不代表那個 task 不存在、也不代表 blanket 管不到它
③兩顆種子的 7 種【不完全相同】（1337 有 TRIBUTE、77 有 CAMP）⇒ 邊緣型別是偶發的
④tap 只記帳、零行為改動；世代 6／HW-2 —— 次數比跨機有效、★跨代不可引用
```

# 七、下一步

**你**：依這顆數字裁「slice 還是 arc」，並決定 §五 那個分支要不要進 main。
★**而我建議你把 §四 那一格一起看**：我們兩個的母體差 12 種，**而差的那幾種正是主力** ——
**先對齊母體，再談 24 或 36。**
