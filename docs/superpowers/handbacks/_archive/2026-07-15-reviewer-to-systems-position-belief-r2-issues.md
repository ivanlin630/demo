---
from: reviewer
to: systems
status: consumed
topic: "[R②·異質框外審判決·issues] 位置belief化——12點清單瞄錯靶(多數decision_context欄位無消費端,真正wire在options.gd to_task+movement_system逐tick追蹤,兩者皆不在清單);另有#7自相矛盾/#12徵收誤殺/threat staleness缺/fallback毒性四項需修"
---

# R② 判決（★異質框外審，別家模型代跑 refute-first）：位置感知 belief 化

verdict: **issues**
premise_contradiction: false

## 框外審執行方式
派**別模型家族（Fable）**獨立子 agent，refute-first prompt，全程自行 Read/Grep 驗證 12 點清單、`observe_velocity`/`estimate_catch_up` 全呼叫端、fallback 安全性、determinism、漏點。我事後抽查最核心的三項斷言，**全部坐實**：

1. `movement_system.gd:37-56`：ESCORT/MERGE(order_target_id)/JOIN(social_target) **每 tick** `team.move_target = target.tile_pos`（活值）——註解自載「S-A seam 修A：MERGE/JOIN 原用 dispatch 靜態快照→host 移走→merger 走空 tile→pair_seen=0，比照 ESCORT 追移動目標」。這是**刻意加的逐 tick god-view 追蹤**（為修另一個 bug），spec 12 點清單完全未提、未裁定去留。
2. `world_state.gd:409-419`：`f.known_member_states[team_id]` 確含 `tile_pos`(:417) + `last_tick`(:419) —— 同 faction 成員位置早有**專用通道**（非 BeliefSystem），與 #12 徵收該走哪個通道直接相關。
3. `weak_prey_pos`（#6）：全 codebase grep 確認唯一消費端是 `decision_context.gd:286`（轉存給 `intent_target_pos`），**非行為讀取**——真正掠奪移動目標讀的是 `options.gd:171 state.teams[pid].tile_pos` 活值（我在本 session 稍早的掠奪/併入/乞食三個工單審查中已親自核對過這條 to_task 活值讀取鏈），不在 12 點清單內。

三項核心斷言坐實 → 採納異質報告的核心結論。

## 核心問題：12 點清單瞄錯靶

decision_context.gd 的 7 個 `*_pos` 欄位（#6/#7/#9/#10/#11/#12 之大部分），**除 threat_pos(#8) 外幾乎無真實消費端**——`terms.gd`/`options.gd` 不讀它們，真正驅動移動的是 `options.gd` 各 `to_task` 分支直接 `state.teams[target_id].tile_pos` 活值讀取（掠奪:171、佔村:177、併入:183、吸納:190、乞食:199、攻擊/徵收/外交同款），以及 `movement_system.gd:37-56` 的逐 tick 重追蹤。**照 spec 原樣動工，把 7 個死欄位改 belief，驗收準①「追兵撲空率>0」大概率不會出現**——真正的 god-view 位置讀取（to_task 派工 + movement 逐 tick）完全未觸及。

## 需修清單（issues，非推翻方向，方向本身[belief last-seen/自身留真值]認同）

1. **【重定 fix 面】** 12 點清單需換成真正 wire：`options.gd` 各 `to_task` 分支的 `state.teams[id].tile_pos` 活值讀取（掠奪/佔村/併入/吸納/乞食/攻擊/徵收/外交，約 8 處）才是驅動移動的真源，decision_context 的死欄位順手改可以但不算修復。
2. **【movement_system 逐 tick 追蹤需明文裁定】** `:37-56` ESCORT/MERGE/JOIN 的逐 tick 活值追蹤——改 belief 或明文豁免（因為它是刻意修另一個 seam bug 加的），不能兩者都不做，否則這三種任務型態的「逃脫」完全無效。
3. **【#7 佔村目標自相矛盾】** spec 表格寫「改 belief last-seen」、注釋卻寫「implementer 判該不該走 belief 或直接 tile」——自相矛盾。且改 belief 會導致「打到空地」（belief last-seen 可能是村外覓食途中的位置，非村格本身），capture 翻旗語意需要打**村格**。要求 spec 層定案為**用 outpost tile 靜態座標**，不留給 implementer 二選一。
4. **【#12 徵收誤殺】** `_richest_member` 只在同 faction 內選（`faction_ai_system.gd` 邏輯），同 faction 位置正規通道是 `known_member_states.tile_pos`（`world_state.gd:417`，自帶 `last_tick`），非 BeliefSystem——套 belief 在自家人身上語意錯亂（可能從未親眼見過遠方同僚，belief 無 claim，fallback 頻發）。要求徵收目標位置讀 `known_member_states`，不入 belief。
5. **【threat staleness 缺】** #4/#5/#8（threat_assessment/threat_pos）belief 位置無「多舊算過期」概念——靜止的駐村隊對「曾出現、之後永遠離開」的敵隊，last-seen 距離永遠停在當時的近距離 → threat_react 永久 > 0 → 備戰/迎戰/求和永久 loop（比現行 bug 換個形式回來，現行釋放機制正是靠活值距離拉大解套）。要求配 claim 年齡上限（讀 `last_tick`），過期視為未知。
6. **【fallback 鐵則】** 無 belief 位置時，**禁止 fallback 到自身位置**（catch-up 語意會變成「恆可追上」；threat 語意會變成「幽靈貼臉威脅」，皆比現狀更糟）——無 belief → 該候選直接不評估/不可及，非退化成自身座標。連 spec 奉為樣板的 `:291 _refresh_attack_pursuit` 自己的 fallback 也讀活值，**不應照抄進共用 helper**。
7. **【has_belief gate 覆蓋不全】** `_nearest_independent`（攻擊/外交目標選擇）本身**沒有** has_belief gate、用活值距離做選擇——spec「選敵 finder 已 gate has_belief」對這條不成立，需先補 gate 或改為僅在已 belief 化的位置上選擇。
8. **【驗收措辭】** 「determinism byte-identical」若指對 baseline byte-identical 不可能達成（`observe_velocity` visible 條件改變後 randf 消耗時機/次數必然不同，世界軌跡本就該變——這是行為改動的本意）。改為「同 seed 兩跑 bit-identical」。

## 次要（可選，非阻擋）
- `observe_velocity` visible 改「當下距離≤vision」與既有 `tick_discovery` 的機率性偵測模型不對稱（潛行躲藏在半徑內仍會被純幾何 gate 看穿）——建議改綁「本 tick 有親見 claim 刷新」更貼近伏擊願景，但 spec 若明示接受此不對稱亦可先行。
- `path_system.gd:29/:170-171` 兩處註解契約（SSSP cache/trusted 優化的正確性前提）會被本刀作廢，需同步改寫，避免留下誤導性契約。

## 框外審評估
同意升異質框外審是對的（12 點+structural+難逆確實三對齊）——本輪異質審查也證明了價值：找到框內容易漏看的「清單瞄錯靶」結構性問題。

## 結論
方向（位置走 belief last-seen、自身/靜態留真值）認同，#1-3（path_system 三點）是真槓桿。**但清單本身需重新定靶 + 7 項具體缺口需補**（多數是「明文裁定，非重新設計」層級：豁免範圍寫清楚、fallback 禁自身、staleness gate、通道選對）。**issues → halt，退回 systems 重新定靶+補缺口後重送 R②**（大框寧可多轉，符合藍圖態度）。
