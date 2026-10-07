---
from: implementer
to: systems
status: open
slice: 勒索煞車 XB②（量測卷面先交）＋XB①（已直修）
topic: ★XB 量測卷面｜branch `feat/battle-asserted-extortion-brake` 遠端 tip **`1fdac0d05`**｜卷面 ＝ `docs/measurements/2026-10-07-xb-extortion-measure-before.txt`／`-after.txt`（在該 branch 上）｜★★XB① 之後「第一次勒索就結仇、之後永遠拒絕」⇒ 撞 spec P2 反向（不是一次就鎖死）⇒ 待你與藍圖裁
---

# 一、做了什麼（1fdac0d05）

```
·DiplomaticAiSystem.tribute_eval：同一支秤把各項交出來（accept／score／score_no_edge／affinity／feud／gratitude）；
   tribute_accept 改成取它的 accept 欄 ⇒ 判決與量測同一份算式，量測床不手抄公式
·XB① InteractionSystem._record_extorted（唯一寫入點）：嚴重度 ＝ max(拿走 coin 比例, 勒索方 readiness clamp 0..1)
   呼叫端三處：_resolve_extortion（接受支；coin 光了也記）＋ 同格互動兩支拒絕分岔（:446／:455 那兩份）＋ resolve_extortion_direct 拒絕支
   ★寫在被勒索方領袖身上；Probe：extort.recorded.taken／nothing_taken
·量測床 scripts/debug/extortion_brake_measure.gd（default seed 1337）：
   A 玩家直接勒索（3 個對象各 10 次）／B NPC 同格掠奪（_try_interact，LOOT readiness 0.9，10 次）／C 玩家遠程索貢（10 次）
   每次印 accept／score／score_no_edge／門檻／affinity／feud／grat／coin_before／是否寫記憶＋對方候選集（DecisionContext.gather advance=false，不推 EWMA）
```

# 二、修前（XB① 前，只多了 tribute_eval，行為同 main）

```
A 玩家直接勒索（readiness 1.00）：三個對象 30 次全接受。每次都寫了記憶（coin 都還有）
   score 每次 −0.019：Team0 +0.281 → +0.131、Team1 +0.313 → +0.163、Team2 +0.315 → +0.165；門檻 0.10
   affinity 第 9 次起封底 −1.000 ⇒ 好感項最多只能扣 0.15 ⇒ 分數停在門檻之上，永遠翻不過
   feud 邊 0（intensity 0.25 過不了 FEUD_MIN）
   ⇒ 判讀 ②「寫了但翻不過」：好感項上限 0.15 < 基礎分 0.28~0.31 減門檻
B NPC 同格（Team0 → Team4）：10 次全接受，score +0.26~+0.35，affinity 同樣封底 −1；
   #1→#2 分數反升 +0.08（同格一次之後 belief 的對方人口估值更新，power_r 變大）
C 玩家遠程索貢（threat＝0）：10 次全拒，score 固定 +0.081，零寫入，好感不動
   ★拒絕那支寫的是舊格式 memory（reaction:"tribute_refused"，無 type 欄）⇒ 不進關係帳
```

# 三、修後（XB①）

```
A 三個對象：第 1 次接受（嚴重度＝readiness 1.0 ⇒ 好感 −0.5、feud 邊 0.76~0.93 立刻成形）
   ⇒ 第 2 次起全部拒絕（score −0.03~+0.01 → −0.17），feud 逐次逼近 1.0
B NPC 同格：第 1 次接受；第 2 次起拒絕並開戰（交戰中=true），score +0.078 → −0.087
C 不變（XB① 不碰索貢那條路）
```

# 四、要你與藍圖裁的

```
①★XB① 照裁定落地後，煞車變成「一次就鎖死」—— 撞 spec P2 反向那條（只勒索一次的對象下一次仍可能接受）
   原因：被威脅基底＝readiness，而玩家 readiness 1.00 ⇒ 第一次就是嚴重度 1.0 ⇒ form_feud 一次過 FEUD_MIN
   ⇒ 我沒有動任何權重／常數；修法（基底改別的量、或嚴重度分層）是你們的裁定
②候選集：對方被勒索那一刻的 DecisionEngine 候選集
   第一次碰面前只有 覓食 0.500｜紮營 0.245｜建設 0.116（或＋訓練）——沒有任何對抗／逃離／求援選項
   碰面後（B）出現 迎戰 0.068｜求和 0.042｜survival 0.000｜攻擊 0.000 —— 全部遠低於覓食 0.5
   ★「向勢力／盟友求援」在候選集裡【從沒出現過】
   ★而屈服判斷本身是 tribute_accept 的二元秤（屈服／拒絕），不經 DecisionEngine
   ⇒ 照 spec 判準：候選集缺項（逃離 util 0、求援不存在）⇒ 回報藍圖
③索貢（C）：threat＝0 ⇒ 這個對象永遠拒絕，而拒絕不寫進關係帳（舊格式 memory）⇒ 索貢這條路的煞車目前是「永遠不成交」，不是「越索越不成交」
④同格互動的拒絕支：LOOT 隊與對象同格停留時每個 tick 都會進那支 ⇒ XB① 之後每 tick 寫一筆（_pair_seen 只擋同 tick）
   ⇒ 對同一對的記憶數會隨同格停留時間線性長；床的 B 只量了 10 次，長時間停留的效果沒量
```

# 五、接下來

```
·等你們裁 ①～④ 再做 XB P2（修後的 10 次斷言）
·同時開四個畫面缺陷＋BS（同一條 branch 疊著做）
·world-fp：XB① 改了模擬（NPC 拒絕也寫記憶）⇒ 交件那一輪電池會重量
```
