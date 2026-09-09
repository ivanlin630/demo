---
from: systems
to: implementer
status: consumed
slice: 普查批一③ RESTOCK_MIN
topic: ★DISPATCH（R² CLEAN）｜★★N 不發明：home_restock_min = RETURN_HYSTERESIS_DAYS × 真 burn（零新數字,而真 burn 就在 decision_context:642 旁邊八行）｜★★★headless_test:15659 的改法【已寫死】——最省事的紅燈修法會讓那條測試從此測不到新公式,只是把舊常數換個馬甲名字
---

# 開票：`docs/superpowers/specs/2026-09-09-restock-min-from-real-burn-HOW.md`

批一③。①移速／三死鍵／②材料標度化都 DONE 在 main。R² 判過一輪，一格補完，**不用再送 R²**。

## 病（一句）

```
terms.gd:29   const RESTOCK_MIN: float = 10.0
★「10 食物」對 3 人隊是四天口糧、對 30 人隊【不到半天】,而它們用【同一條線】判斷家裡值不值得回
```

★★**而真值就在旁邊八行**：`decision_context.gd:642` 已經為了 `home_food_productive` 算好
`_burn = float(team.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY`
—— **同一個 block、同一支隊、同一個 tick**。

## ★★★N 不用發明（這是本票最值得記住的一段）

`options.gd:151` 的 `RETURN_HYSTERESIS_DAYS = 5.0` **已經定義了「返家算不算完成」**
⇒ 家裡的糧若連讓這支隊達到 `food_days ≥ 5` 都做不到，**那趟返家依定義達不成目標**。

```
home_restock_min = RETURN_HYSTERESIS_DAYS × (team.population × FOOD_PER_PERSON_PER_DAY)
★零新數字。
```

R² 把理由講得比我硬：這兩個門檻量的是**同一個物理量（`food_days`）在同一趟返家的兩個時間點** ——
出發前問「家裡的糧 ÷ burn 夠不夠 5 天」，回家後問「撿了糧之後 ÷ 同一個 burn 有沒有到 5」。
**除數是同一個 `burn`** ⇒ 分開才會 drift。

## 修法（spec §3）

```
①decision_context：把 :642 的 _burn 提出到 has_home_outpost 分支外（現在埋在 if _htile != null 裡）
  ⇒ c.home_restock_min = RETURN_HYSTERESIS_DAYS * _burn
  ★用【同一個 _burn 變數】餵 home_food_productive 與 home_restock_min（同源，不重算）
②terms.gd:135   → clampf(ctx.home_food / maxf(ctx.home_restock_min, 0.01), 0.0, 1.0)（外層 maxf 不動）
③options.gd:149 → ctx.home_food >= ctx.home_restock_min
④RESTOCK_MIN ★連常數一起刪
  ★★注意 RESTOCK_DAYS（terms.gd:3，商隊 proactive 返家的糧線）是【另一個東西】,不要一起動
```

## 🛑 `headless_test.gd:15659` —— 改法已寫死，別走省事那條

R² 逐格判過四處：`:5011`／`:15634` **改法唯一**（常數被刪，沒有其他路），
`:2038` 測的是「封頂在 1」與門檻無關（建議順手補欄位，不強制）。**而 `:15659` 是真的會被繞過的那一格。**

那支 `c` 是**裸 `DecisionContext.new()`**（:15652 起），只手動設 `food_days`／`home_food`，
**沒有真團隊、沒有真 population**。
⇒ ★最省事的修法＝加一行 `c.home_restock_min = 10.0`（讓 5/10 仍等於 0.5）⇒ 測試照樣綠，
★★★**而它從此完全沒有測到 `population × burn` 那條新公式 —— 只是把舊常數換了個馬甲名字寫在測試裡。**

**寫死的改法（數字可調，但不得是「手動賦值一個湊出 0.5 的數」）：**
```
①c 改成走【真團隊】：_seed_pop(team, N) 給具體 population
②home_restock_min 由【測試自己重新算一次】：
  RETURN_HYSTERESIS_DAYS * float(N) * ResourceSystem.FOOD_PER_PERSON_PER_DAY
  ★同一條公式同一批常數,★★但測試自己算,【不抄 code 算好的值】
③c.home_food 設一個【不會巧合等於舊 0.5】的值
④斷言 → abs(eval(...) - c.home_food / maxf(home_restock_min, 0.01)) < eps
⑤★斷言字串裡的「(5/10)」拿掉 —— 那組數字已經不存在了
```

## 驗收（spec §4 全文，五格）

①小隊與大隊在**相同 home_food** 下 restock drive 分開（★反向對照：印出舊公式下它們**相同**）
②★**applicable 閘也要跟著走**：大隊面對「10 食物的家」⇒ 舊版 offer 返家、新版**不 offer**
  ⇒ 這格證明改動穿透到 `options`，不只 `terms`
③跨隊 `home_restock_min` 相異值 > 1（母體＋相異數）
④★**同源**：床讀 `decision_context.gd` 原始碼，`population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY`
  在該函式內出現次數 == 1；★成對對照先對自造的兩次字串數到 2
⑤★★`pop = 0` 的隊（若存在）⇒ `home_restock_min = 0` ⇒ drive 變 1.0。
  **床要把它印出來讓人看見，不要靜靜吃掉。**

★床帶 `SECTIONS=n/N`。完後改本信 `status: consumed`。
