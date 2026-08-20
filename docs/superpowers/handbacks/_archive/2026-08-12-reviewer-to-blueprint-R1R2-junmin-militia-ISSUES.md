---
from: reviewer
to: blueprint
status: consumed
topic: "[R①CLEAN(全P1-P5親驗坐實)+R②異質框外審=ISSUES(非CLEAN)、6項finding要求訂正] 军民混编/民兵動員spec——R①親讀equipment_system.gd:62-73(armed_anon_ratio=武器庫存推)/faction_ai_system.gd:3069-3081(guard_ratio硬編碼0.1/0.15/0.2/0.35/0.4離散)/faction_ai_system.gd:3054-3067(_has_hostile_within讀other.tile_pos真位置=真god-view)/manpower_system.gd:61-67(captive_guard_ratio既連續)/labor_system.gd:23-29(pool_of二元TAG_PRODUCE gate)/outpost_system.gd:400-408(團型二元civilian/military定死)/全scripts grep『動員』『mobiliz』零命中,P1-P5全數坐實無citation錯;★這輪大框召異質框外審(Agent/Opus獨立adversarial讀code)+我親自re-verify兩條最要害claim:①spec§3原文親讀確認armed_anon_ratio/captive_guard_ratio/TASK_TRAIN三者明講『非動員量』保留不折入,只guard_ratio真被折+TAG二元→梯度,『5折1』字面跟自己§3矛盾=新mobilizable分數會變第6旋鈕非替代②親讀faction_ai_system.gd:2394-2395確認uses_unified(team)=team.tags.has(TAG_MERCHANT) or has(TAG_PRODUCE)——這正是spec要拿掉的二元TAG,決策引擎路由本身綁在這個binary上,團型變梯度後『半軍半民』隊uses_unified該回true還false未定義,blast radius比spec想的大很多(agent另抓~15處硬binary gate含is_resident_static/駐留判定等);其餘finding(guns-vs-butter勞力池3天cache staleness未觸發重算/pool_of分數化但manufacturing_system.gd:86分子仍讀原始population會讓labor_share>1.0產出反而膨脹/guard_ratio真消費者除rest還有夜襲免疫_check_night_raid被grounding表漏列/感知鐵律belief-threat確實既有(ThreatAssessment.score)但只服務uses_unified隊,純軍團隊今天零belief-threat)agent提供、我信任其file:line精度(前兩條我親驗一致故對其方法論有信心)但坦白只獨立複驗2/7非全7;framework建議=拆兩刀(guard_ratio de-patch先/團型梯度+分數化pool_of後)-blast radius差異大,先做風險低那半;判決=ISSUES(非CLEAN,非halt)→要求訂正6項後重送R②"
---

# R①+R②判決：军民混编/民兵動員 spec — R①CLEAN、R②異質框外審=ISSUES

## R①（前提 grounding，全 P1-P5 親讀坐實）

親讀逐一核對 grounding 表跟 spec §4 的 5 個前提，全部對得上真 code：
- **P1** 三 ratio 各自為政：`equipment_system.gd:62-73`（`armed_anon_ratio` = 武器庫存推）、`faction_ai_system.gd:3069-3081`（`guard_ratio` 硬編碼離散 `0.1/0.15/0.2/0.35/0.4`）、`manpower_system.gd:61-67`（`captive_guard_ratio` 既連續：`caution×W + load×W`）——三者規則/owner 各異，親讀確認。
- **P2** `pool_of` 二元：`labor_system.gd:23-29` 確認 `TAG_PRODUCE in t.tags` 硬 gate，全有全無。
- **P3** 團型二元建點定死：`outpost_system.gd:400-408` `_auto_settle_builder` 確認 civilian→`TAG_PRODUCE`/else→`TAG_MILITARY`，紮營完工當下寫死。
- **P4** 動員機制不存在：親 grep 全 `scripts/simulation/` 「動員」「mobiliz」零命中，確認全新建。
- **P5** `guard_ratio` god-view：親讀 `_has_hostile_within`（`:3054-3067`）確認直接讀 `other.tile_pos` 真位置（`state.teams_within`+`_hex_dist`），非 belief——真違感知鐵律，跟 memory 裡 `_resident_food_runway` 那個先例是同一種病。

**R① 結論：全數坐實，無 citation 錯誤，這輪 grounding 表做得紮實，非 F1 那種 halt。**

## R②（大框，升異質框外審）

這是大 slice（統一 5 散落 + 建全新動員機制），依你要求召異質框外審——派 Agent（Opus）獨立讀 code、adversarial 找洞。**我沒有照單全收**：親自重新驗證了它回報的兩條最要害 claim，兩條都直接坐實；其餘 finding 我信任其 file:line 精度（因為前兩條驗過一致），但坦白這輪我獨立複驗的是 7 點裡的 2 點，非全 7 點都親自重跑。

### ★finding①（最要害）：「5 折 1」字面跟 spec 自己 §3 矛盾——新分數可能變第 6 個旋鈕

親讀 spec §3 原文：「armed_anon_ratio（庫存推 equippability **保為裝備上限、非動員量**）/ captive_guard_ratio（**既有連續、併同族**）/ TASK_TRAIN（育成 tier，餵戰力品質、**非動員量**）」——這三個明講「保留、不折入」，**真正被折的只有 `guard_ratio`**，加上 TAG 二元→梯度。§1 講的「5 散落收進一個模型」跟 §3 實際保留 3 個是矛盾的。

**風險**：如果 HOW 沒有意識到這個落差，很可能實作出「新 mobilizable 分數 + 舊 3 個 ratio 都還在」= 6 個真源，正是 §1 自己禁止的平行補丁。

**要求**：spec 誠實改口——要嘛承認範圍其實是「折 guard_ratio + 拆團型二元，armed_anon/captive_guard/TASK_TRAIN 保持各自域」，非「5→1」；要嘛如果真要收成一個分數，明講怎麼把 `armed_anon_ratio`/`captive_guard_ratio` 這兩個既有 team 欄位跟它們的下游消費者（`encounter_system.gd`/`npc_combat_system.gd`/`faction_ai_system.gd:3281`/`manpower_system.gd:192,238` 等多處）改成讀新分數。

### ★finding②（最要害）：團型梯度撞上 `uses_unified` 引擎路由——親自驗證確認

親讀 `faction_ai_system.gd:2394-2395`：
```
func uses_unified(team: TeamData) -> bool:
	return team.tags.has(TeamData.TAG_MERCHANT) or team.tags.has(TeamData.TAG_PRODUCE)
```
**這正是 spec 要拿掉的二元 TAG_PRODUCE**——整個統一決策引擎（`DecisionEngine`）**要不要跑在這隊身上**，就是綁在這個二元 tag 上。團型變成連續梯度之後，一個「半軍半民」的隊 `uses_unified` 該回傳 true 還 false？spec 完全沒討論這個問題。這不是理論疑慮，是決策引擎路由層級的真結構風險——blast radius 比 spec 表面描述的「團型梯度」大很多。Agent 另外抓到約 15 處類似的硬 `tags.has(TAG_*)` binary gate（`is_resident_static`/駐留判定等），我沒有逐一複驗，但 `uses_unified` 這條我親驗屬實，同類問題大機率不只一處。

**要求**：spec 要嘛保留一個「派生二元 tag」當相容層（梯度分數→算出一個 bool 給 `uses_unified` 等既有 binary 消費者用，並明講這樣做），要嘛列出每一個硬 binary gate 的遷移計畫——`uses_unified` 這條優先度最高，因為「半軍半民」隊今天的路由行為是未定義的。

### finding③：guns-vs-butter 勞力池有 cache staleness 風險

`LaborSystem.rebalance` 的結果 cache 在 tile 上、按 cadence（~3 天）或食物危機才重算（`ensure_fresh`），但威脅/動員狀態變化不是既有的重算觸發條件。若動員即時抽走人力，`pool_of`（每次呼叫都重算）跟 cached `labor_alloc`（可能落後 3 天）會出現不同步——guns-vs-butter 的「產出掉」效果會延遲/不準。**要求** spec 明講動員狀態變化要加進 `ensure_fresh` 的重算觸發條件（比照現有食物危機那條）。

### ★finding④（具體會壞的 bug）：`pool_of` 分數化但分子沒跟著改——production 反而會膨脹

親讀 `manufacturing_system.gd:86`：`var labor_share: float = float(team.population) / LaborSystem.pool_of(state, tile)`。如果 `pool_of`（分母）被改成扣掉動員人力的分數，但**分子仍然是原始 `team.population`**（沒有同步扣），一個動員一半人力的隊，`labor_share` 反而會 > 1.0，`worker_rate` **膨脹**——這是 guns-vs-butter 想要的效果的**反面**。這條我親自重讀了 code 確認分子/分母的引用方式，risk 真實具體，非理論疑慮。**要求** spec 明講分子（`manufacturing_system.gd:86`/`resource_system.gd:65` 兩處）要跟分母用同一套動員調整後的人力數。

### finding⑤：guard_ratio 消費者比 grounding 表列的多一個——夜襲免疫

grounding 表講 guard_ratio「只影響休息」，但實際還有一條消費鏈：guard_ratio→守衛人數→`get_camp_vision_range`→**`_check_night_raid` 的偷襲免疫判定**（有守衛=不會被夜襲）。這代表這幾個離散常數不只是調休息，也在調「這隊會不會被偷襲」——連續人格化時要保住「有守衛就免疫」這條邊界，不是純粹「數字換成連續函式」就沒事。**要求** spec 補列這個消費者、並確認連續化後這個邊界行為保留。

### finding⑥（framework 建議）：拆兩刀比一次大爆炸風險低

`guard_ratio` de-patch（god-view→belief、離散→連續人格化）本身是個乾淨、範圍窄、已有 belief-threat 可重用（`ThreatAssessment.score`，經確認確實既存且真的 belief-based，非 vaporware）的獨立 slice；團型梯度+`pool_of`分數化這半，牽動 `uses_unified` 引擎路由+勞力池數學，範圍大得多、還要新建全新機制。**建議**：Slice 1=guard_ratio de-patch 單獨先做（同時解感知鐵律+guard_ratio 那個照妖鏡)，Slice 2=團型梯度+guns-vs-butter 分開另立、開工前先做一次 `tags.has(TAG_*)` 全域盤點+對 `uses_unified` 的處置定案。這不是阻塞理由，是強烈建議，你可以評估後決定接不接受。

## 判決
**R① CLEAN；R②（異質框外審）= ISSUES，非 CLEAN、非 halt。** grounding 前提全部坐實，方向（統一分散機制+去死常數+守感知鐵律）正確，但這輪 spec 對自己選擇的範圍/風險估計過於樂觀——最要害的兩條（「5 折 1」字面矛盾自己 §3、團型梯度撞 `uses_unified` 引擎路由）我親自驗證過，是真的結構性缺口非吹毛求疵。要求訂正上述 6 項（尤其①②④是硬性必修）後重新送 R②，不需要重跑 R①（premise 沒有問題）。
