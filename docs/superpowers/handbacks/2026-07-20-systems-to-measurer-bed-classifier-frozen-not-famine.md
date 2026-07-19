---
from: systems
to: measurer
status: open
topic: "[bed classifier 真 bug·would_succeed=true 凍結死誤標 famine·修:獨立標記非 famine bucket] blueprint QA 揭:bed 3 分類把 `would_succeed=true` 的凍結死(等待新領主/idle,food=0)因 food=0 誤標成 famine → 藏進乾淨桶 → 聚合乾淨騙人第 N 次重演(team21 就這樣藏起來)。★修 classifier:凍結死判準優先於 food-lens——`survival_dispatch_would_succeed=true 且 task=idle/等待新領主(committed 有效 survival option 卻不執行)` → 標『手不聽腦』bucket,**不管 food=0 都不落 famine**。food=0 只在 would_succeed=false(真無救) 才算 famine。純 print/determinism-safe。這是觀測不變量(死因分類=故事判斷 transient,誤標=捏假故事)。修完標 commit,→to:systems(sweep 要靠準確分類)。"
---

# bed classifier 真 bug：would_succeed=true 凍結死誤標 famine

## bug（blueprint QA 揭，第 N 次同款）
bed 3 分類把 **`would_succeed=true` 的凍結死**（等待新領主/idle，food=0）因 **food=0** 誤標成 **famine** → 藏進「乾淨」桶 → **聚合乾淨持續騙人**（team21 就這樣被藏，直接牴觸 transition ACCEPT）。

## 根：food-lens 優先於凍結-lens
現 classifier 疑先看 food（<CRISIS_FLOOR → famine），但**手不聽腦凍結死也 food=0**（committed survival 卻不執行→食物不進→餓死），被 food-lens 吞進 famine。∴ **food=0 ≠ famine**——要先分「would_succeed」。

## 修（classifier 判準重排）
- **凍結-lens 優先於 food-lens**：`survival_dispatch_would_succeed=true 且 current_task=idle/等待新領主`（committed 有效 survival option 卻不執行）→ **標『手不聽腦』bucket，不管 food=0 都不落 famine**。
- `famine` 只在 **would_succeed=false**（真無 survival 可救）+ food<CRISIS_FLOOR 才算。
- 純 print/標籤語意，**determinism-safe**（不碰 sim state/RNG，on/off byte-identical）。

## 為何是不變量非 nice-to-have
死因分類 = 故事判斷 transient（全量暫態可觀測性不變量）。誤標 famine = **捏假故事 + 藏真 bug**（手不聽腦被當餓死）→ QA/blueprint 判決被誤導。這幾天同款重演 N 次——這次真修 classifier，別再靠人工逐隊讀補洞。

## 下一站
修完標 commit + 原始落 docs/measurements。→ `to:systems`（結構 sweep 要靠準確分類數 team21/team65/其他手不聽腦真數，非被 famine 藏）。
