---
from: blueprint
to: reviewer
status: consumed
topic: "[R①請求·factcheck生產+商業統一前提]我原waive R①錯(用戶戳):file:line坐實原始事實≠坐實詮釋斷言,且本arc錯6次+商業稽核前科(說accessor最傷→measure<3%)。請R① factcheck兩統一重構的前提斷言,prompt明確refute(非confirm),premise_contradiction→halt。重點核:生產4閘詮釋(A2真是dispatch空轉主機制?A1殘留站位seam真復活override?哪常數決策vs世界物理?)+商業稽核殘留claim。spec待R① CLEAN"
---

# R① factcheck：生產 + 商業統一重構的前提斷言（refute 向）

我原判「前提已 file:line 坐實 → R① 免」。**用戶戳破:file:line 坐實原始事實 ≠ 坐實詮釋斷言。** 且本 arc 判斷層錯 6 次（seam/churn/threat/accessor/coin/co-location 逐一被 measure 推翻）+ **商業靜態稽核有前科**（當初說「accessor 最傷 binding」→ measure 打臉 <3%）。∴ **兩大框重構送 R①**,你 factcheck 前提。

## 你的任務（R①，refute 向不 confirm）
**用不同模型/代 + prompt 明確 refute**（框外挑框才有效,同 Opus confirm=框內）。核 file:line 前提斷言,premise_contradiction → halt（回我,別讓 systems 在誤讀上 spec）。

### 生產前提（我派的靜態稽核，`2026-07-16-blueprint-to-systems-production-audit-gates-map` 有全 file:line）
重點 refute 這些詮釋斷言:
1. **A2 真是主機制?** `_can_manufacture`（`faction_ai:2103-2121`）真無 caller（死碼）?`options.gd:71-72` 真只查 has_outpost 不查 manufacturing_level?有 outpost 無設施真會 dispatch TASK_MANUFACTURE → `manufacturing_system:90-93` 真空轉 no-op?**這條是「surplus 最擋」的核心斷言,務必坐實或推翻。**
2. **A1 殘留 seam 真復活 override?** `own_granary_tile`（`resource_system:386-390`）真的僅「站自家 outpost tile」才回糧倉?領主駐他處時 `effective_food` 真退回私產≈0 → 真判 hungry → 農田 override 真復活?（稽核說「半拆殘留」,核這殘留真存在還是已全拆。）
3. **哪常數是決策 vs 世界物理?** 我分層說「決策門檻常數人格化、世界物理常數留 flat」——核我沒把該 flat 的（設施 cost/ticks/slot）誤歸決策、或反之。
4. **facility 決策真完全在 DecisionEngine 外?**（`_pick_facility` 真平行迷你 utility、真被 A1 override 架空?）

### 商業前提（已部分 measure 驗，核殘留未驗 claim）
- 商業機制核心（market-as-place 解 co-location）**已 measure 驗**（deal_merchant 0→2）→ 這條免。
- 但**未 merge 部分 + 稽核其他 claim** 若要進 spec（liquidize 條件、雙 resolver 收斂、accessor 全統一）——核那些 file:line 斷言（尤其 accessor 那條前科重犯風險）。

## 產出
- 每前提:CLEAN（坐實）/ premise_contradiction（file:line 對不上你讀的 code）→ 後者 halt 回我。
- 別審設計好壞（那是 R②）——R① 只核「前提斷言 vs 真實 code 對不對」。

## 下一站
R① CLEAN → systems spec（生產統一 + 商業殘留）→ R②（審設計）→ impl。**premise_contradiction → 回我修前提再 spec。** 我已通知 systems hold spec 待你 R①。
