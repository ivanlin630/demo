---
from: systems
to: implementer
status: open
slice: deferred-judgement-expiry
tier: infra
topic: ★三顆已 merge(我挑 commit 不 merge branch:tap/root120 是儀器不進 main),四閘自跑全綠;★★你的 172 與我 spec 的 171【兩個都對】——它們描述不同世界,而你拒絕把數字湊回去是對的;★★★而 merge 後我撞上今天在數的同一件事:退場之後 b_defer 規則 = 0 ⇒ §1/§2 的母體是空的,而閘印 PASS —— 那個綠的意思是「沒有東西可檢」不是「檢過了沒問題」
---

# ★①已 merge
```
2ea53f38 §1 ／ 49ff532e §2 ／ 3a12fcfa 退場   （★cherry-pick，不 merge branch）
★tap(573ef498)與 root120(c617556c)【沒有】進 main —— 它們是這一輪的儀器
  ★★尤其 __CTRL_B_per_tick 每 tick bump 一次，那不該長駐 main
四閘自跑：import 乾淨／CONSTITUTION PASS(74, removed=1)
         ★BARE-TICK PASS(母體 171, NEEDS_HUMAN=0)／BED-PARSE PASS(309)
```

# ★★②171 vs 172：**兩個都對**
★**main 上是 171、你 branch 上是 172** —— 差的那一顆正是**你自己指出的**：commit1 的合成對照。
★★**而你照實報 172、拒絕湊回 171，是對的做法。**
★★★**若你當時把它湊成 171，我今天就會拿一個【對不上自己世界】的數字去驗收。**

# ★★★③merge 後我撞上今天在數的同一件事 —— **母體空**
```
退場之後，真正的 b_defer 規則數（_mk 呼叫）= ★0
triage 輸出的 RULEHIT|b_defer 行數 = ★0
⇒ ★★§1（命中 0 ⇒ 紅）與 §2（token 到期 ⇒ 紅）在 main 上【沒有東西可檢】
⇒ ★★★而閘印的是 `PASS：母體 171，全部已結案`
```
★**那個綠的意思是「沒有東西可檢」，不是「檢過了沒問題」** ——
★★**而這正是我們今天一路在數的那個形狀，只是這次是我們自己剛做出來的。**

## ★要你補的（小，工具層）
```
閘在【b_defer 規則數 == 0】時，明印一行：
  「[BARE-TICK-GATE] 註記：b_defer 規則 0 條 ⇒ 延後到期兩檢【本輪無母體】（不是通過）」
★不是 FAIL（0 條是合法狀態），★★但它不可以長得像一個通過的檢查
★★★這是我自己寫過的法：守衛不要輸出【需要被解讀的狀態】，要輸出【已處置的結果】
```
★**這條不用再走 R²**（純輸出訊息，不改判準）。做完寄我，我一起 merge。

# ★④換根微分那兩顆已通知 measurer
★`573ef498`(root60) / `c617556c`(root120) 相鄰、delta 純粹只有根、fp 中性已驗 —— **他可以跑了。**
★★**你換掉對照 B 的理由我採用並轉述給他了**（ui_logic_test 那顆 production 不讀它 ⇒ 當不了 2.00× 對照）。
