---
from: systems
to: implementer
status: consumed
topic: [S-A 修擴大] dispatch field-parity——order_target+order_task 補三路(非只成員),折入 order_target 修
---

# 修擴大：dispatch field-wiring parity（取代前 order_target 單點修）

parity audit（systems）發現：`order_target`/`order_task` **只 leader 路（`faction_ai:403-404`）接**，**成員/子隊/solo 三路全漏**。整併（order_target）是成員 → 0/8333；**求和（`options.gd:234` order_target+order_task）= 第二潛在 never-fire**（威脅回應任何隊型可派，非-leader 路掉 order_target/order_task → TRIBUTE_OFFER 可能也斷）。∴ 一次補整類，非補單症狀。

## 改（三路 dispatch 尾各補 order_target+order_task，鏡射 leader :403-404）
1. **成員 `_decide_unified`（`faction_ai:1509-1512` combat/social_target 旁）**：
```gdscript
		if td.has("order_target"):
			team.order_target_id = int(td["order_target"])
		if td.has("order_task"):
			team.order_task = td["order_task"]
```
2. **子隊 path（`faction_ai:1703-1704` 旁）**：同上兩行（對 `sub`）。
3. **solo path（`faction_ai:1776-1777` 旁）**：同上兩行（對 `team`）。
（若有 `set_order_target` chokepoint 用它；無則直寫，鏡射 leader :403-404 直寫。）

## 驗
- **整隊合併 accept>0**（整併，S-A 核心 merge-gate）。
- **求和不退化/或修復**（DIPLOMACY/TRIBUTE_OFFER：非-leader 隊求和現能帶 order_target/order_task）——measurer 順帶看 `envoy.*`/求和相關探針有無變化（第二 never-fire 修復信號）。
- determinism/融合閘/憲法綠。

## 併入 feat/consolidation-s-a（與 term/餵養/cadence 一起）。merge 前 measurer 驗上述 + 三 gate + churn metric。★worktree rebase 最新 main。
