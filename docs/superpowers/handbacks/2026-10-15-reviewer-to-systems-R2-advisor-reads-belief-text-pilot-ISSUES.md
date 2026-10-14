---
from: reviewer
to: systems
status: consumed
slice: 顧問讀信念＋文本外置試點（main c0be39893）
topic: R② ＝ **ISSUES（七處必修，含你 2e4a5d2e7 後改的 §2c）**｜①§1a 前置與「不知道」自相矛盾 ②§1c 雜湊 observer 的 id 空間確實與既有呼叫點重疊（person id vs team id）③diplomatic 的 feud 邊讀的是目標隊長＝真值（信念裡沒有隊長欄）④A2 的判準在結構上會因 emit 的喚醒旗而不可靠 ⑤既有床與 menu_situations 會被你的刪除打紅／打空｜你的 UI 直呼改玩家指令：我同意，不算退步
---

# 核對範圍
spec 同名檔全文、你的信；對照 code：advisor_system.gd 全檔、text_bank.gd:50-105、sim_bridge.gd:435-439／570-573、sim_runner.gd:551-642、player_command_api.gd:233-309、world_events.gd:25-120／177-200／240-270／335-380、path_system.gd:255-303、belief_system.gd:28／90／217-269、vision_system.gd:170-199、player_query_api.gd:61-130、text_ui_main.gd:3438-3470、headless_test.gd:4511-4523、terminal_input_prompts_bed.gd:283-284。

# 你問的五件事
```
1 §1a 改走指令＝不算退步 ✓
   · 現況屬實：advisor_system.gd:37、:59 兩個 randf()，唯一呼叫點 sim_bridge.gd:573 是 UI 直呼 ⇒ 問一句會挪全域 RNG。
   · 玩家可感成本＝答案晚 1 tick 出現：command_player（sim_bridge.gd:435-439）入列後 request_advance(1)，
     而自動推進中（is_advancing）不另加推進——答案跟著那一顆走。與打聽同形，我同意。
   · 但請注意：打聽不是 VERB（player_command_api.gd:233-240 沒有它；它走 execute_action 的 gather_intel）。
     你說「與打聽同形」指的是【入列＋推進一 tick】，不是「同一種動詞」——新增 VERB 是第一次在 VERB 加非世界動作的詞，
     VERB 必須同時進 dispatch 的 match（P9 異源比對，sim_bridge.gd:448 的註解）；describe 要有中文（零英文識別字，player_command_api.gd:247 的規則）。

2 §1b 偷讀真值：一處是（diplomatic feud）→ 見 M3；其餘四格 OK
   · assess_enemy／intel_read／resources／strategic 全部走附身隊自己的帳或自知真值，沒有偷讀。
   · 己方武裝「自知合法」成立；但「與遭遇戰同一支」這句我沒法替你核（你自己說交件信列）。

3 §1c salt/observer 撞不撞：撞（有一個具體的）→ 見 M2

4 §2d 鍵對帳會不會恆綠：結構 grep 這一支守不住 → 見 M6

5 §2c 既有床有沒有直接讀 RES_NAMES／RESOURCE_NAME：沒有 ✓
   · 全 scripts grep：RES_NAMES 只有 observer_event_text.gd:6／:87；RESOURCE_NAME 只有 team_ui_helper.gd:59／:61。
   · 經 resource_name() 的呼叫點只有兩個：resource_format.gd:26、player_command_system.gd:2303。
   · 但 resource_name 現在是【短名 4 鍵、其餘回原鍵】（team_ui_helper.gd:59-61）；改轉呼 res_name 時必須用 "short" 變體
     且「short 查不到 ⇒ 回原鍵」，不得退回 full——否則 ResourceFormat 面板（:26）每一格變寬，會被 foot_block 的裁寬吃掉字。請寫進 spec 一句。
```

# 必修
```
M1 §1a 前置（「target_id 在附身隊的 belief 裡，不過⇒ok:false」）與 §1c／A3（「目標無 belief ⇒ 不知道、ok:true」）自相矛盾
   · 目標選單沒有可選時以 target_id=-1 入列（§1b 末），A3 要 ok:true；但前置字面會把 -1 與「無 belief」都擋成 ok:false。
   · 實作端兩種讀法各吃一邊，A3 與 A7 只會有一邊綠。
   ⇒ 前置只留「附身隊存在、顧問是活著的成員、situation 合法、target_id 是整數」；
     「要目標而 -1／無 belief／已過期」一律進【不知道】分支（ok:true）。把這個優先序寫成一句。
   ⇒ 並釘一件：玩家選了目標、入列後那一 tick 內目標 belief 被別的事件清掉，也走【不知道】（不是 ok:false）——否則「選單列出的」≠「handler 接受的」。

M2 §1c 雜湊 id 空間重疊（有具體撞點）
   · observation_noise01 在 repo 裡唯一的生產呼叫點：path_system.gd:302，參數是 (tick, observer.team_id, target.team_id)。
   · 你的呼叫是 (tick, advisor 的 person_id, target_id[隊 id])。person id 與 team id 都是小整數、空間重疊：
     顧問 person_id=5、目標隊 9、與「隊 5 觀測隊 9 的移動速度」在同一 tick 拿到【同一個 u】——
     兩個系統的雜訊相關。不是理論：兩邊的值域都從 0 起。
   · 次要：salt 用 -(情境序+1)——-1 同時是你自己的「不知道」目標哨兵；且同一顧問、同一 tick、同一目標，
     assess_enemy 與 diplomatic 拿到同一個 u（salt 只有 target_id）⇒ 兩種情境的偏差方向總是同向。
   ⇒ 修法（便宜、不動 observation_noise01 本體、它的跨語言釘值床不受影響）：
       observer 參數 ＝ advisor_pid + ADVISOR_NOISE_NS（具名常數，如 1 << 40；與任何 team/person id 空間不交）
       salt      ＝ target_id * 8 + 情境序（target 為 -1 時取 -(情境序+1)；兩段值域互斥）
   ⇒ 床加一格（負對照）：同一 (tick, id, id) 若走【無命名空間】的呼叫 ⇒ 與 path_system 那條取得相同 u（證明撞點存在），
     有命名空間 ⇒ 不同。沒有這格，命名空間可以被日後「簡化」掉而床不紅。

M3 diplomatic 的 feud 邊＝god-view（你問的那一處，我判是）
   · 「對 tgt【隊長】person_id 的邊」：隊長是誰來自 state.teams[tgt].leader_id（真值）。
   · belief 的 claim value 裡沒有隊長欄：vision_system.gd:170-199 的 snap 只有外觀／位置／人口／武裝／resource_scale 等；
     belief_system.gd 全檔 grep leader_id|known_leader 零命中。⇒ 「目標隊長是誰」不在附身隊的帳裡。
   · 後果：玩家與未曾見過其隊長的隊之間，只要成員恰好對那個人有 feud，顧問就會說「有宿怨」——卻沒有任何信念支撐。
     A8（人口 ×3 撥鐘）不會抓到它，因為它改的是人口不是隊長／邊。
   ⇒ 採你信裡的退路：diplomatic 只讀 known_reputations（BeliefSystem 的隊層帳），feud 判斷帶拿掉；
     優／劣的 feud 條件改為名聲單軸。若藍圖要「自家人的仇」進顧問，那是 WHAT（新 belief 欄：隊長身分），不在本票。
   ⇒ 床加 n6：把目標隊長換成與成員有 feud 的人（belief 不變）⇒ 同 tick 句子不變。

M4 A2 的判準在結構上不可靠（同一族：RNG 位移）
   · 你的出口是 WorldEvents.emit(…, false, info)。emit 無條件對 subjects 設 pending_rethink（world_events.gd:185；
     該檔 :46-53 已有「誠實限」自白：wake_thinking=false 並未關掉行為面），
     而勢力層讀它：pending_source_faction（:250-269）——附身隊所屬勢力的任一成員被標，【該勢力本 tick 重想】。
   · 所以「問顧問」會讓玩家隊的勢力多想一輪＝多抽 randf。A2 寫「問之前、之後各取 randi() 與不問的對照世界相等」：
     ① 對照世界若不推進同一 tick ⇒ 恆紅（命令本身推進 1 tick）；② 對照世界若推進同一 tick 但沒有那一次喚醒，
     玩家隊在勢力裡時 ⇒ 亦紅；玩家隊不在勢力裡 ⇒ 平凡綠。紅或綠取決於佈置，不取決於「handler 是否耗 RNG」。
   ⇒ 拆成兩格：
       A2a（要證的真命題）：直接呼叫 handler（dispatch），前後取 randi()，【零抽取】；同 tick 兩次同句。
       A2b（誠實的另一半）：寫明「問顧問會標玩家隊 pending_rethink（勢力層會多想一輪）」是被接受的行為，
          交件信印出佈置（玩家隊在勢力內／外）下對照世界的位移結果。
          這是 systems 的裁量（不是新玩家面行為），請你決定接受還是在 emit 前判掉；我偏接受＋誠實寫出，與 09-25 那四種事件同一先例。
   ⇒ A8 的「撥鐘不推進」：command_player 會 request_advance（sim_bridge.gd:437），床必須走 _enqueue_command 或直呼 dispatch；
     spec 一句話寫清，否則實作端用 command_player 做「同 tick 問兩次」會被自己推進。

M5 刪除／改名會打紅或打空既有的東西，spec 沒列
   · headless_test.gd:4511-4523 呼叫 get_advice(person, "assess_enemy", {enemy_pop…}, state) 舊簽名——merge-gate 的床；
     簽名一變就是 script error。
   · terminal_input_prompts_bed.gd:283-284 斷言 menu_situations().size()==3；五情境後變 5。
   · ★menu_situations（advisor_system.gd:16-21）現在是「SITUATION_SKILL_MAP 鍵 ∩ TEMPLATES.has("advisor_"+k)」。
     你把 advisor_* 從 TEMPLATES 刪掉、搬進 advisor.tsv ⇒ 這個交集【空集合】⇒ 選單恆空，
     且「∩ 有模板」那道守衛從此恆回同一答案。必須改：集合來自 TEXT_KEYS（或外置表的鍵），並說明守衛換成什麼。
   · 另 distortion_engine.gd:43 用 TEMPLATES.has(msg.type) 判斷——不涉及 advisor 鍵，但外置後任何「用 TEMPLATES.has 判斷鍵存在」的地方都要掃一遍；
     交件信附一份 grep 結果（TEMPLATES.has／TEMPLATES.get 全 scripts）。
   · WorldEvents 新 kind "advice"：all_kinds() ＝ MESSAGE_KINDS＋FUNC_KINDS＋STATE_KINDS（world_events.gd:91），
     KIND_LABEL（:97-111）有 E2E 格 a 逐一驗每個 kind 有短名（檔內 :96 自述）。spec 只寫了「describe 加 advice 分支」——
     還要進 FUNC_KINDS（或 STATE_KINDS）＋ KIND_LABEL，否則 T4 守衛與 E2E 格 a 紅。

M6 鍵對帳（§2d）：結構 grep 可被繞，而且它本來要守的不是這個
   · 「scripts 內除 TEXT_KEYS 行外零個 "advisor_ 字面」：①advisor_system.gd 現在就是 "advisor_" + situation（:19、:29、:34）——
     字面是前綴，grep 命中的是合法組鍵，會把正確寫法擋掉；②反過來 "advisor" + "_" + x、或 StringName／format 組鍵 ⇒ grep 不命中、綠。
     兩個方向都不是守衛要守的東西。
   · 真正的失效模式是 TextBank.fmt 的【靜默預設】：查不到 (鍵,變體) 回 "Team{origin} 有動靜"（text_bank.gd:104）——
     組錯鍵或漏一行 tsv 玩家看到的是一句無關的話，不報錯。
   ⇒ 守衛改成【執行期對帳】：床跑 五情境 × 優／均／劣／不知道 × 四語氣，在 TextBank.fmt 加一個測試旗（只在床開），
     記錄每一次「落到預設句」；斷言為 0；再斷言 tsv 的每個 (鍵,變體) 至少被取用過一次（兩向）。
     結構 grep 若要留，只當輔助，並明寫它不是守衛。
   ⇒ n3（刪一行）要【真的】讓這一格紅：刪的是會被取用到的那一行，而不是備用變體。
   ⇒ 槽對帳：_params_for 回傳的 key 集合 vs 句子 regex 取出的 {槽}——同意；注意 String.format 對缺槽是【原樣保留 {槽}】不報錯，
     所以槽對帳是唯一能看見它的地方；不要被 A1 的「句子有人數」誤當作它的覆蓋。
```

# 其餘（小，不擋）
```
· §1d 事件與 command_results 帶同一句 text：玩家事件流和結果行各印一次——請在 A6 斷言畫面上這句只出現一次（或明說兩處各一次是設計）。
· A4 的比較：同 belief 下技能高者 amp 嚴格較小、u 序列相同 ⇒ 結果由構造保證，是接線檢查不是行為檢查；可留，但別當成驗證了「技能有作用」。
· 兩常數「ADVISOR_BIAS_GAIN、ADVISOR_UNKNOWN_U」各自加 TEST VALUE 註解（你已寫）；strategic 的「assess 判劣」要說明 assess 用哪個目標（最近敵對）——寫一句。
· PlayerApiMapper._food_days 改公開 food_days：已確認 faction_ai／beds 另有同名私有函式，各自獨立，改名不會連動打到它們。
· threat_scan 抽出後的 P5 守衛（「本函式體內 best_estimate 呼叫＝1」）要改指向 threat_scan，並確認 map_threat_line 本體 best_estimate 呼叫＝0——別留兩處。
```

# 你後來改的 §2c（main 2e4a5d2e7：ITEM_NAME 併入 names.tsv、T4）——以新版為準，我補核
```
M7 「顯示名只准一張表」＝還有第四張，而 T4 的結構 grep 母體沒驗
   · 第四張：ObserverQueryApi.RES_LABEL（observer_query_api.gd:7-14）——資源鍵→中文，用字又不同
     （材料／貨物／近戰武器(低)／護甲(低)），與 RES_NAMES（木料／貨品／粗製近戰武器／粗製甲）並存。
     你的三常數清單與「三個常數變一張表」漏了它；它是 god-view 觀測專用，但「藍圖裁：只准一張表」若字面成立，它就是違反。
     ⇒ 二選一寫進 spec：(a) 併入（RES_LABEL 的消費者改呼 res_name；順便合掉 res_label／facility_label 之外的重複）；
        (b) 明列「觀測專用 god-view 表，本票不併」並進範圍外——別讓 T4 的名義聲稱比做的多。
   · T4 結構 grep「『近戰武器』『護甲』字面只在 names.tsv」——我在 scripts 全掃：
        observer_query_api.gd:10-11（"近戰武器(低)"…）、:13（"護甲(低)"）、:22（"護甲坊"，設施名，與裝備無關）、
        popup_layer.gd:345（"裝→護甲" 按鈕字）、以及 item_attributes.gd:72／tile_data.gd:48 等註解；
     ⇒ 第一天就紅，或被實作端用豁免清單壓綠（又一個靠豁免才綠的守衛）。母體沒驗。
     ⇒ 改成【由表派生】：床讀 names.tsv 的每個 value（例「粗製近戰武器」「粗製護甲」），
        斷言這些【整句值】在 scripts/**/*.gd 的字串字面（非註解）零出現；母體＝表本身，不靠人挑兩個關鍵字，也不誤傷「護甲坊」。
        再加反向：戰鬥畫面裝備欄與事件句對同一鍵印同一字（你已寫），用 res_name 比，不寫死字。
   · text_ui_main.gd:1794 `const ITEM_DISPLAY: Dictionary = TeamUiHelper.ITEM_NAME`（讀者 :2272、:2282 經 human(ITEM_DISPLAY, …)）：
     刪掉 ITEM_NAME 常數 ⇒ 這一行是 parse error（const 初值引用不存在的常數）。spec 的刪除清單沒列它。
     ⇒ 列出：ITEM_DISPLAY 改成什麼（建議刪掉，:2272／:2282 改 res_name 或 item_name）。
   · 「舊床若比對舊字（terminal_e2e、team_ui_test、ui_logic_test）」：我 grep scripts 全樹，「低階／高階／護具／粗製甲／精製甲」
     只出現在 team_ui_helper.gd:53-55 與 observer_event_text.gd:12（生產表本身），沒有任何 *_bed／*_test 比對這些字，
     那三個檔名我找不到對應命中。⇒ 這句話現在是空的；交件信請貼實際 grep（含 tools/、docs 的鍵表），別留一句沒有母體的「若」。
   · 玩家可見改字（低階→粗製、護具→護甲）：藍圖已裁，不在我的範圍；encounter_view.gd:193-194 走 item_name，保留函式名即可，無需動。
```

# 判決
```
verdict: issues
必修：M1 前置矛盾｜M2 命名空間＋情境序進 salt｜M3 diplomatic 去 feud（或另開 WHAT）｜M4 A2 拆 a/b、A8 不經 command_player｜M5 既有床與 menu_situations、kind 登記｜M6 鍵對帳改執行期｜M7 第四張表＋T4 改由表派生＋ITEM_DISPLAY parse error
補完後貼修訂處給我核一次（短信即可）；其餘小項照辦不需再審
```
