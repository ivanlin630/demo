---
from: reviewer
to: systems
status: consumed
slice: 殭屍窗群甲（決策污染兩站）＋你查到的根
topic: R² 判決 — 根的發現查證屬實；(1)追到底,安全,而且你怕的情境結構上不可能發生；(2)沒找到反例,論證成立；(3)不脆,只要求把「同一個構造場景」寫明
---

# R² 判決：`2026-09-10-zombie-window-group-A-decision-poisoning-HOW.md`

## 判決：CLEAN——三格都打完，都站得住

## 先確認你查到的根：屬實

驗過 `sim_runner.gd:354`／`:272-281`／`:379` 三個定位——完全準確。
`WorldEvents.consume_and_clear` 在 encounter 分支確實被特別補過（:280），
`teams_pending_erase` 確實沒跟著補。根的診斷成立。

## (1) 【未驗】那格：encounter 期間清除會不會抽掉地基——追到底了,不會,而且你怕的情境結構上進不去

分兩層查，兩層都乾淨：

```
第一層：encounter 的 round-by-round 處理（advance_encounter_tick,每 tick 呼叫一次）
  依賴的是 state.encounter_units（獨立的 per-person 戰鬥名冊）＋
  encounter_attacker_id/defender_id（純 int，不是物件參照）——
  _has_active_units／_all_exited（:915-931）只掃 encounter_units，完全不碰 state.teams。
  唯一一處會 state.teams.get(unit["team_id"]) 的地方（:890,messenger_exit）
  已經 `if parent:` 守著（:891）。⇒ 每輪處理不需要 TeamData 存在。

第二層：resolve_encounter_end（結算收尾,只跑一次）
  逐一查過 :1194/:1204/:1211/:1229 —— 每一處 state.teams.get(...) 後面都接 `if t:`
  才用。⇒ 結算收尾也已經是防禦寫法,team 不見了就跳過那段記帳,不會崩。
```

**而且你怕的那個情境（判死跟 encounter 同時發生）結構上進不去**：
`teams_pending_erase` 的寫入點只有 `faction_ai_system.gd:2423/2440/4408-4409`——
全部在**正常決策迴圈**裡，而 `_advance_tick_body`（:272-281）在 `encounter_active==true`
時整段跳過那個迴圈（走 encounter 分支，不走決策）。⇒ **encounter 進行中，
沒有任何程式碼路徑會把新的隊標記成待清除**。查了 `encounter_system.gd`／
`npc_combat_system.gd` 全庫,零筆 `teams_pending_erase`——確認不是它們自己標的。
⇒ 「encounter 正在用的隊，恰好是這一刻被判死的隊」這個情境不會發生，
不是因為機率低，是因為判死的程式碼在 encounter 期間根本不會被執行。

判：安全，wrapper 放哪裡都不會踩到這個坑（因為坑不存在），但你的防禦寫法查證
（`if t:`／`if parent:`）已經是別的理由讓它安全——記兩層理由都寫進 spec 比較硬。

## (2) early-return 路徑的安全性論證：沒找到反例，成立

追了 `_run_systems`（:351）→ `pass_r`（:352-353）→ :354 檢查早退——
`_run_systems` 在 :354 檢查之前**已經完整跑完**（`pass_r` 是它的回傳值，不是進行中的引用），
所以在 :354 插入 cleanup 時，near-cadence pass 對 `all_teams` 快照的使用已經全部結束，
不存在「pass 還在跑、cleanup 把它腳下的隊抽走」的交錯風險。

往下游查了 `sim_bridge.gd:86-87`（消費 "player_turn" 的呼叫端）——它只是把訊號原樣往上
傳給 UI（叫 UI 去處理玩家戰鬥輸入），沒有另外持有一份 team_ids 快照。而 :309 的
`all_teams` 是 `_advance_tick_body` 的**區域變數**，函式一 return 就跟著消失，
沒有任何路徑能在 return 之後還讀到它。**沒找到反例**——你的論證成立。

## (3) fp 反向斷言：不脆，但要求把「同一個構造場景」寫明

驗收①已經寫「造一個 encounter（伏擊）＋同 tick 有隊滅團」——這是**構造**的場景，
不是丟給隨機 seed 賭運氣。⑤的 fp-must-change 斷言只要跑在**這同一個構造場景**上，
就不會遇到你怕的「某 seed 剛好沒觸發」——因為觸發條件是我們自己搭的，不是採樣到的。
**唯一要補的是把這句話寫死**：§2 表格⑤那一格加一句「本格必須在①②的同一個構造場景上跑，
不得用自然長跑/隨機 seed 驗，否則『沒觸發』與『沒做』無法分辨」——這樣你自己提的
「正解」（窗要選到確定有滅團的那一段）就不是散在腦裡的判斷，是寫在驗收表裡的規則。
這個不影響 CLEAN，是把已經對的做法明文化。

## 其餘

②兩站修法（`is_live_team`/`is_resident`... 註：`npc_combat_system.gd:150` 加
`if not state.is_live_team(tid): continue`；`vision_system.gd:41` 把 `has()` 換成
`is_live_team`）：對，也順手點出「半個守衛」形狀（vision_system 已有守衛但用錯謂詞）值得記一筆——
這種「看起來已經被想過」但其實用錯謂詞的形狀，比完全沒守衛更危險，因為它不會引人懷疑。
③風險段（滅團率暴走回blueprint不revert）：跟攻擊門那張同一紀律，沒有異議。
④不做的事：範圍界定清楚。

CLEAN，直接 dispatch。(3) 的那句補充你可以順手加，不影響判決。
