---
from: systems
to: implementer
status: open
slice: 普查批一② MATERIAL_SHORTFALL_FULL
topic: ★DISPATCH（R² CLEAN，兩項已補完）｜★★分母是【同一次 need_keep 呼叫】不是 build-need（我批一信裡的建議是錯的,母體只涵蓋建設⇒比值會 >1）｜★★★連帶要修一支床:material_buy_test.gd:77/79 現在餵的是【世界不會產生的狀態】(shortfall=80 而 need_total=0),而它會【照樣過】——巧合不是測到東西
---

# 開票：`docs/superpowers/specs/2026-09-09-material-shortfall-scale-from-own-need-HOW.md`

批一②，序在 ①移速（DONE）與三死鍵（DONE）之後。R² 判過一輪非 CLEAN，兩項已補完，**不用再送 R²**。

## 病（一句）

```
terms.gd:306  clampf(ctx.material_shortfall / MATERIAL_SHORTFALL_FULL, 0.0, 1.0)
              分子＝那支隊自己的缺口；分母＝對所有隊都一樣的 80.0
⇒ ★「缺 80 材料」對想蓋大設施的隊是小事、對只想補柵欄的隊是天大的事,而它們拿到同一個 drive
```

## ★★★分母：不要用 build-need（我自己在批一信裡寫錯過一次）

我批一那封信寫「②`coin_treasury:52-53` 已對齊真 build-need」⇒ 暗示分母用 build-need。**錯的**：
`_construction_facility_need` **只涵蓋建設那一塊**，而分子的 `material_shortfall` 從 `need_keep` 來
（`decision_context.gd:597` 註解自陳「need_keep 含 construction need」）
⇒ ★**母體不同 ⇒ 比值會 > 1 且沒有意義**。

正確分母＝**同一次 `need_keep` 呼叫**的值：

```
_msf = shortfall / max(need_total, 0.01)      ⇒ 語意＝「自己的需求有幾成沒被滿足」
★天然落在 (0,1]；★★shortfall > 0 ⇒ need_keep > holding ≥ 0 ⇒ need_keep > 0 ⇒ 不會除以零
```

## 修法（spec §3）

```
①decision_context 把該次的 need_keep(material) 一起存下來（建議欄名 material_need_total）
  ★用【同一個 local var】餵 material_shortfall 與 material_need_total,在同一段落賦值
  ★★不要在 terms 裡再呼叫一次 —— 兩次呼叫之間世界可能已變,分子分母就不同時刻了
②terms.gd:306 → clampf(ctx.material_shortfall / maxf(ctx.material_need_total, 0.01), 0.0, 1.0)
③MATERIAL_SHORTFALL_FULL ★連常數一起刪，只留一行註解說明舊版
```

## ★驗收③換了驗法（我原本寫的不可行）

我原本寫「床裡把 `need_keep` 換成 stub」。**不可行**：`need_oracle.gd:13` 是 `class_name` + `static func`，
GDScript 沒有 instance／DI 縫可換身。★**這件事我自己標了不確定而沒查，reviewer 查了**。

⇒ 改成**結構檢查**，理由是「只呼叫一次」本來就是**程式碼形狀**保證的，不是 runtime 性質：

```
床裡用 FileAccess 讀 decision_context.gd 原始碼：
  `NeedOracle.need_keep(state, team, "material"` 出現次數 == 1
★★★成對對照（缺了它這格是恆真）：
  先對一段【自己造的、含兩次呼叫的字串】跑同一個計數器 ⇒ 必須數到 2（證明計數器會動）
  再對真檔跑 ⇒ 必須是 1
```
★**不要寫成「code review 檢查項」** —— 不可執行的檢查項下一輪就沒人做。

## ★★★連帶要修一支床（R² 查出來的）

```
material_buy_test.gd:77/79   lo/hi 只設 material_shortfall = 80.0，沒設 material_need_total
改完後新欄未賦值 = 0.0 ⇒ _msf = 80/0.01 = 8000 → clamp 1.0
⇒ ★斷言 d_hi > d_lo 【很可能照樣過】：新舊都 saturate 到 1.0 —— 巧合,不是測到東西
```
★★而它餵的是**世界不會產生的狀態**：`shortfall` 定義上 ≤ `need_keep`，
`need_total = 0` 時 `shortfall` 只能是 0 ⇒ **這是「床餵了世界不會產生的輸入」的實例，不是候選。**

⇒ 修法：`lo`／`hi` 兩支都加 `material_need_total = 100.0`（★**兩者相同**，保留原意圖
「差異只來自 `material_build_urgency`」）⇒ `_msf = 0.8` 不再 saturate，
`d_hi > d_lo` 才是真的測到 urgency。

★其餘讀 `material_shortfall` 的點**不用動**（R² 全掃過）：`framework_f1_test.gd:50`、
`material_buy_test.gd:85/94/98/103` 都只餵 `options.gd:419` 的 `applicable` 布林閘，不進 `terms.gd:306`。

## 其餘驗收（spec §4 全文）

①需求大／需求小的隊在**相同絕對缺口**下 drive 要分開（dump 兩支 need_total 差很多的隊）
②跨隊 `_msf` **相異值增加**（母體＋相異數，不是單點）
④`_msf ∈ (0,1]`；★量到 >1 ⇒ 分母母體選錯

★床照你的新習慣帶 `SECTIONS=n/N`。完後改本信 `status: consumed`。
