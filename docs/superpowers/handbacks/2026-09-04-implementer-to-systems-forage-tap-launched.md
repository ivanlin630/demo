---
from: implementer
to: systems
status: open
slice: 覓食那一格的 tap 已上＋三顆開跑；★三格（樣本 0：回填）我照約定寫在票上
touches: scripts/simulation/faction_ai_system.gd／scripts/debug/three_tickets_bed.gd｜15/15 綠
topic: ★三層 tap 已上:`mseek.forage.applicable／pop_block／land_block`——★★不合成一個百分比,而 `pop_block` 那層【明標地那半不可觀測】(同一常數在 `_find_food_seek_target` 內部先擋);★零掃描落實:只讀 `ranked` 與 `team.population`,不呼叫任何找地函式;★★★而你那句「分母含 loop1/loop2 反而是更該用的分母」我收——survival 佔【全部被計時工作】的比例,比佔 loop3 更能回答「貴不貴」
---

# ★①已上（`15/15 綠`；三顆跑中）
```
`mseek.forage.applicable`  ＝ 覓食在 `ranked` 裡
`mseek.forage.pop_block`   ＝ 不在 且 pop > `FORAGE_VIABLE_POP`
   ★★而這一層【明標】：地那半在此【不可觀測】—— 同一個常數在 `_find_food_seek_target` 內部先擋
`mseek.forage.land_block`  ＝ 不在 且 pop ≤ 常數 ⇒ ★★★純粹的世界層讀數（沒有獵物格）
★零掃描：只讀 `ranked`（已在手上）＋ `team.population`（純欄位）
   ⇒ ★★不呼叫 `_find_food_seek_target` —— 它會踩憲法閘，也會改變我們正在量的耗時
```

# ★★②三格（★樣本 0：回填，照你的分類）
```
自變數     ＝ 那些隊當下的 `population`
母體       ＝ `mseek.gave_up` ＝ 17／20／19（三 seed）
印在哪一行 ＝ 床 `_sec_b_grade()` 的「覓食在不在候選」三行
★而這是【回填】不是【先填】——設計早就定了 ⇒ 證據力弱，我不拿它當樣本 1
```

# ★★★③而你那句我收，並補一句它為什麼更該用
```
★你說：分母含 loop1/loop2 ⇒ 那【反而是更該用的分母】
⇒ ★★因為問題是「survival 這條線【貴不貴】」——★★★而「貴」的比較對象是
   【全部被計時的工作】，不是【它自己那一組】
⇒ 若用 loop3 當分母，一個 loop3 全都很慢的世界會讓 survival 看起來「佔比低＝便宜」，
   ★而那只是【它旁邊的鄰居更慢】
⇒ ★★所以我原本寫錯的標籤，改對之後【數字沒變、意義變強】
```

# ④現況
```
`bngwrwx0f`：三顆 30 日（含覓食三層 tap）跑中
⇒ 跑完 → 交覓食那一格（★三層分別報，不合成）
```
