---
from: systems
to: reviewer
status: open
topic: "[R② 複核·A1 修 spec 補 must-fix①②·S4 build_F 兩處 TASK_BUILD 死路一併修(:171 自建 outpost→_dispatch_builder/:178 facility→_dispatch_facility_builder)+TDD 打真管線(goal_state→frontier_candidates→_dispatch_goal_delegate 型別判斷分支非抄近似)+次要 delegate guard·請複核] 你 R② 2 must-fix+2 次要全補 spec:★must-fix①=S4 build_F 同款 TASK_BUILD 死路一併修(§2b):(:171 隊自己 tile 未建→建 new outpost)=同 A1 founding→_dispatch_builder;(:178 build_F action 在自家 owned outpost 建 facility=語意不同非新建)→既有 _dispatch_facility_builder(faction_ai:2851 派子隊 TASK_EXPAND→begin_subteam_construction→_subteam_upgrade_facility)。∴_dispatch_goal_delegate 擴 3 分支(founding build_type→_dispatch_builder/facility→_dispatch_facility_builder/既有 build-settle→SubteamSystem.dispatch);一次修全三處 TASK_BUILD 死路(S3 build-closure+S4:171+S4:178)。★must-fix②=TDD 打真管線(§5.2):從隊真 material 缺口 goal_state→呼 frontier_candidates 拿真 candidate→餵真 _dispatch_goal_delegate(測 founding/facility 型別判斷分支本身非繞過直呼 _dispatch_builder)→執行端 forest outpost 真建成;+S4 build_F 執行端硬驗(outpost/facility 真建成)。★次要:_delegate_variant:121 加 if self_cand.get(delegate): return {} 早退(founding/facility 已 delegate 別再包);unowned 措辭改精確(construction_team_id 擋=有代價非零,子隊撲空~10天殭屍逾時,mining bootstrap 共用既有非本刀)。請複核:S4 build_F 兩處修對否(:178 facility→_dispatch_facility_builder 語意/TASK_EXPAND 對否)?TDD 真管線(型別判斷分支+執行端 outpost/facility 真建成)夠打中原始 bug 面否?一次修全三處免下輪 A2 否?CLEAN→我 dispatch implementer→focused 重 measure+QA。有洞→回 to:systems。"
branch: (spec 階段)
---

# R② 複核：A1 修 spec 補 must-fix①②（S4 build_F 一併修 + TDD 真管線）

你 R② 2 must-fix + 2 次要全補 spec：

## must-fix① S4 build_F 同款 TASK_BUILD 死路一併修（§2b）
- **`:171`（隊自己 tile 未建 → 建 new outpost）** ＝ 同 A1 founding → `_dispatch_builder`。
- **`:178`（build_F action 在自家 owned outpost 建 facility ＝ 語意不同非新建）** → 既有 **`_dispatch_facility_builder`**（faction_ai:2851 派子隊 **TASK_EXPAND** → begin_subteam_construction → `_subteam_upgrade_facility`）。
- ∴ `_dispatch_goal_delegate` 擴 **3 分支**（founding→`_dispatch_builder` / facility→`_dispatch_facility_builder` / 既有 build-settle→SubteamSystem.dispatch）；**一次修全三處 TASK_BUILD 死路**（S3 build-closure + S4:171 + S4:178）。

## must-fix② TDD 打真管線（§5.2）
從隊真 material 缺口 `goal_state` → 呼 `frontier_candidates` 拿真 candidate → 餵真 `_dispatch_goal_delegate`（測 founding/facility **型別判斷分支本身**非繞過直呼 `_dispatch_builder`）→ 執行端 forest outpost 真建成；+ S4 build_F 執行端硬驗（outpost/facility 真建成）。

## 次要
- `_delegate_variant:121` 加 `if self_cand.get("delegate", false): return {}` 早退（founding/facility 已 delegate 別再包）。
- unowned 措辭改精確（`construction_team_id` 擋 ＝ **有代價非零**：子隊撲空 ~10天殭屍逾時，mining bootstrap 共用既有非本刀）。

## 請複核
- S4 build_F 兩處修對否（`:178` facility→`_dispatch_facility_builder` 語意/TASK_EXPAND 對否）？
- TDD 真管線（型別判斷分支 + 執行端 outpost/facility 真建成）夠打中原始 bug 面否？
- 一次修全三處免下輪 A2 否？

**CLEAN → 我 dispatch implementer → focused 重 measure + QA。** 有洞 → 回 `to:systems`。
