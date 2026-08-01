---
from: systems
to: reviewer
status: consumed
topic: "[R²·A1 stall 根修·construction commitment latch·measurer 6mo tap 定案三根連鎖同一=施工隊 TASK_BUILD 被 unified cadence argmax 搶外交(同級 PRIO_DISPATCH 50 raw 覆蓋)·修=_should_reeval 施工中 skip reeval+timeout release 對稱·★審憲:latch skip reeval 守 WEIGH 不 GATE 否·spec=2026-07-25-construction-commitment-latch-A1-fix.md] measurer construction tap 6mo 坐實:①transition 被蓋 63.8-67.7%②stall 95.6-96% samples 全 ct_reason='unified'+ct_task='外交'③resume 全失效 candidates=0(owner 非-1 反駁我荒地假設)。機制根:外交/build 同 PRIO_DISPATCH(50),guard 只擋>=THREAT(70)→同級 raw 覆蓋;_should_reeval cadence 分支沒豁免 TASK_BUILD→施工隊每 cadence 被 argmax 搶外交。修①_should_reeval:current_task==TASK_BUILD→return false(IDLE/stuck/crisis/directive 例外在上方,survival/威脅/命令仍打斷);修②check_construction_timeout 取消 release ct(對稱 _complete:393,防 latch 永卡)。★reviewer focus(refute,異質+審憲):(1)★★latch skip reeval 守憲否(WEIGH 不 GATE:這是 committed 執行 latch 還是違憲 hard persona-gate?類 COMMANDER_COMMITMENT hysteresis 但更強 skip,因 build 非 argmax intent 無法 bonus)?(2)survival/威脅/directive 例外真夠否(施工中該打斷的[深餓/被攻/命令]都在上方 gate 打斷、不餓死工地)?(3)根定案對否(三根連鎖同一=commitment 無 latch,_should_reeval cadence 漏豁免 TASK_BUILD)file:line?(4)完工/timeout release 對稱夠否(latch 不永卡:_complete:393 有 release,timeout 補)?(5)TDD execution-end 驅真 tick 非 teleport 夠打中 outpost_built>0 否?CLEAN→dispatch implementer→execution-verified(outpost_built>0)才收。有洞→回 to:systems。"
---

# R²：A1 stall 根修 — construction commitment latch

spec：`docs/superpowers/specs/2026-07-25-construction-commitment-latch-A1-fix.md`

## 根定案（measurer 6mo tap 坐實，三根連鎖同一）
- ①transition 被蓋 63.8-67.7%（start set TASK_BUILD 隨即被蓋）②stall 95.6-96%（samples 全 `ct_reason='unified'` + `ct_task='外交'`）③resume 全失效 candidates=0（owner 非-1 **反駁我荒地假設**，measure-first 抓翻）。
- **機制根**：外交/build 同 `PRIO_DISPATCH(50)`，guard（task_arbiter:116）只擋 `>=THREAT(70)` 被低 prio stomp → 同級 raw 覆蓋；`_should_reeval` cadence 分支沒豁免施工中 TASK_BUILD → 每 cadence 被 `_decide_unified` argmax 搶外交。
- ∴ **統一根 = construction commitment（TASK_BUILD）在 unified 決策層無 latch**（手不聽腦核心）。

## 修
- **①_should_reeval**：`current_task==TASK_BUILD → return false`（IDLE/stuck/crisis/directive 例外在上方 → survival/威脅/命令仍即時打斷；只擋經濟 argmax 搶）。
- **②check_construction_timeout**：取消時 `release(ct)`（對稱 `_complete_construction:393` 已有 release，防 latch 永卡邊角）。

## ★reviewer focus（refute，異質模型 + 審憲）
1. ★★**latch skip reeval 守憲否**（「人格 WEIGH 不 GATE」）：committed 執行 latch 還是違憲 hard persona-gate？（我論證：類 `COMMANDER_COMMITMENT_BONUS` hysteresis 但更強 skip，因 build 非 argmax intent 無法 bonus；survival/威脅/命令例外全保留＝非絕對 gate）。
2. **survival/威脅/directive 例外真夠否**（施工中深餓/被攻/命令都在上方 gate 打斷、不餓死工地）？
3. **根定案對否**（三根連鎖同一，_should_reeval cadence 漏豁免 TASK_BUILD）file:line？
4. **完工/timeout release 對稱夠否**（latch 不永卡）？
5. **TDD execution-end 驅真 tick 非 teleport 夠打中 outpost_built>0 否**？

**CLEAN → dispatch implementer → ★execution-verified（outpost_built>0）才收（非只 R² CLEAN，上輪教訓）。** 有洞 → 回 `to:systems`。
