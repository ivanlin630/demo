# HOW spec：計畫用的移速接上【執行端真正的每格成本】

owner: systems ｜ 2026-09-09 ｜ player_reachable: no ｜ 狀態：待 R²
上游：TEST VALUE 普查第一批①（blueprint 裁「先開」，(ii) 型、證據最硬）

## §1 病：決策層拿著一個【那支隊沒有的速度】在做計畫

```
goal_resolver.gd:1023  const MOVE_TILES_PER_DAY: float = 2.0   # TEST VALUE — 移速估（淺啟發）
goal_resolver.gd:1033  days += _hex_dist(team.tile_pos, target) / MOVE_TILES_PER_DAY
★而執行層算的是【逐隊真成本】：
movement_system.gd:216 `_compute_team_speed` → :190-214 `_move_cost`
  含：named/anon 速度加權、坐騎、車輛、★地形、★疲勞、★超載
  :214 return clamp(int(round(BASE_MOVE_TICKS / speed)), MIN_MOVE_TICKS, MAX_MOVE_TICKS)
⇒ ★★計畫與執行【用不同的數】。而症狀出現在【執行端】（走不到／延遲），
   ★★★沒有人會回頭懷疑決策端的一個常數 —— 這就是 (ii) 型比 (i) 型危險的地方。
```

## §2 ★★★單位鐵則（違反即整票變成更錯的值）

```
★天真代換會壞：`_compute_team_speed` 回的【不是】tiles/day,
  它是餵給 :214 的中間量,而 :214 回的是【每格 tick 成本】。
★★正確推導：
     tiles_per_day = float(TICKS_PER_DAY) / float(_move_cost(state, team))
     days          = hex_dist / max(tiles_per_day, ε)
★★★用【成本】不用【速度】：成本那一版已經含地形/疲勞/超載/車輛,而且被 clamp 在
   [MIN_MOVE_TICKS, MAX_MOVE_TICKS] ⇒ 不會除爆。
⇒ 若有人直接拿 `_compute_team_speed` 代進去,結果會差約 TICKS_PER_DAY 倍。
```

## §3 修法

```
①`_move_cost` 需可從決策路徑呼叫（目前是 instance `func`）——
   改 static 或提供 static wrapper。
★★★【我先前寫「零副作用」是錯的,在此更正】：:194 與 :211 有兩處
   `if Probe.enabled: Probe.bump("rootdiff.TERRAIN_SPEED_MULT" / "rootdiff.WAGON_TERRAIN_MULT")`。
   它不耗 RNG（不違反「觀測者禁耗 global RNG」),但它【是寫入】——
   ⇒ 從決策路徑再呼叫一次,這兩個計數會【混入決策端的呼叫】,
     而它們原本的語意是「執行端走了幾格」。任何讀這兩格的分析/床都會被改。
★★修法（二選一,實作者挑,理由寫進 handback）：
   (a) 抽出 `_move_cost_pure(state, team, time_mult)` 不含 Probe.bump,
       執行端 `_move_cost` 呼叫它再自己 bump ⇒ 計數語意不變、決策端不污染。★推薦。
   (b) 決策端呼叫時傳 `probe := false` 旗標。★較差：旗標會被忘記傳。
⇒ 驗收要多一格：`rootdiff.TERRAIN_SPEED_MULT` 的計數在 before/after 【不變】。
②`goal_resolver.gd:1033` 改用 §2 的推導。
③`MOVE_TILES_PER_DAY` ★連常數一起刪（不留沒人用的），只留一行註解說明舊版。
```

## §4 驗收（★成對 + 單位健全性）

```
①【腦看得見】同世界 before/after：
   ★慢隊（重載/疲勞/惡地形）的計畫天數【變長】
   ★★快隊（有坐騎/輕載/平原）的計畫天數【變短】
②【不亂動】速度落在舊估值附近的隊 ⇒ 計畫天數變化很小
③★★★【單位健全性】典型隊的 tiles_per_day 必須與舊常數 2.0 【同一個數量級】。
   ⇒ 若差約 TICKS_PER_DAY（~1440）倍 ⇒ ★單位接錯,不是發現。
   ⇒ 若差 2–3 倍 ⇒ ★★那才是發現（舊估值本來就不準）。
   —— 這一格專門把【單位 bug】與【真實差異】分開,不要合成一個「數字變了」。
```

## §5 誠實限

```
①★`_move_cost` 用【當前 tile 的地形】與【當前疲勞】⇒ 這是「以現況估」的 ETA,
   不是路線平均。★★而執行端每一步用的也是同一種現況估 —— 兩邊【同源】,
   這正是本票要的（一致），不是精確路線預測。
②★★★仍然不含：路線上的地形變化、途中疲勞累積、被打斷。
   ⇒ 本票把【平版猜測】換成【與執行端同源的現況估】,不是換成【準確的 ETA】。
③本票只改 goal_resolver 那一處用法；若別處另有移速估算，本票不碰（未普查）。
```

## §6 鐵則
```
★決策路徑【禁寫快取】—— `_move_cost` 每次算（它很便宜：無迴圈外的 IO）。
  要快取由 movement_system 在自己的 advance 路徑寫，決策端只讀。
★★不動 movement 的任何常數（BASE_MOVE_TICKS / MIN / MAX / TERRAIN_SPEED_MULT）。
```
