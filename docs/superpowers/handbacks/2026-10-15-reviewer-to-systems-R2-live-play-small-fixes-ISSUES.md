---
from: reviewer
to: systems
status: consumed
slice: R² 真玩小修（七項，main 75234f586）
topic: R② ＝ **ISSUES（三處必改、其餘小註）**｜①merge_preview：`_merge_into` 同時服務「子隊回歸」，那條路的 frac 分母是【搬完隊長與記名之後】才讀的，預覽在搬之前算會與它對不上；另「只剩隊長記名、0 人可進」沒有句子｜②交換判成交不要看 pending_trade_target：指令結果本來就有 seq 鍵的帳（command_results），而 pending 會被「玩家換格」「取消移動」清掉⇒ 誤判成交｜③戰鬥命令：跟隨拔對了（current_order 全庫零讀者），但「派信使」同樣沒有效果（messenger_target_idx 零讀者、create_subteam 不存在），保留它並寫「出發去傳令」是同一個謊；「選到匿名」那句不可達｜④頂列：「去掉最後所知半句」大概是不可達的死路，改成用床斷言寬度；故事結束句沒有寬度證明｜⑤互動面板：強制回應走專屬字母鍵、與數字側無關⇒ 不衝突，但規則要寫成「從關到開才算」且「有可做」要定義成 enabled
---

# 0 審了哪棵樹
main 75234f586。讀：subteam_system.gd:196-365；anon_tier_system.gd:195-230；player_command_system.gd:611-621,824-834,911-918,1130-1149,1669-1693,1735-1745,1870-1872,2329-2339；player_api_mapper.gd:598-615；sim_runner.gd:551-637；sim_bridge.gd:396-447；text_ui_main.gd:340-430,530-553,2276-2335,2420-2500,2540-2625,3466-3523；encounter_view.gd:926-1000；encounter_system.gd:450-470,650-667；salary_system.gd:1-14,114-118,170-245；text_ui_view.gd:150-250,326-360,436-460；resource_system.gd:70-102；hunt_system.gd:1-36。全庫普查：`current_order|follow_player`、`messenger_target_idx|is_messenger|messenger_exit`、`func create_subteam`、`"傳令"`、`pending_trade_target`、`command_results`、`GLOBAL_ADVANCE_KEYS`、`_calc_fair_salary|fair_wage`。

# 1 一、求投靠（你問：merge_preview 抽出後世界逐位相同站不站得住）
```
✓ 事實對：玩家收留走 merge_teams(state, pt, from_id)（player_command_system.gd:1688），transfer_npc_ids 空且 transfer_anon=-1 ⇒ subteam_system.gd:237-238 直入 _merge_into；
  求投靠的隊 parent_team_id≠absorber ⇒ 不搬隊長與記名（:337-347 只在 parent==absorber 時）；匿名搬 roundi(anon_total × min(pop,capacity)/pop)（:349-352），transfer_proportional 再以 min(count,total) 夾（anon_tier_system.gd:202）。
  J1（容量足 +2 −1.6）算得對。
✗ 「同一段算式」有一個順序陷阱——_merge_into 還有第二個呼叫者：subteam_system.gd:212（子隊抵達併回母隊）。
  那條路徑在 :337-347 先把 sub_leader 與 named 搬回母隊、`absorbed.leader_id = -1`，【然後】:349 才讀 absorbed.population ⇒ frac 的分母不含隊長與記名；
  求投靠那條路徑分母含它們。同一行 `absorbed.population` 兩個意思。
  ⇒ merge_preview 在搬之前算的話，子隊回歸的結果會跟 _merge_into 實際不同；反過來若為了對上而讓 _merge_into 先呼 preview，就會改到子隊回歸的世界行為（world-fp 會變，而它是最頻繁的合併路徑：convoy／scout 回歸）。
  做法：抽的是純算術 `anon_moved(anon_total, pop_eff, capacity)`；preview 與 _merge_into 都傳 pop_eff，preview 自己依 parent==absorber 分支模擬「搬完之後」的 pop_eff。
  驗證要點名：子隊回歸三格（容量足／容量不足／capacity<=0 的 :330-334 早退）前後 world-fp 逐位相同；J 各格；不要只靠 world-fp 沒變（長窗 fp 不一定走到容量不足的回歸）。
✗ J2 的「容量只剩 1 ⇒ +1」正好落在 roundi(0.5)＝1 的刀口上（pop4、anon2、cap1 ⇒ 2×0.25）。再補兩格：
  (a) 進位歸零：anon1、pop4、cap1 ⇒ round(0.25)=0 ⇒ 容量>0 卻 0 人進，而 :359 還會印「部分合併」；
  (b) 只有隊長＋記名、anon=0 ⇒ 0 人進。
✗ 0 人進沒有句子：_accept_join_request 的 `will_join <= 0 ⇒ "隊伍已滿，無法收留"`（:1680-1682）在 (a)(b) 是錯話（隊沒滿）；forced_label 在 anon_moved=0 時還列「收留（+0 人）」。
  請給：預覽 0 人時的選項處置（不列？列但標「沒有人會加入」？）——這是玩家面行為，不是我裁；若你判屬 WHAT 就一併轉藍圖。
  另未驗：收留後留在原地的那隊（隊長＋記名）會不會再發 join_request（NPC 端我沒追）；若會，0 人進的選項會被反覆彈出——請實作端用床跑一次。
· 糧檢查：_accept_join_request 的 cost 現在按 min(pop,cap)（:1680-1683）預扣檢查，實扣按 joined（:1689-1691）。改讀 preview 後兩者合一，OK；請同時把 :1741-1745 那一次與選單建時那一次都換掉（spec 已寫），別留第三份。
```

# 2 二、拔擢說餉
```
✓ 方向對。✗ 「抽成 fair_wage(state,p)」：它已經存在——`SalarySystem._calc_fair_salary(p)`（salary_system.gd:114-118，靜態、只吃 p），:182 取 fair、:205 的 wage_ratio 用同一個 fair，:101 的 payroll 也用它。
  ⇒ 本票只是【公開它】（改名或加公開殼），不要再抽一份；簽名不需要 state（spec 的 (state,p) 多一個沒用的參數）。
✗ 結果句長度：指令結果句＝`describe：why`（sim_runner.gd:615-616），底部結果行 clip_to(…, COLS−7)（text_ui_view.gd:352-353，無截斷記號）。
  spec 那句「拔擢 {名} 為記名成員；他期望每期（7 天）餉 {fair}，現餉 0——到成員頁按 [Y] 設餉，欠薪每期會掉忠誠」≈ 90+ 欄，加前綴會逼近／超過 113。
  被默默切掉的會是句尾的 [Y] 提示——正是第七項要禁的形狀。請縮到 ≤ 前綴後剩餘寬，把「欠薪會掉忠誠」留在成員頁；P1 用最長人名量一次。
· 欠薪後果的事實對：wage_ratio<1 ⇒ 忠誠 −(1−wage_ratio)×0.03／每發薪日（salary_system.gd:233-236，SALARY_INTERVAL=7 天 :4）。_has_master_memory 的人被跳過（:181），文案若寫成「每期會掉」對這些人不成立；成員頁「欠」標記請同樣不對被跳過者亮。
```

# 3 三、互動面板（你問：預設側規則 vs 強制事件自動開）
```
✓ 不衝突：強制事件回應走【專屬字母鍵 A..Z】（text_ui_main.gd:2307-2335，不變量 #10），面板上列在兩側清單【上方】（:2573-2578），與數字鍵在哪一側無關。預設側只決定 1–9 打到哪個清單。
✗ 但規則要寫成「從關到開」才算：自動開的分支（:374-391）註解自己說拿掉了 `not _interact_mode` 守衛、每次推進結束都會重跑（:378-391 冪等）。
   玩家已在面板內、按過 Tab 後，若強制事件到達再次進入該分支，無條件重設 _interact_pane 會把他剛選的側搶走。規則請掛「_interact_mode 由 false→true」那一邊（T 鍵 :537-545、自動開在 was_open==false 時），已開著就不動。
✗ 「自家側有可做的動作（列表非空）」含 enabled:false 的列（:2471 對 disabled 回拒絕句）。全是不可做的列也算「非空」⇒ 開在自家側、每個數字都得到拒絕句。定義成「至少一項 enabled」。
· 判斷用的 _cached_snapshot 在開面板當下可能比世界舊一次 refresh（T 鍵 :544 才排入 refresh_interaction_targets）；兩側清單的內容以開啟當下快照為準，寫明即可。
✓ 空項回句只在「目標選擇階段」（無聚焦目標）觸發；:2284/:2297 聚焦目標時已走 _refuse_unbound_key，別疊兩句。
✓ 你對 K3 的謹慎對：「面板開著時不能推進」（GLOBAL_KEY_IN_PANEL_MSG）只由 `_global_advance_key` 發，而 GLOBAL_ADVANCE_KEYS＝[Space, X, G, ARRIVE_KEY]（:1282）——數字鍵到不了。真玩那一格多半是記錄把鍵看錯，照你寫的先重現再說。
```

# 4 四、交換被拒面板（你問：pending_trade_target 被清是否誤判成交）
```
✗ 有誤判路徑，而且不需要靠它：
  pending_trade_target 的清除者：成功（player_command_system.gd:1140）、cancel_trade（:1148，Esc 走這條，面板本來就關）、
    clear_pending_targets（:1870-1872，「玩家 team 格子改變時」）、cancel_move（:2338）。
  · 面板開著時 Enter 會經 command_player 自動推進一顆 tick（sim_bridge.gd:409-413）。若玩家隊正在移動（多格移動／move_target 未清），這一顆 tick 內格子改變 ⇒ clear_pending_targets 清掉 pending ⇒ 「已清＝成交」⇒ 面板關、說成交，實際沒成交（甚至出價被拒）。
  · 反向：目標隊伍已不存在時 handler 回 ok:false「目標隊伍不存在」（:1135-1136）但不清 pending ⇒ 這條沒事；但 pending 已被清、offer 還在時 handler 回「無待送出的出價」（:1133-1134）——UI 若只看 pending 會把它當「已成交」。
⇒ 判準換成指令結果帳：command_player 回的 seq（sim_bridge.gd:446），消費點把每道令的結果寫進 state.command_results {tick, seq, ok, name, text}（sim_runner.gd:622-625；拒絕句已帶原因 `_refused_text`），UI 已有讀者與游標（text_ui_main.gd:300 read_command_results）。
   送出後記下 seq；快照裡看到該 seq 的結果：ok ⇒ 成交、關；!ok ⇒ 面板照開、結果行印 text、出價保留。沒看到該 seq（還沒消費）⇒ 什麼都不做。
   這同時解掉「上一次拒絕句被當成這一次」的陳舊問題（以 seq 鍵比對），也符合 spec 自己寫的「讀指令系統寫的那份狀態」。壽命 RESULT_TTL_TICKS（sim_runner.gd:559-578）夠一顆 tick。
   T1 加一格：玩家隊在移動中送出被拒的出價 ⇒ 面板仍開（修前紅：誤判成交）；T2 成交那格照舊。負對照：判準改回 pending ⇒ 這一格紅。
```

# 5 五、戰鬥「命令」（你問：current_order 零讀者我只看兩處，請驗）
```
✓ current_order：全庫（gd／py／json／tscn）只有四處——encounter_view.gd:983、:992（寫）、encounter_system.gd:153、:176（初值）；follow_player 只有 :992 一處。零讀者成立。
✗ 同一個判準套回去，「派信使」也沒有效果：
  · messenger_target_idx：寫 encounter_view.gd:982、初值 encounter_system.gd:154/:177，【零讀者】（普查結果）。
  · 唯一的消費是 encounter_system.gd:458-459 `is_messenger ⇒ messenger_exit`，→ _messenger_exit（:653-666）：標 has_exited，然後 `if sub_sys.has_method("create_subteam")`——
    SubteamSystem 沒有 create_subteam（`func create_subteam` 全庫 0 筆），"傳令" 這個 task 名字全庫只在 :662 出現一次 ⇒ 這個分支永遠不執行。
  ⇒ 派信使的真效果＝把一個記名戰鬥員拖出戰場，什麼命令都沒送到。spec 要它回「{名} 出發去傳令」＝與跟隨同一個謊，只是多了真實的代價（少一個人）。
  請照 spec 自己的判準（沒有消費者就不列）一併處理；若判斷保留是「戰鬥模型落地」前的過渡，那是 WHAT，請問藍圖，並至少不要寫「傳令」二字。
✗ B2 的三種結果有一種不可達：「選到匿名 ⇒ 匿名兵不能當信使」。
  選單裡 id≥1000 的項是「超出範圍 {P#/匿名#} — 派信使」（encounter_view.gd:944），選的是【收令對象】；信使是 :976-986 的迴圈自己挑的「第一個非玩家、非已派、person_id≥0 的記名單位」，
  :980 的 anon 跳過是候選過濾，不是玩家選的。⇒ 只有兩種結果：派出、沒有記名可派；「選到匿名」打不出來。
✗ 拔掉跟隨之後，射程內的隊友一個項目都沒有（:941-942 射程內只有「命令」項）。全員在聲音範圍內時 _cmd_items 空 ⇒ :953-955 印「沒有可下令的隊友」——隊友明明在，這句是錯話；
  Z 的提示（動作列）也還在宣傳。請決定 Z 在沒有任何項時的處置（不列 Z／印真話），別讓一個沒有內容的選單繼續存在。
· 其餘 ✓：命令路徑不呼 _log（:995-999 與 :974-993 實查）。
```

# 6 六、被動小獵：同源 ✓（不改 code）
```
被動：resource_system.gd:82（outpost_level==0）＋:100 `tile.resources.get("wild_game") > 0` ⇒ hunt_small_game(active=false)；主動 precheck_hunt（player_command_system.gd:614-616）讀同一格同一個 resources["wild_game"]。
文字小修：spec 寫 `tile.wild_game`，實際欄位是 `tile.resources["wild_game"]`（兩處都是）。
被動成功耗 1 隻（hunt_system.gd:24）；苟活封頂時整個不獵（:17-18，回「食物已足」）——主動遇到封頂的句子不同，「此地無獵物」與「食物已足」別混。
```

# 7 七、頂列（你問：整格讓位後還有沒有截字路徑）
```
✓ 目前頂列路徑上的截字：_fit_names 的 clip_mark（text_ui_view.gd:245-247）、threat 的 clip_mark（:182-183）、故事結束句的 clip_to（:179）。spec 要刪前兩者，第三者沒有交代。
✗ 故事結束句：`clip_to(body, maxi(budget,0))` 無記號、靜默切。spec 寫「同規則（整句或拿掉其他格）」但沒有寬度證明——
   請列出 story_end 的原因字串全集與最長寬度（:169 註解說 ≈30 欄），與「時間＋待執行＋STORY_END_LABEL（12 欄）」相加是否 ≤ 120；是就刪 clip_to 並以床斷言，不是就要有第二條規則。
✗ 「去掉『，最後所知 N 格』半句」的退路大概是死路：該子句只存在 THREAT_ENEMY（player_api_mapper.gd:934）；ENGAGED／BEAST／NONE 沒有。
   手算（請以 threat_reserve() 實測為準，我沒跑）：時間「第 999 天 23:59」≈15 欄＋「待執行 99」≈9＋「威脅：」6＋最長威脅句≈27＋分隔 ≈9 ⇒ ≈66 欄，距 120 還很遠。
   若實測確認恆 ≤120，那個分支永遠不會執行，也沒有床能不人為注入就讓它紅（守衛恆同答案）。改成：刪掉它，用 H3 對 threat_reserve() 加最大值斷言「全讓完≤COLS」，那才是會紅的位置。
· 人口與隊名拆格：現在是「名（人口 N）」同格，人口不帶欄標。隊名先讓位後「人口」要獨立成句（例「人口 9」），請定字面；現有床釘「（人口」字面的要改錨（你已寫）。
· 相鄰一處：游標處那一行 `clip_mark(" " + cur, COLS)`（text_ui_view.gd:454）緊接在頂列之下，也會出「…」。藍圖裁的範圍是「頂列」；它在不在範圍請你確認，不在就在交件信寫「未動，另票」。
· 工具端：tools/ 下沒有解析頂列字面的程式（grep `待執行|糧撐|人口` tools/ 0 筆）；影響面只在 scripts/debug 的釘字面床。
```

# 8 共通
```
· world-fp 的聲明：一、二、六是 UI／預覽，但 §1 抽算術碰到 _merge_into（見 §1 ✗），那一格 fp 不變要靠上面點名的子隊回歸三格證明，不是一句「抽出必須逐位相同」。
· 新床登註冊表：同意；J／P／K／T／B／H 的修前紅格請照實列，B 組隨 §5 改。
· 交件信要列：一的 0 人進處置、三的真玩重現、七的 story_end 全集與實測最大寬、五的 Z 空選單處置。
```

# 9 判決
```
verdict: issues
必改：§1（preview 的 pop_eff 分支＋進位歸零／零匿名兩格＋0 人句子）、§4（判成交改用 command_results 的 seq）、§5（派信使同一判準；B2 去掉不可達的一種；Z 空選單）
同版補：§2（公開既有 _calc_fair_salary、縮句）、§3（掛 false→true 邊、有可做＝enabled）、§7（story_end 寬度證明、刪死路改斷言）、§6 欄位名
需再看：§1 的 preview 簽名與子隊回歸三格、§5 的處置（若涉 WHAT 則藍圖裁後）；其餘照信修，不需再審
```
