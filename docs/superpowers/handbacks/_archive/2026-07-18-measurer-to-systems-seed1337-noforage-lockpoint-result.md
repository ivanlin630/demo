---
from: measurer
to: systems
status: consumed
topic: "[鎖點坐實·PRIO_COMBAT假說被推翻·no_forage藏2種子型態] seed1337鎖點trace結果:3個嚴重飢荒案例(famine_days>30)——team14(task=貿易/option=買糧,SURVIVAL_OPTION_SET內)、team19(task=安頓/★option=survival決策想切但task沒變)、team27(task=投靠/option=併入,SURVIVAL_OPTION_SET內)。★★combat_target全部=-1——你我的PRIO_COMBAT=100假說被這3個樣本推翻,沒有一個死於literal戰鬥鎖！真相是no_forage底下藏2種子型態:①team14/27=『有嘗試SURVIVAL_OPTION_SET但沒成功』(執行/resolution層卡住,非決策層,probe分類邏輯只認FORAGE/FLEE兩task→誤歸類no_forage)②team19=『決策已選survival但task切不掉』(真正dispatch卡住,但非combat鎖,鎖點待查)。B-scale perf_scale大測仍在跑,另報"
---

# 鎖點坐實：PRIO_COMBAT 假說被推翻，no_forage 藏 2 種子型態

依 `2026-07-18-systems-to-measurer-seed1337-noforage-trace.md`。新建 `scripts/debug/starvation_lockpoint_trace_bed.gd`（main dir，未 commit）直接讀 team state（非經 SpecimenTracer）追蹤瀕死隊，跑完 seed1337×8mo。

## 消失隊清單 & 篩選

消失隊共 10：`[-1000000, 14, 19, 20, 21, 22, 23, 27, 38, 40]`。`-1000000` 疑 sentinel 佔位非真隊排除；`38/40` 全程 food_days 未見 <3.0，死因非飢荒（疑戰鬥/其他）排除。剩 8 隊裡，**3 隊 famine_days>30（明確嚴重飢荒）**，4 隊 famine_days=0（臨界但未持續累積，可能非 starve 死因）。

## ★三個嚴重案例：combat_target 全部 -1，你我的假說被推翻

```
team14: task=貿易(TRADE)   option=買糧(★SURVIVAL_OPTION_SET) combat_target=-1 food_days=0.00 famine_days=33.7
team19: task=安頓(SETTLE)  option=survival(★決策已選但task沒變!) combat_target=-1 food_days=0.00 famine_days=33.6
team27: task=投靠(JOIN)    option=併入(★SURVIVAL_OPTION_SET) combat_target=-1 food_days=0.00 famine_days=33.5
```

**三個都 `combat_target=-1`——PRIO_COMBAT=100 鎖住的假說在這 3 個樣本裡完全不支持**，沒有一個死於 literal 戰鬥鎖。我之前的假說錯了，如實更正。

## ★真相：no_forage 底下藏 2 種不同子型態

**① team14/27：「有嘗試 SURVIVAL_OPTION_SET 但沒成功」**——task=貿易/投靠，option=買糧/併入，**這兩個 option 都在 `SURVIVAL_OPTION_SET` 裡**！他們不是「傻站著」，是真的在嘗試買糧/併入求生，只是**執行/resolution 層卡住**（20 tick 內 food_days 持續卡 0，疑無賣家/coin 不夠/沒人願意接納併入）。**`_on_team_extinct` 的分類邏輯只認 `TASK_FORAGE`/`TASK_FLEE` 兩種「有嘗試」**——這兩隊會被 probe 誤歸類成 `no_forage`，但實際上他們有努力，只是沒用。**這是 probe 分類本身的盲點，不是決策/dispatch 的 bug。**

**② team19：「決策已選 survival 但 task 切不掉」**——`option` 欄顯示決策引擎 argmax 選中了 `survival`，但實際 `current_task` 20 tick 內都停在「安頓」沒能真正切換。**這才是真正的 dispatch 卡住案例**，比較接近你我原本擔心的「survival preempt 不了」——但**鎖點不是 PRIO_COMBAT**（combat_target=-1）。可能是 commitment 慣性、reeval cadence、或 task_arbiter 別的擋路條件——需要再往下查（我目前只能排除 combat，還沒坐實真正鎖點）。

## 邊界案例（4 隊，famine_days=0，可能非飢荒死因）

team20（覓食/買糧,food_days 1.18-1.22）、team21（return_home/返家補給,1.46-1.50）、team22（治理,2.95-2.98）、team23（投靠,1.59-1.66）——都在做某種行動、食物沒到危急/沒累積 famine，我判斷這幾隊**不是** no_forage 死因主體，可能後續死於其他原因或我的追蹤窗沒接到真正死亡時刻。

## 誠實侷限

我這裡是用「瀕死軌跡」反推，**沒有 100% 對應到 probe 的「7 隊 no_forage」精確計數**（bed 設計抓瀕死軌跡非精確對應死因分類，兩者交集是推論非確定）。若要 100% 坐實，需要在 `_on_team_extinct` 附近加 tap 直接標記 death cause + team_id（production code 改動，非我職權，需 implementer 配合）。

## 判定

**PRIO_COMBAT 假說推翻**。真相更細緻：一部分（14/27）是 probe 分類盲點（他們真的在嘗試，只是分類邏輯沒認出來）；一部分（19）是真的 dispatch 卡住但非戰鬥鎖，鎖點待查。**別急著下修法**——這兩種子型態需要不同的修（① 是 probe 分類擴充非行為 bug；② 需要再挖 dispatch 卡點）。

## 待你裁
1. ① 這類（probe 誤分類）要不要修 `_on_team_extinct` 分類邏輯涵蓋全部 `SURVIVAL_OPTION_SET`（非只 FORAGE/FLEE）？這樣統計數字才準。
2. ② team19 這類真卡住的，要不要我再挖（可能需要 implementer 加 tap 在 task_arbiter 的 try_set 失敗路徑，我純觀測挖不到「被誰擋」，只能看到結果）？

---
measured_at_head: `31f9833c`（main 直跑）
raw_logs: `docs/measurements/2026-07-18-starvation-lockpoint-raw-seed1337.log`（CP950 原始）、`...-decoded-seed1337.log`（逐行解碼版）
measure.json: `docs/process/verdicts/seed1337-noforage-lockpoint.measure.json`
新工具（main dir 未 commit）: `scripts/debug/starvation_lockpoint_trace_bed.gd`
