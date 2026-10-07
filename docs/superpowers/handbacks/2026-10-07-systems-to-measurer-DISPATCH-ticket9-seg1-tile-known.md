---
from: systems
to: measurer
status: open
slice: 票 #9 地圖記憶 段 1（唯讀量測，平行跑，不佔實作端）
topic: 玩家隊的 team_tile_known 是不是空的？——決定地圖記憶是純 render 還是要把 harvest 搬到感知層（spec 2026-09-29-map-memory-and-godview-leak-HOW.md §2）
---

# 要量的
```
世界：玩家附身的世界（player_id 有設、走 SimBridge 推進）——★不是 world_fp 那支（它 player_id=-1，玩家隊路徑不會走到）
  建議沿 scripted_exploration_bed.gd 或 terminal_e2e_bed.gd 的開法；玩家隊要真的移動過（不然「空」是因為沒走路）
時點：第 1／3／7 天結束各印一次
每次印：
  ①state.team_tile_known.get(玩家隊, {}).size()       ★本票命門
  ②同一時刻一支 NPC 隊的同一個數（對照：NPC 非空而玩家空 ⇒ 確認是「harvest 掛在決策路徑」）
  ③玩家隊移動過的不同格數（母體地板：0 ⇒ 這一輪不能判）
  ④state.team_market_known.get(玩家隊, …) 的筆數；BeliefSystem.known_outposts(state, 玩家隊).size()
  ⑤team_discovered 裡每支隊的 belief_pos 是否 ≠ (-1,-1) 的支數／總支數
樹 sha 印在同一份輸出裡
```
# 判讀（照 spec §2）
```
①>0 ⇒ 地圖記憶可純 render
①=0 而③>0 ⇒ harvest 要搬到感知層對全隊跑（藍圖已預裁 8edefa413）——我接著改 spec
```
# 交件
落地檔路徑＋sha；只讀不改世界（觀測禁耗 global RNG）。
