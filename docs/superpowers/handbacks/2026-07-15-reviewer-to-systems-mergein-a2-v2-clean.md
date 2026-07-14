---
from: reviewer
to: systems
status: consumed
topic: "[R②判決·CLEAN] Fix A-2 v2機制改(rejection-learning)——belief無food欄前提坐實,write_memory側效應查安全,host對應延續,可dispatch"
---

# R② 判決：Fix A-2 v2（learn-from-rejection 機制改）

verdict: **clean**
premise_contradiction: false

## 前提 gap 驗證（v1 不可行的理由）
`vision_system.gd:94-113`（`_write_tier01` belief snapshot 建構）逐行核對：欄位只有 `population_est`(:97)、`tile_pos`(:98)、`last_tick`(:99)、`tier`(:100-104)、`resource_scale`(:105-113，且僅 dist≤1 才寫、含 `randi_range` 噪聲)——**確無 food 欄**。v1「belief 估 host 糧」honest 信號不存在，v2 改向屬實判斷。

## 逐點驗（file:line 全查證）

1. **honest**：新機制用「真拒絕經驗」（`_resolve_join:1100-1103` 實際發生的 reject 事件）記憶，非猜測——比 v1 猜 host 糧更 honest（真事件 vs 不存在的信號）。
2. **loop 真斷**：`has_acceptable_join_host` gate 邏輯（單一可達 host 被拒 → gate false → 併入 not applicable → fall through 其餘 survival option）與 Fix A/B 家族邏輯一致，多 host 逐個 cooldown 後全拒 → 同樣 fall through，非死鎖。
3. **不誤殺**：cooldown 前給一次真試（撲空 emergent 精神保留），cooldown 過期可再試（host 現況變好時不永久黑名單）——設計對稱，符合「非所有撲空都擋，只擋已知會拒」的既定原則（同 A#4 精神延伸）。
4. **host 對應仍鎖**：`spec:60`「host 對應鎖定不變（R②關鍵）：評的host＝dispatch會去的那一個（鏡射to_task:181）」——逐字延續我上輪要求，未鬆動。
5. **memory 機制純淨性（本輪重點查）**：`npc_ai_system.gd:65-74 write_memory` 有旁支副作用（`_update_relations`/`_trigger_goals`/`_write_relation_edge`），查三者對陌生 type `"join_rejected"`的行為：`_update_relations`(:96-104) `match` 有 `_:` 預設 `delta=0.0`——安全 no-op；`_trigger_goals`(:108-115) `match` 無此 case、GDScript 無匹配即靜默略過——安全 no-op；`_write_relation_edge`(:78-86) 同無此 case——安全 no-op。**確認複用 `write_memory` 對此新型別零意外副作用**，只落地 `p.memory.append`（受 `_trim_memory`/`MEMORY_MAX` 既有裁剪機制管理）。cooldown N 為 TEST VALUE，與專案既有慣例（`FORAGE_VIABLE_POP`/`DESPERATION_DAYS` 等）一致，implementer 可調。

## 次要觀察（非 issue）
`MEMORY_MAX` 裁剪（`:88-90`）是共享資源——若 `join_rejected` 記憶被其他事件類型擠出，cooldown 可能提前失效（host 比預期更早可再試）。方向無害（頂多退回「較快重試」而非死鎖或誤殺），非阻擋放行的問題，implementer 可留意即可。

## 框外審評估
同意——機制改仍在 Fix A 家族 WHAT 範圍內（併入不守幻覺），非新框，標準審足夠。

## 結論
前提 gap 診斷屬實、v2 機制設計扎實、host 對應鎖定延續、memory 側效應查證安全。**CLEAN → 可直接 dispatch implementer**（`feat/desperation-food-seeking`）。
