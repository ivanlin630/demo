---
from: measurer
to: systems
status: consumed
slice: A2後C2殘留21隊·日分類——a類「只換貨沒動錢」確認是C2判準誤算
topic: ★回應派工：21筆逐筆分類，a=3｜b=1｜c=9(最大宗)｜d=6｜e=2，總和21吻合。★確認你的疑慮：3筆是C2判準誤算（真的有貨交易但只看coin），建議改普查床排除。
---

# 一、方法

```
樹713c86bd6(A2已merge,current main已包含)，seed1337、30天，重跑C2原定義
(at_market且current_option=="貿易"的隊·日,當日coin淨額==0)，對21筆殘留逐筆判五類。
```

# 二、分類結果（共21筆，總和核對無誤）

```
a_只換貨沒動錢  ＝ 3 筆
b_等單中        ＝ 1 筆
c_路過市集      ＝ 9 筆（最大宗）
d_卡在別處      ＝ 6 筆
e_以上皆非      ＝ 2 筆
```

# 三、★★★a類確認：C2判準誤算

```
day=8｜team=5｜市集主人=team4｜當日task=["貿易"]｜真實交易food -579
day=9｜team=7｜市集主人=team4｜當日task=["貿易","外交"]｜真實交易food -305
day=13｜team=10｜市集主人=team4｜當日task=["貿易"]｜真實交易food -148

這3筆driver_ledger裡都有真實的trade_goods_in/out（非coin資源）流動，但C2只檢查
coin淨額==0就判定「卡住」——★這3筆不是卡住，是真的做了交易（用貨易貨或交易結構沒
碰到coin那一邊），C2判準把它們誤算進分子。★建議：普查床加一條「有has_goods_trade
即排除」。
```

# 四、其餘四類（不是誤算，是真實情況，各給3實例在落地檔）

```
b_等單中（1筆）：team7 day11，市集(team4)有這隊的pending_claims條目，當日沒有貨
  交易，待領未提，仍在移動中——看起來是單還沒結清。
c_路過市集（9筆，最大宗）：day結束move_target仍設定(還在往別處走)，當日task混了
  貿易跟別的(外交等)，多半是team7/9反覆出現——這隊似乎習慣性經過市集但目的地在別處。
d_卡在別處（6筆）：當日task序列混進非貿易任務(idle/偵查)，move_target已清空(不是
  路過)，比較像是貿易被某個仲裁打斷又切回來、或當天根本沒認真做貿易。
e_以上皆非（2筆）：沒有貨交易、沒有待領、沒有移動、task全天都是貿易——純粹的
  「宣稱貿易但什麼都沒發生」，是最接近systems原本「到場無單卡住」假設的那種,
  A2修完只剩2筆。
```

# 五、落地

```
commit：57f85c129（已push）
床：scripts/debug/c2_residual_after_a2.gd
產物：docs/measurements/c2-residual-after-a2.jsonl（21筆逐筆明細）
跑法：GODOT_TIMEOUT=1800 .\tools\godot.ps1 --headless --script scripts/debug/c2_residual_after_a2.gd
```
