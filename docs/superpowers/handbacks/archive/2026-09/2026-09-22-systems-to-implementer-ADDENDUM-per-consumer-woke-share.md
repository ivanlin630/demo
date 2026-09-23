---
from: systems
to: implementer
status: consumed
slice: 第 0 步 —— **加印一欄**（★若已開跑，能從既有卷面補算就不要重跑）
topic: ★WHAT 裁 (乙)：抑制**只限主決策 T0 思考路徑**，三個消費者行為不動｜★★**f 那一步請順手印【每個消費者的 woke 份額】** —— 它是一列 defer 的**機械觸發條件**（四條合計 ≥ 20% 尖峰 ⇒ 開新票）｜★★★**而 R² 那四個消費者漏了第五條，我補上**：`world_events.gd:106-128` 的 faction 層查詢（**直接讀 `pending_rethink`，不走 `pending_source`**）
---

# 一、加印的那一欄

```
`t0.woke.by_consumer.<name>` —— **五條路徑各一欄**：
  INDEP_INFRA（`faction_ai_system.gd:1352`）｜LADDER（`:1436`）｜GOAL（`reaction_system.gd:62`）
  ｜**faction 層查詢（`world_events.gd:106-128`）**｜主決策 T0 思考路徑（本票要改的那個）
★母體要印：pass tick 上的 woke 總次數（要能跟 `woke_only` 441 對得起來）
★★**若你已經在跑** ⇒ **先看既有卷面能不能補算** —— 你已經三次不重跑就答出來了；
   **補算得出來就不要重跑**，機器不必再燒一次。
```

# 二、★為什麼這是「觸發條件」不是「順便看看」

```
`docs/process/defers.tsv` 新登一列 `t0-wake-nonthinking-consumers`：
  **四條非思考路徑合計 ≥ 20% 的尖峰 ⇒ 開新票各自裁**
⇒ ★★寫成機械的，**不是「有人記得」** —— 今天我們才處理過一列**逾期 25 天沒人執行**的決定。
```

# 三、★★★第五條路徑是我補的

```
`world_events.gd:106-128` 的註解自己寫著：
  「**這不是第二套機制 —— 它讀的是同一份 `pending_rethink`，只是換一個索引**」，服務**五支 T3 節點**
⇒ ★R² 窮盡的是 `pending_source`／`is_pending` 的消費點，**而它直接讀 `pending_rethink`**
   ⇒ ★★**掃【讀取形態】不是掃【名字】** —— 同一族今天第 N 次
⇒ 處置：**不動它**（用 WHAT 自己的原則，保守側＝行為不變），★但**它要出現在你那一欄裡**。
```

# 四、實作仍然 hold

```
★形狀從「不 emit」變成「範圍化通道」⇒ **票已送回 R² 再審一次**（我自己寫死的規矩）
★★設計見票 §10.1：`emit(..., wake_thinking: bool = true)`，
   ★★★**預設 true** ⇒ 未來新增的 emit **自動維持瞬醒** ＝ **構造保證**，不靠清單
★兩條硬約束（票 §10.2）：新集合**必須在 `world_events.gd:171` 同點清空**
   （`world_events.gd:6` 明寫「單 tick 內清空」正是它**不入 `state_fingerprint`** 的正當性基礎
     ⇒ **不同步清 ⇒ fp 語意當場破掉**）；新欄位同樣不入 fp。
```
