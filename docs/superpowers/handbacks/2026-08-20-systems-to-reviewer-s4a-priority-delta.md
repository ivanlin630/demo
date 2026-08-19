---
from: systems
to: reviewer
status: consumed
topic: "[FYI+快查(非阻塞、我已 REDO dispatch):§4a build 漂了你審時的前提——紮根登記 survival set→priority_for 回 80(你審時明寫預期 PRIO_DISPATCH 50 跟舊 scaffolding 一致)→80>THREAT 70=壓境打不斷 L1 工期(S2b 設計要能斷)·implementer TDD⑤ 是靜態 set 成員 assert、抓不到動態 preempt·★我裁修法:①留 survival set(rank_survival 只收 survival-set decision_engine:169、拿掉=絕境隊結構性沒紮根=隱含硬門檻違禁回潮)②REGISTRY 加【通用 optional 'priority' 欄】、priority_for 先讀(無則舊邏輯)③紮根標 PRIO_DISPATCH·理由=解耦『在哪些 rank 競爭』(set)與『committed 後誰能打斷』(priority)兩個被綁死的語意·★快查請你判(非阻塞、你若反對我改):(a)通用 priority 欄=延伸統一還是我在開後門(未來 option 亂標 priority 繞過 rank 語意)?(b)紮根@50 committed 後被 survival@80 打斷→corvee_site recovery 回頭續建=既有機制夠不夠(不會變成永遠開工又中斷的新 churn)?·地基KEEP"
---
# FYI+快查（非阻塞、我已 REDO dispatch）
§4a build **漂了你審時的前提**：紮根登記 survival set → `priority_for` 回 **80**（你審時明寫預期 `PRIO_DISPATCH 50` 跟舊 scaffolding 一致）→ **80 > THREAT 70 = 壓境打不斷 L1 工期**（S2b 設計要能斷）。implementer TDD⑤ 是**靜態 set 成員 assert**、抓不到動態 preempt。
**★我裁修法**：①**留 survival set**（`rank_survival` 只收 survival-set `decision_engine:169`；拿掉=絕境隊結構性沒紮根=**隱含硬門檻違「禁回潮」**）②REGISTRY 加**通用 optional `priority` 欄**、`priority_for` 先讀（無則舊邏輯）③紮根標 `PRIO_DISPATCH`。理由=**解耦「在哪些 rank 競爭」(set) 與「committed 後誰能打斷」(priority)** 兩個被綁死的語意。
**★快查請你判**（非阻塞、你若反對我改）：
- (a) 通用 `priority` 欄=**延伸統一**還是**我在開後門**（未來 option 亂標 priority 繞過 rank 語意）？
- (b) 紮根@50 committed 後被 survival@80 打斷 → `corvee_site` recovery 回頭續建=**既有機制夠不夠**（不會變成「永遠開工又中斷」的新 churn）？
地基 KEEP。
