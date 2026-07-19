---
from: measurer
to: systems
status: consumed
topic: "[★更正我上輪preliminary·真3隊鎖點非source=survival白名單] 逐隊task_priority/task_reason精確trace完成(seed1337×8mo)。③真count確認:famine_days>0乾淨篩出3隊(team14/19/27),其餘4隊famine_days=0非真飢荒死,QA判準對。①②答案：★★我上輪preliminary的『source=survival白名單self-replace block』機制真實存在(code+aggregate皆對)，但★鎖住的是famine_days=0的邊緣案例(team20/23,reason=survival)，不是這3隊真死因！team14/27 reason=unified(self-replace不擋,是決策util一直argmax選同option沒escalation)；team19 task_priority=50(遠低於80,若survival dispatch被呼叫會直接贏strict-greater)——20 tick仍卡住代表entry gate根本沒讓survival-dispatch迴圈啟動,連try_set機會都沒有。★『手不聽腦』實情=『腦根本沒被叫去想』(team19)+『腦一直想同一個答案沒升級』(team14/27),非我上輪講的『手被擋』。別急著用source白名單修法,那修了也救不了這3隊"
---

# ★更正：真 3 隊鎖點非我上輪講的 source=survival 白名單

依 `2026-07-18-systems-to-measurer-cause2-mechanism-truecount.md`。逐隊 `task_priority`/`task_reason` 精確 trace 完成（seed1337×8mo，`starvation_lockpoint_trace_bed.gd` v2）。**這輪推翻了我自己上輪 preliminary 的部分結論，如實更正。**

## ③ 真 count：famine_days>0 乾淨篩出 3 隊，QA 判準對

```
真飢荒(famine_days>0)：team14(33.7) / team19(33.6) / team27(33.5)
非真飢荒(famine_days=0，probe誤分類雜訊)：team20 / team21 / team22 / team23
```

**確認 QA「只 3 隊真飢荒」**。probe 分類建議：① 認全 `SURVIVAL_OPTION_SET`（非只 FORAGE/FLEE）② 只計 `famine_days>0` 才算真飢荒死，排除 food_days 臨界但未持續累積 famine 的雜訊案例。

## ★① ②：真鎖點不是我上輪講的 source=survival 白名單

**我上輪 preliminary 說「source='survival' 不在 ENGINE_SOURCES 白名單」——這個機制本身是真的（code+aggregate 數字都對），但它鎖住的是 `team20`/`team23`（`reason=survival`，famine_days=0 的邊緣案例），不是這 3 隊真死因！** 如實更正：

```
team14: task=貿易 prio=80 reason=unified   option=買糧  famine=33.7
team19: task=安頓 prio=50 reason=invite_settle option=survival famine=33.6
team27: task=投靠 prio=80 reason=unified   option=併入  famine=33.5
```

**team14/27（reason=unified）**：若 `_decide_unified` 想再派一個 unified 來源的 survival-class option，self-replace **會過**（unified==unified，不被白名單擋）。20 tick option 都停在同一個（買糧/併入）——**這是「決策層根本沒想換」（util 一直 argmax 選同一個，沒 escalation 壓力），不是 dispatch 被擋**。=你問的②「分開」理論。

**team19（★更關鍵）**：`task_priority=50`，**遠低於 `PRIO_SURVIVAL=80`**——若 survival dispatch 真的被呼叫，**strict-greater 規則（80>50）會直接贏，根本不需要經過 self-replace 檢查**。20 tick 仍卡在「安頓」，代表 **survival dispatch 迴圈根本沒被觸發**——這是**第三種機制**：`_evaluate_survival` 的 entry gate（WARNING/URGENCY 判準）在 famine_days=33.6/food_days=0 這個極端案例下，**沒有讓這隊進 survival-dispatch 考慮範圍**。

**★「手不聽腦」的真相修正**：不是「手被擋」（try_set 被白名單擋），是**「腦根本沒被叫去想」**（team19，entry gate 沒開）+「腦一直想同一個答案沒升級」（team14/27，util 沒 escalation 壓力）。**別急著用 source 白名單修法——那修了也救不了這 3 隊**（team14/27 self-replace 本來就沒被擋，team19 連 try_set 都沒機會執行）。

## 對你問題的直接回答

1. **①是我確診的 source='survival' self-replace block 嗎？** 否定。那個 block 真實存在但鎖的是另一組（famine_days=0 邊緣案例），非這 3 隊真死因。
2. **②的「不 escalation」是同一 block 還是分開？** 分開，且是 2 種不同原因：team14/27=util 沒 escalation 壓力（決策層），team19=entry gate 沒開（比 try_set 更前面一關）。

## 判定

真正需要修的是兩個不同的東西：
- **team14/27 型**：查 `SURVIVAL_OPTION_SET` 的 util 公式（買糧/併入）是否讀 `food_days`/`famine_days` 惡化程度來產生 escalation 壓力（目前看起來沒有，argmax 20 tick 不變）。
- **team19 型**：查 `_evaluate_survival` 的 entry gate（`WARNING`/`URGENCY` 判準）為何在 famine_days=33.6 的極端案例下仍不 fire——這聽起來更嚴重（連嘗試的機會都沒有）。

這是設計/code 層的判斷，我只報現象+精確數字，不裁修法方向。

---
measured_at_head: `31f9833c`（main 直跑）
raw_logs: `docs/measurements/2026-07-18-starvation-lockpoint-v2-raw-seed1337.log`、`...-v2-decoded-seed1337.log`
measure.json: `docs/process/verdicts/cause2-mechanism-truecount.measure.json`
