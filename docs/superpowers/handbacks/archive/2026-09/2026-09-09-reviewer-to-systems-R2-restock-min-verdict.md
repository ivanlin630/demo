---
from: reviewer
to: systems
status: consumed
slice: 普查批一③ RESTOCK_MIN
topic: R² 判決 — item1/2 CLEAN(理由比你寫的更硬)；item3 抓到真會被繞過的那一格
---

# R² 判決：`2026-09-09-restock-min-from-real-burn-HOW.md`

## 判決：非 CLEAN，item3 一處要在 spec 裡把改法寫死，其餘 CLEAN

## item 1（N 不用發明）：CLEAN

## item 2（綁定是同源不是偷懶）——判「同源，一起動才對」，理由比你寫的更硬

你自己的立場寫成「這是我選的框，不是資料選的」——查了 `food_days` 怎麼算之後，
我認為你可以講得更硬，不必自謙成「框」：

```
decision_context.gd:261  c.food_days = ef / max(pop×FOOD_PER_PERSON_PER_DAY, ε)
                          ★ef = ResourceSystem.effective_food(state, team) —— 這是【隊自己帶的糧】
options.gd:151/152       TASK_RETURN_HOME 隊撐到 ctx.food_days ≥ RETURN_HYSTERESIS_DAYS(5) 才釋放
                          ★這個 food_days 用的還是同一支隊、同一個 ef、同一個 burn
```

`home_restock_min = RETURN_HYSTERESIS_DAYS × burn` 量的不是「兩個不相干的東西湊同一個 N」，
量的是**同一個物理量（food_days）在同一趟返家的兩個時間點**：
- 出發前：家裡的 `home_food ÷ burn` 夠不夠給這支隊 5 天？
- 回家後：這支隊撿了糧、`ef ÷ burn`（＝新的 `food_days`）有沒有到 5？

兩邊除數是同一個 `burn`，除的是「同一支隊要撐 5 天」這一件事，只是分子從『家裡的糧』換成
『隊撿了糧之後帶的糧』。**這不是「怕發明數字所以借一個現成的」，是這兩個門檻在量同一件事**——
分開才是兩個常數各自表述同一個物理量，才會 drift。判：同源，綁對了。

## item 3（headless_test 四處）：三處安全、一處是真的會被繞過，要在 spec 裡把改法寫死

```
✅ :5011   ctx2.home_food >= DecisionTerms.RESTOCK_MIN → 機械改 ctx2.home_food >= ctx2.home_restock_min
           安全：RESTOCK_MIN 常數本身被刪(§3④)，這個寫法【沒有其他路可走】，改法唯一。
✅ :15634  同上，ctx4.home_food >= ctx4.home_restock_min，同理安全。
⚠️ :2038-2039  ctx.home_food=999.0 → assert restock_need==1.0
           risk 低：ctx 是裸 DecisionContext.new()，home_restock_min 沒設(default 0.0)，
           新公式 999/max(0,0.01)=99900→clamp 1.0，斷言照樣過——但這條本來就在測「滿了會封頂在1」，
           跟 home_restock_min 實際多少無關，不算被繞過，只是這個裸 ctx 沒有 pair 好 home_restock_min。
           建議順手補 ctx.home_restock_min = 某正數，不強制。
🛑 :15659  abs(eval("restock_need", c, ...) - 0.5) < 0.01, "T1:restock=home_food/RESTOCK_MIN(5/10)"
           ★這支 c 是裸 DecisionContext.new()（:15652 起），只手動設 food_days/home_food，
           【沒有經過 gather()、沒有真團隊、沒有真 population】。
           ★★這正是你怕的那條路：最省事的紅燈修法＝手動加一行
           `c.home_restock_min = 10.0`（讓 5/10 還是等於 0.5），
           斷言字串照舊、數字照舊、測試照樣綠 —— 而這樣改完之後，
           這條測試【完全沒有測到】population×burn 那條新公式，只是把舊常數換了個馬甲名字寫在測試裡。
           spec 現在只交代「headless_test 會紅，改成用 ctx.home_restock_min 表述」，
           但【沒有點名這一格要怎麼避開手動塞數字】——這格必須寫死改法，不能留給實作者自己選最省事的路。
```

**要求：在 spec §3（或另開一段）把 :15659 的改法寫死成類似這樣（你可以調數字，但不能是「手動賦值一個湊出 0.5 的數」）：**
```
c 改成走真團隊：_seed_pop(team, N) 給一個具體 population，
home_restock_min 用 `RETURN_HYSTERESIS_DAYS * float(N) * ResourceSystem.FOOD_PER_PERSON_PER_DAY` 算出來
（跟 code 用同一條公式、同一批常數，但這裡是【測試自己重新算一次】，不是抄 code 算好的值）
再把 c.home_food 設成一個跟這個 home_restock_min 不會巧合等於舊 0.5 的值，
斷言用 `abs(eval(...) - c.home_food/max(home_restock_min,0.01)) < eps`，
不要留字串裡的「(5/10)」——那組數字已經不存在了。
```

## 其餘

「我知道的盲區」（`_home_granary_food` 多 outpost）：不擴大 scope，本票不用管，沒有異議。

CLEAN 只差 :15659 這格的改法寫死進 spec。寫完不用再送 R²，你直接 dispatch。
