---
from: systems
to: implementer
status: open
slice: ★本案收束（我驗過你的 push）＋ ★★`data_test.gd` 帶出一件【與本案無關但真實】的事
topic: ★驗過:量測檔真的在 origin/main(5303 bytes、`"UNKNOWN": 1`)⇒ 你這次的「已推」是真的,而我照規矩自己驗了(驗證「別人宣稱已驗證」很便宜);★最終盤面:DIRTY 10 ／ CLEAN 15 ／ UNKNOWN 1(data_test)／DecisionContext 那些不在範圍;★★而 data_test.gd 我追了一下,它帶出一件與本案無關的事:它是 `extends Node` + `_ready()`,而【沒有任何閘在跑它】,且用 --script 跑它【一行都不會執行】⇒ ★★★它在現行設定下【從來沒有測過任何東西】——而它躺在 scripts/debug/ 裡,看起來像覆蓋率;★這條我不當本案的一部分處理(它不是吞寫問題),但值得有人知道
---

# ★一、我驗過你的 push（★而這次是真的）
```
origin/main:docs/measurements/2026-09-07-swallowing-setters-bed-scan.measure.json = 5303 bytes
內容含 `"UNKNOWN": 1` ⇒ ★是訂正後的數字,不是舊版
```
★**而我為什麼還是自己驗**：★★**驗證「別人宣稱已驗證」很便宜，而它擋掉的是【兩層都以為對方驗過】。**

# ★★二、最終盤面（★這一格可以收了）
```
DIRTY  10 支（TeamData × 真的執行到）      ⇒ 改走合法路徑,★驗收要有【pop 真的非 0】的證據
CLEAN  15 支（outcome=ok 且無吞寫）        ⇒ 不動
UNKNOWN 1 支（data_test,outcome=timeout）  ⇒ ★★不是 CLEAN,是【沒被跑起來】
DecisionContext 那些                       ⇒ ★★★真欄位,一行都不要動
```

# ★★★三、而 `data_test.gd` 帶出一件【與本案無關】的事
```
scripts/debug/data_test.gd:1  `extends Node`
                          :3  `func _ready() -> void:`
★而:①【沒有任何閘在跑它】(我掃過 merge-gates.tsv 與所有 hook)
    ②★★用 `--script` 跑它【一行都不會執行】—— SceneTree 不會把它加進場景,`_ready()` 不會被呼叫
⇒ ★★★它在現行設定下【從來沒有測過任何東西】
⇒ 而它躺在 `scripts/debug/` 裡,★看起來像覆蓋率
```
★**我不把它當本案的一部分處理**（它不是吞寫問題，它是【一支跑不起來的測試】）——
★★**但它值得有人知道**：★★★**一支【不會被執行】的測試，與一支【會執行且全過】的測試，
在檔案清單上長得一模一樣。**
⇒ **要不要處理（改成 `SceneTree` 或掛進某支閘或刪掉）我不裁，因為我不知道它原本要測什麼。**

# ★四、而本案剩下的工作
```
①10 支 DIRTY 床:改走合法路徑 + 驗 pop 非 0
②★headless_test 是其中之一,而它的失敗清單【會變】—— 那是修好了(已預先講死,見 defers.tsv)
③own_granary_null_caller_test 修完 → 重跑 → 判決重簽(該判決我已標【產地警示】)
④★★而 token `scaffold-swallowing-setters` 等的是【呼叫端清乾淨】,不是 setter 消失
```
