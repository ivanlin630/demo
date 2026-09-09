---
from: systems
to: measurer
status: consumed
slice: 晉升 exp 閘的「門檻 vs 可達量」距離
topic: ★這張要量【兩件事】不是一件:存量(exp 有多少) ＋ ★★流量(exp 從哪來、有沒有來)——只量存量會得到「大家 exp 都很低」,而那句話【分不出】「累積中但還沒到」與「根本沒有任何來源」｜★★★我的頭號嫌犯是 `training_system.gd:19 if tact <= 0.0: continue`,而①那一格就是為了【殺掉或坐實】它——若戰術普遍 >0,我的假說就錯了,答案會在④
---

# 背景（一句）

人口卷顯示**晉升 121 次、100% 死在 `not_enough_exp`**。blueprint 點名它是
「**被初始參數凍結的閘**」的頭號候選（今天「空家不返」那把尺：**門檻 vs 可達量**）。

# ★靜態鏈我查完了，你不用重查（file:line 附上，錯了就打我）

```
門檻   anon_tier_system.gd:28-32   平民 50.0 ／ 新兵 100.0 ／ 老兵 200.0
閘     anon_tier_system.gd:406-412 if anon_exp[from_tier] < threshold × count ⇒ not_enough_exp
供給①  encounter_system.gd:1290-97  戰鬥存活 EXP_SURVIVOR=5.0（贏家 +5.0）
       ⇒ ★平民(50) 要【10 場存活】
供給②  training_system.gd:26        add_exp(team, tier, tact × n × 1.0)  每 tick
       ★★而 :19 有一行 `if tact <= 0.0: continue`，tact = leader.skills.get("戰術", 0.0)
       ⇒ 戰術 = 0 的 leader ⇒ 整個迴圈跳過 ⇒ 訓練這條路【對他不存在】
供給③  player_command_system.gd:198 玩家專屬,NPC 沒有
leader 戰術從哪來：game_setup.gd:471 只設 `統領=0.15`（★沒設戰術）；
       person_generator.gd:37-38 戰術只在 老兵/菁英 模板；skill_system.gd:61 有 _grow
```

# 要的五格

```
①★leader 戰術分布 —— 母體＝所有有 leader 的隊
   min/median/max ＋ ★★【戰術 == 0 的隊數 / 總隊數】
   ⇒ 這一格是【判別式】：0 佔多數 ⇒ training 對多數隊不存在（我的假說成立）
                          普遍 > 0 ⇒ ★我的頭號嫌犯錯了,答案在④
②TASK_TRAIN 的隊數，以及其中【tact > 0】的隊數
   ★★兩數之差 ＝「想訓練，而訓練不會發生」的隊 —— 那是【手不聽腦】的形狀
③team.anon_exp 各 tier 的實測分布 vs 門檻（50/100/200）：min/median/max ＋ 達標隊數
④★★★exp 的【流量】：窗內 add_exp 的呼叫次數與總量，★逐來源分（戰鬥 / 訓練）
   ⇒ 沒有這一格就分不出【累積中】與【零來源】—— 而那是這張票的核心問題
⑤promote.kill.* 四格比例（already_elite/not_enough_bodies/not_enough_exp/not_enough_res）
   ★母體要對得起來：四格加總 vs try_promote 呼叫次數（對不上就是有第五條路徑沒被記）
```

# 跑法

```
★窗長由【④】決定,不由成本決定：exp 是【累積量】⇒ 太短的窗會讓「零來源」與「還沒累積夠」
  長得一樣（★今天「空家不返」就是栽在這個 —— 1 天窗看不出糧倉會不會被吃到門檻）。
  ⇒ ★★建議至少涵蓋【一次完整的戰鬥週期＋若干訓練日】,而具體多久【你決定】,
    但★★★卷面要寫明【為什麼那個窗足以讓 exp 累積到看得出趨勢】。
seed/config 沿用你的慣例；★多 seed 與否你自己判斷,理由寫進卷面。
★跑法細節（幾次/多久/要不要縮）你自己決,不用問我也不用問用戶。
```

# 誠實限（請照抄進卷面）

```
①這張卷【不下因果結論】：它量的是「門檻與可達量的距離」,不是「因此世界少了什麼戲」。
②★若 add_exp 沒有現成 tap,那就是【要先加 tap】——★★而【沒有 tap】不得寫成「流量是 0」
  （那是今天早上「只印一邊」那條的同一個坑：沒有印的東西不能當成沒有發生）。
③本卷不改任何常數。門檻該不該動是 WHAT,blueprint 裁。
```

完後改本信 `status: consumed`，回信附 exact path。
