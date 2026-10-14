---
from: reviewer
to: systems
status: open
slice: 真玩小修 §1／§5 核對（main 89e2a07b8）
topic: R② 第二輪 ＝ **ISSUES（小，一處必修＋一處要釘死）**｜§1 absorb_whole_team 的「低階搬移函式」清單漏了小孩／俘虜／匿名公庫／資源，被併的隊 erase 時這些會蒸發或被記成死亡（用戶裁過「小孩跟著大人走」）；而【整隊搬】本來就有一條現成、被走過的路（merge_teams 長分支），不需要第三份搬人實作｜§1 另：強制事件按下「不可」的接受會把整件事清掉（respond_to_forced 不管 ok 都清），要選一種處置寫進 J2｜§5 方向對、刪除清單補全（兩份動作列字串、終端選單三處、BATTLE⑦ 床要換不是刪、is_messenger 零寫者的整串）
---

# 核對範圍
spec 同名檔 §一、§五與你的信；對照 code：subteam_system.gd:235-320（merge_teams 長分支）、:321-364；world_state.gd:877-970（erase_teams）；player_command_system.gd:1669-1693,1735-1842；faction_ai_system.gd:7813-7824；recruit_tutorial.gd:27；team_data.gd:130,136,519；encounter_view.gd:33-34,114,226,693-725,823-827,920-1000；encounter_system.gd:147,163,458-459,653-666,898-906；text_ui_main.gd:607；terminal_e2e_bed.gd:2274-2282。

# 1 §一 求投靠整隊（absorb_whole_team／absorb_block_reason）
```
✓ 不碰 _merge_into：分母順序陷阱確實不存在；J3 要的「_merge_into 沒被動到」我同意用行為比對（三格＋census），再加一條最便宜的：交件時 `git diff` 對 subteam_system.gd 的 _merge_into 函式體 0 行。
✓ 三處同呼 block_reason（選單 forced_label、處理前、執行）＝列的條件＝做的條件；整隊 ⇒ 沒有 0 人進／進位歸零／半隊再求。
✗ 必修：absorb_whole_team 的搬移清單不完整，而它【erase 被併的隊】。
   spec :17 的「低階搬移函式（transfer_proportional 全數、記名逐一 set_team／名冊）」只搬了匿名與人。被併的隊還有：
   · minor_population（team_data.gd:130）——長分支 :291-299 的註解寫明「小孩跟著大人走（用戶裁定）：被併進去的小孩若不搬，會被記成滅團損失＝死亡」；
   · captive_groups（:136）——整隊 erase 即蒸發；
   · anon_treasury（:519）與 resources——_transfer_proportional_assets(frac=1, will_empty=true) 才會連殘餘一起掃光（subteam_system.gd:217-229）；
   · 其下子隊（erase_teams 步驟 1 把 subteams 的 parent 設 -1，world_state.gd:953-956）、其名下據點（步驟 3a 死亡釋放成 -1，:968-969）、其勢力成員身分（步驟 2）。
   求投靠者是絕境流民團（faction_ai_system.gd:7813-7824 的 _maybe_request_join_player；recruit_tutorial.gd:27 也寫同一種事件），有小孩與俘虜並不罕見。
   ⇒ 建議（少一份實作、多一條被走過的路）：absorb_whole_team = block_reason 把關 ＋ 呼 `merge_teams(state, absorber, absorbed, [leader]+named_members, anon_total)`（subteam_system.gd:235 長分支）。
      該分支本來就：按 frac 搬匿名、frac=1 時搬光 minors（:291-299）、_transfer_proportional_assets 掃光資源與公庫（:300）、population 歸零時 erase（:304-306）。
      block_reason 事先保證容量塞得下，所以 :248 的靜默 return 與 :251/:267 的夾限都不會觸發。
      若堅持新寫搬移：J1 加一格「守恆」——併入前後 (人口＋minors＋俘虜＋coin＋各資源) 總和相等、CoinAudit 為 0，並明講據點／子隊／勢力身分三件的處置（我看不到 spec 寫）。
   J1 的負對照再加：拿掉 minors 搬移 ⇒ 守恆格紅。
· block_reason 的輸入也請寫清：與 cap 比較的是哪個 population（同一個 getter，別一邊含 minors 一邊不含）；被併隊若屬某勢力／是盟主時 erase 會走繼位（world_state.gd:962-964），要不要擋是意圖問題——寫進理由句或明說不擋。
✗ 要釘死：強制事件按下接受而被 block 擋住時會怎樣？
   respond_to_forced 不管 result.ok 都清 player_forced_event（player_command_system.gd:1828-1829），再把失敗句包成「你選了「…」，但… ⇒ 沒有生效」（:1838-1841）。
   spec 的「不可 ⇒ 照列並標理由，按下回同一句」按字面＝按了【不可】的接受 ⇒ 請求被消耗，等於婉拒，而玩家看到的是「沒有生效」。
   現成先例：choose_heir 的 stale 單選「不清 forced，讓玩家重選」直接 return（:1801-1803）。兩種都可以，但要二選一並寫進 J2：
     (a) 擋住時不清事件、玩家可改按婉拒或先騰出容量（逾時有 forced_event_timeout 自動婉拒，sim_runner.gd:746）；
     (b) 清掉，J2 明寫「按下＝請求消耗，等同婉拒」。
   我偏 (a)（沒有人替玩家做掉他的選擇），但這是玩家面行為；你判屬 WHAT 就轉藍圖。
· mapper 的訊息句 :337「（%d 人）」與 :412「接受＝對方整隊併入你」已經是整隊語意，不需改。
```

# 2 §五 戰鬥命令全拿掉
```
✓ 同一判準處理跟隨與派信使；Z 鍵與提示一起拿掉；不留空選單。方向我同意。
補全刪除／改動清單（我 grep 到的，請對照你的普查）：
  · 動作列字串兩份：encounter_view.gd:114（初值）與 :226（ACTION_HINTS 常數）都含「Z:命令」——順手併成一份，免得下次漏一份；
  · 未綁鍵回句 :827 的列舉「…Z 命令／F 投降…」要同步改（否則玩家被告知「可用 Z」而 Z 是未綁）；
  · 終端選單三處：_cmd_items／_cmd_popup 宣告 :33-34，戰鬥區印選單 :693-705，鍵處理 :717-725，加上 :823-824 的 Z 分支與 _open_command_menu／_close_command_menu／_on_command_selected／_dispatch_messenger／_open_sub_command（:926-993）、SOUND_RANGE（:920，只被選單用）；
  · `_waiting_for_player = true` 在 :957、:972 由選單設——刪選單後檢查它還有沒有別的設值者，別留一個讀者在等一個永遠不會被設的旗標；
  · is_messenger 整串：encounter_view.gd:550-551（黃點）、:979-982；encounter_system.gd:147/163（初值）、:154/177（messenger_target_idx 初值）、:458-459（messenger_exit 動作）、:653-666（_messenger_exit）、:898-906（動作分支）；debug 夾具 headless_test.gd:3823/3838 的 "is_messenger": false 鍵無害但請一併清；
  · ★別動 text_ui_main.gd:607 的 KEY_Z——那是主畫面的 Z，與戰鬥無關（主畫面 match 最後一支）。
✗ terminal_e2e_bed.gd:2274-2282「BATTLE⑦ Z 命令選單」是會紅的床：要【換成】「按 Z ⇒ 未綁處置」的斷言，不是單純刪掉（刪掉＝這個鍵少了一個守衛）；B1 已寫「按 Z 走既有未綁鍵處置」，請讓 BATTLE⑦ 成為它。
· B2 的普查範圍請包含 scripts/debug（上面 headless_test 兩處）與 docs 的鍵表；B3「無玩家世界 fp 不變」成立（is_messenger 唯一寫者在 encounter_view）。
```

# 3 其餘七項（你說照信改，我只抽核了這幾條有 spec 文字可對的）
```
二：公開 _calc_fair_salary、結果句縮到 ≤ COLS−7、skipped 不標「欠」✓。
三：掛「關→開」邊、enabled、空項回句只在選擇階段 ✓。
四：seq 帳 ✓；T1b／T1c 兩格正中我指的兩個誤判。
七：刪死路改斷言 ✓（請照 §7 我說的以 threat_reserve() 實測，數字貼交件信）。
六：欄位名 ✓。
```

# 4 判決
```
verdict: issues（小）
必修：§1 absorb_whole_team 搬移清單（minors／俘虜／公庫／資源＋據點／子隊／勢力三件處置），建議改呼 merge_teams 長分支；J1 加守恆格
要釘死：§1 「不可」接受按下後事件清不清（J2 寫一句）
同版補：§5 刪除清單與 BATTLE⑦ 改換
補完 §1 搬移那一段（貼進交件信或回我一封短信）我核一次；§5 照清單修，不需再審
```
