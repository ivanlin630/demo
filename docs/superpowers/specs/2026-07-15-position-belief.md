# Spec：位置感知 belief 化（god-view 位置根治）— v2 重定靶（異質框外審後）

status: 核心 A-E merged-to-branch bd6f97d2（systems 驗 PASS）；+Fix F pursuit vision-gate（blueprint 裁定 ①，待 R② → dispatch implementer）
owner: systems
premise_verified: ★v1 瞄錯靶（decision_context `*_pos` 多數 dead），v2 靶＝真 wire（options.gd to_task 活值 + movement_system 逐 tick），異質框外審 file:line 坐實
blueprint_intent: `2026-07-15-blueprint-to-systems-godview-position-arc.md`（逃得掉/躲得住/伏得成）
governing: `invariants.md §感知鐵律`（位置只吃可見/最後可見）

## ★v1→v2 為何重寫（異質框外審抓）
v1 清單（12 個 decision_context `*_pos`）**瞄錯靶**——那些欄位**幾乎無消費端**（除 threat_pos），真正驅動移動的是：
1. **`options.gd` 各 `to_task` 分支直讀 `state.teams[id].tile_pos` 活值**（8 處，派工 move target 真源）。
2. **`movement_system.gd:37-56` ESCORT/MERGE/JOIN 每 tick `move_target=target.tile_pos`**（活值逐 tick 追蹤，為修 seam 加）。
3. **`_nearest_independent` 用活值距離選目標，無 has_belief gate**。
v1 照改死欄位＝驗收①撲空率仍 0（真 wire 沒動）。v2 重定靶到上述 3 真源。

## Fix（真 wire）
### Fix A：`_belief_pos` 共用 helper（★fallback 鐵則：無 belief 禁退自身）
`decision_context.gd`（或 belief_system）加：
```
static func belief_pos(state, observer_id, target_id) -> Vector2i:
    # 跨-faction 敵情：讀 belief last-seen（含 staleness gate）
    var bel = BeliefSystem.best_estimate(state, observer_id, target_id)
    if bel.is_empty() or _claim_too_old(bel, state):   # staleness：last_tick 太舊視同未知
        return Vector2i(-1, -1)   # ★無有效 belief → 不可及（caller 據此棄該 option/target），★禁退自身
    return bel.get("tile_pos", Vector2i(-1, -1))
```
- **★fallback 鐵則（R②#6）**：無 belief/過期 → 回 `(-1,-1)`（caller 棄），**絕不退自身位置**（退自身＝catch-up「恆可追上」、threat「幽靈貼臉」，比現狀更糟）。`_refresh_attack_pursuit:291` 自己的活值 fallback **不照抄**。
- **★staleness gate（R②#5）**：`_claim_too_old` 讀 belief `last_tick`（`vision_system:114`），超 `BELIEF_STALE_TICKS`(TEST VALUE) 視同未知→回 (-1,-1)。防「敵曾出現後永遠離開→last-seen 距離永停近距→threat_react 永久>0→備戰/迎戰/求和永久 loop」（現行靠活值距離拉大解套，belief 化必須自帶過期）。

### Fix B：`options.gd` to_task 8 分支改 belief（真 wire 主力）
掠奪(:192)/攻擊(:198)/JOIN(:204)/MERGE(:211)/BEG(:220)/攻擊 intent(:230)/徵收(:237)/外交(:242)：`state.teams[id].tile_pos` → 依目標類型：
- **跨-faction 敵情/社交目標**（掠奪/攻擊/JOIN 投靠**跨-faction host=strong_neighbor**/外交）→ `belief_pos(state, team, id)`；回 (-1,-1) → 該 to_task 回 IDLE（撲空 emergent，隊改別的）。
- **★JOIN 併入 host 兩源分流（R②v2#issue，鏡射 #12 通道規則）**：JOIN host＝`strong_neighbor_id if !=-1 else consolidate_target_id`（同 to_task 優先序）。**strong_neighbor（跨-faction）→ belief_pos**；**`consolidate_target`（同-faction）→ `known_member_states.tile_pos`**（同徵收 #12，自家人走世界通道非 BeliefSystem）。依選定 host 的 faction 關係走對應通道，非一律 belief_pos。
- **★#12 徵收/同-faction 目標（R②#4）**→ 讀 `known_member_states[id].tile_pos`（`world_state:417`，自帶 last_tick，同-faction 專用通道）**非 BeliefSystem**（自家人套 belief 語意錯，遠方同僚沒 claim→fallback 頻發）。
- **★#7 佔村（R②#3）→ 用 outpost tile 靜態座標**（capture 翻旗要打**村格**，belief last-seen 可能是村外覓食位置→打空地。outpost 不會跑，讀 tile 真值＝物理設施非隊瞬時位置）。**spec 定案，不留 implementer 二選一。**

### Fix C：`movement_system.gd:37-56` 逐 tick 追蹤改 belief（★R②#2 明文裁定）
ESCORT/MERGE/JOIN 的 `team.move_target = target.tile_pos`（活值逐 tick）→ `belief_pos(state, team, tgt_id)`：
- 目標在視野→belief 刷新→跟上（保原 seam 修意圖：host 移動時仍追得到，只要看得見）。
- 目標斷視線→belief 過時→move 到 last-seen→**撲空**（逃脫生效）。
- belief 回 (-1,-1)（從沒見過/過期）→ 保持原 move_target 或 release（implementer 定，不可退自身）。
- **同-faction MERGE（吸納/consolidate）→ known_member_states**（同 Fix B #12 通道）。

### Fix D：`_nearest_independent` + 選目標 finder 補 has_belief gate（R②#7）
`_nearest_independent`（攻擊/外交目標）現用活值距離、**無 has_belief gate** → 加 gate（只在已 belief 化目標中選，用 belief_pos 距離），或 spec 明示這條走哪個通道。稽核「選敵 finder 已 gate has_belief」對這條不成立，補齊。

### Fix E（次要，R② secondary）：observe_velocity visible + path_system 契約
- `observe_velocity` visible「當下距離≤vision」vs `tick_discovery` 機率偵測不對稱（潛行半徑內仍被幾何看穿）→ **建議綁「本 tick 有親見 claim 刷新」**更貼伏擊願景；spec 若接受幾何不對稱亦可先行（implementer 判/blueprint 裁）。
- `path_system.gd:29/:170-171` SSSP cache/trusted 優化契約會被本刀作廢 → 同步改寫註解，別留誤導契約。

### Fix F：`_refresh_attack_pursuit` vision-gate（blueprint 裁定 ①，2026-07-15）
**根**：`faction_ai_system.gd:285-293`（engage combat_target 後每 tick 追擊微調）**未過 belief gate**——`:291` best_estimate fallback=`prey.tile_pos`(live)、`:292` `predict_intercept(state, team, prey)` 吃**活 prey 物件**做攔截預測。∴ engage 後即使斷視線仍神視精準追活位置＝**逃脫破口**（躲森林/斷後撤退全無效）。blueprint WHAT：engage 後只在**視線內**讀活值；斷視線→跟丟→fallback belief last-seen（撲空）。

**HOW（systems 定）——vision-gate 訊號**：本 tick vision pass 已見 = belief snap `last_tick == current_tick`。權威且無 off-by-one：pipeline 序 `sim_runner` near vision`:184`→faction_ai`:216`、far vision`:238`→faction_ai`:257`——vision 皆在 faction_ai **前**同 tick 跑（current_tick 已 +1），故可見目標本 tick 必有 `last_tick==current_tick`；不可見則落後。

**改（`_refresh_attack_pursuit`，prey==null 早退保留）**：
```gdscript
var snap: Dictionary = BeliefSystem.best_estimate(state, team.team_id, team.prosperity_target_id)
var last_tick: int = int(snap.get("last_tick", -1))
if last_tick == state.world.current_tick:
    # 本 tick 可見 → live 攔截預測合法(在視線內)
    var predicted: Vector2i = PathSystem.predict_intercept(state, team, prey)
    team.move_target = predicted if predicted != prey.tile_pos else prey.tile_pos
    return
# 斷視線 → 去 belief last-seen 搜(prey 已移=撲空空地); belief 過期/無位 → 放棄追擊(re-eval)
var stale: bool = last_tick < 0 or (state.world.current_tick - last_tick) > BeliefSystem.BELIEF_STALE_TICKS
if stale or not snap.has("tile_pos"):
    team.prosperity_target_id = -1
    TaskArbiter.release(team)
    return
team.move_target = snap["tile_pos"]   # last-seen 搜(撲空機制)
```
**三態**：①可見→live 攔截(公平,在視線)；②斷視線+belief 新→追 last-seen(prey 已移=撲空 headline)；③斷視線+belief 過期/無→放棄+re-eval（**staleness 解 loop、防 ghost-chase 無限走向空地**——此 release 非 scope creep，是 vision-gate 引入「追 last-seen」後必要的收尾，否則追兵永遠走向舊位）。
**憲法**：改移動目標來源+既有 release 路徑，零新 try_set；determinism（讀 belief 確定，seen_now 分支才呼 predict_intercept／observe_velocity——與 Fix C 同 randf 時機語意）。

## invariant 守
- **感知鐵律位置版**：敵情/社交目標位置只吃 belief last-seen（含 staleness）；自身位置 + 靜態設施（outpost tile）+ 同-faction（known_member_states）留真值/專用通道。
- **★engage≠永久鎖定 god-view**（Fix F）：追擊 live 讀值需**本 tick 可見**（`last_tick==current_tick`）；斷視線降級 belief last-seen→可撲空→過期放棄。
- **★fallback 禁自身**（Fix A）；**★staleness 必配**（Fix A）。
- **determinism**：belief 讀確定。★**驗收改「同 seed 兩跑 bit-identical」**（R②#8），**非** baseline byte-identical（observe_velocity visible 改→randf 時機/次數變→世界軌跡本就該變＝行為改動本意）。
- **憲法**：改位置資料來源，不加判斷器、無新 try_set。

## 驗收法（★中性世界 + 故事 QA）
0. **★Tier1 pursuit-hiding 控制場景（blueprint ② 裁定，旗艦 story 非 organic code-verify 就收）**：measurer 建控制場景床——手構「1 隻 prey 斷視線躲藏（走森林/繞路降 exposure 出視野）+ 1 隻追兵 engage 後」→ 演示**乾淨逃脫**：prey 出視野 → 追兵 belief `last_tick` 停更 → 撲空/去 last-seen 搜、**非精準攔截**。一齣 before/after（Fix F 前=每 tick god-view 精準攔截 vs 後=可撲空）。此床＝「控制場景 story 驗證床」，god-view 首用戶，後續 story-central/稀有 option 復用。
1. **★逃脫故事（headline）**：斷視線+移動的隊，追兵撲空率 > 0（現＝0）。specimen trace：追擊 move 到 last-seen、視野內刷新、斷視線→撲空。**驗真 wire（to_task/movement/`_refresh_attack_pursuit`）改到，非死欄位。**
2. **staleness 解 loop**：駐村隊對「曾現後永離」的敵→threat_react 隨 belief 過期歸零（非永久 loop）。
3. **不誤殺**：自身位置/佔村 outpost tile/徵收 known_member_states 照正確通道；佔村仍打村格（非空地）、徵收仍找到同僚。
4. **fallback 安全**：無 belief 目標→option 不評估/撲空 release，**無隊移向自身座標**。
5. **無回歸**：**同 seed 兩跑 bit-identical**；憲法 sites 不變；HOB obey%；sanity 零新增。
6. **中性世界判**。

## dispatch 註（R② re-confirm CLEAN 後）
- 新分支 `feat/position-belief`。
- **R② re-confirm**（方向已過異質框外審，v2 重定靶+8 缺口是否收斂——真 wire 對、fallback 禁自身、staleness、通道選對、佔村 outpost、has_belief gate 補）。reviewer 定要不要再升異質（傾向標準複核，方向已認同）。
- 完成判定 = systems + reviewer/QA + measurer 中性驗（逃脫故事）。implementer TDD：構「target 斷視線移動」斷言追兵去 last-seen 撲空；「target 過期」斷言 threat 歸零；「無 belief」斷言不移向自身；「佔村」斷言打村格；「徵收」斷言找到同僚。
