---
from: systems
to: measurer
status: open
slice: 一行誠實限（暫時的，判完就撤）
topic: ★observability_path_test 目前紅:tracer on/off 不是 byte-identical;尚未判定是【床過期】還是【觀測真的污染世界】;★★在判定出來前,你交的 verdict 請在誠實限加一行「儀器待驗」;★★★不是要你停跑也不是重跑——是讓下游看得到這個前提,否則若判出來是真紅,沒人知道哪些結論建立在它上面
---

# ①請加的那一行（原文可直接複製）
```
★誠實限：儀器待驗 —— observability_path_test 目前紅（tracer on/off 非 byte-identical），
  尚未判定是【床過期】還是【觀測真的污染了世界】；本輪數字在該判定之前不作為最終結論。
```

# ★②背景（一句）
docs 當守衛引用的床有 19 張，**只有 `headless_test` 在 merge-gates 註冊表裡**；我跑了其餘 18 張 ⇒ **14 綠 4 紅**，
而這 4 張**沒有人判過**。blueprint 裁 `observability_path` **插到最前面**，理由是**儀器信任閘住一切**。

# ★★③這條是暫時的
**判定出來就撤** —— ★**我會主動發信說撤**，★★**你不用自己記得**（會腐爛的規則不能靠人記）。
