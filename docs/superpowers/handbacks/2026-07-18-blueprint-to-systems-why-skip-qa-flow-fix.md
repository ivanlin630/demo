---
from: blueprint
to: systems
status: consumed
topic: "[流程問責·為何跳QA + 修flow] 用戶戳:threat-oracle 3輪全走 measurer數字→藍圖,跳過QA故事稽核。你是flow owner,交代為何跳(QA session沒開?release-gate砍後習慣沒重接?趕?)+修。★用戶關鍵:單seed也要給QA——QA故事稽核≠multi-seed,兩條不同軸:multi-seed驗『普不普適(跨世界)』,QA驗『故事對不對(隊在演啥)』。單一seed的trace就足以看穿餓死vs戰死,不必等multi-seed。∴跳QA=連單seed的故事都沒人讀。修:canonical鏈量測→QA故事稽核→藍圖不可跳,QA沒開=flag blocker非跳過藉口,入process doc+memory。"
---

# 流程問責：為何跳 QA + 修 flow

用戶戳出的：threat-oracle attrition 3 輪全走 **measurer 數字 → 藍圖，跳過 QA 故事稽核**。你是 flow owner（`docs/process/*` + dispatch），請交代 + 修。

## 要你交代（為何跳）
canonical 鏈明寫 **量測員 → QA 故事稽核 → 藍圖**（`00_roles 接力流向` + `04_qa §第五職`，2026-07-14 加回）。這 3 輪為何跳？誠實查：
- QA session 沒開，沒人可 route → 就默默 measurer→藍圖？
- 2026-07-09 砍 QA release-gate 後，習慣性 measurer→藍圖，2026-07-14 加回故事稽核**沒重接進 dispatch flow**？
- 趕著收 loop？

（非指責——三度打臉部分根就是這個跳，找到才修得掉。）

## ★用戶關鍵洞見：單 seed 也要給 QA
**QA 故事稽核 ≠ multi-seed，是兩條不同的軸：**
- **multi-seed** 驗「**普不普適**」（跨世界一致否）。
- **QA 故事稽核** 驗「**故事對不對**」（隊到底在演什麼：餓死 vs 戰死、有沒 fire 絕境出路）。
- **單一 seed 的 trace 就足以看穿故事**（seed42 一顆的 trace 就能讀出「隊傻站餓死」）——**不必等 multi-seed 才給 QA**。
- ∴ **跳 QA = 連單 seed 的故事都沒人讀** → 只剩聚合數字，而數字分不出戰死/餓死 → 我順著系統的故事下結論 → 打臉。

**兩軸都要，且時機不同：** 任何 seed 一跑完 dump → **QA 讀故事**（單 seed 即可）；宣「修好/普適」→ **multi-seed**。別再只有數字這一條。

## 要你修（flow + durable）
1. **canonical 鏈不可跳 QA**：量測→QA 故事稽核→藍圖，**單 seed 也走**。dispatch flow 重接（2026-07-14 加回的故事稽核明確進 pipeline，非只寫在 doc）。
2. **QA session 沒開 = flag blocker**，不是「跳過的藉口」。沒 QA 就報，別默默 measurer→藍圖。
3. **入 memory（你單寫者）**：驗收兩軸——multi-seed(普適) + QA故事稽核(故事對)，**單 seed 也要 QA**；跳任一 = 缺陷。併我剛送的 [[multi-seed-before-claiming]] 那條，合成完整驗收紀律。

## 溯源
用戶 2026-07-18「問01工作流為啥跳qa,單seed也要給qa」；`00_roles 接力流向`(量測→QA→藍圖);`04_qa §第五職`;我 to:qa story-check-seed1337(已 route QA 讀 trace)。
