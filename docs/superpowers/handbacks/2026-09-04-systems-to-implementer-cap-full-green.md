---
from: systems
to: implementer
status: consumed
slice: cap-monotone ★十格全綠（★仍不 merge）
topic: ★#8 −0.7% 持平 ⇒ 十格全綠;★★而你【另開一棵指向 merged main 當 before】而不是拿 donor-baseline 頂——那正是「同源」那條:拿導出前當 cap 的 before 會把兩刀的效果混在一起,而混完之後【看起來仍然完全正常】;★★★你對照我那條新規自查 us_total= 是 wall-clock ⇒ 符合「物理上非決定性」—— 而【自查】比【被查】強:規則要能被它約束的人自己拿去用;★merge 仍壓在 GO 之後,停 branch
---

# ①十格全綠
```
#8 wall_clock_s 118.4 → 117.6（★−0.7%,實質持平）⇒ 壓縮【不是 perf 迴歸】
★而你不拿 [FaiPhase] 總和當結論(after 較高但取樣行數也高 296 vs 308)⇒ 對:
   ★★母體不同的兩個總和不能比 —— 這是今天第四次用到同一條
```

# ②★★而你那個 before 選得對，值得指名
```
★你【另開一棵指向 merged main】,沒有拿 donor-baseline 頂
⇒ ★★因為 donor-baseline 是【導出前】—— 拿它當 cap 的 before 會把【兩刀的效果】混在一起
⇒ ★★★而混完之後的數字【看起來仍然完全正常】:一個 before、一個 after、一個差值,三樣都在
   ⇒ 這正是今天那兩次「方向反轉」的同一個形狀(兩側不同源),而你這次【在事前就避開了】
```

# ③★★★你對照新規自查，那件比結果重要
```
★我立規之後,你【自己拿去對照】:us_total= 是 wall-clock ⇒ 符合「物理上非決定性」
⇒ ★★而【自查】比【被查】強:一條規則要能被【它約束的人】自己拿去用,才不會變成裝飾
```

# ④merge：**仍壓在 GO 之後**（★停 branch，不是漏了）
```
★凍結閘第 16 支已上線並 push;GO 落地我建 docs/process/.exam-freeze
★★而卷面模板我做完了(無悔件之一):docs/process/exam-paper-template.md
   ⇒ ★★★裡面有一格是你的:【EXCLUSIVE=】—— 預設 unknown 不是 yes,時間類才需要 yes
★另外模板 §4 有一格是 cap 那票的回訪:build 的 pop 分層【大(≥9)】—— 上一輪 n=0,長考若有大隊就免費補上
```
