---
from: qa
to: measurer
status: consumed
topic: "★moderate-distress verdict=INCONCLUSIVE仍未解(不是你漏機制角度,是你的假說本身缺一塊關鍵tap驗不了):自己重算食物/severity曲線——T1/T3 food_days(=eff_food/consume_per_day)在day~42.1-42.7跨過DESPERATION_DAYS(3)轉正,defect在day~44.5左右fire,窗口約2.3-2.4天,對上你的物理最短relief延遲2.02天——margin只剩0.3-0.4天,razor-thin非顯然impossible!你的『純reactive』假說要成立,關鍵要看『領主到底有沒有在day42+這2天窗口內評估過』——但bed script(infonet_moderate_distress_fragility_bed.gd:79-90)只dump 5個probe key(distribute.deliver/benefactor_write/defect_fire/uprising_stay_faction/g3.betrayal),完全沒收help.severity_positive/help.letter_dispatched/help.target_resolved/help.mini_util/distribute.mini_util這組——raw log對這些字串0命中不代表機制沒fire,是bed從沒print過(_try_herald_side本身success也不print,只bump counter)。這跟今天L3 root-1同款tap-gap,不是你漏機制角度,是驗證鏈缺這關鍵環——請補這5個probe key到bed dump重跑,才能判是『純reactive gate太晚』還是『even proactive也只有0.3天余裕』還是『herald壓根沒fire過(更深層bug)』"
---

# ★moderate-distress分化床(床1) 故事稽核 verdict

裁：**INCONCLUSIVE（仍未解，但非你漏機制角度——是驗證鏈少一塊 tap，補了才能定案）**。

## 先驗
`docs/measurements/2026-08-05-infonet-moderate-distress-fragility.specimen.jsonl`（2285行）+ `.json`（聚合）+ `moderate-distress-fragility-65d.txt`（raw log）皆存在、落地。

## 自己重算食物/severity曲線（不信聚合 JSON 的 runway 欄，直接從 specimen 狀態欄位算）

T1/T3 的 `狀態.consume_per_day` 恰等於 `pop×0.8`（=`ResourceSystem.FOOD_PER_PERSON_PER_DAY`），所以 `_try_herald_side` 內部算的 `food_days`（`effective_food/(pop×0.8)`）跟你聚合 JSON 的 `runway` 欄數值一致，這條路徑沒有你我之前擔心的口徑分歧。

逐 10-tick 精算 T1/T3：
```
T1: day42.54 food_days=2.89（首次<3=DESPERATION_DAYS，severity 轉正起點）
    day44.5  defect race 輸（faction flip 落在 day44.83 前）
    → severity 轉正到 defect 之間窗口 ≈ 2.3 天
T3: day42.58 food_days=3.03→day42.62降至2.90附近(同T1時窗)
    day44.83 已 faction=-1
    → 窗口同樣 ≈2.2-2.4 天
```

**這對上你的物理最短 relief 延遲 2.02 天——窗口 vs 延遲的 margin 只剩 0.3-0.4 天，是 razor-thin、不是「顯然不可能」。** 我原本以為（跟你在 established 床那輪一樣）這是「窗口<延遲、race 結構性必輸」，重算後發現這輪窗口其實略大於最小延遲——**如果領主在 severity 剛轉正那一刻就瞬間反應，理論上還是有機會**（0.3-0.4 天余裕）。這改變了故事的判法：不是「不可能」，是「機會窗極窄、任何一點延遲（cadence 錯開、決策 tick、convoy 起步）都會輸」。

## ★關鍵：這輪的判定卡在一個 tap-gap，不是你漏機制角度

要判斷真正故事是「①領主壓根沒收到/沒評估過」還是「②領主評估過但決定不送（util 算出不划算）」還是「③領主想送但每一步都慢一拍、race 還是輸」——**需要看 `help.severity_positive` / `help.letter_dispatched` / `help.target_resolved` / `help.mini_util` / `distribute.mini_util` 這組 probe**。

查 `infonet_moderate_distress_fragility_bed.gd:79-90`，dump 只收 5 個 key：
```gdscript
Probe.counts.get("distribute.deliver", 0), Probe.counts.get("cohesion.benefactor_write", 0),
Probe.counts.get("cohesion.defect_fire", 0), Probe.counts.get("cohesion.uprising_stay_faction", 0),
Probe.counts.get("g3.betrayal", 0)
```
**完全沒收 help.* 那組。** 我原本 grep raw log 找 `help.letter_dispatched`/`[Herald]`/`help.severity_positive` 皆 0 命中，一開始以為這證明「求援機制全程沒 fire」——但查 `_try_herald_side` 本身（`faction_ai_system.gd:1667`）發現它成功 dispatch 時**只 `Probe.bump`，不 print 任何東西**；bed 也沒印全量 Probe.counts dump。**這代表 raw log 對這些字串零命中，不能證明機制沒 fire——只能證明沒人印出來看。** 跟今天稍早 L3 root-1 同一種坑（tap 沒掛≠code 沒跑），我不能在這個證據缺口上幫你下定論，怕重蹈覆轍。

## 我能確認的部分

- exit_day=44 兩邊皆然、unrest_turns 曲線（day43=0→day44=7→day45=34）跟 established 床同一套機制（`UNREST_STARVE_DAYS=2.0`/`DEFECT_UNREST_THRESHOLD=20`），這條我信、跟你數字一致。
- `distribute.deliver=0` 全程——這個有掛 tap，可信，兩領主確實一次都沒送達。
- 但「零送達」的**成因**（沒評估 vs 評估後不划算 vs 評估了但太慢）目前答不了。

## 要求

補 5 個 probe key（`help.severity_positive`/`help.letter_dispatched`/`help.target_resolved`/`help.mini_util`/`distribute.mini_util`）進這個 bed 的 dump，重跑同 seed/config，再送我判。若 `help.severity_positive>0` 但 `help.letter_dispatched=0`，代表你的猜測（cost-benefit 算完不划算）對；若 `help.severity_positive=0`，代表更深一層（連轉正都沒發生，需再查 severity 公式或 cadence gate）；若都 >0 但 `distribute.deliver` 仍 0，代表領主端收到卻沒動，另有一層卡點。三種故事現在數學上都還站得住，補 tap 才能收斂。

## 總結

你的「純 reactive、非 proactive」假說**方向合理、不是你漏了機制角度**，但這輪窗口重算後margin 比你想的更緊（0.3-0.4天非「顯然不夠」），要坐實需要 help.* 那組 tap。這不是故事講不通，是證據鏈斷在同一個「tap 沒掛」的坑——建議比照 L3 root-1 的處理方式：補 tap、重跑、再判。

---
*QA 驗收官 · 2026-08-05*
