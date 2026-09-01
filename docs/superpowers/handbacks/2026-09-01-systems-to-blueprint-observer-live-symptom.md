---
from: systems
to: blueprint
status: open
slice: read-write-safety
topic: ★★★掃到【現症】而不是潛雷:specimen_tracer:107 → to_task → gather → 寫 state(EWMA 推進+cache 寫+★cadence 重排);★★而 tracer 就是【QA 讀故事的那支工具】⇒ 觀測正在改世界,而 QA 的判決建在上面;★★★另外:tracer 自己有一層保護(:87 _begin_observe 自述 suppress RNG+Probe)而它【擋不住 state 寫入】—— known_issues:653 那句「抑制清單＝易漏的黑名單」拿到第一個實證,且漏的就是最重要的那一項
---

# ★①現症
```
specimen_tracer.gd:107 → to_task → gather → ★寫 state
gather 的三項副作用：EWMA 推進 ／ cache 寫 ／ ★★cadence 重排
★★★而 specimen tracer 是【QA 讀 motive→action→outcome 故事】用的那支工具
```
★**用戶立過法**：**觀測不得改變被觀測物**（`observer_no_global_rng`）——
★★**而這一例比「耗 RNG」更重：它直接寫 state。**

# ★★②那層保護擋不住它 —— **而這是黑名單的第一個實證**
```
specimen_tracer.gd:87  _begin_observe 自述：suppress RNG ＋ suppress Probe
⇒ ★它【沒有】suppress state 寫入
⇒ ★★known_issues:653 早就寫「抑制清單＝易漏的黑名單，優先拆 pure-read」
   —— ★★★本輪拿到第一個實證，而漏掉的就是【最重要的那一項】
```
★**這條之所以值得單獨講**：★★**保護存在，讓人以為問題被處理了** ——
★★★**而它擋的是兩個小的，漏的是那個大的。**

# ★★★③要你裁的：**這是否影響過去的判決**
```
★工作流硬規則是「長跑必附 specimen trace → 送 QA 故事稽核，才可下 behavior 因果結論」
⇒ ★★所以【每一個經過 QA 故事稽核的 behavior 結論】,都可能是在【被觀測改過的世界】上下的
⇒ ★★★而我【不知道規模】—— 已派 measurer 量：開/不開 tracer，同 seed，fp 是否逐位元相同
   （★我預期會不同，因為 cadence 重排會改「誰在哪個 tick 被評估」—— ★★但那是預期不是結論）
```
## ★要你排的
```
①★等 fp 那支回來再裁（★★一輪，便宜）—— 我建議這個
②★★現在就把讀寫分離插隊到重錨前（★成本是動 gather 的三條線）
③只標記不修 ⇒ ★★★我判它不夠：保護已經存在且已經漏了，再加一層標記不會改變什麼
```
★**我建議①**：★★**因為「要不要插隊」取決於規模，而規模一輪就能知道。**

# ★④另外兩顆是潛雷（附回訪條件，照新規矩）
★**而 implementer 標了一句我要點名的**：**UI observer 系零命中，但【那是還沒踩到，不是踩不到】。**
