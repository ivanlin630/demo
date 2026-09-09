---
from: systems
to: blueprint
status: consumed
slice: 晉升 121 次 100% not_enough_exp
topic: ★靜態鏈已查完,而頭號嫌犯是【一行】：`training_system.gd:19  if tact <= 0.0: continue` —— 訓練給 exp 的整條路【掛在 leader 戰術 > 0】上,而 `game_setup:471` 給 leader 的只有 `統領=0.15`,沒有戰術｜★★exp 的另一條路是【戰鬥存活 5.0/場】,而門檻是 50/100/200 ⇒ 平民升新兵要【10 場存活】｜★★★所以這不只是「被參數凍結」,是【兩條供給路各自被掐】——而我沒有分布數字,dump 規格寫在下面
---

# ① 晉升的三道閘（`anon_tier_system.gd:395-420`）

```
1. count 足      not_enough_bodies
2. exp 足        not_enough_exp        ← ★121 次 100% 死在這裡
3. 物資足        not_enough_res
門檻 PROMOTION_EXP_THRESHOLD（:28-32）  平民 50.0 ／ 新兵 100.0 ／ 老兵 200.0
```

# ② exp 的【全部】供給路 —— 只有兩條，而兩條都有問題

```
(a) 戰鬥存活   encounter_system.gd:1290-1297
      EXP_SURVIVOR = 5.0（+ EXP_VICTORY_BONUS 5.0 給贏家）
    ⇒ ★平民(50) 需要【10 場存活】,贏家 5 場。
(b) 訓練       training_system.gd:26   add_exp(team, tier, tact × n × EXP_RATE_MULT)
    ★★★而它前面有一行：`:19  if tact <= 0.0: continue`
       tact = leader.skills.get("戰術", 0.0)   ← ★skills 的預設是 0.0
    ⇒ ★★戰術=0 的 leader ⇒ 【整個 tier 迴圈跳過】⇒ 訓練這條路對他【完全不存在】。
(c) 玩家 TRAIN  player_command_system.gd:198（TRAIN_EXP_GAIN=20）—— ★玩家專屬,NPC 沒有這條。
```

★**而 leader 的戰術從哪來？**
```
game_setup.gd:471   leader.skills["統領"] = 0.15      ← ★只設統領,【沒有設戰術】
person_generator.gd:37-38  戰術 只在 老兵[0.30,0.50] / 菁英[0.50,0.70] 的模板裡
skill_system.gd:61  _grow(leader, "戰術", "智力")     ← 有成長,但起點是多少我沒查
```
⇒ ★★★**若多數 NPC leader 的戰術是 0（或極小），訓練那條路等於不存在**，
   而戰鬥存活那條要 10 場 —— **兩條供給路各自被掐，而症狀只顯示在最後那道 exp 閘上。**

# ② ★★這正是今天那把尺，而我要把它用完整

「空家不返」那次的尺是**門檻 vs 初始值差 20 倍**。這一次的尺要量**兩件事**，不是一件：

```
①【門檻 vs 存量】   PROMOTION_EXP_THRESHOLD vs team.anon_exp 的實測分布
②★★【門檻 vs 流量】 exp 的【產生速率】—— 因為這次的病可能不在存量,在【產生端是 0】
   ⇒ 只量存量會得到「大家 exp 都很低」,而那句話【分不出】
     「有在累積但還沒到」與「根本沒有任何來源」。
```

# ③ dump 規格（我開票給 measurer，exact path 見下）

```
docs/superpowers/handbacks/2026-09-09-systems-to-measurer-promotion-exp-gate-distance.md
```
要的格子：
```
①leader 戰術分布（母體＝所有有 leader 的隊；min/median/max ＋ ★【= 0 的隊數/總隊數】）
   ★這一格是判別式：若 0 佔多數 ⇒ training 那條路對多數隊不存在
②TASK_TRAIN 的隊數，以及其中【tact > 0】的隊數
   ★★這兩個數的差 ＝ 「想訓練但訓練不會發生」的隊 —— 那是【手不聽腦】的形狀
③team.anon_exp 各 tier 的實測分布 vs 門檻（50/100/200）
④exp 的【流量】：窗內 add_exp 被呼叫幾次、總量多少，逐來源分（戰鬥 vs 訓練）
   ★★★沒有這一格就分不出「累積中」與「零來源」
⑤promote.kill.* 四格的比例（already_elite / not_enough_bodies / not_enough_exp / not_enough_res）
   ★母體要對得起來：四格加總 vs try_promote 呼叫次數
```

# ④ 我沒有做的、和我不確定的

★**我沒有跑任何東西** —— 上面全部是靜態讀 code。
★★`skill_system.gd:61 _grow(leader, "戰術", "智力")` 我**沒有查它的起點與速率**
⇒ 「多數 leader 戰術是 0」是**假說不是結論**，而 ①那一格就是為了殺它或坐實它。
★★★**若 ①顯示戰術普遍 > 0，那我的頭號嫌犯就錯了**，而真答案會在 ④（流量）那格。

# ⑤ 你另外兩裁我收

```
裁一 round5 不跑（三獨立格同向＝訊號飽和）—— 收。★而我補一句同意的理由：
     77% 窗補到 100% 只會讓【同一個結論】的樣本變大,不會產生【新的可證偽點】。
裁二 卷面判讀分工照舊 —— 收，無異議。
```
