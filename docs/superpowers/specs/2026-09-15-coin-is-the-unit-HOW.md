---
owner: systems
status: 裁定版（v2 — 原「補一行常數」版【撤銷】）
date: 2026-09-15
supersedes: 本檔 v1（`BASE_PRICE["coin"] = 1.0`）
---

# 裁定：原票撤銷，拆成兩票

## ① 原票錯在形狀，不是錯在方向

v1 要的是 `BASE_PRICE["coin"] = 1.0`。**撤銷。**

- `trade_valuation.gd:173-175` **已經有** `if res == "coin": return 1.0`
  ⇒ 「coin ＝ 1.0」**不是新規則**，它已經在 `local_value()` 裡了。
- 補進表 ⇒ **表與函式各有一份真相**（我們今天才為「兩處同型」記過一次）。
- ★★★**而更硬的理由是型別**：`BASE_PRICE` 是**商品表**，交易迴圈對「每一個有價的資源」做買賣配對
  （`interaction_system.gd:1291/1325/1332`、`player_trade_system.gd:39/45`、`player_api_mapper.gd:860`）
  ⇒ 補表 ⇒ **coin 變成一種可賣可換的商品**，「用 coin 換 coin」**型別上成立**。
  ⇒ ★**那是型別錯，不是數值錯** —— 而型別錯不能用「反正 1.0 是對的」抵銷。

## ② root：病在需求，不在定價（★靜態必然，非推測）

`maintain_coin` 0 次的原因，鏈條每一節都讀得出來：

```
goal_resolver.gd:44   status = effective_holding(coin) < NeedOracle.need_keep(coin) ? active : satisfied
need_oracle.gd:82     need_keep = _self_use + _supply_chain + _construction_facility_need
  _self_use            :236-249  coin 非 food／非 goods／非 PURE_INTERMEDIATE ⇒ 落末行
                                 pop × TARGET_PER_POP.get(res, 0.0)
                                 ★ trade_valuation.gd:30-51 的 TARGET_PER_POP 【沒有 coin 鍵】⇒ 0
  _supply_chain        :254-276  coin 不是任何配方的 `in`（manufacturing_system.gd 零筆 "coin"）⇒ 0
  _construction_...              建造成本明文「無 coin、無有限資源」
                                 （outpost_system.gd:9 ／ :94）⇒ 0
⇒ need_keep(state, team, "coin", *) ≡ 0.0
⇒ holding ≥ 0 ⇒ `holding < 0` 恆 false ⇒ status 恆 satisfied
⇒ 永不進 frontier ⇒ derived_payoff 0 次
```

★**兩條獨立證據對上了**：implementer 的**實跑 0 次**（4320 tick／seed 1337）
與此處的**靜態恆 0**（由表的缺席推出）—— 一條量到、一條證出來。

⇒ **待驗的那句話結案**：「這個世界的隊伍，從來不會因為想要錢而去做任何事」**成立**，
  ★★而**原因不是錢沒有價格，是這個世界裡沒有「想要錢」這個需求**。

## ③ ★★★真正的病：同一個形狀在兩張表上

`BASE_PRICE` 缺 coin、`TARGET_PER_POP` 缺 coin。
⇒ ★**每張 per-resource 表的預設值都是 `0`，而 `0` 在語意上是「不存在」，不是「零」**
⇒ coin 在每一條路上都被**靜默地**當成不存在，而缺席不會叫。

★★**而 `local_value():173` 的那個特判，就是補丁閘的教科書例子**：
有人已經撞過這個洞，修法是**在一個函式裡特判**，不是**修表**
⇒ 補丁把洞遮起來，洞在**其餘 37 處照樣開著**，而且從此沒人會再撞到它。
⇒ **de-patch 方向＝取價單一入口，不是再加一個特判。**

# 票甲：取價單一真相（seam 收斂）

**★先驗先行**（沿用 v1 的「先驗後修」紀律）：
- 38 處中 **C 類「固定鍵索引」8 處讀得出字面鍵** ⇒ **靜態可判**，直接列表。
- **A 類「單鍵 `.get(res, ...)`」9 處的 `res` 是變數** ⇒ **要 runtime**：
  量「這 9 個呼叫點中 `res == "coin"` 的次數」。
- **若全 0** ⇒ 不一致是**潛伏**（給未來的陷阱），**不是現行 bug**
  ⇒ 修法降級成機械收斂：`.get(res, 0.0)` → `local_value()`／共用取價函式，**零行為變**。
- **若非 0** ⇒ 有現行 bug，逐處判，**不准整批套同一個修法**。

**驗收必有一格**：★★**fp 不變＝等價，而等價不證明被走到**
⇒ 要一顆 tap 證「新路徑真的被走到」——`local_value()` 內 `:180-190` 已有同型 tap 可抄。

**不在範圍**：不拆 `local_value():173` 的特判（收斂完才談）。

# 票乙：coin 的需求是衍生的（機制）

**★禁手抄物理**（本專案既有立法）：**不准往 `TARGET_PER_POP` 塞 `"coin": N`**
—— 那是「一支隊每人該有 N 塊錢」的手抄常數，**三個月後又爛**。修法形狀＝**改接線，不是改數值**。

**★★正確接線**：**錢的需求＝它要買的東西的預算**
⇒ `need_keep(coin)` 由**已經存在的 gap** 導出：
`Σ over res：max(need_keep(res) − holding(res), 0) × 取價(res)`，
**只算這支隊打算用買的**（而非自產的）—— 也就是 `_supply_chain` 的錢版。

**★★★遞迴 hazard 具名**：若 `need_keep(coin)` 反過來呼叫 `need_keep(res)`，
而任何 res 的鏈又回到 coin ⇒ 無限遞迴。
⇒ **硬約束：coin 必須是這張 DAG 的葉 —— coin 的 need 計算內禁再算 coin。**
（`_supply_chain` 已有兩層遞迴守衛的前例，可沿用其形狀。）

**驗收**：★這一票會**第一次**讓世界裡有「想要錢」這件事
⇒ 必問 **`maintain_coin` 會不會一上來就贏過一切**。
★**若它突然佔據 argmax 的多數 ⇒ 回報，不要在票裡壓它** —— 壓它是灌水，
正確的處置是問「為什麼缺口那麼大」。

**序**：**票乙等票甲** —— 它要用取價函式，而取價現在有兩份真相。

# 不做 / 另立

- **不**補 `BASE_PRICE["coin"]`。
- **不**碰 `local_value():173`（票甲收斂完才談）。
- `maintain_material` **85% payoff ＝ 0**（implementer 側報，未查）⇒ **另立一條**，不併本票。
- `faction_ai_system.gd:4654` 的逐鍵迴圈：implementer 已查證 coin gap ＝ 0 ⇒ **安全**，
  但它在票甲後應一併走取價函式。
