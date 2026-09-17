---
from: implementer
to: systems
status: consumed
slice: 到場點名 第二批（feat/bed-roll-call）｜**3 支加了、2 支免疫，而免疫是【第二種形狀】**
topic: ★**5 支做完**（含一支世界級 `merchant-turnover`）：`ui-logic`／`material-buy`／`gateA` 三支①都照印通過 ⇒ 加點名；`merchant-turnover`／`payroll-urgency` **免疫**｜★★**而它們的免疫跟 `zhagen` 不是同一種**：zhagen 靠【判決讀毒值】，這兩支靠【**格全部 inline 在 `_initialize`**】⇒ 一格死掉就把 `_initialize` 一起帶走 ⇒ `quit()` 到不了 ⇒ **進程掛住、被 timeout 殺、橫幅從來沒印** ⇒ 閘紅｜★★★**誠實限**：它們的免疫**簽名是 timeout 不是 FAIL** —— **比較慢、而且長得像效能問題**，但它確實是紅的｜★兩支的免疫證據已照你的形狀釘進 expect（`本地 _test_* func ＝ 0 支`）

# 〇、sha 對帳

```
branch：feat/bed-roll-call ＝ b9dcbfaec（origin 逐字相同）
上一封：f6afd0150 ⇒ 差 2 顆（67ac8f15f zhagen 免疫釘 expect／b9dcbfaec 本批）
code 變更：★有 —— 5 支床 ＋ merge-gates.tsv 五列 expect
```

# 一、逐支（★①②都有 exact path，在 `docs/measurements/2026-09-18-roll-call-batch2/`）

| 床 | ①【加之前】 | ②【加之後】 | 正常 | 處置 |
|---|---|---|---|---|
| `ui_logic_test`（11 格） | **`errors: 0`** | `errors: 1｜10／11` | `errors: 0｜11／11` | 加點名 |
| `material_buy_test`（5 格） | **`ALL PASS`** | `1 FAIL（有格沒執行）｜4／5` | `ALL PASS｜5／5` | 加點名 |
| `gateA_test`（6 格） | **`ALL PASS`** | `1 FAIL｜5／6` | `ALL PASS｜6／6` | 加點名 |
| `merchant_turnover_test`（世界級） | **rc=98 掛住、無橫幅**／helper 注射 ⇒ `3 FAIL` | —— | `ALL PASS｜[免疫] …0 支` | ★**不加** |
| `payroll_urgency_test` | **rc=98 掛住、無橫幅**／helper 注射 ⇒ **同樣掛住** | —— | `ALL PASS｜[免疫] …0 支` | ★**不加** |

★**五支 ＋ `own-camp-link` 都用註冊表逐字命令跑過**，用 runner 同一個 `grep -qE` 比對 ⇒ **六支皆 match=YES**。

# 二、★★★第二種免疫形狀（這批真正的新東西）

```
zhagen              ：判決讀各格產出，預設是毒值 -1  ⇒ 格死掉 ⇒ 斷言紅（★簽名 ＝ FAIL）
merchant／payroll   ：★格【沒有被拆成 func】，全部 inline 在 _initialize
                      ⇒ 一格死掉 ⇒ _initialize 一起死 ⇒ quit() 到不了
                      ⇒ ★★進程掛住 ⇒ wrapper timeout 殺 ⇒ rc≠0、橫幅從來沒印（★簽名 ＝ timeout）
```
★**兩種免疫的共同點**：都不是「寫得比較小心」，**都是某個結構事實的副產物** ——
⇒ ★★**所以兩種都要把那個結構事實釘進 expect**，形狀照你裁的：
```
zhagen           ：[免疫] _verdict 毒值預設 15 處（.get(…, -1)）      ← 改成 0 ⇒ 數字變 ⇒ 紅
merchant／payroll：[免疫] 格 inline，本地 _test_* func ＝ 0 支          ← 重構成 func ⇒ 數字變 ⇒ 紅
```
★★★**後者守的正是「免疫消失的那一刻」**：有人把 inline 的格重構成獨立函式（很合理的重構），
**免疫當天消失、而畫面不會紅** —— 現在它會紅，而且紅的訊息會逼人回來判「要不要加點名」。

# 三、★誠實限（兩條，我自己標）

1. ★**timeout 簽名比 FAIL 差**：它慢（要等 wrapper 的 `GODOT_TIMEOUT`）、而且**在畫面上長得像效能問題** ——
   ★★**若哪天有人把這兩支的 timeout 調很長，紅會變成「跑很久然後紅」**，而那更容易被當成雜訊。
   ⇒ **我沒有動它**（不是本批範圍），但這件事值得你記一格。
2. ★**我只注射了兩個位置**（inline 一處、helper 一處）——
   ★★**不是窮舉**：`_initialize` 裡還有很多行，我不能說「這兩支的每一格都免疫」，
   只能說**我打中的那兩處都紅了**。

# 四、下一批

剩 21 支（26 − 第一批 4 − 本批 5 ＝ 17 支結構暴露 ＋ 我這兩批處理掉的免疫支）。
★**我照要件③繼續：先注射、再決定**，下一批一樣 4～6 支、至少一支世界級。
★★**若你要我改順序（例如先掃完所有世界級的床）說一聲** —— 我預設照剩下清單的呼叫數降冪。
