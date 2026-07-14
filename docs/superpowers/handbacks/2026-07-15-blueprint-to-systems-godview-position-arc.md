---
from: blueprint
to: systems
status: consumed
topic: [藍圖意圖·下個主 arc] 感知腳位置 god-view=最大結構債;願景=逃得掉/躲得住/伏得成;位置走belief last-seen非god-view;解鎖逃脫/迷霧/伏擊/斥候;patch-gate-first+R²(大框可升異質框外審)
---

# 藍圖意圖：感知腳位置 god-view（下個主 arc，用戶批順序）

稽核揭最大單一結構債。用戶批「照你順序」＝god-view 位置優先。我定 WHAT，你 spec HOW。

## 願景意圖（WHAT）
**逃得掉、躲得住、伏得成——命運不看玩家臉色的位置版。**

現在（稽核 file:line 坐實）：選敵「打誰/多弱/多富」已 belief 化守鐵律，**唯獨目標「在哪」＋「追不追得上」讀活體真值**（~12 點，根 `path_system` reachability + `decision_context *_pos`）。後果：**「一旦發現過→對方現址永久零延遲零迷霧可讀」**——躲森林、繞路、斷後撤退全無效，追兵永遠精準攔截。**世界感覺全知、非有迷霧的真實世界。**

**要的**：
- **位置感知走 belief（last-seen），非 god-view**。追擊者追的是**最後看到的位置**；你斷了視線+移動→他**跟丟**（去 last-seen 搜、可能撲空）。belief 已存 last-seen 位置，**決策層改讀它、別讀活體真值**。
- **感知鐵律的位置版**——同「威脅只吃可見表象」，位置也只吃「可見/最後可見」，不吃神視角現址。

## 解鎖的戲（為什麼值最高）
- **逃脫**：弱隊斷後撤退、躲地形→甩掉追兵（現在不可能）。
- **迷霧/誤判**：追丟了→撲空→虛驚；憑舊情報攔截→撲了個空位。
- **伏擊**：藏起來（跳出對方 belief）→ 出其不意打。
- **斥候有價值**：目標追丟了→派斥候重新定位（belief 刷新）。
- **命運不看玩家臉色**：一隊躲不躲得掉，看它有沒有真斷視線，不看「系統全知」。

這是決策模型「決策對得上現實」的最大一塊 + 感知腳最後大洞（[[game-design.md §決策模型接線]] 感知腳待完成）。

## patch-gate-first + 對抗閘
- **挖到底**：~12 點逐一（哪些 `*_pos`/reachability 讀活值）→ 哪些改讀 belief last-seen、哪些是自身位置（自己不靠情報、照讀真值 OK，如 `_max_threat` 距離用自身位置）。
- **★這是大框 call（redirect 大量工作、structural、難逆）→ R② 建議升異質框外審**（[[feedback_frame_challenge]]：大框三對齊時召不同模型 reviewer refute），確認「位置 belief 化」不會誤殺該讀真值的地方（自身位置/物理判定）。

## 驗收（中性世界 + 故事 QA）
- **逃脫故事出現**：斷視線+移動的隊，追兵撲空率 > 0（現在=0，永遠攔截）。
- **belief 位置驅動**：追擊 target 讀 last-seen，視線內才刷新；追丟→�regis-est 過時→撲空可 trace。
- **不誤殺**：自身位置/物理判定照讀真值（自己不靠情報）。
- **無回歸**：determinism/憲法/sanity；HOB obey%。

## 邊界
- 只做**位置感知 belief 化**。不碰死常數/矩陣/記憶情緒腳（後續 arc）。
- 不動已 merged 的 desperation。

## 下一站
系統：patch-gate-first 盤 ~12 god-view 位置點 → spec → **R②（升異質框外審，大結構框）** → impl → measurer 中性世界（逃脫故事 + belief 位置驅動 + 不誤殺）→ QA 故事複判 → 我批 merge。
