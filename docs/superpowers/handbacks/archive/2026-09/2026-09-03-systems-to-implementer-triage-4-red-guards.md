---
from: systems
to: implementer
status: consumed
slice: 4 張紅守衛的【判定】—— 只判不修
topic: ★背景:docs 當守衛引用的床 19 張,只有 headless_test 在註冊表;我跑了其餘 18 張＝14 綠 4 紅;★★這 4 張沒有人判過(跟今早那 7 條 assert 同族);★★★要的只有一格:逐張判【床過期】還是【code 真壞】——不修,判完就停
---

# ★①四張（逐字，repro 都是 `.\tools\godot.ps1 --headless --script scripts/debug/<bed>.gd`）
```
seam1_registry_test        ★applicable 清單少了 "survival"（team 與 subteam 兩處都少）
unified_commerce_test      ★交易整條沒發生（訪客 material 0→0／owner coin 0→0／庫存沒扣／order 沒被吃）
observability_path_test    ★tracer on vs off 不是 byte-identical（re-query 包 suppress 不污染）
tracer_completeness_test   ★commit-fail/heartbeat entry 期望 1、實際 0
```

# ★★②每張只要一句話的判定 ＋ 一個 file:line
```
【床過期】＝床的期望值描述的是【舊世界】（例：option 改名／機制搬家）⇒ 貼出改名/搬家的那個 commit 或 file:line
【code 真壞】＝床的期望值仍然正確，而 code 不再滿足它    ⇒ 貼出不滿足的那一行
★不確定 ⇒ 寫「不確定」＋你查到哪一步（★★「不確定」是誠實第三態，不要為了給答案而挑一邊）
```

# ★★★③兩件先講死
1. ★**`seam1` 那條看起來跟你今天量的 #10／紮根同一區域** —— ★★**而我明講那是 lead 不是結論**：
   **不要用今天的結論去解釋這張床，先獨立判它**（否則兩邊互相當證據）。
2. ★**`observability_path` 那條踩的是既有紀律（觀測不得改變被觀測物）** —— ★★**但同樣可能是床過期**，判準一樣。

# ④不要做的
★**不修**（修法要看判定結果，而優先序在 blueprint 手上）。★★**不改床的期望值**（那會把警報器關掉）。
★★★**這張排在你手上兩張之後** —— 樹靜止那件事優先。
