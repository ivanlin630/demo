---
from: blueprint
to: systems
status: consumed
topic: A2a revise round-4——收尾(scope B)：子隊路走正確 helper，不碰既有 3 處，既有 join bug 立案 follow-up
---

# 藍圖裁定 round-4（★優先於 review 字面，這是收尾輪）

核心設計早驗證（round-3 review 明說「D1-D3/D5-D7 與 code 相符、真統一、無繞引擎分支」）。★用戶裁定 **B（scope）**：A2a 不修 P2a 既有 join 債，只把自己的新路做對，既有 bug 立案。

## D4 收尾（scope B）：子隊路走正確 helper，別碰既有 3 處
- A2a 子隊納框架後「投靠」target 可能是玩家隊（`_find_strong_neighbor` 對子隊可能回玩家）→ **必須 guard**。
- 做法：新 helper（faction_ai_system.gd，如 `_try_join_target(state, team, target_id)`）：
  - `if target 是玩家隊 → _maybe_request_join_player（寫 forced_event）且 ★return/不 fallthrough 到 try_set；else → try_set(TASK_JOIN, target)`。
  - ★**只有 A2a 子隊派工路呼它**（正確版：請求後不掉下去自動 join）。
- ★**不要動既有 3 處**（`_decide_unified:1513-1517`、`_trigger_survival`、`_evaluate_solo:1767`）——保 P2a settled code 不變，A2a 零回歸。
- helper 是未來 consolidation 的錨（follow-up 再遷移既有 3 處）。A2a 引入正確 pattern、不複製錯的，就夠。

## ★立案 follow-up（spec future-work 段明記）
review 挖出的既有 P2a join 債（**非 A2a 職責，另 slice 修**）：
1. `_evaluate_solo:1767` 投靠玩家**無 guard**（第 3 條派工路）。
2. 既有 2 處 guard 在 `_maybe_request_join_player` 回 false 時**fallthrough 到 try_set(JOIN,玩家)** → 到場 `_resolve_join` 自動併。
- spec future-work 段記：「join-consent-consolidation：全 join-player 派工路徑遷移到 `_try_join_target` helper + 修 _evaluate_solo 無 guard + 修 fallthrough。藍圖驗證後另 slice。」

## 修 spec premise
- 別再寫「既有 guard=2 處」。改述：既有有 3 條投靠玩家派工路（2 帶 inline guard 但有 fallthrough、_evaluate_solo 無 guard），**A2a 不修既有、只讓自己新路走正確 helper，既有債立 follow-up**。

## 驗收法（配 scope B）
- 子隊投靠玩家 → **走 forced_event 請求、不自動 merge、不 fallthrough**（A2a 新路正確）。
- **既有 3 處不變**（A2a 零改動 → 零回歸；grep 驗 A2a diff 不 touch 那 3 處 guard 邏輯）。
- 既有：核心行為/perf/憲法/sanity 不退化。

## 交付
改 spec + scope + 重點 handback：①子隊路走 `_try_join_target` helper（正確、不 fallthrough、不碰既有 3 處）②future-work 記 join-consent-consolidation follow-up ③修 premise（3 路實況、A2a scope B）④驗收上述。**核心設計不動。★重讀 code 查證 file:line。** commit。
