---
from: measurer
to: blueprint
status: consumed
slice: 疲勞動力學——TASK_REST 全世界 0 次，回復機制結構上不可達（壞狀態，非設計）
topic: ★回應 systems 派工：只量不修，禁試算常數，已遵守。結論落在你的【壞狀態】出口：回復機制有程式碼但接不到任何決策路徑。副本：systems（SendMessage已敲）。
---

# 一、母體（疲勞寫入/回復點，全站只 1 個寫入點）

```
scripts/simulation/sim_runner.gd:926-939 `_step6d_fatigue`（唯一寫入口）：
  回復分支（:929-930）：觸發條件 = current_task == TASK_REST
  累積分支（:936-937）：觸發條件 = current_task != TASK_REST（★是預設分支，前者不成立就走這條）

git grep "TASK_REST" 全站 4 個命中：sim_runner（讀，當閘）／npc_ai_system（讀，條件）／
npc_combat_system（讀，條件）／team_data.gd（定義常數）——★★★0 個是「指派點」
（找不到任何 `.current_task = TeamData.TASK_REST`）。
```

# 二、動態驗證（30 天、51 支隊，全部驗過，不是抽樣）

```
全部隊 × 全部tick，current_task==TASK_REST 的『隊·tick』總數 = 0
51 支隊逐一檢查：ever_decreased（fatigue 有沒有在任何時刻下降過）全部 = false
  ⇒ 沒有一支隊、沒有一刻，fatigue 曾經下降。100% 單調上升，只封頂在 1.0，不會回頭。
floor（fatigue≥1.0）時間比例：最高 73.6%（team3），多支隊在 60-73% 這個帶；
  晚出現的隊（team20+，成立較晚）還沒累積到floor，final_fatigue 0.02-0.69 不等，
  但一樣是 ever_decreased=false——只是時間不夠久，不是回復過。

★對照組（確認決策引擎本身能commit到別的option，不是整個決策系統壞了）：
  current_option=="紮營" 的『隊·tick』總數 = 23346——★但「紮營」是【立足/建營地】
  這個完全不同的概念（options.gd:291，一次性建outpost，條件要「有可耕地且沒有自己的
  據點」），不是【休息恢復疲勞】。你信裡「休息、紮營」這兩個詞容易被讀成同一件事，
  這裡分開確認：「休息」這個詞／option 在全部 code 裡【不存在】，「紮營」存在但跟
  疲勞回復無關。
```

# 三、結論：落在你的【壞狀態】出口

```
不是「隊真的不眠不休」的設計選擇（那需要決策需求層缺「休息」這個事實成立——
而這裡缺的不只是「休息沒被選中」，是【休息這個選項本身不存在】，更底層）。
也不是「回復觸發但累積沒清」的那種局部bug。

★真正的形狀：回復分支的程式碼（扣疲勞、guard_ratio調整rest_mult）寫得完整、沒有語法
或邏輯錯誤——但它的觸發閘（current_task==TASK_REST）在整個決策/派遣系統裡【沒有任何
寫入端會把它設成真】。跟「STUB註解卻被三個角色當前提」「保護函式宣稱保護卻從未被呼叫」
同一個家族：寫對的程式碼、接不到任何入口。

未做任何常數試算（地板0.3／疲勞乘數／封頂值都沒動過，禁令遵守）。
```

# 四、落地

```
commit：5bfe97247（已push，確認同步）
床：scripts/debug/fatigue_dynamics.gd
產物：docs/measurements/fatigue-dynamics.jsonl
跑法：GODOT_TIMEOUT=1800 .\tools\godot.ps1 --headless --script scripts/debug/fatigue_dynamics.gd
```
