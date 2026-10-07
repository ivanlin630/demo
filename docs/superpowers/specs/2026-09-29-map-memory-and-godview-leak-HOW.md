# HOW spec：地圖記憶（探索過的格）＋ 地圖上的 god-view 漏

owner: systems ｜ 2026-09-29 ｜ **player_reachable: yes**
上游：blueprint 票 `2026-09-29-blueprint-to-systems-TICKETS-map-memory-plus-godview-leak-and-text-ui-layout-v2.md`
序：#8 → #7 → **本票** → 探索床 → #10

---

## ★★★§1 前提（逐字 file:line）

```
①`text_map_renderer.gd:55`  var explored: bool = in_vision  # TODO
   ⇒ ★`explored` **就是** `in_vision` ⇒ `:68 elif explored:`（小寫地形）那一支
     **永遠到不了**（前面 `:66 elif in_vision:` 已經先接走）
   ⇒ ★★所以那不是「功能沒做」，是**一個從來沒 fire 過的分支 ＋ 一個替它解釋的 TODO**
②`text_map_renderer.gd:78-83 _visible_team()`：只要 `discovered.has(tid)` 就用
   **live 的 `team_at`** 畫出它 ⇒ ★★★**一旦發現過，那隊此刻在哪都畫得出來** ＝ god-view 漏
   （感知鐵律：位置只能在【此刻真的看得見】時用真值，否則走 `belief_pos`）
```

## ★★★§2 一個【會讓半張票變成假修】的前提，必須先量

```
★①的修法是「讀 `state.team_tile_known[player_tid]`」（既有 belief 表、不新增儲存）
★★而 `harvest_tile_known()` 全庫只有兩個呼叫點，兩個都在【NPC 決策路徑】裡：
   ·`faction_ai_system.gd:7610`（在 `_find_occupy_target` 裡；production 呼叫端＝
     `decision_context.gd:778`／`options.gd:218`）
   ·`strategic_ai_system.gd:315`（在 `_find_trade_partner` 裡 —— ★該檔自己的註解寫著
     **它今天沒有任何 production 呼叫點**，且有 defer 在追）
★★★而**玩家隊在 faction_ai 的決策路徑上有多處 early-return**
   （`:2166`／`:4557`／`:6125` 都是 `leader_id == player_id ⇒ return`）
   ⇒ **玩家隊的 `team_tile_known` 很可能是空的**
   ⇒ 那麼「改讀 belief 表」之後畫面**一格小寫地形都不會出現** ＝ **假修**
   ⇒ ★而它的長相會是「做完了、而畫面沒變」—— 跟 faction_ai:7608 那段註解自己警告的
     「team_tile_known 恆空 ⇒ 長得像修好了」是同一個坑。
```

### ⇒ ★★所以本票**分兩段**，段1 是唯讀量測

```
段1（唯讀，先做，10 分鐘）：印 `state.team_tile_known.get(player_tid, {}).size()`
  ·非空 ⇒ ②那一半可以純 render 做 ⇒ 照 §3 走
  ·★空 ⇒ **blueprint 已預裁（2026-09-29，8edefa413）**，而他的形狀比我提的好：
    ★★★**不准為玩家隊開一條 harvest 特例** —— 那違反 #43「玩家隊零特毊物理」
      與資訊網「一個訊息模型零特例」。
      ⇒ ★真因是 **harvest 掛錯層了**：它掛在【NPC 決策路徑】裡
        （`_find_occupy_target` 內；`strategic_ai` 那一支還沒有 production 呼叫點）
      ⇒ ★★**知不知道一格是【感知】的事，不是【決策】的事**
      ⇒ ★★★修法：tile 知識 harvest **搬到感知層、對全部隊跑**
        （跟視野更新同一趟：`sim_runner.gd:743 _step1b_update_vision`
         → `VisionSystem.tick_discovery()`，註冊在 `:221` 的 `grp: "hour"`）
        ⇒ fp 變、基準同 commit 落地；★render 側仍禁 harvest。
    ★★★而我要把一件 blueprint 沒提的代價寫在這裡：成本。
      `harvest_tile_known()` 是一個 **(2r+1)² 的方形迴圍**（`VISION_RADIUS = 3` ⇒ 49 格）
      × 每隊 × 每個 hour-tick ⇒ ★**要量 per-tick 成本，不得只看功能**
      （而它本來就只在【有隊在找佔領目標】時跑過 ⇒ 次數會長很多）
      ⇒ ★★P5 多一欄：**改前後的 per-tick 中位數與 p99**（不是撇絕門檿，是要有數）。
    ⇒ ★★那是寫入 ⇒ **world-fp 會變** ⇒ 與 blueprint 「純 render、fp 不變」的假設衝突
    ⇒ ★★★而 render 路徑**不得自己 harvest**（`render-no-write` 已 merged）——
      所以這不是實作端可以繞過的，它是一個要 blueprint 知道的代價。
段2：依段1結果做（見 §3）
```

## §3 做什麼

```
(A)★god-view 漏（★**純 render、與段1 無關，可先做**）：
   `_visible_team()` 拆成兩條
   ·視野內（`dist <= VISION_RADIUS`）⇒ 用 live 位置（★那是「此刻真的看得見」）
   ·視野外 ⇒ 用 `BeliefSystem.belief_pos(player_tid, tid)`，並在畫面上**標不確定**（`?` 或淡色）
   ★★`belief_pos` 的 fallback 鐵則：無有效／過期 belief ⇒ 回 `(-1,-1)`
     ⇒ **那一格就不要畫那支隊**（★絕不退回自身位置或 live 位置）
(B)地圖記憶（段1 非空才做）：`explored` 改讀 `team_tile_known[player_tid]`
   ·畫小寫地形；★記得的據點用 `known_outpost_at()`（既有）不要 live 讀 `tile.outpost_owner`
   ·★★把 `:55` 那個 TODO 連同「explored = in_vision」一起拿掉 ——
     ★★★留著它就是留一個「替死分支解釋的註解」
```

## §4 驗收

```
P1 [god-view 關掉] 造一支【發現過但此刻在視野外】的隊 ⇒ 地圖**不得**畫在它的 live 位置
   ｜★負對照：把 `_visible_team` 改回 live ⇒ 必紅
   ｜★★母體地板：先斷言那支隊**真的被發現過**（`team_discovered` 含它）且**真的在視野外**
P2 [belief 過期就不畫] 讓那支隊的 belief 過期 ⇒ `belief_pos` 回 (-1,-1) ⇒ 那一格不畫它
   ★這一格守的是「絕不退回 live」——★★而它是 P1 的補集，缺了它 P1 可以用「畫在舊位置」蒙過
P3 [地圖記憶] 走過一格再離開 ⇒ 該格印**小寫地形**而不是 `?`
   ｜★★★母體地板（本票命門）：**先印 `team_tile_known[player].size()`**
     ⇒ 為 0 就不是「記憶沒生效」，是**段1 的前提不成立** ⇒ 床要把這兩件分開講
P4 [TODO 不留] `grep 'explored: bool = in_vision'` 零命中；`grep 'TODO'` 在該檔零命中
P5 [fp] (A) 純 render ⇒ world-fp **不變**
   ★若段1 逼出 sim 側 harvest ⇒ **fp 會變** ⇒ 基準值與改動同一顆 commit，且**回報 blueprint**
P6 ui-flow 綠；merge 前全電池 BATTERY_RC=0
```

## §5 不在本票

```
✘ 讓 `_find_trade_partner` 接進 production（它有自己的 defer）
✘ #10 版面 v2（排最後）
✘ ★`post_buy_order`／`post_sell_order` 在 TextUI 零引用 —— blueprint 已裁併進 #10
```

## ★§6 誠實限

```
①全靜態 file:line，沒跑 Godot。
②★我**沒有實際量**玩家隊的 `team_tile_known` 是不是空的 —— 我只證明了
  「它的兩個寫入點都在 NPC 決策路徑，而玩家隊在那些路徑上有 early-return」
  ⇒ ★★所以段1 是量測不是形式：**我提出的是懷疑，不是結論。**
③★★★`belief_pos` 對玩家隊有沒有資料，我同樣沒量 —— 但它的寫入點（vision／message）
  不在玩家 early-return 的那幾支上，所以我**預期**它非空。★而 P1／P2 會逼它現形。
```

## ★★★§7 可視化（blueprint AMEND 2026-09-29，01b07679a）＋HOW 補的兩件

### WHAT 定的字元語言（用戶 2026-10-07 點頭，藍圖 `98493cd95`；取代舊四態稿）
```
一格只印一個主字，由上往下搶：
 ① @        你
 ② a–z      看得到的隊伍（代號表見下，與右欄同一份）
 ③ 據點圖示  已知據點（belief 裡有的）；擁有者在游標處看
 ④ a?       記得的隊伍，畫在 belief_pos（不是 live）；過期不畫
 ⑤ P F M    視野內地形｜p f m 記得的地形｜? 沒去過
同格並存 ⇒ 高壓低；被壓掉的在游標處那一行全列
游標處只印已知與預估（最後所知幾小時前、估計人口）；真值只在 debug pane（TEXTUI_DEBUG_PANE=1），每行帶「附身者不知道」
```

### HOW 定的三件（字元選擇與代號表）
```
①據點圖示（ASCII，圖例常駐地圖標題列）：
   ^ 村（civilian）｜# 營（military）｜$ 市集（tile 在 team_market_known[玩家隊] 裡；市集壓村）
   ★只畫 known_outposts(state, 玩家隊) 裡有的格，不讀 live 的 tile.outpost_*；市集同理只讀 team_market_known
②★隊伍字母不得撞地形小寫：p f m 已被「記得的地形」佔用 ⇒ 隊伍字母表＝a–z 去掉 f m p（23 個）
   ⇒ 否則「看得到的隊 p」與「記得的平原 p」在畫面上同形（兩種意思一個字）
③代號表一份、一個產生點（例 sim_bridge／mapper 出 `team_codes`），地圖、右欄清單、游標處三處同讀：
   母體＝這一幀【畫得出來】的隊（看得到的＋belief 未過期的），按 team_id 排 ⇒ 依序配字母
   ★不用右欄清單順序當代號：右欄只列可互動目標（pending_targets），記得的隊不在裡面，翻頁也會讓字母換人
   超過 23 支 ⇒ 第 24 支起印 *，在游標處列出
   右欄每列前印同一個代號（例「[1] b Team5 …」）
```

### ★HOW 補一：記號只有 **4 個字元**的空間
```
現成格寬：`"%s   "`（非游標）／`"[%s] "`（游標）⇒ **實字只有 1 個**
⇒ ★據點記號【不得把格擐寬】（擐寬就毀了 axial 切變的列對齊）
⇒ ★★所以記號寫在【第 2 個字元】：`p*  ` —— 只占原本的空白，總寬仍是 4
⇒ ★★★而他隊的 `N?` 本來就是 2 字元 ⇒ 同一個預算，不衝突
```

### ★★★HOW 補二：「最後見到：第 N 天」對大多數格子【問錯了問題】
```
★`team_tile_known` 的值形狀（`belief_system.gd:493-514`）：
   ·普通格：`known[tid] = true`  ← ★**一個 bool，沒有 tick**
   ·只有 `_entry["outpost"]` 子記錄帶 `last_tick`
⇒ ★★所以 blueprint 的 fallback「沒 tick 就印不記得何時」會是**常態而不是例外**
⇒ ★★★而更重要的：對【地形】問「最後見到何時」**本身就不成立** ——
   `belief_system.gd:487-500` 已經釘死那個區分：
     「我見過這塊地」**不會過期**（地不會走）
     「它當時有一座 L 級據點」**會過期**（可能被拆／易主）
⇒ ★所以游標面板分三句，而不是一句帶 fallback：
   ·地形      ⇒「記得（地形不會變）」★**不印「不記得何時」** ——
                  那句話暗示【記憶缺了一塊】，而真相是【這個問題不適用】
   ·記得的據點⇒「最後見到：第 N 天」（讀 `outpost.last_tick`，除 TICKS_PER_DAY）
   ·記得的他隊⇒「最後見到：第 N 天」（讀 belief 的 `last_tick`）
★★而若用戶真的要【地形也有最後見到】⇒ 那要在 `team_tile_known` 存 per-tile tick
   ⇒ **資料形狀改動 ⇒ fp 變** ⇒ ★★★登待辦，不在本票偷渡
```

### ★R² 打回（b9c3a5381）：用結構擋 live tile，不靠記得
```
今天 _cell()（text_map_renderer.gd:41-46）同一個 scope 裡握著 live 的 HexTileData ⇒ 讀 tile.outpost_* 是最順手的錯路
⇒ 拆成兩段：
   ①_belief_overlay(state, player_tid) -> Dictionary（每幀一次）：只呼 BeliefSystem.known_outposts／team_market_known／team_codes／belief_pos，
     產出 {tile_key: {outpost_glyph, team_code, remembered_code}}；★它不接 HexTileData
   ②_cell() 改收 terrain 字串＋overlay 那一格的值 ⇒ ★_cell 簽名裡不再有 HexTileData
     （地形讀 live 合法：地不會走；視野外但記得的格本來就印同一個地形）
P9b grep：text_map_renderer.gd 內 `outpost_` 出現次數＝0（據點只經 overlay 進來）
    ｜反向：在 _cell 裡加一行讀 tile.outpost_level ⇒ 必紅
```

### 驗收補三格（照新字元語言改寫）
```
P7 [五層分得開] 一個畫面同時出現 @／隊伍字母／據點圖示／x?／大寫／小寫／? 
   ｜★母體地板：先斷言每一種【各至少一格】—— 否則「分得開」在只有一種的畫面上恆綠
P7b [優先序] 同一格放一支看得到的隊＋一個已知據點 ⇒ 印隊伍字母；游標處列出那個據點
P7c [最後所知不是 live] 隊伍走出視野 N 小時 ⇒ 字母變 x? 且位置＝belief_pos；★負對照：改讀 live ⇒ 必紅（同 P1）
P7d [代號一致] 同一幀地圖上的字母與右欄、游標處的字母指同一支隊（逐支比對）
P7e [不撞字] 隊伍字母表不含 f m p；★反向：塞一支會配到 p 的隊 ⇒ 不得印 p
P8 [圖例] 地圖標題列的圖例存在，且五層與三種據點圖示都在裡面
   ｜★負對照：新增一種而不加圖例 ⇒ 必紅（圖例與字元表同一處維護）
P9 [格寬不變] 每格仍是 4 字元（x? 與據點圖示都在同一個預算內）
```

## ★★★§8 三層一張圖（blueprint AMEND 9b）＋★★★HOW 抳出一個真缺陷：畫面的「現在看得到」用錯了來源

### WHAT 定的三層（全收）
```
現在  半徑内＝真值
記得  最後一次观測：地形永久／據點到被否證／他隊到 `BELIEF_STALE_TICKS` 過期
聆說  relay 進 belief 的，**同畫法**，來源只在面板
★renderer 只畫 belief store 說的：【不自己模糊、不自己過期、不自己算半徑】
  ·模糊 → 資訊模型（distorted claim）；renderer **不得畫回真位置**
  ·過期 → `BELIEF_STALE_TICKS`（`belief_pos` 已回 (-1,-1)）
  ·子隊在外＝另一支隊，回報到了才進你的表
```

### ★★★HOW 抳出的缺陷：「半徑】在 sim 裡**每隊、随時間變**，而 renderer 用平常數
```
`text_map_renderer.gd:4`  const VISION_RADIUS: int = VisionSystem.VISION_RADIUS
                          # 註解寫「引用 sim 權威源（單一真值）」
`text_map_renderer.gd:54` var in_vision: bool = dist <= VISION_RADIUS      ← ★平半徑
★而 sim 的【單一權威】是一支**函式**（它自己的註解就寫「單一權威」）：
  `vision_system.gd:11 vision_range(state, team, time_vision_mult)`
    = roundi((VISION_RADIUS + 偵查技能 * SCOUT_BONUS) * 地形倍率 * 時間倍率)
  ⇒ ★★**有偵查的隊看得比地圖畫的遠**；地形與日夜也會移動那條線
  ⇒ ★★★而 `:4` 那行的註解【是假的】：它引的是**基底常數**，不是權威函式
     （同一族：「註解替它編好了理由」）
```
**⇒ 裁定**：`in_vision` 必須呼 `VisionSystem.vision_range(state, player_team)`
（★它是**純讀**，不寫 state ⇒ `render-no-write` 仍然成立）；
★★`:4` 那一行要麼刪掉、要麼把註解改成真話（「這是基底值，不是有效半徑」）。
★★★**訂正（blueprint 收窄、我核完）：那個誠實限【不必存在】**——
  我核了整條鍵，**全部是純函式**：
```
day_night_system.gd:31 get_vision_mult(state)  → get_time_period(state)
  → get_time_of_day(state) = float(state.world.current_tick % TICKS_PER_DAY) / TICKS_PER_DAY
★全檔零寫入（唯二的 `.append` 在別的函式裡、對局部陣列）
⇒ ★★**renderer 拿得到它** ⇒ 不必用預設 1.0、也不必在圖例旁寫落差
```
  ★而有兩件 HOW 要釘：
   ①`sim_bridge.gd` 目前**沒有日夜出口**（grep `day_night`／`vision_mult`／`time_period` 零命中）
     ⇒ ★★加**一支唯讀 accessor**（例 `get_vision_mult()`），
       ★**不得讓 renderer 直接伸進 `_state`** —— 同【單一咽喉】那條
   ②`DayNightSystem` 的方法是**非 static**（需實例）
     ⇒ 用 runner 已有的 `_day_night_system` 那一份，★**不要每幀 `new()`**（它無狀態，
       所以 new 不會錯——但那是【每幀配置一個物件】，沒理由）
★舊的誠實限（以下一行）已作廢，留它是為了記住它曾經存在：
~~日夜倍率是 sim 傳進來的，renderer 拿不到 ⇒ 它只能用預設 1.0~~
  ⇒ 那一段差要**寫在圖例旁邊或面板裡**，不要默默吃掉。

### 驗收補四格（前三是 blueprint 的、第四是本節抳出的）
```
P10 [過期由 sim 決定] 把 `BELIEF_STALE_TICKS` 改大一倍 ⇒ `N?` 活一倍
    ｜★守的是「renderer 不自己過期」：若 renderer 自己算，這一格不會動
P11 [失真不被修回] 餵一筆 distorted claim ⇒ 畫在**失真位置**且面板標「聆說」
    ｜★★負對照：renderer 改成畫真位置 ⇒ 必紅
P12 [子隊要回報] 子隊走出去而未回報 ⇒ 那幾格仍是 `?`
P13 ★★★[半徑跟得上 sim] 給玩家隊一個高偵查成員 ⇒ **大寫區跟著變大**
    ｜★負對照：用平常數（`VisionSystem.VISION_RADIUS`）⇒ 區域不變 ⇒ 必紅
    ｜★★母體地板：先印 `vision_range()` 的回傳值（基底 vs 加偵查）
      —— 兩個數相等的話這一格恆綠（而那表示樣本選錯了）
```

## ★★★★★訂正（實測回馒 2026-09-30）：P5 那種寫法【預測不是授權】

```
我在 #8 的 P5 寫「fp 會變是預期内的 ⇒ 基準值與改動同一顆 commit 落地」
★實測：fp **逐字不變**（`world_fp_snapshot_bed.gd:99` 設 player_id=-1、
  `:112` 直呼 runner.advance_tick ⇒ 不經 SimBridge ⇒ 那個咽喉在那支床上不可能 fire）
⇒ ★★若實作端照我寫的**預先換 hash** ⇒ **親手弄壞那支闸**，
   而弄壞的長相是「基準值更新了」—— **看起來完全正常**。
⇒ ★★★以後 P5 一律寫成：
   **先量 ⇒ 變了才換基準（同 commit）⇒ 沒變就【不要動】，並把【為何沒變】寫進卷面**
```
