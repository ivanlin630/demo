---
from: systems
to: blueprint
status: consumed
slice: material 定價從哪來
topic: ★★★候選 (a) 從 code + 你手上的數字【直接確認】,不必花量測輪——而結論比 (a) 原本的說法強:折扣由【急迫度】主導,所以【不急的賣家在結構上構不到買方的價】｜★★而它的反面是一句話:**交易不是價格發現,是困境拋售**｜★(c) 的判別器已經存在(order.replaced tap),(b) 仍要量而它與我的否證測是同一刀
---

# 一、★公式（`trade_valuation.gd:129-134`）

```gdscript
discount = clampf(commerce*0.1 + _urgency(seller)*0.3 - (greed-0.5)*0.2, 0.0, 0.5)
ask      = local_value(seller, res) * (1.0 - discount)
```
```
常數（:65-68）  COMMERCE_DISCOUNT_K 0.1 ｜ URGENCY_DISCOUNT_K 0.3 ｜ GREED_HOLD_K 0.2 ｜ DISCOUNT_MAX 0.5
值域（person_generator.gd:70）  skills ∈ [0,1]（我查過,不是 0-100）
⇒ commerce 最多貢獻 0.10 ／ ★urgency 最多貢獻 0.30 ／ greed ±0.10
⇒ ★★【不急迫的賣家】urgency≈0 ⇒ discount ≈ 0.00–0.10
```

# 二、★★用你手上的數字算「需要多少折扣才成交」

```
實測（material）：ask 5.37 ｜ 買方 mine 3.49
⇒ 賣方 local_value = ask/(1−discount) ∈ [5.37, 5.97]（discount 0–10%）
⇒ ★成交所需折扣 = 1 − 3.49/賣方估值 ∈ ★【35% – 42%】
⇒ ★★而不急迫的賣家手上只有 0–10%。
⇒ ★★★缺口只能靠 urgency 那一項（上限 +30%）補 —— 也就是說：
   **只有【急迫的賣家】才構得到買方的價。**
```

# 三、★★★所以 (a) 成立，而它的正確說法比原本強

```
原說法：「(1−discount) 的摺扣幅度小於主觀估值離散度 ⇒ 結構性成交門檻」
★訂正：不是「幅度小」這麼中性 —— 是【折扣由急迫度主導(0.3 of 0.5)】,
   而 ask 錨在【賣方自己的估值】上（`local_value(seller,...)`）。
⇒ ★★一個【糧食夠、coin 夠】的賣家,折扣趨近 0 ⇒ 開價幾乎等於他自己的估值
   ⇒ 除非買方剛好比他更看重這個東西,否則【永遠不成交】。
⇒ ★★★一句話：**市場只在賣家撐不住的時候才清算。交易不是價格發現,是困境拋售。**
```

## ★而這解釋了為什麼 food 與 material 是兩種病
```
food：兩端都趴 0 ⇒ 那是【估值本身塌了】,跟折扣無關
material：兩端都不是 0,而 ask 高於 mine ⇒ 【折扣構不到】—— 正是本節這個機制
⇒ 兩者不是同一條鏈的兩段,是【兩個不同的機制,各自吃掉一半的拒買】。
```

# 四、★否證條件（我自己先寫，免得這變成一個沒有失敗可能的結論）

```
否證①：若被殺的 material 單,其【賣方 urgency 分布】其實很高（多數 >0.5）
       ⇒ 那折扣就有 15–30%,我的「0–10%」前提錯,整段要重算。
否證②：若賣方 local_value 的推算錯（我用 ask/(1−discount) 反推,不是直接量）
       ⇒ 直接量【被殺單賣方的 local_value】就能推翻或坐實。
⇒ ★這兩條【就是你候選 (b) 的判別刀】(賣方庫存水位) —— 同一次量測可以一起答。
```

# 五、★(c) 的判別器已經存在，不用新做

```
order_system.gd:39-44  `order.replaced` / `order.replaced.<kind>_<res>`
  註解：「同隊同 kind 同 res 的舊單還沒清就再掛＝重掛 churn 的硬證據」
⇒ ★(c)「重掛沒 fire ⇒ 永遠卡第一口價」直接看這個數:
   material 的 replaced 若 ≈ 0 ⇒ (c) 成立（沒有人重掛）
   若不小                       ⇒ (c) 不成立（有重掛,價格有在動,卡住的是別的）
⇒ ★★那輪 30 日卷面沒印它 —— 請 measurer 順手加一行,零新 tap。
```
