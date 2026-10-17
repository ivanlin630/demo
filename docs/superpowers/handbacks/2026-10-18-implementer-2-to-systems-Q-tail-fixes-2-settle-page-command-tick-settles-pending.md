---
from: implementer-2
to: systems
status: consumed
slice: 批尾小修二（HOW 2026-10-17-tail-fixes-2）
topic: 問 A2：結算頁上按 K／L／J 走 command_player 會推一顆 tick，而那顆 tick 的 settle_pending_aftermath 會把還沒選的傷兵／追擊／居民被動結清——與「按 L 不推進、待處置還在」衝突；建議甲（頁上指令那一拍不算「沒處置就推進」），等你裁，我先做 B–E
---

# 現況（main 16af14eca 讀的）
- `SimBridge.command_player`（`sim_bridge.gd:435-439`）：入列後 `request_advance(1)`（press-is-do，一道令＝一顆 tick）。結算頁的 K／L／J 都走它（`encounter_view.gd:711-730`）。
- 戰鬥在分支 A 結算：`resolve_encounter_end` 寫 `last_encounter_result.tick = T`，接著 `_step1_advance_time` ⇒ T+1（`sim_runner.gd:645-654`）。
- 下一道令（例如按 K 收戰利品）走常規路：時間 → T+2、消化指令、然後 `settle_pending_aftermath`（`sim_runner.gd:657-659`）。結清條件 `res.tick < current_tick` 成立 ⇒ **傷兵處置、追擊、居民處置被動結清**，並發「你沒有處置：…」。
- ⇒ 今天的形狀：玩家贏了，先按 K 收戰利品，傷兵就被放走了，接著按殺會回「現在沒有要你處置的事」。

# 跟 spec 的衝突
- A2 驗收格：「按 L ⇒ 留戰利品（不推進）」接著「Esc 關頁後推進 ⇒『你沒有處置』」。照現況，按 L 那一拍就已經結清了，Esc 之後那一句不會再出現；「待處置還在」也不成立。

# 選項
- **甲（建議）**：`settle_pending_aftermath` 在「這一拍消化的指令裡有結算頁上的令」時不結清。結算頁上的令＝`take_loot`／`leave_loot`／`subjugate_enemy` 加上 `AFTERMATH_FATE`／`PURSUIT`／`RESIDENTS`（就是頁上綁鍵的那些）。
  - 理由：被動結清的語意是「推進而沒處置」；在頁上按收戰利品不算略過處置。
  - 代價：多一個判斷（讀這一拍消化的那批令的名字，不讀世界）。tick 照樣走一顆（press-is-do 不動），所以「不推進」我讀成「L 在頁上是留戰利品，不是走到抵達」。
  - 只在玩家世界作用（指令佇列只有玩家寫）⇒ world-fp 不變。
- **乙**：頁上的令只入列不推（`_enqueue_command`）。按了要等 Esc 之後的推進才生效，頁上看不到結果句（「收取戰利品：糧食 37…」要等關頁），A3b 那一格會變怪。不建議。
- **丙**：不動，接受「先按 K 就沒得處置」。A2 驗收格要改寫。不建議。

# 我這邊
- 先做 B／C／D／E，A2 的推進鍵／未綁鍵／Esc 那部分照 spec 寫（跟這題無關），只有甲這一行等你裁。
