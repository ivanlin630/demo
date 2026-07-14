# Spec：求生執行鎖 thrash-fix（決策模型第一刀·承諾 reach into execution）

status: draft（待 reviewer R② CLEAN → dispatch implementer）
owner: systems
premise_verified: 根因純結構 de-sync，全 file:line 坐實（見下）；R① 免（小 slice、前提已 code 坐實，非新概念大框）
blueprint_intent: `2026-07-14-blueprint-to-systems-thrash-fix-intent.md`（求生 fire→鎖執行到完成，零被動/thrash 餓死）

## 一句話
求生決策 fire 後（如 買糧）本該鎖住執行到買糧單下成，卻被 legacy `_evaluate_survival` **每 tick 重觸打回 idle** → `貿易↔idle` 抖 122 次餓死（Team14 血證）。根因＝求生 recognizer 白名單 `SURVIVAL_TASKS` 漂移，不認自己派的 `TASK_TRADE`(買糧)/`TASK_ATTACK`(掠奪/佔村)。**de-patch＝recognizer 改 priority-based，讓既有 execution-lock 機制生效**（非加新閘）。

---

## 根因（patch-gate-first 診斷，全坐實）

### 誰在跟求生控制器搶 execution
**答：求生控制器搶自己**——legacy `_evaluate_survival` 的「我在不在 survival?」recognizer 過期，導致它不認得自己剛派的求生 task，每 tick 把 in-flight 求生 dispatch 當「沒在求生」重觸、release 掉。

### 結構 de-sync（兩份必須一致的清單漂移）
- **survival 選項→task 映射**（`options.gd`）：`SURVIVAL_OPTION_SET`(:49) 含 `買糧`/`掠奪`/`佔村`；`to_task`(:226/:168-176) 把 `買糧→TASK_TRADE`、`掠奪/佔村→TASK_ATTACK`。
- **survival recognizer 白名單**（`faction_ai_system.gd:80`）：`SURVIVAL_TASKS = [TASK_RETURN_HOME, TASK_BEG, TASK_JOIN, TASK_FORAGE, TASK_CAMP]`——**缺 `TASK_TRADE`（買糧）+ `TASK_ATTACK`（掠奪/佔村）**。
- 覆蓋率：8 個 survival 選項的 task 輸出，白名單只認 5（覓食/乞食/併入/紮營/返家），漏 2 條 task（TASK_TRADE、TASK_ATTACK）。

### thrash 機制（Team14 血證，`docs/measurements/2026-07-14-sliceA-reeval-attribution-branch-67d4a47.log:4242-4425`）
Team14＝**非-unified 子隊**（`parent_team_id != -1`）→ 不在 Slice A Fix1 退役範圍（`:3063 uses_unified or parent==-1 return`），走 legacy `_evaluate_survival` body（每 tick 跑，初觸 :3112 無 cadence gate）：
- tick A：current=idle+餓 → `:3112 _trigger_survival` → `rank_survival` 選 買糧 → `try_set(TASK_TRADE, PRIO_SURVIVAL)`（:3213）→ current=貿易。印 `idle→貿易`。
- tick B：current=貿易 → `:3093 if current_task in SURVIVAL_TASKS` = **FALSE**（貿易/TASK_TRADE 不在白名單）→ **跳過 recover-hysteresis(:3096) + cadence-relatch(:3102) 兩道執行鎖守衛** → 落 :3112 → `_trigger_survival` 又跑 → 未到市集的 in-flight 買糧單被 release → 印 `貿易→idle`。
- ∴ 買糧單永遠在下成前被自己 release → 餓死（days_left 2.7→0，抖 122 次；期間 :4348 urgent 還買 weapon×6＝軍備堆積另一 tuning 面，非本刀）。

### ★關鍵洞察：execution-lock 機制本就存在，被過期 recognizer 擋在門外
`:3096` recover-hysteresis（糧恢復到 RECOVER=7 才釋放）+ `:3102` cadence-gated relatch（`current_tick >= decision_eval_next_tick or crisis` 才重評，非每 tick）＝**「求生 fire 後鎖到完成/週期重評」的執行鎖**。這正是 blueprint 要的「承諾 reach into execution」。它從不對 買糧/掠奪 survival 生效，唯一原因＝recognizer(:3093) 不認 TASK_TRADE/TASK_ATTACK。**de-patch＝修 recognizer，非加新鎖。**

### PRIO_SURVIVAL 是乾淨的 survival marker（fix 前提坐實）
`terms.gd:42` 確認 `PRIO_SURVIVAL=80 > PRIO_THREAT=70 > PRIO_PLAYER=60 > PRIO_DISPATCH=50`。全 codebase **唯一** `try_set(..PRIO_SURVIVAL..)` 在 `:3213`（`_trigger_survival`）→ `task_priority == PRIO_SURVIVAL` ⟺「求生控制器派的 in-flight task」，零歧義、抗未來 survival 選項→task 新增的 drift。

---

## Fix A（root de-patch）：求生 recognizer 改 priority-based

**設計**：加 helper，把「我在不在 survival-in-progress?」的判定從**易漂移的 enum 白名單**改為**enum 白名單 ∪ PRIO_SURVIVAL**：

```gdscript
# faction_ai_system.gd（helper，near SURVIVAL_TASKS :80）
func _in_survival(team: TeamData) -> bool:
    # 白名單認 proactive-camp 等 @PRIO_DISPATCH 的 survival task；PRIO_SURVIVAL 認買糧/掠奪等
    # survival 派但 task enum 也用於非-survival（TASK_TRADE/TASK_ATTACK）的情形。
    # priority-based 主判 → 抗 SURVIVAL_OPTION_SET→to_task 未來新增 task 的 recognizer drift。
    return team.current_task in SURVIVAL_TASKS or team.task_priority == TaskArbiter.PRIO_SURVIVAL
```

三處 recognizer 統一改呼 helper（**行為只對「買糧/掠奪/佔村 survival」變，其餘不變**——它們原本就命中白名單）：
1. **`:3093`（核心·執行鎖入口）**：`if team.current_task in SURVIVAL_TASKS:` → `if _in_survival(team):`
   - 效果：買糧 survival（TASK_TRADE@PRIO_SURVIVAL）next tick 命中 → 走 recover-hysteresis(:3096)+cadence-relatch(:3102) → **HOLD 到 cadence/crisis 或糧恢復**，不再每 tick 重觸 → 買糧單下得成。execution-lock 生效。
   - `proactive_camp` 特判（:3094 TASK_CAMP@PRIO_DISPATCH）不受影響（白名單仍認 TASK_CAMP）。
2. **`:1360`（leader survival-sticky）**：`if leader_team.current_task in SURVIVAL_TASKS:` → `if _in_survival(leader_team):`
   - 修潛在同型 bug：買糧/掠奪 survival 中的 leader 原本不 sticky（會被 :1366+ 主 rank 蓋過）→ 現正確 sticky（不蓋，仍派成員）。
3. **`:3484`（uprising skip）**：**保留窄白名單 `if team.current_task in SURVIVAL_TASKS: return`（不改 `_in_survival`）**。
   - **★scope 修訂（2026-07-14，systems 事後裁定）**：本處**行為中性**——`_evaluate_uprising` 所有副作用都在 `try_set(TASK_REVOLT/HOLD, PRIO_THREAT=70)` 之後（:3502-3508 `if not try_set: return`）；team @PRIO_SURVIVAL(80) 的 uprising try_set @70 **恆被 arbiter 拒**（80>70）→ 早退零副作用。∴ broad `_in_survival`（skip eval）vs narrow（run-then-reject）**行為完全相同**，兩者皆正確。保留 narrow＝維持該處原語意（「全隊一致對外求生 journey」skip 起義），不擴 blast radius。
   - ⚠ **note**：實作 handback（`execlock-redo-fixed`）給的理由「窄化才不掩蓋叛亂訊號」**技術上錯**（叛亂本就被 priority 80>70 擋，窄化不多揭任何叛亂）；正確理由＝上述「行為中性、保留原語意」。且該改動經由**不存在的 systems REDO**（虛構授權，見 provenance note），systems 事後 ratify（因中性無害）非事前授權。

**為何不直接把 TASK_TRADE/TASK_ATTACK 加進 `SURVIVAL_TASKS` 白名單**：TASK_TRADE/TASK_ATTACK 也用於**非-survival**（正常商隊貿易、正常攻擊）——盲加會讓正常貿易/攻擊隊被誤判「在 survival」→ 誤 skip uprising / 誤 sticky / 誤走 hysteresis。priority-based 精準只認 `@PRIO_SURVIVAL` 的 dispatch，正常 task（@PRIO_DISPATCH）不誤傷。

**dual-producer 殘留？**：子隊另有引擎 `_decide_subteam`（:1736 買糧→TASK_TRADE@**PRIO_DISPATCH**，cadence 1日）。Fix A 後：legacy 派 @PRIO_SURVIVAL(80) HOLD → 引擎 @PRIO_DISPATCH(50) try_set 被 arbiter 拒（80>50 no-op）→ **不再互蓋**。若引擎先派買糧@50，legacy 下 tick upgrade 到 @80（單次 benign transition 非 thrash），隨即 HOLD。

## Fix B（觀測·blueprint「順帶收」）：SpecimenTracer 補接子隊決策路徑

**tap-gap 坐實**：`SpecimenTracer.capture_decision` 接了 `_decide_unified`(:1480/:1523)/`_decide_solo`(:1876)/`_trigger_survival`(:3217)，**唯獨 `_decide_subteam`(:1742) 只呼 `HandBrainProbe.capture`、漏 `SpecimenTracer.capture_decision`**。∴ specimen 是子隊（如 Team14）時 SpecimenTracer `decision_count=0`＝**假象**（血證 `2026-07-14-samewrld-team14-deathcause-67d4a47-dirty.log`，死時 coin=47/weapons=3/food=0 卻 decision_count=0），差點誤判「架構絕症」。

**設計（最小·鏡射既有 tap）**：`_decide_subteam` winner commit 處（:1742，`HandBrainProbe.capture` 旁）補一行：
```gdscript
SpecimenTracer.capture_decision(state, sub, opt, td["task"], tgt)   # specimen tap（鏡射 solo/unified，補子隊漏接）
```
- no-op-unless-specimen（非 specimen 零成本，同其餘 tap）。
- 「歸建」lifecycle（:1715-1719）不 tap（比照 solo/unified 對 lifecycle move 不 capture）；「併入」try_join 分支已有 HandBrainProbe 特判，SpecimenTracer 只補標準 try_set winner 這條主路。
- **落地全量暫態可觀測性不變量**（`invariants.md`）首個 dogfood：子隊決策從此可溯，thrash/死因不再假象 0。

---

## 觸及檔
- `faction_ai_system.gd`：Fix A helper `_in_survival` + 三處呼點(:3093/:1360/:3484)改；Fix B `_decide_subteam`(:1742) 補 SpecimenTracer tap。
- **無新 const、無新 option、無新行為、無 data 欄**（純 recognizer 邏輯修正 + 一行 tap）。

## invariant 守
- **決策模型/憲法**：不加行為規則、不加判斷器；Fix A 是修正既有 recognizer 的正確性（讓既有引擎執行鎖生效），非繞過引擎。零新 gate。
- **全量暫態可觀測性**（新不變量）：Fix B 補子隊 tap-gap，正向落地。
- **determinism**：純邏輯判定（priority 讀既有欄）+ tap（no-op），零 randf → byte-identical 保。
- **憲法 site-freeze**：無新增 TaskArbiter mutation 面（改的是讀 task_priority 的判定，非新 try_set）→ gate baseline 不動。

## 驗收法（measurer 標準床 + 全量 specimen dump，seed1337 + 補 seed42/7）
1. **★thrash 歸零（headline）**：Team14 型非-unified 子隊 `貿易↔idle`（含掠奪/佔村 survival 的同型抖）**同 tick 反覆翻轉次數 → 歸零/趨零**；`[Survival] TeamN …→…` 每 tick flip print 消失。量法：`reeval_attribution_bed.gd`/specimen trace 數 `SPECIMEN_TEAM_ID` 的 task-flip/tick。
2. **★買糧單下得成（執行鎖生效）**：餓子隊 fire 買糧後 **HOLD 到抵市集 + 成交**（`[Order] TeamN buy food` 出現），非落空抖死。specimen trace：買糧 dispatch→到達→order 鏈完整。
3. **★故事性（QA 第五職，全量 specimen dump）**：抽 thrash-死 specimen 判 motive→action→outcome——求生**真的持續在做**（跨 tick 持有 survival task 移動中），非落空抖動。`extinct.starve_no_forage` 類「有意求生卻抖死」→ 降。
4. **Fix B tap-gap 收**：`SPECIMEN_TEAM_ID` 設子隊時 `decision_count > 0`（非 0 假象）；子隊每次 `_decide_subteam` winner 進 specimen trace。
5. **不回歸**：determinism byte-identical（純邏輯+tap）；憲法閘綠（sites 不變）；established/attrition 跨 seed **無退化**（本刀治抖不治死亡率，attrition 順帶觀察不強求回 baseline——blueprint line 24）；正常貿易/攻擊隊**未被誤判 survival**（抽驗：@PRIO_DISPATCH 的 TASK_TRADE/TASK_ATTACK 隊 uprising/sticky 行為不變）。
6. **量測附雙數字**（承 slice A reviewer 條件精神）：thrash flip 數 + attrition，防換皮。

## dispatch 註（reviewer R② CLEAN 後）
- 走 **R② 審設計**（真根治 vs 搬問題/退化/違 invariant）；範圍小、無新概念大框 → **R① 免**。
- **框外審評估**：本刀非「強結論 redirect 大工」（單檔 recognizer 修 + 一行 tap，engage 既有機制），非三對齊 → R② 標準審即可，不需升異質框外審。
- task 完成判定 = systems + reviewer，非 implementer 自判。implementer 走 TDD（先寫 thrash 重現 failing test：構餓子隊+可達市集，跑 `_evaluate_survival` 二 tick，斷言 HOLD 貿易@PRIO_SURVIVAL 不 release）。
