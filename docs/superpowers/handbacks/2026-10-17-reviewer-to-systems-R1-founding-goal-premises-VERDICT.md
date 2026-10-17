---
from: reviewer
to: systems
status: consumed
slice: 開點登進既有長程目標表 — R① 前提查核（P1–P8，main e357289f1）
topic: R① 結果：P1 ✓（藍圖「5 種」是舊註解）、P2 ✓（你對，藍圖錯）、P3 ✓ 但母體不止四條、P4 ✓、P5 ✓、P6 ✓（比你想的更集中）、P7 部分 ✓（多一份 12 人；no_advisor 是物理但有副作用順序 bug）、P8 ✓ 有欄位但撞設計規則 HOW §9
---

# 總表
```
P1 ✓   P2 ✓（systems 對）   P3 ✓（另列發現）   P4 ✓   P5 ✓   P6 ✓   P7 部分 ✓（+兩條新發現）   P8 ✓ 但撞書面規則 HOW §9
無需 halt 的 premise_contradiction。P2 是藍圖信的前提錯，方向對你有利：要拆的早返回不存在。
```

# P1 ✓ 表上登了什麼
```
· goal_registry.gd:16-21 MAINTAIN_GOAL_RES ＝ 4 鍵（food／material／tools／weapon_melee_low）；:25-34 BUILD_FACILITY_GOALS ＝ 8 座；REGISTRY :39-42 維持 4 列、:52-59 設施 8 列。
· 全檔 grep（maintain_coin|found|outpost|開點|expand|settle）只命中 :24 註解與 :43「maintain_coin 拆掉」說明 ⇒ 沒有任何開點列。
· 你引的行號差 2（實際 :16-21／:25-34），結論不受影響。
· 「5 種」的來源：REGISTRY 上方註解「S2 5 資源維持」、decision_engine.gd:102 行尾註解「冪等確保 5 資源維持 goal」。code 是 4 種（coin 已拆）。兩處註解過期，請 HOW 順手改。
```

# P2 ✓ 沒據點的隊照跑目標迴圈（你對，藍圖信錯）
```
· decision_engine.gd:102 ensure_maintain_goals 無條件呼；:498 frontier_candidates 同。
· goal_resolver.gd:22-29：ensure_maintain_goals 只有兩個早返回——state／team／world 為 null、cadence 未到（GOAL_EVAL_CADENCE 3 天）。沒有任何讀 otile 的早返回。
· goal_resolver.gd:222-225：frontier_candidates 只擋 null。
· otile 只出現在設施列：取 otile 在 :46-48 一帶；退場迴圈 :60-85（otile==null ⇒ _why="no_otile"）；重掛迴圈整段在 `if otile != null:`（:99），null 時只在 Probe 開著才數 readd_blocked_no_otile（:86-91）。
  ⇒ 藍圖信的「:88 早返回」最像是這個 `if otile != null:`，它只管【設施列的重掛】，不是整個目標迴圈的早返回。
· 維持列與它們的資源前置候選照跑，沒據點的隊也有。
⇒ 你的判斷成立：新開點列只要掛／退不讀 otile，沒據點的隊自然會跑。藍圖 WHAT 第 3 條在 code 上已經是真的。
誠實限：這是靜態讀。「某支沒據點的隊真的跑到 :102」我沒用執行輸出驗；goal.skip.seen.day.*、goal.payoff.seen.* 是現成的進場計數，HOW 驗收請對「無據點隊」分開印一次，免得「迴圈會跑」只是讀出來的。
```

# P3 ✓ 四條屬實；母體另有發現（請 HOW 先定範圍）
```
四條（行號為合併後）：
 ① 紮根 option：options.gd:350-358（TASK_BUILD、settle_site）；commit 端 faction_ai_system.gd:7402 _commit_settle_site → :7436 OutpostSystem.start_build。
 ② 擴點：options.gd:373-380（delegate、build_type）；applicable 的 can_expand 在 decision_context.gd:895-903 ＝「選址有效候選 ∧ population ≥ 12」，選址 _evaluate_new_outpost_location 讀 _find_own_outpost ⇒ 沒據點走不到（你對）。
 ③ 採料遠端：goal_resolver.gd:1174-1175 _mk_delegate_candidate(… PREREQ_LOCATION …, {"build_type":"civilian","target":best_pos})。
 ④ infra (3)：faction_ai_system.gd:6559 _dispatch_builder(state, leader_team, loc.pos, outpost_type, 1)。
 ②③④ 都落到 faction_ai_system.gd:5510 _dispatch_builder（③ 經 _dispatch_goal_delegate 的 build_type 分支 :5885-5889）。同 tick 出發；開工在子隊抵達（outpost_system.gd:1046-1052 begin_subteam_construction → start_build）。
 ① 同 tick 開工／續建，或走回營地（多 tick、move_target）。

「還有沒有第五條」——有，請 HOW 先決定算不算：
 a. 紮根的子隊版：faction_ai_system.gd:4487 對 sub 呼 _commit_settle_site（其他呼叫點 :4033 母隊、:4782、:7349 求生路）。四個呼叫點都落 :7436 同一個 start_build ⇒ 紮根執行端是一支函式、四個進口。
 b. 紮根的委派變體：goal_resolver.gd:563-576 _delegate_variant 把 TASK_BUILD／TASK_SETTLE 自候選包成 delegate（settler＝clampi(pop/4,2,5)）；→ _dispatch_goal_delegate 的 generic 分支 faction_ai_system.gd:5902-5911，沒有 build_type ⇒ 不走 _dispatch_builder，直接 SubteamSystem.dispatch(…, settler, TASK_BUILD, target)。這是「第二條派建點子隊的路」，用 settler(2–5) 不是 6。
 c. 營地（L0）建立：establish_crude_camp（faction_ai_system.gd:7220）的呼叫點 ——:3078（_tick_solo_settle）、:3092（村遷移完成）、:7076（TASK_CAMP 抵達）、subteam_system.gd:20（子隊到場 CAMP）、player_command_system.gd:1091。它只寫 camp_level=1（尚非 outpost），是紮根的前置；但 :3078 註解寫「空地 founding（新 level-1 outpost）」與函式體不符（過期註解）。算不算「開點」是 WHAT，我不裁，請問藍圖。
 d. 玩家路：player_command_system.gd:1105、:1426 start_build；玩家隊不走目標迴圈，HOW 範圍聲明即可。
更正我自己：先前審 §三之三 時我稱派出的建點子隊 task 是 TASK_BUILD，實際 _dispatch_builder 派 TASK_CONSTRUCT（SubteamSystem.dispatch(…TASK_CONSTRUCT…)）；合併後 new_outpost_commitment（need_oracle.gd:208-232）照 TASK_CONSTRUCT 讀，沒出事，只是我當時措辭不精確。
```

# P4 ✓ 現有前置種類不能直接承接「開點地點」
```
· PREREQ_RESOURCE → _resource_prereq_candidates（買／採／守）。
· PREREQ_LOCATION → _resolve_location_prereq（goal_resolver.gd:1462-1481）：參數 {terrain, control?}；已有自家據點且地形吻合就回 {}（視為滿足）；否則 find_nearest_known_tile／find_nearest_terrain_tile 找【最近】可達格，產 {"task":TASK_MIGRATE,"target":pos}（_mk_candidate :1484-）＝把隊移過去，不是選址、不看分數。
· MANPOWER／FACILITY／SUBGOAL：frontier_candidates 內 :315-317 註解「S4-S6（無 candidate，stub 邊界）」，kind 不是 RESOURCE／LOCATION 時 cand 保持空 ⇒ 不出候選。
⇒ 你的結論成立：要讀結構輪的選址秤（_evaluate_new_outpost_location，含 gather_term、M8 濾除），只能新寫一種 location 解法（或新 kind），不能用 :1462。
補充：「已有自家據點就視為滿足」（:1469-1471）對開點是反向的——有據點的隊反而是最該開第二點的隊；新解法不可沿用這條。
```

# P5 ✓ payoff 會掉進維持類公式
```
derived_payoff（goal_resolver.gd:194-221）：設施列讀 FACILITY_DEFICIT_DEF.outputs 缺口×價；其餘取 prereqs 第一個 PREREQ_RESOURCE 的 res（:213-218）：
  無資源前置 ⇒ 回 def.payoff 表值（:219）；有 ⇒ (pop×TARGET_PER_POP[res] − 持有)×BASE_PRICE[res]，clamp ≥ 0。
開點列若掛 material 前置：res2="material" ⇒ 掉進維持類公式 ⇒ payoff 是「我缺多少料」不是「開一座點值多少」。✓ 你的判斷對。
兩個邊角：
· 只掛 location 的列走表值（:219）——N 隊同值＝tie（:186-193 注釋寫過 tie 上千次）。
· 缺料越多 payoff 越大＝缺料越想開點，方向是反的。payoff 要另寫一支，輸入是開點本身的價值（§三之二 的 productivity 先驗、距離、採料天數），不是持有量。
```

# P6 ✓ 需求帳接點：只改一支
```
合併後的實作比信上多一層：
· 單一來源：NeedOracle.new_outpost_commitment（need_oracle.gd:208-232），回 {kind: gather|walk, type, level, tile} 或 {}。
· 它的呼叫者只有兩個：_new_outpost_need（:238）、新點迫切（:269）。全庫（非 debug）grep 無第三個。
· _new_outpost_need 的呼叫者：_construction_need（:261）、order_system.gd:342（買單 "for":"new_outpost" 判斷）。
· _construction_need 的呼叫者：need_oracle.gd:122（need_keep 建造加數）、trade_valuation.gd:137（reserve）、coin_treasury.gd:54。
⇒ 把「掛上的開點目標」加進需求帳，只需在 new_outpost_commitment 加第三種 kind，下游自動跟著走。✓ 只改這一支。
注意兩件：
 1. 下游對 kind 是二選一：_new_outpost_need 取量 `if kind=="gather" … else 整筆成本`（:241-245），第三種 kind 落進 else（整筆），是想要的；但 Probe 鍵 "need.new_outpost."+kind（:249-251）會多一個鍵，N1／N3 的斷言要補。
 2. 「掛上而未出發」的隊不在路上、不在工地，讀到的是 goal_state 元素，不是 task／move_target；tile 必須由元素的 target 欄供給（見 P8）。那格是遠端的：感知鐵律要想——成本與地形先驗走 site_prior，不讀遠端真值。
```

# P7 部分 ✓
## 人數：多一份，派出人數兩種
```
· 派建點子隊的「母隊最小人數」12：faction_ai_system.gd:5583-5585（pop=maxi(6, level*4)；population < pop*2 擋；L1=12）。TEST VALUE 註解屬實。
· 同一個 12 的第二份拷貝：decision_context.gd:900-903（_settler=maxi(6,1*4)；population >= _settler*2 ⇒ can_expand）。注釋寫「沿用 _dispatch_builder 既有規則」——是手抄，不是呼同一支（擴點的 applicable 與執行端各一份，改一邊另一邊不跟）。
· 「派了之後母隊剩多少」的另一套：MIN_PARENT_POP_AFTER_DISPATCH=10（faction_ai_system.gd:187），用在 :899-900（_dispatch_subteam_settle：settler=clampi(pop/4,2,5)，pop−settler<10 擋）與 goal_resolver.gd:568-569（_delegate_variant：同式）。
· 實際派出人數：_dispatch_builder 傳 pop=6（SubteamSystem.dispatch(state, leader, advisor, pop, TASK_CONSTRUCT, target)）；generic 委派分支傳 settler=2–5（faction_ai_system.gd:5908-5909）。你讀到的「6 對 2–5」屬實。
· 母隊剩多少：builder 路 pop≥12 時剩 ≥6；settle／委派變體路剩 ≥10。同一件事兩路兩個數，一個寫成「2×派出人數」，一個寫成「絕對 10」。
⇒ 藍圖說「12 該翻成秤、與 MIN_PARENT_POP_AFTER_DISPATCH 同源禁兩份」：現況是 12 在 :5583 與 decision_context:900-903 兩處，10 在 :900 與 goal_resolver:569 兩處。HOW 要定一個來源。我不裁用哪個數。
```
## 擋下多少、被擋的去哪
```
已有的數（implementer 交件信 2026-10-17-implementer-to-systems-DONE-structure-round-probes-v8-not-passed-worldfp.md:37-55）：修後 warring：attempt 573、busy_subteam 6、site_barren 145、no_advisor 257、pop 165、派出 0；factioned no_advisor 74。
· 「被擋的本來會去哪」code 上讀不出來：:5583 之後無備援，return false 回 delegate.build_fail；失敗只進 _log_dispatch_fail（:5580、:5586）與 FailureMemory。HOW 驗收要量：被 pop 擋下的隊，之後幾日做了什麼 option（argmax 次佳）。
· 排序注意：no_advisor（:5579）在 pop（:5583）之前。pop 計數是通過 advisor 之後才數的；兩數不是同一母體的並列，不能直接比大小。
```
## 帶隊人 ✓ 是物理，但有一條副作用順序 bug
```
· _pick_or_promote_advisor（faction_ai_system.gd:5860-5868）：_pick_advisor（:5502-5506）回 named_members 裡第一個非 leader；沒有 ⇒ PersonGenerator.generate_for_team（person_generator.gd:86-91）：
    named_count＝(leader 在 ? 1 : 0)＋named_members.size()；anon_pop＝population − named_count；anon_pop ≤ 0 ⇒ return null（person_generator.gd 內 `return null` 只此一處 :91）。
  ⇒ 回 -1 的條件＝「沒有非領袖具名成員 ∧ 沒有可升的匿名人」。named_members 為空時即 population ≤ 1；named_members 非空時 _pick_advisor 不會是 -1。
  ⇒ 這是物理（沒人可派），不是門。
· 但 257 次 no_advisor 的隊是否 population ≤ 1？靜態讀只能說「條件上如此」。若 warring 有 population≥12 的隊落在這裡，代表 population 與 named／anon 記帳不一致（anon_pop 算出 ≤0），那是 bug 不是物理。交件信沒有 pop 樣本。請在 no_advisor 處加 bump_sample（pop、named、anon_pop、leader_id），一輪就能分。
· 順序 bug（新發現）：_pick_or_promote_advisor 在 :5579 有世界寫入（generate_for_team 內 state.persons 新增、AnonTierSystem.kill_random、領 anon_treasury×3 的獎金 person_generator.gd:95-100；state.add_member faction_ai_system.gd:5867），而其後的 pop 門（:5583）、糧橋門、SubteamSystem.dispatch 失敗都能 return false。
  ⇒ 被 pop／糧橋擋下的嘗試，已把一名匿名人升成具名人。下一次嘗試 _pick_advisor 會直接找到他，不會每次升，但失敗的嘗試有世界副作用。這與 options.gd:334-336 紮根為避免 zombie 工地而把世界寫入放 commit-hook 的原則相反。
  建議（你定）：升人移到所有 return false 之後、SubteamSystem.dispatch 之前，或先用純查詢判斷「能不能有帶隊人」，真要派時才升。
```

# P8 ✓ 欄位有，但撞設計規則
```
· goal_state 元素今天的欄位：{"goal_type","target","created_tick","status"}（goal_resolver.gd:36-37、:106-107 兩處寫入，皆 `"target": null`；測試床 means_end_s1／s2／s4_test.gd 也都建 `"target": null`）。target 欄存在。
· 讀者：全庫 grep goal_state——goal_resolver.gd、decision_engine.gd、observer_query_api.gd:120（duplicate(true) 給觀察者）、state_fingerprint.gd:398（_arr_canon(t.goal_state) ⇒ 每個元素 str(x) 進指紋）、team_data.gd:191 宣告、commitment_fields.gd:34 註解。
  沒有任何程式讀 g["target"] 或 g.get("target")（goal_resolver.gd 內 get("target") 只命中 to_task／candidate 的 target：:1333、:1577）。⇒ 沒有讀者假設 target 恆為 null。
  指紋：state_fingerprint 會把 Vector2i 目標字串化 ⇒ 只在真的有開點目標時才變；沒掛的世界指紋不動。
· 撞設計規則：
   goal_resolver.gd:4-6 檔頭「唯讀合成、每 tick 重算 transient frontier（不寫回 goal_state＝無 plan-state，守 HOW §9）」；
   commitment_fields.gd:34「goal_state：長期目標＝慾望層，尚未開始的不算承諾」。
  把選定的格寫進 goal_state[i].target 並跨日持有，就是把 plan-state 寫進 goal_state，與 HOW §9 對立。藍圖 WHAT 2 說「跨日持有＝既有 goal_state」，但 goal_state 目前被設計成只存慾望、不存計畫。
  這不是 code 障礙，是一條書面規則；要不要鬆它是藍圖／你的決定（WHAT 與架構），不是我的。HOW 必須明說：(i) 鬆 §9 並改 commitment_fields.gd:34 與 goal_resolver.gd:4-6 的註解；或 (ii) target 不存，格每次由選址秤重算（那就沒有「跨日持有一個選定的格」）。
· 先例：team.expand_site_cached（decision_context.gd:895-897）已是「每隊一個選定的候選格」快取，由 gather() 寫（有 advance／observe 兩種模式計數）。plan-ish 狀態在 team 上，不在 goal_state 上。它的過期條件我沒追，未驗。
```

# 給 HOW 入口的幾句（不是裁決）
```
1. 新列不讀 otile（P2）。
2. 新 location 解法要新寫（P4）、payoff 另寫（P5）、需求帳只動 new_outpost_commitment（P6）。
3. 「派建點子隊」的人數規則與帶隊人先定單一來源（P7），advisor 升人移到所有 return false 之後。
4. goal_state.target 能不能放格＝先過 §9（P8）。
5. 母體：四條＋紮根子隊版＋紮根委派變體（P3 a、b）；營地 L0（c）等藍圖裁算不算。
```

# 判決
```
R①：無需 halt 的 premise_contradiction。
P2：藍圖信前提錯（對你有利），請你回藍圖更正。P3 母體、P7 手抄與副作用、P8 的 §9 請寫進 HOW 前提段。
不加門。
```
