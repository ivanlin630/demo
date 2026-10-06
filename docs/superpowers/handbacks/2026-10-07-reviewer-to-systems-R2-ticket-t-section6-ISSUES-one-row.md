---
from: reviewer
to: systems
status: open
slice: 票 T §6：休息承諾優先序改讀疲勞＋休息收益補忠誠項
topic: R② ＝ **ISSUES，一列**（`2ce905d9a`，只看§6）｜★你優先打的②：核完——真實的忠誠懲罰是`sim_runner.gd:956`的硬門檦`if team.fatigue >= 1.0`,不是連續函式；§6現在的文字「休息的收益含避免的忠誠損失（同一個FATIGUE_LOYALTY_PENALTY×具名成員數）」沒有寫出這個門檦,照字面讀會在任何疲勞值下都把這一項算進util,正是你擔心的「不累時也被拉高」；①③核過沒問題
---

# 0 審了哪棵樹

`origin/main` ＝ `7d18ef86d`；spec sha `2ce905d9a` 是它的祖先。

# 1 ★你優先打的②——核完：真實懲罰是硬門檦，spec文字沒把門檦抄過去

## 證據：忠誠懲罰的真實觸發條件

```
sim_runner.gd:955-958：
  if team.fatigue >= 1.0:
    for pid in team.named_members:
      LoyaltyBank.adjust(p, -FATIGUE_LOYALTY_PENALTY, "fatigue")
⇒ 這不是「疲勞越高扣越多」的連續函式,是**全有全無**：fatigue 0.99 時懲罰=0、fatigue 1.0 時懲罰=
  FATIGUE_LOYALTY_PENALTY*具名成員數——中間沒有漸增
FATIGUE_LOYALTY_PENALTY = 0.005（sim_runner.gd:21，TEST VALUE）
```

## §6 現在的文字缺這個門檦

```
逐字：「休息的收益含『避免的忠誠損失』（同一個FATIGUE_LOYALTY_PENALTY×具名成員數，讀既有量不新增常數）」
⇒ 這句話告訴implementer要算「FATIGUE_LOYALTY_PENALTY × 具名成員數」這個量,但★沒有告訴他
  這個量只在 team.fatigue >= 1.0 時才算進去——照字面讀,一支fatigue=0.1的隊選「休息」時,
  util也會加上這一項（因為它永遠是FATIGUE_LOYALTY_PENALTY×具名成員數,跟目前fatigue無關）
⇒ 這正是你自己問的「會不會讓休息在不累時也被拉高」——答案是：**照現在的文字會**,
  因為文字沒寫條件句,只寫了要算哪個量
```

## 處置

```
補一句明文門檦，照搬sim_runner.gd:956同一個條件：
  「該益處項只在 team.fatigue >= 1.0 時才非零（跟真實懲罰同一個門檦，不要連讀fatigue值算一個
   漸增的近似值——真實懲罰是全有全無，近似出來的連續量會在fatigue還沒到1.0時就先給休息一個
   不存在的優勢）；fatigue < 1.0 時這一項 = 0」
⇒ 這樣修完,休息在不累時（fatigue<1.0）util不會因為這個新項目被拉高,只有真的累垮（會被
  LoyaltyBank扣到的那個狀態）才拿到這個避免掉的收益——跟你問題裡「應只在累垮時才有那一項」
  逐字對上
```

# 2 ①③ 核過沒問題

```
① 疲勞只影響移動(path_system.gd:191)與戰鬥體力(encounter_system.gd:147)、不影響施工產出——
  這個查證是靜態讀碼可以支持的正面斷言（這裡有讀fatigue／那裡沒有），而你據此判斷「施工隊
  從不休息是照世界規則理性」而不是秤壞了，這個歸因方向對；而忠誠懲罰確實存在但決策看不到，
  判準庫那條「決策讀不到自己的狀態」在這裡適用，接電補上是對的處置
③ P1改判只判會移動/戰鬥的隊，施工隊印出不判、等WHAT——範圍控制對，跟今天另外幾張票
  同一個紀律（量了再說/回報不補），不在這張小票裡越權做WHAT決定
```

# 3 判決

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "休息的收益含避免的忠誠損失（FATIGUE_LOYALTY_PENALTY×具名成員數）",
     "file_line": "sim_runner.gd:955-958（真實懲罰的硬門檦if team.fatigue>=1.0）",
     "truth": "spec文字沒寫這個門檦,照字面implementer會讓這一項在任何fatigue值下都算進util,導致休息在不累時也被拉高;要補一句明文門檦,fatigue<1.0時這一項=0"}
  ],
  "note": "①③核過沒問題。改完②那句門檦敲sha，我只看那處。" }
```
