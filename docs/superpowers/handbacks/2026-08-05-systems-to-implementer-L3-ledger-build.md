---
from: systems
to: implementer
status: consumed
topic: "[dispatch build 2 補完批 slice(R②×2 CLEAN、各新 slice branch off 更新後 main 含核心 arc merge 4f09671e)·(1)L3 循環貿易 feat/L3-circuit-trade,spec docs/superpowers/specs/2026-08-05-L3-circuit-trade-HOW.md:升級 _nearest_market_outpost naive→genuine _best_market_target visit-util(staleness+arb 期望−路程×人格 modulate)+放寬 options.gd:19 貿易 applicability(+has_market_visit_value,settled 產隊進得去)+探索未知市集(staleness MAX)+新 team_market_last_read store(read_market_board 到場 stamp);arb_expectation reuse best_arbitrage_order(order_system:302-331,belief-only 天然守感知鐵律);走主 argmax 非 side-action;禁平行機制·★reviewer 輕追蹤:trip_cost 權重/staleness_norm calibration 錨真值(真移速/典型 relay 週期 DERIVED,禁反推調到剛好 fire)·(2)失聯帳本 feat/missing-contact-ledger,spec docs/superpowers/specs/2026-08-05-missing-contact-ledger-HOW.md:共享原語 _contact_elapsed_days(抽 faction_ai:4658-4663 的 best_estimate.last_tick+/TICKS_PER_DAY,重構 _evaluate_owner_contact 走它=母↔子一套,單一呼叫點:843 低風險,CONTACT_TIMEOUT_DAYS 門檻本批不動留原地,:4666-4674 owner-leader-changed 不在重構範圍)+TeamData.dispatch_ledger:Array[Dictionary](各 dispatch 點 append,letter 用既有 spawn_tick 當 dispatched_tick)+逾時 overdue_ratio 連續值→失聯 belief(零 god-view)→人格反應·★★reviewer 硬追蹤(genuine 結構命門):react_util 四類(再派/防禦/救援flag/註銷)必須是 competing util 候選集,各自算 util 用 argmax/mini-util>0 選最高,禁 if/elif 人格特質分支揀死一條(=偽裝 util 的死常數門檻、退化);同求援/偵察 mini-util 候選集模式·守 TDD/gate(constitution 74)/determinism byte-identical/感知鐵律/人格非死常數;完成 handback to:systems R²+量測員(人格分化)·地基 KEEP"
---

# dispatch build 2 補完批 slice（R²×2 CLEAN → build）

reviewer R²×2 CLEAN（親驗坐實：L3 感知鐵律 reuse 乾淨函式自動守；ledger 整併義務逐行核對）。各**新 slice branch off 更新後 main**（含核心 arc merge `4f09671e`）。

## (1) L3 循環貿易 — `feat/L3-circuit-trade`
spec：`2026-08-05-L3-circuit-trade-HOW.md`（三塊、皆升級既有 seam）。
- 塊①`_nearest_market_outpost` naive→新 `_best_market_target` visit-util（staleness+arb 期望−路程 × 人格 modulate）；naive helper 保留給買料 caller `_nearest_market_outpost_with` **不動**。
- 塊② 放寬 `options.gd:19 貿易.applicable`（+`has_market_visit_value` ctx 欄、擴充既有 has_goods/has_arb 家族、settled 產隊進得去）。
- 塊③ 新 `team_market_last_read` store（staleness 源、`read_market_board` 到場 stamp `current_tick`）；資訊帶回走既有 carrier。
- `arb_expectation` **reuse `best_arbitrage_order`（order_system:302-331）**（belief-only、只讀 received orders、零 market live stock=感知鐵律自動繼承、reviewer 親驗）。
- 走**主 argmax**（訪市=body 移動、非 side-action）；禁平行「訪市」step/REGISTRY。
- **★reviewer 輕追蹤**：`trip_cost` 權重 / `staleness_norm` calibration **錨真值**（真移速 / 典型 relay 週期 DERIVED；**禁反推調到剛好讓訪市 fire**——訂值交代錨定依據）。

## (2) 失聯帳本 — `feat/missing-contact-ledger`
spec：`2026-08-05-missing-contact-ledger-HOW.md`（三塊）。
- 塊① 共享原語 `_contact_elapsed_days`（抽 `faction_ai:4658-4663` 的 `best_estimate.last_tick + /TICKS_PER_DAY`；team-subject→belief、非-team letter→dispatch-log elapsed）。**重構 `_evaluate_owner_contact` 走它**=母↔子一套（單一呼叫點 `:843` 低風險）；`CONTACT_TIMEOUT_DAYS` 門檻**本批不動、留原地**；`:4666-4674` owner-leader-changed **不在重構範圍**（不同關注點、別誤捲）。
- 塊② `TeamData.dispatch_ledger: Array[Dictionary]`（各 dispatch 點 herald/scout/convoy/subteam append；`expected_return_tick` 機械估零人格；**letter 用既有 `spawn_tick` 當 `dispatched_tick`**、不加欄）。
- 塊③ 逾時 `overdue_ratio` 連續值 → 失聯 belief（**零 god-view**：只知逾時不知死活）→ 人格反應。
- **★★reviewer 硬追蹤（genuine 結構命門、別做壞）**：`react_util` 四類反應（再派/防禦/救援flag/註銷）**必須是彼此 competing 的 util 候選集**——各自算 `react_util("redispatch")`/`react_util("defensive")`/... 用 **argmax / mini-util>0 選最高分**，**禁 `if 人格特質X高 then 反應Y` 決策樹分支揀死一條**（=偽裝成 util 公式的死常數門檻、退化）。同**求援/偵察 mini-util 候選集模式**（保「務實但也有點多疑的領主兩反應 util 接近時的真實張力」emergent 細節）。反應接既有 herald/scout side-dispatch、不新動詞（救援隊新動詞不在本批）。

## 守 + 序
- TDD（各 spec 驗收段）/ constitution gate PASS 74 / determinism byte-identical / 感知鐵律硬驗（god-view detector 綠）/ 人格非死常數。
- **worktree off 更新後 main**（stale-base 注意：main 現 HEAD 含 merge `4f09671e`+blueprint 補完批 commit）。
- 完成 → handback `to:systems`（R²）+ 路 measurer 量（**訪市 + 失聯反應人格分化**、per-option util dump）→ QA（新常態）。地基 KEEP。
