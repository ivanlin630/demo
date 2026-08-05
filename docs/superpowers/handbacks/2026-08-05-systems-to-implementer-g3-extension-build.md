---
from: systems
to: implementer
status: open
topic: "[dispatch build g3.betrayal 延伸(R² CLEAN、續 feat/faction-cohesion 同 arc)·spec docs/superpowers/specs/2026-08-05-faction-cohesion-g3-extension-HOW.md·grounding=cohesion ③FAILED 因 rep 床 collapse 真驅動是 g3.betrayal(單邊秤:driver=機會+不忠、零 bond counter、漏修)·設計:①★bond counter=diplomatic_ai_system.gd:299 driver 計算後加 driver−=FactionAISystem.new()._faction_stay_benefit(state, self_team)——★reviewer 親驗:_faction_stay_benefit 已是 FactionAISystem 無 self-state 純函式(只讀 state/team 參數)、diplomatic_ai 呼 FactionAISystem.new()._faction_stay_benefit(...) 是 codebase 既有跨 class 慣例(數十 precedent 如 _merchant_trade_target)、不需改 static 即達『一套非兩套』統一(避 reviewer 上輪抓的兩精度病)②結果:忠的/被救的 stay_benefit 高→driver<0.65 不叛、無情+利大+無恩義 stay_benefit≈0→仍過門檻照叛(genuine opportunism 保留)·0.65 semi-cliff 連續化 defer(避 scope creep、非本延)·守 §1 雙向(零刪:_execute_betrayal clear_team_faction 不碰 reviewer 證未觸/禁忠誠常數 boost:counter=已驗 genuine helper 減項/無配額)+零 god-view(counter self benefactor memory+belief、driver ally-est 已 belief-snapshot)+determinism(純算術插 driver 上游、betrayal soft-band randf 不動)·TDD:分化命門(被救/忠 member 盟弱不叛 vs 無情無恩義 member 盟弱叛)/genuine opportunism 保留(stay_benefit≈0 仍過 0.65)/共享 helper(faction_ai+diplomatic_ai 呼同一)/零 god-view 硬驗/determinism·完成 handback to:systems R²+measurer re-measure(★③下游解鎖真驗 rep 床不秒崩+4 出口佔比 map、判 cohesion+g3 是否真解 faction-fragility)·地基 KEEP"
---

# dispatch build g3.betrayal 延伸（R² CLEAN、續 feat/faction-cohesion）

reviewer R² CLEAN（Seam 全親驗坐實 + 共享 helper 架構零風險確認）。續 `feat/faction-cohesion`（同 arc）。spec：`2026-08-05-faction-cohesion-g3-extension-HOW.md`。

## 設計
1. **★bond counter**：`diplomatic_ai_system.gd:299` driver 計算後加 `driver -= FactionAISystem.new()._faction_stay_benefit(state, self_team)`。
   - **★reviewer 親驗**：`_faction_stay_benefit` 已是 FactionAISystem **無 self-state 純函式**（只讀 state/team 參數）；`diplomatic_ai` 呼 `FactionAISystem.new()._faction_stay_benefit(...)` 是 **codebase 既有跨 class 慣例**（數十 precedent 如 `_merchant_trade_target`）；**不需改 static 即達「一套非兩套」統一**（避 reviewer 上輪抓的兩精度病）。
2. **結果**：忠的/被救的（stay_benefit 高）→ driver<0.65 **不叛**；無情+利大+無恩義（stay_benefit≈0）→ 仍過門檻 **照叛**（genuine opportunism 保留）。
3. **0.65 semi-cliff 連續化 defer**（避 scope creep、非本延）。

## 守
- **§1 雙向**：零刪（`_execute_betrayal` clear_team_faction 不碰、reviewer 證未觸）+ 禁忠誠常數 boost（counter=已驗 genuine helper 減項）+ 無配額。
- 零 god-view（counter self benefactor memory+belief、driver ally-est 已 belief-snapshot）。
- determinism byte-identical（純算術插 driver 上游、betrayal soft-band randf 不動）+ constitution 74。

## TDD
①分化命門（被救/忠 member 盟弱**不叛** vs 無情+無恩義 member 盟弱**叛**、RED counter neuter→皆叛）②genuine opportunism 保留（stay_benefit≈0 仍過 0.65 叛）③共享 helper（faction_ai+diplomatic_ai 呼同一、RED 改 helper 兩端同步變）④零 god-view 硬驗⑤determinism。

## 序
完成 → handback `to:systems`（R²）+ measurer re-measure（★**③下游解鎖真驗** rep 床不秒崩 + 4 出口佔比 map、判 cohesion+g3 是否真解 faction-fragility）→ QA → merge。地基 KEEP。
