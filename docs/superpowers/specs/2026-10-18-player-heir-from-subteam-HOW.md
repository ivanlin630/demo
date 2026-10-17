# 玩家從子隊繼位（子隊獨立成玩家的新本隊）— HOW（第二版，依 R² M1–M4／S1–S6）

- 審查：R² `docs/superpowers/handbacks/2026-10-18-reviewer-to-systems-R2-player-heir-from-subteam-ISSUES.md`。

- WHAT：用戶裁 2026-10-17「甲」，意圖帳 `docs/mechanism-intents.md:37`：玩家死、本隊沒有記名可接而子隊有記名成員 ⇒ 從子隊選繼承人；那支子隊脫離母隊、成為玩家的新本隊（不得被電腦母隊召回或併掉）；原母隊照「領袖死 → 最強者接位」走電腦繼承；多支子隊有候選 ⇒ 玩家自己選；附身＝繼承記憶照舊。
- 前提量測：`docs/superpowers/handbacks/2026-10-17-measurer-to-systems-DONE-round5-four-root-probes.md` §3——判定只讀本隊 `named_members`；子隊 16 的隊長 42 有名字，但**不在任何隊的 `named_members`**（隊長跟記名分職，`world_state.gd:774`）⇒ 候選要讀各子隊的 `leader_id`。
- 排序：全員在場之後（progress 板）。本張提前寫；file:line 在 main `97d059175` 上讀，**批尾小修二合併後動工前重對**——小修二 B3 會把「無繼承人」的句子收成 `EventSystem.story_end_reason`，本張接在它上面。
- 範圍：玩家路徑。觀察者世界（`player_id == -1`）不走這條（`event_system.gd:85-86` 照舊）⇒ world-fp 不變。

---

## 一、現況

- `handle_player_succession`（`event_system.gd:79-103`）：本隊 `named_members` 空 ⇒ 故事結束、母隊走 `_npc_succession`；非空 ⇒ 開 `choose_heir` 視窗，候選＝本隊 `named_members`。
- 候選過濾（`player_command_system.gd:2018-2027`）只留「仍在該隊 `named_members`」的人。
- `_action_choose_heir`（`:2252-2280`）：`set_leader(team, heir)`——`set_leader` 會把那個人的 `team_id` 強制改成 `team`（`world_state.gd:777`），所以子隊的人被選上會被拉回母隊。
- `player_controlled` 是從附身隊的 `subteam_ids` 推出來的（`world_state.gd:1168-1190`，`player_controlled_ids_derived`）：附身隊一換，`sync_possession` 會自動重算誰是玩家子隊。

## 二、候選

- 一支 `EventSystem.heir_candidates(state, team) -> Array`（唯一產生者；視窗、過濾、合法性檢查、故事結束句都讀它）：
  1. 本隊 `named_members` 裡還活著的人 ⇒ `{pid, from_team: team.team_id}`。**本隊有人就只列本隊**（WHAT：本隊無記名可接**才**從子隊選）。
  2. 本隊沒有 ⇒ 每一支子隊（`team.subteam_ids` 裡還存在、`parent_team_id == team.team_id` 的）的 `leader_id`（若活著）＋ `named_members` 裡活著的人 ⇒ `{pid, from_team: sid}`。「活著」＝`persons.get(pid) != null`，本隊與子隊同一個濾法（S1b）。
  - 子隊不分是不是玩家派的：玩家隊附身期間電腦不替它派子隊（不變量 12），所以 `subteam_ids` 裡本來就只有玩家派的；若出現附身前留下的親屬子隊，也算（它的人也是你隊上的人）。交件信印玩家世界裡實際出現的子隊來源分佈。
- `handle_player_succession`：`heir_candidates` 空 ⇒ 故事結束（照今天）；非空 ⇒ 開視窗，`candidates` 存上面那個陣列（帶 `from_team`）。
- 候選陣列形狀從 `[pid…]` 改成 `[{pid, from_team}…]`，讀者全列（M4）：
  - 寫：`event_system.gd:99`。
  - 過濾：`get_forced_response_options` 的 `choose_heir`（`player_command_system.gd:2018-2027`）改成重呼 `heir_candidates`、比對 pid。
  - 合法性：`_action_choose_heir` 的 `fe.get("candidates", []).has(heir_id)`（`:2259`）改成重呼 `heir_candidates` 找 pid；**選到的人屬哪支隊由重算結果給**，不信 `fe` 裡存的形狀、也不信請求端。
  - 文案：`forced_label`（`player_api_mapper.gd:646`）與視窗 `message`（`:348`）。
- 候選數上限：選單一個字母一個人（`text_ui_main.gd:2481` 註解：超過 26 個第 27 個按不到）。超過 26 ⇒ 依「本隊／子隊順序、子隊內隊長先」取前 26，`Probe.bump("heir.candidates.truncated")`，視窗加一行「另有 N 人未列出」。
- 視窗文案：子隊的候選後面加「（子隊 Team12，在 (x,y)）」；選項 label 同一支產生。名稱走 names.tsv（小修二 E2）。

## 三、選了子隊的人之後

`_action_choose_heir` 分兩支（`from_team == team` 走今天那一支，不動）。`from_team == sid`（子隊）：

1. **脫離母隊**：`state.detach_subteam(sub)`（`world_state.gd:677`，走 `set_subteam_parent(sub, -1)`）；接著照專案三個先例收尾（M2）：`remove_tag(sub, TAG_SUBTEAM, "heir_independence")`（先例 `interaction_system.gd:686-687`、`:1816`、`faction_ai_system.gd:4409`），並清 `sub.dispatched_by_player = false`（脫離後語意不成立；留著的話它日後被掛到別人名下會被誤判成玩家派的）。
   - 順序固定（S2）：先脫離、後換 `player_id`。`set_subteam_parent` 對 `player_controlled` 的子隊會先跑一次 `sync_possession`（`world_state.gd:674-675`），此時 `player_id` 仍是死者 ⇒ 走「戰死窗口保持」（`:1158`），結果正確。顛倒順序會讓母隊在 `_was_ctrl` 那段被重設看守比（`:1176-1179`）。註解寫在這一段。
2. **接位**：`heir` 不是 `sub` 的隊長 ⇒ `state.set_leader(sub, heir, "member")`（原隊長降為記名，同 `set_leader` 現成參數）；是 ⇒ 不動。
3. **換玩家**：`state.player_id = heir`；`state.sync_possession()`。⇒ `sub.possessed = true`；`player_controlled` 依新附身隊重算——原母隊的其他子隊不再是玩家子隊（改由電腦帶），不用手寫。
4. **原母隊交電腦**：`EventSystem.new()._npc_succession(state, team)`（唯一一份 NPC 繼承路，`event_system.gd:44-47` 註解禁止另抄）。它補不出人 ⇒ 照它原本的路走（匿名晉升／崩潰）。
5. **勢力**：子隊在派出時抄了母隊的勢力（`subteam_system.gd:158`）。脫離後**照舊留在那個勢力**（不另寫勢力邏輯）——若原母隊是盟主，玩家的新隊就成為原母隊（電腦）手下的成員。**這一點已送藍圖確認**（見交回）；回覆若是「獨立出來」，改成脫離時 `set_team_faction(sub, -1, …)` 一行。
6. 子隊原本的任務、目的地照舊（它本來就在跑玩家給的任務；附身後決策層不准寫，只有玩家能改）。
7. 不設 `game_over`。
8. 事件（玩家事件流，一支產生者）：「你接手了子隊 Team12（在 (x,y)）。它從 Team5 獨立出來，成為你的隊；Team5 由 <新隊長> 帶，交給電腦。」母隊補不出領袖（`_npc_succession` 回 false，`event_system.gd:73-74`）⇒ 後半改「Team5 沒有人能接手」（S6）。
9. **共用收尾**（S3）：清 `player_forced_event`、`player_state.erase("heir_id")`、印 log（今天 `:2276-2280`）抽成一支，兩支分支都呼它。
## 三之二、不得被母隊併掉（M1）

WHAT 寫「不得被電腦母隊召回或併掉」。召回與 `try_merge_back` 以母子關係為前提，脫離後自然不成立（而且 `try_merge_back` 對附身隊本來就 return false，`subteam_system.gd:231`）。但另有兩條現成的併入路徑對任何附身隊都沒守，這張把玩家放在最壞的位置（人少、同勢力、旁邊就是強母隊）⇒ 在這張堵，修在寫入端：
- **(A) 同勢力同格、兩隊都閒置、大併小**：`interaction_system.gd:407,416-423`。附身主隊同勢力時會走到這裡（`:283-287` 的 `pass`）。⇒ 任一方是玩家方（小修二 D7 的謂詞）⇒ 不併。
- **(B) 吸納**：`_find_absorb_target`（`faction_ai_system.gd:7850-7870`）的母體沒有排除附身隊；到格後 `_try_merge` → `_resolve_mergein`（`interaction_system.gd:1742-1767`）會溶掉玩家隊，或把它重掛到吸納者名下並 `TaskArbiter.release` 它的任務。⇒
  - `_find_absorb_target` 的母體排除玩家方；
  - `_try_merge`／`_resolve_mergein` 入口再守一次：被吸者是玩家方 ⇒ 放手，`TaskArbiter.release(merger)`（同現有 reject 分支）。
- 三處同一支謂詞（D7 的「玩家方」），不另寫。
- 這兩條是全專案附身隊的通用洞（不只繼位之後）；堵了之後，玩家附身的隊不再被電腦併或吸納——這就是不變量 12 的寫入端排除，不是新的設計。交件信寫一句；它會讓「玩家投靠電腦隊」只剩玩家自己下令的那條路（`join` 類動詞），不受影響。

## 四、小修二 B3 那句

- 小修二 B3 的過渡句「子隊 <名> 有記名成員，從子隊接手還沒做」在本張之後不會再出現（子隊有人就開視窗）。`story_end_reason` 裡那一支刪掉；兩邊都沒人那句照舊。
- 交件信寫刪了哪幾行、相關床怎麼改。

## 五、tap

`heir.candidates.home`、`heir.candidates.subteam`、`heir.chosen.home`、`heir.chosen.subteam`、`heir.subteam.detached`、`heir.parent_to_npc`。

---

## 驗收

- 新床 `scripts/debug/player_heir_from_subteam_bed.gd`，閘列 `player-heir-from-subteam`，expect `=== player_heir_from_subteam DONE === errors: 0`。真鍵路徑（視窗選人）。

| 格 | 斷言 |
|---|---|
| S1 | 本隊有記名 ⇒ 候選只有本隊；選了照今天（現成 `player_team_succession_bed` 照綠） |
| S2 | 本隊無記名、一支子隊（隊長記名、`named_members` 空，同量測員那一局）⇒ 視窗開、候選＝子隊隊長；不出故事結束 |
| S3 | 選他 ⇒ 子隊 `parent_team_id == -1`、母隊 `subteam_ids` 不含它、標籤不含「子團」、`dispatched_by_player` 為假、`player_id` 是他、子隊 `possessed`、母隊不 `possessed` 且有新隊長（電腦繼承）、`game_over` 為假；事件句一句 |
| S4 | 兩支子隊都有候選 ⇒ 視窗列兩支、各帶子隊名；選第二支 ⇒ 第二支變本隊，第一支仍是母隊的子隊、`player_controlled` 為假（改由電腦帶） |
| S5 | 子隊候選是記名而非隊長 ⇒ 他接位、原隊長降記名、仍在同一隊 |
| S6a | 原母隊與新隊同勢力、同格、都閒置，推 3 天 ⇒ 新隊仍在、人數不變（**修前先紅**：印修前新隊被併的 tick） |
| S6b | 原母隊人多、新隊人少、母隊的吸納候選含新隊（修前），推到母隊抵達 ⇒ 新隊仍獨立、任務沒被 release（**修前先紅**） |
| S6c | 弱斷言（只作回歸）：`try_merge_back` 對新隊 0 次；新隊照原任務走 |
| S7 | 開視窗後、選之前那個子隊候選死了 ⇒ 過濾掉（同今天 N-2 的寫法）；全死 ⇒ 故事結束句 |
| S8 | 本隊與子隊都沒人 ⇒ 故事結束句「你沒有可以接手的人」 |
| S9 | 觀察者世界（`player_id == -1`）同樣的隊型 ⇒ 不開視窗、照 NPC 繼承（`heir.*` tap 全 0） |
| S10 | 勢力：母隊在勢力裡 ⇒ 新隊照舊在同一勢力（或依藍圖回覆改成獨立）；斷言照回覆；推 3 天，勢力層對新隊寫任務／移動目標的次數＝0（不變量 12，S5） |
| S11 | 候選 27 人以上 ⇒ 列 26、`heir.candidates.truncated`=1、視窗有「另有 N 人」 |
| S12 | 母隊所有人都在子隊（本隊 pop＝0）⇒ 選一支子隊後，母隊照 `_npc_succession` 的路；其餘子隊的去向印出（交件信寫結論，S4）；事件句不印空名字 |
| S13 | 子隊候選正在運糧（`task_extra_data.convoy_phase`）⇒ 接手後任務的走法印出（交件信寫結論，S1a） |

- 母體地板：S2–S7 每格印候選數與 `from_team`，候選數 ≥1 才算數。
- 負對照：
  - n1：候選只讀本隊 `named_members` ⇒ S2 紅（故事結束）
  - n2：候選不讀子隊 `leader_id`（只讀子隊 `named_members`）⇒ S2 紅
  - n3：子隊那支走 `set_leader(team, heir)`（舊路）⇒ S3 紅（人被拉回母隊）
  - n4：不 `detach_subteam` ⇒ S3 紅（`parent_team_id`／母隊 `subteam_ids`）
  - n6：拿掉 (A) 的守 ⇒ S6a 紅
  - n7：拿掉 (B) 的守 ⇒ S6b 紅
  - n8：`_action_choose_heir` 合法性改回 `fe.candidates.has(heir_id)` ⇒ S2–S5 全紅（恆「非合法候選」）（被召回或併掉）
  - n5：本隊有人時也列子隊 ⇒ S1 紅
- world-fp：照常跑閘，預期不變；變了歸因。
- 驗收後 QA 真玩：同一 seed 第一局第 4 天那一刻（量測員那筆樣本），應該開視窗、能選子隊隊長。

## 誠實限

- 勢力歸屬待藍圖回覆；HOW 預設「留在原勢力」，是因為那是不寫新邏輯的那一支，不是因為它比較對。
- 玩家的新隊沒有據點、人少：這是 WHAT 的後果，不在本張補。
- 附身前留下的親屬子隊也算候選；若藍圖要「只算玩家派的」，`heir_candidates` 加一個 `dispatched_by_player` 條件。
