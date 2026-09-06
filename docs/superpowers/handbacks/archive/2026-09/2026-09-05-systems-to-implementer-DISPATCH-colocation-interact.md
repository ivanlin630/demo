---
from: systems
to: implementer
status: consumed
slice: 共位互動 ★派實作（R² issues 小，已照做）
tier: slice
topic: ★cadence = DecisionTier.T1_OPERATIONAL(=TICKS_PER_HOUR=60);★★而 R² 抓到的那格其實在說【我把機會掛錯對象】:pair 沒有天然 owner 存 last_eval ⇒ 改成 per-team `colocate_eval_next_tick`(沿用 ambition_eval_next_tick／infra_eval_next_tick 的既有慣例)——★★★不是「這一對該不該互動」,是【這支隊該不該環顧四周】;★而控制床 48 tick < T1 的 60 tick ⇒ 床要延到【至少 120 tick】,否則跑不到那個機會
---

# 派工（spec = `docs/superpowers/specs/2026-09-05-colocation-interact-HOW.md`）
```
★①保留移動觸發（不動）
★②新增 per-team 週期機會:`team.colocate_eval_next_tick`,cadence ＝ DecisionTier.T1_OPERATIONAL
   ⇒ 輪到某隊 ⇒ 讀 `state.teams_by_tile` 裡【自己那格】的其他隊（★排序後）⇒ 逐一呼 `_try_interact`
★★③【不新增互動語意】:呼叫同一支 `_try_interact` —— 只新增進入它的路
   ⇒ ★★★驗收 #3 會查:diff 顯示 `_try_interact` 本體【未改】
```

# ★★三個坑（★spec §4，我重貼因為它們最容易在實作時掉）
```
①★迭代順序:teams_by_tile 是 Dictionary ⇒ 用【排序後的 key 與 team_id】
   ⇒ ★★否則「誰先互動」隨字典順序漂 = fp 假紅與真行為漂移的老來源
②★★同 tick 去重:一個 pair 可能同 tick 既被 moved 觸發又被駐留觸發 ⇒ key 用 (min_id, max_id) 對稱
③★★★零 RNG:排程與列舉都不得耗 global RNG
```

# ★驗收（★#1 的床要延長）
```
1 ★控制床:兩隊同格靜止 ⇒ ≤ 一個週期內互動 —— ★★床要【至少 120 tick】(T1=60,舊床 48 跑不到)
2 ★★join.resolve > 0／true<belief 下降（★這是從共位必見那票移過來的）
3 ★★★不新增語意:_try_interact 本體未改（diff 證）
4 同 tick 同 pair 不重複（機械計數 = 0）
5 determinism 三跑一致（fp 會變）＋ 迭代用排序鍵
6 perf:每 tick 同格 pair 母體＋該段耗時（★母體應極小,不小則回報）
7 憲法閘 ＋ 17 支全綠
8 ★★零 RNG:三跑 byte-identical ＋ 該段不出現 randf/randi
```

# ★★而 merge 我打算【兩票一起】（★先講，免得你等）
```
★共位必見(已停 branch,自己的驗收全綠)＋ 本票 ⇒ ★★一起 merge
⇒ ★★★理由:它們是【同一個裁定的兩半】,分開 merge 會讓「JOIN 到底修好沒有」
   再一次分不清是哪一刀的效果 —— 而今天已經因為三變因同換吃過一次虧
★而做完【停 branch】回報我,我接 merge → 17 支 → 重建凍結 → peaceful×3 重跑
```
