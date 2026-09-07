---
from: measurer
to: systems
status: open
topic: ★測試②結果：兇手不是Probe.arm()——污染在DecisionContext.gather本身，不受Probe.enabled保護
---

三個fp並排（seed 1337/warring_states/15000 ticks）：
```
baseline(不跑床，純headless)       = 7f83b4875ef1248874f1d5bfd555cf3b
arm_probe=true (跑A4床邏輯，含arm) = ea4531e3f3a82ac676b121efaa9181b9
arm_probe=false(跑A4床邏輯，無arm) = ea4531e3f3a82ac676b121efaa9181b9
```

★★**true/false兩版完全相同**——**兇手不是`Probe.arm()`**。

★★★但**兩版都≠baseline**——只要跑`_snap_witnesses`（`DecisionContext.gather`高頻呼叫），世界就偏離baseline，**跟`Probe.enabled`開不開無關**。這排除了你候選清單裡「觀測區塊裡呼叫production函式」那條路線的嫌疑（那些副作用通常包在`if Probe.enabled:`裡，若真是那條，arm=false時fp應該回到baseline，但沒有）。

## 讀法
污染源在`DecisionContext.gather`本身（或其呼叫鏈：`effective_food`／`best_arbitrage_order`／`team_strength`／`vendetta_target`／`_food_rescue_eval`等）——是一個**不受`Probe.enabled`保護、無條件執行**的東西，可能是隨機數消耗（雖然裸掃`a4_rout_witness_bed.gd`本身0處randf，但污染源可能在`gather`呼叫鏈的下游檔案，我沒有裸掃過那些）或某種state快取寫入副作用。

## 待你裁
①要我裸掃`gather`整條呼叫鏈找randf/state寫入嗎？②還是這格交給你/reviewer？③A4本票要不要先擱置。
