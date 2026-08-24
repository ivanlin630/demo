---
slice: a1-construction-dispatch-drop
tier: full
qa: required
from: systems
topic: A1 建設族 —— 「紮根 argmax 贏 8 → 真開工 1」的 7 個 drop 去哪了(結構列舉,禁逐隻抓)
---

# A1 建設族：`8 → 1` 的 drop 點分佈

**來源**：blueprint 裁定 2026-08-21，`camp-access` 四端同秤實測 `紮根贏 8 → 開工 1 → 完工 0`。
**這是「手不聽腦第 4 型」本尊**：建設 argmax 贏了、`try_set` noop。
**清單 A1／B6 早就列著，但一直沒有硬數字 —— 現在有了。**

## §1 方法（**硬性**）
★**結構列舉 drop 點，不准逐隻抓。**
這族已經栽過三次：逐隻追會追到天亮，還漏掉沒想到的那一種。
**做法**：把「argmax 贏 → `settlement.l0_to_l1_start`」之間的**每一個 return／false 分支各掛一顆 tap**，
**一輪跑完看分佈**。

## §2 站點已窮盡列出（systems code-read，implementer 不必再找）

```
紮根 argmax 贏
  │
  ├─① to_task 回 {TASK_BUILD, target, settle_site}        options.gd:203-222
  │
  ├─② TaskArbiter.try_set(...) 可能 false ← ★四個已知原因（option 註解自列）
  │     (a) combat 鎖   (b) crisis 免疫窗
  │     (c) progressive-hold persist   (d) 同層搶班失敗
  │     ★注意 priority = PRIO_DISPATCH（committed 後只值 @50，低於 PRIO_THREAT 70）
  │
  └─③ _commit_settle_site（faction_ai:5063，try_set 成功後才跑）四個 early-return：
        (a) not td.has("settle_site")
        (b) tile == null
        (c) ★resume 分支 → bump `settlement.l0_to_l1_resume`（**不是 start**）
        (d) ★tile.camp_level != 1  or  outpost_level > 0  or  construction_team_id != -1
             → 「情境已變」靜默 return
  │
  └─④ 落地 → bump `settlement.l0_to_l1_start`
```

**要的分佈**：**①②(a~d)③(a~d)④ 每一格的計數**，一輪 90 天同床（peaceful seed 1337）。

## §3 ★一個高嫌疑假說（**待驗，不得當結論**）
**③(d) 的 `tile.camp_level != 1`** ——
紮根要求**站在 `camp_level == 1` 的 tile 上**，但**營地棄置率 75%**（`camp.built 24 / abandoned 18`）。
⇒ **決策時 `can_settle_here` 為真，到 commit 時營地可能已衰減成 level 0 ⇒ 靜默 return。**
★**若分佈證實 ③(d) 佔大宗，這條 drop 與「蓋了就丟」是同一顆病的兩個出口。**
**但這只是假說** —— 分佈說了算，**不准先照這個假說改 code**。

## §4 判讀規則（**先寫好，免得看到數字才編故事**）
| 分佈落點 | 意義 | 修法方向 |
|---|---|---|
| **②** 佔大宗 | 仲裁端搶班／鎖 | 看是哪一個原因；`persist`／`priority` 層 |
| **③(c) resume** 佔大宗 | 不是 drop，是**重複認回同一個工地** | ★那 8 次可能是**同一隊反覆**，母體要重算 |
| **③(d)** 佔大宗 | 決策與 commit 之間**世界變了** | 與 camp 棄置同源 ⇒ 併 camp 工期票一起看 |
| **①** 有量 | `to_task` 自己回空 | 上游 ctx 問題 |

★**②③(c) 那格特別重要**：如果 8 次裡有數次是 resume，**「贏 8 次」的母體語意就不是 8 個獨立機會**
—— 這正是我今天被咬過的**母體 vs 樣本**問題，**先報母體語意再談 drop 率**。

## §5 不在本刀
- `1 → 0`（工期端）→ **`camp-access` 工期票**（另開，不併）
- `subteam-idle-latch`（B6 另一半舊帳）→ 不動

## §A ★★acceptance 頭條（blueprint 升格 2026-08-25）

**普查坐實**：`peaceful` 90 天 **outpost day0 ＝ 11 → day90 ＝ 9、中途新增 ＝ 0**
⇒ ★**這個世界只會失去據點、不會產生據點**（文明化從未發生、去文明化正常運作）。
**併同 `construct.progress 344 / stall 5871 ＝ 94.5% 停滯`。**

⇒ **本票與另一票（A1 建設族 ／ camp 工期）的 acceptance 頭條升格為**：
> ★**「從無到有蓋成一個 outpost」＞ 0 —— 文明化二值閘。**

**二值、無旋鈕可假造**（同 §7 #1 的設計理由）。**兩票落地後同床重量。**
★**blueprint 明示不開新案**：修法就是這兩票，**排程零調整**。

## §6 閘
`headless` ／ `det×3` fp ／ `constitution_gate` ／ `seam-gate`（**HARD**）／
★**tap 全部 Probe-gated**，且**不得耗 global RNG**（觀測禁改被觀測物）。
