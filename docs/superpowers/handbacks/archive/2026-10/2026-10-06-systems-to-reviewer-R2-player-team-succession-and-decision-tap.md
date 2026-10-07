---
from: systems
to: reviewer
status: consumed
slice: 故事結束之後原玩家隊照 NPC 的路補領袖（＋決策 tap）
topic: ★**R② 送審**｜spec ＝ `A:/GDS/demo/docs/superpowers/specs/2026-10-06-player-team-succession-after-story-end-HOW.md`｜sha `251d668f7`（★遠端 tip 同一顆）｜★序：藍圖裁**排在威脅欄那張之前**｜★★請優先打 §3 的爆炸半徑與 §4b ② 的 T1
---

# 範圍（全文，新票）

```
§1 刀 1 的殘留：`event_system.gd:72-86` 在設 game_over 的同一分支 return false ⇒ 繼承停止
§2 抽 `_npc_succession` 單一定義；handle_player_succession 在 game_over 之後 return 它
§3 爆炸半徑：`on_leader_death` 回傳值唯一讀者 `npc_combat_system.gd:786-790` ⇒ 勢力交出／保留改變
§4 P1-P6 ／ §4b 藍圖兩件：P7 全世界 leaderless 掃描 ／ ② 決策 tap（T1-T3）
```

# ★★我知道的弱點

```
(a) §3「唯一讀者」是 `git grep "on_leader_death("` 數的：faction_ai_system:1549／subteam_system:294 不讀回傳值、
    npc_combat:786 讀 ⇒ ★我**沒查** `handle_player_succession` 的回傳值有沒有經別的包裝往上傳
(b) ② T1「在合成點記不准重算」—— 我只找到 `rank_scored`（:79）與 `rank_scored_ctx`（:267）兩支，
    **沒核**掠奪那一輪實際走哪一支、也沒核「需求層加權」「人格調製」是不是在那兩支裡算的
    ⇒ 若其中一層在別處算，T1 的「同一處」就不成立 ⇒ 請你判：spec 該寫成「先查」還是我現在就該補錨
(c) P7「≥1 天」的時鐘：我沒指定用哪個欄位判「變 leaderless 的時刻」（今天可能沒有這個欄位）
    ⇒ 若沒有，P7 只能在**每天邊界取樣**、連兩次都 leaderless 才算 ⇒ 這樣寫夠不夠？
(d) 我預測 fp 不變（fp 床 player_id=-1，那支不動）—— 預測不是授權，P5 寫了「先量」
```

⇒ CLEAN 我就派（插在威脅欄之前）；ISSUES 請指名哪一列。
