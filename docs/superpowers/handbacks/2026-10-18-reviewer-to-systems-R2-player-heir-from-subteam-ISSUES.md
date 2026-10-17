---
from: reviewer
to: systems
status: consumed
slice: 玩家從子隊繼位
topic: R² VERDICT＝ISSUES（4 條 must-fix：M1–M4；小項 S1–S6）。靜態讀 code（main 94a9f28a6 一帶），沒跑測試。
---

# 一、你問的五點，先答

| 點 | 答 | 依據 |
|---|---|---|
| 1 子隊不篩 `dispatched_by_player` | 站得住，補兩個小條件（S1） | `world_state.gd:1190`；`subteam_system.gd:130,187,218`（AI 派的信使／移民 `leader_id=-1`，被 `leader_id` 判斷自然濾掉） |
| 2 順序與半套狀態 | **同步單次呼叫、中間沒有 tick，InvariantAudit／`check_possession_drift` 看不到半套**；但第一步會順帶呼 `sync_possession`（見 S2），而脫離的收尾漏了一件事（M2） | `world_state.gd:665-675,1154-1192` |
| 3 勢力預設留原勢力 | 沒有「對玩家隊自動做事」的新規則；**但原勢力內有兩條現成的併入路徑會併掉它（M1）**——這是這張最大的洞 | `interaction_system.gd:407-423`、`:1742-1767`、`faction_ai_system.gd:7850-7870` |
| 4 召回／併回窮盡 | **不窮盡**，且 S6／n4 的紅燈位置不成立（M1、M3） | 見下 |
| 5 n1–n5 | n1、n2、n3、n5 能紅；n4 紅不在 S6（M3） | 見下 |

# 二、must-fix

## M1 「不得被電腦母隊併掉」只擋了一條路，另外兩條現成的併入路徑沒擋
spec §三只說召回／併回靠 `parent_team_id == -1` 自然不成立（`try_merge_back`，`subteam_system.gd:226-228`）。我把把「A 被併進 B」的寫入端全列了一遍（`merge_teams`／`_merge_into`／`set_subteam_parent(…, absorber)` 的非 debug 呼叫者：`interaction_system.gd:423,1757,1760,1802`、`subteam_system.gd:255,400`、`world_state.gd:678`）。除 `try_merge_back` 外還有：
- **(A) 同勢力兩隊同格且都閒置，大的併小的**：`interaction_system.gd:407,416-423`：`same_faction` 分支，`a`、`b` 都是 `TASK_IDLE` ⇒ 人口多的當 absorber、少的被 `merge_teams(..., all_npcs)` 整隊搬走。玩家隊進這個分支的路是 `:283-287`（同勢力 `pass`）。新隊「照舊留在原勢力」（§三-5）＋站著不動（閒置）＋原母隊（同勢力、人多）走到同格 ⇒ 玩家的新隊被併掉（或對方若較小則反過來被玩家隊吞，同樣是 AI 寫附身隊）。`interaction_system.gd` 全檔 `possessed`／`player_controlled` 只在 `:398,403,882` 三處，沒有一處守這條。
- **(B) 吸納**：`options.gd:276-289`「吸納」選項的目標來自 `faction_ai_system.gd:7850-7870` `_find_absorb_target`：母體是強隊 `team_discovered` 裡「信念人口 < 自己 70% 且裝得下」者，**沒有任何 `possessed`／`player_controlled` 排除**（`decision/` 目錄 grep 無此二詞）。原母隊（同勢力、剛失去子隊、人還多）正是最像的獵物主人；到格後 `_try_merge`→`_absorber_accepts`（只看吸納者的野心×統領×餵養，`:1686-1700`）→`_resolve_mergein`（`:1742-1767`）：`dissolve` 時直接 `merge_teams` 把玩家隊溶掉；否則 `set_subteam_parent(absorbed, absorber)` 把玩家隊重新掛回母隊並 `TaskArbiter.release(absorbed)` 改寫它的任務（不變量 12 的寫入端）。
- 這兩條對任何附身隊本來就存在（現況漏洞），但這張的 WHAT 明寫「不得被電腦母隊召回或併掉」，且這張把玩家隊放進「人少、同勢力、附近就是強母隊」的最壞位置，所以得在這張堵（修在寫入端排除，不在 UI）。
- 要求：
  1. `_find_absorb_target` 把附身隊與 `player_controlled` 隊排除出母體；`_try_merge`／`_resolve_mergein` 的入口再守一次（被吸者是附身隊或玩家控制隊 ⇒ 放手，`TaskArbiter.release(merger)` 同現有 reject 分支）；`:416-423` 的閒置併合同樣守（任一方是附身隊或玩家控制隊 ⇒ 不併）。三處同一支謂詞（D7 的「玩家方」，不另寫）。
  2. 驗收：S6 加兩格——(a) 原母隊與新隊同勢力、同格、都閒置，推 3 天 ⇒ 新隊仍在、人數不變；(b) 原母隊人多、新隊人少且母隊的吸納目標候選含新隊，推到母隊抵達 ⇒ 新隊仍獨立。兩格都要有**修前先紅**（印修前新隊是否被併／重掛）。負對照 n6：拿掉 (A) 的守 ⇒ (a) 紅；n7：拿掉 (B) 的守 ⇒ (b) 紅。
  3. 若你判斷這兩處排除超出本張範圍（它們是全專案附身隊的通用洞），請寫成交件信的「已知缺口」並送藍圖：WHAT 的一句承諾就沒有被兌現。

## M2 脫離只做了 `detach_subteam`，漏了現成的收尾
- 專案內三個「子隊脫離變獨立」的先例都在 `detach_subteam` 之後 `remove_tag(…, TAG_SUBTEAM, …)`：`interaction_system.gd:686-687`（`envoy_orphan`）、`:1816`（`convert_resident`）、`faction_ai_system.gd:4409`（`discipline_fail`）。spec §三 的脫離沒有。
- `TAG_SUBTEAM` 還被這些地方讀：`faction_ai_system.gd:857,1415-1416`（子隊不評估叛離）、`:1759`、`interaction_system.gd:800`（徵收對子隊的處理）、`:1835`、`event_tag_shift.gd:25`（有此標籤不做標籤轉變）。玩家新隊留著「子團」標籤會被當成子隊處理、且 `parent_team_id == -1` 與標籤並存（那正是 `_recall_envoy_home` 的註解「非 zombie」要避免的）。
- 要求：脫離時 `remove_tag(sub, TAG_SUBTEAM, "heir_independence")`；同時決定 `sub.dispatched_by_player`（`team_data.gd:264`）要不要清（它在脫離後語意已不成立；若留著，之後它又被掛到別人名下時會被誤判為玩家派的）。寫明並加格：S3 斷言標籤不含「子團」、`dispatched_by_player` 為假。

## M3 S6 與 n4 守不住它要守的東西（守衛恆同答案）
- S6：「脫離後推 3 天：原母隊沒有召回／併掉玩家的新隊（`try_merge_back` 對它 0 次）」。但 `try_merge_back` 第 231 行：`sub.player_controlled and sub.current_task != TASK_MERGE ⇒ return false`；而附身隊本身就在 `player_controlled` 集合裡（`world_state.gd:1187` `out.append(_possessed_tid)`）。⇒ 即使**不脫離**，新隊（已附身）也不會被 `try_merge_back` 併回；S6 的 0 次在修前就成立。
- n4「不 `detach_subteam` ⇒ S6 紅」因此不成立：不脫離時 S6 仍是 0 次，綠。真正會紅的是 S3 的 `parent_team_id == -1`、母隊 `subteam_ids` 不含它。
- 要求：S6 改成直接量 M1 的兩條路（上面 (a)(b)）；n4 的紅燈位置改為 S3（並寫明 S6 的 `try_merge_back` 0 次是弱斷言，僅作回歸）。

## M4 候選陣列形狀改了，三個讀者沒列全，UI 還有 26 鍵上限
- 候選從 `[pid…]` 改成帶 `from_team` 的陣列。讀者：`event_system.gd:99`（寫）、`player_command_system.gd:2023`（過濾，`int(pid)` 當 pid 用）、`player_command_system.gd:2259`（`fe.get("candidates", []).has(heir_id)`，拿整數對字典陣列比 ⇒ 恆 false ⇒ 一律「非合法候選」）。spec 只提了 `get_forced_response_options`。
- `text_ui_main.gd:2481` 註解寫「choose_heir 的候選數若超過 26，第 27 個按不到」；子隊候選把名單加長，本隊記名＋多支子隊可能超過 26。
- `forced_label`（`player_api_mapper.gd:646`）與視窗 `message`（`:348`）都吃候選；「子隊 Team12，在 (x,y)」要由同一支產生。
- 要求：讀者清單寫全；`_action_choose_heir` 的合法性檢查改讀 `heir_candidates` 重算（不信 `fe["candidates"]` 的形狀）；選到的人屬哪支隊由重算結果給（不信請求端）；候選數超過 26 時寫明截斷或分頁的做法（至少 `Probe.bump("heir.candidates.truncated")` ＋ 驗收一格）。

# 三、小項（不擋，併同輪）
- **S1 子隊候選**：(a) 子隊正在帶貨運送（`task_extra_data` 有 `convoy_phase`，`interaction_system.gd:247-249` 一帶）時，新隊繼承的是中途的運糧任務；脫離後它不會再「併回」收尾（`convoy.return` 只在併回點計）。請交件印一次，確認任務在無母隊情形下的走法；(b) `leader_id` 與候選人 `persons.get(pid) == null` 要濾（死者留在 `named_members` 的情形，同本隊候選）。
- **S2 脫離會順帶 `sync_possession`**：`set_subteam_parent` 在 `child.player_controlled` 為真時呼 `sync_possession()`（`world_state.gd:674-675`）。此時 `player_id` 還是死者、`persons.get` 為空 ⇒ 走「戰死窗口保持」分支（`:1158`），結果正確；但這是「第一步就跑一次 sync」，請 spec 寫一句，免得實作端調換順序（先換 `player_id` 再脫離）時遇到母隊被標回非附身後 `_was_ctrl` 的看守比重設（`:1176-1179`）。
- **S3 兩支分支共用的收尾**：今天 `_action_choose_heir` 的尾巴（清 `player_forced_event`、`player_state.erase("heir_id")`、印 log，`:2276-2280`）要子隊分支也跑。請寫成共用收尾，不要在兩支各抄一份。
- **S4 母隊補不出領袖**：`_npc_succession` 在母隊沒有匿名可晉升時回 false（「崩潰中」，`event_system.gd:73-74`）。母隊此時既無領袖又無人，而它還有其他子隊（原本是玩家子隊，現在變電腦帶）。spec 寫「照它原本的路走」，請加一格：母隊 pop 全在子隊的情形，其餘子隊不變成孤兒（被誰接？）；交件信寫結論。
- **S5 勢力與盟主**：若原母隊是盟主（`FactionData.leader_team_id`，`faction_data.gd:6`），脫離後盟主仍是母隊（電腦帶），不變量 12 的「盟主是附身隊的勢力」整句不再適用——這是預期的；但玩家新隊從此是電腦盟主的成員，會被徵收等（現有附庸路徑）。請 S10 另加一格：推 3 天，勢力層對新隊沒有任何寫任務／移動目標的動作（不變量 12 寫入端），印次數。
- **S6 事件句**：「Team5 由 <新隊長> 帶」在母隊補不出領袖（S4）時要換句，不要印空名字。

# 四、結論與下一站
- 判定：**ISSUES**。M1–M4 都在 HOW 內；M1 的第 3 點若選擇不在本張堵，要送藍圖（WHAT 的承諾缺口）。
- 修完回 R²b，只審 M1–M4 對應段＋S1–S6 有沒有收。
- 排程不變：全員在場之後動工；沒有急迫。
- 沒重審：小修二 B3 已 CLEAN 的段。
