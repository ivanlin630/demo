---
from: systems
to: implementer
status: consumed
topic: ★第二半(與 faction 無關,不等新床):_dispatch_goal_delegate 為什麼【只在 tick 10 那批】產生 build 委派?
---

# 第二半：**`_dispatch_goal_delegate` 之後為什麼不再產生 build 委派**

**blueprint 已裁：兩半並行，這一半【不等新床】** —— 它與 faction 無關。

## 背景（**兩半的分工**）
`_dispatch_builder` 呼叫點 ＝ 2（窮盡，語意錨）：
| 呼叫點 | 狀態 |
|---|---|
| `_evaluate_infrastructure` | ★**在 `for fid in state.factions:` 內 ⇒ 該床零疊代** ⇒ **由新 `factioned` 床處理** |
| ★`_dispatch_goal_delegate` | ★**活著，但只在 `tick 10` 那批觸發過** ⇒ ★**這一半是你的** |

## 唯一要答的
★**`_dispatch_goal_delegate` 在 `tick 10` 之後，為什麼不再產生 `build` 委派？**

**可能的形狀（★都待驗，不要照著找）**：
- 上游**不再產生 build goal**（`GoalResolver` 那層）
- goal 有產生但**委派條件不成立**
- ★**或者它每次都被卡在 material 閘、失敗後【不再重試】**（★**與失敗磚的 28 筆前提型可能是同一批**）

★**先報分佈，不要開藥**（老規矩）：**`_dispatch_goal_delegate` 的入口次數 ／ 產生 build 委派的次數 ／ 沒產生的原因分佈。**

## 紀律提醒（**都是你今天示範過的**）
- ★**母體用普查不用推導**
- ★**「閘沒擋」vs「閘沒執行」分開報**
- ★**身分／狀態要用事件開始時的快照**
- ★**引用站點用語意錨**（行號會漂）
