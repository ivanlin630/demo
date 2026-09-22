---
from: systems
to: reviewer
status: consumed
slice: R² 第二輪 —— **形狀改變了，照規矩回來**
topic: ★WHAT 裁 (乙)：抑制**只限主決策 T0 思考路徑** ⇒ 從「不 emit」變成「**範圍化通道**」⇒ ★★**這是形狀改變，所以我回來再過一次**（我自己寫死的）｜★★★**而你那四個消費者漏了第五條**：`world_events.gd:106-128` 的 faction 層查詢 —— ★**不是指責**：你窮盡的是 `pending_source`／`is_pending` 的消費點，**而它直接讀 `pending_rethink`**｜★請重點看 §10.1 的預設值與 §10.2 的 fp 約束
---

# 一、新形狀（票 §10.1）

```gdscript
emit(state, kind, subjects, wake_thinking: bool = true)
    state.pending_rethink[id] = true                  # 三個既有消費者：一行都不動
    if wake_thinking: state.pending_think[id] = true  # 新：只有思考路徑讀它
belief_system.gd:293 是唯一傳 false 的呼叫點
```
★**請你挑預設值**：我選 `true` 的理由是「未來新增的 emit **自動維持瞬醒** ＝ 構造保證」
⇒ ★★**它的代價是**：想讓某個新事件不吵醒思考，**必須主動記得傳 false** —— **這個取捨你同意嗎？**

# 二、★★★我要你重點查的兩條 fp 約束（票 §10.2）

```
`world_events.gd:6` 明寫：**`pending_rethink` 不入 `state_fingerprint` 的正當性基礎
  ＝【單 tick 內清空】**（`:171` clear）
⇒ ①**新集合必須在同一點清空**，否則**它就得入 fp** ⇒ **fp 語意當場破掉**
⇒ ②`world_state.gd:156` 旁的新欄位**同樣不入 `state_fingerprint`**
★這兩條是我讀 code 才看到的 ⇒ ★★**請你用同樣的方式查我有沒有漏第三條。**
```

# 三、★第五條消費路徑（我補的）

```
`world_events.gd:106-128`：faction 層查詢，**直接讀 `pending_rethink`**（不走 `pending_source`），
  註解自寫「這不是第二套機制 —— 它讀的是同一份 `pending_rethink`」，服務**五支 T3 節點**
⇒ ★**這大概就是它從你的窮盡裡消失的原因**：你掃的是 `pending_source`／`is_pending`
   ⇒ ★★**掃【讀取形態】不是掃【名字】** —— 同一族今天第 N 次
⇒ 處置：**不動它**（用 WHAT 自己的原則，保守側＝行為不變）＋ 進 defer（觸發條件機械化）
```

# 四、其餘未動

```
B1~B6、B4a/b/c（含間隔 p99）、§9 禁令與 §9.1 陽性對照 —— 你上一輪核過的都沒改。
★第 0 步（量 f）不受形狀影響、已派且可以先跑：
  `docs/superpowers/handbacks/2026-09-22-systems-to-implementer-DISPATCH-step-zero-measure-f-only.md`
```
