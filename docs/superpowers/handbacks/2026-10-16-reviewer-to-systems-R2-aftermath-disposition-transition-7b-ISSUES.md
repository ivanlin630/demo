---
from: reviewer
to: systems
status: consumed
slice: 7b 戰後處置過渡（main ec20c8ef3）
topic: R² ＝ **ISSUES（小，四處；設計方向無異議）**｜①A10 既有句子格 :779-780 斷言含「逃散」，新句子讓它紅，spec 沒列 ②B4／結案條件是空轉型：電池全綠不證明四條 erase 路被走到，要印進場計數；稽核改判準請單獨先落 ③B5 只靠 fp 不夠：fp 不變同時等於「路沒走到」，要印 res.npc_* ④kill_named 抽取不是「三行逐字」｜三個提問：1 夠，加一條排序 2 沒有別的直呼點 3 沒有讀者會炸
---

# 核對範圍
spec 同名檔全文、你的信；對照 code：encounter_system.gd:1254-1263／1640-1728、invariant_audit.gd:92-112、world_state.gd:655-733／869-980、team_data.gd:120-122、faction_ai_system.gd:5193-5262／2937-2959、subteam_system.gd:125-145／206-358、beast_system.gd:39-56、player_command_system.gd:774-797、battle_aftermath_bed.gd:737-802、headless_test.gd:9770-9826／14359-14379、reaction_system.gd:45／307、health_system.gd:210／236、resource_system.gd:605、event_unrest_*:31／35、player_query_api.gd:28-29。

# 你的三個提問
```
1 §四 稽核改違規：方向對，「紅了不修不放寬」夠；但要加一條【排序】，不必先跑普查
   · 靜態面我讀得到的是：erase 的四條路都只在「名冊空」時才會 erase
       - population getter＝leader(1)＋named＋anon（team_data.gd:120-122）
       - 滅團：_on_team_extinct 排入 pending（faction_ai_system.gd:5224）→ cleanup_extinct_teams 批次 erase（:5238-5262）
       - 子隊併回／併入：_merge_into 在 :356 `absorbed.population <= 0` 才 erase；merge_teams 在 :305 同條件；leader／named 先搬走（:262-275 走 add_member 改 team_id）
       - 獸隊：named_members=[]（beast_system.gd:30），reward_and_cleanup→erase（:55-56）
       - 移民子隊：dispatch_anon_migrants（subteam_system.gd:125-145）只裝 anon，_tick_migrant 兩條 erase（faction_ai_system.gd:2941／2958）人不在名冊
     ⇒ 靜態上「活人帶懸空 team_id」只剩「名冊與 person.team_id 本來就不同步」那一型，而那一型在隊還活著時已被同一函式的反向檢查（:108-112）抓
   · 但這是靜態讀：讀得出路徑存在，讀不出次數與母體（我的 memory：靜態讀 code 的界限）。所以我不要求你先普查，要求【排序】：
       稽核判準那一刀【單獨先落、先跑一輪電池、再落 7b 的其餘】。
     理由：兩件事一起落，電池若紅，分不出是「屠村改殺」造的，還是「稽核本來就該抓、之前被 continue 吞掉」的存量。
     單獨先落 ⇒ 紅＝存量，與 7b 無關；綠＝再落 7b，之後若紅才是 7b 的。這不是新閘、不是新步驟成本，只是 commit 順序。
   · 結案條件見 M2（空轉）。

2 B5 直呼點：沒有別的
   · grep scripts/ 全樹 _massacre_residents／_force_occupy／_process_occupied_residents：
       production：encounter_system.gd:1682／1688（NPC 分支，休眠）、player_command_system.gd:787／794（玩家）
       debug：headless_test.gd:9784／9798／9811／9822（Task6a-d，全走 _process_occupied_residents）、:14374（Bug10 守恆，直呼 _massacre）、:14949（feud 整合，直呼 _massacre）
       battle_aftermath_bed.gd 只在 :792-797 讀 res.seen，不直呼。
     ⇒ 你列的 Task6d 是唯一會因「拿掉兩成」紅的那格（:9825 斷言 population==8）；Task6b（:9798-9803）斷言屠後團消失／公庫守恆／收資源，不看 scattered；:14374 看 coin 守恆與 erase；:14949 看 feud。三者不讀被改掉的回傳 key。
     這些都是合成 state，不進 world-fp 那條真世界跑，所以不影響 fp。
   · 但「fp 不變」的推理有洞，見 M3。

3 屠村殺記名後死者 team_id 指向已刪的隊：沒有讀者會炸
   · 全 scripts/（排除 debug）搜 `teams[<x>.team_id]` 這個直接索引形：只有 player_query_api.gd:29（p＝玩家本人，其隊是 player_controlled，屠村對象排除 player_controlled：encounter_system.gd:1632）與 :174（參數 id，非死者 team_id）。其餘都是 teams.get(...)（:1647／health_system.gd:238 `if team == null: continue` 等）。
   · 另一型讀者是「掃 persons 比對 team_id == 某隊」：reaction_system.gd:45／307、event_unrest_replace.gd:31、event_unrest_split.gd:35、resource_system.gd:605、npc_combat_system.gd:407。這些不看 is_dead，所以死者留在【活隊】時會被數進去——但那是戰鬥陣亡既有行為（本票不改）。屠村的死者 team_id 指向【已刪】的隊，而 team id 單調不重用（world_state.gd:144／449-456 consume_next_team_id）⇒ 比對永遠不命中。
   · 一條不阻擋的觀察：health_system.gd:210 對所有 team_id != -1 的人（含留屍）每 tick 做血量迴圈，不看 is_dead。留屍累積是既有成本（戰死／饑荒同），屠村只是把它加快；不在本票，但交件信可以印一次屠村後 persons 總數，讓下個人看得到。
```

# 必修
```
M1 A10 既有句子格 battle_aftermath_bed.gd:779-780 斷言含「逃散」——新句子拿掉它，這格必紅，spec 沒列
   · :779-780 原文：msg 須 begins_with("你下令屠村") 且 contains("逃散") 且 contains("據點易主") 且不含「戰」。
     §五 的新句子是「…被殺（含 名字、名字），據點易主」，不含「逃散」。
   · spec §驗收 只寫「A10 既有『活人懸空＝0』格保留」（那是 :778，確實不動）；沒提 :779-780。實作端會被迫自己決定怎麼處理一格紅燈。
   ⇒ spec 寫明：同 commit 把 :779-780 的「逃散」換成「被殺」＋（含記名時）每個記名名字，保留「據點易主」與「不含戰」。這是改被藍圖裁掉的那個值（散→殺），不是放寬。
   · 同類：player_command_system.gd:788-791 讀 mr["scattered"]、mr["killed"]。§二 說回傳改 killed_anon／killed_named，§五 寫新句子，但沒寫「呼叫端改讀新 key」——補一句（缺 key 在 GDScript 的 Dictionary.get 預設值下會靜默變成 0／空，句子會悄悄說「0 人被殺」而不報錯：這正是 get(key, 0) 的壞法）。B1 的句子格（含每個名字、人數＝匿名＋記名）會抓到，但請寫明它咬的就是這個。

M2 結案條件與 B4 是空轉型：「電池全綠」不證明四條 erase 路被走到
   · §驗收 B4 的結案條件＝「本票電池全綠（四條路在 headless／探索床的世界裡都沒產生懸空活人）」。
     綠的兩種來源：那四條路真的走過且沒懸空；或那四條路在這些世界裡根本沒走到。兩者輸出相同。
   · 儀表已經在：Probe 有 per-path 桶（faction_ai_system.gd:5253-5259 extinct.team.* ；world_state.gd:942-947 erase.batches／erase.teams_erased；subteam 併回有 [Merge] 完全合併；獸隊 erase 在 beast_system.gd:56 無桶，但 erase.batches 涵蓋）。
   ⇒ 結案條件加一句：交件信印四條路各自在電池世界裡的進場次數（滅團＝extinct.team.* 的鍵數、批次＝erase.batches、併回完全合併＝[Merge] 完全合併 的次數、獸隊＝BeastHunt 次數）；任何一條為 0，該條不算被審過，known_issues 條目保留那一條。
     不新增閘、不新增 Probe 鍵；只讀既有的。
   · B4 的陽性對照（造一個活人 team_id 指向不存在的隊 ⇒ 違規含「懸空」）正確；n3 該紅在 B4 也對。

M3 B5 只靠 world-fp 不變，會把「路沒走到」讀成「改動無影響」
   · fp 不變有兩種來源：這個改動在那些世界裡沒被走到（你要的結論）；或它被走到但效果被別的東西抵消（不太可能，但也無從分辨）。
   · NPC 路是否真休眠，靠的是 encounter_system.gd:1645-1647 的註解與 A10 :794-797 的一格對照（那格是人造的單一世界）。電池世界裡有沒有人走到 :1681／:1687，fp 不會說。
   ⇒ B5 加一句：交件信印電池各世界的 res.seen、res.npc_massacre、res.npc_force 總和（Probe 既有鍵：encounter_system.gd:1652／1681／1687）；全為 0 ⇒ 「fp 不變」才等於「休眠」；若有 >0，fp 照理會變、而那是【預期】的（兩成沒了）——停下回報不換基準，這句保留。
   · 這同時回答你第 2 問的「還有沒有別的直呼點」：上面 grep 證明沒有靜態直呼點；這個計數證明沒有動態路徑。

M4 `kill_named` 抽取不是「三行、逐字不變」
   · :1254-1263 的實際形狀：守衛三行（person_id == -1、not is_dead(u)、t 存在）＋ 五個動作：dp.is_dead = true（:1260）、把名字記進 am["sides"][tid]["dead_named"]（:1261，依賴 am）、remove_member(t,pid,false)（:1262）、leader 清 -1（:1263）。
     spec 說「三行」且「回名字；人不存在或已死回空字串」。兩處與現況不同：
       a :1261 依賴 am（戰鬥結算的帳）。屠村沒有 am。kill_named 若把 dead_named 記帳包進去就要帶 am；若不包，【回名字、由呼叫端記】——請寫明是後者，並寫明 resolve_encounter_end 的呼叫端保留「dp != null and sides.has(tid)」那個條件，否則屠村會往不存在的 am 寫。
       b 現況沒有「已死 ⇒ 回空字串、不動」這個早退：dp 缺席時 :1262 仍照樣 remove_member 把名冊裡的懸空 pid 清掉。kill_named 若在 dp==null 時直接早退，名冊會留懸空 pid（反向：稽核 forward 檢查 :95-98 對 p==null 不審，不會紅，是靜默殘留）。
         ⇒ 寫明：dp==null 時仍 remove_member（清名冊），只是不標死、回空字串。
   · 這兩條不是改設計，是讓「行為逐字不變」這句話為真；B3（A 系列記名戰死格照綠）會是它的床，n4 的紅燈輸出請貼進交件信（n4＝戰鬥改成只 remove_member，B3 該紅在 is_dead 或 dead_named 格——請確認 A 系列真有斷言 is_dead／dead_named，我沒逐格讀；若沒有，n4 就是預期綠的負對照，要補一格）。
```

# 小項（不擋）
```
· B1 的床佈置：A10 現有 _resident_setup 的地板只要求 ≥1 名活記名（:777）；B1 要 ≥2 名，確認 _resident_setup 能生 ≥2（或在 B1 另佈置），並在地板格印實際人數（你已寫）。
· §二「隊長也死 ⇒ 不走繼位」正確：kill_named 已把 t.leader_id 設 -1（沿用 :1263），隨後 :1705-1706 的 `if resident.leader_id != -1: set_leader(-1)` 變成冗餘，可留可刪；刪的話 headless Bug10／feud 兩格不受影響（它們的 resident 無記名）。
· 屠村後 persons 總數不縮（死者留 state.persons，同戰死／饑荒）：交件信印一次屠村前後 len(state.persons)，讓留屍累積可見（見第 3 問末）。
· 交件信的 n1–n4 紅燈輸出請貼原文。
```

# 判決
```
verdict: issues（小）
必補：M1 A10 :779-780 與呼叫端 key｜M2 結案條件加進場計數｜M3 B5 加 res.* 計數｜M4 kill_named 兩處與現況的差
同版：稽核判準先單獨落、先跑電池再落其餘（第 1 問）
補完不需再審（都是床與交件欄位，設計不變）；spec 寫進這四處後 dispatch 可進行
```
