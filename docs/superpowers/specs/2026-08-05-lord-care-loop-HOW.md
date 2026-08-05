# 領主主動照護 loop — HOW（systems，實作設計）

status: DRAFT → reviewer R²
owner: systems（HOW）；WHAT=`2026-08-05-lord-care-loop-design.md`（blueprint LOCKED、R① CLEAN、P4=(a) firsthand 觀察 write）
date: 2026-08-05
branch: 新 slice `feat/lord-care-loop`（off 更新後 main，含 ledger+cohesion merge）
grounding: cohesion ①natural blocked（relief reactive、傲村不開口→好領主建不起恩義史）；wiring arc 三塊全接既有件。

## 目標（承 WHAT）
proactive-care loop 讓好領主自然建恩義史→cohesion ①natural 分化活。**注意力=人格秤+真成本、零死常數、非保姆國家、結果分化**。四塊全接既有件。

## Seam（親驗 file:line、merged main）
- ledger：`dispatch_ledger`（team_data）+ `_ledger_record`（faction_ai:4676、kind/subject_ref/dispatched/expected/resolved）+ `_step_contact_ledger`（:4696 掃逾時→overdue_ratio→`_pick_contact_reaction` 4 類 argmax）+ `_apply_contact_reaction`（redispatch=`_try_scout_side`/`_try_herald_side`）。
- scout：`_try_scout_side`（:1709、reuse）；S-scout tick（`:1581-1582`）co-located→查子民 need（食糧買單）帶回領主 `team_known`/刷新 belief——**但依賴村 post 買單**。
- distribute：`_try_distribute_side`（:1661）→`_distribute_candidates`（goal_resolver、讀 `received_buy_orders` belief + 人格 relief、零 god-view/零死常數）。
- benefactor：relief settle→`interaction:890` write benefactor memory（cohesion 已 merge）。

## 四塊 HOW

### ①ledger 加 holding 條目類（第 4 kind）
- 領主對**自家 faction 固定據點/村（holding）**記 `dispatch_ledger` 條目 kind="holding"（subject_ref=村 team_id、is_team=true）。與 herald/scout/convoy 別：**holding 非一次性派出、是持久監看**——`expected_return_tick` = 上次接觸 + **預期音訊週期**（機械估：依距離、零人格）；每次接觸（scout-check 帶回 / 村自身訊息達）**刷新** dispatched_tick（非 resolved-and-drop）。
- 記帳點：領主 established 據點/收村時 append holding 條目（or lazy：`_step_contact_ledger` 對自家 faction holding 補建）。
- 逾時偵測：`_step_contact_ledger` 對 holding 用共享 `_contact_elapsed_days`（belief last_tick / 自我 last-contact）> 預期→失聯 belief（村久無音訊）。**零 god-view**（只知逾時、不知村真況）。

### ②理不理＝領主人格秤（零死常數）
- holding 逾時→**領主決定理不理**＝`_pick_contact_reaction` 家族的 care 變體（連續 util）：`care_util = overdue_ratio × 人格加權（責任/仁慈）`，vs `ignore_util = overdue_ratio × 人格加權（野心/疏忽）`——argmax（competing、同 react 家族結構、**禁 if/elif 死一條**）。
- 責任/仁慈高→**check**（派 scout 查村）；野心/疏忽高→**ignore**（村照樣餓死叛離=正確分化）。**零死常數**（無「逾時 X 必派」）。

### ③scout reuse +（a）firsthand 觀察 write（P4 核心）
- check→reuse scout side-dispatch（`_try_scout_side` / `dispatch_anon_messenger TASK_SCOUT` target=村 pos）。**真成本**（斥候佔人力、與軍偵搶）。
- **★(a) firsthand 觀察 write（P4 缺口補）**：scout 抵村 co-located（既有感知 carve-out 合法）→ **讀現場可見**（村 food 存量 / population / 困頓跡象、**非私念非全知**）→ 合成 distress 觀察值（**不依賴村 post 買單**——傲村不開口也看得見；類 herald `runway-deficit synth`）→ 寫 belief（`received_buy_orders` proxy 訊 or distress belief、**帶時戳**）。
- ＝現行 S-scout tick 的 firsthand read **擴**：原只讀「村 post 的買單」→ 加「村可見 food/pop 缺口」（posted-order-independent）。

### ④觀察 belief → distribute mini-util（餵已 merge 賑濟秤）
- firsthand distress 觀察值入 belief → `_try_distribute_side`/`_distribute_candidates` 讀（received_buy_orders / distress belief）→ 領主 preemptive 賑濟（既有免費 gift convoy）→ relief settle → benefactor memory 累積（cohesion ①natural 地基）。
- **無新賑濟機制**（reuse 已 merge distribute mini-util、只多一個 belief 來源=firsthand 觀察）。

## 守（憲法/感知鐵律/程度界線）
- **零 god-view**：holding 逾時=自我 last-contact 記憶；scout firsthand=co-location 物理在場讀現場可見（既有 carve-out）；distress belief 帶時戳、非全知村況。constitution gate 綠。
- **零死常數**：理不理=人格秤（連續 util argmax、非「逾時 X 必派」）；預期音訊週期=機械估（距離、非人格排程）。
- **真成本/資訊守物理**：scout 佔人力+走路延遲、偏遠村天生少被看、窮領主賑濟不起=非普遍照護。
- 人格非死常數 / determinism byte-identical（觀察 write 純讀現場+算術、scout dispatch 既有）/ §程度界線（非保姆國家：無天眼、無自動補滿、結果分化）。

## TDD 驗收（implementer）
1. **holding 逾時偵測**：領主自家村久無音訊→holding overdue（RED：holding kind 未加→無 care 觸發）。
2. **理不理人格分化**：責任/仁慈 lord→check(scout 派) vs 野心/疏忽 lord→ignore（competing util argmax、RED：care/ignore neuter→齊一）。
3. **★(a) firsthand 觀察 write**：scout 抵**不 post 買單的傲村**→仍讀出 food/pop 缺口→distress belief 寫（RED：只讀 posted order→傲村永遠盲）。
4. **觀察→賑濟**：firsthand distress→distribute mini-util fire→preemptive relief→benefactor write（端到端 RED：觀察 belief 未接 distribute→relief 不 fire）。
5. **零 god-view 硬驗**：holding/observation 讀自我記憶+co-location belief、非全知村況（感知鐵律 gate）。
6. determinism byte-identical + constitution 74。

## 量測（= cohesion ①natural 真考、measurer→QA）
- **★自然床分化**（moderate-distress ex-ante 判準床：distress 窗>物理最短救援延遲）：責任/仁慈 lord 的村被查/被救→恩義史→**留得住** vs 疏忽 lord 的村**照樣叛離**。
- **失敗照常在**（查太晚/斥候死/領主窮=非普遍照護）。人格分化可觀測、零死常數、determinism、感知鐵律、QA 故事稽核（照護 motive→scout→firsthand→賑濟→留人鏈）。無配額。
