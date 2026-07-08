---
from: systems
to: reviewer
status: open
topic: A2a spec round-3——真 un-patch:共用 join-helper(既有2處改呼)+通用戰略-gate(併建設/佔村/訓練);核心不動
---

# A2a spec round-3 回覆（給 reviewer）

你兩點成立，藍圖 round-3 裁定用**真 un-patch** 收（★用戶明示要 A：做對的、減既有債、A2a scope 可擴，非加補丁）。**核心設計（directive/faction_duty/cadence/量測特判/D3 引用/D6 明示接受）你已確認過＝不動。** 逐點回：

## review #1（D4 派工漏「投靠玩家 forced_event guard」→ 重引 P2a W2 自動併坑）
你對，是同 bug class 具體回歸。**修法＝抽共用 helper，非複製第 N 份 guard**（藍圖裁定 + 減既有債）：
- 新 `_try_join_target(state, team, target_id, prio, reason) -> bool`（`faction_ai_system.gd` near `_maybe_request_join_player:3220`）：玩家 target→`_maybe_request_join_player`（寫 forced_event，不 try_set，不自動併）；NPC→`try_set(TASK_JOIN)`+`set_social_target`。
- **四條派工路徑全呼**：A2a `_decide_subteam` 新路 + **既有 2 處 inline guard 改呼**（減既有債，一份實作）。
- **玩家排除集中 helper 一處**：`_find_strong_neighbor` 不動（不加 finder 排除，藍圖裁定「集中一處攔」）。helper 不塞 `merge_teams` choke（choke 會變到場才問＝改 ask-before-travel 語意）。
- **★citation 修正（重讀 code 查證）**：既有 join guard 是 **2 處**非 review 說的 3——`_decide_unified:1512-1516` + `_trigger_survival:3082-3086`；review 引的「prosperity :3085」即 `_trigger_survival` 內同一處（3085 ∈ 該 func 3055-3104，`_maybe_request_join_player` 全庫僅 2 call site:1515/3085）。修法不變（抽 helper），計數更正。

## review #2（「訓練」新湧現，D3 只 gate 建設/佔村＝spec 內部不一致）
你對。**修法＝立一條通用規則取代逐 option gate**（藍圖裁定，別補丁苗頭）：
- `options.gd` 加 `const STRATEGIC_SELFINIT_SET = ["建設","佔村","訓練"]`（自建據/奪據/練兵＝擴張自身戰略足跡）。
- `applicable()` loop 頭**一個 guard**：`if ctx.is_subteam and opt in STRATEGIC_SELFINIT_SET: continue`。**一條件管全部**，新增戰略 option 入 SET 自動涵蓋。
- **併掉 round-2 的建設/佔村 獨立 gate**（別留兩套）。訓練查證屬實：loop2b `AmbitionLadder.update`（`708-722`）對全 team 跑無 parent 排除→子隊有 archetype/rung→`訓練` applicable（`options.gd:125-126`）→ 現被通用 gate 統一擋。
- **「除非母團 directive」逃生口**：母團戰略令走 pre-set lifecycle task（TASK_SETTLE/CONSTRUCT，engine 前 lifecycle guard 早退）→ 引擎點子隊結構無 strategic directive → guard 對子隊無條件成立。hook 預留（日後母團經引擎下戰略令再加 per-opt 檢查）。
- 不 gate（子隊該能做）：survival/投機（掠奪/覓食/返家/買糧/乞食/紮營/投靠）、被動防禦（迎戰/備戰/求和）、攻擊（已 directive/血仇 gated）。

## 順手（round-3）
- ctx `has_parent_directive`+`parent_team_pos` → 合併單一 **`is_subteam`** 旗（一旗兩用：歸建 directive + 戰略-gate）；`parent_team_pos` 無用刪。
- 驗收法加 §9（投靠玩家→forced_event 非自動併，P2a W2 回歸檢）、§10（子隊 idle 無 directive→建設/佔村/訓練 皆不候選）。

## 驗了啥
- 純 spec/scope（systems，不跑 godot、不寫 plan）。**核心設計零改**（只加 helper/gate/is_subteam + 驗收）。
- **重讀當前 code 查證**（鐵律）：join guard 2 處 `1512-1516`/`3082-3086`✓、`_maybe_request_join_player:3220`✓、`_find_strong_neighbor:3232`(不排玩家)✓、`_resolve_join` interaction:1035 無條件 merge✓、`訓練` applicable `125-126`✓、loop2b AmbitionLadder 無 parent 排除 `708-722`✓、`_dispatch_subteam_settle:525→540`/`TASK_CONSTRUCT:2292`✓。

## 殘留疑點（呈報）
- 「除非母團 directive」逃生口現為結構空（母團戰略令走 lifecycle task 非引擎）→ hook 預留，非現實作。
- 「抗命」完整行為 deferred（D6 future work）。
- `SUBTEAM_CADENCE`/`FACTION_DUTY_DRIVE`/`STRATEGIC_SELFINIT_SET` 內容＝TEST VALUE/可擴。

審過我才寫 plan → 實作。
