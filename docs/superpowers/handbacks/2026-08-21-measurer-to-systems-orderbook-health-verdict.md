---
from: measurer
to: systems
status: open
topic: "★票2 verdict(peaceful完整90天,warring進行中)：訂單簿健康度——★★決定性:壽命不是分布是硬常數牆(ORDER_LIFETIME=5天,order_system.gd:3),成交率0.7%,churn=0(order.replaced全期0次)"
---

# ★票2 verdict：訂單簿健康度(peaceful完整90天★決定性、warring進行中)

`.measure.json`：`docs/process/verdicts/orderbook-health.measure.json`

## 世界級數字(peaceful_economy, seed1337, 90天完整)

- `order.placed`=1001, `order.filled`=**7**, `order.abandoned`=945, `order.replaced`=**0**
- **成交率=0.7%(7/1001)**，abandon率=94.4%，run結束時還開著未到期=4.9%
- **重掛churn率=0%**（`order.replaced`全期0次，硬證據非估計）

## ★★決定性發現：「壽命」不是分布，是硬常數牆

`order_system.gd:3`：`const ORDER_LIFETIME: int = 5 * WorldState.TICKS_PER_DAY`（=1200 ticks，寫死5天，下單當下`expire_tick`就固定`current_tick+ORDER_LIFETIME`，非隨市場條件變動）。

`order.abandoned.sample`(16筆cap樣本，跨不同order_id/team/res/kind)逐一驗證：**age_ticks全部=1200，零變異**。這不是「平均壽命/年齡分布」，是每張被abandon的單100%活滿整整5天才被砍——你要的item①答案本質上退化成單點常數，唯一還有變異空間的是那7張filled單的實際成交時點(<5天，但這輪沒有per-order sample記錄各自成交tick，只有count)。

**這解釋了低成交率**：不是市場撮合機制弱，是每張單只有5天窗口就被砍，5天內沒撮合到=強制abandon，跟撮合演算法本身好壞是兩件事——若要提升成交率，直接槓桿點可能是這個5天常數本身（是否夠長讓市場自然撮合），而非撮合邏輯。這是HOW判斷交你。

## warring_states狀態

還在跑(day10/90為止，warring每tick成本隨N成長快，90天可能要數小時以上)。ORDER_LIFETIME=5天是全域硬常數不分config，「壽命非分布/是硬牆」這個結構性結論不會因warring變——會變的是fill_rate/abandon_rate的具體數字。跑完後另補handback，或你判斷peaceful這份決定性數字夠不夠先用。

## 交你裁

用戶追問的舊懸案，這份是世界級數字非specimen近似。要不要繼續等warring補齊，還是peaceful這份已經夠回答。地基KEEP。
