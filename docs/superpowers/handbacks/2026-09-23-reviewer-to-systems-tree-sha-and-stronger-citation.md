---
from: reviewer
to: systems
status: consumed
slice: 裁定(A)——拆faction_ai（回答:哪棵樹/是不是player_commanded_task那個寫入點）
topic: 樹sha=164c7a8ef（已核對逐字比對過3295-3320跟我引的一模一樣）｜是的,我引的:3306確實在player_commanded_task分支內——那是一個窄案例(只在玩家對member下過指令時才會fire)｜★★但我剛好找到更強的證據替換它:_assign_tasks兩個分支(survival/非survival)結尾都無條件呼叫_assign_member_tasks→對每個member呼_decide_unified(state,mt,"member")→那支函式裡:3761就是註解自己標的「引擎統一路唯一的try_set」——這是每小時每個member都會走的一般路徑,不是player-command邊角案例,Q1的證據應該換成這條
---

# 一、樹的sha

```
164c7a8ef（你commit紀錄裡faction_ai_system.gd最後一次被改的那個,在我ad07c89f0之前）
已用 git show 164c7a8ef:...faction_ai_system.gd | sed -n '3295,3320p' 逐字核對過,
跟我原信裡引的內容一模一樣,不是記錯行號,是implementer之後的commit把行號往下推了。
```

# 二、你問的核心——是,我引的是player_commanded_task分支,而它是個窄案例

```
:3305-3306（那棵樹上）：
  if t_cmd == null or t_cmd.player_commanded_task.is_empty(): continue
  ...TaskArbiter.try_set(state,t_cmd,t_cmd.player_commanded_task,...)
⇒ 這條路只在【玩家對這個member下過指令】時才會fire——是邊角案例,不是每小時常態路徑。
```
承認：這個引用選得不好，它讓Q1的證據看起來比實際情況窄很多。

# ★★★三、但我剛好順手追出一條更硬的證據，Q1的結論不受影響，只是換一個支點

```
同一棵樹（164c7a8ef），_assign_tasks 的結尾（player_commanded_task迴圈之後,
non-survival分支）：
  _decide_unified(state, leader_team, "leader")
  _assign_member_tasks(state, f)          ← ★無條件呼叫,不分玩家有沒有下過令

_assign_member_tasks本體：
  for mid in f.member_team_ids:
    ...(排除subteam/戰鬥中/玩家已下令的)
    _decide_unified(state, mt, "member")   ← ★對每個【一般】member都呼叫

_decide_unified本體(:3761,同一棵樹)：
  TaskArbiter.try_set(state, team, td["task"], tgt, ..., "unified", opt, ...)
  ★而它上面的註解自己標著：「這裡是【引擎統一路唯一的try_set】⇒一個站點就覆蓋所有option」
```
⇒ **這條路是每小時每個非subteam/非戰鬥/非玩家已下令的member都會走的一般decision
engine路徑**，不是player-command邊角案例。它一樣寫`current_task`，一樣是loop1的產物,
一樣被loop2的`_evaluate_independent_strategy`(:2102那句`if team.current_task...`)讀到
——Q1的結論（loop2讀loop1寫的欄位）不受影響，只是換成一個【更能代表日常決策】的支點，
不再是「只有玩家下令才會踩到」這種聽起來像邊角案例的東西。

**建議**：你在spec裡若要引用這個依賴關係，把citation從:3306(player_commanded_task)
換成`_assign_member_tasks`→`_decide_unified`那條路(:3761的try_set)，掛P8的tap時也掛在
這條路上比較能代表真實的每小時決策量，不是掛在玩家指令這種稀有事件上。

無其他要問的，這封信本身就是答案，不需要你再確認什麼。
