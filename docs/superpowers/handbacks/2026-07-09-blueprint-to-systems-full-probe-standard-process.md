---
from: blueprint
to: systems
status: consumed
topic: 流程修(用戶提)——seeded 診斷床要標準全探針對照;停逐slice客製反應式量測,一次抓全因果
---

# 流程修：全探針對照標準化（用戶親提）

## 用戶戳的病
用戶問「為啥不每個模擬都跑全探針」。根因（我認）：
- 探針**逐 slice 客製**（A2a/A2b守衛/conquest/food_ledger 各自為政），無統一「一次抓全」harness。
- ∴ 每次只量一維 → 不夠再補量 → **反應式來回**（A2c-1 這串：byte0→drive→characterize→artifact→phantom→drama→今日因果，每步都因缺某維度數據而回頭）。
- 用戶（+我）已多次戳「別理論化、先量測」。反應式量測正是理論化的溫床——沒全景數據就腦補因果。

## 方向（願景/流程 owner 你，我給意圖）
**seeded 診斷床要有標準全探針對照模式**：一次 run 抓全景、可 A/B 並排——
- 衝突面：征服 intent/宣告/成員攻擊/交戰/掠奪/血仇/背叛/外交
- 生存面：餓死/餓滅隊/pop/food_flow 分布/team size 分布
- 決策面：option 選擇分布（誰選 merge/attack/survival…）、merge-applicable 隊的實際去向
- 結構面：teams 消長/faction 消長/established
- **並排兩 branch（baseline vs slice）逐點 + 月級曲線**

一 run 產齊 → 因果一眼（如「衝突降 vs 餓死升」的方向性當場可讀，不用事後補診斷）。

## 邊界/現實
- **不是每個 sim/每 headless/live GUI 都埋**（perf：sim 已 compute-bound）。是 **seeded 診斷/驗收床**（本就要跑對照的場合）預設開全探針。那些 run 慢一點可接受，換一次看全。
- seam/實作你自決：可能是統一 `full_probe_bed.gd` + 標準 JSON schema，measurer 跑它產一份齊全 `.measure.json`，QA/blueprint 讀同一份。
- 這是**流程/tooling owner（你）的活**。我只給意圖：停反應式逐維補量，改一次抓全。入 memory [[feedback_avoid_rabbithole]] / [[feedback_structural_audit_complement]] 系族（我不寫 memory，你單寫者提煉）。

## 與 A2c-1 的關係
- A2c-1 的因果診斷（starvation-causal handback）**就是這模式的首個實例**：與其補一個 bespoke 診斷，不如用它試產「全探針 740-vs-520 對照」。若能順手立起標準模式最好；不能就先手動產這次的，事後再標準化。
- 優先序你排：A2c-1 因果診斷急（擋 shipping 定性 + 用戶等數據判）；全探針標準化可借這次立、或 A2c-1 後補。

用戶在線等「全探針對照」數據才判 A2c-1 世界。先給那份。
