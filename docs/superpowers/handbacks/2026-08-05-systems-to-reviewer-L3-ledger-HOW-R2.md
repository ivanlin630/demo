---
from: systems
to: reviewer
status: consumed
topic: "[R² 審 2 補完批 HOW spec(各新 slice branch、CLEAN 才 dispatch implementer)·(1)L3 循環貿易 HOW=docs/superpowers/specs/2026-08-05-L3-circuit-trade-HOW.md:升級既有 _nearest_market_outpost naive→genuine visit-util(staleness+arb 期望−路程×人格)+放寬 options.gd:19 貿易 applicability(settled 產隊進得去)+探索未知市集(staleness MAX);禁平行機制(R① HOW 約束);新 team_market_last_read store(staleness 源);走主 argmax 非 side-action·審點:感知鐵律(visit-util 讀 belief staleness/heard-arb 非市集 live stock,到場 firsthand 才知真貨)/湧現非 script(無 waypoint)/人格 MODULATE 非 crank·(2)失聯帳本 HOW=docs/superpowers/specs/2026-08-05-missing-contact-ledger-HOW.md:共享原語 _contact_elapsed_days(整併義務,母→子 dispatch-log elapsed + 子→母 reuse best_estimate.last_tick,重構 _evaluate_owner_contact:4662 走共享=一套非兩套)+dispatch_ledger 機械估+逾時 ratio 人格 mini-util 反應(接既有 herald/scout side-dispatch 不新動詞)·審點:整併義務(帳本非第 4 散落點=必收斂 _evaluate_owner_contact 原語)/零 god-view(失聯 belief 不含 subject 真死活)/人格非死常數(逾時 ratio 連續進 util 非硬門檻必派)/照妖鏡候選(CONTACT_TIMEOUT_DAYS 等本批不動、記 faction-balance)·序:R² CLEAN each→我 dispatch implementer build→量(人格分化)→QA·兩 spec 前提已 file:line 親驗 merged main(seam 行號 real)·核心 arc merge 我收尾中不擋·地基 KEEP"
---

# R² 審 2 補完批 HOW spec（L3 + 失聯帳本）

blueprint WHAT R①×2 CLEAN → systems HOW 完 → **R² 每 slice 必過**（CLEAN 才 dispatch implementer）。兩 spec 前提已 file:line 親驗 merged main（seam 行號 real）。

## (1) L3 循環貿易 HOW（`2026-08-05-L3-circuit-trade-HOW.md`）
**升級既有路、非平行機制**（R① HOW 約束）：
- 塊①`_nearest_market_outpost` naive→genuine `_best_market_target` visit-util（staleness+arb 期望−路程 × 人格 modulate）。新 `team_market_last_read` store（staleness 源、`read_market_board` 到場 stamp）。
- 塊② 放寬 `options.gd:19 貿易.applicable`（+`has_market_visit_value`、settled 產隊進得去）。
- 塊③ 資訊帶回=既有 carrier（確認不新建）。
- 走**主 argmax**（訪市=body 移動、非 side-action）。
- **審點**：感知鐵律（visit-util 讀 belief staleness/heard-arb、**禁讀市集 live public_storage 真值秤 util**、到場 firsthand 才知真貨）；湧現非 script（無 waypoint、staleness↑→visit↑ 湧現巡迴）；人格 MODULATE 真值非 crank；禁平行「訪市」step/REGISTRY。

## (2) 失聯帳本 HOW（`2026-08-05-missing-contact-ledger-HOW.md`）
**整併義務核心**（R① 定、防第 4 散落點）：
- 塊① 共享原語 `_contact_elapsed_days`（team-subject→`best_estimate.last_tick`、非-team letter→dispatch-log elapsed）；**★重構 `_evaluate_owner_contact:4662` 改呼此 helper**=母↔子一套失聯感知（非兩套）。
- 塊② `TeamData.dispatch_ledger`（各 dispatch 點 append、`expected_return_tick` 機械估零人格）。
- 塊③ 逾時 `overdue_ratio` 連續值 → 失聯 belief（零 god-view）→ 人格 mini-util 反應（接既有 herald/scout side-dispatch、不新動詞；救援隊新動詞不在本批）。
- **審點**：整併義務（帳本必收斂 `_evaluate_owner_contact` 原語、否則第 4 散落點）；零 god-view（失聯 belief 不含 subject live 死活/位置）；人格非死常數（逾時 ratio 進 util、**禁硬門檻必派**）；照妖鏡候選（`CONTACT_TIMEOUT_DAYS`/`OWNER_CHANGE_BUFFER` 等本批**不動**、記 faction-balance 批）。

## 序
R² CLEAN each → 我 dispatch implementer build（各新 slice branch）→ 量（訪市 + 失聯反應**人格分化**）→ QA（新常態）。核心 arc merge 我收尾中（gate 全綠 blueprint ack）、不擋補完批。地基 KEEP。
