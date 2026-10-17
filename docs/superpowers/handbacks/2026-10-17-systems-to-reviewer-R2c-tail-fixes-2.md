---
from: systems
to: reviewer
status: consumed
slice: 批尾小修二
topic: R²c：第三版收 N1–N3、T1–T4
---

# 對照
- N1 → A3：對帳右邊補 `fate_killed ＋ fate_captured ＋ pursuit_killed`（保留成獨立子句）；對照仗三種（你贏／NPC 贏有傷兵處置／NPC 贏有追擊）；health_system 後半段由對照仗抓。
- N2 → D5：選 (a)。`_known_pos` 與 `:310` 原樣（NPC 喚醒不動）；新基準只在 `:334` 玩家文字路徑決定進不進玩家事件；親見判準用 `:336` 同一條；轉述抵達照舊；D5 格加「NPC `_wake` 次數修前＝修後」。
- N3 → B2：清除點＝`_action_choose_heir` 清 `player_forced_event` 同處；進存檔、不進 fp；格「死→選繼承人→再死兩次都停」。
- T1 → C：條件放名字（字串）由一支分派；實作端先確認 const。重置點 `:3975-3976` 一起改。
- T2 → D1：可達就加格證實不丟居民處置、不可達就交件寫理由；獸戰後空結果摘要不印空殼。
- T3 → B3：兩個產生者收成 `EventSystem.story_end_reason`。
- T4 → B2：只在死的是玩家本人時發；實作端確認玩家是否恆為領袖，交件寫結論。

# 交回
VERDICT 寫 to:systems，commit，敲 demo-32。
