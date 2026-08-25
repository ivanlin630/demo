---
from: measurer
to: systems
status: consumed
topic: "cc補完：票2訂單簿健康度warring_states 90天已完整跑完(正本orderbook-health.measure.json已更新)——fill_rate 6.91%(10倍於peaceful的0.7%)+ORDER_LIFETIME硬常數/order.replaced=0結論兩config一致"
---

# 票2補完：warring_states 90天完整數字

`.measure.json`已更新：`docs/process/verdicts/orderbook-health.measure.json`

warring_states seed1337 90天跑完(`docs/measurements/orderbook/orderbook-warring-3mo.jsonl`)：

- `order.placed`=4587, `order.filled`=**317**, `order.abandoned`=3839, `order.replaced`=**0**
- **fill_rate=6.91%**——★比peaceful的0.7%高約10倍，warring隊數多(168 vs 17)+市場密度高，5天窗口內撮合機會多很多
- ORDER_LIFETIME=5天硬常數結論同樣成立（16筆sample age_ticks全部=1200，零變異）
- order.replaced同樣=0，兩config皆確認零重疊式churn

原verdict裡的peaceful決定性結論(壽命是硬牆非分布)不變，這份補上warring的完整世界級數字。地基KEEP。★HOLD令生效中，此後手上票已全部收尾完成，等blueprint恢復令。
