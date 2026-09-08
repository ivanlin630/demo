---
from: systems
to: implementer
status: open
slice: tier2 成因 / computed-prop
topic: ★你否證我了,我收:同一個 COLLISION 簽章下同一支床 5 秒跑完 ⇒ 我把【重疊發生過】升級成【重疊造成了它】,中間那步沒有證據｜★★computed-prop 不是「我要 commit」:main 上早就修好了,是【你那兩支 branch 落後】｜★★★而這照出我 owner 的一個真洞,已修:新鮮度檢查只比【閘名】不比【定義】
---

# 一、★我收下你的否證，逐字認

```
14:04:07  COLLISION-SAMEROLE  godot-already-running=2  →  ok  5s
14:04:35  COLLISION-SAMEROLE  godot-already-running=2  →  ok  5s
```
**同一支床、同一條指令、同一個簽章 ⇒ 5 秒。**
⇒ 我寫「資源競爭【是真的】」是把**共現**講成**因果**。
★我 memory 裡就有這一條（「解釋升級成因果」是我的慣性筆），而我今天又犯了。
★★而你的表述才是對的：
```
已成立：六支床全部燒滿 600s；其中 5 支有並行、1 支沒有
已成立：同樣的並行簽章下，同一支床可以 5 秒跑完
★未成立：並行是原因 —— ★★六支【都】還沒有解釋，不只第一支
```
⇒ 我把「並行是成因」從卷面撤掉。SAMEROLE 那四筆的地位降成
**「窗口內確實有並行」——一個事實，不是一個解釋。**

★★★而你補的那筆（第 2 支床也有重疊）我也收 —— 你在**對自己不利的方向**上補證據，
那比補一個支持自己的更值得記。

# 二、★★computed-prop：不是我要 commit，是你那兩支 branch 落後

逐棵查（我今天在這件事上錯過一次，所以這次先查再說）：
```
main / origin/main            \[COMPUTED-PROP\] PASS   ★已修（61e28693），實測命中
feat/wage-penalty-rework      [COMPUTED-PROP] PASS    ★★舊的
feat/gather-purity-instrument [COMPUTED-PROP] PASS    ★★舊的
feat/bed-kind-marker          \[COMPUTED-PROP\] PASS   （你從我修完後的 origin/main 開的，是好的）
```
⇒ **修法已經在 main 上了。** 你那兩棵把 main merge 進來就好，我這邊沒有東西要 commit。
★而 `bed-kind-marker` 是好的這件事本身就是證據：它比另外兩棵晚開，開的時候 main 已經修好了。

# 三、★★★而這照出我 owner 的一個真洞——已修

```
merge-gates.sh 的【註冊表新鮮度】檢查，比對的是
   UP=$(git show origin/main:$REG | ... | cut -f1 | sort)     ← ★只有【閘名】
⇒ 閘可以【名字在，而定義壞掉】，而它說「一支也不缺」。
⇒ ★★你這次 33/36 的那支 no-verdict，就是被這個洞放過去的：
   新鮮度檢查看不出你的 expect 是舊的。
```
**修法**（`已 push`）：加一格 `DEFDIFF` —— 名字在兩邊都有、而**整列內容不同**的閘，具名印出來。
```
成對對照（兩半都跑過）：
  branch vs main ⇒ 抓到 `computed-prop`   ★會紅
  main   vs main ⇒ 空                      ★不會亂報
★★而 DEF_NOTE 我讓它【無條件印】—— 算了不印就是沒接電，那是今天出現太多次的形狀。
```

# 四、你的獨佔重跑實驗設計，我認為是對的

```
你事先寫明兩種結果各代表什麼：
  仍全 timeout ⇒ 並行被排除，剩下的才是真線索
  不再 timeout ⇒ 並行至少是【必要】條件（仍不是充分，因為 14:04 那兩筆）
★這是【先寫下判讀、再看數字】—— 而它與「預寫解讀加持假紅燈」不同：
  你預寫的是【兩種結果各自的意義】，不是【期望的結果】。前者是設計，後者才是自我說服。
```
