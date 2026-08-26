---
from: reviewer
to: systems
status: open
slice: outpost-development-unified
topic: R②判決:issues(小)——①warring_states真走得到faction路徑,fp判準對但要補一句風險提醒(非RNG,是迭代順序);②統一形狀給你一個具體分解;③不擋
---

# 判決：`issues`（小，不阻擋方向），`premise_contradiction: false`

## ①驗收3——**warring_states 真的走得到，母體不是空的**
查 `config/warring_states.json`：`factions.count=8`、`teams_per_faction_range=[2,5]`、`independent_ratio=0.35`（即 65% 隊在 faction 裡）——真有 faction。
`_evaluate_infrastructure(state,f)` 呼叫點在 `:739`：`for fid in state.factions: ... if tick%INFRA_INTERVAL==0: _evaluate_infrastructure(state,f)`——**這是主 tick loop 的常規呼叫，不是特殊 harness 才會走到**。⇒ **warring_states 上每個 faction 每隔 `INFRA_INTERVAL` tick 都會真的進這支函式，回歸防線不是空的。Q1：對，可用。**

## ①`fp` 逐位元不變——**判準對，但風險不在 RNG，在迭代順序/tap 次序，補一句給 implementer**
好消息：查過 `faction_ai_system.gd`／`outpost_system.gd` 這整條決策鏈，**沒有 `randf()`/`randi_range()`**（唯一一處 `randf()` 在 `:2982`，跟這支無關）——★**跟你上一票踩到的 RNG 消耗次序不是同一種風險，這條路徑本身是決定性的（純迭代+guard），不會因為抽共用體而多消耗隨機數。**

★但有一個結構性風險要明寫進 spec（同一種紀律，換一個變數）：
`_evaluate_infrastructure` 段 (1)(2) 都是 `for tile_id in state.world.tiles:`（**全地圖 tile，不是「faction 自有 tile 清單」**，靠 `tile.outpost_owner != leader_team.team_id: continue` 過濾）——**這個【全地圖字典的迭代順序】本身就是「哪一格先被評估、先被誰蓋」的決定因素**（多個 tile 都符合升級條件時，先掃到的先觸發 `_dispatch_upgrader` 然後 `return`，後面的格子這輪根本不會被看到）。
⇒ **要求（建議寫進 spec）**：共用體抽出後，**faction 入口對 `state.world.tiles` 的迭代順序、進入共用評估函式的 tile 順序，必須跟現況逐格一致**（不能為了「乾淨」改成先收集清單再排序、或改成別的資料結構迭代）——否則即使邏輯完全正確，`fp` 也會因為「同樣都升級了，但先升的那格不同」而假紅，跟你上一票的 RNG 教訓是同一個母題：**判準本身沒錯，但執行判準（或這裡是：執行重構）的方式可能悄悄改變被量的東西。**

## ②不會逼出爛形狀——給你一個具體分解
faction 段(2)跟獨立版本來就已經共用 `_pick_facility`（`:4620` 跟獨立版一致）——不是從零統一，是「再往下收一層」。
**「掃所有自有 tile」vs「`_find_own_outpost` 單格」不是實作隨意選的，是結構性事實**：faction 是多隊結構（leader+可能的居民/子隊/其他 owner tile），獨立隊只有自己這一個 team、天生只有一格。
⇒ **建議的分解（不是共用體吃旗標，是共用體吃「一格+一隊」，迭代權留給各自入口）**：
```
共用：evaluate_upgrade(state, leader_team, tile) -> bool     # 段(1)的單格版
共用：evaluate_facility(state, owner_team, tile, leader) -> bool  # 段(2)的單格版（現有 _pick_facility 已經是這層）
faction 入口：for tile_id in state.world.tiles: 過濾自家 → 逐格餵共用函式（迭代順序照現況）
獨立入口：own_pos = _find_own_outpost(...) → 一格餵共用函式（跟現在一樣單格）
```
**共用體本身完全不知道呼叫者是 faction 還是獨立**——不是五旗標函式，是「拆迭代跟單格判斷成兩層」，跟你講的「不得寫 if faction_id==-1」完全相容，我認為不會逼出更糟的形狀。

## ③不動 FACILITY_SLOTS/DEMOLISH_MARGIN——**不擋**
spec 自己驗收②跟誠實限已經先手處理了「若沒降,不是失敗是下一格」——**這條已經誠實分層過，不會變成不可達驗收**（跟前幾票不同，這次你自己先做對了）。

## ⇒ 要你補的
只有①的迭代順序那句（建議寫進 spec，跟 RNG 教訓同一母題）。②③不用改，方向確認即可。

**premise_contradiction: false，小補一句即可轉 CLEAN，不用大改。**
