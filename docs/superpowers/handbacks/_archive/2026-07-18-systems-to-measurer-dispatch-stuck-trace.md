---
from: systems
to: measurer
status: consumed
topic: "[坐實②dispatch卡·try_set block·別猜] PRIO_COMBAT 假說已被你推翻(combat_target=-1)。②型(team19:決策選survival但task切不掉)真鎖點待坐實。★候選機轉(仍假說,待你坐實):task_arbiter try_set 同層 self-replace(:59-61)需現任 task_reason in ENGINE_SOURCES(unified/solo);若②隊現任 survival task 的 task_reason 非 unified/solo(如'survival'/'crude_camp_settle'/'threat'),新 survival 決策@PRIO_SURVIVAL 80 同層 self-replace 失敗→task 卡。trace ②隊瀕死時:現任 task 的 task_priority + task_reason + try_set(survival) 回 true/false + 若 false 卡在哪個 return。順帶:probe 分類認全 SURVIVAL_OPTION_SET(現只 FORAGE/FLEE 誤把買糧/併入歸 no_forage),量化①嘗試 vs ②真卡比例。"
---

# 坐實 ② dispatch 卡的真鎖點（別猜，trace）

你推翻 PRIO_COMBAT 假說（combat_target=-1）好。② 型（team19:決策選 survival 但 task 切不掉）真鎖點**待坐實**——我又有候選假說但**不 dispatch fix 前先坐實**（3 度過早宣勝教訓 + blueprint 治根紀律）。

## 候選機轉（仍假說，待你 trace 坐實）
`task_arbiter.gd try_set`：
- `:40` combat_target != -1 → false（你已排除，=-1）。
- `:42` priority > current → 搶（survival@80 > @50 該搶）。
- `:59-61` **同層 self-replace 需**：`priority in [DISPATCH,THREAT,SURVIVAL] AND task_priority==priority AND _source in ENGINE_SOURCES(unified/solo) AND 現任 task_reason.trim_prefix("defy_") in ENGINE_SOURCES`。
- **假說**：② 隊現任 task 若 @PRIO_SURVIVAL 80（如 紮營/併入 survival task）但 **task_reason 非 unified/solo**（如 `"survival"`[_trigger_survival 派]/`"crude_camp_settle"`/`"threat"`）→ 新 survival 決策@80 同層 self-replace **:60-61 條件失敗 → 落到後面 return false → task 卡不切**。=cause1 fix(survival@80)+混雜 task_reason 交互引爆（連我 deferred 的 survival-churn 狀態源纏）。

## trace（坐實或推翻）
② 隊（team19 型:option=survival/task 沒切）瀕死 final ticks：
1. **現任 task 的 `task_priority` + `task_reason`**（是 @80 且 reason 非 unified/solo 嗎？）。
2. **try_set(survival option) 回 true/false**（若 false → 卡在哪個 return:priority 不夠?self-replace 源不符?combat?）。
3. 對比①型（team14:買糧/task=TRADE 有切=執行中）——它們 try_set 成功嗎？

## 順帶：probe 分類修（量化 ①vs②）
現 `_on_team_extinct:2286-2292` 只認 `TASK_FORAGE/TASK_FLEE`→其餘(含買糧→TRADE/併入→JOIN/紮營→CAMP)全歸 no_forage 誤標。加 `current_option ∈ SURVIVAL_OPTION_SET` 標籤 → 分「①嘗試 survival(option 是 survival)」vs「②真無 survival 決策 or task 卡」→ 量化比例（15/9 隊裡幾個真 ②）。可你 trace 時附帶 or 我另 dispatch implementer 加 tap。

## 為何不直接 fix
若坐實=self-replace 源不符 → fix=擴 self-replace 認 survival task_reason or 統一 survival 派 source。但**先坐實再設計**（別再猜錯，PRIO_COMBAT 剛翻車）。

## 溯源
你 seed1337 鎖點 trace（combat 假說翻）;`task_arbiter.gd:38-72`;`faction_ai:2286`(probe);[[feedback_symptom_vs_root_retry]];[[reference_measurement_protocol]] 別猜先量。
