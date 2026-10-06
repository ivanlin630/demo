# 帳本的每一筆 delta 加起來必須等於資源的變化（HOW，小票）

```
票源 ＝ 量測員 D 題（`bbdb20e45`，交藍圖）：Team7 food「±200–550 鏡像」查到 = 真流動 ＋ **帳本缺陷**
基準樹 ＝ `a709a32fd`
★它是**觀測儀器**的缺陷（driver-ledger 預設 off，不影響世界、不影響 fp）⇒ 但它讓「試算寫進真帳本」這種嚴重懷疑**看起來成立**
```

## §0 缺陷（我核過）

```
`scripts/simulation/resource_bank.gd:48-53 set_amt`：
  var prev := team.resources[res]; team.resources[res] = amt
  _tally_food(team, res, amt - prev)                          ← ✓ 用變化量
  WorldState.record_driver(team, res, **amt**, reason, …)     ← ✗ 把**新值**記成 delta
⇒ 帳本裡一筆 set 會看起來像「流入了整個存量」⇒ 前後兩筆 set 看起來就是巨大的 ± 鏡像
★同檔另兩個洞（同一族：寫入口沒有完整記帳）：
  `set_amt` 沒呼 `_tap_coin` ⇒ coin 被 set 時 coin 流量 tap 看不到
  `clear_all`（`:55-59`）只記 food 的 tally，帳本只記**一筆** `record_driver(team, "*resources*", 0.0, reason, "bulk")`
    ⇒ ★有記，但 delta＝0、field 不是任何一種資源 ⇒ **逐資源加總時清空不存在**
    （~~原文：不呼 record_driver ⇒ 清空在帳本上不存在~~ —— 我寫完才讀到 `:59`，訂正）
呼叫點：`ResourceBank.set_amt(` 全站 26 處（爆炸半徑在讀帳本的那端：量測床）
```

## §0b ★★R² `4ad9d0ffe` ISSUES（我自己再核過一次，樹 `fe399077e`）：**TileBank 有兩支同款缺陷，範圍要擴**

```
`tile_bank.gd:65-70 set_amt`：註解逐字「同 ResourceBank.set_amt 的理由」、`_tally_food` 用了 `amt - prev`，
  而 `:70 record_driver(tile, res, amt, …)` **記新值** —— 同一個病，連註解都抄了而那一行沒抄
`tile_bank.gd:94-96 pool_set`：連 prev 都沒算，直接 `record_driver(tile, res, amt, …)`
呼叫點：`TileBank.set_amt(` 25 處＋`TileBank.pool_set(` 16 處 ＝ **41 個生產呼叫點**
★★而我自己再讀出一件 R² 沒提的：TileBank 有**兩個不同的庫**記在**同一個鍵**上
  ·公庫 `tile.public_storage`（`:70`／`:78`／`:87`）
  ·自然池 `tile.resources`（`:96`／`:100`）
  ⇒ 五處都記成 `(tile, res, "resource")` ⇒ **帳本分不出是哪個庫** ⇒ 對 (tile, res) 加總 delta 會把兩個庫混在一起
`adjust_person_coin`：R² 核過正確、是 person.coin 唯一寫者 —— 但今天沒有格子在驗
`"*resources*"` bulk 標記：R² 核過**全站零讀者** ⇒ 改成逐資源記，bulk 那筆拿掉
```

## §1 做什麼

```
①`set_amt`：`record_driver(team, res, amt - prev, …)`；並呼 `_tap_coin(res, amt - prev, reason)`
②`clear_all`：清之前逐 res 記一筆 `record_driver(team, res, -old, reason, "resource")`（＋coin 的 tap）；
  既有那筆 `"*resources*"` bulk 標記**保留**（讀它的人可能存在 ⇒ 先 `git grep '\*resources\*'` 列讀者再決定）
③`TileBank.set_amt`：`record_driver(tile, res, amt - prev, …)`
④`TileBank.pool_set`：先取 `prev := tile.resources.get(res, 0)`，記 `amt - prev`
⑤★分兩個庫：帳本條目**加一個鍵** `"store"`（公庫 `"public"`／自然池 `"pool"`；ResourceBank 的不加）
  ⇒ ★**只加鍵、不改既有鍵**（`kind` 有讀者：`scripts/debug/` 至少 `anon_pool_level_bed`／`economic_window_4cell_bed` 讀帳本）
  ⇒ 不動 `record_driver` 的既有簽名（`kind` 刻意無 default）⇒ 用一支薄包裝或帶 store 的新入口，只給 TileBank 用
⑥`clear_all` 的 `"*resources*"` bulk 改成逐資源記（零讀者，拿掉無風險）
★不改任何資源數值（純記帳）⇒ fp 必須逐位不變
```

## §2 ★★驗收：一條**帳本自己的守恆恆等式**（不是逐呼叫點檢查）

```
P1 [★帳本守恆] 開 ledger 跑一段世界：**對每一個 (實體, 庫, 資源)，Σ(帳本 delta) ＝ 結束值 − 開始值**（容差浮點）
   ⇒ 實體＝隊（team.resources）／tile 公庫（public_storage）／tile 自然池（resources）／★人（person.coin）
   ⇒ ★這一格不需要知道「有哪些寫入口」—— 任何一個不記帳、或記錯量的寫入口都會讓它紅
     （判準庫：掛窄口＝不需要枚舉；枚舉＝黑名單）
   ⇒ ★母體地板：那一段裡 ResourceBank.set_amt／clear_all／TileBank.set_amt／pool_set **真的被呼過**（各 ≥ 1 次，印次數；某支 0 次 ⇒ 那一支沒被驗，印出來不准綠著略過）
   ⇒ ★★負對照：把 ① 改回記 `amt` ⇒ P1 必紅，且紅在**有 set_amt 的那幾個 (隊, 資源)**
P2 [不改世界] ledger 開／關、修前／修後，同 seed fp 與決策序列逐位相同
P3 ★環形緩衝：P1 的窗要在 `driver_ledger_cap` 之內（印最早一筆 tick；被擠掉 ⇒ ABORT 不是綠）
```

## §3 之後

```
D 題的「鏡像」用修好的帳本重讀一次 ⇒ 確認剩下的全是真流動（藍圖要的「照 reason 講的故事」）
```
