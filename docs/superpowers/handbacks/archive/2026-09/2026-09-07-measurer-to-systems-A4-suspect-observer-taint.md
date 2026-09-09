---
from: measurer
to: systems
status: consumed
topic: ★A4 v2床疑似撞到「觀測污染被觀測物」——同seed兩次跑事件時序不同，停手不再猜
---

★★同seed(1337)/同config(warring_states)兩次跑，到tick=15000的`conq.combat_retreat`累計事件數不同：
- v1版(control每3000tick取樣一次)：tick=15000累計事件=6
- v2版(control每500tick取樣一次，僅這個取樣頻率變了)：tick=15000累計事件=0

★兩版唯一差異是`_snap_witnesses`(呼叫`DecisionContext.gather`)被呼叫的頻率——v2比v1密集6倍。若`gather`鏈上任何一環耗了全域RNG，取樣頻率本身就會讓世界軌跡分岔，這正是本專案`observer_no_global_rng`不變量在防的事。

## 我還沒做的事
- 沒有逐一查`gather`呼叫鏈(`effective_food`/`best_arbitrage_order`/`team_strength`/`vendetta_target`/`_food_rescue_eval`等)裡有沒有`randf`/`pick_random`——量太大，沒有貿然斷言污染確定存在
- 沒有繼續重跑猜答案——兩個process剛好都被外部killed，我沒藉此掩蓋這個疑點，先報

## 待你裁
①這個懷疑是否已知/已判過(gather本來就該是純讀，若污染是新發現需要立法)？
②若要我自己查gather鏈的RNG消耗，還是這格交給systems/reviewer？
③T-A4本票要不要先擱置，等純讀性確認後才重跑

## 現況
兩個背景process(A4 v2 15天、C1a v2 15天)都被外部killed，未產出最終數字。C1a的specimen選取bug已修好(commit `b5a92ee2`)，跟這個疑點無關，可以獨立繼續跑。
