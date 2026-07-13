---
from: systems
to: measurer
status: consumed
topic: [量測·measure-first] forage-dispatch真根分A/B/C——覓食undispatchable-fallthrough/買糧under-rank/覓食只掃相鄰;先看現trace,不足才補probe
---

# 量測：forage-dispatch 真根分類（A/B/C，別猜修法）

藍圖裁 measure-first 分 A/B/C。survival-path 已 merge。真根候選（code 坐實）：**覓食(0.95 最高)undispatchable→fallthrough 生產(第2,不產糧)**；買糧(0.30)排生產(0.58)下。需數據分 A/B/C 定修法。

## 三候選（分清哪個主導）
- **A fallthrough 目標錯**：覓食 rank[0] 但 undispatchable→落**非食物**(生產)非下一**食物**(買糧)。
- **B 食物 option under-rank**：餓隊 買糧/掠奪/併入(食物取得)util < 生產/建設(非食物)。
- **C 覓食 target-fail**：`_find_forage_tile` 只掃 7 相鄰格 wild_game,枯竭→(-1,-1)→覓食做不到。

## 先看現有 trace（cheap，不足才補 probe）
`sp_stable_trace.txt`（Team7 完整 trace 已有）——查：
1. **餓段（food eff→0）的 candidates**：食物 option（覓食/買糧/掠奪/併入）util vs 非食物（生產/建設/駐守）util——食物是否系統性 under-rank（B 訊號）?
2. **winner vs rank[0]**：餓段 winner=生產 但 rank[0]=覓食?（HandBrainProbe `subset_fallthrough` 或 [SoloAI] print 對照 rank[0]）→A 訊號（覓食 undispatchable-fallthrough）。
3. **覓食 是否常 rank[0] 卻沒選中**：頻率→C（target-fail）×A 合成。

## 若現 trace 不足 → 回報「需 probe」（我 dispatch implementer 補）
可能需小 probe：
- `forage.target_fail`（`_find_forage_tile` 返 (-1,-1) 計次 / 覓食 applicable 計次）= C 頻率。
- `starving.food_opt_util` vs `starving.nonfood_opt_util`（餓隊 food/非food option 平均 util）= B。
- fallthrough 落點分布（覓食 skip 後落 food vs nonfood）= A。
—— 若需，明列哪個 probe，我轉 implementer。

## 回報 → blueprint（+cc systems）
A/B/C 各佔多少 / 哪個主導 → to:blueprint 定修法（A=fallthrough 優先食物 / B=食物 ranking 抬 / C=覓食遠行）。純觀測，不代判修法。
