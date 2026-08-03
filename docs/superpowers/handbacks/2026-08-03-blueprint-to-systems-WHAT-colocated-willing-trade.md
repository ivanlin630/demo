---
from: blueprint
to: systems
status: consumed
topic: "[用戶WHAT定調(交易面):任兩個同格、雙方都想交易→就能成交(用各自持有team.resources,非只屋主public_storage公庫)·守感知鐵律(同格=物理在場零god-view)·現model market-at-outpost取代舊pairwise=太窄(只owner+只公庫)·此=恢復pairwise一般性·★高槓桿:隊本就常同格(居民/訪客/子隊擠同outpost)→同格願意即交易可能不靠convoy就unstall一大塊(426掛單同格能配的立即fulfill)·但measure-first別pre-conclude全解:同格此原則解/隔格仍需convoy·訊息湊·∴=交易面fix正確方向(broaden surface),診斷確認unstall多少+convoy·訊息root還缺啥·★你查證:當初為何併掉pairwise(別重引已解問題如O(N²);但同格有tile→teams索引=bounded便宜)·fold進root修:root診斷含『同格願意即交易unstall多少』·地基KEEP·仍root先於全面fix"
---

# 用戶 WHAT 定調（交易面）：同格雙方願意即可交易

## WHAT（genuine、守憲）
> **任兩個同格（同 tile）、雙方都想交易 → 就能成交**。貨源 = **任一方的任何持有**（公庫 `public_storage` / 團庫 `team.resources` / 私庫——**任何 store 皆可**），**不看 store 種類、只看「願不願意」**（交易是**方對方**、非「庫對庫」）。**守感知鐵律**（同格=物理在場、零 god-view）。
>
> ★**但「願意」≠ 全賣**：只賣**真剩餘 = 持有 − keep-line**，且 **keep-line 含戰略儲備**（need_keep 求生 + **前瞻/戰略 reserve**：戰前囤武器、荒前囤糧、計畫要蓋的料）。**該留的留住、含戰略用**——不賣掉戰爭家底。willingness gate = `持有 − keep-line(含戰略) > 0`。★genuine（戰略 reserve = 真前瞻 need 按真條件算，非 arbitrary 囤積 crank）。接 [[labor-pool full-stop]] 那條「reserve target = genuine anticipatory need 非 floor」completeness item。

現 model `market-at-outpost` 取代舊 pairwise（`interaction:742` 註）= 太窄（只 owner + 只公庫）。此 = **恢復 pairwise 一般性**。

## ★高槓桿（可能不靠 convoy 先 unstall 一大塊）
隊本就常同格（居民/訪客/子隊擠同 outpost）→ **同格願意即交易 → 426 掛單裡同格能配的立即 fulfill**、不必等 convoy 搬。

## measure-first（別 pre-conclude 全解）
- **同格的** → 此原則直接解。
- **隔格的**（買賣不同格）→ 仍需 convoy/訊息湊 → convoy=0 root 照查。
- ∴ 此 = **交易面 fix 正確方向（broaden surface）**；診斷確認 unstall 多少 + convoy/訊息 root 還缺啥。

## ★你查證（別重引已解問題）
- **當初為何併掉 pairwise**（perf? O(N²) meeting?）→ 別重引；但「**同格**」有 `tile→teams` 索引 = bounded、便宜（非全域配對）。
- fold 進 root 診斷：含「**同格願意即交易能 unstall 多少**」這一量。

地基 KEEP。**仍 root 先於全面 fix**（此 WHAT 是交易面方向、非宣布 root）。診斷回我含此維 → 設計真 fix。
