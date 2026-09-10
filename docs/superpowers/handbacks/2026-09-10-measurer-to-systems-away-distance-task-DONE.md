---
from: measurer
to: systems
status: open
slice: 不在家是不是只是在田裡
topic: ★交件+意外發現:不是「遠派vs田間半徑」二選一——day60的13支不在家隊裡12支(92%)【無自家outpost可比】(_find_own_outpost回傳-1,-1)，只有1支真的量到距離(=3，剛好卡邊界)。這是方法論落差:_find_own_outpost只查team自己擁有的outpost,跟is_resident_static的「家」定義(自己的或同faction的)不一致——這12支隊很可能是透過「同faction outpost」取得居民身分,本身沒有自己的outpost
---

# 交件

```
.measure.json：docs/process/verdicts/away-distance-task.measure.json
raw log：docs/measurements/2026-09-10-away-distance-task.txt
床：scripts/debug/away_distance_task_bed.gd
窗：warring_states/seed=1337/60天，5次快照(同resident-identity-vs-position卷可比)
```

# ★★★意外發現——不是你原本問的那個問題

```
day60不在家13隊：
  有距離可算=1隊(team36, dist=3, 剛好卡田間半徑邊界)
  無自家outpost可比=12隊(92%)——_find_own_outpost回傳(-1,-1)
day10/20/30/45：全程0隊有距離、2-6隊無自家outpost可比——同型態貫穿全程
```

⇒ 這不是『遠派vs在田裡』二選一，是方法論落差：`_find_own_outpost`
(faction_ai_system.gd:6628)只查『team自己擁有』的outpost，而`is_resident_static`
判定居民身分時的『家』定義更寬(自己的outpost或同faction其他隊的outpost都算)。

# 推論(標明是推論非實測)

```
這12支隊的resident身分，極可能是透過『站在同faction其他隊的outpost上』取得的，
本身從未擁有自己的outpost——離開那個位置後，_find_own_outpost自然找不到參照點。
非bug，是我用錯了跟is_resident_static語意不匹配的查詢函式。
```

# 若要真的回答『在田裡vs遠派』

```
需要換一個更貼近is_resident_static語意的outpost查詢(掃全部同faction outpost
取最近距離，不只查team自己擁有的)——本卷未做，跑法你裁是否要補測。
```

誠實限完整版見.measure.json（含team36那1筆樣本n=1不能當趨勢）。
