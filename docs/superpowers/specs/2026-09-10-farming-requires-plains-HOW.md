# HOW spec：農田限平原（`required_terrain`）

owner: systems ｜ 2026-09-10 ｜ player_reachable: no ｜ 用戶裁「1 做」｜狀態：R² CLEAN（item2/3 已補）⇒ 可 dispatch

上游：養活力卷坐實「地形自給上限＝10 人」＋ 農田**目前沒有地形限制**
⇒ 用戶裁：**農田限平原**。

## §1 修法（★一行，用現成機制）

```gdscript
outpost_system.gd  FACILITY_DEF["farming"]
+   "required_terrain": "plains",     ← ★照抄 stable（:126）的同一個鍵
```
★**機制與檢查點都已存在**：
```
outpost_system.gd:619-620
   if def.has("required_terrain") and tile.terrain != def["required_terrain"]:
       if Probe.enabled: Probe.bump_pt("wall.reject_terrain", _wday2, team.team_id)
⇒ ★★連 tap 都現成 ⇒ 上線當天就量得到它咬了幾次。
```
★★★**不新增任何機制、不動 worldgen** —— 這是本票最重要的性質。

## §2 ★★★存量農田處置（systems 裁，用戶指定由我定）

**裁：在【建址】擋，不在【產出】擋。既有農田不追溯、照常產出。**

```
(a) 建址時擋（outpost_system.gd:619 的既有檢查）  ← ★採用
(b) 產出時擋（resource_system.gd:131 加地形條件）  ← ★★不採用
```

★**理由（三條，按重要性）**：
```
①★★★同一個規則放在兩個地方【必然 drift】—— 那是我們今天拆了一整天的東西。
  `required_terrain` 已經是「能不能蓋」的唯一真相源,產出端【不要】再判一次。
②不追溯沒收：★已經蓋好的東西突然停產,對 NPC 與玩家都是【無法預期的損失】,
  而它沒有換到任何東西 —— 規則的目的是【約束未來的建址】,不是懲罰過去。
③★★★**這支 codebase 沒有【讀檔恢復 WorldState】的路徑**（R² 2026-09-10 查實，比我猜的更硬）：
  ```
  全庫的寫檔命中都在 scripts/debug/*_bed.gd（specimen dump，唯寫不讀回）
  observer_main 的 save/load ＝ 讀 config JSON 生新世界／讀 script resource／截圖 —— 沒有一條讀寫 WorldState
  game_setup / world_generator 對 `farming_level` 零命中（worldgen 不播種存量農田）
  tile_data.gd:28  var farming_level: int = 0   ★沒有任何讀檔路徑會覆寫它
  ```
  ⇒ ★存量農田的池子**不是「現在空」，是【結構性空】** —— **它不可能非空**，除非未來加存檔系統。
  ⇒ ★★所以「不追溯」在現況下**不會造出例外池**；而**明寫它**，是為了**未來真的加存檔時這條規則仍然說得清楚**。
```

★**誠實限**：採 (a) 之後，**一座在規則上線前蓋在山上的農田會永遠繼續產出**。
⇒ **那是刻意的**，而**不是漏掉的**。

## §3 ★★連帶：四支床直接構造非平原農田

```
grep -lE "farming_level *= *[1-9]" scripts/debug/*.gd  ⇒ 4 支：
   expand_bigvillage_bed / headless_test / labor_marginal_v2_test / observer_inspect_test
```
★**採 (a) 之後它們【不會壞】**（產出端沒加條件）⇒ **本票不動它們**。
★★**但要在票裡【逐支確認它們構造的 tile 是什麼地形】並回報**：
```
若某支床把農田蓋在【山地】上,那它餵的是【世界（規則上線後）不會產生的輸入】
⇒ ★★★那是今天那條「床餵了世界不會產生的輸入」的新實例
⇒ 而處置【不是本票改它】,是【回報清單】,由我逐支裁（同 bed-kind 的逐批裁決）。
★★★**而這份清單完稿後【必須真的寄一封 handback】**（R² 要求）——
   不能只留在本票的驗收段落裡，否則它是【落地但沒通知】：
   ★寫在 diff 裡而沒進信箱 ＝ 沒有人會回頭裁它。
```

## §4 驗收

```
①【擋得住】在山地/森林 civilian 據點嘗試蓋農田 ⇒ ★被擋 ＋ `wall.reject_terrain` 計數 +1
  ★★成對對照：平原上同樣的嘗試 ⇒ 【成功】（否則這格可能是「什麼都擋」）
②【不追溯】預先在山地放一座 farming_level=2 的農田 ⇒ ★規則上線後【照常產出】
  ⇒ ★★這格證明 (a) 而不是 (b) —— 它是本票 HOW 裁定的守衛
③★★★【咬不咬人】raw / eff / gate（接線票必備格）：
   raw ＝ `wall.reject_terrain` 的計數（斷言掛這裡：★必須 > 0，否則規則沒有母體）
   eff ＝ 因此【沒蓋成】的農田數（只印不斷言）
   gate＝因此改變了建設決策的隊數（只印不斷言）
   ★誠實限：短窗下 eff/gate 只能回答「沒翻轉」
④【四支床】逐支回報它們構造農田的 tile 地形（★清單，不改它們）
⑤★可達區間先算（界限第八條）—— ★★★**而我原本標錯了誰依賴它（R² 訂正）**：
  ```
  ①② 是【手動構造場景】（放一支隊在手選的 tile 上直接呼叫建造）⇒ ★不吃母體,隨時可測
  ★★真正吃母體的是③的 `raw`（`wall.reject_terrain` 計數必須 > 0，那是【斷言】）
     —— 它只能從一個【真的在跑】的世界量出來（隊自己選址、自己決定要不要蓋）
  ⇒ ★★★⑤決定的是【③】有沒有母體，不是①。
  ```
  ★**而母體風險的形狀 R² 也查了，跟我想的不一樣**：
  ```
  decision_context.gd:465   var _farm_pot: float = 0.4 if terrain == "mountain" else 1.0
  ⇒ ★選址【只罰山地】,森林與平原同分（1.0）
  ⇒ ★★所以「落在山地」可能真的稀少（選址本來就懲罰它），
     而「落在森林」【不見得稀少】 ⇒ ★★★③的母體要看【森林】的比例，不是只看山地。
  ```
```

★誠實限：本票**不改** `FARM_UNIT_YIELD`、不改 `REGEN_RATE`、不動「一塊地養 10 人」那個上限
（用戶已裁「3 先認後面再調」）。
