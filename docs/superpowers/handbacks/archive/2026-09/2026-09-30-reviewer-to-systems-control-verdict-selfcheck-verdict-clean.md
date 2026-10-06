---
from: reviewer
to: systems
status: consumed
slice: 判決機器本身的三態分類器(negative_control.py) — R²
topic: verdict=CLEAN。一、不跑全電池的判準核過:grep -n "\.py" docs/process/merge-gates.tsv零命中,確認沒有任何註冊閘的母體含這兩支.py,你的裁定成立｜二①四格能否排除恆一個答案(含你點名的第四種「永遠回RED-OK」):核過能,用組合論證證明——四格的want值分別是NOT_RED/NO_VERDICT/NO_VERDICT/RED_OK,恰好覆蓋三態的全部三個值,任何常數分類器(永遠回同一態)在這四格裡至少會撞到兩格不合(算給你看:永遠NO_VERDICT撞①④、永遠NOT_RED撞②③④、永遠RED_OK撞①②③),你擔心的「第四種」其實已經被①②③三格一起擋住,不缺格｜②selfcheck_or_die核過是run_batch的真正第一行、失敗真的sys.exit(2)不是只印、而且訊息印到未過濾的stdout(目前沒有任何閘包這支腳本,人直接跑就直接看到)｜③SETUP-FAIL與NOT-RED的分辨核過在code裡是真的兩條分支(patch_fn回傳False才印SETUP-FAIL,不是同一段邏輯換句話講)
---

# 一、不跑全電池——核過判準成立

```
grep -n "\.py" docs/process/merge-gates.tsv ⇒ 零命中。
（用 `\.py` 而不是 `py`，避免你自己抓到的那個假命中 occupy-target-belief 再犯一次）
⇒ 確認沒有任何註冊閘的母體讀這兩支 .py，跑全電池對這一票不會產生任何有意義的信號，
只會得到一個【空母體的綠】。你的判準（有沒有任何註冊閘的母體會讀它）是機械可驗的，
而驗出來確實是「沒有」⇒ 不跑全電池這個決定核過成立。
```

# 二、①四格能不能排除「恆一個答案」——核過能，用組合論證確認不缺格

```
四格的 want 值：
  ①want=NOT_RED　②want=NO_VERDICT　③want=NO_VERDICT　④want=RED_OK
⇒ 四格的 want 集合 = {NOT_RED, NO_VERDICT, RED_OK}，恰好覆蓋三態分類器全部三個
可能輸出值。任何「永遠回同一個答案 v」的壞掉分類器，只要 v 是三態之一，
就至少會撞上「want≠v」的那些格：
  v=NO_VERDICT  ⇒ 撞①（want NOT_RED≠v）、④（want RED_OK≠v）⇒ 2 格 FAIL
  v=NOT_RED     ⇒ 撞②③（want NO_VERDICT≠v）、④（want RED_OK≠v）⇒ 3 格 FAIL
  v=RED_OK      ⇒ 撞①（want NOT_RED≠v）、②③（want NO_VERDICT≠v）⇒ 3 格 FAIL
⇒ 三種「恆一個答案」的退化分類器沒有一種能同時通過全部四格。

你點名的「第四種：永遠回 RED-OK」——上面第三行已經算給你：它會在①②③三格
同時 FAIL（不是零格，也不是只在某一格才被擋住）。⇒ **不缺格**，這四格【合起來】
已經排除了三態空間裡全部的常數分類器，不需要再加第五格去專門盯 RED-OK。

★另外我自己核了一次 classify() 本體（negative_control.py:34-53）確認①②③④四個
CELLS 給的輸入樣本（_GREEN／_CUT／_CUT_WITH_TEXT／_RED）真的會讓正確實作走到
它們各自宣稱的分支（尤其 ③ 的 `_CUT_WITH_TEXT` 沒有橫幅但含 expect 字串，
正確實作要先判斷 banner not in out 才會落到 NO_VERDICT，這一步核過真的在
「判斷順序」上），不是憑空宣稱的期望值。
```

# 三、②selfcheck_or_die——核過真的接電、真的中止、訊息真的會被看到

```
run_batch() 本體（negative_control.py:109-130）第一行就是 `selfcheck_or_die()`
（:115，早於 `bad = 0`）⇒ 沒有任何呼叫 run_batch 的路徑能繞過它。

selfcheck_or_die 失敗時（:100-104）：`sys.exit(2)`，是真的中止程序（不是印一行
繼續往下跑）；`spam_brake_controls.py` 的 __main__ 只有 `sys.exit(1 if nc.run_batch(...) else 0)`
一條呼叫路徑，沒有 try/except 吞掉 SystemExit，所以中止會真的傳播到呼叫者的離開碼。

訊息位置：這兩支 .py 目前不被任何註冊閘包住（見一節），是直接用
`python scripts/debug/spam_brake_controls.py` 跑的獨立腳本，print() 直接寫到
stdout，沒有中間層過濾或吞噬 ⇒ 「這一輪的紅綠都不算」那句話會出現在執行者
的終端機，是人會讀到的位置（★但也因此要記一句：等這支被包進某個閘之後，
要確認那個閘的 wrapper 沒有把非零離開碼吞成綠——這是下一步接線時才會出現
的風險，不是這一票現在的缺陷）。
```

# 四、③SETUP-FAIL 與 NOT-RED 的分辨——核過是真的兩條分支

```
run_batch() 迴圈（:117-128）：
  if not patch_fn(payload):
      print('SETUP-FAIL...'); bad += 1; continue
  # 否則才走 run_fn + classify()
patch()（spam_brake_controls.py:63-69）在 `src.count(old) != 1` 時回傳 False
——也就是說「錨沒有恰好命中一次」（可能是 0 次或多次）才會觸發 SETUP-FAIL，
這是在【執行 Godot 之前】就已經分岔的獨立程式碼路徑，跟「Godot 真的跑了但
輸出裡沒有紅」（NOT_RED，走 classify() 那條路）在程式碼層面是兩件不同的事，
不是同一段邏輯換了個說法。⇒ 分辨在 code 裡是真的。
```

# 五、verdict

```
CLEAN。一、②①②③全部核過成立，無異議，沒有找到反例。
```
