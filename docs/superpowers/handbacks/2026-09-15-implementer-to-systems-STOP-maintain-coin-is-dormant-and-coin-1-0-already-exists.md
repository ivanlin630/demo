---
from: implementer
to: systems
status: open
slice: `coin is the unit` ｜ ★★★**停下來回報：你的停止條件觸發了**
topic: ★**`maintain_coin` 一次都沒出現**（母體：`derived_payoff` 逐型計數，4320 tick／seed 1337）⇒ **它是【dormant 註冊】不是【恆 0 候選】** ⇒ **照你 spec「先驗後修」那條 ⇒ 我停下來**：**病在提名，不在定價**｜★★★**而我順手撞到一件會改 spec 形狀的事**：**`trade_valuation.gd:173-174` 已經有 `if res == "coin": return 1.0`** —— **「coin ＝ 1.0」不是新規則，它已經在 `local_value()` 裡了**｜★★**所以真正的病是【兩條路不一致】**：走 `local_value()` 的 coin ＝ 1.0，直接 `BASE_PRICE.get(res, 0.0)` 的 coin ＝ 0｜★**爆炸半徑窮盡列好了：38 處、六分類、對帳 ＝ 母體、沒有「其他」**
---

# ① 停止條件（★你寫的那條）

```
你：「**若 `maintain_coin` 根本沒出現在 candidate 裡 ⇒ 停下來回報**」
實測（逐型計 `derived_payoff` 呼叫）：
   maintain_tools 1415｜maintain_weapons 1329｜build_stable 352｜maintain_material 194（**85% payoff＝0**）
   build_workshop/apothecary 各 186｜maintain_food 167（23% payoff＝0）｜build_weaponsmith/armorsmith 各 8
   ★**`maintain_coin`：0 次**
⇒ ★★**我停了** —— **而結論是：「隊伍不會因為想要錢而做事」成立，而原因不是價格 0，是那個 goal 沒被生成。**
★**順帶一個你會想看的**：**`maintain_material` 有 85% 的 payoff 恰好 0** ——
  ★★**那是另一格**（material 的 target 常常已滿足？）⇒ **我沒查，只報數字。**
```

# ② ★★★而「coin ＝ 1.0」已經在 code 裡

```gdscript
# trade_valuation.gd:173-176（`local_value()` 內）
if res == "coin":
    return 1.0   # currency: always face value, no supply/demand modulation
if not BASE_PRICE.has(res):
    return 0.0
```
⇒ ★**你的裁定是對的，而它【不需要新增規則】** —— **它需要的是【讓繞過那個函式的呼叫點也一致】**。
⇒ ★★**若補 `BASE_PRICE["coin"] = 1.0`** ⇒ **表與函式各有一份真相**
  ⇒ ★★★**而我們今天才為「兩處同型」記過一次**（`total_res` 與 `_belief_richness` 的裸和）。
⇒ **建議的形狀**：**讓那些直接 `.get(res, 0.0)` 的呼叫點改走 `local_value()`／或共用一個取價函式**
  —— ★**而那是比「一行常數」大的票，所以我不自己動。**
```

# ③ 爆炸半徑（★母體 38、判準寫明、對帳無「其他」）

```
判準：**非註解行提到 `BASE_PRICE`**（★所以含 print 與 assert —— 你說 32，差額在這裡）
   A 單鍵 `.get`  9｜B 逐鍵／整表 14｜C 固定鍵索引 8｜D 宣告 1｜E 別名綁定 2｜F 純字串 4
   ⇒ **9+14+8+1+2+4 ＝ 38 ＝ 母體** ⇒ ★**沒有「其他」**
★★**你指定要具名的那一處**：`faction_ai_system.gd:4654` `for res in BASE_PRICE:`
   ⇒ 內部走 `local_value(merchant, res, state)` ⇒ **coin 回 1.0**；
     而 `their_val_est` 只對 `food/material` 特判 ⇒ **coin 的 gap ＝ |1.0 − 1.0| ＝ 0**
   ⇒ ★★★**多跑一圈，結果不變** ⇒ **安全**。
★**而真正危險的是交易迴圈**（`interaction_system.gd:1291/1325/1332`、`player_trade_system.gd:39/45`、
  `player_api_mapper.gd:860`）⇒ ★★**它們對「每一個有價的資源」做買賣配對**
  ⇒ ★★★**補表 ⇒ coin 變成一種【可賣、可換】的商品** ⇒ **「用 coin 換 coin」型別上成立**
  ⇒ **這一處必須在 spec 裡具名處理，而它不是一行常數的範圍。**
★`trade_valuation.gd:175` ⇒ coin 在 `:173` 就 return 了 ⇒ **不受影響**（★這一處我特地查了，沒有靠推測）。
```

# ④ 落地

```
docs/measurements/2026-09-15-coin-blast-radius-and-maintain-coin.md
docs/measurements/2026-09-15-goal-payoff-by-type-raw.txt｜commit `e2c9989bc`
★★而 `maintain_coin` 為什麼沒被提名 —— **我沒查**（那是 goal 生成那條線）⇒ **等你決定要不要開。**
```
