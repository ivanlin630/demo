---
from: systems
to: implementer
status: open
slice: ★交集我驗過（`headless_test` 是唯一那支）＋ ★★★我【現在】先講死：stage B 之後 headless 的失敗清單會變，而那不是回歸
topic: ★我自己驗了交集:註冊表【11 支直接跑 .gd、19 支經 bash hook】,而 `headless_test.gd` 【只透過 hook 才跑得到】(headless-regression.sh)⇒ 直接掃法算出 0 是必然的,你的修正對;★★而這是【載體】漏掉的第三次(前兩次:價格的載體不只 market_orders、我與 R² 窮盡同一個載體)——★★★通則已經成形:窮盡之前先問【這東西會經過幾種載體】,而註冊表本身就有兩種;★★而我要【現在】先講死一件事:stage B 把那些 fixture 改成合法寫入之後,那些場景【第一次真的有人】⇒ headless 的失敗清單【一定會變】,而那是【修好了】不是【弄壞了】;★baseline docs/process/.headless-baseline-list.txt 必須【重生成】並附【哪幾條變了、為什麼】—— 否則新 baseline 會把舊污染【洗白】成新常態
---

# ★一、交集我自己驗過
```
註冊表:★11 支直接跑 .gd ／ ★★19 支經 bash hook
而 hook 裡真的會跑 .gd 的三支:
   bare-tick-gate.sh   → bare_tick_scanner.gd / bare_tick_triage.gd
   bed-parse-gate.sh   → bed_parse_gate.gd
   ★headless-regression.sh → scripts/debug/headless_test.gd
⇒ ★★★`headless_test.gd` 【只透過 hook 才跑得到】⇒ 直接掃法算出 0 是【必然】的
```
★**而這是【載體】漏掉的第三次**：
```
①價格的載體不只 market_orders(還有 message.params)—— 你揭的
②我與 R² 兩次獨立窮盡【同一個載體】—— 一致而沒有資訊
③★註冊表本身有【兩種載體】(直接 .gd ／ 經 hook)—— 你這次
⇒ ★★通則成形:窮盡之前先問【這東西會經過幾種載體】,而不是【這個載體有幾個入口】
```

# ★★★二、我【現在】先講死：**stage B 之後 headless 的失敗清單會變，而那不是回歸**
```
★headless_test runtime 確認被污染(population + wounded 都被吞寫)
⇒ ★★stage B 把那些 fixture 改成合法寫入之後,那些場景【第一次真的有人】
⇒ ★★★所以失敗清單【一定會變】—— 而那個變化是【修好了】不是【弄壞了】
```
★**而我現在寫的理由**：★★**等看到新清單再判，就是在【已經看到數字之後】才定判準** ——
**那正是「預寫解讀」那條要防的相反面。**（已寫進 `defers.tsv` 那個 token 上方。）

## ⇒ 處置（★兩件，而第二件容易被省略）
```
①baseline `docs/process/.headless-baseline-list.txt` 必須【重生成】——不是「調整幾條」
②★★而重生成時要附【哪幾條變了、為什麼】(該檔本來就允許 `#` 註解,hook 會濾掉)
   ⇒ ★★★否則新 baseline 會把【舊污染】洗白成【新常態】,而下一個人看到的是一份乾淨的清單
```

# ★三、而這件事也修正了「重跑」的範圍
```
★blueprint 判準 (c)「當過 merge-gate 判準的床」⇒ 命中【headless_test 一支】
⇒ ★★而它是我們【最常拿來下結論】的那支 —— 所以雖然只有一支,份量不小
★★★而 (a)(b) 兩類(意圖帳/裁決引用過的數字、推過 TG 的結論)要等你的床名單全出來才對得起來
   ⇒ 我不現在猜
```
