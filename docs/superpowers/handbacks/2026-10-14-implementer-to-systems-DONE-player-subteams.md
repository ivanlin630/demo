---
from: implementer
to: systems
status: open
slice: 玩家子隊只做玩家給的任務
topic: 請 merge fix/player-subteams 8bcc14eb2（基 main 16b49d1af）｜全電池釘死 8bcc14eb2：126 支全綠（BATTERY_RC=0，總時 5197s）｜★憲法基準加一行請你准或退
---

# 玩家子隊：可以 merge（有一行憲法基準要你裁）

## 電池
- detached worktree `.worktrees/mm2neg` 釘死 `8bcc14eb2`。
- 126 支全綠（BATTERY_RC=0，總時 5197s），run-id `1398-20261014-150038`。
- 原始輸出：`docs/measurements/2026-10-14-player-subteams/battery-8bcc14eb2.txt`（main 上，隨本信同 commit）。

## 分支 `fix/player-subteams`（已推）
- 45f73a5d5／0e2edc716 床＋census → bfde1ff26 玩家子隊本體 → 50de08bfd 自家人（is_kin）→ 859dc7329 census tap
- → 4a38ea61e 併 main 16b49d1af → 47fc009da／34119a815 床補格 → 0abb61b3c 文件＋量測落檔
- → c3f953a13 註冊表＋world-fp expect → 8bcc14eb2 憲法基準一行。

## ★要你裁：憲法基準加一行（8bcc14eb2）
- `subteam_system.gd::send_home::taskarbiter`：`TaskArbiter.try_set(…TASK_MERGE, PRIO_PLAYER, source)`。
- 兩個呼叫端：召回送達（interaction `_deliver_order`）、建設逾時強制併回（`_tick_player_subteam`）。
- taskarbiter 型的指紋不看 inline `# gate-ok`（constitution_gate.gd:248-249 在 gate-ok 判斷之前就記）⇒ pre-push 擋。
- 照票 T 前例（048af8c75 `_action_rest`）寫進 baseline、附理由。
- 不准的話我改：召回那支併回 `_deliver_order` 既有的 try_set；建設逾時改成只發事件＋釋放、不強制併回（偏離 spec「強制併回」，要你同意）。

## 做了什麼（spec 2026-10-13-player-subteams-execute-given-tasks-HOW）
- **一、謂詞**：
  - `TeamData.player_controlled`（衍生欄，唯一寫者 `WorldState.sync_possession`）＝附身隊＋其 subteam_ids 中 `dispatched_by_player` 的。
  - `check_possession_drift` 比 want／have 兩集合。`set_subteam_parent` 觸發重算。
  - 自主子隊：面板「自主（非你派出）」；下令／召回**被接受後**才翻 `dispatched_by_player`。
- **二、決策層不碰**：
  - arbiter `_possessed_blocks` 改讀 `player_controlled`；EVENT_SOURCES 加 construction_started／resident_converted／construct_timeout；RELEASE_SOURCES 加 resident_converted／construct_timeout／discipline_fail／camp_established。
  - 入口跳過：`_evaluate_subteam` → `_tick_player_subteam`；`_decide_subteam`；loop3 野心層；`set_strategic_move`；`_evaluate_threat`；**`_evaluate_survival`**（見下「修的過程」）。
  - 外交提案生成：子隊只會經 `_decide_subteam`（引擎→外交）走到，已在入口跳過；`try_proactive_diplomacy` 只對 leader team 呼（faction_ai_system.gd:1387）。
  - 事件 `player_subteam`（推進停點、wake=false、subjects 含玩家隊）：被攻擊／斷糧／紀律失效／建設逾時／分隊／落腳不成／移居不成／建設不成。
  - ★「糧將盡」我掛在 `famine_crossed`（句子「斷糧了」），不是預警。要預警得另掛閾值，你說要就加。
- **三、各任務**：
  - 覓食：停在目標格。結果句照真採集規則：只有營地／據點的格採得到（resource_system collect），光格寫「採不到糧，只能獵野味」。
  - 偵查：停留觀察；巡邏移出子隊選單（ORDERABLE_TASKS 的成員令沒動）。
  - 落腳：到了 `establish_crude_camp`；移居自家據點：到了 `_convert_to_resident`；選單無「安頓」。
  - 建設：`OutpostSystem.BUILDABLE_TYPES` 單一來源（玩家自己的建設提示也讀它）；派 `TASK_CONSTRUCT`＋`task_extra_data{build_type, level:1, owner}`，抵達 `begin_subteam_construction`；完工 `set_owner` 讀 `construction_target.owner`＝母隊；玩家子隊完工不 `_auto_settle_builder`。
  - 一律歸建閘：只對玩家子隊拿掉；`try_merge_back` 對玩家子隊只在 MERGE 時併。
- **四、自家人**：`TeamData.is_kin`（母／子／同母兄弟）；`try_proactive_diplomacy` 與威脅掃描（decision_context）共用。
- **五、腳下派遣**：派往腳下就不寫 move_target ⇒ 當下抵達。原因：同格清 move_target 在 movement 那支，但要等一格移動計時才輪到。

## 修的過程抓到的三件（床 7 紅 → 0）
1. **落腳途中就地紮營**：`_evaluate_survival`（W1 hoist）對所有 TASK_CAMP 隊「腳下可紮就紮」，在途中格就紮了。⇒ 玩家子隊不進求生（spec「不自動求生」）。床 S5b 守。
2. **覓食結果句說謊**：原本報格上 food（167）但光格採集＝0（1 天格上 167→167）。⇒ 結果句照採集規則改。
3. **召回永遠送不到（修前就壞）**：信使送令只在 `same_faction` 分支（interaction_system 那段），獨立玩家隊勢力 -1 ⇒ 永遠進不去。修前床 S9「綠」是歸建閘一天內先把子隊吞了，不是召回做的（床加地板「召回前子隊還在」後修前紅）。
   - ⇒ 收件人是玩家子隊、信使是自家人就送。
   - ★NPC 獨立隊同病，本票不動，只掛 tap `herald.kin_nofaction_undelivered`：修前 census 3 seed 皆 0（30 天沒遇到這情境）。要不要另開票由你判。

## 床 `player_subteams_bed.gd`（acceptance；註冊表列 `player-subteams`）
- 修前 main 16b49d1af：**紅 26**；修後 34119a815：**紅 0**。
- 修前已成立（綠）4 格：S6 移居轉居民、S7 抵達開工推進、S7c start_build 不被 deny、S8 不自動逃。
- 修後幾個值（`bed-postfix-34119a815.txt`）：
  - S1 有營地格：1 天隊上糧 13.1→34.3（吃 2.4）、格上 167.0→141.5。
  - S5／S6：抵達後 36 tick 成立（faction AI 依隊錯開，所以床用「等到成立、給期限」）。
  - S7 缺料原因「建民用據點需材 50.0，子隊帶 0.0」；完工 owner＝15（玩家 15），召回併回後仍 15。
  - S4c 母隊對子隊的原始威脅分 1.00，掃描不選它（佈置成不排除就會選）。
- 床的佈置（不是世界裡剛好有）：S1 目標格放玩家自己的 L0 營地；S5／S6 的「不可」格放一個別人的 L1 據點；母隊補兩名記名成員（召回要一名信使）。

## 負對照（各拔一刀、跑床、還原；`neg-*.txt`）
| 拔哪刀 | 紅哪格 |
|---|---|
| n1 一律歸建閘放回（`_evaluate_subteam` 不分流玩家子隊） | S1、S5 |
| n2 arbiter 謂詞改回 `possessed` | S3b |
| n3 外交拿掉 is_kin | S4b（300 次走到通商 300） |
| n4 自家信使送令拿掉 | S7b、S9 |
| n5 求生不跳過玩家子隊 | S5b |
| n6 威脅掃描拿掉 is_kin | S4c（選中母隊、分 1.00） |
| n7 謂詞不含子隊（spec「拿掉謂詞」） | 14 格，含 S3、S4 |
| n8 建設改回 TASK_BUILD（spec 那刀） | S7、S7b |
- ★第一版床 n2／n3／n5 拔了不紅：入口跳過已擋住，arbiter 那一層與 kin 在床上沒有會紅的格。⇒ 補 S3b／S4b／S4c／S5b，補完才紅。
- ★n3 第一次 S4b 只數「找上門」＝恆 0（通商暫停中不送）⇒ 改數「走到通商分支」。

## census（先量，30 天；修前 16b49d1af 只打 tap、修後 47fc009da）
| seed | 一律歸建閘 修前→修後 | kin.threat_best 修前→修後 | kin 外交送出／找上門 |
|---|---|---|---|
| 1337 | 42 → 42 | 542 → 0 | 0／0 |
| 2 | 37 → 17 | 427 → 0 | 0／0 |
| 3 | 157 → 157 | 195 → 0 | 0／0 |
- 歸建閘各 task 分佈記進 known_issues（「NPC 子隊抵達＝完成」那條）。
- seed 2 的 37→17 是自家人不當威脅改了 NPC 世界；1337、3 分佈逐項相同。
- 只報計數，不下行為因果。
- 修前 seed 1337 那輪撞 wrapper 360s 被殺（1337 跑完之後），2、3 另跑；檔內有註。

## world-fp（換基準）
- `8e0287d1…` → `4a8102dec551e5c21c86105da0c5c54a`。
- 二分（`worldfp-bisect-summary.txt`）：
  - 遮 `dispatched_by_player`／`player_controlled`／`_player_ctrl_ids` ⇒ `8e0287d1`（＝舊）。
  - 再拔兩處 is_kin ⇒ 仍 `8e0287d1` ⇒ 差異只在新欄；自家人規則與具名來源在這顆 warring_states 種子看不到效果（census seed 2 看得到）。

## 要列的
- **抵達觸發、仍用預設來源 "transition" 的**（spec 要列）：outpost_system `start_upgrade_level`:617、`_begin_facility_construction`:686、`start_demolish`:704、`_subteam_upgrade_level`:846、`demolish_with_control`:898；faction_ai `_try_resume_construction`:5723、`_trigger_defection_evaluation`:8101；interaction `_execute_settlement`:1771。玩家子隊選單走不到這些。附身隊走這幾支會不會被 arbiter 擋，我沒驗（本票沒動附身隊那半）。沒改。
- **erase_teams 不清 `construction_team_id`**：工地靠 outpost tick 懶清（outpost_system.gd:396-399，施工隊不在就清工地）⇒ 建到一半召回＝工地與進度丟掉。沒改。
- `establish_crude_camp` 本身不寫 task；落腳成功後由 `_tick_player_subteam` release（"camp_established"）。

## 量測原始輸出（`docs/measurements/2026-10-14-player-subteams/`，fix/player-subteams 上；電池那份在 main）
- 床：`bed-prefix-16b49d1af.txt`（[TREE] dirty＝床複製進去未提交）、`bed-postfix-34119a815.txt`。
- 負對照：`neg-n1…n8-*.txt`（[TREE] 印出被拔的那個檔）。
- census：`census-prefix-16b49d1af-s{1337,2,3}.txt`、`census-postfix-47fc009da-s{1337,2,3}.txt`。
- world-fp：`worldfp-full.txt`／`worldfp-M1.txt`／`worldfp-M2.txt`＋`worldfp-bisect-summary.txt`。
- 截掉模擬 log（[ 開頭行）與開局對帳區塊，檔頭有註。

## 已消費的 GO
- `2026-10-13-systems-to-implementer-GO-player-subteams-execute-given-tasks.md`

## 下一輪
- 照佇列：附身隊三件（GO-possessed-team-followups，乙先量再動）。
