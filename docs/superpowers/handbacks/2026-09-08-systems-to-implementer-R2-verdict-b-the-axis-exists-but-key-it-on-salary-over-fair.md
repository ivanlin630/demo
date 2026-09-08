---
from: systems
to: implementer
status: open
slice: wage-penalty-rework
topic: ★R² 判 (b) 判準切錯軸——修法一句話量級｜★★而我改 reviewer 的處方一個字：軸要鍵在 `p.salary/fair`【不是】`npc_salary_mult`，否則【玩家領主】被靜默豁免｜★★★而這個修法對現有兩格綠是【數學上的 no-op】，所以它需要一個新的第三格陽性對照，否則沒有鑑別力
---

# 一、判決

reviewer 判 **(b) 判準切錯軸**，`premise_contradiction: false`。
①（改接線非改數值）與 ③（反轉斷言真的在守新語意）**已通過，不用重跑**。
只補 ②，其餘不動。

★順帶：reviewer 抓到**我的**方法錯誤——我 diff 用 `origin/main..branch`，
而本支真 base 是 `970ee864`；`origin/main` 這幾天跑過好幾票早已分岔
⇒ 我那句「零 const 命中」是在**被污染的 diff** 上得到的。答案碰巧對，方法是錯的。
（reviewer 用 `970ee864..HEAD` 重跑，並且多查了我沒查的 `headless_test.gd`／`wage_penalty_test.gd`。）

---

# 二、★病：兩條軸早就各自算好，只是第二條從沒被讀進懲罰判斷

```gdscript
:101-108  npc_salary_mult = clampf(1+(義氣−貪婪×0.5)×0.4, 0.7, 1.3)  ← ★純人格，不吃 coin
:156      p.salary = fair * npc_salary_mult                          ← 領主【肯不肯付】
:157      paid     = p.salary * budget_ratio                         ← 村子【有沒有錢】
:169      ratio    = paid / fair          ⇒ ★恆等於 mult × budget_ratio
:142      _can_pay = budget_ratio >= 1.0                             ← ★只讀了財力那條
```

⇒ 窮村的貪婪領主：`_can_pay=false` ⇒ 掉進 `:191 unpayable_local`
⇒ 不扣忠誠、`_willful` 不增、`:212` unrest 也不加 ⇒ **貪婪在窮村完全隱形**。
不是「這概念分不出來」，是**分出來的那半已經算好放在旁邊，沒人去讀**。

---

# 三、★★而我改處方一個字（這點請照我的、不要照 reviewer 的字面）

reviewer 建議判 `npc_salary_mult < 1.0`。**別鍵在那個變數上**——它只在 NPC 隊被算：

```gdscript
:99   var is_player_team := (team.leader_id == state.player_id and state.player_id != -1)
:101  var npc_salary_mult: float = 1.0        ← ★玩家隊：恆為 1.0
:155  if not is_player_team: p.salary = fair * npc_salary_mult
```

⇒ 鍵在 `npc_salary_mult` 的話，**吝嗇的玩家領主 `mult` 永遠是 1.0 ⇒ 永遠不算 willful
⇒ 現在會被罰的玩家、修完之後【不會被罰了】**。那是把一個 bug 修成另一個 bug。

**正確的軸 ＝ budget 縮放【之前】的薪資比**：

```gdscript
var willful_ratio: float = p.salary / maxf(fair, 0.01)   # ★不乘 budget_ratio
```
- NPC 隊：`p.salary = fair*mult` ⇒ `willful_ratio == npc_salary_mult`（與 reviewer 的處方**等值**）
- 玩家隊：`p.salary` 是玩家自訂 ⇒ 這條軸**照樣讀得到玩家的吝嗇**

一樣是「既有變數，只差沒被讀」，而且不漏玩家。

---

# 四、★★★而我要裁一件 reviewer 沒展開、你一定會撞到的事：三格互斥會被打破

軸一獨立，一個人就可能**同時**「不肯付」且「付不出」。
現行三格是 `if/elif/else` ⇒ 互斥且涵蓋，而**互斥正是今天接住兩次假綠的那個性質**
（每一格都是一個真母體）。所以：

## 裁定：開第四格，不要改成兩個獨立 flag

```
salary.reason.paid_full            ratio >= 1
salary.reason.underpaid_willful    壓低薪資、且付得出        （willful_ratio<1, budget_ratio>=1）
salary.reason.unpayable_local      只是沒錢、薪資沒被壓低    （willful_ratio>=1, budget_ratio<1）
salary.reason.underpaid_both       ★新：壓低薪資【且】沒錢   （willful_ratio<1, budget_ratio<1）
```
四格仍**互斥且涵蓋** ⇒ 每格都還是可用的母體，
下游要總量就 `willful_total = underpaid_willful + underpaid_both`。
（兩個獨立 flag 的話，`willful>0` 在無幣半就變成歧義的，床會失去鑑別力。）

## 懲罰的【量】也要換軸——這是同一個病的另一半

```gdscript
現行 :187   LoyaltyBank.adjust(p, -(1.0 - ratio) * SALARY_LOYALTY_PENALTY, "underpay")
                                        ↑ ratio = mult × budget_ratio
                                        ⇒ ★把【村子窮】的那一份也算在領主頭上
改為        LoyaltyBank.adjust(p, -(1.0 - willful_ratio) * SALARY_LOYALTY_PENALTY, "underpay")
```
**只罰他自己選的那一份**。`SALARY_LOYALTY_PENALTY = 0.03` **不動**（改接線非改數值）。

`_willful` 計入 `underpaid_willful + underpaid_both` ⇒ `:212` unrest 兩種都會加。
`:215 elif budget_ratio < 1.0` 的 `suppressed_unpayable` 保留：現在它專指**真的只是窮**。

---

# 五、★★★這個修法對現有兩格綠是【數學上的 no-op】——所以它需要新的陽性對照

```
① 半 _mk_team(1, coin=100000, 貪婪1.0, 義氣0.0) ⇒ budget_ratio = 1
   ⇒ ratio == willful_ratio ★恆等 ⇒ 懲罰量【一模一樣】
   ⇒ 忠誠必須仍然是 0.8000 → 0.7820，willful=3、paid_full=0、unpayable=0
   ★這是你的內建回歸檢查：這幾個數字只要動了一位，就是改錯了東西。

② 半 _mk_team(2, coin=0, 貪婪0.5, 義氣0.5) ⇒ mult = 1+(0.5−0.25)×0.4 = 1.1 ≥ 1
   ⇒ ★不是 willful ⇒ 仍然落 unpayable_local ⇒ 忠誠不變、unrest 不變【全部照舊】
   （fixture 的註解「人格中性，卡點只在沒錢」本來就選對了，不用改它。）
```

⇒ ★★★**兩格都不會變色，意思是：床現在對這個修法完全沒有鑑別力。**
**必須加第三格**，否則「全綠」只證明你沒弄壞東西，不證明修法發生過：

```
③ 新：_mk_team(3, coin=0, 貪婪1.0, 義氣0.0)   ← ★貪婪領主 ＋ 窮村
   修前：unpayable_local > 0、忠誠不變、unrest 不變      ← 就是那個洞
   修後必須：underpaid_both > 0
             unpayable_local == 0      （★母體：不得再被判成「只是窮」）
             忠誠【下降】               （罰的是他壓低的那 0.2，不是村子的窮）
             unrest +1
   ★★而請你【先在修法之前跑一次這格】——它必須是紅的。
     一格從沒紅過的驗收，跟沒有這格是一樣的。
```

---

# 六、交付

```
改 scripts/simulation/salary_system.gd（軸 + 第四格 + 懲罰量）
改 scripts/debug/wage_penalty_test.gd（★加 ③ 半；①② 兩半【不要動】）
跑 wage-penalty 閘 + headless 閘（HARD-FAILS 必須仍是 3、清單逐條相同）
更 docs/measurements/2026-09-08-wage-penalty-rework.measure.json
   ★★卷面請加一行：③ 這格在修法【之前】跑出來是紅的（貼那次的實際輸出）
→ 寄回 systems，我跑 36 道閘 → merge → push。★不用再走一輪 R²，reviewer 已說「其餘不用動」。
```
