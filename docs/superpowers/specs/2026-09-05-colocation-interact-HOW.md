# HOW spec（草案，送 R²）— **駐留共位 pair 的週期互動機會**

**裁定（blueprint 2026-09-05）**：**共位保證的不只「看見」，還有「互動機會」，而且是【持續的】不是「路過那一下」。**
**「只在移動時觸發」＝事件驅動優化把語意吃掉** ——★**優化是對的，語意錯了**：
**互動機會屬於【共位狀態】，不屬於【移動事件】。**

## §1 現況（★窮盡驗過）
```
★`_try_interact` production 入口只有 interaction_system:97(arrived)／:125(moved),都在 `process_on_move` 內
   而它由 sim_runner:459 以 moved_ids 呼叫
⇒ ★★雙方都沒動 ⇒ 不進 moved_ids ⇒ ★★★結構性不互動（控制床:48 tick、moved 每 tick 0 筆）
```

## §2 形狀（★保留便宜且對的那半，補上缺的那半）
```
①★保留【移動觸發】—— 它沒有錯,而且便宜
②★★補【駐留共位 pair 的週期機會】:同格且都沒動的 pair,每隔一個 cadence 得到一次互動機會
③★★★而它【不新增互動語意】:呼叫的是【同一支】`_try_interact` —— 只新增【進入它的路】
   ⇒ 這條是本 spec 最重要的約束:新語意 = 新 bug 面;新入口 = 既有語意被套用到本來就該套用的情境
```

## §3 用哪些現成結構（★都已存在，不新造）
```
★母體列舉:`state.teams_by_tile`（world_state.gd:74，tile_id → Array[team_id]）
   ⇒ ★★只取 size ≥ 2 的 tile —— 同格 pair【天生極小】,符合「計算跟隨事件密度」
   ⇒ ★★★而它由 `rebuild_team_tile_index()` 在 `_step2_move` 重建 ⇒ 掛在移動之後才讀得到新鮮索引
★節流:`CadenceStagger.next_tick(current_tick, last_eval_tick, team_id, cadence)`
   ⇒ ★零 RNG、純函式、同 (tick, team_id, cadence) 恆同值 ⇒ 可重播
   ⇒ ★★而它的用途在這裡【不是 perf】,是【避免同格兩隊每 tick 互動一次＝洪水】
★★★cadence ＝ ★**`DecisionTier.T1_OPERATIONAL`**（decision_tier.gd:23 ＝ `TICKS_PER_HOUR` ＝ 60）
   ⇒ ★R² 判：`_try_interact` 在 moved 路徑上本來就【零 cadence 節流】，性質是【反應窗執行】不是【策略重評】
   ⇒ ★★而 T1 的語意（物理心跳／反應窗）貼合「避免洪水」，不是「避免重複思考」

### ★★★★訂正（R² 抓到的 spec 缺格）：**機會屬於【隊】，不屬於【pair】**
```
★R² 指出:pair【沒有天然 owner】存 last_eval_tick,而 CadenceStagger 的簽名要【單一 entity】
⇒ ★★而那其實在說:我把機會【掛錯了對象】—— 不是「這一對該不該互動」,
   是【這支隊該不該環顧四周】
⇒ ★★★所以改成【per-team】:`team.colocate_eval_next_tick`（★沿用既有慣例:
   ambition_eval_next_tick／infra_eval_next_tick 都是 entity 上的欄位）
★輪到某隊時:讀它自己 tile 上的其他隊（排序後）,逐一呼 `_try_interact`
⇒ ★★零新狀態結構(只多一個既有形狀的欄位)、零 pair 表、而錯峰天然由 CadenceStagger 提供
⇒ ★★★副作用是好的:同一對可能被【兩邊各自】給一次機會 —— 而那正是「兩隊各自環顧」的語意
```
```

## §4 ★必須寫死的三個坑
```
①★**迭代順序**:`teams_by_tile` 是 Dictionary ⇒ ★★必須以【排序後的 key】與【排序後的 team_id】迭代
   ⇒ ★★★否則「誰先互動」會隨字典順序漂 —— 而那正是 fp 假紅與真行為漂移的老來源
②★★**同 tick 不重複**:一個 pair 可能同 tick 既被 moved 觸發、又被駐留觸發
   ⇒ 需要 per-tick 去重（★而去重的 key 要對稱:(min_id, max_id)）
③★★★**零 RNG**:排程與列舉都不得耗 global RNG（觀測者/排程改變被觀測物的老病）
```

## §5 ★我不自己選的一格：**cadence 用哪個既有值**
```
★blueprint 說「掛 T1/T2 cadence」,而我不想【新造一個常數】
⇒ ★★候選:沿用決策層既有的 social/interaction 類 cadence
⇒ ★★★而我沒有把握哪一個是【語意上對的】——交 R² 判（★★同 cap 那票的做法：不確定就送審，不自己放行）
```

## §6 驗收
| # | 判準 |
|---|---|
| 1 | ★**控制床：兩隊同格靜止 ⇒ 在 ≤ 一個 cadence 週期內發生互動**（★★現況 48 tick 0 次）<br>★★★**床要延長**：T1 ＝ 60 tick 而舊床只有 48 tick ⇒ **48 < 60，跑不到那個機會**（R² 抓到）⇒ **至少 2 個週期（120 tick）** |
| 2 | ★★`join.resolve` **> 0**／`true<belief` 下降（★這是從共位必見那票**移過來**的 #3/#4） |
| 3 | ★★★**不新增互動語意**：diff 顯示只新增入口，`_try_interact` 本體**未改** |
| 4 | ★同 tick 同 pair **不重複處理**（機械計數 ＝ 0） |
| 5 | determinism 同 seed 三跑一致（★`fp` 會變）＋ ★★迭代用排序鍵 |
| 6 | ★perf：每 tick 同格 pair 母體 ＋ 該段耗時（★★母體應極小，若不小則回報） |
| 7 | 憲法閘 PASS ＋ 17 支全綠 |
| 8 | ★★★**零 RNG**：三跑 byte-identical ＋ 該段不出現 randf/randi |

## §7 不在範圍
```
★①`_try_interact` 內部的任何判定（★不動語意）
★★②#8 新鮮度洗白（另一票，排在這之後）
★★★③JOIN 之外的互動類型不特別調整 —— 它們【自動】拿到同一條新入口,而那是本設計的目的
```
