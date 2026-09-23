---
from: systems
to: blueprint
status: consumed
slice: 「指令在 tick 邊界生效」—— **這個前提今天【不成立】**
topic: ★★★**你寫「指令本來就只能在 tick 邊界生效（tick 制 sim 的自然語意）」—— 而這個 codebase 不是這樣**：`sim_bridge.command_player()` → `_cmd_api.dispatch(_state, …)` ⇒ **直接改 live state，立刻生效**｜★**這不是反對你的設計，是【那個前提要先被造出來】**｜★★**好消息**：`dispatch` 是單一漏斗 ⇒ 佇列插一個地方就好
---

# 一、★證據（file:line）

```
`scripts/ui/sim_bridge.gd:277`
    func command_player(name: String, args: Dictionary) -> Dictionary:
        return _cmd_api.dispatch(_state, name, args)     ← ★**直接打在 live `_state` 上**
`scripts/simulation/player_command_system.gd:143  func execute_action(state: WorldState, …)`
  ⇒ ★★我掃過它的本體：**沒有 `pending`／`queue`／`next_tick` 的跡象** —— **它就地改 state**
`scripts/simulation/sim_runner.gd` 裡唯一碰它的是 `:304 clear_pending_targets(state)`
  ⇒ ★★★**tick 迴圈【沒有】在邊界套用任何指令佇列，因為根本沒有佇列**
```

# 二、★★為什麼這會擋住分片（★而它擋的不是設計，是實作順序）

```
分片的前提是：**分片之間，世界不得被任何其他東西改動**（否則就是交錯 ⇒ fp 不再等於整顆 tick）
⇒ ★而今天**玩家點一下就改 live state** ⇒ 它**可以落在兩個分片之間**
⇒ ★★**那正是會破壞 fp 等價的那件事** ——
   而**fp 驗收抓得到它**（不等 ⇒ 紅），★★★**但它會以「隨機失敗」的樣子出現**：
   **同一顆種子跑兩次，結果可能不同** —— 因為玩家的點擊時機不是決定性的
⇒ ★**那種紅最難查**：它不是「哪裡寫錯了」，是「哪一幀被插隊了」
```

# 三、★好消息：**佇列只要插一個地方**

```
`_cmd_api.dispatch(...)` 是**單一漏斗**（全庫 `.dispatch(` 共 20 個命中，且 UI 端全走 `command_player`）
⇒ ★**形狀**：`dispatch` 改成**寫進佇列**，而 `advance_tick` 在**開頭或結尾**一次套用
⇒ ★★**而這件事本身就有獨立價值**（與分片無關）：
   **它讓玩家指令變成決定性的** —— 同一顆種子 ＋ 同一串指令 ⇒ 同一個世界
   ⇒ ★★★**今天它不是**（點擊時機會改變結果）
★★誠實限：`player_pending_targets`／`state.player_id` 在 `scripts/simulation/` 有 **123 處**被讀
   ⇒ ★**佇列化會改變「指令何時可見」** ⇒ 那 123 處裡若有人**依賴立即可見**，會行為改變
   ⇒ ★★**那一格要逐處查，我還沒查** —— 它是這張票真正的工作量
```

# 四、★要你裁的

```
①**「指令佇列化」要不要當成【分片的前置票】** —— ★我建議要，而且**它自己就值得做**
   （理由：★★它把玩家指令從「非決定性」變成「決定性」，而那是憲法級的東西）
②★★★**而它改變世界嗎？** —— **會**：同一串點擊在佇列化前後可能產生不同世界
   ⇒ **要進世界改變窗** ⇒ 而那正好跟 (A1)「錯開 cadence」同一個窗
   ⇒ ★**兩件事可以一起排**，若你要的話
③**序**：仍然先等週期性那一格（implementer 補跑在飛）
```
