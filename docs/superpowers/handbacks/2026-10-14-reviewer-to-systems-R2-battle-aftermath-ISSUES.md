---
from: reviewer
to: systems
status: consumed
slice: R² 第 7 張戰後收尾（c72b16b7e）
topic: R② ＝ **ISSUES,兩處擋**｜①【三個守衛容量,兩個人格讀者】:spec 的 guard_budget（人口上限制）與 manpower 的 _enforce_guard_cap（看守比×3）是兩套不同的容量;玩家俘到 budget 允許的數量後,下一個 captive tick 的 _enforce_guard_cap 會依【附身者的殘忍】把超額殺掉或放掉——spec 只攔了 decide_treatment 與 _decide_guard_ratio,漏了 manpower_system.gd:233-262 這第三個人格讀者,A5/A7 會被它悄悄打破;②『未決擋推進』是專案裡沒有先例的硬模態（強制事件不擋推進,是停點＋逾時）:request_advance 沒有任何閘,要寫清擋在哪、逃生口（放走永遠可用）、與 choose_heir／game_over 的交疊、E2E 床受影響清單,否則是軟鎖風險;另:encounter 的 draw 分支實際打不到、沒有逾時,A8b 的『平手／逾時』佈置要改造法;NPC 三分數是純人格,域專判斷器要穿記憶/現況;記名被俘含玩家本人
---

# 0 審了哪棵樹
main c72b16b7e。核對 encounter_system.gd:95-120,596-640,915-945,1195-1340,1366-1375,1410;sim_runner.gd:625-650;health_system.gd:165-200;anon_tier_system.gd:120-146,162,234-330;
manpower_system.gd:28-100,225-300;npc_combat_system.gd:609-634;sim_bridge.gd:44-90;observer_bridge.gd:32;全 scripts 對 resolve_encounter_end／decide_treatment／_decide_guard_ratio 的呼叫端。

# 1 ★擋①:容量與人格讀者——spec 漏了 _enforce_guard_cap
```
事實（manpower_system.gd）:
   ·decide_treatment（:36）讀領袖 野心／殘忍,並呼 _decide_guard_ratio（讀 慎重,:63-71）;
   ·tick_all（:279）每個 captive cadence 對每個持有者設 holder.captive_guard_ratio = _decide_guard_ratio(…),再【先】呼 _enforce_guard_cap,再逐 group 呼 decide_treatment;
   ·_enforce_guard_cap（:233-262）:guard_n = total_pop × captive_guard_ratio;cap = floor(guard_n × GUARD_CAP_MULT(3.0));total_captives > cap ⇒ 超額部分強制處置——
     領袖 殘忍 ≥ 0.5 ⇒「苛用」:按 REVOLT_COMBAT_LOSS 比例殺掉（_spawn_breakaway 的 slain);否則「釋放」成流民。這就是【第三個讀人格的決策】,而且動作是殺人。
spec 的相關改法:『玩家 holder 不呼 decide_treatment／_decide_guard_ratio,改讀 group 欄』——沒碰 _enforce_guard_cap,也沒說 holder.captive_guard_ratio（holder 層欄）與 group.guard_ratio（group 層欄,spec 新造）誰是真值。
後果:玩家選『俘』得 k=min(N, guard_budget) 人（guard_budget=effective_pop_cap − population − total_captives,capture_routed_as_captive 那條公式）;
   但 _enforce_guard_cap 用的是另一套容量（看守人數×3）。例:玩家隊 10 人、看守比 0.2 ⇒ guard_n=2 ⇒ cap=6;而 guard_budget 若是 20 ⇒ 玩家俘 15 人 ⇒ 下一個 captive tick 超額 9 人被【依附身者殘忍值】殺掉或放掉。
   ⇒ 這同時違反 #12（玩家隊的決策不屬 AI）與 spec 自己的『禁憑空消失／玩家待遇由玩家定』,而 A5（k=min(N,budget)）與 A7（decide_treatment 呼叫 0 次）都【綠】,因為它們看不到 _enforce_guard_cap。
要求:
   (a) 把『能留住多少』收成【一個】容量函式（spec 的 guard_budget 要等於 _enforce_guard_cap 的 cap 減已有,或反過來把 _enforce_guard_cap 改讀 guard_budget）,捕獲、2a、_enforce_guard_cap 三處同一支——『一個形狀一支身體』正好套在這裡;
   (b) 玩家 holder（用 possessed／player_controlled 事實欄,不是 leader_id==player_id——非領袖附身時兩者分叉）:_enforce_guard_cap 的超額處置不得讀人格;因為 (a) 之後玩家不會超額,可直接『玩家 holder 遇超額＝發事件、不處置』並把這條當守衛（Probe 計數恆 0);
   (c) A7 的 tap 要涵蓋【所有】讀 holder 領袖人格的 manpower 路徑（decide_treatment、_decide_guard_ratio、_enforce_guard_cap),不只前兩者;
   (d) 新增 A7b:玩家俘 k 人（k 接近 budget)後推 3 個 captive cadence ⇒ captive_groups 總數不變、無『苛用』『GuardCap』輸出、無 breakaway 隊產生;負對照:拿掉 (a) 的統一 ⇒ A7b 紅。
group.treatment／group.guard_ratio 欄:現有 group schema 是 {cohorts, morale, origin_faction, entry, treatment_history}（anon_tier_system.gd:259-265、312-318);加兩欄無妨,但
   holder.captive_guard_ratio 與 group.guard_ratio 並存＝兩份真值;建議只留 holder 層一欄（看守是 holder 的人手),group 只留 treatment。
```

# 2 ★擋②:『未決擋推進』是專案裡沒有的硬模態
```
你問的第 2 點。現況:
   ·SimBridge.request_advance（sim_bridge.gd:44）只是 `_ticks_remaining = n`,沒有任何前置閘;推進在 tick_step 遇事件停,不是被拒。
   ·強制事件（player_forced_event）也【不擋推進】:它是停點＋逾時自動拒絕（forced_event_timeout,SimRunner hour-tick 自動拒絕,sim_runner.gd:746),玩家不回應世界照走。
   ·last_encounter_result 的 take_loot／leave_loot／subjugate（player_command_system.gd:581-600…）是『可做的動作』,不擋任何事,下次遭遇戰開始時被覆蓋。
   ⇒ spec『未決之前推進鍵回「先決定戰後處置」』是新機制,不是接上既有形狀。
要寫清楚的:
   (a) 擋在哪:所有推進入口——X、空白、G 跳 tick、L 走到抵達(ADVANCE_UNTIL_EVENT)、PlayerRepl.press_on 的 while is_advancing 等待迴圈——共用的咽喉是 SimBridge.request_advance;擋在 UI 鍵處理（text_ui_main 各鍵)會漏掉 L／M／腳本;擋在 request_advance 則床/腳本直接呼叫也被擋——選哪個要寫,並加床:每一條推進入口各驗一次被拒。
   (b) 軟鎖守衛:每一種 pending（命運／追擊／居民）都必須【至少一個永遠可用】的動作（命運=放走,追擊=不追,居民=放棄佔領);precheck 失敗的選項（殺N=0、俘 budget=0)不得讓整組不可選。
       加格:對每種 pending 枚舉『所有選項 precheck 為假,除了逃生口』的世界狀態 ⇒ 逃生口仍可用、推進解鎖。
   (c) 與其他強制態的交疊:choose_heir 強制事件（玩家 leader 戰死,event_system.gd:96-100）與 fate_pending 同時成立時,誰先?玩家看得到的順序與句子;game_over（無繼承人）時 pending 要被清除而不是擋住『故事結束』畫面後的推進。
   (d) 凍結 vs 陳舊:擋推進＝世界凍結到玩家決定,所以 N（敵方 wounded 數）不會陳舊;若改成不擋,敵隊會在決定前走動／治療,N 失真。兩者取捨請寫進 spec;若採擋,就需要 (b)(c)。
   (e) 受影響的床:terminal_e2e_bed 的 BATTLE 系列（戰後繼續推進)、ui_flow 的戰後流程、multi_hop_move_bed 若有戰鬥;每一支戰後還要推進的床都要先解 pending——spec 的『會動的床』段沒有這一節,補列。
   (f) 觀察者／無玩家世界:fate_pending 只在 player_id≠-1 且玩家為留場方時成立;observer_bridge.gd:32 的 draw 路與無玩家模擬不受影響（明寫)。
```

# 3 你問的第 1 點:留場判準與 encounter 的收場路徑
```
✓ 用 is_combat_capable 而非 result 字串是對的,因為 result 字串根本不可信:
   ·advance_encounter_tick 末段（encounter_system.gd:930-932)的順序是:`if def_exited or (not def_alive and def_id != -1): return "attacker_win"`、`if atk_exited or (not atk_alive …): return "defender_win"`、最後才是 `if not atk_alive and not def_alive: return "draw"`。
     雙方同時無人可戰時,第一個條件先命中 ⇒ 回 "attacker_win"（def_id≠-1);"draw" 只在 def_id==-1 時可達。⇒ 正常流程【打不出 draw】;resolve_encounter_end 的 draw 分支只被 observer_bridge.gd:32 強制呼叫。
   ·全檔沒有回合上限／逾時結局（grep MAX_ROUNDS／round 上限無命中);遭遇只因『一方無 active unit』或『一方全撤』而結束。
   ⇒ 『雙方都留場而結算』不存在（迴圈到一方無 active 才結束,而 _has_active_units 排除 prisoner／exited／incapable);『雙方都不留場』存在,但結果字串是 attacker_win。
   ⇒ A8b『平手／雙方撤 ⇒ 零俘虜』的床佈置不能靠 result=="draw";要造『雙方同時全失能(或一方全撤、另一方同 tick 全失能)』,並【斷言 result 是 attacker_win 而零俘虜】——這剛好證明 spec 不看 result 的判準必要。
   ⇒ 修前紅也要重寫:現況 :1324-1334 在 result 有勝方時對『敗方』is_prisoner 單位加計數器,不問勝方是否真有人留場。
   (注意 :1295 `if result == "draw"` 早退分支對玩家流程基本是死碼,別在它上面掛新邏輯。)
留場謂詞細節:`is_combat_capable` 不檢查 is_prisoner;被押單位本來就是不可戰者,無影響;但 has_exited 要一併排除（你的第 0 步已含)。
```

# 4 你問的第 3 點:玩家 holder 的讀者清單
```
manpower_system.gd 內讀 holder 領袖人格的位置(grep values.get):decide_treatment(:37-39 野心／殘忍)、_decide_guard_ratio(:65 慎重)、_enforce_guard_cap(:241 殘忍)——共三處,spec 只列前兩處(見 §1)。
_check_trajectory／_apply_treatment／同化／暴動／逃:grep 無人格讀取,讀的是 group.morale、看守人數等物理量 ✓。
外部呼叫端:全 scripts 排除 debug,decide_treatment／_decide_guard_ratio／tick_captives 只被 manpower_system 自己的 tick_all 呼叫 ✓(沒有別的系統吃它們的回傳)。
另:『玩家 holder』的判定要用隊層事實(possessed／player_controlled),不是 holder.leader_id==player_id;附身者非領袖時,leader_id 是 NPC 領袖,人格讀的是 NPC 領袖——兩種判定會分叉(多格移動票已踩過)。
缺糧自動釋放(decide_treatment 的 food_per_cap<0.5 分支)是物理:你寫對玩家照跑並發事件 ✓;但那個判斷寫在 decide_treatment 內(:42-46),玩家 holder 跳過 decide_treatment 時要把它【搬出來】成獨立的物理檢查,否則玩家的俘虜永遠不會因養不起而放走(與 NPC 不對稱)。
```

# 5 你問的第 4 點:共用 helper
```
✓ 方向對。現況已有兩份『組 captive group』:absorb_as_captive 的 append（anon_tier_system.gd:259-265)與 capture_routed_as_captive 的 append（:312-318),欄位相同、只有 entry 字串不同(「吸收」／「潰逃-capture」);
   你新增第三份就是三份——抽成一支 `_new_captive_group(captured, origin_faction, entry)` 且順手把前兩份改呼它(否則變成『新增一支共用 helper 但舊兩份照舊』)。
guard_budget:同樣三處需要它(capture_routed 內聯的 :299-301 公式、你的新 absorb_wounded、2a 的押走),加上 §1 的 _enforce_guard_cap——四處;見 §1(a)。
absorb_wounded_as_captive 與 absorb_as_captive(rate) 的差別只是『取哪個 health 桶、取多少人』;_capture_from_health(anon_tier_system.gd:323)已經是 health-aware 的取人 helper,新函式應是它的薄包裝,不是第四種取人迴圈。
```

# 6 你問的第 5 點:NPC 勝方的三分數
```
kill＝殘忍、capture＝貪婪(且 budget>0)、release＝義氣,取最大(同分 放>俘>殺):
·『禁門檻梯』:取最大不是門檻梯,tie-break 順序也只在同分生效 ✓ 沒有違反。
·但憲法說域專判斷器『合法＝真穿 人格／記憶／現況＋讀同一組人格值』(invariants #域專判斷器):這支只穿人格,沒穿記憶(對敗方領袖有 feud／gratitude 邊嗎?DiplomaticAiSystem._edge_intensity_to 已有讀法)、沒穿現況(養不養得起俘虜:ResourceSystem.effective_food 與 captive 日耗,decide_treatment 已有 food_per_cap<0.5 的判斷)。
  建議:至少把『養不起』併進 capture 的分數(budget>0 之外再看糧),並讓 release 吃『對敗方領袖的好感邊』。不然 NPC 會在糧盡時照樣俘人再於下個 captive tick 因缺糧放走(折騰人口與事件)。
·尺度:相鄰的 _apply_pursuit 用 round(殘忍×2.0+貪婪×0.8)(npc_combat_system.gd:623)夾 [0,3];命運用三個 0..1 原值互比。同一場戰後兩個人格函式尺度不同,不是錯,但請在 spec 一句話交代為什麼(命運是三選一的相對比較,追擊是砍數)。
·★記名失能者:spec 的 NPC 勝方只談匿名 N。玩家隊的【記名】失能者(含玩家本人若倒地)NPC 勝方要不要『殺』?若有,玩家角色會在結算當下被人格最大值確定性殺死(無 RNG、無抵抗窗),走 handle_player_succession。
  這是巨大的玩家可見後果,而且 spec 沒寫:請明確(a)NPC 勝方對玩家記名失能者:只能俘/放(但記名俘虜帳不存在 ⇒ 實質只有放),或(b)殺但玩家本人豁免,或(c)全按人格——這是 WHAT,請藍圖定;預設我建議 (a)。
```

# 7 你問的第 6 點:A1 母體
```
人口會變的結算點:resolve_encounter_end 內 kill_random（匿名陣亡,:1258)、記名戰死出隊（:1233-1241)、敗方後備連坐（_apply_reserve_casualty,:1195)——三者都在 beast／draw／一般【分岔之前】,所以三條結算路都會改人口 ✓ A1 的『四場(勝／敗／平手／野獸)』覆蓋三條路。
  但因為 "draw" 打不出(§3),『平手』這一場要改造法(雙方同時全失能 ⇒ 結果其實是 attacker_win);另加一格 observer_bridge 強制 draw 路(無玩家,不應發玩家事件:反向格)。
  野獸路:勝方得肉、獸隊 cleanup(獸隊 population→清除),也是人口變動來源;事件要含『獵得』;對野獸不做命運／追擊步驟(戰場上被標 is_prisoner 的單位在野獸遭遇不存在,_check_prisoners 對野獸 team id<0 不抓,encounter_system.gd:604-607)——spec 請明寫『野獸遭遇沒有命運/追擊/居民步驟』,免得 pending 在野獸路誤成立。
  A1 判準『人口變了而事件流沒有這則 ⇒ 紅』的比較單位:要 per-encounter（resolve_encounter_end 前後),不是 per-tick——結算後同 tick 的其他系統(飢餓、再生)也會動人口,會讓判準誤紅。
  還有一個漏洞:玩家指令 subjugate／take_loot(戰後動作)也會改人口/資源,各有自己的結果句,不屬 combat_end 事件;A1 只守結算那一刻。
```

# 8 其餘小註
```
·2a:『押方結算時仍有 is_combat_capable 單位在場 ⇒ 被帶走』:_check_prisoners（:596-612)是『失能者身旁 1 格有敵人』即標;敵人隨後被殺/撤離,被押者仍帶 is_prisoner(_check_rescues 只在隊友貼身且無敵時救回,:625-640)。結算規則『押方全倒或全離場 ⇒ 回到失能者看留場』你已寫 ✓;補測:押方在結算前一刻才倒(同 tick)。
·記名被押『放回並寫明』✓ 誠實。
·prisoner_population 退場 + 換 fp 基準:計數器唯一讀者是指紋 ✓(已核);退場安全。
·『帶團頁一行』『日耗讀 CAPTIVE_FOOD_RATE』✓;A12 對帳『1 天後實際扣的糧』要把 captive cadence 的粒度寫進斷言(CAPTIVE_CADENCE 非每 tick)。
·combat_end 事件 kind 沿用 MESSAGE_KINDS 內既有名稱 ✓ 但 emit 路徑換成 WorldEvents.emit:要確認 describe 有它的句子(world_events.gd:98 只有簡稱『戰鬥結束』),玩家面零英文識別字,句子由單一產生者組(別在 encounter_system 裡手寫字串)。
·world-fp:除 prisoner_population 退場外,『NPC 勝方處置玩家失能者／追擊』是 NPC 對玩家,不動 NPC↔NPC;你的 census 證明方式(3 seed×30 天 npc_combat 計數)可以,補一格『玩家為留場方』與『NPC 為留場方』各至少一場出現在 census 母體,免得 census 本身沒碰到。
```

# 9 判決
```
verdict: issues
擋:§1（三處容量與第三個人格讀者 _enforce_guard_cap;玩家俘虜會被附身者殘忍值殺掉）、§2（未決擋推進:閘位置、逃生口、與 choose_heir／game_over 交疊、床清單）
同版補:§3（A8b 佈置、draw 打不出、無逾時）、§4（玩家 holder 判定用隊層事實、缺糧物理檢查搬出）、§5（helper 三份→一份、舊兩份改呼）、§6（NPC 判斷穿記憶／現況;記名失能者含玩家本人=WHAT,請藍圖定）、§7（A1 per-encounter、野獸路明寫）、§8
補完 §1 §2 後請重送一次我核（兩處都是會讓玩家看到錯誤結果的設計,不只文字）
```
