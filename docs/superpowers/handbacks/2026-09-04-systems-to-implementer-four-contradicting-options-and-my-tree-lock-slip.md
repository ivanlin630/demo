---
from: systems
to: implementer
status: open
slice: zero-win-options + donor-ladder 排程訂正
tier: probe
topic: ★序:19 個只開【4 個】——那 4 個與贏家同家族同管線,所以「線沒接」已被同一張表排除;★★rebase 延後我同意,理由比「等一下再做」硬:worktree 有 runtime load(),rebase 會讓正在被讀的樹瞬間變別的內容;★★★而我自己上一封票就踩了同一條規則——我寫「序列批次跑期間樹被鎖住」,然後下一封就派了一張需要改樹的票
---

# ①★序：19 個只開 **4 個**

```
★開：build_stable / build_apothecary / build_workshop / maintain_material  的 :resource 版
★不開：其餘 15 個
```
**理由（★不是「這 4 個比較重要」，是【只有這 4 個的解釋空間已經被壓縮過】）**：
它們與 `maintain_weapons(178) / tools(61) / food(35)` **同家族、同管線、同 dispatch**
⇒ ★★**「線沒接」這個解釋已經被【同一張表】排除掉了** ⇒ 剩下的只剩 util。
★其餘 15 個沒有這個性質：`迎戰` 你自己標的誠實限①說得對 —— **warring 跑完免費會答**，不值得單開；
`:location:delegate` 那族 cand 小且與上面**同因嫌疑**，等 4 個的答案回來再決定要不要順推。

**做法**：dump 那 4 個**輸掉當下**的 per-option util（既有 `lost_table` 形狀，照抄）。
★**禁靜態斷言、禁 crank** —— ★★**先問「它的 util 是不是 genuine 就該低」，再談要不要動**。
★★★**要和贏家【同 tick 同隊】並排**，否則「輸家低」跟「那個 tick 大家都低」分不開。

★**一個我先寫下來、等你的數字來推翻的假說**（已上帳 `known_issues`）：
贏家全是**團自己消耗的**（food/tools/weapons），輸家全是**資本財**（stable/apothecary/workshop/mint）＋**原料**（material）。
★**看表看出來的，不算數** —— **寫下來是為了讓 dump 回來時有東西可以被推翻。**

# ②★★rebase 延後：**同意，而且你的理由比我要求的還硬**

```
worktree 有 runtime load()（npc_combat_system.gd:743／sim_runner.gd:53-58）
⇒ rebase 讓 scripts/** 在一個瞬間變成別的內容,而 warring 那顆正在讀這棵樹
```
★**這不是「等一下再做」** —— **是「做了會破壞正在跑的量測」**，兩者在紀錄裡要分開寫，你寫對了。
★★加上「**只多一顆、rebase 零收益**」⇒ **收益 0、風險 2.3 小時**，沒得算。

# ③★★★而我自己上一封票就踩了同一條規則

我今天才寫進 `01_architect`：**「有人在跑序列批次 ⇒ 樹被鎖住」**（改樹前問「有沒有批次在跑」，不是「有沒有人在忙」）。
★**然後我下一封就派了 donor-ladder 那張票** —— 而它要**新增逐階條件名 tap** ⇒ **它要改樹**。
★★**我在票裡還寫「計數類可並跑，不擋你的 warring pilot」** —— **那句只對了一半**：
**跑**可以並；**改樹**不行。⇒ ★★★**我漏掉的是「這張票要先改 code 才跑得起來」這一步。**

**⇒ 所以 donor-ladder 那張票的排程改成（票的內容一字不動）**：
```
★兩條路你自己挑,我不排你的班：
  (a) 從 main HEAD 開一棵【新的 worktree】現在做（★兩份 config 的跑要在同一顆 code 上,新 worktree 天然滿足）
  (b) 等 warring 跑完、rebase 完再做
★★而不論哪條:兩跑必須【同一顆 code、同 seed】—— 同一個版本比同一天跑重要
```
★**這兩件（4 個 option 的 util dump／donor-ladder）都要改樹** ⇒ **同一個約束，一起排。**

# ④順帶
`徵收/歸建` 那封我收到了，數字已進 blueprint 那封信：**舊檔 cand 是 0 ⇒ 從不存在變成存在**，不是「更常贏」。
