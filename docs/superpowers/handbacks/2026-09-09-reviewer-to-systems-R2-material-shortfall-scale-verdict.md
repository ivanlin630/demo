---
from: reviewer
to: systems
status: consumed
slice: 普查批一② MATERIAL_SHORTFALL_FULL
topic: R² 判決 — 分母 CLEAN；§4③驗法不可行需換；找到一支床會被餵不可能狀態
---

# R² 判決：`2026-09-09-material-shortfall-scale-from-own-need-HOW.md`

## 判決：非 CLEAN，兩處要改（都不是「分母對不對」那件事，那件事你對）

## item 1（分母選擇）：CLEAN

同一次 `need_keep` 是對的分母。查過 `decision_context.gd:597` 註解與 `coin_treasury.gd` 的
`_construction_facility_need` 只涵蓋建設一塊，你的更正成立——沒有異議。

## item 2（§4③ stub 驗法）：不可行，原因是你自己漏查的一個事實

```
need_oracle.gd:13   static func need_keep(state, team, res, leader_values := {}) -> float
```

`NeedOracle` 整支是 `class_name` + `static func`。GDScript 沒有辦法在床裡對 static class method
換身（沒有 instance、沒有 DI 縫）——要做到可 stub，唯一路是動 `NeedOracle` 本體加一個測試縫，
而 spec 誠實限寫著「本票只改標度化基準，不改 `need_keep` 本身」。你自己不確定的那件事是真的：**不可行**。

**替代驗法（結構檢查取代行為 stub）：**
你要驗的「同一次呼叫」其實不是一個要在 runtime 用呼叫次數量出來的性質——
按 §3① 的修法（一個 local var 同時餵 `material_shortfall` 和新欄 `material_need_total`，
在同一段落賦值），「只呼叫一次」是**程式碼形狀**保證的事，不是 runtime 行為。
→ 把 §4③ 改成**結構檢查**：grep `decision_context.gd` 裡
`NeedOracle.need_keep(state, team, "material", ...)` 呼叫點數＝1，
且 `material_shortfall`／`material_need_total` 這兩行在同一個 local var 賦值段落裡
（可以是 code review 檢查項，不必是跑得動的床）。
§4④（可達區間 (0,1]）留著當 runtime 側的次要保險網——雖然它抓不出所有「母體不同源」，
但能抓到 ratio>1 這個症狀。

## item 3（其他消費者）：查到一支床會被餵不可能狀態，你 grep 對了但沒往下追一步

`terms.gd:306` 的消費者全掃過（結果見下），只有一處會真的動到新公式：

```
material_buy_test.gd:77-82   _test_drive_rises_with_urgency()
  lo.material_shortfall = 80.0 / hi.material_shortfall = 80.0   # 都沒設 material_need_total
  d_lo = DecisionTerms.eval("buymaterial_drive", lo, "買料")     ← 真的打進 terms.gd:306
  d_hi = DecisionTerms.eval("buymaterial_drive", hi, "買料")
```

改完後 `ctx.material_need_total` 沒被這支床設,會吃你 §3②的 default（新欄未賦值＝0.0）
→ `_msf = 80.0 / maxf(0.0, 0.01) = 8000` → clamp 到 1.0。
這剛好跟舊公式 `80/80=1.0` 同一個值，所以 `d_hi > d_lo` 這條斷言**很可能還是會過**——
但那是巧合（新舊常數剛好都讓它 saturate），不是這支床在測真的東西。
它現在餵的是「shortfall=80 但 need_total≈0」——一個世界不會產生的狀態（shortfall 定義上
≤ need_keep，need_total=0 時 shortfall 只能是 0）。之後如果誰去動 `buymaterial_drive` 對
`_msf` 的權重，這支床會因為 `_msf` 恆卡在天花板而測不出退步——就是你 memory 裡那條
「床餵了世界不會產生的輸入」的候選,而且已經不是候選,是實例。

**其餘讀 `material_shortfall` 的點不用動**（只碰 `options.gd:419` 的 `applicable` 布林閘
`material_shortfall > 0.0`，不進 terms.gd:306）：
```
framework_f1_test.gd:50            ctx.material_shortfall = 1.0            ← 只餵 applicable 閘，安全
material_buy_test.gd:85 (no_mkt)   material_shortfall = 80.0               ← 被 has_material_market=false 閘擋，drive=0，安全
material_buy_test.gd:94/98/103     material_shortfall = 50.0/50.0/0.0      ← 只餵 food-ok gate 的 applicable 閘，安全
```

**要改的地方：** `material_buy_test.gd:77` 與 `:79` 的 `lo`/`hi` 兩支加
`lo.material_need_total = 100.0`／`hi.material_need_total = 100.0`（兩者相同,保留原測試意圖
「差異只來自 `material_build_urgency`」）→ `_msf = 80/100 = 0.8`,不再 saturate,
斷言 `d_hi > d_lo` 才是真的測到 urgency 的效果,不是巧合過。

## 待你確認

1. §4③ 換成結構檢查你同意嗎？還是你有別的可行 runtime 驗法我沒想到。
2. `material_buy_test.gd:77/79` 兩處補 `material_need_total` 你順手改，還是要我另開票？

其餘（誠實限、§3 修法本身）沒有異議。這兩項補完（或你給出更好的替代）才 CLEAN，才 dispatch。
