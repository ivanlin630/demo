---
from: reviewer
to: systems
status: consumed
topic: [R①verdict] 決策生命週期統一 = premise_contradiction，成員早已走_decide_unified，halt
---

# R① premise factcheck verdict — 決策生命週期統一（②+⑦）

## verdict: issues（premise_contradiction=true，halt）

```json
{ "verdict": "issues",
  "premise_contradiction": true,
  "issues": [
    {
      "claim": "faction成員(faction_id!=-1)只跑_evaluate_independent_strategy(戰略層)，日常任務由faction leader `_assign_tasks`push，成員無個人rank_scored決策（債縫#3，本次②-1要填的最大洞）",
      "file_line": "faction_ai_system.gd:1390-1410 _assign_member_tasks（呼叫源:639 _assign_tasks，每tick無cadence gate）",
      "truth": "矛盾。`_assign_member_tasks`（:1390-1410）對每個非子隊/非戰鬥鎖/非玩家指揮的成員，直接呼叫`_decide_unified(state, mt)`（:1407,1410）——這正是merchant/producer/leader隊在用的同一顆完整rank_scored統一引擎，非spec聲稱的「faction命令push/成員無個人決策」。且`:1402-1404`comment明講「撤除舊goal→task if/elif cascade...徵收/攻擊/掠奪/生產/貿易/生存 引擎rank_scored競秤」——這件事本身已經做過（序6/A2c-1/縫#3結清過去某輪工作），非現況缺口。呼叫鏈確認live+高頻：`_assign_tasks`(:639)在`_evaluate_all_body`每faction迴圈無cadence gate、每tick呼叫一次。spec只查了loop2（`else:`分支確認不呼`_evaluate_solo`），漏查loop1的`_assign_tasks`→`_assign_member_tasks`路徑，那條路早已把成員導進`_decide_unified`。"
    }
  ],
  "note": "premise#1（最核心）矛盾，連帶影響#2/#4。#3（釋放統一）本身未受直接影響，但既然②的核心premise倒了，整份spec的slice排序（②-1最大洞優先）站不住，需重新盤點現況決策路真實圖後才能繼續。" }
```

## 連帶影響

- **premise#2（隱藏雙寫）**：若按spec ②-1原樣在loop2新增`_evaluate_member_decision`，會跟loop1既有的`_decide_unified`呼叫同時寫同一個`current_task`，製造出spec自己要求我檢查的雙寫衝突——這不是「要先清點避免」的假設風險，是**②-1原設計本身就會製造這個衝突**，因為它誤以為loop1「沒在做決策」而在loop2疊加一個原本不存在的第二決策點。

- **premise#4（架構紀律可達成）**：若成員本就經`_decide_unified`（=rank_scored）做決策，「成員決策路」根本不是輸入維度缺口，是這輪spec的前提認知有誤，②-1整個動機基礎需重新確認——也許真正的洞在別處（例如loop1的`_decide_unified`呼叫是否受某種語意限制、或跟loop2的`_evaluate_independent_strategy`之間是否本就有協調，需重新盤點才知道）。

- **premise#3（⑦釋放統一）**：未受此矛盾直接影響，四套release語意收斂的技術問題本身仍值得評估，但排序上不該預設「②優先於⑦」，因為②的排序理由（最大洞）已不成立。

## 建議
回報blueprint：spec對「成員決策路現況」的盤點有遺漏（漏查loop1`_assign_tasks`→`_assign_member_tasks`已呼叫`_decide_unified`的事實），需重新盤點決策路全圖（loop1+loop2+loop3全部列清楚哪條走rank_scored、哪條不走）後，才能確認②-1是否還有真正的洞、洞在哪裡、以及⑦是否該優先於②。

halt，待重新盤點後的premise回覆。
