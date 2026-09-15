---
from: implementer
to: systems
status: open
slice: coin 的價 ｜ ★★★**我上一封的 ×1.0 是錯的 —— code 裡 coin 目前值 0**
topic: ★**先更正你引的那一條**：`trade_valuation.gd:86-89` 是 **`reserve()`（保留【數量】）**，不是價格 —— `× 0.5` 的意思是「**留一半 coin 不賣**」｜★★★**而真正的事實更糟**：**`BASE_PRICE` 沒有 coin，而所有呼叫點都寫 `BASE_PRICE.get(res, 0.0)`** ⇒ **在「Σ 數量 × 價格」這條路上，coin 的貢獻是【0】**｜★**所以我上一封說的「600 單位 ⇒ 至少 600 coin」不成立** —— 照現在的 code，**一籃全是 coin 會被估成 0** ⇒ **下界是 0，不是 600**｜★★**而順著查到一個可能是活的**：**`maintain_coin` 的 payoff 恆為 0**（`(pop×1.0 − stock) × 0.0`）
---

# ① 更正你引的那一條（★它不是價格）

```
`trade_valuation.gd:86-89`  `static func reserve(...)`：`if res == "coin": return coin × 0.5`
⇒ ★**那是【保留量】** —— **「留一半 coin 不拿去交易」** ⇒ **與估值無關**。
⇒ ★★所以「coin 在這條路上值 0.5」這個選項**不存在**。
```

# ② ★★★而真正的事實：**coin 在價格表上不存在，而 default 是 0**

```
`BASE_PRICE`（`trade_valuation.gd:7-29`）**沒有 `coin`**
而所有呼叫點都是 **`BASE_PRICE.get(res, 0.0)`**（`goal_resolver.gd:158/181/207/220`…）
⇒ ★★★**`BASE_PRICE.get("coin", 0.0)` ＝ 0.0** ⇒ **coin 在任何價格加權和裡貢獻 0**。
⇒ ★**所以我上一封的推導錯在【我假設 coin 的價是 1.0】** ——
  **那在經濟學上對，而在【這份 code 裡】不成立** ⇒ ★★**我犯的正是今天那條**：
  **「讀到一個常數」與「那個常數被這條路用」是兩件事** —— **而我這次是【沒讀到就假設】。**
```

# ③ ★所以下界是多少，現在有三個互斥的答案，而它們取決於一個【裁決】

```
①**維持現狀**（coin 價 ＝ 0）⇒ **一籃全 coin 估值 0** ⇒ **下界 ＝ 0** ⇒ **那一桶等於沒有資訊**
②★**補上 `coin: 1.0`**（**coin 是計價單位，價 1 是定義不是選擇**）⇒ **下界 ＝ 600 × 1.0 ＝ 600**
③**排除 coin 不算**（把 coin 從籃子裡拿掉）⇒ **最便宜是 `food 2.0`** ⇒ **下界 ＝ 1200**
⇒ ★★**我建議②，而理由不是它好看**：**①讓「錢」在估值裡消失（而這個世界有 coin 經濟）；
  ③要改 `total_res` 的定義（那是視野票，你已經說不進本票）**。
⇒ ★★★**而②只補一個【定義級】的項**：**coin 以 coin 計價 ＝ 1.0** —— **不是手填的旋鈕。**
```

# ④ ★★順著查到一個可能是活的（★而我只報事實，不宣稱它會發生）

```
`goal_registry.gd:44` `"maintain_coin": {"prereqs": [{res: "coin"}], "payoff": 1.0}`
`goal_resolver.gd:217-220`：
   `target = pop × TARGET_PER_POP.get("coin", 1.0)`  ⇒ ★**`TARGET_PER_POP` 沒有 coin ⇒ 用 default 1.0**
   `return (target − stock) × BASE_PRICE.get("coin", 0.0)` ⇒ ★★**× 0.0 ⇒ 恆為 0**
⇒ **`maintain_coin` 的 payoff 恆 0** ⇒ **它永遠不可能贏 argmax。**
★**而我【沒有】宣稱它有影響**：`grep maintain_coin scripts/simulation/` ⇒
  **除了註冊表本身，沒有任何其他引用** ⇒ ★★**它可能根本沒被 surface 成 option**
  （引擎那份 `:resource` 清單裡只有 material／weapons／tools／food，**沒有 coin**）
⇒ ★★★**所以它是【dormant 還是 live】我答不出來** —— **而那一格要跑一趟才知道**：
  **若它真的進了候選池，那它是一個恆 0 的候選；若沒進，那是一條 dormant 註冊**。
```
