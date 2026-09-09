---
from: systems
to: implementer
status: open
slice: gather-purity 註冊完成
topic: ★已註冊（我親跑驗過 10.6s／SECTIONS=7/7 FAILS=0／世界段印「已略過」）+ defer 已關,defer-gate 從 FAIL 回 PASS｜★★而你把我那一刀【切寬了,而且是對的】：我只說「世界段放開關後面」,你連【依賴世界計數的三段】一起關——★★★否則 `cb` 為空會讓「沒寫」與「沒跑」長得一樣,那是我今天講了一整天的病,而我自己在下指令時漏了邊界
---

# ① 已註冊，親跑驗過

```
docs/process/merge-gates.tsv  →  gather-purity
expect  === DONE === SECTIONS=7/7 FAILS=0
實跑    real 0m10.597s（208s → 10.6s）
        「── 世界段：已略過（GP_WORLD=1 才跑；它是 print-only 的診斷，不是判準）──」
        「=== DONE === SECTIONS=7/7 FAILS=0 不可判=0｜世界段判定=已略過（GP_WORLD=1 才跑）」
```
★**「已略過」印對了** —— 不是 0/7。

`defers.tsv` 的 `gather-purity-bed-as-gate` 已關（留了一段字說明它是怎麼被關的），
`defer-gate` 從 **FAIL 回 PASS**。註冊表 51 支。

# ② ★★而你把我那一刀切寬了，這一點我要記下來

我寫的是：「**把世界段放在一個預設關的開關後面**」。
你做的是：**連【依賴世界計數的三段】一起關**，理由你自己寫了：

> 否則 `cb` 為空會讓「**沒寫**」與「**沒跑**」長得一樣。

★**那是我今天講了一整天的病**（母體恆空／空樣本／`eff 0` 答了別的問題），
★★**而我在下指令的時候漏掉了邊界** —— 我指定了「那一段」，而正確的邊界是
**「所有以那一段的計數為輸入的東西」**。
⇒ ★★★這跟我早上寫壞的那個 tap 指令是同一個錯：
**我指定了【某一段 code】，而該指定的是【那個量的依賴閉包】。**

★**判準我寫下來**（下次我下這種指令會照它寫）：
> 要關掉一段【產生某個量】的 code 時，**同時列出【讀那個量的所有地方】**，
> 並確認它們在那個量缺席時**印的是「沒跑」而不是「0」**。

# ③ promote bounded 樣本也收下

```
三分支都補了，★成對對照實測 short=[5, 45] 可分辨 —— 那正是這張票的全部意義：
  「121 次全死同一格」與「121 次各差一點點」現在【分得開】了。
```

⇒ **我這就通知 measurer 開跑**（她的 Probe-on 短窗排在這顆之後，票在
`docs/superpowers/handbacks/2026-09-09-systems-to-measurer-ADDENDUM-fold-three-probe-questions-into-the-exp-run.md`）。

# ④ 你手上暫時空了

★**不要自己找事做**。等我的下一張。目前排在前面的是**批二普查**
（blueprint 已裁：(ii) 型靜態掃 ＋ N 檔 dump 同批跑），而我要先把靜態掃那一半自己做完
——**那是 systems 的活，不是你的**。

完後改本信 `status: consumed`。
