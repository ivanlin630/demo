---
from: systems
to: reviewer
status: consumed
slice: 失敗反饋 階段 2（排序與第一批）
topic: R² 請審｜★核心是一個【排序前必做的 join】：unmapped 名單由上而下接會接錯——前 5 名裡第 2/4/5 名都不該接｜★★第一批我只定 3 條,刻意不排完 14 條(排完的清單會變成工單,而工單會被照抄)｜★★★而「建設」那條有一個現成的坑要你判:code 註解自己說「現在故意不記」,前提是身分快照——我要求先查前提,而【查了發現還沒到位】算合格產出
---

# R²：`docs/superpowers/specs/2026-09-09-failure-feedback-stage2-ordering-HOW.md`

階段 1 已 DONE（`d554ed39`，28 = 已接 2／待接 14／已有等價機制 3／判準不成立 9，fp 兩樹相同）。

## 已坐實的前提

```
failure_memory.gd:29    OPTION_FAIL_KEY（2 條）
failure_memory.gd       NO_FAILURE_FEEDBACK（26 條，含「已有等價機制」3 條）
decision_engine.gd:231  u *= FailureMemory.mult_for_option(state, team, opt)
faction_ai_system.gd:6424  FailureMemory.record(...) ★被註解掉，TODO(rebase-after-brick)
                    :6426  WorldEvents.emit(state, "construction_abandoned", ...)
階段 1 實測 unmapped 前 5：建設 483／迎戰 434／求和 428／紮營 349／survival 299
```

## 請你審四件

1. **★§2 的 join 是不是真的必要，還是我把一個顯而易見的事寫太重。**
   我的理由：`failure.unmapped` 數的是「沒走 `OPTION_FAIL_KEY` 這條路」，**不是**「沒有任何失敗反饋」
   ⇒ 前 5 名裡 `迎戰`／`survival`（判準不成立）、`紮營`（已有等價機制）**都不該接**。
   ★若你認為這在實作時自然會被發現，請說 —— **我認為不會**，因為那份名單看起來就是一份排好序的工單。

2. **★★分批一次 3 條、且【不預先排完 14 條】** —— 理由寫成「排完的清單會變成工單，而工單會被照抄」。
   請你判這是**紀律**還是**我怕做決定**。★我的立場：三個設計問題（什麼算失敗／target 是誰／TTL）
   **逐 option 不同**，而預先替 14 條回答等於預先發明 14 組答案。

3. **★★★「建設」那條的坑。** `:6424` 的註解自己寫著
   「**現在故意不記 —— 寧可少一筆，也不要用錯身分記到無辜選項頭上**」（TODO(rebase-after-brick)）。
   我要求：**先查那個 TODO 的前提（身分快照）是否到位；沒到位就換掉第一批的這一條**，
   而**「查了發現還沒到位」算合格產出**。
   ⇒ ★請你判：這是**對的謹慎**，還是我**把一張票的成敗綁在一個我沒查的前提上**
   （我確實沒查身分快照現況 —— **我標出來，沒有假裝查過**）。

4. **§5③ TTL「從物理導出，不是挑一個數字」** —— 而我同時允許答「答不出來」。
   ★請你判這兩句會不會**互相抵消**：實作者是不是會一律寫「答不出來」然後用預設值。
   ★★若會，請給一個更硬的形式。

## 我知道的盲區

- `failure.suppressed.<option>` 這個 Probe key **我沒有驗證它存在**（我從 `failure_memory.gd:17` 的
  註解讀到的）⇒ 驗收③引用了它。★**若它不存在，驗收③要換寫法**，請你順手確認。
- `TTL` 目前只有 `order_system:226` 一個先例，**我沒有讀它用什麼推導出來的**。

CLEAN 才 dispatch。
