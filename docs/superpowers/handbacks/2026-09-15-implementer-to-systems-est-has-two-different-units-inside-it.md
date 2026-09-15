---
from: implementer
to: systems
status: open
slice: CAP 那一格 ｜ ★★★**我查了 `est` 的單位，而它【有兩種】**
topic: ★`faction_ai_system.gd:379-384` `_belief_richness()` 有**兩條回傳路徑**：①有 `coin_est/food_est/material_est` ⇒ **`(coin + food + material) / 100.0`** ②只有 `resource_scale` ⇒ **直接回那個 0..3 的【桶號】**｜★★★**所以 tier1 的 `est = 2.0 / 3.0` 不是資產估計，它是【桶的編號】** —— 而我實測 tier1 的 p10/p50/max ＝ **2.0 / 3.0 / 3.0**，**逐字吻合**｜★★**而第一條路徑本身也不是 coin 當量**：**coin 與 food／material 是不同單位，它把三個數【直接相加】再除以一個手填的 100**｜★**所以 CAP 那一格不能先填** —— **要填的是【單位】，不是上限**
---

# ① 證據（★file:line）

```gdscript
# faction_ai_system.gd:379
static func _belief_richness(bel: Dictionary) -> float:
    if bel.has("coin_est") or bel.has("food_est") or bel.has("material_est"):
        return (coin_est + food_est + material_est) / 100.0     # ★★不同單位【直接相加】
    if bel.has("resource_scale"):
        return float(bel.get("resource_scale", 0))               # ★★★回【桶號 0..3】
    return 0.0
```
★**實測對得起來**（n=400 逐 tier）：
```
   tier0  est 恆 0
   tier1  p10 **2.0**｜p50 **3.0**｜p90 3.0｜max **3.0**   ← ★**這是桶號，不是資產**
   tier2  p10 0.021｜p50 3.785｜p90 17.6｜max 24.269        ← （coin+food+material）/100
```

# ② ★★★這讓 spec 的①整個換題

```
★spec ① 問「`x` 怎麼來（現在是 `est/3.0`，而 3.0 的註解寫 tier0/1 的 0..3）」
⇒ ★★**真正的問題不是除數選 3 還是別的** —— **是被除的那個東西有兩種單位**：
  **tier0/1 給【桶號】、tier2 給【混合資產和/100】** ⇒ **除以同一個數，本來就沒有意義**。
⇒ ★★★**而註解裡那句「tier0/1 的 `resource_scale` 是 0..3」其實是【誠實的】** ——
  **寫註解的人知道它是桶號** —— **問題是 tier2 走的是另一條路，而公式只有一條。**
```

# ③ ★★而「混合資產和」本身也不是 coin

```
`coin + food + material` ⇒ ★**coin 是錢，food／material 是【數量】** ——
  ⇒ ★★要變成 coin 當量應該是 **`coin + food × BASE_PRICE[food] + material × BASE_PRICE[material]`**
  ⇒ ★★★**而那正好就是 `derived_payoff` 的形狀**（`(target − stock) × BASE_PRICE`）
    ⇒ **你說「範本已經在 code 裡」是對的，而要對齊的是【這一層】，不是壓縮那一層。**
★**除以 100 也是手填的** —— ★★而「估算器禁手抄物理」那條在這裡直接適用。
```

# ④ ★我那個「不必挑數字」的 CAP 答案（★而它現在排在單位之後）

```
①**`CAP_L = 1.0`** ⇒ ★**理由不是挑的，是【本票不抬上限】那條**（你 spec §⑤）：
  **維持現有可達上限不變** ⇒ **壓縮只換保序，不換量級** ⇒ **驗收只需驗「分得出肥瘦」。**
  ★★而 `x/(1+x)` 在 `CAP = 1` 時**永遠到不了 1** ⇒ **撞頂比例【由公式保證】是 0**，不必調參。
②**`x` 的分母**：★**不要再挑一個常數** —— **用 `derived_payoff` 已經在用的那把尺**：
  **`UNIT ＝ pop × FOOD_PER_PERSON_PER_DAY × BASE_PRICE[food]`（＝一天生計的價值）**
  ⇒ ★★★**於是 `x` ＝「這個目標值幾天的生計」** —— **無量綱、有物理來源、跨 tier 一致。**
③★**壓縮的對象**：**壓 `loot` 那一段** ——
  ★★理由：`odds` 的「0 ⇒ 整項 0」是**設計如此**（送死沒人幹），**壓整個 `_opp` 會把那條性質
  變成【靠壓縮函式在 0 是 0】而成立** ⇒ ★★★**能力歸能力、機會歸機會，不要混在一個壓縮裡。**
```

# ⑤ 我建議的順序（★而這是你的裁）

```
★**先做【單位統一】**（tier0/1 與 tier2 都輸出 coin 當量）⇒ **再做壓縮**
  ⇒ ★★**理由**：**壓縮是保序變換** —— **它不會修好「兩種單位」**，
    **而先壓縮會讓那個 bug 被一條漂亮的曲線蓋住。**
★★**而單位統一那一步會改行為**（tier1 的值會從「桶號 2/3」變成真的估值）
  ⇒ **它需要自己的驗收**，不該塞進這張票。
⇒ ★★★**所以我建議把這張票拆成兩張，而我不自己拆** —— **你裁。**
```
