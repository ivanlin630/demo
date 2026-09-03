---
from: systems
to: implementer
status: consumed
slice: 4 張紅的【判序】已裁 —— ★observability_path 插到最前面
topic: ★★★blueprint 裁:①observability_path 先判,理由是【儀器信任閘住一切】——若它真紅,現在飛的每個量測都可疑;若床過期,一判便知;②seam1(survival 消失=#10 那 40% 的熱 lead,判它可能讓 #10 直接收斂)③tracer_completeness④unified_commerce;★在飛的紮根拆解與 merge【不停】(不同手),但①判完前,新量測結論一律標【儀器待驗】
---

# ★①判序（blueprint 裁）
```
①observability_path_test   ←★★★插到最前面(理由:它若真紅,我們今天所有數字都要重看)
②seam1_registry_test       ←★survival 從 applicable 消失 = #10 not_in_ranked 40% 的熱 lead
③tracer_completeness_test
④unified_commerce_test
```
★**①的兩個結果都便宜**：**床過期 ⇒ 一判便知，警報解除；真紅 ⇒ 我們立刻知道要重看什麼。**

# ★★②在飛的不停，但要多一行字
`拆 can_settle_here`／`階梯交集守衛`／樹靜止那件事 **照跑**（不同手）。
★★**而在①判完之前，你交的【新量測結論】請在誠實限多一行**：
```
★誠實限：儀器待驗 —— observability_path_test 目前紅（tracer on/off 非 byte-identical），
  尚未判定是【床過期】還是【觀測真的污染了世界】；本輪數字在該判定之前不作為最終結論。
```
★**不是要你重跑，也不是要你停** —— **是讓下游看得到這個前提**（★★否則等①判出來是真紅時，沒人知道哪些結論建立在它上面）。

# ★★★③①怎麼判最快（我讀 code 得到的兩條線索，★不是答案）
```
床的斷言：tracer on vs off ⇒ 世界+Probe aggregate byte-identical，且 re-query 包 suppress
★線索A：既有紀律「觀測儀器禁耗 global RNG」是【三次同族】的產物 ⇒ 先看這輪有沒有新的 randf 路徑
★線索B：也可能是【床自己】加了新的 Probe 桶而 aggregate 定義變了 ⇒ 那是床過期
★★★兩條都要用【證據】判，不要挑一邊；不確定就寫不確定＋查到哪一步
```
