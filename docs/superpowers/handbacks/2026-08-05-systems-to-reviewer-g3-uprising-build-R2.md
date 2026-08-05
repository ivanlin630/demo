---
from: systems
to: reviewer
status: consumed
topic: "[R² merge-gate 審 g3.betrayal bond counter + uprising faction_id gate(feat/faction-cohesion 03f03ce4+00a40775、HOW spec R² 你上輪 CLEAN、現審 build diff)·★特別驗:diplomatic_ai counter 被 linter/concurrent revert 一次已 re-apply——systems 親驗確認在 committed code(diplomatic_ai:305 driver -= FactionAISystem.new()._faction_stay_benefit;uprising gate faction_ai:4536 if faction_id==-1: return)、但請你獨立再驗一次(concurrent revert scare、確保真 landed 非又被 revert)·實作:①g3 bond counter=driver−=_faction_stay_benefit(共享同一 helper 一套非兩套、跨 class FactionAISystem.new() 既有慣例=你上輪確認的架構)→忠/被救不叛、無情+利大+無恩義照叛(genuine opportunism 保留)②uprising cheap-win=_evaluate_uprising 開頭補 if faction_id==-1 return(鏡射 defect gate、清 independent 隊空觸發+cascade 副作用)·gate:g3_test 4/4(分化命門+opportunism+共享helper+零godview)+headless 0-new+constitution 74+determinism 28C07CF1 byte-identical(≠cohesion-alone=真改)·審點:①counter 真在 committed(concurrent revert 後)②§1 雙向(零刪 _execute_betrayal clear 未觸/禁常數 boost/無配額)③零 god-view(counter self memory+belief)④genuine opportunism(stay_benefit≈0 仍過 0.65)⑤uprising gate 鏡射 defect 正確+不改真 uprising⑥共享 helper 真統一·★注 re-measure 改床(反轉:g3 rep 床 0 fire、③下游解鎖驗在 measurer 建的 established-factions 床非 rep 床、g3 驗在 betrayal-fires 床、誠實標 g3=通用修)·R² CLEAN→measurer re-measure→QA→merge·地基 KEEP"
---

# R² merge-gate 審 g3.betrayal bond counter + uprising faction_id gate

HOW spec R² 你上輪 CLEAN → build 完（`feat/faction-cohesion` `03f03ce4`+`00a40775`）→ R² merge-gate 審 diff。

## ★特別驗（concurrent revert scare）
diplomatic_ai counter 被 linter/concurrent **revert 一次、已 re-apply**。systems 親驗確認在 committed code：
- `diplomatic_ai:305` `driver -= FactionAISystem.new()._faction_stay_benefit(state, self_team)` ✓
- `faction_ai:4536` `if team.faction_id == -1: return` ✓
- **請你獨立再驗一次**（確保真 landed 非又被 revert）。

## 實作
1. **g3 bond counter**：`driver -= _faction_stay_benefit`（共享同一 helper 一套非兩套、跨 class `FactionAISystem.new()` 既有慣例=你上輪確認架構）→ 忠/被救不叛、無情+利大+無恩義照叛（genuine opportunism 保留）。
2. **uprising cheap-win**：`_evaluate_uprising` 開頭補 `if faction_id==-1: return`（鏡射 defect gate、清 independent 隊空觸發+cascade 副作用）。

## gate 全綠
g3_test **4/4**（分化命門+opportunism+共享helper+零godview）+ headless **0-new** + constitution **74** + determinism **28C07CF1 byte-identical**（≠cohesion-alone=真改）。

## 審點
①counter 真在 committed（concurrent revert 後）②§1 雙向（零刪 `_execute_betrayal` clear 未觸/禁常數 boost/無配額）③零 god-view（counter self memory+belief）④genuine opportunism（stay_benefit≈0 仍過 0.65）⑤uprising gate 鏡射 defect 正確+不改真 uprising⑥共享 helper 真統一。

## ★注：re-measure 改床（反轉）
g3.betrayal 在 rep 床 0 fire（occupancy-map 定案）→ **③下游解鎖驗在 measurer 建的 established-factions 床（非 rep 床）**、g3 驗在 **betrayal-fires 床**、誠實標 **g3=通用修非 rep 床藥**。

R² CLEAN → measurer re-measure（established 床）→ QA → merge。地基 KEEP。
