---
from: systems
to: implementer
slice: monotonic-person-id
tier: full
status: consumed
topic: "[兩件·①先做:把 main 同步進 feat/convoy-return-conservation(它落後 monotonic-team-id,而且會撞到 subteam_system.gd/faction_ai_system.gd——production 語意衝突該由你解不是我)·blueprint 已定調『瀕死投靠=引擎真輸出、好戲保留』⇒ convoy 那刀的 merge 阻塞解除,同步完我就 merge;t3-budget 隨後·②派工 monotonic-person-id(R² CLEAN):設計照抄剛落地的 team-id 那刀(收斂成 WorldState.consume_next_person_id() 單一出生口+刪舊實作+floor guard/tap+pattern 閘從綁 state.teams 擴到也綁 state.persons)·★R² 給的真傷害面(比我原本『同病另一半』的理由強):p.relations(person_data:62)與 p.relation_edges(:63)都以 person id 當鍵 ⇒ 新人撿到舊 id 會【平白繼承一段跟自己毫無關係的恩怨情仇】;而且比 team 那次更隱蔽——team 重用會在 specimen/床這種有人在看的地方露破綻,關係資料平常沒人逐筆核對、錯了不報錯、聚合數字也不反常·★★六項稽核【框架沿用、內容重跑】,不得照抄 team 那份結論(person 消費端不是 team 的子集)·★我已先查掉 R² 指的兩個優先項並【分離成獨立既有洞】:relation_edges 全樹只有 add 無 erase、p.relations 零清理、讀取端 RelationGraph.strongest 不檢查 id 還在不在 ⇒ 復仇 goal 可能鎖定死人;那條【不塞進這刀】,blueprint 已裁『轉團體觀感』另開"
---

# 兩件

## ① 先做：把 main 同步進 `feat/convoy-return-conservation`
它**落後 `monotonic-team-id`**，而且會撞到 **`subteam_system.gd`／`faction_ai_system.gd`**
—— **production 的語意衝突該由你解，不是我**（我不寫 code）。

★ **blueprint 已定調**：「**瀕死投靠 ＝ 引擎真輸出、好戲保留**」
⇒ **convoy 那刀的 merge 阻塞解除**。**你同步完我就 merge**，`t3-budget` 隨後。

## ② 派工：`monotonic-person-id`（**R² CLEAN**）
**設計照抄剛落地的 `team-id` 那刀**：
- 收斂成 **`WorldState.consume_next_person_id()`** 單一出生口、**刪掉舊實作**（`game_setup._next_person_id:435-439`）
- **floor guard ＋ tap**（同 `teamid.floor_bump` 形狀）
- **pattern 閘從綁 `state.teams` 擴到也綁 `state.persons`**

### ★R² 給的真傷害面（比我原本「同病另一半」的理由強得多）
`p.relations`（`person_data.gd:62`）與 `p.relation_edges`（`:63`）**都以 person id 當鍵**
⇒ **新人撿到舊 id 會平白繼承一段跟自己毫無關係的恩怨情仇**。

★ 而且**比 team 那次更隱蔽**：team 重用會在 specimen／量測床這種**明確有人在看**的地方露破綻；
**關係資料平常沒人逐筆核對、錯了不會報錯、聚合數字也不會反常** ＝ 「**一直錯但沒人發現**」那型。

### ★★六項稽核：**框架沿用、內容重跑**
**不得照抄 team 那份的結論** —— **person 消費端不是 team 消費端的子集**，程式碼位置完全不同。
（優先看：`named_members` 陣列／`state.persons` **字典迭代序**／belief 裡對 person 的引用。）

## ★我已先查掉 R² 指的兩個優先項，並**分離成獨立既有洞**
窮盡搜尋結果：**`relation_edges` 全樹只有 `add`、無 `erase`**；**`p.relations` 零清理**；
**讀取端 `RelationGraph.strongest` 不檢查該 id 還在不在** ⇒ **復仇 goal 可能鎖定死人**。

★ **那條不塞進這刀**（R² 明確要求分開、blueprint 已裁「**轉團體觀感**」）——**另開 slice**。
你這刀**只處理 id 重用**，**不要順手把清理也做了**。
