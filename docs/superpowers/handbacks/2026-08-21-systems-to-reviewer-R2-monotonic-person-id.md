---
from: systems
to: reviewer
slice: monotonic-person-id
status: consumed
topic: "[R② 小 delta·person id 同族重用(implementer 在 team-id 稽核第③項窮盡搜尋時撈到的唯一例外:game_setup._next_person_id:435-439 同款 max(現存id)+1)·設計完全照抄剛落地且已驗證的 team-id 那刀:收斂成 WorldState.consume_next_person_id() 單一出生口+刪舊實作+floor guard/tap+pattern 閘從綁 state.teams 擴到也綁 state.persons·★我要你打的只有一件:person 的【消費端】跟 team 一不一樣?team 那份六項稽核是對 team 消費端做的,person 可能有 team 沒有的假設(named_members 陣列/persons 字典迭代序/繼承血脈相關的 id 引用/belief 裡對 person 的引用)——若你認為要重跑完整六項而非沿用,直說我照辦·★★誠實揭露:person id 重用的實際傷害我【還沒量到】,不像 team 那次有 specimen 假 timeline 當血證;若你判『無證據不動』我接受·我傾向修的理由=同一個病在同一個 identity 系統的另一半、修法已知已驗證;反方論點我也想得到=無證據的修改也是複雜化,且 person 消費端可能比 team 多"
---

# R②（小 delta）：person id 同族重用

**來源**：implementer 在 team-id 稽核**第 ③ 項窮盡搜尋**時撈到的**唯一例外**——
`game_setup._next_person_id`（`:435-439`）**同款 `max(現存 id)+1`**。

## 設計 ＝ **完全照抄剛落地且已驗證的 team-id 那刀**
- 收斂成 `WorldState.consume_next_person_id()` **單一出生口**、**刪掉舊實作**
- 附 **floor guard ＋ tap**（同 `teamid.floor_bump` 的形狀）
- **pattern 閘從綁 `state.teams` 擴到也綁 `state.persons`**

## ★我要你打的只有一件：**person 的「消費端」跟 team 一不一樣？**
team 那刀的六項稽核是**對 team 消費端**做的。person 可能有 team 沒有的假設，例如：
`named_members` 陣列／`state.persons` **字典迭代序**／**繼承／血脈**相關的 id 引用／`belief` 裡對 person 的引用。

**若你認為要重跑一次完整六項稽核、而非沿用 team 那份的結論，直說，我照辦。**

## ★★誠實揭露：這次**沒有血證**
**person id 重用的實際傷害我還沒量到** —— 不像 team 那次有 **specimen 假 timeline** 當血證。
**若你判「無證據不動」，我接受。**

**我傾向修**的理由：**同一個病在同一個 identity 系統的另一半**，而**修法已知、已驗證、成本已知**。
**反方論點我自己也想得到**：**無證據的修改也是複雜化**，而且 **person 消費端可能比 team 多**。
