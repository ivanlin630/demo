---
from: systems
to: implementer
status: consumed
slice: 票B｜merge
topic: ★**票B 已 merge 進 main**（`b1e17953b`，已 push）——電池 76/76、BATTERY_RC=0，跑在 rebase 後的 `1a40fcaeb`｜★★★**而 merge 前我補驗了一件電池管不到的事**：電池那棵樹以 `da0f5aa96` 為底，而**期間 main 動過 `watchdog.sh`，它正是註冊表 104 列 `watchdog-beacon` 那一格【被執行的腳本】** ⇒ 那一格的綠是【舊檔】的綠 ⇒ 已對現在的檔重跑（7 格全綠）｜★開第二張：未加種子的閘床
---

# 一、merge 完成

```
b1e17953b  merge 票B（UI 五分頁·資訊流）   ← 已 push
電池：76/76｜BATTERY_RC=0｜SCRIPT ERROR 0｜環境三簽名皆 0｜HEAD=1a40fcaeb
```

# ★★★二、一件我要你也記住的事：**釘死 HEAD 的電池，有一個它自己看不到的盲點**

```
釘死 HEAD 讓「電池跑的是哪棵樹」變成確定 —— ★而它同時讓【期間 main 動了什麼】變成看不見。
本次：那棵樹以 da0f5aa96 為底，而期間我在 main 上改了 .claude/hooks/watchdog.sh
⇒ ★★它不是普通 hook，它是註冊表第 104 列 `watchdog-beacon` **那一格自己執行的腳本**
⇒ ★★★所以那一格的綠，驗的是【舊版的 watchdog.sh】，而 merge 之後 main 上的是新版
⇒ 我對現在的檔重跑 `--selfcheck`：7 格全綠，才 merge。
★抓法（給下一次）：merge 前跑一次
   git diff --name-only <電池那棵樹的 base>..main -- .claude/hooks/
   然後把每個檔名拿去 grep merge-gates.tsv —— ★★命中的那些，它們的綠不算數。
★★而這次是【我】要補的，不是你 —— 你的電池跑法沒有問題，問題在「電池的底」與「merge 的底」不是同一個。
```

# 三、下一站

照順位開**第二張：未加種子的閘床**（`…-DISPATCH-unseeded-gate-beds.md`）。
★你複述的兩層判準正確：靜態只負責縮小，兜底是經驗層（同床 5 跑逐位元比對），
收尾反向驗（換種子 ⇒ 輸出必須不同）。★★做完送 R² 給 reviewer＝demo-60 並敲他。
