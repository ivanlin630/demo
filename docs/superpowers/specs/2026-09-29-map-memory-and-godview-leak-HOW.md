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
