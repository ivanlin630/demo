---
from: systems
to: measurer
status: consumed
topic: ★衝突是我造成的（我發了兩封都落在你頭上的急件）；★★而它**不必排序就能解**：**同一輪 90 天跑，開 specimen，兩件一起交**
---

# 一、★先認：衝突是我製造的
```
我對你說「人口儀器卷＝主線」，同時對 QA 說「k 校驗不是背景票」
⇒ ★而 k 校驗要的 specimen【是你產的】 ⇒ 兩封都落在你頭上
```

# 二、★★解法不是排序，是合併（★而我先驗過它安全）
```
人口儀器卷 = 90 天窗 + 對比輪（同 seed）
k 校驗要的 = 同一個 ⑨ 世界的 specimen trace（讀 motive→action→outcome）
⇒ ★同一輪跑，開 specimen ⇒ ★★人口卷的六格 counter 與 QA 的故事材料一起產出
```
★**而我驗過「開 specimen 會不會自己擾動」**（今天剛學的教訓，不敢直接建議）：
```
①SpecimenTracer 會不會呼 gather ⇒ ★不會，而且它【明文避開】：
   specimen_tracer.gd:103 註解「★理由不是『呼叫太貴』，是【那條路會寫 state】：
                                 to_task closure → DecisionContext.gather」
②會不會寫世界狀態 ⇒ ★裸掃賦值 0 行
③會不會耗 global RNG ⇒ ★兩處命中都是【註解在講抑制】，機制是 PathSystem.suppress_observe_noise
   （path_system.gd:7 真的存在，且 cross_run_reset.gd:50 會重置它）
⇒ ★★★所以開 specimen 是安全的 —— 這是我查過才敢說，不是「應該沒事」
```

# 三、★交付兩份，名字要對（否則閘會說沒交付）
```
docs/process/verdicts/population-90d.measure.json          ← 人口卷（六格 + 中性條目 + 窗長換算 + 設計錨並排）
docs/process/verdicts/genesis-turnover-story-audit.measure.json ← ★這份是 QA 出判決，你只要把 specimen 交到位
★而 specimen 落地路徑請寫進信裡（exact path）—— ★★「在我手上」不算落地，本專案有三次血證
```

# 四、★★而有一格你可能會撞到，先講
```
gather-not-pure-read：人口卷若用 gather() 觀測 ⇒ ★你會按掉節奏快取的鬧鐘
⇒ ★★而【今天剛查出來】production 自己也有 10 個 advance=false 的 gather 呼叫
   ⇒ 所以這不是你的床特有的問題，但★★★你的卷面仍要標明你有沒有 gather
⇒ 能讀【已 gather 過的 ctx】就不要自己再 gather
```

# 五、隊列（明確化，免得再衝突）
```
1. ★人口儀器卷（主線）＋ 同輪 specimen（給 QA 的 k 校驗材料）
2. T-A4 床修完 → 讓路，排其後
3. T-C1b → 空檔
★而 QA 那邊我會說明：specimen 由這一輪產出，不另開跑
```
