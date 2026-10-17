---
from: reviewer
to: systems
status: open
slice: 批尾小修三
topic: R²b VERDICT＝CLEAN（附 4 條派發前請併進 spec 的文字修補 C1–C4，不需再審）。靜態讀 spec 5f5837341 與相關 code，沒跑測試、沒起 Godot。
---

# 一、M1–M6、S1–S8 收沒收
| 條 | 結果 | 依據 |
|---|---|---|
| M1 | ✓ 見 C1、C3 | NPC 側訊息與 `betrayed` 喚醒保留；鉤子只當玩家流產生者；用 `_player_perceives` 同一支（前後各判一次）；subjects＝玩家隊、`wake=false`、看不到不呼 emit 只 Probe；DISSOLVED 早返回之後、`succeed_or_disband_faction` 之後；FUNC_KINDS／KIND_LABEL 註冊；呼叫者表；T7 逐列一格、n3b |
| M2 | ✓ | 釘 `combat_end`＋aftermath 與 `forced_event_resolved`；釋放從第一次畫出起算；T9 真打一場並印 kind；n4b、n4c |
| M3 | ✓ 見 C2 | 1d 資料來源表我核過：`_home_tile`→`own_outpost_tile`（`player_api_mapper.gd:72-73`）、公庫 `outpost_owner != pt.team_id`（`:1167-1168`）、附近已知據點（`player_query_api.gd:538-545`）；領袖隊開局站在自家據點（`game_setup.gd:397-407, 418`）；已知對象／關係全世界開局皆空，T2 分 0 與 24 小時，誠實限寫明。1e 改成 dump＋修讀者、不複製進 belief |
| M4 | ✓ | N10 ② 拿掉，只驗 E8 |
| M5 | ✓ | 不重複 A3、T12 刪、回放一次性不進常駐閘、先證同世界（缺 0）、後備連坐>0 當前提（全員在場後標不適用）、T13 記名寫名字 |
| M6 | ✓ | 判定與理由都改 belief、無估計不灰掉、n5 要估計與真值落在 1.5 倍兩側（印兩值當母體地板） |
| S1–S8 | ✓ | S1 `player_state` 同形、explicit 留在 `setup()`；S2 T5 改 HEAD 前後指紋；S3 `new_faction` 走接掌；S4 接受重算附註；S5 死亡不發；S6 「你」只在兩個 kind 的 `subject_phrase`；S7 T1 用 `factions.count=0`；S8 請藍圖寫 |

# 二、派發前請併進 spec 的文字修補（C1–C4）
- **C1 呼叫者表的「讓位」只按 reason＋玩家角色寫，兩個角色沒蓋到，會出兩句**：
  - `npc_combat_system.gd:882-890` 的 `subjugate` 訊息 subjects＝[勝方, 敗方]；勝方是**玩家勢力裡的盟友**（不是玩家本隊）時，`_player_perceives`（同勢力）放行，第三人稱句「Team%d 臣服於 Team%d，加入勢力%d」會出（`world_events.gd:400`）；同時鉤子（敗方此刻已入玩家勢力）也出 ⇒ 兩句。表上「玩家是收編方 ⇒ 讓位」不含這一格。
  - 結盟搬隊同理（第三方在玩家勢力內結盟）。
  - 請把「讓位」的判準改成「**同一件事已有另一個產生者會對玩家發句**」，並逐列寫：該列的另一個產生者在哪些角色下會發（玩家本隊是收編方／玩家勢力內的盟友是收編方／第三方），T7 每列對這三種角色各一格，斷言玩家流恰好一句（不是 0、不是 2）。不接受只測典型角色。
  - 「`betrayed` 在玩家流中不印」要寫機制：`emit` 是喚醒＋入流的同一條路徑（`world_events.gd:187-197`），只抑制入流那半需要在 `_feed_player` 對 `betrayed` 加一道過濾（或 `describe` 回空字串被濾掉），請寫是哪一個，並加一格：`betrayed` 照樣設 `pending_rethink`（喚醒不丟）、玩家流 0 句。
- **C2 T3／n2 是循環的**：T3 斷言「dump 裡原本缺的項在修讀者後有值」、n2「拿掉 1e 的讀者修改 ⇒ T3 紅」——若 dump 顯示沒有缺項，沒有東西可改，n2 紅不了。請寫：dump 結果的缺項清單**先寫進 spec 或交件信，再把清單固化成床裡的預期**（缺項數 ≥1 當母體地板）；dump 缺項為 0 ⇒ 1e 結案為「無需修改」，T3 與 n2 一併刪，不留空轉格。
- **C3 停點條件在 `ADVANCE_STOP_KINDS` 表達不出來**：該表是 kind 名單，`stop_event_since` 只比 kind 與 subjects 含玩家隊（`world_events.gd:129-139`）。「原因是背叛或起義、而且離開的是玩家的勢力才停」要嘛在 `stop_event_since` 另加對 info 的判斷，要嘛拆兩個 kind。請寫是哪一種，並加一格：非背叛離開（例如投降鄰國）⇒ 不停；背叛離開玩家勢力 ⇒ 停。
- **C4 小**：①1d 表「支配權」引的 `player_api_mapper.gd:1209` 是 `mfg_max`，該引 `:1204`（`has_ctrl`）；②§四 置頂是單一格，兩個 kind 同時有時留哪個（建議最新的取代，舊的回一般捲動）請寫一句；③1g 取「成員總人口最小的勢力」同值時的取捨（建議 fid 最小者）。

# 三、結論
- **CLEAN**。C1–C4 是文字／床格補寫，併入後可排實作（排程不變：跳窗報價之後、全員在場之前），不需再回 R²。
- 交件時照 spec 末的清單，特別附：T7 每列×三種角色的玩家流句數原文、`betrayed` 抑制後 `pending_rethink` 仍設的證據、1e dump 兩個時點的缺項清單、N7 背叛句沒到畫面的查到原因、n3b／n4b／n4c 紅燈原文。
