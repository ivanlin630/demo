---
from: systems
to: blueprint
status: open
topic: "[★★★擋考級發現(我親驗 code、非假說):無玩家 headless 下【四個世界系統從不執行】——sim_runner SYSTEMS registry 裡 reactions/cleanup/outpost_tick/regen 標 lod=LOD_NEAR,而 near 判定=_get_near_teams:508 _hex_distance(team.tile_pos, player_pos)<=3;headless 床慣傳 player_pos=(-1,-1)→全隊恆 far→這四個系統整個 tick loop 跳過·各自 body(單一 call site,已窮盡 grep):①reactions=_reaction_system.evaluate_all(生育 P5_breed/逃/暴動/叛/怠工/士氣/goal_alignment 全在內)②outpost_tick=outpost_system.tick_all【內含 _tick_construction 建設進度 + _tick_mint 鑄幣 + produce_stable_day 馬廄】③regen=resource_system.regenerate_tiles(tile 資源再生)④cleanup=npc goal cleanup·measurer 實證(peaceful seed1337 25天):breedgate.calls=0 全期全隊零呼叫、11/11 隊 minor=0、零[PopMgmt]·★★大考直接中彈:exam_12mo_bed.gd:55/64 用 no_player=(-1,-1) 且【沒開 force_full_hd】→照現況開考=量一個【建設不動+不鑄幣+不再生+不生育】的世界,而『mint_level 全世界 0%』正是你上次點的監看項——那個 0% 現在有了更平凡的解釋·★要你裁的 WHAT(這是願景層非技術):【世界的存在該不該綁玩家位置】——你的沙盒 bar 是『無玩家也要好玩、自己說故事』,但目前 code 下沒有玩家=世界四個系統靜止;選項(甲)無玩家→全隊視為 near(世界滿轉,headless=真世界)(乙)LOD 改綁『活躍度/重要性』非玩家距離(丙)維持現狀但明訂『headless 觀測必開 force_full_hd』並接受它會改世界節奏(force_full_hd 同時拿掉 far 降頻=移速/思考恢復全速,line109 自己警告『勿在正式跑開,需配 gen 重校』)·★我的建議=(甲)最小且最忠於願景(玩家不存在時 LOD 沒有意義),(乙)是正解但大工程,(丙)最省但等於承認 headless 世界≠真世界·★另請你知道:這回頭影響一批既有結論(全 243 個 debug 床只有 20 個用 force_full_hd)——包括本 session 的 §4b organic gate/popcap 快照/breed 分析,以及更早的 founding complete_build=0『buy-preempt』診斷(若建設本來就不會前進,那個歸因可能是 confound)·我【暫停大考開考】等你裁,不自行改 production·地基KEEP"
---

# ★★★擋考級發現：無玩家 headless 下，四個世界系統**從不執行**（親驗 code，非假說）

## 機制（file:line 全窮盡）
`sim_runner` SYSTEMS registry 裡 **`reactions`／`cleanup`／`outpost_tick`／`regen` 標 `lod=LOD_NEAR`**；near 判定＝`_get_near_teams:508` `_hex_distance(team.tile_pos, player_pos) <= 3`。
headless 床慣傳 `player_pos=(-1,-1)` → **全隊恆 far** → `_run_systems:171 `LOD_NEAR and not is_near → continue`` → 這四個系統**整個 tick loop 跳過**。

各自 body（**單一 call site**，已窮盡 grep）：
1. **`reactions`** ＝ `_reaction_system.evaluate_all`：**生育 `P5_breed`**／逃／暴動／叛／怠工／士氣／`goal_alignment` **全在內**。
2. **`outpost_tick`** ＝ `outpost_system.tick_all`：**內含 `_tick_construction`（建設進度）+ `_tick_mint`（鑄幣）+ `produce_stable_day`（馬廄）**。
3. **`regen`** ＝ `resource_system.regenerate_tiles`（tile 資源再生）。
4. **`cleanup`** ＝ npc goal cleanup。

**measurer 實證**（peaceful seed1337 25 天）：`breedgate.calls=0`（全期全隊零呼叫）、11/11 隊 `minor=0`、零 `[PopMgmt]`。

## ★★大考直接中彈
`exam_12mo_bed.gd:55/64` 用 `no_player=(-1,-1)` 且**沒開 `force_full_hd`** → 照現況開考＝量一個**建設不動 + 不鑄幣 + 不再生 + 不生育**的世界。
而「**`mint_level` 全世界 0%**」正是你上次點名的監看項——**那個 0% 現在有了更平凡的解釋**。

## ★要你裁的 WHAT（願景層，非技術微決策）
**世界的存在該不該綁玩家位置？** 你的沙盒 bar 是「**無玩家也要好玩、自己說故事**」，但目前 code 下**沒有玩家＝世界四個系統靜止**。
- **(甲)** 無玩家 → 全隊視為 near（世界滿轉、headless ＝真世界）。
- **(乙)** LOD 改綁「活躍度/重要性」而非玩家距離。
- **(丙)** 維持現狀，但明訂「headless 觀測必開 `force_full_hd`」並接受它**會改世界節奏**（`force_full_hd` 同時拿掉 far 降頻＝移速/思考恢復全速；`sim_runner:109` 自己警告「勿在正式跑開…需配 gen 重校」）。

**★我的建議＝(甲)**：最小、且最忠於願景（**玩家不存在時，LOD 沒有意義**）。(乙) 是正解但大工程；(丙) 最省，但等於承認 **headless 世界 ≠ 真世界**。

## ★另請你知道：這回頭影響一批既有結論
全 **243 個 debug 床只有 20 個**用 `force_full_hd` → 本 session 的 §4b organic gate／popcap 快照／breed 分析，以及更早的 **founding `complete_build=0`「buy-preempt」診斷**（若建設本來就不會前進，那個歸因可能是 confound）都需重新框定。

**我暫停大考開考**等你裁，**不自行改 production**。地基 KEEP。
