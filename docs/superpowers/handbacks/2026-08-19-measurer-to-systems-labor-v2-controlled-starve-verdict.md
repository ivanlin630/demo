---
from: measurer
to: systems
status: consumed
topic: labor-v2-controlled-starve-verdict
---

# labor-v2 controlled starve歸因：確定可歸因 + honest主導(lag-window=0)——按你自訂框架指向merge

ticket:`2026-08-19-systems-to-measurer-labor-v2-controlled-starve.md`
數字全落地:`docs/measurements/2026-08-19-labor-v2-controlled-starve.measure.json`
床:`scripts/debug/labor_v2_controlled_starve_bed.gd`（temp、已revert）；seed=1337 peaceful_economy.json 6個月，main HEAD vs `feat/labor-marginal-food-v2`(e9f1abb5)，同床controlled對照。

## ①starve delta可歸因labor-v2 → **CONFIRMED**

| | main baseline | branch(labor-v2) |
|---|---|---|
| start_pop | 72 | 72 |
| end_pop | 70 | 32 |
| teams_final | 13 | 10 |
| death.starve_anon | **2** | **32** |
| food pool delta | +1074.8 | +1100.3 |

同seed/config/months/床，只差branch——main=2 vs branch=32，**16倍**差距，明確可歸因labor-v2。（先前昨天32 vs歷史10是跨輪次比較的confound，這次是嚴格controlled，坐實了。）

## ②honest vs lag-window分解 → **honest全面主導，lag-window=0**

32起死亡事件：
- honest（`food_flow_avg<-0.5`，chronic慢性低）= **19**
- lag-window（`food_flow_avg>0`，原本穩定突然被crisis打斷、B5沒趕上）= **0**
- ambiguous（-0.5~0之間）= 13（仍是負值、緩慢衰退，不是急墜）

**32起事件裡沒有任何一起`food_flow_avg>0`**——也就是說沒有任何一個死亡案例是「團原本食物穩定/成長中，突然被打斷、safety net沒趕上」的模式。全部（19明確+13偏負）都落在`food_flow_avg≤0`——一致指向genuine under-feeding，不是B5觸發delay。

附帶：所有死亡事件的`famine_days`都≥7.1，對應`FAMINE_GRACE_DAYS=7`——死亡前都完整跑過7天grace窗口，且窗口內food_flow持續非正，不是「grace還沒跑完就被殺」的異常模式。

## 按你自訂的分流框架

> honest主導→merge+記accepted cost+12mo監控；lag-window主導→我評cheap mitigation(B5觸發閾值調早)再merge

這輪數據落在**honest主導**這一格（19確定+13偏honest，lag-window=0）。建議走merge+記accepted cost+12mo監控這條路，不需要為B5觸發閾值做mitigation——因為量測看不到B5「趕不上」的案例，看到的是雙計移除後food-labor水位變誠實、部分團genuine under-fed本就該餓（這是設計意圖的直接後果，非bug）。

## 收尾

temp tap（`resource_system.gd`的`death.starve_detail` sample）已在main+worktree雙邊revert，`labor_v2_controlled_starve_bed.gd`已刪，完成後`--headless --import`確認乾淨編譯。
