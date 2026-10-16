# 玩家勢力目標改用引擎同一套詞 — HOW

> systems 2026-10-16。
> WHAT：藍圖票 2026-10-16-blueprint-to-systems-TICKET-player-faction-goal-uses-engine-vocabulary（用戶裁「好」）。
> 狀態：R² ISSUES（2026-10-16-reviewer-to-systems-R2-player-faction-goal-engine-vocabulary-ISSUES）M1–M3＋同版項已補；R²b（…-R2b-…-ISSUES）M2 改「上次套用」兩欄已補，審查註明補完不需再審 ⇒ GO。藍圖 2026-10-16 同意 §二 對象母體、外交不含「不先動手」、§四 交接清令（b073eb826）。
> 位置：玩家可見批尾，我的掛單與押貨之後。
> 關 known_issues「玩家設的勢力目標，成員一個也讀不到」（含其「交接」一行，見 §四）。

## 現況（main b698fe380，file:line 本輪已讀）
- 玩家能設：`player_command_system.gd:54` `FACTION_GOALS = ["expand","defend","trade_net"]`、:55 標籤；`_action_set_faction_goal`（:1790）只驗在集合裡＋是盟主，寫 `f.player_goal_override`（單一字串）。
- 選單：`text_ui_main.gd:2822-2835` 數字選單＝`FACTION_GOALS + [""]`；面板 :2939「目標：無（等你下令）／目標：{標籤}（你設的）」。
- 目標進 goals：`faction_ai_system.gd:1947-1953` 玩家領導 ⇒ goals＝[override]（或空）。
- 成員讀法：`decision_context.gd:1131-1145` 只收 `options_in_set("stakes")`＝攻擊／徵收／外交 且在 `f.goals` 裡的詞；**詞不帶對象**——
  - 攻擊：`faction_attack_target = _nearest_independent(state, team)`（每個成員自己算：自己 discovered＋有 belief 位置＋獨立隊、最近者；faction_ai_system.gd:5154）。
  - 徵收：`faction_tribute_target = _richest_member(state, f)`（勢力名冊快照最富、非盟主、非自己）。
  - 外交：`faction_diplo_target = _nearest_independent(...)`；**而 `外交` 的 `to_task`（options.gd:470-475）自己再呼一次 `_nearest_independent`，不讀 ctx**。
  - 分數：`terms.gd:608-610` `faction_duty`＝`FACTION_DUTY_DRIVE`（三詞各自要求 target != -1）；`攻擊` 的門＝`attack_target_id != -1`，而 `faction_attack_target` 是它第一優先來源（decision_context.gd:1205）。
- 立國：
  - 閘在 `_rebuild_goals` :1975-1982（成員 ≥2、盟主統領 ≥ `ESTABLISH_COMMAND − (野心−0.5)×0.2`、野心 ≥ `ESTABLISH_AMBITION − 0.1`、盟主隊 readiness ≥ `ESTABLISH_READINESS`；未立國才判）。玩家領導在 :1947 早退，**到不了這道閘**。
  - 執行在 `_assign_tasks` :3469 `if "立國" in f.goals: _declare_established(...)`——**只看詞、不重驗閘**；玩家領導的勢力會走到這裡。
  - `_declare_established`（:7968）`goals.erase("立國")`，**不清 override** ⇒ 下一小時 :1950 又把「立國」放回 goals ⇒ 每小時再宣告一次（訊息洗版、faction_name 重寫）。
- ★交接（我上一輪登 known_issues 時寫「無作用」，**寫錯了**）：`:1955-1958` G-09 支「override 非空 ⇒ goals＝[override]、return」——玩家領導那支在它前面，所以只有【玩家交出盟主之後】才走到 ⇒ **NPC 新盟主從此不重建目標**，goals 永遠是玩家留下的那個詞。今天那個詞沒讀者 ⇒ NPC 勢力等於永遠沒有勢力義務；本票換成引擎詞之後 ⇒ NPC 勢力會永遠執行玩家最後一道令。

## 改法

### 一、目標＝引擎詞＋（攻擊／外交）一個對象
- `FACTION_GOALS = ["攻擊", "徵收", "外交", "立國"]`；`FACTION_GOAL_LABELS` 只剩 `"": "清除（不設目標）"`（其餘標籤＝詞本身）。expand／defend／trade_net 刪，不留別名。
- `FactionData` 加 `player_goal_target: int = -1`（攻擊／外交的對象；其他詞恆 -1）。註解寫：只有玩家寫、只有 `faction_directive_target` 讀。
- `_action_set_faction_goal`：讀 `faction_goal_input`＋`faction_goal_target_input`。
  - 攻擊／外交 ⇒ 對象必填，且在 `directive_target_candidates(state, pt)` 裡（見 §二），否則 ok:false 回理由。
  - 徵收 ⇒ 對象恆 -1（成員照 `_richest_member` 自己找，同 NPC）。
  - 立國 ⇒ §三的閘。
  - 清除 ⇒ override＝""、target＝-1。
  - 句子：「勢力目標設為 攻擊 Team{X}」／「…設為 徵收」／清除「清除勢力目標」。
- 選單：兩層——先選詞，攻擊／外交再選對象（沿用終端既有的對象選單形狀，實作端挑現成的那一支，不另寫）。對象列表＝§二候選集；空 ⇒ 該詞灰掉並寫原因「你知道位置的獨立隊伍：0」。
- 面板：「目標：攻擊 Team{X}（你設的）」；對象已不在候選集（死、入勢力、你不知道它在哪）⇒ 後面加「（對象已失效：{原因}）」。
  - ★兩個顯示點都改（R² 小項）：`text_ui_main.gd:2939` 與 `:1714-1717`（「★玩家指定: 」那行，今天印原詞、會缺對象）；`player_api_mapper.gd:1124` payload 加 `player_goal_target`（絕對 id）。
  - 誠實限（交件信印一次）：「對象已失效」只覆蓋**玩家這邊**的失效；某個成員不知道 X 在哪只有 Probe，面板照印「攻擊 X」。
- 殘留舊詞（舊 override 是 expand／defend／trade_net）：標籤查不到回原詞；玩家領導下 override 不在 `FACTION_GOALS` ⇒ 下次 `_rebuild_goals` 清空並 Probe `faction.override_cleared_stale_word`。

### 二、對象一支函式，成員與選單共用
- 新 `FactionAISystem.faction_directive_target(state, team, f, word) -> int`（static 或掛 shared() 皆可，**全專案唯一一支**）：
  - `f.player_goal_target != -1` ⇒ 回它，但要過成員自己的感知：`state.teams.has(X)`、X 仍 `faction_id == -1`、`BeliefSystem.belief_pos(state, team.team_id, X) != (-1,-1)`；任一不過 ⇒ 回 -1（**不 fallback 到最近者**——玩家說打 X，成員不知道 X 在哪就不該去打 Y）。Probe：`directive.pinned.used`／`directive.pinned.unknown_to_member`／`directive.pinned.invalid`。
  - 否則 ⇒ `_nearest_independent(state, team)`（現況逐字）。
- `decision_context.gd:1136-1145` 攻擊、外交兩處改呼它；徵收不動。
- `options.gd` `外交.to_task` 改呼它（取代自己那份 `_nearest_independent`）——門與執行讀同一個對象（同 `攻擊` 已做過的那一刀，見 options.gd:419-421 註解）。
- `directive_target_candidates(state, pt)`（選單＋action 驗證用）＝玩家隊 `team_discovered` 中：存在、`faction_id == -1`、玩家隊對它有 `belief_pos`。**與 `_nearest_independent` 的母體同一個過濾**（獨立隊＋有情報）；不開放打別的勢力——那不是成員今天會讀的東西，要開是另一張票的 WHAT（給藍圖的 FYI 已寫）。
- NPC 勢力 `player_goal_target` 恆 -1 ⇒ 走原路，逐位不變。
- `faction_directive_target` 容忍 `f == null`（獨立隊直呼 `外交.to_task`）⇒ 退回 `_nearest_independent`；`外交.to_task` 自己 `state.factions.get(team.faction_id)`。實作端 grep 全部 `to_task` 呼叫並貼。
- 「全專案唯一一支」指的是**勢力義務的對象**；`_nearest_independent` 其他使用者（faction_ai_system.gd:1859 盟主意圖 target、:2245 結盟候選；strategic_ai_system.gd:107／146 另一份同名函式）不歸它管，交件信列出。
- ★命令戳記（R² M2，第二輪改法）：`FactionData` 加「上次套用」兩欄 `applied_goal_override`／`applied_goal_target`；`_update_goals` 外殼（faction_ai_system.gd:1905-1933）比**現值 vs 上次套用**，不同即 changed，蓋完戳記再把現值寫進上次套用。（不能用外殼內前後快照：action 在 player_command_system.gd:1801 先寫了欄位，進外殼時前後已相同。）理由——今天只比 goals 集合＋drivers，而玩家領導時 drivers 空、goals 只有詞 ⇒「攻擊 X」改「攻擊 Y」不算變 ⇒ `directive_change_tick` 不動 ⇒ 成員不被叫醒（:1899-1904 註解那個病換一個欄位重現）。

### 三、立國：同一道閘，玩家選了不過要說
- 把 :1975-1982 的條件抽成 `FactionAISystem.establish_block_reason(state, f, for_player: bool) -> String`（空字串＝過）：
  - ★藍圖裁 2026-10-16（4b77e0823）：**玩家不看野心**——野心是 NPC 的「想不想」，玩家的想就是按下去那一下。`for_player` ⇒ 跳過野心那條，統領門檻用不打折的 `ESTABLISH_COMMAND`（0.4，即 ambition_discount＝0）；理由句不出現野心。NPC（`for_player=false`）逐字照舊。
  - 盟主隊長不存在（leader_p == null）⇒「盟主隊長不存在」（R² M3：原式 null 時整段不進；抽成理由函式時 null 必須回非空，不可用預設值放行）
  - 已立國 ⇒「已經立國了」
  - 成員 <2 ⇒「勢力至少要 2 隊（現 {n}）」
  - 統領不足 ⇒「盟主統領 {v} 未達 {門檻}」
  - 野心不足 ⇒「盟主野心 {v} 未達 {門檻}」
  - readiness 不足 ⇒「盟主隊準備度 {v} 未達 {門檻}」
  - 理由句印**實際用的門檻**：統領＝`0.4 − (野心−0.5)×0.2`、野心＝`0.7 − 0.1`＝0.6，不是常數本身。
  - `_rebuild_goals` 改呼它（行為逐字不變：過 ⇒ `_emit_goal(...立國...)`）；**呼叫位置留在 survival override 的 return 之後（:1970-1973）**，不提前。
  - 兩條路的既有差：NPC 餓了先 return、不進閘；玩家 precheck 不看糧（:1947 早退）。「同一道閘」指同一組條件，不指同樣會被餓擋。
- 玩家選立國：`establish_block_reason` 非空 ⇒ ok:false 回該句，override 不動；選單上立國那一項也用同一支判灰＋印理由。
- 過 ⇒ 寫 override＝"立國"；`_assign_tasks` :3469 照舊執行。
- `_declare_established` 加：`if f.player_goal_override == "立國": f.player_goal_override = ""`（一次性，不每小時重宣告）。
- 玩家句：立國成功由既有 `faction_establish` 訊息帶；設立國時的回句補「立國後目標清除」（單一欄位，先前的攻擊令會被這次選擇蓋掉）。

### 四、交接清掉玩家的令
- 刪 :1955-1958 G-09 支，改成：`not is_player_led(f) and (override 非空 or target != -1)` ⇒ 兩欄清空、Probe `faction.override_cleared_on_handover`，然後**往下走正常重建**。
- 理由：override 只有玩家領導時有意義；NPC 盟主不該執行前任玩家的令。這是本票換詞之後才會咬人的病，同票修。

### 五、可觀測性
- Probe 新鍵：`faction.goal_set.<詞>`、`faction.goal_rejected.<原因類>`、§二三鍵、§四一鍵。
- 不加新 stakes 列、不加對照表。

## 驗收（新床 `player_faction_goal_bed.gd`，acceptance，註冊表一列；舊床同 commit 改）
- ★G1／G1b／G1c 共用四個前提（R² 第 4 問；缺一則綠得太容易）：a 盟主隊 `player_controlled`（否則 is_player_led 假）；b 設完要呼該勢力 `_update_goals` 再 gather（action 只寫 override）；c 成員隊有 leader PersonData（decision_context.gd:1179 的 `if ldr != null`）；d 設前地板格：「攻擊」不在 faction_stakes、faction_duty 攻擊分量＝0。
- G1 攻擊 X：玩家盟主＋≥1 成員，成員對 X 有 belief、對另一獨立隊 Y 也有且 Y 比 X 近（**用成員的 belief 位置排距離**，faction_ai_system.gd:5163-5165）。床註解寫明：咬 n1 的是 `attack_target_id == X` 那格，faction_duty 變化咬不到 n1。設前 dump 成員 per-option util（`攻擊` 項值＋`attack_target_id`）；設「攻擊 X」後同一成員再 dump ⇒ `攻擊` 項的 `faction_duty` 分量由 0 變 `FACTION_DUTY_DRIVE`、`attack_target_id == X`（不是更近的 Y）。印前後兩組原始 util。
- G1b 成員不知道 X：先斷言 `belief_pos(成員, X) != (-1,-1)`（地板），再用實作端寫明的 API 清掉該成員對 X 的 belief ⇒ `faction_attack_target == -1`、`faction_duty` 攻擊分量 0、Probe `directive.pinned.unknown_to_member` ≥1（勢力義務不 fallback 到 Y；成員仍可能因自己的獵物／仇打 Y——斷言的是 faction_duty＝0，不是「不會打 Y」）。
- G1c 改對象叫醒成員（R² M2）：設「攻擊 X」→ 成員決策過一輪（`last_decision_tick` 追上）→ 改「攻擊 Y」→ **先斷言 `_update_goals` 前 `_directive_fresh(成員) == false`（地板）**→ `_update_goals` 後 `_directive_fresh(成員) == true`，下一次 gather `attack_target_id == Y`。
- G2 徵收：設「徵收」⇒ 非最富成員的 `徵收` 項 applicable 且 `faction_duty` 分量變 `FACTION_DUTY_DRIVE`。
- G3 外交 X：設「外交 X」⇒ 成員 `外交` 項 applicable、`faction_diplo_target == X`，且 `外交.to_task` 回的目標位置＝成員對 X 的 belief 位置（門與執行同一個對象）。
- G4 立國閘不過：佈置盟主統領低於門檻 ⇒ 回 `{ok:false, msg: "盟主統領 … 未達 …"}`、override 不變、30 天 `is_established` 仍 false。
- G4c 理由逐條表（R² M3）：NPC 版（`for_player=false`）六列各佈置「只有這一條不過」（隊長不存在／已立國／成員 <2／統領／野心／準備度），斷言回句含該條關鍵字；另一列全過 ⇒ 空字串。野心兩格放在 0.6 邊界兩側（0.59 不過、0.60 過）。
  - 玩家版（`for_player=true`）：盟主野心 0.3、其餘全過 ⇒ 空字串（不看野心）；統領 0.39 ⇒ 不過、0.40 ⇒ 過（門檻不打折）；所有不過的回句都不含「野心」。
- G4d 抽前抽後：同一組五個邊界佈置（每個連言一個），NPC 路 `_rebuild_goals` 後「立國」in goals 在抽前樹與抽後樹逐格相同；交件信印兩組。
- G4b 立國閘過：⇒ 下一個 `_assign_tasks` 後 `is_established`、override 清空；之後 3 天 `g2.faction_found` 只 +1（不每小時重宣告）。
- G5 交接：玩家盟主設「攻擊 X」後把盟主交給 NPC 隊 ⇒ 下一次重建後 override＝""、target＝-1，且 `goal_drivers` 非空（NPC 重建才寫 driver；G-09 舊支與玩家領導支都不寫）。
- G6 舊詞拒收：`faction_goal_input = "defend"` ⇒ ok:false。
- G7 選單：攻擊／外交在候選空時灰＋理由；立國在閘不過時灰＋理由；面板對象失效印原因。
- ★同 commit 改舊床：`directive_stamp_test.gd` ③（:61-75，R² M1）——今天用 NPC 盟主＋直寫 override 測「override 變 ⇒ 蓋戳記」，走的正是 §四 要刪的 G-09 支；改成玩家領導佈置（盟主隊 player_controlled＋state.player_id 指向它）、詞換成引擎詞（「攻擊」→「徵收」）；`player_led_faction_bed.gd:204-215`（F1b 用 "defend"）、`terminal_input_prompts_bed.gd:259`（P1h 期望 "defend"）——改的是被用戶裁掉的詞，不是放寬；F1b 原本「只印不判」那半改成真斷言（成員 faction_stakes 讀到它）。
- world-fp 不換基準（NPC 路 target 恆 -1、G-09 支只在玩家交接後走到）；若變 ⇒ 停下回報。★fp 看不到 override／target（state_fingerprint.gd:431-437 不印）⇒ 「fp 不變」證明不了 target 恆 -1；交件信另印電池各世界 `directive.pinned.*` 與 `faction.override_cleared_on_handover` 總和，無玩家世界應全 0。普查無玩家層照「你領導的勢力」那支跑一次、逐項相同。

### 負對照
| 對照 | 該紅 |
|---|---|
| n1 `faction_directive_target` 忽略 pinned（只回最近） | G1（target＝Y）、G3 |
| n2 pinned 失效時 fallback 到最近 | G1b |
| n3 `外交.to_task` 改回自己呼 `_nearest_independent` | G3 to_task 那半 |
| n4 action 不呼 `establish_block_reason` | G4 |
| n4b 玩家路傳 `for_player=false` | G4c 玩家版野心 0.3 那格 |
| n5 `_declare_established` 不清 override | G4b（found 次數 >1） |
| n6 G-09 支放回 | G5（新版 directive_stamp_test ③ 走玩家領導，**不會**紅——不是雙守） |
| n7 外殼不比 `player_goal_target`（或不更新「上次套用」） | G1c |

## 範圍外
- 目標強度／期限、成員違抗目標的忠誠帳（藍圖票明列）。
- 對別的勢力下攻擊／外交令（目前成員讀法的母體只有獨立隊）。
- 防守、貿易網：等圍城／通商有身體時用那張票的詞回來。

## 交件信要列
- G1／G3 前後 util 原始輸出。
- `faction_directive_target` 的呼叫點清單（應恰 3：gather 兩處＋外交.to_task；另選單候選共用過濾）。
- world-fp 新舊值、普查逐項比對。
- n1–n7 紅燈原文。
- G4d 抽前／抽後兩組輸出。
