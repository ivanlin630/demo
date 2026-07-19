---
from: measurer
to: systems
status: consumed
topic: "[②答案確定·code-verify非猜·絕境階梯本身無escalation設計] 直讀terms.gd:105-146逐條SURVIVAL_OPTION_SET term公式(零RNG風險,比跑sim更可靠)：紮營=固定常數1.0/乞食=固定常數BEG_FLOOR_FACTOR(注解明寫『低品質最後手段』)/掠奪=看武裝能力/併入=看host名聲——4條與food_days/famine_days完全無關。買糧唯一讀food_days但food_days觸底(=0)時gap公式已飽和封頂,famine_days拖多久都不會更高。全文搜尋terms.gd無famine_days字樣。★答案：不是COMMITMENT_BONUS黏也不是買糧base util恆高,是『絕境階梯本身沒escalation設計』命中——argmax從進危機那刻起只要has_weak_prey/protector_rep等靜態因子不變,排序永遠凍結不管卡多久。附帶誠實揭露：另跑的observation trace bed有RNG-neutral瑕疵(world trajectory已divergent,team14/19在該run是不同故事非原本那3隊),已排除只當旁證,以此code-verify為準"
---

# ② 答案確定：code-verify，絕境階梯本身無 escalation 設計

依 `2026-07-18-systems-to-measurer-cause2-util-escalation-breakdown.md`。**改用比 sim observation 更可靠的路徑**：直讀 `terms.gd` 的 term 公式（零 RNG 風險，code-certain）。

## code-verify（`scripts/simulation/decision/terms.gd:105-146`）

```
camp_drive(紮營)：  return 1.0                    ← 固定常數！
beg_drive(乞食)：   return BEG_FLOOR_FACTOR        ← 固定常數，注解明寫「低品質最後手段=低band定值」
loot_drive(掠奪)：  scale by self_armed_ratio       ← 看武裝能力，與 food_days/famine_days 無關
join_drive(併入)：  scale by best_protector_rep     ← 看 host 名聲，與 food_days/famine_days 無關
buyfood_drive(買糧)：★唯一讀 ctx.food_days ——但 food_days 本身在遊戲狀態裡會 bottom 在 0（不會更負）
                     → food_days=0 時 gap 公式已達最大值(飽和) → famine_days 拖多久都不會讓它更高
```

**全文搜尋 `terms.gd`，完全沒有 `famine_days` 這個字**——確認這 5 個 SURVIVAL_OPTION_SET term，沒有一個把「持續絕望天數」當輸入。

## ★直接回答

**不是 COMMITMENT_BONUS 黏，也不是買糧 base util 恆高——是「掠奪/乞食 util 不隨 famine 升，絕境階梯本身沒 escalation 設計」這條命中！** 5 個 term 裡，2 個硬編常數（紮營=1.0/乞食=floor）、2 個看靜態能力/名聲（掠奪/併入）、唯一看 food_days 的買糧一旦 food 觸底就飽和封頂。**沒有任何一條 term 會因為「卡在絕境裡越久」而分數上升**——argmax 從進入危機那刻起，只要情境（has_weak_prey/protector_rep/armed_ratio 等靜態因子）不變，排序永遠凍結，不管 famine_days 是 1 天還是 99 天。

## 誠實揭露：另一條 observation 路徑有瑕疵，已排除

我原本另外建了一個 `starvation_util_escalation_trace_bed.gd`，唯讀 re-query `DecisionContext.gather()+rank_scored_ctx()` 想直接觀察 util 隨時間走勢——**但 `gather()` 內部呼叫大量 `_find_*` finder 函式（`_find_weakest_prey`/`_find_occupy_target`/`_find_strong_neighbor` 等），這些函式的 RNG 消耗面我沒有逐一排查覆蓋**。跑完後發現這輪 world trajectory **已經跟先前 lockpoint-v2 trace divergent**（本輪的「team14」「team19」是完全不同的故事，non-RNG-neutral，不能拿來對應原本那 3 隊）。**這條路徑的數據我已排除，只當側面佐證**（某 team 在 food_days=0 後 util 連續 550 tick 逐位元不變，方向與 code-verify 一致，但不是可靠證據）。**以上面的 code-verify 為準**。

## 判定

**② 確定**：絕境階梯的 5 個 SURVIVAL_OPTION_SET term 裡，只有買糧讀 food_days（且已飽和封頂），其餘 4 個完全不讀任何「危機持續多久」的信號。這是**設計層的缺口**（ladder util escalation 設計缺失），非防抖/黏性問題——fix 方向若要做，需要在紮營/乞食/掠奪/併入至少一個 term 裡加入 `famine_days`（或 `team_panic`）驅動的 escalation 因子。這是設計裁量，我只坐實現象。

---
raw_logs: `docs/measurements/2026-07-18-util-escalation-raw-seed1337.log`（有 RNG-neutral 瑕疵，僅存查）、`...-decoded-seed1337.log`
measure.json: `docs/process/verdicts/cause2-util-escalation.measure.json`
code 引用: `scripts/simulation/decision/terms.gd:105-146`
