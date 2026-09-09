# HOW spec：返家補給的「家裡有沒有糧」改成【那支隊的真實燃燒率 × 返家本身的成功條件】

owner: systems ｜ 2026-09-09 ｜ player_reachable: no ｜ 序：批一③｜狀態：R² CLEAN（:15659 改法已寫死）⇒ 可 dispatch

blueprint 裁批一③：「`RESTOCK` ＝ N 天 × 真實 burn；**N 是設計選擇留參數，burn 讀真值**」。

## §1 病

```
terms.gd:29    const RESTOCK_MIN: float = 10.0   # TEST VALUE — 家糧倉至少這麼多 food 才值得返家補給
terms.gd:135   maxf(clampf(ctx.home_food / RESTOCK_MIN, 0.0, 1.0), 1.0 if ctx.home_food_productive else 0.0)
options.gd:149 ctx.has_home_outpost and (ctx.home_food >= DecisionTerms.RESTOCK_MIN or ctx.home_food_productive)
```

★「10 食物」對一支 3 人隊是四天口糧，對一支 30 人隊**不到半天**，而它們**用同一條線**判斷「家裡值不值得回」。
★★(ii) 型（看見了一個錯的值）。

★★★**而真值就在旁邊八行**：`decision_context.gd:642`
```
var _burn: float = float(team.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY
```
已經為了 `home_food_productive` 算好了 —— **同一個 block 裡，同一支隊，同一個 tick。**
⇒ 這是 blueprint 立的那條制度性檢查項（「舊 code 誰在用這個量的佔位版？」）的**現成範例**：
   世界早就長出這個量，而決策層旁邊放著一個平版常數。

## §2 ★★★N 不用發明 —— 它已經被【返家這件事自己的成功條件】定義了

```
terms.gd:4      const RETURN_HYSTERESIS_DAYS: float = 5.0
options.gd:151  or (ctx.current_task == TASK_RETURN_HOME and ctx.food_days < RETURN_HYSTERESIS_DAYS)
                ⇒ ★返家【要撐到 food_days ≥ 5 才算完成】（GATE-A 二刀 hysteresis，破 oscillation）
```

⇒ ★**若家裡的糧連「讓這支隊達到 food_days ≥ RETURN_HYSTERESIS_DAYS」都做不到，
   那趟返家【依定義】達不成它自己的目標** ⇒ 這就是「值不值得回」的判準本體。

```
home_restock_min = RETURN_HYSTERESIS_DAYS × (team.population × FOOD_PER_PERSON_PER_DAY)
```

★★**不新增任何數字**：`RETURN_HYSTERESIS_DAYS` 已在、`FOOD_PER_PERSON_PER_DAY` 已在、`population` 是真值。
★★★這比「另立一個 N」好的地方是：**N 之後若被調整，兩處會【一起】動** ——
   而分成兩個常數時，「返家的目標」與「值不值得返家」會 drift，
   ⇒ 那正是我們這兩天一直在拆的東西。

★★★R² 把這條的理由講得比我硬（2026-09-09，我原本自謙成「這是我選的框」）：

```
decision_context.gd:261  c.food_days = effective_food(state, team) / max(pop × FOOD_PER_PERSON_PER_DAY, ε)
options.gd:151           TASK_RETURN_HOME 隊撐到 ctx.food_days ≥ RETURN_HYSTERESIS_DAYS 才釋放
                          ★同一支隊、同一個 burn
```
⇒ **這兩個門檻量的是【同一個物理量（food_days）在同一趟返家的兩個時間點】**：
   出發前問「家裡的 `home_food ÷ burn` 夠不夠給這支隊 5 天」，
   回家後問「撿了糧之後 `ef ÷ burn` 有沒有到 5」。
   **除數是同一個 `burn`，除的是「同一支隊要撐 5 天」這一件事**，只是分子換了。
⇒ ★**分開才是兩個常數各自表述同一個物理量** —— 那才會 drift。判：同源，綁對了。

★誠實限（保留）：若日後有人要它們分開，那是**設計選擇** ——
★★**要拆的人必須說出為什麼它們該分開**，而不是因為「多一個旋鈕比較靈活」。

## §3 修法

```
①`decision_context`：把 :642 的 `_burn` 【提出到 `has_home_outpost` 分支之外】
   （現在它埋在 `if _htile != null` 裡）⇒ 新欄 `c.home_restock_min = RETURN_HYSTERESIS_DAYS * _burn`
   ★用【同一個 `_burn` 變數】餵 `home_food_productive` 與 `home_restock_min`（同源，不重算）。
②`terms.gd:135`   → `clampf(ctx.home_food / maxf(ctx.home_restock_min, 0.01), 0.0, 1.0)` 外層 maxf 不動
③`options.gd:149` → `ctx.home_food >= ctx.home_restock_min`
④`RESTOCK_MIN` ★連常數一起刪，只留一行註解說明舊版。
   ★★注意 `RESTOCK_DAYS`（:3，商隊 proactive 返家的糧線）是【另一個東西】，不要一起動。
```

★★★`headless_test.gd` 四處硬編舊公式期望 —— **R² 逐格判過（2026-09-09），三格安全、一格必須寫死改法**：

```
✅ :5011   ctx2.home_food >= DecisionTerms.RESTOCK_MIN → ctx2.home_food >= ctx2.home_restock_min
           安全：RESTOCK_MIN 常數本身被刪（§3④）⇒ 這個寫法【沒有其他路可走】，改法唯一。
✅ :15634  同上，同理安全。
⚠️ :2038-2039  裸 ctx、home_food=999 → assert restock_need == 1.0
           它測的是「滿了會封頂在 1」，與 home_restock_min 實際多少無關 ⇒ 不算被繞過。
           ★建議順手補 `ctx.home_restock_min = <某正數>`（讓裸 ctx 的欄位成對），不強制。
🛑 :15659  abs(eval("restock_need", c, ...) - 0.5) < 0.01, "T1:restock=home_food/RESTOCK_MIN(5/10)"
```

★**`:15659` 這格必須寫死改法，不能留給實作者選最省事的路。**
那支 `c` 是裸 `DecisionContext.new()`（:15652 起），只手動設 `food_days`／`home_food`，
**沒有經過 `gather()`、沒有真團隊、沒有真 population**。
⇒ ★★最省事的紅燈修法＝手動加一行 `c.home_restock_min = 10.0`（讓 5/10 仍等於 0.5）
   ⇒ 斷言字串照舊、數字照舊、測試照樣綠，★★★**而這條測試從此完全沒有測到
   `population × burn` 那條新公式 —— 它只是把舊常數換了個馬甲名字寫在測試裡。**

**⇒ 寫死的改法（數字可調，但【不得】是「手動賦值一個湊出 0.5 的數」）：**
```
①`c` 改成走【真團隊】：`_seed_pop(team, N)` 給一個具體 population。
②`home_restock_min` 由測試【自己重新算一次】：
   RETURN_HYSTERESIS_DAYS * float(N) * ResourceSystem.FOOD_PER_PERSON_PER_DAY
   ★跟 code 用同一條公式、同一批常數，★★但是測試自己算，【不抄 code 算好的值】。
③`c.home_food` 設成一個【不會巧合等於舊 0.5】的值。
④斷言改成 `abs(eval(...) - c.home_food / maxf(home_restock_min, 0.01)) < eps`。
⑤★斷言字串裡的「(5/10)」拿掉 —— 那組數字已經不存在了。
```

## §4 驗收

```
①【腦看得見】同世界：★小隊與大隊在【相同 home_food】下 restock drive 分開；
   ★★而舊公式下它們相同 —— 反向對照要印出舊值（0.5/0.5）與新值（分開）。
②【applicable 閘也跟著走】一支大隊面對「10 食物的家」⇒ 舊版 offer 返家、新版【不 offer】
   ⇒ ★這格證明改動穿透到 options，不只 terms。
③【分布】跨隊 home_restock_min 相異值 > 1（母體＋相異數，不是單點）。
④★★★【同源】`home_food_productive` 與 `home_restock_min` 來自【同一個 `_burn` 變數】——
   驗法同批一②：床裡讀 `decision_context.gd` 原始碼，
   `population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY` 在該函式內出現次數 == 1，
   ★成對對照：先對自造的兩次字串數到 2（證明計數器會動）。
⑤【誠實限可見】：pop=0 的隊（若存在）⇒ `home_restock_min = 0` ⇒ 除法用 maxf 保護，
   ★而那種隊的 drive 會變成 1.0（家裡有任何糧都夠）—— 這是對的還是要另外處理，
   ★★床要把它印出來讓人看見，不要靜靜吃掉。
```
