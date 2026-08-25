---
from: systems
to: implementer
slice: subteam-survival-ladder
tier: full
status: consumed
topic: "[派工·在途子隊入同一把求生尺(用戶連兩問裁定,R² CLEAN)·★排在最後但它是四張裡最大的一張:t3同步 → person-id → breed-anon → 本刀·spec=docs/superpowers/specs/2026-08-21-subteam-survival-ladder-HOW.md·★決策真空不是 convoy 專屬:_evaluate_subteam 對移民/BUILD/CONSTRUCT/UPGRADE/EXPAND/CONVOY 全部早退 ⇒ 所有在途子隊都不做決策·★而兩塊拼圖已在位:PROGRESSIVE_HOLD_TASKS 列的正好就是這些 task、hold 對 ≥PRIO_THREAT 讓行 ⇒ 承諾保護早就對了,缺的只是子隊沒被問·設計=每 tick 先跑求生尺評估、未觸發維持現行早退;★★單一源鐵律:禁為子隊複製一份 survival 邏輯/選項表/門檻(今天已因『兩個物理上分開的同步概念』栽四次,複製=製造第五次)·★★gate3 措辭 R² 訂正過,你回報時照這個拆法:survival-override 方向【真的活了】、routine-block 方向【仍結構性打不到】(本刀不開放 routine ⇒ 沒人對子隊搶班 ⇒ hold 沒東西可擋)⇒ 帳上寫【T1 半活】不得寫【T1 活了】·R² 已親查 faction_id/leader_id/is_subteam 三個耦合點皆正確處理,coupling 風險低·perf 門檻 5% R² 認可"
---

# 派工：在途子隊入同一把求生尺（**R² CLEAN**）

**WHAT**：用戶連兩問裁定（授權真檔 ＝ blueprint 五裁定信 §②）
**spec**：`docs/superpowers/specs/2026-08-21-subteam-survival-ladder-HOW.md`

## ★排序：排在最後，但**它是四張裡最大的一張**
`t3-budget` 同步 → `monotonic-person-id` → `breed-anon` → **本刀**。

## 前提（我已查證，你不用重查）
- **決策真空不是 convoy 專屬**：`_evaluate_subteam` 對
  **移民／BUILD／CONSTRUCT／UPGRADE／EXPAND／CONVOY 全部早退** ⇒ **所有在途子隊都不做決策**。
- ★**兩塊拼圖已在位**：`PROGRESSIVE_HOLD_TASKS` **列的正好就是這些 task**、
  **hold 對 `≥PRIO_THREAT` 讓行** ⇒ **承諾保護早就對了，缺的只是子隊沒被問**。

## 設計
**每 tick 先跑一次求生尺評估；未觸發則維持現行早退。**

### ★★單一源鐵律（本刀最重要）
**禁為子隊複製一份 survival 邏輯／選項表／門檻。**
走**既有 survival option set ＋ 既有 `DecisionEngine`**，**只是把子隊也送進去問**。
★ 今天已因「**兩個理論上該同步、物理上分開**」栽四次
（specimen 選樣清單凍結／fate 以隊伍消失推論／trip 以 id 為鍵／七份 `_next_team_id`）——**複製一份 ＝ 製造第五次**。

## ★★gate 3 的措辭：R² 訂正過，回報時照這個拆法
- **survival-override 方向：真的活了**（求生選項第一次真的走 `try_set`、hold 讓行）
- **routine-block 方向：仍結構性打不到**（本刀不開放 routine ⇒ 沒人對子隊搶班 ⇒ hold 沒東西可擋）
⇒ **帳上寫「T1 半活」，不得寫「T1 活了」** —— 否則**重演 convoy 那輪的 over-claim**。
（`persist.hold` 對子隊 task **預期仍為 0**；**若非 0 反而要查是誰在對子隊丟 routine**。）

## 其餘
- **R² 已親查** `faction_id`／`leader_id`／`is_subteam` **三個耦合點皆正確處理**，coupling 風險低。
- **perf 門檻 5%** R² 認可（`faction_ai` 是 93.7% 熱點，超過要先講）。
- **§3 留帳**：dispatch 記委託清單 → 歸建比對差額 → 寫進母隊 belief。
  ⛔ **不新造評價／懲罰系統**——「**後果應該是別人怎麼看你，不是系統罰你**」。
