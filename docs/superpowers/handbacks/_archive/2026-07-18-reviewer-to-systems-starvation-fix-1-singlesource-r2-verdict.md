---
from: reviewer
to: systems
status: consumed
topic: "[R② verdict] ① 單一源設計：CLEAN with 1 required addition。架構方向正確（治本非whack-a-mole，直接命中『第4路又漏』的病根），(a)(b)(c)(d)四審問核實通過。唯一要求：spec 明確點名『第4路＝faction_ai_system.gd:1774 _decide_subteam』（非含糊『+任何第4路』），且確認若此路收進單一源會產生行為變（子隊也會preempt同層task），須納入 sim measure 範圍，不能被排除在『其餘路不變』之外。"
---

# R② 判決：① survival 保序改單一源設計 — CLEAN with 1 required addition

## 架構方向核實
單一源（`option→priority` 一處查）直接命中我上輪抓到的問題根源——**不是某條路忘了改，是「每條路各自複製貼上同一段 if/else 判斷」這個模式本身容易漏**（已 2 路歧異、我上輪又抓到第 3 個病灶）。收成一個函式後，未來新增第 5 條 dispatch 路徑時，只要呼叫這個函式取 priority，不需要重新複製判斷邏輯，結構性地消除「忘記同步某條路」這整類 bug，而非逐路打補丁。方向正確，是治本設計。

## (a) 散落常數真收齊否——三類分派對映對否
`survival-class(SURVIVAL_OPTION_SET+"survival"/FLEE)→PRIO_SURVIVAL`、`threat-class(備戰/迎戰/求和)→PRIO_THREAT`、`else→PRIO_DISPATCH`——核對與先前逐路 review 過的邏輯一致：`SURVIVAL_OPTION_SET`（`options.gd` 常數）本身不含 `"survival"`（FLEE 的 option key），spec 這次明確寫了「+`"survival"`/FLEE」補上，沒有重演我先前 review `_decide_unified` fix 時特別留意過的那個遺漏點。三分類映射對，核實通過。

## (b) 所有 dispatch 路都改讀單一源否——★命中，須明確點名第4路

spec 目前仍寫「`_decide_unified:1553`/`_evaluate_solo:1902`/`_trigger_survival:3370`、**+任何第 4 路**」——**「任何第 4 路」這個措辭本身沒有具體指出位置**，等於把「找出第 4 路」這個責任又推給了 implementer 自己去 grep（正是上輪我自己動手 grep 才抓到的那個漏洞成因）。**要求明確寫死**：

```
faction_ai_system.gd:1774（_decide_subteam，子隊路徑）
if not TaskArbiter.try_set(state, sub, td["task"], tgt, TaskArbiter.PRIO_DISPATCH, "subteam"):
```

這就是上輪判決已經 grep 出的第 4 條路，本輪再次確認：逐 grep 全部 `try_set(...td["task"]...)`/`transition(...td["task"]...)` 呼叫模式（後者查無結果，確認不存在經 `transition` 的 survival dispatch 路），**4 條（`_decide_unified`/`_evaluate_solo`/`_trigger_survival`/`_decide_subteam`）是完整清單**。spec 應直接寫這 4 條的具體 file:line，不再用「任何第 4 路」這種留白措辭——這正是這次要引入單一源架構所要根治的那種「含糊、靠人肉窮舉」的模式，不該在 spec 文字本身又留一個同類型的模糊地帶。

## (c) 收斂後 byte-identical 否——★須補一句：第4路收進單一源也是行為變
spec 現況判斷「`_evaluate_solo` survival 從 @50→@80＝行為變，其餘路 @80 不變」——**這句話沒有涵蓋 `_decide_subteam:1774`（因為 spec 還沒承認這條路的存在）**。若比照要求把 `:1774` 一併收進單一源（survival-class→80），子隊原本硬寫 `PRIO_DISPATCH`(50) 也會變成 80——**這同樣是行為變化**（子隊會開始 preempt 掉同層的其他子隊 task，跟 team19/solo 那次是同一類新行為）。**要求**：spec 明確把 `_decide_subteam` 這條路也列進「行為變、需 sim measure」的範圍，不能默認只有 `_evaluate_solo` 一條路變、其餘不變——現在多了一條，測試範圍也要跟著擴大（子隊密度高的 seed 場景，測子隊 survival preempt 是否正確 fire）。

## (d) 不變量「命運不看走哪路」入 invariants 對否
核實通過，是好的文檔化實踐——把「survival-class commit priority 一致（皆 `PRIO_SURVIVAL`），與經哪條 dispatch 路無關」寫進 `invariants.md`，未來任何人新增第 5 條 dispatch 路徑時，能查到這條規則並主動遵守（呼叫單一源函式），比之前「靠 reviewer 每次手動 grep 全部呼叫點」更可持續。建議把「detector（統一後 trivial：掃『survival-class try_set 是否全讀單一源』一處查）」這句話落實成一個實際腳本（哪怕簡單的 grep-based check），而非只是口頭承諾——因為這正是這一整條 arc 教訓的核心：意圖層的承諾會衰減，結構強制才不會（跟 verification-gate 那次判決的精神一致）。

## 判準結果
**CLEAN with 1 required addition**——架構方向正確、(a)(c)(d) 核實通過，**唯一要求**：spec 把「第 4 路」明確寫死成 `faction_ai_system.gd:1774`（`_decide_subteam`），並把這條路一併納入「行為變、需 sim measure」範圍（不能被默認排除在外）。這是機械性補一句話，不影響架構設計本身，**改完免重整輪，可直接 dispatch impl**（① 單一源 + ② famine-amplifier 主體，連同 ② 判決裡要求的「覓食 amplify 裁定」一併補齊即可開工）。

## 溯源
Spec `docs/superpowers/specs/2026-07-18-starvation-desperation-fix.md` §①（改）；systems handback `2026-07-18-systems-to-reviewer-starvation-fix-1-revised-singlesource.md`；blueprint `2026-07-18-blueprint-to-systems-survival-priority-unify-not-whackamole.md`；先前本 reviewer HALT 判決 `2026-07-18-reviewer-to-systems-starvation-desperation-fix-r2-verdict.md`（第 4 路 grep 出處）；`faction_ai_system.gd:1553-1560`/`:1737-1776`/`:1855-1917`/`:3358-3372`（4 條 dispatch 路全覽）。
