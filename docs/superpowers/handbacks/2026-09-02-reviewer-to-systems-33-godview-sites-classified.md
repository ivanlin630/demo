---
from: reviewer
to: systems
status: open
slice: 族①殘：逐顆分類
topic: 33顆逐一分類完畢(22新warn命中+11舊gv_*標記)——①真違規4個(decision_context.gd::gather兩處/_try_invite_nearby_exile/_evaluate_alliance_need)+舊標記裡_find_trade_partner自認未修算第5個;②legit豁免27個(各附一句理由,可批量inline gate-ok);③判不出來1個(_update_escort,缺call-graph證據);最重要的③案例點名:_find_trade_partner的baseline標記本身就自認是「待修的leak」不是「判過legit」,清單語意本身有被誤讀風險
---

# 分類完畢：33 顆，逐一 file::func::行 + 理由

抽查過兩個最重的①（`decision_context.gd::gather`／`_evaluate_alliance_need`）親自 Read 驗證，跟下方一致，不是照轉。

## ①真違規（5 個，含舊標記 1 個）——**進修法清單**

```
decision_context.gd::gather::gv_belief_post（:436-441, :443-448）
  ⇒ 親驗：join_host_flow 讀 _host.tile_pos/_host.population（live，:436/:441）；
    occupy_target_flow 讀 _vt.tile_pos/_vt.population（live，:443/:447-448）
  ⇒ c.strong_neighbor_id/c.occupy_target_id 選拔階段已 belief 化，★選中後的【估值】階段直接讀 live
  ⇒ 同函式 :391-395 absorb_yield 是正確做法（belief 閘+population_est）——證明不是能力問題，是漏改一格

faction_ai_system.gd::_try_invite_nearby_exile::gv_belief_pre
  ⇒ :686-689 讀 t.tags/.parent_team_id/.combat_target/.current_task 在 belief_pos 閘（:693）之前
  ⇒ :692 註解只處理了 live tile_pos 那一項，四個篩選欄位漏改

strategic_ai_system.gd::_evaluate_alliance_need::gv_belief_pre
  ⇒ 親驗：:262 `_get_pop_est(state, obs_id, tid, t.population)`——第 4 引數（無 belief 時的 fallback）
    是敵方（:259 已排除同 faction）的【live 真實人口】，餵進 threat_map 驅動結盟決策
  ⇒ 對照 :250 self_pop 走 `_faction_total_pop`（fallback 用【自己】隊伍的 live pop，同款寫法但對象是自己人，legit）
  ⇒ 同一個 fallback 寫法，一個對自己（legit）一個對敵人（illegit）——複製時漏改了觀察對象

strategic_ai_system.gd::_find_trade_partner::gv_mapscan（舊標記，baseline :76）
  ⇒ baseline inline 註解自己寫「CANDIDATE-LEAK...半漏,待 R²+follow-up」
  ⇒ ★這不是「判過 legit」，是「記著待修但先放行」——標記存在本身不代表已判定安全
```

## ②legit 豁免（27 個）——附一句理由，可批量走 inline `# gate-ok:`

```
diplomatic_ai_system.gd::try_proactive_diplomacy       co-location測試(同格才互動,physically可見)
faction_ai_system.gd::_assign_tasks                    全讀自己faction leader/成員(自身真值)
faction_ai_system.gd::_decide_subteam                  parent=自己的母隊(內部階層)
faction_ai_system.gd::_deposit_help_need               origin自願誠實回報自己位置(信使親送)
faction_ai_system.gd::_dispatch_builder                讀自己的子隊(自身階層知識)
faction_ai_system.gd::_ensure_holding_ledger           m僅來自同faction成員,位置已正確走belief
faction_ai_system.gd::_evaluate_all_body               本身就是belief harvest正確消費模式
faction_ai_system.gd::_evaluate_infrastructure(pre)    leader=自己faction leader;tile掃描=legit-geo同族
faction_ai_system.gd::_find_absorber                   t僅來自同faction成員,同:2170/:2471既有先例
faction_ai_system.gd::_maybe_request_join_player       co-location測試
faction_ai_system.gd::_rebuild_goals                   leader_team=自己faction leader
faction_ai_system.gd::_tick_info_scout                 讀取限定在co-location分支內,刻意設計的親見模式
faction_ai_system.gd::_tick_migrant                     target=遷徙目的地,同faction既有慣例(:2220自述)
faction_ai_system.gd::_tick_one_letter                  co-location=送信抵達物理判定
faction_ai_system.gd::_try_relocate_order               village來自自己leader的行政管轄記錄,已走belief
faction_ai_system.gd::consolidate_target_of(pre)        同既有baseline標記74(gv_teamstate)同一函式同理由
faction_ai_system.gd::tick_relocations_all              每隊對自己生命週期的例行更新,非A觀察B
strategic_ai_system.gd::_assign_encirclement            target正確走belief;member全來自自己faction
strategic_ai_system.gd::_faction_total_pop              t僅來自自己faction成員,fallback讀自己人口
decision_context.gd::_home_granary_food(舊)             legit-self掃own糧倉
need_oracle.gd::_team_has_facility(舊)                  legit-self掃own設施
faction_ai_system.gd::_check_ore_surplus(舊)            legit-self掃own faction outpost
faction_ai_system.gd::_evaluate_infrastructure(舊)      legit-geo,同本輪新標記判斷一致
faction_ai_system.gd::_evaluate_new_outpost_location(舊) legit-geo
faction_ai_system.gd::_evaluate_outpost_residency(舊)   legit-geo
faction_ai_system.gd::_faction_has_workshop(舊)         legit-self
faction_ai_system.gd::consolidate_target_of::gv_teamstate(舊) 同上,一致
faction_ai_system.gd::_enemy_outpost_positions(舊)      團隊已核可過(followup-fixed 63d93aab)
```
★附一個非分類但要記的：`faction_ai_system.gd::_find_own_outpost::gv_mapscan`（舊標記）已在憲法閘輸出裡自報 `removed（de-patch進度）`——現行 code 已不存在此站點，不用處理。

## ③判不出來（1 個）——**缺的資訊寫清楚，不是拖字訣**

```
faction_ai_system.gd::_update_escort::gv_belief_pre
  ⇒ :3196 target.tile_pos（live，零belief閘）直接寫進 team.move_target
  ⇒ 若 order_target_id 保證同faction/友軍（「護衛」語意上應該只護衛自己人）＝合法；
    但 order_target_id 是通用欄位（grep到 :490/:5635 多種option都寫入同一欄）
  ⇒ ★缺什麼：需要追完整個 dispatch call graph，確認哪些 current_task 會走到 _update_escort、
    以及那些 task 對應的 option handler 是否保證 order_target_id 只被設成同faction/友軍 id
  ⇒ 這需要窮盡 grep + 讀懂 dispatch 分支，不是我現在能一次讀完的範圍，寫在這裡不猜
```

## ★值得點名：清單語意本身的誤讀風險

`_find_trade_partner::gv_mapscan` 這顆舊標記的存在本身，示範了「標記存在 ≠ 已判定合法」——它的 inline 註解自己承認是待修的 leak，若下一個人只看「有標記」就當作已核可，會誤放行一個團隊自己都承認還沒修的洞。這個案例值得寫進「憲法閘覆蓋盤點」的 known_issues，不只是本票的一條分類結果。

## ⇒ 結論
①4+1＝5 個進修法清單（`gather` 兩處、`_try_invite_nearby_exile`、`_evaluate_alliance_need`、`_find_trade_partner`）；②27 個可批量走 inline `# gate-ok:`；③1 個（`_update_escort`）誠實掛起，不猜。
