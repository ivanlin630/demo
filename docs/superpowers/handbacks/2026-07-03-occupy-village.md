# Hand Back: 佔村 option（雙引擎複利咬合點）

> Status: consumed（2026-07-03 merged,系統收編）
分支：`feat/occupy-village`。Spec：`docs/superpowers/specs/2026-07-03-occupy-village-design.md`。Plan：`docs/superpowers/plans/2026-07-03-occupy-village.md`。

## TL;DR

- **Task 1（measure）= 完成，判定明確。** 「戰不落村格」假說**否決**（100% raid 戰鬥落 outpost 格）。主斷 = **收益鏈/成長引擎斷**（翻旗真發生但食引擎不點火），次因 = **無佔村 option + 狼追流浪隊空轉**。
- **Task 2（佔村 option）= 已接線且會 fire，但食引擎未點火。** option 架構正確（means-end 連續 util、零新判斷器、複用 capture+residency），safe（緊 gate 防自殺圍城），長窗 dispatch=13。但 **capture_flip=0**：小狼派佔村攻擊打不贏村圍城 → 無翻旗 → 無食引擎。**根因是 Task 1 已指認的上游收益鏈/成長斷**（小狼太弱贏不了村、翻旗村不產出、同化 0/7 完成），非 option 本身——屬單 session 安全範圍外的大改。
- **Task 3（驗收）= 部分達成。** 佔村事件>0（dispatch=13）、不 over-war、回歸全綠；但 food_flow 未轉正、雙引擎弧未見（需收益鏈修）。
- **回歸全綠**：headless（1 FAIL pre-existing 容忍）、framework 7/7、coin_eq（CoinAudit delta=0）、InvariantAudit（population/faction/subteam/roster 皆 OK）。

## Task 1 — Measure 判定（seed 1337, 6 月, longwindow_bed）

探針裝在三點（純觀測，Probe.enabled gate）：raid 解決分佈（interaction TASK_LOOT 落點）、capture 真翻旗（outpost.capture）、prey residency。基線數字（Task-1-probes-only，未動行為）：

```
raid 解剖：resolve=11  extort=4  combat_at_outpost=5  combat_open_field=0  loot_noresolve=2
戰鬥落村格率 = 100%          ← 「戰不落村格」假說否決
prey 組成：resident村隊=3  流浪隊=8
capture 翻旗=13（by_loot=1  civilian村格=10  流浪狼首據點=4）
funnel：conq.intent=119 → prosperity_reached=5(4.2%)；surv.loot_dispatch=1005 vs raid.resolve=11
wolf pop growth(Σ狼) = -6  ；assimilate created=6 completed=2（interrupted 碾 completed）
```

**判定（機制斷 vs 權重斷佔比）：**

1. **「戰不落村格」= 否決（0% 開闊地）。** 追流浪隊撞開闊地=capture no-op 的假說**不成立**——raid 戰鬥全落 outpost 格，翻旗機制正常，13 次翻旗真發生。
2. **主斷 = 收益鏈/成長引擎斷（機制斷）。** 翻旗 13 次但 wolf growth **-6**、food_flow 恆 ≤0、assimilate 2/6 完成。翻旗改所有權，但：(a) 小狼贏不了圍城（村防守用全 pop×armed_floor，belief 軟≠真軟）；(b) 翻下的村不為新 owner 產出（原住民非同 owner/faction，`_team_works_tile` 擋）；(c) 同化鏈斷（captive 多 scatter/escape）。**捕獲是 attack/pursuit 附帶（by_loot=1），非蓄意佔住。**
3. **次斷 = 權重斷（無 option）。** `_decide_unified`/`rank_survival` menu **無佔村 option**——conq.intent 119 → 實際 prosperity-attack 僅 5；surv.loot_dispatch **1005** vs 真 resolve 11（狼狂派 loot 但追流浪隊追不到 → 空轉），且翻旗後無任何 util 秤「守住這據點」。

## Task 2 — 佔村 option（已實作，safe，foundation ready）

按 spec：means-end 兩 option 並列（掠奪=搶了就走 / 佔村=佔住），零新判斷器，複用既有 capture 翻旗 + `_evaluate_outpost_residency` 派駐 + 產出歸 owner。**不新造據點系統。**

接線（統一決策引擎縫）：
- `decision_context.gd`：新 `has_occupy_target`/`occupy_target_id`/`occupy_target_pos`（gather 呼 `_find_occupy_target`）。
- `decision/terms.gd`：`occupy_drive`（野心 base_need，無 outpost 流浪狼=1、有=0.3）+ weight `occupy`（野心/好戰/統領）+ `_intent_fit` 加「匱乏→奪產村」boost（與掠奪 parallel，同 hunger scale）。
- `decision/options.gd`：REGISTRY `佔村` = `[occupy_drive, intent_fit]`（同掠奪 shape）；applicable（有可據弱村 + pop≥OCCUPY_MIN_POP + 無 outpost/征服 intent）；to_task = `TASK_ATTACK` 到村格（戰勝→capture 自動翻旗→次 cadence has_own_outpost→生產/駐守+residency 接手）；`佔村` 入 `SURVIVAL_OPTION_SET`（狼慢性餓，佔村須在 survival menu 可選，否則永不 fire）。
- `faction_ai_system.gd`：`_find_occupy_target`（可據=站自家 outpost 的村；weakness 讀 belief `pop_est`/`armed_est` 非 god-view；緊 gate：`pop_est < pop×OCCUPY_POP_RATIO(0.6)` + `armed_est < pop×0.5` + `eta ≤ OCCUPY_ETA_MAX(720)` 防自殺圍城）。dispatch 探針。

**行為結果（6mo, eta720+緊 gate）：佔村 dispatch=13、不 over-war（raid resolve 降）、無 food_flow 崩（早期鬆 gate 版曾致 -63 圍城餓死，緊 gate 修掉）。但 capture_flip=0——小狼贏不了村圍城 → 翻旗 0 → 食引擎不點火。**

**佔村 option 是正確的 means-end foundation，但無法在此 session 獨力點火雙引擎**——需先修上游收益鏈/成長引擎（見下），狼壯了才圍得贏、翻旗才有產出。

## 連動風險

- **`decision_context.gd` gather 每 tick 多一輪 `_find_occupy_target`（O(discovered)+estimate_catch_up）**：仿 `_find_weakest_prey`，約倍增該成本。有界（服 per-tick 有界不變量），但 seed 化 harness 的 RNG 流被 `estimate_catch_up` observe randf **擾動**（seeded warring final teams 89→87，仍逐點重現 a==b、headless 綠）。屬 estimate_catch_up 既知 RNG 副作用，非新病。
- **`SURVIVAL_OPTION_SET` 加 `佔村`**：survival 路多一 option。緊 gate 下 safe（只圍近+明顯弱村，不餓死途中）；survival 路 dispatch 時補設 `team.current_option="佔村"`（capture 歸因用，non-unified 原不設 current_option）——低風險，若日後入 unified 路會給佔村 commitment bonus（合意）。
- **無新 latch**：佔村複用 `TASK_ATTACK`（既在 `STUCK_TASKS`，`_is_stuck`→release、prey 亡→release），無新 timeout 債。residency 的 `TASK_SETTLE` 是既有子隊機制，未動。

## 待主 session 確認 / 建議後續

1. **收益鏈/成長引擎修（Task 1 指認的主斷，建議首序 next task）**——佔村 option 點火的前提。三段任一或全：
   - **翻旗村產出歸新 owner**：捕獲的定居村原住民（敗方 PRODUCE 隊）轉為新 owner 受控人力/同 faction → `_team_works_tile` 才放行 → 糧倉續產。（spec「村民=受控人力」）
   - **小狼圍城勝算**：佔村目標 belief 弱≠真弱（村用全 pop×armed_floor 防守）。需 狼夠壯（pop 門檻/戰力比）才佔，或 佔村限「真可勝」村。當前小狼（pop 8）圍 pop 15-25 村必敗——循環依賴：無佔村不壯、不壯佔不了。
   - **同化鏈**（asm completed 2/6→0/7）：captive 多 scatter/escape → 受控人力不成形 → 狼不壯。
2. **佔村 option 去留裁定**：現 shipped=safe foundation（fire 但未點火）。若主 session 認為未點火前不宜掛（省 gather 成本），可暫收 applicable gate 至 dormant，待收益鏈修好再開。
3. **DIAG 探針**：`occupy.scan_*`/`appl_*`/`ctx_hastarget` + bed `[occupy DIAG]` 印——為收益鏈修的 tuning 佐證保留（Probe-gated，production no-op）。點火達成後可裁。

## TEST VALUE 清單（正式平衡 pass 調）

| 常數 | 檔 | 值 | 意義 |
|---|---|---|---|
| `OCCUPY_DRIVE_BASE` | terms.gd | 1.2 | 佔村野心驅力基值 |
| `OCCUPY_MIN_POP` | terms.gd | 6 | 佔村最低 pop（守+日後分駐 settler；注意 `MIN_PARENT_POP_AFTER_DISPATCH=10`，pop<12 難派 settler） |
| `OCCUPY_ETA_MAX` | faction_ai_system.gd | 720 | 佔村目標最遠 eta（≈3 日，防久圍餓死） |
| `OCCUPY_POP_RATIO` | faction_ai_system.gd | 0.6 | 目標 believed pop 須 < 我方×此（防小狼圍大村） |
| occupy weight/armed gate 0.5 | terms/faction_ai | — | 次濾 armed_est < pop×0.5 |

## 檔案改動

- `scripts/simulation/interaction_system.gd`：Task1 raid 解剖探針（`_probe_raid`，TASK_LOOT 落點分 extort/combat_at_outpost/combat_open_field + prey residency）。
- `scripts/simulation/outpost_system.gd`：Task1 capture 翻旗探針（`_probe_capture_flip`，by_loot/civilian/流浪狼首據點 + 佔村歸因）。
- `scripts/simulation/decision/decision_context.gd`：佔村 target ctx 欄。
- `scripts/simulation/decision/terms.gd`：`occupy_drive` + weight `occupy` + `_intent_fit` 匱乏→奪產村。
- `scripts/simulation/decision/options.gd`：REGISTRY `佔村` + applicable + to_task + SURVIVAL_OPTION_SET。
- `scripts/simulation/faction_ai_system.gd`：`_find_occupy_target` + 佔村 dispatch 探針（unified + survival 路）+ OCCUPY 常數。
- `scripts/debug/longwindow_bed.gd`：`_print_raid_dissection`（Task1 分佈表 + occupy DIAG funnel）。
