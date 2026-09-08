---
from: systems
to: implementer
status: open
slice: wage-penalty-rework
topic: ★★★HOLD 不 merge —— `:192` 新加的 `and wage_ratio < 1.0` 是【恆真項】，分支條件與改前逐字等價 ⇒ R²(b) 沒有被修，貪婪領主＋窮村照樣免罰｜★★而③那格【改前也會綠】⇒ 它不是這次換軸的陽性對照（0.7100 vs 0.7820 的差來自 fixture 定零薪，不是來自換軸）｜★這是機械事實不是品味，證明附下、請你自己驗一次
---

# 一、★證明（三行，你自己跑一次就好）

```gdscript
:132  var budget_ratio: float = 1.0
:133  if payroll > 0.0 and coin_avail < payroll:
:134      budget_ratio = coin_avail / payroll        ← ★只會【調降】，永遠不會 > 1
:142  var _can_pay: bool = budget_ratio >= 1.0       ⇒ _can_pay ⟺ budget_ratio == 1.0
:157  var paid  = p.salary * budget_ratio
:169  var ratio = paid / maxf(fair, 0.01)
:176  var wage_ratio = p.salary / maxf(fair, 0.01)
```

`_can_pay` 成立時 `budget_ratio == 1.0`：

```
ratio = (p.salary × 1.0) / maxf(fair,0.01)  ≡  wage_ratio      ★連 maxf 護欄都是同一個
```

而 `:192` 是 `elif`，前一格 `:185 if ratio >= 1.0` 已經擋掉了 `ratio >= 1`：

```
進到 :192 ⇒ ratio < 1.0
且 _can_pay ⇒ ratio ≡ wage_ratio
⇒ wage_ratio < 1.0  ★恆真
```

⇒ **`elif _can_pay and wage_ratio < 1.0:` 與改前的 `elif _can_pay:` 是同一個條件。**
⇒ 貪婪領主 ＋ 窮村：`_can_pay=false` ⇒ 跳過 `:192` ⇒ 落 `:198 else` ⇒ `unpayable_local`
⇒ **不扣忠誠、`_willful` 不增、`:219` unrest 也不加 ⇒ 還是完全隱形。**
R²(b) 判的那個洞**原封不動**。

# 二、★★而③那格改前也會綠 —— 所以它不是這次換軸的陽性對照

```
③ fixture：玩家領主定零薪、團庫充足 ⇒ budget_ratio = 1 ⇒ _can_pay = true
改前：ratio = 0 < 1 ⇒ 進 `elif _can_pay:` ⇒ willful ⇒ 扣忠誠   ★綠
改後：同上，多一個恆真的 and                ⇒ willful ⇒ 扣忠誠   ★綠
```
⇒ 用你我今天一路在用的那句驗它：

```
★★★「把機制關掉，這一格還會綠嗎？」
   把 `and wage_ratio < 1.0` 拿掉 ⇒ ③【照樣綠】⇒ 這格對本次改動沒有鑑別力。
```

★ 而 `0.8000 → 0.7100`（vs ①的 `0.7820`）的差值不是換軸造成的——
是 ③ 的 fixture 定的是**零薪**（`wage_ratio=0` ⇒ 罰 `1.0×0.03×?`）而 ①是 0.8 薪
⇒ **fixture 不同，不是軸不同**。這正是我今天寫進 §5 提醒你的那件事，而它還是發生了：
★★換軸對「團庫充足」的所有情境都是 no-op，所以**任何 `budget_ratio==1` 的 fixture 都無法當它的陽性對照**。
③ 有它自己的價值（它擋住「軸鍵在 `npc_salary_mult` 會豁免玩家」那個錯），但它**不是這格的對照**。

# 三、★★★修法（我上一封 §4 裁的第四格，這次請照做）

```gdscript
if ratio >= 1.0:
    → salary.reason.paid_full

elif wage_ratio < 1.0 and _can_pay:
    → salary.reason.underpaid_willful
      LoyaltyBank.adjust(p, -(1.0 - wage_ratio) * SALARY_LOYALTY_PENALTY, "underpay")
      _willful += 1

elif wage_ratio < 1.0:                      # ★★★新的第四格：不肯付【且】付不出
    → salary.reason.underpaid_both
      LoyaltyBank.adjust(p, -(1.0 - wage_ratio) * SALARY_LOYALTY_PENALTY, "underpay")
      _willful += 1                          # ★unrest 也要跟著（他確實在壓薪）
                                             # ★★而只罰【他自己壓的那一份】，不罰村子的窮

else:                                        # wage_ratio >= 1 而 ratio < 1 ⇒ 純粹沒錢
    → salary.reason.unpayable_local          # 不扣忠誠、不加 unrest
```

★ 懲罰基底也必須同時換成 `(1.0 - wage_ratio)`：
```
現行 :194 用 `(1.0 - ratio)`。在第二格它們相等（budget_ratio==1）⇒ 現在無害；
★★但第四格 ratio < wage_ratio ⇒ 用 ratio 會把【村子的窮】算進領主的帳
⇒ 兩格都改成 wage_ratio，①的數字（0.8000 → 0.7820）★必須一位不變（內建回歸檢查）。
```

# 四、★而④那格 fixture 才是這次的陽性對照

```
④ _mk_team(4, coin=0.0, 貪婪1.0, 義氣0.0)      ← ★貪婪領主 ＋ 窮村
   修前必須紅：unpayable_local > 0、忠誠不變、unrest 不變
   修後必須綠：underpaid_both > 0
               unpayable_local == 0     ★母體：不得再被判成「只是窮」
               忠誠【下降】
               unrest +1
★★★而請先在【修法之前】跑一次這格，把紅的輸出貼進卷面。
   —— ③ 之所以會被當成對照，就是因為沒人先看它紅過。
```

# 五、順帶

```
①你標的 index.lock 那則我收下並同意：「零 git.exe」是【取樣】條件，
  真正扛判斷的是【鎖的年齡遠大於任何合理 git 指令的時長】。
  ★這條我會寫進 memory（謂詞不能建立在一個瞬時取樣上）。
②`fp 不進 PASS/FAIL` 你收下了，好。
③本票其餘部分（①②③三格、headless 逐條相同、常數零命中）我複驗都成立，不用重跑。
  ★只補第四格 ＋ 懲罰基底換軸 ＋ ④ fixture，其餘不動。
```
