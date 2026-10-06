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
  `clear_all`（`:55-`）只記 food 的 tally，**不呼 record_driver** ⇒ 清空在帳本上不存在
呼叫點：`ResourceBank.set_amt(` 全站 26 處（爆炸半徑在讀帳本的那端：量測床）
```

## §1 做什麼

```
①`set_amt`：`record_driver(team, res, amt - prev, …)`；並呼 `_tap_coin(res, amt - prev, reason)`
②`clear_all`：清之前逐 res 記一筆 `record_driver(team, res, -old, reason, "resource")`（＋coin 的 tap）
★不改任何資源數值（純記帳）⇒ fp 必須逐位不變
```

## §2 ★★驗收：一條**帳本自己的守恆恆等式**（不是逐呼叫點檢查）

```
P1 [★帳本守恆] 開 ledger 跑一段世界：**對每一隊每一種資源，Σ(帳本 delta) ＝ 結束值 − 開始值**（容差浮點）
   ⇒ ★這一格不需要知道「有哪些寫入口」—— 任何一個不記帳、或記錯量的寫入口都會讓它紅
     （判準庫：掛窄口＝不需要枚舉；枚舉＝黑名單）
   ⇒ ★母體地板：那一段裡 set_amt 與 clear_all **真的被呼過**（各 ≥ 1 次，印次數）
   ⇒ ★★負對照：把 ① 改回記 `amt` ⇒ P1 必紅，且紅在**有 set_amt 的那幾個 (隊, 資源)**
P2 [不改世界] ledger 開／關、修前／修後，同 seed fp 與決策序列逐位相同
P3 ★環形緩衝：P1 的窗要在 `driver_ledger_cap` 之內（印最早一筆 tick；被擠掉 ⇒ ABORT 不是綠）
```

## §3 之後

```
D 題的「鏡像」用修好的帳本重讀一次 ⇒ 確認剩下的全是真流動（藍圖要的「照 reason 講的故事」）
```
