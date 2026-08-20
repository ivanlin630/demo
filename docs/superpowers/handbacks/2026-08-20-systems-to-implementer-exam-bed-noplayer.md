---
from: systems
to: implementer
status: consumed
topic: "[dispatch 大考床兩修(cheap、且大考已結束=merge 禁令解除,這支連同你停著的 feat/orderbook-tap 一起收)·來源:measurer 回報 warring leg 在 day~70 因 state.game_over 凍結,床沒 guard 傻跑滿 86400 次、用 loop counter 當 day 一路寫到 360=產出 290 天 degenerate 假列(tick 凍結/phase_us 塌成單 key/probe 全空)·★T1 床加 guard:迴圈內偵測 state.game_over 翻 true → print 一行(含當時 day/tick/reason)+break;順帶 print 到 progress sidecar,免得下次又是事後才發現·★T2 更根本(我 code-read 出的真因、比 T1 重要):warring_states.json【有 player 區塊】→該 config 會建玩家隊;那隊 leader 死且無 named 繼承人 → event_system:74 game_over=true → sim_runner:71 凍結世界·∴我們是在【有玩家的 config】上跑【無人值守的世界模擬】,而那個沒人操作的玩家隊一死整個世界就停——跟今天 LOD 那條是同一族(玩家中心假設凍住世界模擬)·處置=【量測側修、不動 production】:大考床 setup 後把該世界的 player 拆掉(state.player_id=-1 + 清 player_forced_event;若 GameSetup 有 no-player 選項優先用選項),並在床頭註明理由;★禁改 sim_runner 的 game_over 語意(那條 H 不變量在【真的有玩家】時是對的)·★T3 註記:床頭寫清楚『本床跑的是無玩家世界;若未來要量有玩家情境,game_over 凍結是預期行為、不是 bug』·gate:短窗 smoke(3 天)全欄位有值+fp 與 main byte-identical(純觀測)+det×3+constitution<=75+headless 0-new(headless_test 這輪要補跑、上次因禁令暫緩)·★可與 feat/orderbook-tap 合併成同一支交付(兩者都是床/觀測層)、或分開隨你,做完一起 handback·地基KEEP"
---

# dispatch：大考床兩修（cheap；★大考已結束 → merge 禁令解除，這支與你停著的 `feat/orderbook-tap` 一起收）

**來源**：measurer 回報 warring leg 在 **day~70 因 `state.game_over` 凍結**，床沒 guard → 傻跑滿 86400 次、用 loop counter 當 day 一路寫到 360 ＝ **290 天 degenerate 假列**（tick 凍結／`phase_us` 塌成單 key／probe 全空）。

- **★T1 床加 guard**：迴圈內偵測 `state.game_over` 翻 true → **print 一行**（含當時 day/tick/reason）**+ break**；順帶寫進 progress sidecar，免得下次又是事後才發現。
- **★T2 更根本（我 code-read 出的真因，比 T1 重要）**：`warring_states.json` **有 `player` 區塊** → 該 config 會建玩家隊；那隊 leader 死且無 named 繼承人 → `event_system:74` `game_over=true` → `sim_runner:71` **凍結世界**。
  ∴ 我們是在**有玩家的 config** 上跑**無人值守的世界模擬**，那個沒人操作的玩家隊一死、**整個世界就停**——跟今天 LOD 那條是**同一族**（玩家中心假設凍住世界模擬）。
  **處置＝量測側修、不動 production**：大考床 setup 後**把該世界的 player 拆掉**（`state.player_id = -1` + 清 `player_forced_event`；若 `GameSetup` 有 no-player 選項則優先用選項），床頭註明理由。
  ★**禁改 `sim_runner` 的 `game_over` 語意**（那條 H 不變量在**真的有玩家**時是對的）。
- **★T3 註記**：床頭寫清楚「**本床跑的是無玩家世界**；若未來要量有玩家情境，`game_over` 凍結是**預期行為、不是 bug**」。

**gate**：短窗 smoke（3 天）全欄位有值 + **fp 與 main byte-identical**（純觀測）+ det×3 + constitution ≤75 + **headless 0-new**（`headless_test` 這輪要補跑，上次因禁令暫緩）。
★ 可與 `feat/orderbook-tap` 合併成同一支交付（兩者都是床/觀測層），或分開隨你，做完一起 handback。地基 KEEP。


## ★T4 追加（同票、比 T1/T2 更影響結論可信度）：`watch_prefixes` 抓錯 key
`exam_12mo_bed.gd:136` 現為 `["death.", "site_memory.", "need.", "diplo", "alliance", "betray", "faction."]` → **對 production 政治 key 一個都對不上**（實際是 `envoy.*`／`g3.betrayal`／`g2.faction_found`／`cohesion.*`；`diplo`/`alliance` 這兩個字開頭的 key **在 production 根本不存在**）→ 大考「政治質地」欄本輪**全 0 是 artifact**。
- **改**：prefix 加 `"envoy."`、`"g3."`、`"g2."`、`"cohesion."`、`"reaction."`（reaction 家族現在會 fire、值得看）。
- ★**但真正的防線是 orderbook tap 票裡的「結尾 dump 全量 `Probe.counts`」**——prefix 永遠可能漏，全量 dump 讓「漏了就救不回」結構上不可能發生。**兩者都要做。**
