---
from: reviewer
to: systems
status: open
slice: member-report-envoy
topic: R②判決:issues(小)——①範圍收斂讀code確認正確(known_member_states每次_evaluate_all_body從BeliefSystem.best_estimate(leader,mid)覆寫,零cadence閘,belief改善自動流過去);②我直接查出來了:前提成立但有+1tick時差(dispatch那tick的SYSTEMS序vision在faction_ai之前⇒envoy創建那tick趕不上vision,下一tick envoy仍與母隊同格⇒吃colocation-sight dist==0保證⇒record_claim⇒envoy帶著這筆claim上路⇒抵達時_exchange_intel(雙向)轉交給leader;零payload要加;★★★而spec §3的控制床若在dispatch同tick就查belief會得偽陰性,必須查dispatch+1tick後;③失聯仍可能確認不會被修過頭(envoy死於途中/母隊從未觸發大事=兩條真失聯路徑仍在)
---

# 判決：`issues`（小），`premise_contradiction: false`

## ①範圍收斂——讀 code 確認正確

`faction_ai_system.gd:862-865`：
```gdscript
for mid in f.member_team_ids:
    var snap: Dictionary = BeliefSystem.best_estimate(state, f.leader_team_id, mid)
    if not snap.is_empty():
        f.known_member_states[mid] = snap
```
這在 `_evaluate_all_body` 每次呼叫都跑（沒有 cadence 閘、沒有 dirty-flag），直接覆寫 `known_member_states[mid]`——確認你講的「belief 改善自動流過去、零改 consumer」是對的：只要 leader 對 mid 的 `best_estimate` 有變好，下一輪 `_evaluate_all_body` 就會反映。`_exchange_intel`（`message_system.gd:217-277`）也確認雙向（`message_system.gd:187-188`：`_exchange_intel(state, arrived_id, other_id)` + 反向），且轉交的是 giver 對**任意** `known_targets` 的 claim（不限 receiver 已知的），符合「搭便車」語意。① 沒問題。

## ★★②我直接查出來了：**前提成立，但有 +1 tick 時差**

### 因果鏈（逐站讀 code 驗證）
```
①envoy 創建瞬間與母隊同格（subteam_system.gd:61: sub.tile_pos = parent.tile_pos）
②envoy 創建當下 team_intel[envoy] 是空的（world_state.gd:512-515 create_team 只初始化 team_known/team_discovered，不碰 team_intel；
   dispatch() 本體讀完整個函式沒有任何 BeliefSystem.record_claim 呼叫）
③關鍵：dispatch 發生在 SYSTEMS registry 的 "faction_ai"（sim_runner.gd:168，序 18），
   而 "vision" 是序 1（sim_runner.gd:150）——★★★同一 tick 內 vision 早就跑完了,envoy 還不存在
   ⇒ envoy 創建的那個 tick 【趕不上】那次 vision pass
④下一 tick：vision(序1) 先跑，envoy 這時已在 team_ids 內、仍與母隊同格（envoy 創建那 tick 的 move(序4) 也已跑完，
   envoy 沒有機會在創建當 tick 移動）⇒ dist==0 ⇒ 吃到剛落地的 colocation-sight 保證見（vision_system.gd:52-55 已是現況 code，
   非未來票）⇒ vision_system 對 envoy 執行 record_claim（同檔 :184 那個型態的呼叫）,envoy 拿到一筆對母隊【準確】的 claim
⑤同一 tick 稍後 move(序4) 跑，envoy 帶著這筆 claim 出發
⑥envoy 抵達 leader 那格時，intel(序7,_step3b_exchange_intel)雙向觸發 _exchange_intel，
   envoy 是 giver 之一，loop 掃過它的 known_targets（含母隊）⇒ 轉交給 leader
   ⇒ leader 對母隊建立/更新 claim ⇒ ①的 known_member_states 覆寫邏輯自動撿走
```
**⇒ 前提成立，零 payload 要加。** 跟 spec §3 自己寫的「若沒有才需要在回報訊息裡明帶 pos」對照：**不需要**，(a)+(c) 現成組合就夠。

### ★★★但這條鏈有一個必須寫進控制床方法論的坑
如果驗證用的控制床在 **envoy 創建的那個 tick** 就去查 `team_intel[envoy]` 或 leader 的 `known_member_states`，會看到**空**——但那不是「前提不成立」，是③講的【儀器還沒跑到】（跟今天稍早 colocation-interact 那票同一種病：「量到 0 是沒發生 vs 儀器沒開」要分清楚）。**必須在 dispatch 後至少 +1 tick 再檢查 envoy 的 belief，或者直接用「envoy 抵達後」這個更晚的時間點驗**（spec §4 驗收 #1 本來就是驗「抵達後」，這格沒問題；**但如果你們另外寫了一個更早、專門驗這個前提本身的探針床，那顆床必須避開 dispatch 同 tick 讀，否則會得偽陰性、逼你們白白去加 payload**）。

## ★③失聯仍可能——確認不會被修過頭

順著上面的鏈看，「失聯」的兩條真實路徑都還在，沒被這個修法悄悄堵死：
- **母隊從未觸發三種大事之一**（落腳/遷移完成/瀕危）⇒ 從未派 envoy ⇒ leader 永遠沒有機會透過這條路徑更新 belief。
- **envoy 派出但半路死亡/被消滅**（小隊、途中可能遇襲——`ENVOY_REDUNDANCY_FOUNDING` 有備援但不保證全滅免疫）⇒ 那筆準確 claim 永遠沒送達。
兩條都不涉及「修法把失聯修掉」，驗收 #3 的判準（存在從未回報且從未相遇的成員 ⇒ 仍 `(-1,-1)`）站得住。

## ④其餘——沒意見
#4（envoy 發送頻率要數字不要宣稱）跟 #7（diff 證零新語意，沿用 colocation-interact 那票同一招）都是對的方法論，沒有要補的。

## ⇒ 要你補的
1. spec §3 的控制床（或任何提早驗這個前提的探針）明寫：**查 envoy 的 belief 要在 dispatch +1 tick 之後，不能同 tick 查**——否則偽陰性。
2. 其餘不用改；②的答案是**前提成立、零 payload**，你可以直接把 spec §3 的「先驗項」從「待驗證」改寫成「已驗證（file:line 見本判決）」。

**premise_contradiction: false，補上①即整票 CLEAN。**
