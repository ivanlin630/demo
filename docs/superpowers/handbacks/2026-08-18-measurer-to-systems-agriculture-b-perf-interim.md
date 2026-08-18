---
from: measurer
to: systems
status: open
topic: agriculture-b-perf-interim-churn-finding
---

# 農業b popcap長跑中途插播：SurvivalMergeIn churn，疑跟②爆/塌雙面同根

②pop-account量測（3mo warring_states）還在跑（截稿時進度~65-70/90天），但已經跑了超過3小時——遠比同規格局正常耗時長很多。中途插播一個已經坐實、值得先報的異常。

## 現象：team暴增 + 同對隊反覆merge-in卡迴圈

- team ID 從起始49隊一路長到 242+（overflow/split不斷造新隊）。
- `[SurvivalMergeIn]` log 目前累計 **698 行**，同一對隊反覆出現，不是各自一次性事件：

| team對 | 出現次數 |
|---|---|
| Team58→Team27 | 54 |
| Team143→Team109 | 47 |
| Team134→Team46 | 41 |
| Team123→Team28 | 33 |
| Team213→Team48 | 29 |
| Team305→Team14 | 26 |

## 機制：committed 但從未真正執行完

`faction_ai_system.gd:4863` 這行印出時，代表 `TaskArbiter.try_set(...)` 剛成功（`_surv_ok=true`），理論上這隊「已經 commit 去合併」。但同一對隊隔幾個 tick 又印一次同樣的訊息——代表**這隊還活著、還在重新決定要合併、還在重新 commit 同一個 target**，真正的合併（讓來源隊消失）從未發生。這是本 session 已知的病灶家族：「committed 卻不resolve」churn（跟先前 hand-obeys-brain arc 抓過的幾個同型案例同款）。

## 我還沒驗證的部分（誠實揭露）

我**還沒確認**這是：
1. **agriculture-b 引入的新問題**（新 pop-cap 機制把更多隊擠進 overflow/homeless 狀態，衝高了走到這條 merge-in 路徑的隊數，讓一個原本很少被觸發的既有 churn bug 大量現形）——這是我目前傾向的假說，因為 team 暴增(49→242+)本身就是②量測要抓的「塌/churn」現象的直接產物；還是
2. **main 上原本就有的既有 bug**（跟 agriculture-b 無關，只是這輪高強度局剛好把它逼出來）。

沒有跑過 main baseline 的同款設定做對照，不能斷言歸因。若要坐實，需要在 main（無 effective_pop_cap）跑同 seed/config 一輪比對 SurvivalMergeIn 頻率。

## 效能面

這 698 次白做工（try_set 成功但沒有真正產生任何狀態改變）本身就是浪費 CPU 週期的來源之一，可能是這輪 popcap 長跑異常慢的部分解釋（但非唯一解釋——team 暴增到 242+ 隻本身也會讓每 tick 的 O(隊數) 迴圈變貴）。

## 建議

不阻塞正在跑的 popcap 量測（讓它跑完，②的完整分布數字仍會回報）。但這個 churn 現象本身建議另開一張票交 implementer/systems 判斷：`_surv_ok` 成功後為何沒有讓合併真正執行（是 `try_set` 只設了 task 沒觸發真正的 merge_teams 呼叫？還是 merge 呼叫了但前置條件不滿足被吃掉？）。這跟 agriculture-b 的 pop-cap gate 本身是否嚴重（塌/churn）是同一個問題的兩面——如果這個 churn bug 修好，②的 overflow 事件率數字可能會完全不同，值得先把這個插播查清楚再看②的最終數字要不要重跑。
