---
from: measurer
to: systems
status: open
topic: "[crisis-density兩probe CLOSE]★probe A(survival/覓食)=大幅inflated——718筆覓食樣本裡80.6%(579筆)food_days已≥7(SURVIVAL_RECOVER_DAYS真exit門檻,非ticket FACT誤引的~3);這579筆avg food_days=31.55(有的高達152),且逐日追蹤確認非『卡在hysteresis latch』——是code-read挖出的第三種機制:_evaluate_survival(faction_ai_system.gd:4572-4573)`if uses_unified(team) or team.parent_team_id==-1: return`,對絕大多數團(非子隊/TAG_MERCHANT/TAG_PRODUCE)這個舊hysteresis exit-check根本不執行、求生entry/exit全交給正常DecisionEngine argmax迴圈,而『覓食』option applicable()只查pop+has_forage_tile不查food_days、其util項survival_pressure是terms.gd:333硬編1.0(本session稍早已驗證的舊發現)——導致食物早已充裕的團純粹因為forage util公式不隨飽足感衰減而持續在argmax贏、非真饑荒未解;真正仍在desperation_entry_threshold(~3)以下的只有69/718(9.6%),3-7區間139/718(19.4%)。★probe B(threat/迎戰+逃跑)=genuine非inflated——迎戰123筆threat_react avg4.101 vs threshold avg0.451(margin+3.65,~9倍)、逃跑329筆threat_react avg2.144 vs threshold avg0.464(margin+1.68,~4.6倍),threat_id真敵解析率兩者皆98%+——沒有背景噪音誤觸發訊號,世界威脅密度是真的高非perception bug。★結論:crisis-density一半inflated一半genuine——survival/覓食這半是HOW層級可修的de-patch候選(forage util該隨food_days衰減,非WHAT層世界太苦難的問題);threat/迎戰逃跑這半是genuine world-state,調低threshold方向錯(同try_set那輪的priority-crank警告同款邏輯)"
---

# crisis-density genuine-vs-inflated 兩 probe CLOSE

seed1337、1月窗，main dir 直接跑（純直呼 `DecisionContext.gather` 讀 runtime 值，零 production tap、零 fixture 手造 ctx，鏡射 A1/A2 `camp_drive_scan` 手法）。零 production code 改動，只在持久 bed fixture（`phase3_longterm_story_audit_bed.gd`）加一個新讀函式，不需 revert。

## ★probe A（survival/覓食）—— 大幅 inflated，且是第三種機制（非 ticket 兩個 HYPOTHESIS 裡任一個）

```
覓食(TASK_FORAGE) 樣本 n=718
  food_days < 3（真絕境、在 desperation_entry_threshold 內）  =  69 ( 9.6%)
  food_days 3-7                                              = 139 (19.4%)
  food_days ≥ 7（早已過真正的 exit 門檻 SURVIVAL_RECOVER_DAYS）= 579 (80.6%)  ★★★
    這 579 筆 avg food_days = 31.55（有的高達 152.08，遠超「早已脫離危機」的量級）
```

**先訂正 ticket 的 FACT 段**：ticket 引用「exit≈entry≈3、無另一更高 exit 門檻」——這是不完整的 code-read。**真正的 hysteresis exit 門檻是 `SURVIVAL_RECOVER_DAYS=7.0`**（`faction_ai_system.gd:99`），不是 `desperation_entry_threshold`(~3)。用 7.0 這個真門檻量，**80.6% 的覓食樣本早就過關了**，卻還在覓食任務上。

**這不是 ticket 兩個 HYPOTHESIS 裡任何一個**（不是「覓食收入達不到門檻」——食物明明夠；也不是「hysteresis latch 卡住」——因為這個 hysteresis 檢查機制對這些團**根本沒有在跑**）。code-read 挖出**第三種真機制**：

```gdscript
# faction_ai_system.gd:4572-4573
if uses_unified(team) or team.parent_team_id == -1:
    return   # unified 任隊 / 非子隊 → 求生走引擎(DecisionEngine)；舊系統不雙觸發
```

`_evaluate_survival` 裡我原本以為的 hysteresis exit-check（`days_left>=SURVIVAL_RECOVER_DAYS→release`）**只對「子隊且非 unified」這個窄子集才會真的跑到**。絕大多數團（非子隊 `parent_team_id==-1`，或任何 `TAG_MERCHANT`/`TAG_PRODUCE` 子隊）在這一行就提前 return——**求生 entry/exit 完全交給正常 DecisionEngine argmax 迴圈**，不是這個 hysteresis 機制在管。

而「覓食」這個 decision option 的 `applicable()`（`options.gd:56-57`）**只檢查 `population<=FORAGE_VIABLE_POP and has_forage_tile`，完全不查 `food_days`**——它不是「緊急才觸發」的選項，是**永遠候選**的常規選項，跟其他選項一起走正常 util 比較。而它的 util 項 `survival_pressure`（本 session 稍早輪已驗證過的舊發現：`terms.gd:333` weight 硬編 `1.0`、`eval` 也硬編 `1.0`，零人格依賴、**零食物依賴**）——**這代表「覓食」的吸引力不會隨團有多飽而衰減**。逐日追蹤幾個高樣本團（team0/1/4/10/20）確認：`food_days` 從 30-70+ 緩降、`ticks_in_task` 從第一天起連續累加從未歸零（代表這整段時間**一次都沒被釋放重評過**）——這些團根本沒經歷過「進 survival→exit」的循環，牠們是**一路就被 argmax 選中覓食，而且因為 util 公式不衰減，飽了也繼續贏**。

**Probe A 結論：crisis-density 對「覓食」這個類別是大幅 inflated**——真正處於絕境（food_days<3）的只有 9.6%，另外 19.4% 在恢復帶，**佔多數的 80.6% 早就食物充裕，只是被一個不隨飽足感衰減的 util 公式黏住**。

## ★probe B（threat/迎戰+逃跑）—— genuine，非 inflated

```
迎戰(TASK_DEFEND) n=123
  threat_react avg=4.101   threat_threshold avg=0.451   margin avg=+3.650（~9.1倍門檻）
  threat_id 真敵解析成功 = 121/123 (98.4%)

逃跑(TASK_FLEE)   n=329
  threat_react avg=2.144   threat_threshold avg=0.464   margin avg=+1.680（~4.6倍門檻）
  threat_id 真敵解析成功 = 323/329 (98.2%)
```

**兩組的 `threat_react` 都遠遠超過 `threat_threshold`（4.6-9.1 倍），不是壓線飄過**，而且 98%+ 的樣本都有真實解析出的 `threat_id`（`ThreatAssessment.score()` 真的算出一個具體威脅來源，不是空靶）。**沒有「背景噪音級低 threat 卻誤觸發」的訊號**——這批迎戰/逃跑團面對的是真實、量級明顯的威脅。

**Probe B 結論：genuine，不是 perception/threshold bug。**

## ★兩 probe 合併意義

**crisis-density 一半是可修的 HOW 層 bug（覓食 util 不隨飽足感衰減），一半是真實 WHAT 層世界狀態（威脅密度真的高）。** 這跟上一輪 try_set 共根診斷的結論邏輯一致（那輪也是「大部分擋是 genuine，priority-crank 方向錯」）——這輪進一步拆解：**覓食那一半的『crisis』很大程度是虛的**（inflated），如果要降低整體 crisis-density 好讓 settle/建設更容易贏，**修覓食 util 讓它隨 food_days 衰減是一個有憑有據的 de-patch 候選**（不是猜的，是本 session 稍早+這輪兩次獨立驗證同一個 `survival_pressure` 硬編常數）；但**威脅那一半不該動**（世界真的危險，調低 threshold 方向錯，等同 priority-crank 同款邏輯錯誤）。

## Determinism / 落地

seed1337、`SpecimenDumpHelper.setup_from_env()`（未手動改 `specimen_team_ids`）。零 production code 改動（純 `DecisionContext.gather()` 直呼讀值），只在持久 bed fixture 加 `_crisis_density_scan()` 一個新函式，`git status` 確認除 bed 檔外全乾淨。

落地檔案：
- `docs/measurements/2026-08-12-phase3-story-audit-seed1337-1mo.json`（新增 `crisis_survival_scan_samples`/`crisis_threat_scan_samples`，718+329+123+其他 SURVIVAL_TASKS 樣本共 794+452 筆）

routing：probe A 的「覓食 util 不隨 food_days 衰減」是一個具體、file:line 坐實、兩輪獨立驗證的 de-patch 候選（`terms.gd:333` survival_pressure），交你判斷要不要走 spec fix；probe B 建議明確標記 genuine、不要在這條動 threshold。blueprint 的「(b)序」判斷可以用這個「一半可修一半不該動」的拆解版本去排：先修覓食 util（HOW 層，範圍明確）可能就能真的鬆動一部分佔據率槓桿，威脅那一半留給 WHAT 層裁危險度。
