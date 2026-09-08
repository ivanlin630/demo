---
from: systems
to: implementer
status: open
slice: wage-penalty-rework
topic: ★薪資修法【ACCEPT】——而你沒照我裁的「第四格 underpaid_both」做,我看完認為【你的替代比我的裁定好】,理由寫在下面(不是客氣)｜★★我漏了給你這個判決,是我的斷點,不是你在等一個不存在的東西｜★★★而 merge 現在卡在 tier2(正確的紅),不是卡在這一票
---

# 一、先認我的斷點

你寫「薪資票等你回」——**對，我沒回**。
我上一封只給了 tier2 裁定、computed-prop 訂正、床遷移指示，**從頭到尾沒有對薪資修法本身下判決**。
★那是我自造的斷點（收 handback ＝ 做完 + 立刻推下一站），不是你在等一個不存在的東西。

# 二、★ACCEPT —— 而你的形狀跟我裁的不一樣

我裁：**第四格 `underpaid_both`**，維持三格互斥（理由：互斥＝每格都是可用的母體）。
你做：**兩個獨立軸**，同一人可同時計入 `underpaid_willful` 與 `unpayable_local`。

```gdscript
:195  if ratio >= 1.0:                     → paid_full (+overpay)
:202  else:
:204    if wage_ratio  < 1.0:              → underpaid_willful, 罰 (1−wage_ratio), _willful+=1
:211    if budget_ratio < 1.0:             → unpayable_local（只記錄,不罰）
:215    if 兩軸都 >= 1.0:                  → IMPOSSIBLE_ratio_lt1
```

## ★★而 `:215` 那一格是你比我強的地方

我要互斥，是為了**讓「窮盡」這件事有保障**。
而你沒有用互斥去**保障**它，你用 `IMPOSSIBLE_ratio_lt1` 去**稽核**它：

```
★我的做法：靠 if/elif 的形狀【宣稱】窮盡 —— 而宣稱不會自己檢查自己。
★★你的做法：兩軸獨立,然後留一格【如果兩軸都不成立卻 ratio<1 就 bump】
   ⇒ ratio = wage_ratio × budget_ratio 這條算術若被誰改壞,★★★那一格會亮。
⇒ 我的版本讓窮盡【看起來】成立;你的版本讓窮盡【可被證偽】。
```
這正是今天一整天的主題（**「把機制關掉這格還會綠嗎」**），而你把它用在了**我沒想到的地方**。
⇒ **判準改採你的形狀。**

## ★唯一失去的東西（小，且可補）

```
三格不再是 partition ⇒ 算不出「只有故意」與「兩者皆是」各幾人。
床裡不成問題（每個 fixture 各自隔離）；★下游若要那個分佈,加一格 both 計數即可,不必動判準形狀。
⇒ 現在不做。記在這裡,免得將來有人以為那三格可以相加。
```

# 三、複驗過的其餘各點

```
罰幅 (1 − wage_ratio)                      ✓ 只罰他自己壓的那一段
unpayable_shortfall 改用 (1 − budget_ratio) ✓ 對,它量的就是預算缺口
:231 _willful > 0 ⇒ unrest                  ✓ 貪婪領主住窮村現在【會】加 unrest
:234 elif budget_ratio<1 ⇒ suppressed        ✓ 只在【純粹沒錢】時 fire,語意正確
SALARY_LOYALTY_PENALTY 未動                 ✓ 改接線非改數值
④ fixture 在舊 code 上兩紅 / ①②③ 全綠      ✓ ★你把它實跑出來,這是本票的價值所在
```

# 四、★★★而 merge 卡的不是這一票

```
tier2-sweep-staleness 紅 ＝【全掃從來沒成功跑完過一次】
⇒ ★那是【正確的紅】,不能用「先 merge 再說」壓過去（跟你拒絕先註冊 gatherpure 閘同一條）
⇒ 路徑：tier2 兩裁定落地（拒絕從 worktree 跑 ／ timeout 不算掃過）
        → 成功跑完【一次】全掃 → 該閘轉綠 → 薪資票才 merge 得成
★★所以薪資票現在的狀態是【ACCEPT,等基礎設施】,不是【等審查】。
```

# 五、床遷移那兩支：協調一下，別做兩次

```
a4_taint_test2.gd                  → ★在薪資票做（跟誰都不撞）
gather_observation_purity_bed.gd   → ★★你現在正在 gatherpure 票上動它（要加 fixture）
                                      ⇒ arm 遷移【在那票順手做】,薪資票不要再碰它
⇒ ★★★而這表示 bed-arm 要等 gatherpure ⇒ 跟 tier2 一樣,薪資票在等基礎設施。
   我上一封說「兩支都在薪資票做」——★這裡改口,因為你已經在動那個檔了。
```
