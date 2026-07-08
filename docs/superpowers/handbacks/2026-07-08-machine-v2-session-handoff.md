---
from: blueprint
to: blueprint
status: open
topic: machine v2 大強化 + A2a 打磨(實作正確但 perf爆炸,②reject,留分支)——壓縮後從 A2a perf-fix pass 續
---

# 交接：machine v2 強化 + A2a（2026-07-08 晚）

## ★立刻要做：A2a perf-fix pass
**A2a 實作正確但 perf 爆炸，② reject 收掉，留在 `feat/machine-A2a` 分支（未 merge、未丟）。**
- **正確處**：integrity PASS、13 assertions 綠、憲法/sanity 綠、spec 完整實作（子隊決策納統一 DecisionEngine、舊 hand-argmax 刪、量測 guard、strategic-gate、join helper）。
- **blocker**：HOB bed + team_trace **都 360s timeout**，sim 核心 O(?) 爆炸（非 probe 噪音）。
- **cause 已縮**（★別再猜逐 tick）：**非 gather**（只加 `is_subteam` bool O(1)）、**非子隊決策頻率**（`_decide_subteam` 有 cadence 閘 `faction_ai_system.gd:1676` `if current_tick < subteam_eval_next_tick: return`，1日/次）→ **在 faction_ai_system.gd 那 120 行改動**（疑：子隊現流過更重的 per-tick 主迴圈 loop3 _evaluate_survival/_tick_conquest_scout/_refresh_attack_pursuit/_evaluate_threat，或新 O(N²)）。
- **下步**：正經 **profile**（`scripts/debug/lod_perf_bed.gd` / `SimRunner.phase_timing`+`_fai_pht` 各相位計時；比 main vs `feat/machine-A2a`）→ pin 出爆的相位/行 → fix。**我 worktree godot 直接跑一直失敗（import lock?），要弄對 profiling 法。**
- **修完怎麼收**：fire `--resume redo`（回 implementer 重跑下游）或新起。實作分支在，別重跑 5 輪 revise。
- 教訓：我一度「逐 tick」猜錯被用戶戳（gate 在 1676）——★守 measure-first、別憑 review 字面猜。

## machine v2 本 session 大強化（全 committed）
- **★pause-poll 工作流（用戶要，已驗）**：worker interrupt **暫停不退**，寫 `runs/<slice>.pause` + poll `runs/<slice>.decision`；**藍圖 Write decision 檔（approve/redo/revise/reject）即續、免 re-fire**（classifier 不擋 Write）。逾時 2h 退。★`!` 只用在初次啟動；checkpoint 藍圖寫檔驅動。
- **is_api_error 修（關鍵）**：429/session-limit 在 result/raw envelope（`"api_error_status":429`/"session limit"）非 stderr → 原漏偵測 → pipeline 空跑到 ②垃圾。改掃 raw 結構標記 + result/error。→ **死在某節點=freeze 在那、resume 從那重跑（非從頭）**。
- **② qa_review 三路**：approve→merge / redo→implementer(下游掛救,如限額/godot) / revise→systems_spec(QA揭spec缺陷) / reject→停。
- **revise 迴圈 + feature 級 01 session**：halt/①/② resume `revise`→systems_spec，續原 01 session（`systems_session`，記得自己 spec）+ 注入藍圖方向 handback（`blueprint-to-systems-<slice>-revise`，優先 review 字面）。MAX_REVISE=5。
- **其他修**：judge effect-fail 重試1次、--cancel 可靠殺 worker、fire 防 double-fire、PYTHONUNBUFFERED、--status 文字路線圖（loop 後 stale 待修）、run_local 處理 __interrupt__、寫節點 guard（scope_dir 必真 worktree，防 commit 洩漏 main）。

## 其他 follow-up（memory `project_future_improvements`）
- **join-consent-consolidation**：投靠玩家 3 路（`_evaluate_solo:1767` 無 guard + 既有 2 處 fallthrough auto-merge）——A2a scope-B 沒修，立案另 slice。
- **子隊抗命完整行為**：A2a 移了 mid-mission 投機叛逃（藍圖明示接受），完整抗命延後。
- **--status 路線圖 loop-stale**：redo/revise 後 log 累積跨輪 ✓ → route-map 顯示亂，按輪次分段修。

## 全 durable
記憶 `project_orchestrator_machine`（單寫者藍圖，接續錨已更新）+ `project_future_improvements`；設計 `docs/process/08_machine_workflow_v2.md`。壓縮後讀這份 + memory 即接回。**A2a 實作在 feat/machine-A2a 分支。**
