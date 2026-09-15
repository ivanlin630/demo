# `coin` 價格的爆炸半徑 ＋ `maintain_coin` 是 dormant（2026-09-15）

## ① ★★★`maintain_coin`：**一次都沒出現** ⇒ **dormant 註冊，不是恆 0 候選**

跑法：herald @ `602b43b70`｜seed 1337／4320 tick｜逐型計 `derived_payoff` 的呼叫
原始：`docs/measurements/2026-09-15-goal-payoff-by-type-raw.txt`

```
   maintain_tools      1415 次｜payoff 恰好 0：   0（0%）
   maintain_weapons    1329 次｜payoff 恰好 0：   0（0%）
   build_stable         352 次｜0
   maintain_material    194 次｜payoff 恰好 0： 165（**85%**）
   build_workshop/apothecary 各 186 次｜0
   maintain_food        167 次｜payoff 恰好 0：  39（23%）
   build_weaponsmith/armorsmith 各 8 次｜0
   **`maintain_coin`：0 次** ⇒ ★**它從來沒有被解析過** ⇒ **病在【提名】不在【定價】**
```
★**所以「這個世界的隊伍不會因為想要錢而做事」這句話成立，而原因不是價格是 0** ——
**是那個 goal 根本沒有被生成。** ★★兩者的修法完全不同。

## ② ★★而 code 裡【已經有】「coin ＝ 1.0」這條規則

```gdscript
# trade_valuation.gd:173-176（local_value 內）
if res == "coin":
    return 1.0   # currency: always face value, no supply/demand modulation
if not BASE_PRICE.has(res):
    return 0.0
```
⇒ ★**「coin 以 coin 計價 ＝ 1.0」不是新規則，它已經在估值函式裡了。**
⇒ ★★**真正的病是【兩條路不一致】**：
   **走 `local_value()` 的呼叫點 ⇒ coin ＝ 1.0｜直接 `BASE_PRICE.get(res, 0.0)` 的 ⇒ coin ＝ 0**
⇒ ★★★**所以 spec 的形狀應該是「讓兩條路一致」，而不是「補一個常數」** ——
  **後者會讓表與函式各有一份真相。**

## ③ 爆炸半徑（★母體 38 處，★★而判準寫在這裡：**非註解行提到 `BASE_PRICE`**）

```
A 單鍵 `.get(res, …)`   9 處 ⇒ ★只有 res == "coin" 時值會變
B 逐鍵／整表            14 處 ⇒ ★★**加一個鍵會多跑一圈** —— 逐處具名判（下表）
C 固定鍵索引            8 處 ⇒ ★鍵都不是 coin（food／material／recipe 的 res）⇒ 不受影響
D 宣告本身              1 處
E 別名綁定              2 處（`var bp = BASE_PRICE`，皆在 headless_test）⇒ 用途同 B，隨其判
F 純字串／訊息          4 處（print 文字提到 BASE_PRICE）⇒ ★**不是讀取**
對帳：9 + 14 + 8 + 1 + 2 + 4 ＝ **38 ＝ 母體** ⇒ ★**沒有「其他」這一桶**
★★systems 說 32 處 —— 差額來自判準（我算「非註解行提到」，含 print 與 assert）
```

### B 類逐處具名判（★★systems 指定 `faction_ai_system.gd:4654` 必須具名）

```
`faction_ai_system.gd:4654` `for res in BASE_PRICE:` ⇒ 內部 `local_value(merchant, res, state)`
   ⇒ ★coin 走 `local_value` ⇒ **1.0**；而 `their_val_est` 只對 `food/material` 特判
   ⇒ **coin 的 `gap = |1.0 − 1.0| = 0`** ⇒ ★★**不影響 `max_gap`** ⇒ **安全**（多跑一圈、結果不變）
`interaction_system.gd:1291/1325/1332`（賣 surplus／以物易物配對）
   ⇒ ★★★**危險**：**coin 會變成一種【可被賣掉、可被拿來交換】的商品**
   ⇒ **「用 coin 換 coin」在型別上會成立** —— ★**這一處必須在 spec 裡具名處理**
`player_trade_system.gd:39/45`／`player_api_mapper.gd:860` ⇒ 同上（玩家側清單會多出 coin）
`trade_valuation.gd:175` `if not BASE_PRICE.has(res)` ⇒ ★coin 在 `:173` 就 return 了 ⇒ **不受影響**
`money_genesis_bed.gd:144`／`headless_test` 的 5 處 assert ⇒ **床與測試**，會多一列／多一個鍵 ⇒ 需更新期望
```

## ★結論（★而它改變了 spec 的形狀）

```
①**`maintain_coin` 是 dormant** ⇒ ★**本票不能靠它驗收** —— 它驗不到任何東西。
②**「coin ＝ 1.0」已經存在於 `local_value`** ⇒ ★★**要做的是【讓繞過它的那些呼叫點也一致】**。
③**最危險的一處是交易迴圈**（`interaction_system` 三處）⇒ ★★★**補表會讓 coin 變成商品**
  ⇒ **而那不是「一行常數」的範圍。**
```
