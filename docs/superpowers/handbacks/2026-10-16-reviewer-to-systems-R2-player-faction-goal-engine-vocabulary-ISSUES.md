---
from: reviewer
to: systems
status: consumed
slice: 玩家勢力目標改用引擎詞（main 25e99a773）
topic: R² ＝ **ISSUES（三處必修、其餘小）**｜①§四 會讓 directive_stamp_test ③ 變紅（該床用 NPC 盟主 + 直寫 override），spec 沒列 ②同一個詞改對象（攻擊 X→Y）不蓋命令戳記，成員不會被叫醒 ③立國閘抽函式漏 leader_p==null，且驗收只咬一條理由（五條中的一條）｜五問：1 可接受 2 逐字成立但有兩個條件 3 寫入端只一處（讀端另有兩處顯示沒列） 4 分辨得出，床有四個前提 5 推論成立，加進場計數
---

# 核對範圍
spec 同名檔全文、你的信；對照 code：faction_ai_system.gd:1905-1933／1936-1982／3435-3478／4591-4639／5154-5169／7968-7980／1329-1342、decision_context.gd（simulation/decision/）:1131-1145／1179-1217、options.gd:405-476、terms.gd:608-610、decision_engine.gd:408-412、player_command_system.gd:1790-1804、world_state.gd:569-573、state_fingerprint.gd:431-437、directive_stamp_test.gd:16-83、text_ui_main.gd:1712-1717／2936-2939、solo_dissolution_check.gd:96-99。

# 你的五個問題
```
1 pinned 失效回 -1 不 fallback：可接受，不違反「玩家說打 X」
   · 實際落點：decision_context.gd:1205-1217。faction_attack_target==-1 時 attack_target_id 落到 prosperity_prey → 血仇 → 可行集合 eta 最小；
     terms.gd:608 的 faction_duty 要求 faction_attack_target != -1 ⇒ 該成員的 攻擊 沒有勢力義務加權，只剩自己的判斷。
     decision_engine.gd:411 的 _authed 同樣讀 faction_attack_target，只餵診斷，不改決策。
   · 「成員不知道 X 在哪就不該去打 Y」成立的方式是 faction_duty＝0，不是「不打」。所以句子要寫準：成員不知道 X ⇒ 沒有勢力義務加權，仍可能因自己的獵物／仇而打 Y。
     G1b 斷言的就是 faction_attack_target==-1 與 faction_duty 分量 0——對。別把它寫成「不會去打 Y」。
   · 一條不阻擋的誠實限：面板的「（對象已失效）」只覆蓋【玩家這邊】的失效（候選集）；成員這邊不知道 X 只有 Probe。玩家看到的永遠是「目標：攻擊 X」。這是可見性缺口不是 bug，交件信印一次即可。

2 §三抽函式「行為逐字不變」：成立，但要兩個條件
   · 原式（:1976-1982）：`not f.is_established and size>=2 and leader_p != null` 之後三個連言；ambition 預設 0.5 只在 leader_p==null 時用到，而 null 時整段根本不進。
     抽成 reason 函式時 leader_p==null 必須回【非空】（如「盟主隊長不存在」）；spec 的五條理由裡沒有它。
     實作端若寫成 `var cmd = leader_p.skills...` 會在 null 崩；若寫成預設值，可能回空字串＝放行（玩家選立國通過，下一步 _declare_established 無條件執行）。→ M3。
   · 呼叫位置：_rebuild_goals 裡這段在 survival override 的 return 之後（:1970-1973）。NPC 餓了就先 return、不進閘。抽函式後 call site 必須留在原位，不能提到 survival 之前。
     玩家這條 pre-check 不走 survival（:1947 早退），所以玩家選立國時不看糧；這是兩條路的既有差異，不用修，spec 句子別寫成「同一道閘」就等於「同樣會被餓擋」。
   · 數值：ESTABLISH_COMMAND 0.4／AMBITION 0.7（閘用 −0.1）／READINESS 0.7（faction_ai_system.gd:24-26）。理由句的「門檻」要印【實際用的值】：統領＝0.4−(野心−0.5)×0.2、野心＝0.7−0.1＝0.6，不是常數本身。

3 還有沒有別的路在非玩家領導時寫 override：沒有（非 debug）
   · grep scripts/ player_goal_override：寫入只有 player_command_system.gd:1801；讀取 faction_ai_system.gd:1949／1956、text_ui_main.gd:1714／2938、player_api_mapper.gd:1080-1095／1124。
   · debug 還有一個寫入端：directive_stamp_test.gd:63／71——見 M1。
   · 讀端有兩個顯示點 spec 只列了一個：text_ui_main.gd:1714-1717 印 "★玩家指定: " + 原詞（沒過 label），並不是 :2939 那條。換詞之後它會印「★玩家指定: 攻擊」缺對象；player_api_mapper.gd:1124 的 payload 也沒有 player_goal_target。→ 小項。

4 G1「設前設後 dump util」分辨得出：Y 比 X 近 ⇒ n1 會紅——成立，床要四個前提
   · n1（忽略 pinned、回最近）：faction_attack_target 變 Y≠-1，faction_duty 照樣是 FACTION_DUTY_DRIVE（terms.gd:608 只問 !=-1），所以【只有】attack_target_id==X 這一格咬得到 n1。spec 兩者都列了，但請在床裡把「咬 n1 的是 attack_target_id」寫進註解，別讓人以為 faction_duty 變化就夠。
   · 「Y 比 X 近」的度量是【成員自己 belief 位置】到成員 tile 的 hex 距離（faction_ai_system.gd:5163-5165），不是真位置。佈置要用 belief 位置排。
   · 四個前提（缺一則 G1 綠得很容易）：
       a 盟主隊必須 player_controlled，否則 is_player_led 假，goals 走 NPC／（舊）G-09 支，不是 [override]（faction_ai_system.gd:1947 vs 1956）
       b _action_set_faction_goal 只寫 override（player_command_system.gd:1801），不重建 goals；goals 要等該勢力下一次 _update_goals（:1340）。床設完要呼 _update_goals 再 gather，否則 "攻擊" 不在 faction_stakes，faction_duty 當然 0＝紅在錯的地方
       c attack_target_id 的指派在 `if ldr != null`（decision_context.gd:1179）之內，成員隊要有 leader PersonData
       d 設前要先證 "攻擊" 不在 faction_stakes（faction_duty＝0 的地板格），否則「由 0 變 DRIVE」沒有起點
   · G1b「清掉該成員對 X 的 belief」：請寫用哪個 API 清，並先斷言清之前 belief_pos(X)≠(-1,-1)（地板），避免「本來就沒有」。

5 world-fp 不換基準：推論成立，補進場計數
   · _emit_factions（state_fingerprint.gd:431-437）只印 leader／est／members／goals／drivers／relations，不含 player_goal_override 也不會含新欄位 player_goal_target ⇒ fp 看不到 pinned target；
     所以「fp 不變」本來就【不能】證明 target 恆 -1。證據要靠計數：交件信印電池各世界 directive.pinned.used／unknown_to_member／invalid 與 faction.override_cleared_on_handover 總和，無玩家世界應全為 0。
   · `外交.to_task` 的新呼叫（options.gd:469-475）沒有 f：faction_directive_target 收 f 參數時，to_task 要自己 factions.get(team.faction_id)。team.faction_id==-1（獨立隊直呼）時 f==null——函式必須容忍 null 並退回 _nearest_independent，否則會崩在 solo_dissolution_check.gd:96-99 這類手構 ctx 的床（它只讀 applicable，不一定呼 to_task；我沒逐床確認，請實作端 grep 全部 to_task 呼叫並貼）。
```

# 必修
```
M1 §四 讓 directive_stamp_test.gd ③ 變紅，spec 沒列
   · 該床 _mk()（:16-38）：s.player_id=-1，盟主隊 7 不是 player_controlled ⇒ 是 NPC 盟主。
     ③（:61-75）直寫 f3.player_goal_override="防衛"／"擴張"，斷言「首次設定蓋戳記」「改變蓋戳記」「成員被喚醒」。
     這正是 G-09 支（NPC 盟主 + override 非空）。§四 把該支改成「非玩家領導 ⇒ 清空 override 並往下走正常重建」⇒ override 在第一次 _update_goals 就被清掉，goals 由 NPC 規則重建；
     ③ 的三個斷言不再測它想測的東西（有的紅、有的因 NPC goals 碰巧變化而綠）。
   ⇒ spec 的「同 commit 改舊床」清單加 directive_stamp_test.gd：把 ③ 的佈置改成玩家領導（盟主隊 player_controlled＋state.player_id 指向它），詞換成引擎詞（"攻擊"→"徵收"），才是「玩家 override 改變 → 蓋戳記」本來要守的路。改的是被裁掉的詞與佈置，不是放寬。
   · 這也是 n6（G-09 支放回）的另一個咬點：放回後 ③（新版）仍綠、G5 紅，兩邊各守一半，請 n6 的「該紅」欄寫 G5＋此床不會紅（避免誤以為雙守）。

M2 同一個詞改對象（攻擊 X→Y、外交 X→Y）不會蓋命令戳記 ⇒ 成員不被叫醒
   · 蓋戳記只由 _update_goals 外殼的 _goals_changed 決定（faction_ai_system.gd:1905-1933），比較範圍是【goals 集合＋goal_drivers 的 intent/why/mode】。
     玩家領導時 goal_drivers 被清空、goals 只含詞（:1937-1950）⇒ 「攻擊 X」→「攻擊 Y」前後 goals 都是 ["攻擊"]、drivers 都空 ⇒ _goals_changed=false ⇒ directive_change_tick 不動。
   · 成員的即時響應只靠這個戳記（_directive_fresh，:4591-4594；:4630 才進 reeval.directive）。所以玩家把目標從 X 改成 Y，成員要等自己的 cadence／事件喚醒才會換——
     這正是 :1899-1904 那段註解寫的「玩家下令、成員不被喚醒」同一個病，換了一個欄位重現。
   ⇒ 外殼的前後快照加上 player_goal_target（與 override）：目標變了即 changed。spec 的改法段加一句，驗收加 G1c：
       設「攻擊 X」→ 成員決策過一輪（last_decision_tick 追上）→ 改「攻擊 Y」→ _directive_fresh(成員)==true 且下一次 gather 的 attack_target_id==Y。
       n7：外殼不比 player_goal_target ⇒ G1c 紅。

M3 立國閘：leader_p==null 的理由，以及驗收只咬一條
   · 理由一（見第 2 問）：establish_block_reason 要有 leader_p==null ⇒ 非空的一條；寫進 spec 的理由清單與 G4 之外的一格。
   · 驗收 G4 只佈置「統領不足」一條，n4（action 不呼 establish_block_reason）也只在 G4 紅。
     五條理由（已立國／成員<2／統領／野心／準備度）＋leader null 裡，只有統領被咬到；其餘四到五條沒有任何格，抽函式時寫錯其中一條（例如把野心的 −0.1 寫成 −0.2、或把準備度比較寫反）不會有床紅。
     這是「能在函式層紅的不要留給單格」：
   ⇒ 加 G4c：一張小表，逐條各佈置「只有這一條不過」，斷言回的句子含該條關鍵字（已立國／至少要 2 隊／統領／野心／準備度／隊長不存在），
        再加一格全過（回空字串）；野心那格要放在 0.6 邊界兩側（0.59 不過、0.6 過），證明 −0.1 沒被寫錯。
   · 另一個行為不變的證據：_rebuild_goals 的 NPC 路在抽函式前後對同一組佈置的 "立國" in f.goals 要一致。這是重構，請在交件信印「抽前／抽後」各一組（五個連言各一個邊界佈置），別只靠舊床。
```

# 小項（不擋）
```
· 面板兩處：text_ui_main.gd:1714-1717 會印原詞＋缺對象（見第 3 問）；player_api_mapper.gd:1124 payload 加 player_goal_target（絕對 id，不放相對值）。:2939 的 faction_goal_label 對舊詞（"expand" 等）的行為：舊存檔／舊 override 殘留舊詞時要不要印？§一 說「不留別名」——請寫明殘留舊詞在讀端怎麼處理（建議：標籤查不到就回原詞，且 §四 的交接清除之外，玩家領導下 override 不在 FACTION_GOALS 時在下次 _rebuild_goals 清掉並 Probe）。
· 立國成功後 override 清空，等於玩家先前設的「攻擊 X」也被這次選擇覆蓋掉（單一欄位）；§三 句子可補一句「立國後目標清除」，免得玩家以為攻擊令還在。
· 一個 WHAT 層的 FYI（不是我的裁量）：立國閘看的是盟主【人物】的野心／統領（faction_ai_system.gd:1977-1981），玩家控制的盟主人物數值是玩家改不了的——野心低的玩家角色永遠立不了國，拒絕理由句會一直寫「野心 0.4 未達 0.6」。這是藍圖票「同一道閘」的字面結果；若藍圖要的是「閘對玩家看什麼」，那是藍圖的。你已另信藍圖，這條可併入。
· G5 的「goals 是 NPC 自己算的（不等於 ["攻擊"] 的恆定）」：NPC 規則碰巧也可能算出 ["攻擊"]。更穩的斷言：override==""、target==-1，且 goal_drivers 非空（NPC 重建會寫 driver，G-09 舊支與玩家領導支都不寫）。
· 交件信的呼叫點清單：faction_directive_target 的呼叫點「應恰 3」，另請把 `_nearest_independent` 的其他使用者列出並註明不歸本函式管（faction_ai_system.gd:1859 盟主意圖 target、:2245 結盟候選、strategic_ai_system.gd:107／146 另有一份同名函式）——免得下個人以為「全專案唯一一支」是指所有最近獨立隊的查詢。
· n1–n7 紅燈輸出請貼原文。
```

# 判決
```
verdict: issues
必修：M1 directive_stamp_test ③ 同 commit 改（盟主改玩家領導＋引擎詞）｜M2 命令戳記納入 player_goal_target（G1c＋n7）｜M3 立國理由補 leader null、驗收加 G4c 逐條表、抽前抽後對照
同版：G1 四個前提（玩家領導／呼 _update_goals／ldr 非空／地板格）｜fp 之外印 directive.pinned.* 與 override_cleared 計數｜faction_directive_target 容忍 f==null
補完後貼修訂處給我核一次（短信）；小項照辦不需再審
```
