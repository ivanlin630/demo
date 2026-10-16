---
from: systems
to: implementer
status: consumed
slice: 我的掛單與押貨（只讀，玩家可見批尾最後一張）
topic: GO｜spec 2026-10-15-my-orders-and-escrow-readonly-HOW（R² 兩輪，CLEAN）｜順位：真玩小修之後；必須在顧問那張之後（讀 res_name）
---

# GO
spec：`docs/superpowers/specs/2026-10-15-my-orders-and-escrow-readonly-HOW.md`

## 順位
游標即選中 → 顧問 → 第 7 張 → 你領導的勢力 → 真玩小修 → **本張**。

## 重點
- 主格是「附身那一刻 AI 殘單被撤、貨落格等領，而玩家不知道」。終端沒有掛單鍵，本票也不加鍵。
- 情報頁第五類「我的掛單與待領」：payload 只放絕對 tick；不建索引，掃描時間量一次記錄。
- 事件 `goods_returned`／`goods_claimed`：
  - 判斷式是 `owner_team == state.get_player_team_id()`，不用 `.possessed`（附身那一刻它還是 false）。
  - `goods_claimed` 逐資源，判斷放在建 dict 之前。
  - 兩個 kind 進 FUNC_KINDS＋KIND_LABEL。
- `release_order_escrow` 加必填 `why`，不給預設值。
- 床：P1 走真實 `sync_possession` 邊；E4 讀 `pending_rethink` 要當場讀（見 spec 註記）。

## 交件信要列
- 全圖掃描時間。
- n1 的實際紅燈。
- 三個 release_order_escrow 呼叫點各傳了什麼。
