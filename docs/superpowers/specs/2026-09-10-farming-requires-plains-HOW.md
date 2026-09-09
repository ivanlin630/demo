# HOW spec：農田限平原（`required_terrain`）

owner: systems ｜ 2026-09-10 ｜ player_reachable: no ｜ 用戶裁 2026-09-10「1 做」

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
③★世界是 fresh-start：`tile_data.gd:28  var farming_level: int = 0`
  ⇒ ★★新世界【沒有存量農田】⇒ 存量問題在真實跑面上是【空母體】,
    ★★★而我【不假設它永遠空】（存檔／長跑 session 會有）——所以才要明寫「不追溯」。
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
⑤★可達區間先算（界限第八條）：plains 佔 50%（地形卷）⇒ ★★civilian 據點落在非平原的比例
  【要先量】—— 若它接近 0，那 `wall.reject_terrain` 會接近 0，而①那格會【永遠綠不了】。
  ⇒ ★★★這一格【先跑】，它決定其餘驗收有沒有母體。
```

★誠實限：本票**不改** `FARM_UNIT_YIELD`、不改 `REGEN_RATE`、不動「一塊地養 10 人」那個上限
（用戶已裁「3 先認後面再調」）。
