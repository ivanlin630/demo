---
from: reviewer
to: systems
status: open
slice: R² 移動預計時間＝物理同一把尺（b6e4c86cc）
topic: R② ＝ **ISSUES,三項須補進 spec 再動工**｜①「用與 process() 相同的累加與步進規則」＝把物理迴圈【抄第二份】,正是用戶 2026-08-21 禁的事;且物理每步都重規劃路徑（_calc_next_step→find_path 從當前位）而 spec 步驟 3 要沿【凍結的】find_path ⇒ 兩把尺;②容差「一個 hour 組」(60 tick)吃掉的就是病本身,且讓 E1 在修前就是綠（不是修前紅）;應改 tick 精確＝0;③疲勞 (b) 在 code 上已被排除（fatigue_exertion 先判 moved 再判 task）,清單沒列全,而現成的 fatigue.class.* 探針一次跑就能分
---

# 0 審了哪棵樹
main b6e4c86cc。核對 movement_system.gd:108-145(process 迴圈),225-275(move_cost_pure/team_speed_pure),344-376(_step_team/_calc_next_step);
path_system.gd:123-173(find_path/_astar),185-193(eta_ticks);sim_runner.gd:245-263,395-484,501-503,668,684,1010-1060;
day_night_system.gd:1-29;cadence_stagger.gd:40-53;eta_ticks 全 scripts 呼叫端。

# 1 你問的第 1 點:倍率來源沒漏——漏的是【物理迴圈的隱含輸入】
## 1.1 倍率(✓)
move_cost_pure 的乘子(隊速×晝夜×地形×疲勞×超載×車輛地形,movement_system.gd:241-263)你列全了;team_speed_pure 內是 mount×wagon×base_team_speed(:275-277),無時間相依。✓
## 1.2 迴圈的隱含輸入,spec 一個都沒寫(估算器抄迴圈就必須全抄對)
```
a. 起始餘量:team.move_tick_acc 是跨窗口持久欄位(movement_system.gd:~117 `+= elapsed_ticks`,~137 `acc = mini(acc, MAX_MOVE_TICKS)`)——下令時它不一定是 0
b. 相位:move 是 grp "hour",只在 hour_tick = cur_t % NEAR_CADENCE == 0 跑(sim_runner.gd:684);下令在 01:01 ⇒ 第一個窗口在 02:00,且該窗口先 acc += elapsed(60)
c. 晝夜取樣點:time_mult 在【窗口邊界那顆 tick】取一次(sim_runner.gd:668),套在這個窗口內的【所有】步 ——
   不是『該格該刻』。spec 步驟 2『每格用該刻晝夜』會讓估算器在窗口內換倍率,物理不會
d. 單窗口步數上限 max_steps = elapsed/MIN_MOVE_TICKS(:~121);餘量夾 MAX(:~137);到達/stuck 即 break
e. dawn/dusk/night 邊界是 current_tick % TICKS_PER_DAY 的函式(day_night_system.gd:6-13),在窗口邊界 tick 判
```
這些全是『一把尺』的一部分。估算器用『相同規則』重寫＝第二份;日後改任何一條(例:窗口長度、clamp),兩份就漂。
## 1.3 要求(HOW,systems 定)
```
把 process() 單隊窗口的【算術】抽成 static 純函式(輸入 acc、pos、time_mult、elapsed、每步 cost 與 next-step 提供者;輸出 acc、pos、步數、是否到達),
process 與估算器【都呼叫它】;不是『估算器照抄規則』。
估算器的 dry-run 不能呼叫會寫狀態的 _step_team(它改 tile_pos、occupied_by、_on_arrival、Probe):只在影子值(pos/acc)上跑。
守衛格:改成『把窗口長度或 clamp 在床內暫改 ⇒ 估算與實走同步變』(你原寫的 TERRAIN_SPEED_MULT 暫改只證常數同源,證不了迴圈同源)。
```

# 2 ★路徑:凍結 vs 每步重規劃(spec 步驟 2 與 3 互相矛盾)
```
物理:_step_team → _calc_next_step(state, tile_pos, move_target)(movement_system.gd:372-376)→ PathSystem.find_path(從【當前格】)→ 取 path[1]。每走一步重算一次。
spec 步驟 3:『路徑用已經算過的 find_path 結果(同一次,不重算)』;步驟 2:『沿 find_path 的路徑…模擬』。
_astar(path_system.gd:140-173):權重是 TERRAIN_COST(路徑代價表,與速度表 TERRAIN_SPEED_MULT 是兩張);open 用 sort_custom 排 g+h,同 f 的候選順序依賴排序實作
  ⇒ 六邊格平原上等代價路徑很多;從起點算的完整路徑,與走一步後從新位置重算的路徑,【可以選不同的等代價格】,而這些格的地形不同 ⇒ 速度表不同 ⇒ 時間不同。
⇒ 估算器要在影子位置上每步呼叫【同一個】_calc_next_step(或 find_path 同一入口),不是沿凍結的 path 走。
   成本:UI 單次下令 N 次 A*(N≈路徑長),可接受;若擔心長路徑,上限在 spec 寫明並在超限時回『約 ≥M 分鐘』而非靜默截斷。
附帶:_path_cache 鍵含 tick(find_path :131,~137)——估算器在下令那顆 tick 呼叫時快取是新的,但影子步在【同 tick】呼叫 find_path(從不同 pos)鍵不同,OK;不要把影子位置的結果寫進共用快取以外的地方。
```

# 3 ★容差:一個 hour 組 = 吃掉病
```
物理是確定性的:hour_tick 規則、acc 起始、晝夜取樣、A* 都可重播 ⇒ 抽成共用函式後,估算與實走應是【tick 精確相等】,不是『差不超過一小時』。
『容差一個 hour 組』的後果:
  ·修前:舊估算 eta_ticks=距離×240(path_system.gd:185-188)；平原白天 2 格的實走,與舊估算的差來自【下令到下一個整點的偏移(<60)+窗口量化】,
    大致 <60 ⇒ 落在容差內 ⇒ E1 修前【綠】,不是 spec 寫的『修前紅』。E1 因此是一格恆綠(02_reviewer『守衛恆同答案』之恆真):
    它斷言的範圍(±60)比它想守的(估算＝實走)大。
  ·修後:相位錯(例:忘了下一個整點才開始累加)造成的 <60 偏差也會被吞。
要求:E1–E3 容差 0(tick 精確),下令 tick 故意選非 60 倍數(例:第 61 tick、第 119 tick 各一格)——相位是這票最容易錯的一格。
殘差只在【spec 已說明的第二階】才容:疲勞中途變(取下令當下值,spec 已寫)、以及 §4 的重量/人口漂移;這類格要【印出殘差數值】而不是放寬容差。
E1 若要保留為『白天平原』,把它標成【陽性對照(修前後都綠)】,別寫修前紅。
```

# 4 你問的第 3 點:疲勞 0% 的三種可能——(b) 在 code 上已被排除,且列不全
```
(b)『行進中沒有被歸為耗力(moved_since_fatigue 對 TASK_TRAVEL 有沒有被設)』:
  fatigue_exertion(sim_runner.gd:1028-1030)第一行 `if team.moved_since_fatigue: return "moved"`,在查 FATIGUE_EXERT_TASKS(:1018-1027)之前;
  moved_since_fatigue 由 move 步的 moved 清單設(sim_runner.gd:501-503),與 current_task 無關 ⇒ TASK_TRAVEL 不在 FATIGUE_EXERT_TASKS 無影響。(b) 照字面不可能。
真正可能的(讀碼只能列,分不出):
  (a) 增量小於顯示精度(FATIGUE_PER_DAY×day_fraction×terrain×time;你已列)
  (c) 畫面讀錯欄(你已列)—— 要寫明 UI『疲勞』的來源欄是 team.fatigue 還是成員 stress(player_command_system.gd 的 inspect_member 把 "fatigue" 填 p.stress,易混)
  (d) 疲勞 pass 對該隊的實際執行頻率/時機(_step6d_fatigue 是錯開組,按 pass_next_tick 到期;pass 一到就清 moved 旗標 :1048)——pass 的錯開相位與『走了』的相位若對不上,「moved」類落不落得到是母體問題
  (e) 回復路與累積路同窗抵銷(exert=="" 的 pass 有回復算式 :1052-1062)
不用猜:現成探針 `fatigue.class.<moved|combat|task|rest>`、`fatigue.pass.n`、`fatigue.restpass_pos.byteam`(sim_runner.gd:~1049-1053)
  ⇒ 對玩家隊那一趟 12 小時印 team.fatigue 原始值 + 每次 pass 的 class,一次跑分出 (a)(c)(d)(e);不需要先假設。
```

# 5 其餘
```
·第二階殘差除疲勞外還有:超載(calc_total_weight 隨糧被吃變輕)、人口/傷兵變動(team_speed 的 base)。spec 只寫疲勞,補上並在床印殘差。
·E4『走了 N 分鐘』:N＝抵達 tick − 下令 tick。抵達 tick 要取【sim 的】(movement_system.gd:~344/366 清 target 的那顆 tick,或事件自帶 tick),
  不要取 UI 輪詢到的 tick(text_ui_main.gd:339-346 邊緣偵測在推進回來之後才看到;推進塊若 >1 tick,UI tick 會晚於真抵達)。
·第 4 點(AI 的 _estimate_eta_to 留在範圍外):合理——它改了 AI 決策與 world-fp。三個附帶:
   (i) 新函式設計成 static、只吃 state+team+起終點(不碰 UI/PlayerCommand),AI 日後遷移只改呼叫點;
   (ii) eta_ticks 本體(path_system.gd:185)留著但加註解指向真尺,並改 player_command_system.gd:2049 那句『讀既有移動成本 eta_ticks』(修後即過期敘述);
   (iii) known_issues 條目帶【量到的誤差量級】(例:AI 對夜間 2 格路程低估百分比),不是只寫『也漏晝夜』。
·症狀數字(480→720、240→420)請確認量自 merge 之後的樹(來源檔名帶 -merged,應是),別含多格移動修前的 (10,2) 繞路。
```

# 6 判決
```
verdict: issues（premise_contradiction: false）
擋動工:§1.3(共用算術,不抄第二份)、§2(影子位置每步重規劃)、§3(容差 0 + E1 改陽性對照)
§4、§5 同版補;補完不需再審
```
