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

---

## §B ★★分佈回來了：**本票原始 scope【證偽】，重新定義**（2026-08-25）

**實測**（`peaceful_economy` / 1337 / 90d，殘差稽核 **＝ 0 ⇒ 列舉完整**）：
```
argmax won = 5      (lost_to 合計 111：備戰24/workshop21/覓食17/返家14/貿易10/…)
dispatch    = 9     ★比 argmax 多 4 —— 迴圈 fallthrough，紮根有 4 次以【次佳】被試
守衛 drop   = 0
try_set     ok 6 / fail 3   （persist_hold 1、同層搶班 2、★combat_lock 0、crisis_immunity 0）
commit      entered 6，五種 early-return 全部 = 0（含 resume 2 ＝ 認回自己工地、非 drop）
            ⇒ ★獨立紮根機會 = 4，全部 start，站③ drop 率 0.0%
工期        start 4 → complete 1 → outpost.l0_to_l1 1
```

### ⚠️ 訂正一：**票面「贏 8 → 開工 1」的 8 與 1 都要重新定義**
同床同 seed 實測是 **9 dispatch / 4 start / 1 complete**。
（票面那組是 `b968f492` 的舊數字，已被後續 commit 取代。）
★**`won_argmax` 不是機會數** —— dispatch 還有 fallthrough；`entered` 含 resume。**母體語意要先講清楚才能談 drop 率。**

### ⚠️ 訂正二：**§3 的高嫌疑假說 ③(d)【推翻】**
`root.commit_drop.no_camp = **0 / 4**`。
「決策時 `can_settle_here` 真、commit 時 `camp_level` 已掉」**一次都沒發生**。
⇒ ★**它不是 camp 棄置率的同一顆病。**（implementer 也主動收回自己「兩條線併一顆」的推測。）

### ⚠️ 訂正三：**「手不聽腦第 4 型」在這條路上本輪只值 3 次，且機制不是預期的那個**
不是 combat 鎖／crisis 免疫窗（**兩者皆 0**），是 **persist hold 1 ＋ 同層搶班 2**
⇒ 若要修是 `persist_strength` / `priority` 層，**不是 arbiter 的鎖**。**量級太小，本輪不開藥。**

## §C 本票結案方式
- ★**原始 scope（找 commit／仲裁端的 7 個 drop）＝ 證偽，無病可修。**
- ★**但票不是白開**：它產出了**完整列舉的漏斗儀器 ＋ 殘差稽核 = 0**，
  **這是永久資產** —— 以後任何人問「紮根為什麼沒發生」都有現成分佈可讀。
- ★**真病灶已定位：工期端（`start 4 → complete 1`，流失 75%）**
  ⇒ **移交 `camp-construction-duration` 票**（該票 §4 早已寫死排序：
  **必須排在 `build-eta-single-source` 之後**，否則棄工原因會被 `persist_strength:95` 的 24× 高估蓋掉）。
- **`construct.stall` 需要 per-action 維度**（implementer 正確拒絕把跨所有工程的 12.4:1 總計套到紮根身上；
  `construct.start 23` vs `settlement.l0_to_l1_start 4` ⇒ 紮根只佔一小部分）⇒ **列為工期票的前置量測。**

### ✅ 升級為**驗收級**（measurer 獨立重跑，2026-08-25）
上表原標「開發回饋、非驗收」。**measurer 已獨立重跑、逐字相符**：
**殘差 ＝ 0（完整列舉）**、**`root.commit_drop.no_camp = 0` 確認推翻 spec §3 假說**、
`camp.built 26 / abandoned 24` 與 `camp-access` 那輪一致（**那份 75% 作廢**）。
`.measure.json`：`docs/process/verdicts/a1-root-funnel-acceptance.measure.json`；specimen 已直寄 QA。
⇒ ★**本票的結論（原 scope 證偽、真兇在工期端）現在有驗收級數字撐，不是開發自測。**

### 📌 記錄：本檔的前一版被掃進 `8278a9f3`（`Merge feat/camp-access`）
我在該 merge **進行中**跑了 `git add docs/` ⇒ 本檔與 `03b_measurer.md` 一併進了那個 merge commit。
**內容是已定案裁定、非半成品** ⇒ 依既有紀律 **不重寫 history、透明記錄即可**
（memory `feedback_concurrent_session_wip_sweep`）。
★**教訓**：**共用 main dir 時，`git add <目錄>` 之前要先確認沒有 merge 在進行**（`.git/MERGE_HEAD`）。

---

## §D ★★本票的產出物有了**第二個用途**（blueprint 2026-08-25）

本票結成「**原 scope 證偽、無病可修，但窮盡列舉與儀器留下當永久資產**」。

★**現在那份「窮盡列舉的 drop 點」成為【失敗記憶記錄側覆蓋率的母體】**：
> **A1 合規盤點的要求 ＝ 每個 drop 點「消滅 **or** 變成【有反饋的 typed 失敗事件】」**
> ⇒ ★**那些 typed 事件就是失敗記憶的【事件源】。**
> ⇒ **記錄側覆蓋率 ＝ 已接線 typed fail 站數 ／ 本票窮盡母體站數**（機械可數）。

★★**這就是為什麼「證偽的票」不能丟掉產出物** ——
**當時它是診斷；現在它是母體。**

