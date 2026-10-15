---
from: implementer
to: systems
status: consumed
slice: 你領導的勢力不自動定目標＋收編要告訴你（spec 2026-10-15-player-led-faction-no-ai-goals-and-subjugate-tells-HOW＋你的裁定 2026-10-16-systems-to-implementer-RULING-player-led-faction-two-premises）
topic: 請 merge feat/player-led-faction f3da28eba（已併 main 8b12326b5，docs only）｜全電池釘 f3da28eba：136／136 全綠 RC=0（run-id 55203-20261016-055840）｜床 21／21 errors 0；10 刀負對照全紅在該紅的格｜普查無玩家層逐項相同（3 seed goals 分佈與所有計數逐項相同；有玩家層 NPC 側也逐項相同）｜兩條前提照你的裁定做完
---

# 結論

- 分支 `feat/player-led-faction` tip `f3da28eba`，base main b35535bfa，已併 origin/main 8b12326b5（只有 docs）。
- 全電池（detached worktree `.worktrees/mm2neg` 釘 `f3da28eba`）：136 支全部通過、BATTERY_RC=0、run-id `55203-20261016-055840`；跑前跑後樹 sha 都是 f3da28eba、跑前 `git status --porcelain` 0 行；原始輸出 `battery2-f3da28eba-green.txt`。「本地多出 player-led-faction」＝本支新註冊的床閘。
  - ★第一輪（釘 da55e934f，run-id `2453-20261016-022111`）RC=1 紅 3 支，原始輸出 `battery1-da55e934f-red.txt`：
    1. ki-status——你登的 known_issues 條目（未確認＋回訪非量測窗），你已在 main 5ce024d17 修，我併進來。
    2. value-key 第二段 lookup-key——床 S2 兩句期望字面「全庫只出現一次」，照 `.lookup-key-allow.tsv` 既有前例（threat_column_bed）登 allow（2954f0605）。
    3. **map-memory**（P3「team_tile_known[玩家] 非空（0）」）——**真缺陷，是我造的**，見下面「spec 前提不符第三條」；修在 f3da28eba，電池前另跑 map_memory_bed＋本票床都綠（`map-memory-bed-f3da28eba.txt`、`bed-full-f3da28eba.txt`）。
  - ★中間有一輪作廢（`void-concurrent/`）：我 TaskStop 停掉的排隊腳本在 Windows 上只停了外層，子 bash 變孤兒繼續跑 ⇒ 兩支電池同時跑、其中一支在另一支跑到一半時把 mm2neg 切到別的 commit。兩支都砍掉、輸出作廢，上面那一輪是之後乾淨單獨跑的。同一個孤兒現象今天發生兩次（另一次是砍掉 627504c19 那輪時留下的 merge-gates／bed-parse-gate 子行程，也是我手動找出來砍的）。這是給 memory 的教訓：**背景鏈要停就 taskkill /T 整棵樹並確認 0 支殘留，不能只信 TaskStop**。
- 新床 `scripts/debug/player_led_faction_bed.gd`（acceptance，21 格到場點名），註冊表新列 `player-led-faction`，expect `=== player_led_faction DONE === 到場 21／21 errors: 0`。
- 原始輸出全在 `docs/measurements/2026-10-16-player-led-faction/`。

# 改了什麼

commit 序：ad9cae1bb（tap＋普查床，先量再改）→ 3fc95ae9e（主體）→ 627504c19（併 main docs）→ da55e934f（世界 A 佈置，n1 血證）→ 2954f0605（lookup allow）→ 7c04f55bb（併 main 5ce024d17）→ f3da28eba（十支記帳半）

| 改法 | 位置 |
|---|---|
| 謂詞 | `WorldState.is_player_led(f)`（data 層唯一一支）；`FactionAISystem.is_player_led` 薄殼 |
| 清成員指派 | `WorldState.clear_member_assignments(f)`；三個呼叫點：`StrategicAiSystem.tick` 頂端、`succeed_or_disband_faction` 設完 leader 後、`set_team_faction` 入玩家勢力（只清那一隊，同咽喉） |
| 1 目標 | `_rebuild_goals` leader null 早退之後：玩家領導 ⇒ 只放 override、`intent = {}`、`strategy = "玩家領導"`、return |
| 2 戰略 | `StrategicAiSystem.tick` 所有戳記之前：玩家領導 ⇒ 清 → return（`_evaluate_alliance_need` 一併略過） |
| 3 外交 | `try_proactive_diplomacy` 入口、randf 之前：`sender.player_controlled ⇒ return` |
| 4 背叛 | BETRAY 迴圈 `member_team.player_controlled ⇒ continue` |
| 5 十支 | `info_side_dispatch_all` 迴圈、`info_eval_next_tick` 戳記之前：`team.player_controlled ⇒ continue` |
| 6a 列＝做 | `NpcCombatSystem.subjugate_block_reason`（純門，`_try_subjugate` 自己用它）；`PlayerCommandSystem.subjugate_block_now`（固定 on_captured_tile=false，註解寫了為什麼）＝precheck 與 encounter_view 兩處（GUI `J:收編敗者`、終端 `_post_combat_hint`）共用；`_action_subjugate_enemy` 做後驗 |
| 6b 事件 | params 加 `loser_team`、`_event_info{founded, faction, winner, loser}`；`WorldEvents.subjugate_sentence`；`ADVANCE_STOP_KINDS` 加 `subjugate`；text_bank 「主服」→「Team{loser} 臣服於 Team{origin}」；print 的「主服」改「收編」 |
| 6c 敵對帳 | `set_team_faction` 早退之後、`fid != -1 且 player_id != -1`：`_erase_hostile_on_join` |
| 7 面板 | mapper `player_led`、`missing_leader_verbs`（常數 `MISSING_LEADER_VERBS`）；`_build_faction_str` 兩種印法；清除項標籤「清除（跟隨 AI）」→「清除（不設目標）」 |
| 8 Probe | `faction.goals_rebuild_player_led`、`strategic.clear_player_led`、`diplo.skip_player_controlled`、`betray.skip_player_controlled`、`side.skip_player_controlled`、`subjugate.blocked.<in_faction／no_command>`、`subjugate.action_failed_after_try`、`hostile.erase_on_join.<reason>`；另加 `subjugate.surrender_failed_after_try`（乙） |
| 你的裁定 (甲) | 敗方是玩家 ⇒「你臣服於 Team{winner}，加入勢力{f}」 |
| 你的裁定 (乙) | `_surrender_subjugate`（三條投降共用）：收編前先算門的理由、收編後驗玩家 faction_id＝勝方勢力；不成立回 ok:false |

## (乙) 三條投降的拒絕句（實跑逐字，床 S4a/S4b/S4c）
- S4a `offer_surrender`：`{ "ok": false, "msg": "對方接受投降，但沒有收編你：要有統領才能收編" }`，玩家 faction_id 仍 -1
- S4b `surrender_in_encounter`：同句，faction_id 仍 -1（遭遇照舊 cleanup）
- S4c `surrender_pre_encounter`：同句，faction_id 仍 -1
- 門開著（S4，走真實的 surrender_pre_encounter）：`{ "ok": true, "msg": "投降被接受，已被收編" }`、玩家進勝方勢力、佇列恰一則「你臣服於 Team5，加入勢力1」、推進停在它
- 原因字取自 `subjugate_block_reason`（門預測不了的回「收編沒有成功」）

前提：`_transfer_surrender_assets` 在收編之前執行（既有順序，沒動）⇒ 門關著時資產仍已轉給對方。這是本票沒碰的既有行為，句子照實說「對方接受投降，但沒有收編你」；資產該不該退回不是我能定的，列出來給你判。

# 交件信要貼的四件

## ① 盟主動作「還沒做」清單 × player_command_system action 表

| NPC 盟主做的事（來源） | 玩家指令 | 列「還沒做」？ |
|---|---|---|
| 立國（goals「立國」→ `_declare_established`） | 無（`establish_faction` 是「建勢力」，不是立國） | 列 |
| 派信使傳消息（`_try_herald_side`） | 無（`order_faction_member` 經信使傳令，但不是傳消息） | 列 |
| 派斥候（`_try_scout_side`） | `order_faction_member` 任務「偵查」（ORDERABLE_TASKS） | 不列 |
| 分糧（`_try_distribute_side`） | 無 | 列 |
| 移民（`_try_migrant_side`） | 無 | 列 |
| 投資據點農業（`_try_invest_side`） | 無（`upgrade_farming` 只限腳下自家據點，不是遠程送料） | 列 |
| 下遷村令（`_try_relocate_order`） | 無 | 列 |
| 以勢力名義遠程外交（`try_proactive_diplomacy`） | 無（`propose_alliance`／`demand_tribute` 是同格隊對隊） | 列 |
| 提拔（`_try_promote_advisor`） | `promote_anon` | 不列 |
| 定目標（`_rebuild_goals`） | `set_faction_goal` | 不列 |
| 徵收率 | `set_tribute_rate` | 不列 |
| 戰略包圍（strategic_assignments） | `order_faction_member` | 不列 |

面板實印：`還沒做的盟主動作：立國、派信使傳消息、分糧給成員、往據點移民、投資據點農業、下遷村令、以勢力名義遠程外交`

## ② `faction_id` 寫者普查（字典／場景初始化有沒有繞過 set_team_faction）
- `grep -rn -E '\bfaction_id\s*=[^=]' scripts`（排除 debug）：TeamData 的寫入只有 `scripts/data/world_state.gd:605`（set_team_faction 本體）；另一筆 `:463` 是 `FactionData.faction_id`（create_faction 編號）。
- `grep -rn -E '"faction_id"\s*:' scripts`（排除 debug）：16 筆全是讀值 DTO（observer_query_api／player_api_mapper／sim_bridge／player_command_system:2461）或 dispatch_ledger 記錄（faction_ai_system:3143／3295）。
- `["faction_id"] =`：2 筆，都是 belief 快照字典（distortion_engine.gd:112、interaction_system.gd:1499），不是 TeamData。
- config JSON 的 faction_id 經 GameSetup explicit 路：`create_faction` ＋ `set_team_faction(…, JOIN_SETUP)`（game_setup.gd:697／707）。
- ⇒ **0 繞過**。
- ★我第一次下的 regex `faction_id\s*:` 抓到的 30 筆全是 `if …faction_id:` 條件句尾——那條 regex 本身答不了這題，上面兩條才是。

## ③ 十支各入口「被呼叫」計數（床原始輸出）
`bed-full-f3da28eba.txt`（各世界 30 天，pc＝玩家控制隊、npc＝其餘隊）：

| 支 | F5 玩家盟主（世界 A） | F5c NPC 勢力裡的玩家成員（世界 B） | F5b 獨立附身隊（世界 C） |
|---|---|---|---|
| promote | pc 0／npc 532 | 0／292 | 0／271 |
| herald | 0／532 | 0／292 | 0／271 |
| scout | 0／532 | 0／295 | 0／271 |
| distribute | 0／532 | 0／292 | 0／271 |
| holding | 0／532 | 0／292 | 0／271 |
| migrant | 0／532 | 0／292 | 0／271 |
| invest | 0／532 | 0／292 | 0／271 |
| relocate_order | 0／532 | 0／292 | 0／271 |
| self_relocate | 0／532 | 0／292 | 0／271 |
| contact | 0／532 | 0／292 | 0／271 |

普查有玩家層（預設 config，玩家是獨立隊）：修前 pc 每支 30（每日一次）→ 修後 0。

## ④ 修前紅格、負對照、普查
- **修前紅格**：床呼叫的是本票新加的函式（`is_player_led`、`subjugate_block_now`、`subjugate_sentence`…），修前那棵樹載不進這張床 ⇒ 沒有「同一張床跑修前」的輸出。替代證據＝下面 10 刀負對照：每一刀把那一處退回修前行為，該格就紅。普查床（不依賴新函式）有修前輸出。
- 負對照（釘 `f3da28eba`，各跑 BED_ONLY 子集，跑完 `git checkout -- scripts` 還原、每份末尾印 `git status --porcelain` 為空）：
| 刀 | 拔掉什麼 | 紅在哪（原文節錄） | 釘的樹 |
|---|---|---|---|
| n1 | 改法 1 return | `F1 玩家勢力 goals 恆空（非空 38862 tick）、intent 恆空（非空 43141 tick）` | da55e934f |
| n2 | clear_member_assignments＋入勢力清除 | `F4c …（剩 { 77: (1, 1) }）`、`F4a …（實際 -1 tick 後）`、`F4b …（剩 2 筆）` | da55e934f |
| n3 | 外交入口 | `F3 以玩家盟主隊為 sender 的勢力外交入口 22 次＝0` | da55e934f |
| n4 | betray continue | `F7 玩家隊（驅力 1.38 ≥ 硬門檻）30 天仍在勢力0（現 -1）` | 627504c19 |
| n5 | 十支 continue | `F5 十支對玩家盟主隊 0 次`、`F5c 玩家村據點 owner 30 天不變（變動 43110 tick）`、`F5c 十支…`、`F5b 十支…` | da55e934f |
| n6 | precheck 不呼 block_reason（＋終端提示傳空） | `S1 無統領：precheck 理由「」…按下 { "ok": false, "msg": "收編沒有成功" }`、`S1 敗方屬別勢力：理由「」` | 627504c19 |
| n7 | action 不驗結果 | `S1b 收編沒發生 ⇒ { "ok": true, "msg": "收編 Team4" }` | 627504c19 |
| n8 | subjects 不補＋停點不加 | `S2 成立勢力：…subjects [0] 含敗方、推進停在它（）`、`S4 …停在 ` | 627504c19 |
| n9 | set_team_faction 不 erase | `S3 …出帳（hostile 有 X=true）、地圖 is_hostile=true、同格交換＝silent`、`S3 背叛後不標（true）…` | 627504c19 |
| n10 | 投降做後驗 | `S4a …{ "ok": true, "msg": "投降被接受，已被收編" }；玩家 faction_id -1`（S4b／S4c 同） | 627504c19 |

- 每份 `neg-nX.txt` 開頭印樹 sha、`git diff --stat`（只動被拔的那一處）、末尾 `git status --porcelain` 空。
- ★**n1 第一次跑（`neg-first-run/`，釘 627504c19）只有 intent 那半紅、goals 那半照綠**：世界 A 玩家盟主原本是慎重 0.5 的人格，AI 接手本來就產空 goals ⇒ 「goals 恆空」是恆真守衛。把玩家盟主改成跟對照勢力同一組大膽人格（da55e934f）後 goals 那半才分辨得出；動到世界 A 的 n1／n2／n3／n5 用新佈置重跑（上表）。
- ★n4、n6–n10 釘的是 627504c19：那幾刀只跑世界 B 或收編格，這兩顆之間只改了世界 A 的佈置；之後到 tip 的差（lookup allow、十支記帳半、docs 合併）不碰它們切的那幾行。**10 刀沒有在 tip f3da28eba 上重跑**——照實寫。
- ★n5 第一次跑（舊佈置）出現 4 筆 `SCRIPT ERROR: Invalid get index 'values' (on base: 'Nil')`（十支跑到玩家隊、某支讀到空的 person）；新佈置那次沒出現。只在負對照（拔掉守衛）時才走得到，沒追。
- 普查（`scripts/debug/player_led_faction_census.gd`，diagnostic，兩層 × 3 seed × 30 天）：
  - 修前 `census-before.txt`（樹 ad9cae1bb）、修後 `census-after.txt`（樹 `f3da28eba`）。
  - ①無玩家層 3 seed：NPC 勢力 goals 分佈（例 seed 1337：外交=680 徵收=1174 空 1）、`dip.proactive_call.npc`、十支 npc、`betray.consider.npc`、`faction.leave.betrayal`、`mp.decide.*` **修前修後逐項相同**。
  - ②有玩家層 3 seed：NPC 側同上**逐項相同**；唯一差＝十支 pc 30 → 0。spec 預期這一層會因少耗 randf 而 RNG 位移、只能比同量級——實際沒有位移（被跳過的十支對玩家隊本來就沒耗 RNG），所以是逐位相同。
  - 收編 `subjugate.emit` 六個世界都是 0 ⇒「多喚醒敗方」在普查母體裡沒機會出現；由床 S2 直接斷言 subjects＝[勝方, 敗方]。
  - `manpower:53` 處置分布（`mp.decide.<處置>.<意圖>`）只出現在 NPC holder，修前修後相同；玩家勢力成員當 holder 的情形普查母體裡沒有（玩家不是盟主）。

# spec 前提不符第三條（我修了，報給你）：十支有記帳半

spec 改法 5 寫「十支一網打盡，不分記帳／決策（記帳半不存在…）」。**不成立**：玩家隊的**地圖記憶**（`team_tile_known`）與**市集記憶**（`team_market_known`）原本是十支的副作用——
`_try_distribute_side` → `DecisionContext.gather`（decision_context.gd:1018 `_harvest_market_known`）→ `_distribute_candidates` → `_resolve_location_prereq` → `find_nearest_known_tile`（goal_resolver.gd:1537）→ `BeliefSystem.harvest_tile_known`（belief_system.gd:545，`team_tile_known` 全庫唯一寫者）。
整支跳過後玩家隊從此不記得走過的格——電池 map-memory 抓到。

修法（f3da28eba，沒有設計選擇：感知不是決策）：玩家控制隊仍跳過十支的決策，但照原 cadence（INFO_DISPATCH_CADENCE，每日）做那兩份 harvest。
代價：戳記移進玩家分支 ⇒ 玩家交出控制後 AI 第一輪最遲晚一個 cadence（spec 原本要「立刻評」）。你若要保留立刻評，改法是另開一個欄位記 harvest 的 cadence，跟你說一聲我就改。

# 床裡你該知道的幾件

- **F1b**：設目標到下一次每小時重建之間有空窗（實測 16 tick 後到位）——goals 沒有別的寫者（grep `goals.append／clear` 只有 _rebuild_goals 與 _emit_goal），是機制延遲。斷言改成「一小時內到位、之後恆定」。成員 `faction_stakes` 現況＝`[]`，照你的裁定只印不判。
- **F4a 對照**：對照 NPC 勢力成員 30 天沒有被派任何指派（intent 不是征服／擴張、也沒有突圍）⇒ 對照那一半印「不可判」，沒湊。玩家側：殘留指派 60 tick 後清空（機制＝每小時那一圈；spec 時窗 STRATEGIC_INTERVAL＝4320 tick）。
- **F5c 佈置先證明 AI 會遷**：玩家村遷值 11.62 > 門檻 2.00；對照村（同勢力、山地、忠）30 天內真的棄了據點（relocate.self=1）。
- **F7**：玩家隊背叛驅力 1.38 ≥ 硬門檻 0.90（確定觸發、不靠骰）；對照同人格 NPC 成員走了（faction.leave.betrayal=1）；`betray.skip_player_controlled=21`。
- **S1b**：create_faction 只有勝方隊不存在時才回 -1，實際世界佈置不出「門開著但沒收成」⇒ 床把 `_interaction` 換成什麼都不做的 InteractionSystem 子類，測的是做後驗那一層本身。
- **S4**：對方接不接受投降由人格秤 ⇒ 床把 `_diplomatic` 換成必接受的子類，測的是「接受之後說什麼」。
- **world-fp**：兩輪電池 world-fp 都綠，**不換基準**（無玩家世界逐位不變，與普查①一致）。
- observer_event_text.gd:35-39 的收編旁觀句本來就是「收服」不是「主服」⇒ spec 說「同改」那一處沒有可改的字，沒動。

# 已知未做／交出去

- 普查兩層的世界裡收編 0 次（6 個世界都 0）⇒ spec 說的「唯一已知差＝收編多喚醒敗方」在普查母體裡沒有機會出現；它由床 S2（subjects 含敗方）直接斷言。
- 普查有玩家層的玩家是獨立隊（預設 config），玩家領導勢力 0 小時 ⇒ 有玩家層量到的玩家側變化只有十支（pc 由 30 → 0）。玩家當盟主的世界由床世界 A 量。
- 投降門關著時資產已轉出（上面 (乙) 段）。
- 消費：GO-player-led-faction-and-subjugate、RULING-player-led-faction-two-premises。

下一張：7b 戰後處置過渡（照你的序，之後真玩小修 → 掛單押貨）。
