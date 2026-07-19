---
from: systems
to: implementer
status: open
topic: "[REDIRECT·subteam-idle v3 結構修·R² CLEAN·extend 036fc42c] hold 解除。v3 R² CLEAN(監看=edge-trigger 收斂/orphan 沿用 discipline_fail proven 路/位置並存不誤傷)。同 branch 036fc42c extend:①_check_discipline 後、position-branch 前加連續母團監看——`if sub.current_task in SURVIVAL_TASKS: parent=get(parent_team_id); if parent==null: _orphan_forager(release+detach+remove TAG_SUBTEAM,沿用 discipline_fail:52-55 路); return; if _parent_needs_food(state,parent): merge_queue.append; return`②v2 sated-merge position-branch 保留。TDD 補:①旅途中母團垂危→forager 掉頭交糧(非駐點也召回)②parent 死→orphan 轉獨立不囤糧③監看不誤傷 ESCORT/BUILD。→to:measurer,★硬驗(別當 non-blocker):(a)recall 收斂—旅途 recall 後 _decide re-pick forage 有無慢震盪(reviewer flag)(b)seed42 famine→0 (c)seed1337 v2 惡化(6→10)回落 (d)orphan 消 (e)手不聽腦維持 0 (f)perf 每tick parent lookup 無 spike。gate 值 tune 排結構後。★off LOCAL,pre-push hook 兩閘。"
---

# REDIRECT：subteam-idle v3 結構修（extend 036fc42c）

hold 解除。v3 R² **CLEAN**（監看=edge-trigger fire→release→IDLE→survival-gate 停 fire 收斂，非 level-spam；orphan 沿用 discipline_fail 雙向清 proven 路；監看位置/兩路並存不誤傷）。

## extend 036fc42c（v3）
`faction_ai:_evaluate_subteam`，`_check_discipline` 後、position-branch 前加：
```gdscript
if _check_discipline(state, sub): return
# ★v3 連續母團監看（foraging subteam，不等駐點——補 v2 只駐點查的結構洞）
if sub.current_task in SURVIVAL_TASKS:
    var parent: TeamData = state.teams.get(sub.parent_team_id)
    if parent == null:
        _orphan_forager(state, sub)   # detach_subteam + remove_tag(TAG_SUBTEAM) + release（沿用 discipline_fail:52-55）
        return
    if _parent_needs_food(state, parent):
        merge_queue.append(sub.team_id)   # 母團垂危 → 掉頭歸建交糧
        return
# （以下 position-branch：v2 sated-gated merge 保留）
```
`_orphan_forager`（新 helper，沿用 discipline_fail 現成路）：
```gdscript
func _orphan_forager(state, sub) -> void:
    state.detach_subteam(sub); state.remove_tag(sub, TeamData.TAG_SUBTEAM, "orphan_forager"); TaskArbiter.release(sub)
    print("[SubAI] Team%d 母團缺席 → orphan 轉獨立" % sub.team_id)
```

## TDD 補（v2 之外）
①旅途中（move_target≠-1）母團垂危 → forager 掉頭交糧（非只駐點召回）②parent 死/缺席 → orphan 轉獨立不囤糧 ③監看只對 SURVIVAL_TASKS，ESCORT/BUILD/CONSTRUCT/SETTLE 不誤傷。

## 驗收 → to:measurer（★硬驗，別當 non-blocker）
- **(a) recall 收斂**（reviewer flag）：旅途 recall 後 `_decide` re-pick forage 有無**慢震盪**（掉頭↔re-forage）。**明列硬驗**（上輪 terminal-sticky 教訓：self-flag 疑點別降級 non-blocker）。
- **(b) seed42 famine→0**（v2 目標）。**(c) seed1337 v2 惡化 6→10 回落**（v3 目標）。**(d) orphan 消**（囤 200-2000 food-days 現象在 orphan 路也消）。**(e) 手不聽腦維持 0**。**(f) perf**：每 tick foraging subteam parent food_days lookup 無 spike（reviewer perf note；有 spike→cadence-gate）。
- gate PASS / headless 0 new / determinism 2 跑 byte-identical。
- **gate 值（SATED/PARENT_LOW）tune 排結構修落地後**（現調無意義，blueprint 裁）。

## base
extend 036fc42c（禁 origin，落後）。pre-push hook 已裝。

## 完成判定 = systems + reviewer/QA。做完 → to:measurer。
