---
from: systems
to: reviewer
status: consumed
slice: `_farm_pot` 單一真相源
topic: R² 請審｜★★★我在 spec 裡【先否決了一個看起來更正確的做法】：森林 `_farm_pot` 歸零 —— 因為它是 `settle_site_quality` 的唯一食物潛力項,歸零＝「森林一文不值」,而森林有 raw regen 3.0＋material 12.0,★★且它會一次翻轉 63% 的據點選址｜★改成【換 predicate 不換數值】(沿用既有 0.4)｜★要你審的是:0.4 的【語意變寬而值沒變】會不會讓下一個人讀成「沒動過」
---

# R²：`docs/superpowers/specs/2026-09-10-farm-pot-single-source-HOW.md`

blueprint 已裁序（排 `YIELD_NORM` 之前）與修法形狀（「兩真相源 → 一源兩讀者」，禁第二份手抄地形表）。

## 已坐實的前提

```
outpost_system.gd  FACILITY_DEF["farming"]["required_terrain"] = "plains"（6805eceb 已 merge）
decision_context.gd:465  var _farm_pot: float = 0.4 if _site.terrain == "mountain" else 1.0
                :467     settle_site_quality = clampf(productivity × _farm_pot, 0, 1) × SettlementMemory.quality_multiplier
實測（農田票交件）：civilian 據點 30 座中【19 座在森林】；wall.reject_terrain 兩天窗 4 次
REGEN_RATE["forest"] = { food 3.0, material 12.0 }
```

## 請你審三件

1. **★★★我否決「森林歸零」的理由夠不夠。**
   `_farm_pot` 是 `settle_site_quality` 的**唯一**食物潛力項 ⇒ 歸零 ⇒ 森林選址品質全歸 0。
   我的理由：①森林**仍有** raw regen（3.0 food／12.0 material）⇒ 歸零等於「森林一文不值」＝**另一個錯**
   ②★它會**一次翻轉 63% 的據點選址** ⇒ **一個修 drift 的票不該有那種爆炸半徑**。
   ⇒ **請判：這是【正確的克制】還是【我在迴避一個該做的大改】？**

2. **★`0.4` 的語意變寬而值沒變。**
   現況 `0.4` 的意思是「山不可農」；修後是「不可農」（含森林）。
   ⇒ ★★**值一樣、適用範圍變了** —— 我在 spec 要求把這件事寫進 code 註解，理由是
   **「一個常數的適用範圍變了而值沒變，是最容易被下一個人讀成【沒動過】的改動」**。
   ⇒ **請判這句夠不夠，還是應該【換一個新名字的常數】把語意變化做成不可忽略的。**

3. **★驗收③（選址往平原偏移）我標成「只印不斷言」。**
   理由：它是 `eff/gate` 類（世界狀態的函數）——某個 seed 下若剛好沒有新選址發生，它會是 0。
   ⇒ 斷言掛①（結構：沒有第二份地形清單）②（森林 `_farm_pot` 1.0→0.4）。
   ★**請確認我沒有把【唯一能證明這票有用】的那格降級成裝飾。**

## 我知道的盲區

- `_find_unowned_farmable_tile:4750`（`:465` 註解點名的「既有慣例」來源）**我沒查** ——
  ★**若它也有一份地形判斷，那會是【第三個】真相源**，而本票只修了兩個裡的一個。
- `productivity` 這個欄位怎麼生成的**我沒查** ⇒ 若它本身已經含地形因素，`× _farm_pot` 可能是**雙算**
  （★blueprint 今天才在 `DELIVER_PAYOFF_NORM` 那條提醒過「同一資訊禁進兩次秤」）。

CLEAN 才 dispatch。
