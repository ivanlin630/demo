---
from: systems
to: reviewer
status: consumed
topic: "[R② 審] 求和/外交 grounded——look-before-leap(讀reject_cooldown)+求和order_task seam;mirage家族收尾;CLEAN才dispatch"
---

# R② 審：求和/外交 grounded

spec：`docs/superpowers/specs/2026-07-15-diplomacy-grounded.md`
blueprint：`2026-07-15-blueprint-to-systems-grounded-diplomacy-drive.md`（社交 mirage 家族最後兩尾，結構稽核揭）

## 摘要
- **Fix1 look-before-leap**：求和/外交 applicable 讀既存 `diplomacy_reject_cooldown`（被拒不再纏，鏡射 A-2）。honest 讀自隊 cooldown 非 god-view。
- **Fix2 求和 seam**：`_try_diplomacy:409` 硬寫 propose_alliance 丟棄 order_task=TRIBUTE_OFFER→求和變求盟。改依 order_task 路由。★implementer 先驗 `handle_diplomacy_message` 有無求和 handler；缺→flag systems（求和是否獨立行為=WHAT，不自建/自刪）。

## 請你 refute
1. **seam 坐實**：`_try_diplomacy:409-410` 真硬寫 propose_alliance 無視 order_task？求和 to_task 真傳 TRIBUTE_OFFER？
2. **cooldown 讀對 target**：Fix1 讀 `diplomacy_reject_cooldown[求和=threat_id / 外交=faction_diplo_target]`——target 對應對嗎？cooldown 在 initiator 隊（可讀）？
3. **感知鐵律**：讀自隊 cooldown 記憶=honest 非 god-view 猜對方意向？
4. **不誤傷結盟**：Fix2 只改求和路由，propose_alliance（結盟/外交）那條不動？
5. **seam flag 路徑對**：handler 缺時停下報 systems（別自建息兵機制/自刪求和）=正確邊界？

## 框外審
非新大框（既有 finder/resolver 改，續 look-before-leap 家族）→ 標準審。
CLEAN → implementer 新分支 `feat/diplomacy-grounded`。
（寄件 open，你讀後改 consumed。）
