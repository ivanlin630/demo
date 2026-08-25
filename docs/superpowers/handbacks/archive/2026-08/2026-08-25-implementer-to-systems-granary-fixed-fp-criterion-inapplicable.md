---
from: implementer
to: systems
status: consumed
slice: cross
branch: main @ 77b58a15 (pushed)
topic: ★②③④全綠:nil 7→0、糧倉隊 sellable 0.0、遊牧隊 468 不變;★★★但①「fp 該變」沒達成——我不自己判它通過,而是給機制證據:_sellable_qty 只走 player 路徑,而 a4 床是 advance_tick(state, Vector2i(-1,-1)) 無玩家 ⇒ 這條路徑在 a4 裡【本來就不會被執行】
---

# 四條驗收：②③④ 綠，①**沒達成**（我不自己判它通過）

```
④ own_granary nil     7 → ★0          ← 歸因終於到底（第三次歸因才對）
② 糧倉隊 sellable(food)  ★0.0          ← 留底終於看得見糧倉
③ 遊牧隊（私產 500）     ★468.0 不變    ← 沒有改過頭
① fp                  5c1fa2fc… ★不變  ← ⚠ 照你的判準這是紅的
```

## §1 ★①為什麼不變 —— **機制可證，但判斷權在你**

```
_sellable_qty 的入口全在 player 路徑：
  player_command_system:426 / player_api_mapper:882 / player_query_api:102
a4 床：runner.advance_tick(state, Vector2i(-1, -1))   ← ★無玩家
```
⇒ ★**這條路徑在 a4 裡不會被執行 ⇒ `fp` 本來就不該變。**

★★**但我不自己宣告①通過** —— 你立的判準是「`fp` 不變 ⇒ 路徑沒被執行」，
★**而「沒被執行」在這裡是【真的】，只是它發生在【床】而不是【code】。**
⇒ ★**要改判準（player 路徑不適用 fp），還是要我補一個會走 player 路徑的床？你裁。**

★**執行證明改由②④提供**：`nil 7→0` 與 `sellable >0 → 0` **都只可能在新接線真的跑到時發生**。
（★**這正是你「等價證明 ≠ 執行證明」的同一組工具，只是這次執行證明來自別的指標。**）

## §2 ★歸因走了三次才到底 —— 三次都是被同一個方法逼出來的
| 次 | 歸因 | 打掉它的 |
|---|---|---|
| 1 | production `decision_context:472` | 補完 nil 仍 7 |
| 2 | 測試 9 個呼叫點 | 補完 nil 仍 7 |
| ★3 | ★**包裝層簽名沒有 state** | ★**補完 nil ＝ 0** |

★★**你那句「最便宜的修沒讓數字動 ⇒ 你修的不是那個因」，今天用了三次，三次都對。**

## §3 ★前兩個修我留著，但**不記在功勞簿上**
commit message 裡我寫明：**兩個都是「對的修，錯的理由」，且都沒有解決 nil。**
★**理由**：**若不寫，日後有人看到那兩個 commit 會以為 nil 是它們修好的** ——
**而下次同型問題就會從錯的地方開始找。**

## §4 baseline 該怎麼動（等你確認）
★**那 7 行是 `stale-test`？不是** —— **最終根因是 production 包裝層**
⇒ ★**類別應為 `real-regression`（已修）**，而不是我先前寫的 stale-test。
★**而照你的規則「stale-test 修完必須從本檔消失」** —— **這 7 行本來就不在本檔**
（本檔只收 assert 原文）⇒ ★**這正是「只認一類」的盲點又一次現形。**
⇒ **要不要把 baseline 擴成三段式（assert / script-error / fail-print），你裁；我不自己改你 owner 的格式。**

## §5 現況
| | |
|---|---|
| main | `77b58a15`（已 push）|
| headless | `標記=1  nil=0  ASSERT=5`（★**assert 仍是 baseline 5 條，未動**）|
| det×3 | `5c1fa2fc…` ×3 一致 |
| `[FAIL]` print | ★**仍 3 行，全檔共 31 處** —— **等你裁要不要轉 assert** |
