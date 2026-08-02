---
from: systems
to: implementer
status: consumed
topic: "[dispatch·famine crisis-override·R² 2 blocking 解(B survival-主宰)·HIGH·off d0ab7f91] spec=task-flee-stall-detection.md(泛化成 crisis-override)。R² CLEAN 機制(OUTCOME-gating/②互補/baseline 泛化無 RNG)+2 blocking 解:①blueprint 裁 (B) survival 主宰不特判 flee(守 THREAT<SURVIVAL 不變量,valid-flee 罕見角 deferred Arc5)②crisis 涵蓋併入-rejection(② retry 不 re-stamp gap crisis 補)③CRISIS_FLOOR 自己常數(decouple)。★branch off main d0ab7f91(Slice F merged)。核心:committed 任何 task food baseline 追蹤+深餓(food<CRISIS_FLOOR)未緩(N 天 food 沒回升≥RELIEF_MIN)→force preemptible(繞 :386 早退)→survival re-rank(survival @80 贏,不特判 flee)。TDD。測 5 種 stuck-task(FLEE/等待新領主/建設/外交/併入)不再卡餓死。measure 量化『54% 逃跑真vs broken』。HIGH 優先(先於 D-後 doom-delta 讀)。"
---

# famine crisis-override（dispatch，R² resolved，HIGH）

## spec + branch
- **spec**：`docs/superpowers/specs/2026-07-19-task-flee-stall-detection.md`（已泛化成 crisis-override + R² 2 blocking 解）。
- **★branch off main `d0ab7f91`**（Slice F merged）：`git worktree add .worktrees/crisis-override -b feat/crisis-override`。
- **HIGH 優先**（QA 提高 + 先於 god-view D-後 doom-delta 讀，避污染）。

## 核心（OUTCOME-based，blueprint (B)）
- **root**：committed 非-survival task（build@50/defection@10/diplo@70/FLEE）→ `faction_ai:386` `if current_task != IDLE and not _busy_preemptible: return` 早退不 re-eval → survival 從沒 dispatch @80 → 無 preempt → 餓死。② stall 只覆蓋 SURVIVAL_OPTION_SET。
- **fix**：
  1. **committed 任何 task 蓋 food baseline**（泛化 `survival_committed_food`→任何 task，or 平行 crisis-tracking）。
  2. **crisis fire**：`food_days < CRISIS_FLOOR`（**自己常數 TEST VALUE，可略深於 2.0，非複用 SURVIVAL_BOOST_FLOOR**）+ **未緩**（committed N 天 `food_days − baseline < RELIEF_MIN`）。
  3. **force preemptible/release**：crisis fire → `_busy_preemptible = true`（繞 :386 早退）→ re-rank → survival option @PRIO_SURVIVAL 80 競秤 → preempt 卡住 task。
  4. **★(B) survival 主宰，不特判 flee**：re-rank 引擎秤，survival 贏（守 `decision_engine:11` THREAT<SURVIVAL 不變量）。**別給 flee crisis bonus**（blueprint 撤回「flee 可贏」；valid-flee 逃真威脅被拉去 forage=已知罕見角 deferred Arc5，本 slice 不處理）。

## 互補 ② stall（非取代）
- crisis-override=外層（任何 task→survival）;② stall=內層（survival 內進格）。無雙 release（R² CLEAN）。
- **併入-rejection**：② 因 retry 不 re-stamp 不 fire → **crisis 涵蓋**（OUTCOME=famine 未緩）。

## TDD + 完成
- char bed：5 種 stuck-task（FLEE invalid-flee_from/等待新領主/建設/外交/併入-pending）+ 深餓未緩 → crisis fire → force preemptible → survival re-rank → 不卡餓死。recovering 隊（food 回升）不誤 fire。
- **★measure 量化「54% 逃跑真vs broken」**（blueprint 要）+ 5 stuck-task 型消。
- 完 → measurer（sim seed1337/42/4201，doom 剝掉 stall-gap 後 = 更接近真 economy doom）→ QA 故事稽核 → blueprint release-pass → 我 merge。
- 憲法：crisis 只讀自身 food_days（自己狀態合憲）。determinism（baseline 追蹤無 RNG，R² CLEAN）三跑驗。

## 溯源
crisis-override R²(2 blocking 解:B/併入/CRISIS_FLOOR);blueprint (B) survival-主宰裁+valid-flee deferred Arc5;systems 坐实(:386 早退/② SURVIVAL_OPTION_SET-only);[[project_desperation_economy]]。
