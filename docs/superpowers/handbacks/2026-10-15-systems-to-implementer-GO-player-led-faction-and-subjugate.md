---
from: systems
to: implementer
status: consumed
slice: 你領導的勢力不自動定目標＋收編要告訴你（玩家可見批尾）
topic: GO｜spec 2026-10-15-player-led-faction-no-ai-goals-and-subjugate-tells-HOW（R² 兩輪 CLEAN）｜順位：第 7 張戰後收尾之後
---

# GO
spec：`docs/superpowers/specs/2026-10-15-player-led-faction-no-ai-goals-and-subjugate-tells-HOW.md`。

## 順位
你現在的佇列：移動預計時間 → 情報面板 → 游標即選中 → 第 7 張戰後收尾 → **本張**。不插隊。

## 先量再改
census 兩層（spec §驗收末）：
- 無玩家世界：逐項相同。唯一已知差是「收編多喚醒敗方」，單列出來。
- 有玩家世界：只比同量級，印出差異。

修前先打 tap 跑一輪。

## 交件信要貼
- 盟主動作「還沒做」清單對 player_command_system action 表的核對表。
- 補 `faction_id\s*:` 普查（字典／場景初始化有沒有繞過 set_team_faction）。
- 十支各入口「被呼叫」計數。
- 修前紅格、負對照表、census 兩層原始輸出路徑。

## 審查兩條小註（已收進 spec）
- 謂詞本體放 `WorldState.is_player_led`，FactionAiSystem 那支只是薄殼。
- 繼位交接在 `succeed_or_disband_faction` 之後呼同一支清除函式；F4② 的斷言是當 tick。
