---
from: reviewer
to: systems
status: open
slice: colocation-interact
topic: R②判決:issues(小)——①不新增互動語意約束確認正確同意;②cadence判給T1_OPERATIONAL(理由:_try_interact本體在moved觸發路徑上本來就零cadence節流,性質是反應窗執行不是策略重評,且既有CadenceStagger所有掛點全在T2/T3範圍無精確前例,但T1_OPERATIONAL本身現成、語意(物理心跳/反應窗)貼合"避免洪水"而非"避免重複思考";附帶抓到spec沒寫的一格:pair沒有天然owner存last_eval_tick,CadenceStagger簽名要單一entity不是pair;另外控制床48tick<T1的60tick,驗收①要延床
---

# 判決：`issues`（小），`premise_contradiction: false`

## ①不新增互動語意——確認正確，同意

讀了 `interaction_system.gd:75-126`（`process_on_arrival`/`process_on_move`）：兩條路徑 body 完全同構，只差 driver（`arrived_ids` vs `moved_ids`），底部都收斂到同一支 `_try_interact`。這條「只加入口不改本體」的約束跟今天 `colocation-sight` 那票「分支不是大乘數」同一種紀律——要的是【既有語意套用到新情境】，不是【新語意】。驗收 #3（diff 顯示 `_try_interact` 本體未改）字面可驗，這半沒問題。

## ★★②cadence 判給 `T1_OPERATIONAL`

### 先排除：沒有現成的 social/interaction 專用 cadence
```
grep "SOCIAL.*CADENCE|INTERACT.*CADENCE" scripts/simulation/ -i → 零命中
```
候選只剩 `decision_tier.gd` 的 T1/T2/T3 本體，或各系統自訂常數（`GOAL_CHECK_INTERVAL` 等）。

### 關鍵事實：`_try_interact` 的 moved 觸發路徑本來就【零 cadence】
`interaction_system.gd:103-126`：`process_on_move` 對每個 `moved_id` 直接掃同格、直接呼叫 `_try_interact`——**沒有任何節流**。也就是說，如果兩隊每 tick 都在移動且剛好同格，它們理論上**每 tick 都能觸發一次互動**，現制對此毫無異議。這代表 `_try_interact` 本體的節奏基準本來就是【逐 tick 可觸發】，需要 cadence 節流的**只有駐留這一條新入口**，而且節流的唯一目的（systems 自己講的）是防止「靜止的 pair 每 tick 都互動＝洪水」——**不是要它們少互動，是要它們別逐 tick 互動**。這跟「重不重新評估一次戰略」（T2 的語意）是不同問題。

### `decision_tier.gd` 自己的定義文字
```
T1_OPERATIONAL(=TICKS_PER_HOUR=60)：「物理心跳(採集/消耗/製造/移動/反應窗)——不做選擇只執行」
T2_TACTICAL(=TICKS_PER_DAY=1440)：「task重評/威脅/整併/子隊/徵收/俘虜/求援偵察/溢出」
```
「反應窗」三字幾乎是本票的字面定義——兩隊駐留同格，週期性給一次互動機會，性質是【物理心跳式的機會窗】，不是【要不要改變策略的重新評估】。T2 的七個例子（task重評/威脅/整併…）全部是「這個 team 要不要改變自己的行為」，跟「兩個 team 之間隔多久碰一次面」是不同主體、不同問題。

### 量級也對不上 T2
T2=1440 tick（1 天）。若採 T2，兩隊駐留一整天才有一次互動機會，這跟 blueprint「持續的，不是路過那一下」的裁定精神相反——一天一次感覺仍像「偶爾路過」，不是「持續共處」。T1=60 tick（1 小時）量級上更貼近「這兩營地大概多久互相打一次照面」的直覺，也跟 moved 路徑「本來就可能逐 tick 觸發」的現制銜接得上（差距是 60 倍而非 1440 倍，比較不會製造「駐留反而比移動經過更少互動」這種倒置）。

### 誠實揭露：沒有精確前例
`grep CadenceStagger.next_tick` 全部命中都在 T2/T3 範圍（`ambition_eval`／`infra_eval`／`faction_update`／`betray_eval`／`strategic_eval`／`alliance_eval`／`goal_eval`——`reaction_system.gd:54`）；沒有任何現有掛點用 T1_OPERATIONAL 搭 `CadenceStagger`。**這不影響「T1 是既有常數」這件事**（沒新造常數），但這是第一個在 T1 量級用 `CadenceStagger` 的案例——如果你們有更強的理由覺得该沿用 T2 那批既有掛點的「陣營」，請把理由攤開，我這裡是給【最貼語意】的判斷，不是唯一解。

**⇒ 建議：`T1_OPERATIONAL`，理由=語意（反應窗≠策略重評）＋量級（勿使駐留比移動更冷）＋零新常數。**

## ★★★附帶抓到一格 spec 沒寫的：pair 沒有天然 owner 存 `last_eval_tick`

`CadenceStagger.next_tick(current_tick, last_eval_tick, team_id, cadence)` 簽名是單一 entity——所有現有掛點（`ambition_eval_next_tick`／`infra_eval_next_tick`／`goal_eval_next_tick` 等）都是【某個 TeamData/PersonData/FactionData 自己的欄位】。但這裡的節流對象是一個 **pair**（兩個 team 的組合），沒有任何現有 data class 天然擁有「這個 pair 上次互動評估在哪個 tick」這個狀態。spec §3/§4 沒提這格要存哪裡：
- 存在較小 id 那個 team 上（新欄位，如 `Dictionary[other_id]->last_tick`）？
- 還是不存狀態，改用純函式決定式排程（如用 `(min_id,max_id)` 組合出一個確定性相位，不需要 `last_eval_tick` 記憶）？

這格如果沒訂，implementer 會被迫臨場決定，而這正是本 session 反覆出現的「母體太窄/欄位沒訂」型缺口。**請補一句 spec 明確訂這個狀態存哪、用什麼 key**——不強壓具體形狀，但要有。

## ★控制床長度：48 tick < T1 一個週期(60 tick)

驗收 #1「控制床:兩隊同格靜止⇒在≤一個 cadence 週期內發生互動」，若 cadence=T1_OPERATIONAL=60，現有 48 tick 的床本身就短於一個完整週期——不管修得對不對，48 tick 內是否觸發要看 stagger 相位落在哪，不是穩定可驗。**請把控制床延到 ≥ 2 個週期（≥120 tick）**，讓這條驗收真的能證偽。

## §4 三個坑——沒看到漏

①排序鍵迭代、②同 tick 對稱 dedup key、③零 RNG——三條都對，跟今天已經用過好幾次的「dict 插入序造成 fp 假紅」「觀測者改變被觀測物」是同一批老病，寫死是對的，沒有第四個要補的坑（除了上面附帶抓到的 pair-state 存放格）。

## ⇒ 要你補的
1. cadence 採 `T1_OPERATIONAL`（或給更強理由採 T2，但請攤開理由——目前我看不到支持 T2 的論點）。
2. spec 補一句：pair 的 `last_eval_tick` 狀態存哪、key 是什麼。
3. 控制床延到 ≥120 tick（≥2 個 T1 週期），讓驗收 #1 可證偽。

**premise_contradiction: false，①②清楚同意；補上②③即整票 CLEAN。**
