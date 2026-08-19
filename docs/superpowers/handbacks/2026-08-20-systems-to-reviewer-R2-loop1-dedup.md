---
from: systems
to: reviewer
status: open
topic: "[R² loop1 faction 決策雙跑去重(tick-stamp、行為影響道)HOW審·spec=2026-08-20-loop1-faction-dedup-HOW.md·blueprint 已裁 GO+定性『接管語意上的事故非設計』(沒人設計每 tick 想兩次;LOD 分流存在而 loop1 無視=管線意外、同食物 need 雙計家族)、意圖語意=每 faction 每 tick 決策一次、修=歸正非新設計·R①免(前提=結構事實我 code-read 坐實:faction_ai_system.gd:712 _evaluate_all_body 參數 _team_ids 底線前綴刻意未用+迴圈 for fid in state.factions 全量;sim_runner.gd:152 lod:LOD_BOTH shape:teams=near/far 各呼一次)·★★blueprint 點名必查(他挑明給你):【有無任何行為依賴雙跑】——near/far 兩 pass 之間世界狀態已被第一 pass 改過(goals/tasks 已指派)、第二 pass 是在【更新後的 context】重評;first-pass-wins 去重=移除這個『二次重評』→(a)有沒有既有行為/機制默默依賴那次二次重評(例如第一 pass 指派後、第二 pass 才看到新 state 而改派/補派)?(b)會不會改變 faction 在【哪個 context】下決策(near-context vs far-context 差異)?(c)interval-gated 的 infra/diplo 現在同 tick fire 兩次、去重後剩一次——有沒有機制依賴那第二次(例如第一次資源不足失敗、第二次成功)?·★其他審點:①tick-stamp 放 instance 欄(比照既有 _last_site_sig/_last_dispatch_fail pattern、sim_runner 持穩定 instance)是否安全、死團清理要不要(我傾向用 current_tick 比對天然失效=無需清、避免新 leak 面)②determinism:iteration 序不變、無 RNG、dict 只做 tick 比對=fp 變只因行為變(intended)非因不確定性③fidelity 不降=每 faction 仍每 tick 決策一次(非降頻)、憲章③守·gate 含 fp intended-change+★全故事審(blueprint 硬要求、世界顯著變樣就回退重議)+perf 實收·時序:R² CLEAN 後【等 measurer ③ 量到雙跑實際份額】再 dispatch(先量後改、blueprint 裁)·地基KEEP"
---
# R² loop1 faction 決策雙跑去重（tick-stamp、行為影響道）
spec=`docs/superpowers/specs/2026-08-20-loop1-faction-dedup-HOW.md`。blueprint 已裁 GO + 定性「**接管語意上的事故非設計**」、意圖語意=**每 faction 每 tick 決策一次**、修=**歸正非新設計**。R① 免（前提=結構事實、我 code-read 坐實）。
## ★★blueprint 點名必查（他挑明給你）：**有無任何行為依賴雙跑**
near/far 兩 pass 之間**世界狀態已被第一 pass 改過**（goals/tasks 已指派）、第二 pass 是在**更新後的 context** 重評；first-pass-wins 去重=**移除這次「二次重評」**：
- (a) 有沒有既有行為/機制**默默依賴那次二次重評**（例如第一 pass 指派後、第二 pass 才看到新 state 而改派/補派）？
- (b) 會不會改變 faction 在**哪個 context** 下決策（near-context vs far-context 差異）？
- (c) interval-gated 的 **infra/diplo 現在同 tick fire 兩次**、去重後剩一次——有沒有機制**依賴那第二次**（例如第一次資源不足失敗、第二次成功）？
## ★其他審點
①tick-stamp 放 instance 欄（比照既有 `_last_site_sig`/`_last_dispatch_fail`、sim_runner 持穩定 instance）安全嗎？死團清理要不要（我傾向 `current_tick` 比對**天然失效=無需清**、避免新 leak 面）②determinism：iteration 序不變、無 RNG、dict 只做 tick 比對 → **fp 變只因行為變（intended）非因不確定性** ③fidelity 不降=每 faction 仍**每 tick 決策一次**（非降頻）、憲章③守。
gate 含 fp intended-change + **★全故事審**（blueprint 硬要求、世界顯著變樣就回退重議）+ perf 實收。
**時序**：R² CLEAN 後**等 measurer ③ 量到雙跑實際份額**再 dispatch（**先量後改**、blueprint 裁）。地基 KEEP。
