---
from: blueprint
to: systems
status: consumed
topic: A2a revise round-3——真 un-patch：共用 join-helper + 通用戰略-gate（取代逐點複製/逐 option gate）
---

# 藍圖裁定 round-3（★優先於 review 字面）

核心設計早驗證過（D3/D6 收尾到位）。round-3 = 把 review 抓的兩點用**真 un-patch** 收——**不是加補丁**。★用戶明示要 A（做對的 un-patch，減既有債，A2a scope 可擴）。

## D4：抽共用 helper，別複製第 4 份 guard
- 現況「投靠玩家→forced_event 請求、不自動併」的 guard **複製在 3 處派工點**（`_decide_unified:1511-1516`、`_trigger_survival`、prosperity `:3085`）＝既有 seam。
- ★**別再複製第 4 份**。抽一個共用 helper（faction_ai_system.gd，名如 `_try_join_target(state, team, target_id)`）：
  - 內含：`if target 是玩家隊 → _maybe_request_join_player(寫 forced_event，不 try_set)；else → try_set(TASK_JOIN,...)`。
  - **四條派工路徑（既有 3 + A2a 子隊新路）全呼它。**
  - ★**順手把既有 3 處 inline guard 改成呼 helper**（減既有債，一份實作）。
- 為何 helper 非塞進 merge_teams choke point：choke 會變「到場才問」，改了 ask-before-travel 語意；helper 保留現行語意。
- 保留玩家排除：`_find_strong_neighbor` 若對子隊也可能回玩家隊，靠 helper 攔（不靠 finder 排除，集中一處）。

## 通用戰略-gate：一條規則取代逐 option gate
- review 抓「訓練」和先前「建設/佔村」都是「子隊憑空多出自主戰略行為」。**別逐 option 加 gate（補丁苗頭）。**
- ★立**一條通用規則**：子隊（`parent_team_id != -1`）**不自主發起戰略級 option**，除非有母團 directive。
  - `STRATEGIC_SELFINIT_SET`（const，options.gd 或 decision_terms）= `{建設, 佔村, 訓練}`（自建據點/奪據點/練兵＝擴張自身戰略足跡的活動，屬 leader/faction 決定）。
  - applicable() **一個 guard**：`if ctx.is_subteam and opt in STRATEGIC_SELFINIT_SET and not <該 opt 有母團 directive> → 不候選`。一條件管全部，新增戰略 option 自動涵蓋。
  - **把 D3 的建設/佔村 gate 併進這條通用規則**（別留獨立 D3 gate + 訓練另一條）。
- 不 gate 的（子隊該能做，別誤攔）：survival/投機（掠奪/覓食/返家/買糧/乞食/紮營/投靠）、被動防禦（迎戰/備戰/求和）、攻擊（已 directive/血仇 gated）。ctx 需要 `is_subteam` 旗（parent_team_id!=-1）。

## 驗收法加（配 un-patch）
- 子隊投靠玩家 → **走 forced_event 請求、非自動 merge**（回歸檢：P2a W2 坑不復現）。
- 子隊 idle 無 directive → **建設/佔村/訓練 皆不候選**（通用 gate 生效）；有母團 directive → 對應 option 可候選。
- 既有：核心行為/perf tick-time/憲法/sanity 不退化。

## 交付
改 spec + scope + 重點 handback：①D4 共用 helper（+既有 3 處改呼）②通用戰略-gate（併 D3、涵蓋訓練）③驗收加上兩項。**核心設計不動。★重讀當前 code 查證所有 file:line（尤其既有 3 處 guard 位置、_resolve_join、options applicable）。** commit。
