# 批尾小修二（第五輪 QA 真玩 UI 面 20 洞）— HOW

- WHAT：藍圖票 `docs/superpowers/handbacks/2026-10-17-blueprint-to-systems-TICKET-tail-fixes-2-and-all-hands-on-field-pulled-forward.md` 票一（五組 A–E）；裁決檔 `docs/playtest/round5-verdict.md`。
- 來源表：`docs/playtest/2026-10-17-round5-qa-live-play.md` §二 ★1–★20、21、22。
- 排序：開點目標票交件之後（藍圖 2026-10-17 確認不插隊）。
- 範圍：玩家面。世界行為只動兩處，都是 WHAT 已裁的：B③ 繼承人看子隊、D① 收割不清掉敗者狀態。其餘不改世界。
- 下面的 file:line 是 main `1f7679c26` 上靜態讀的，動工時先重對一次。
- 共同規則：
  - 每一組都只准有**一個產生者**。不准在兩個地方各寫一份同樣的句子或表。
  - 新的事件類型、停點、確認層都要接 tap（Probe 計數），名字寫在各組裡。

---

## A 戰鬥結算讀得到（★11 ★17 ★12 ★2 ★3 第 6 條）

### A1 結算當下就進事件區
- 現況：
  - `read_player_events()` 讀進 `_feed_rows` 只有一處，在 `text_ui_main.gd:282-299`。它在 `_process` 的推進分支裡（`:267` 不在推進就 return）。
  - 戰鬥走 `encounter_view → sim_bridge.advance_encounter_tick`（`sim_bridge.gd:148-162`），不經 `_process`。
  - ⇒ `combat_end` 那一句要等下一次推進才出現。
- 改：
  - 把 `:282-299` 抽成一支 `_drain_player_events()`。
  - 兩個呼叫者：`_process` 推進分支（照舊），以及 `_on_encounter_ended`（`:226`）。
  - ★讀者仍只有一支，不另寫第二份讀法。

### A2 結算頁擋推進
- 現況：
  - 戰後畫面只有 `can_subjugate` 時才留著（`encounter_view.gd:863-880`），其他鍵一律關畫面（`:708-734`）。
  - 下一次推進就是 `settle_pending_aftermath`（`player_command_system.gd:844-865`），它會替玩家套用被動選項：放走傷兵、不追、放棄占領。
- 改：
  - 只要玩家參戰，戰後畫面一律停在**結算頁**。
  - 頁上印：
    - A3 的結算句（整句，A4 的換行規則）；
    - 當下 `aftermath_listed` 的待處置選項，來源＝`player_query_api.gd:446-484` 那一份，與 T 面板同源；
    - 戰利品／收編鍵（既有 K／L／J）。
  - 待處置選項在頁上可以直接按，走同一條 `execute_action`。
  - 推進鍵（`GLOBAL_ADVANCE_KEYS`，`text_ui_main.gd:1327`）在結算頁上：
    - 回「面板開著時不能推進（Esc 關閉）」，與既有規則同一句、同一支 `_global_advance_key`；
    - **不關頁、不推進**。
  - 只有 Esc（或 Enter）關頁。關了＝看過了；之後推進照舊套被動選項，並發「你沒有處置：…」。
  - tap：`ui.settle_page.shown`、`ui.settle_page.advance_blocked`。

### A3 結算句的內容
- 現況：`world_events.gd:573-634` `combat_end_sentence` 是唯一產生者。
  - 傷只算匿名（`:598` `wounded_mid − wounded0`）。
  - 逃散只在可追擊時出現。
  - 記名重傷只在敗方提一句註記。
- 改：每一方都印同一組欄位，順序固定：**死、傷、逃散、被俘、其他離隊**，各帶數字（0 也印）。
  - **傷**＝匿名傷兵增量＋記名成員在本場轉入重傷的人數，名字附括號。
    - 「記名重傷」的判準＝`_get_hp_status` 同一支判準（`text_ui_main.gd:1186-1197`／`player_api_mapper.gd:845`）。
    - 不另寫第二份判準：把它搬到模擬側一支 static，兩邊共用。
    - 在 `_aftermath_begin`（`encounter_system.gd:1413-1422`）記本場開始時每個記名成員的狀態，結束時比對。
  - **逃散**＝本場離開戰場、沒死沒被俘、仍屬原隊的人。
  - **其他離隊**＝下面的恆等式算出來的餘數。
  - ★**人數恆等式**（每一方、只算本場上過場的人）：
    `上場人數 ＝ 戰後仍在隊且在場 ＋ 死 ＋ 被俘 ＋ 逃散 ＋ 其他離隊`
    - 餘數大於 0 就印「其他離隊 N（原因未記）」，**不准不印**。
    - ★3 那場 6→3 的真實去向是量測員票三④在查；這一格先保證**數字不會無聲消失**，原因欄等量測結果再接。
  - 感知：對方的數字只算**上過本場**的單位，是玩家在場親見的；不讀對方隊伍此刻的總人口。
  - 戰利品照舊印可收清單。
- 收取戰利品回句（★12）：`player_command_system.gd:1317-1334` 的 `"收取戰利品成功"` 改成「收取戰利品：糧食 37、錢 131、粗製近戰武器 2」。
  - 數量就是 `:1332` 那一行 print 的同一組。
  - 物品名走 E2 的顯示名表。

### A4 事件區與結果行整句不截（★17）
- 現況：
  - 事件區 `text_ui_view.gd:300-302` 和結果行 `:317-318` 都用 `clip_to`，無聲截斷。
  - 頂列已依 10-14 裁改成整格讓位（`:153-195`）。
- 改：
  - 這兩處改成**換行**：切點在全形標點或空白，沿用 `_keymap_lines`（`:330-347`）的換行寫法，抽成一支共用函式。
  - 事件區容量以「列」計：放不下就**整則丟掉最舊的**，不截一則的半句。
  - 結果行最多佔 N 列（TEST VALUE 3），超過時整句移進事件區，結果行只留前段加「（全文見事件區）」。
  - ★判準：任何一則事件或結果，畫面上那幾列串起來＝原句全文，不准只有前半句。

### A5 傷兵欄（第 6 條）
- 現況：
  - TextUI 沒有傷兵數。snapshot 已有 `controlled_team.wounded`（`player_api_mapper.gd:190`），TextUI 沒讀。
  - 生存頁只有記名的 `成員傷:`（`text_ui_main.gd:1719`、`1211-1219`）。
- 改：
  - 生存頁加一行「傷兵：匿名 N、記名重傷 M（名…）」。M 用 A3 那支共用判準。
  - 頂列加一格「傷 N+M」，只在 N+M > 0 時出現。
    - 進 `TOP_ORDER`，`TOP_DROP_ORDER` 排在 camp 之後、team 之前。
    - 整格讓位規則照舊。

---

## B 玩家的停點（★1）

### B1 重傷警告＝停點
- 「你重傷，不醫會死」：新事件 `player_critical`，加進 `ADVANCE_STOP_KINDS`（`world_events.gd:118-126`）。
- 機制與「開始挨餓」相同，**不另做停點**。
- 只在玩家本人**轉入**重傷的那一拍發一次（邊緣，不是每拍）。
- 寫入點＝記名成員身體部位轉成 critical 的那個唯一寫者，實作端找到後在交件信寫 file:line。
- tap：`stop.player_critical`。

### B2 玩家死亡＝停點，主詞是「你」
- 現況：
  - 偵測點是 `on_leader_death`（`event_system.gd:31-41`），由它轉 `handle_player_succession`。
  - QA 局裡結算後 3 小時「Team15 的領袖死了」，推進沒停。
- 改：
  - 在 `handle_player_succession` 入口發 `player_died` 事件：「你倒下了（死因）」。這是唯一入口，戰死、餓死、傷死都經過這裡。
  - `player_died` 加進 `ADVANCE_STOP_KINDS`。
  - 本拍推進必停。下一個鍵才進「選繼承人」或「故事結束」頁。
  - 舊的「Team%d 的領袖死了」在玩家隊上不再發（避免兩句說同一件事）。NPC 隊照舊。
- tap：`stop.player_died`。

### B3 繼承人看子隊（WHAT＝藍圖票 B 條）
- 現況：`event_system.gd:79-103` 候選只讀 `team.named_members`，不看 `subteam_ids`。
- 改：
  - 候選＝本隊記名成員 ∪ **現有子隊**（`subteam_ids`，一跳）的記名成員。
  - 選了子隊裡的人：
    - 附身移到那支子隊，走既有的附身唯一寫者 `WorldState.sync_possession`，不另寫一條；
    - 原隊照 NPC 繼承規則續走。
  - 兩邊都空才 `game_over`，句子改成「故事結束：你沒有可以接手的人（本隊與子隊都沒有記名成員）」。
  - 若量測員票三③量出「判定對、只是顯示錯」，交件前我會改這一條，以量測為準。
- 感知：子隊是自己派的，屬於自家事實，不是 god-view。

---

## C 不可逆動作要確認（★5）

- 一個確認層：
  - `ACTION_SHAPE`（`player_command_system.gd:456-533`）的列加欄位 `irreversible: true`。
  - TextUI 一支 `_confirm_irreversible(action_id, payload)`：
    - 先印「確定要<動詞>？這不能撤回 [Y]確定 [其他鍵]取消」；
    - 按 Y 才送出。
- 標成不可逆的動作：
  - 背叛勢力（`text_ui_main.gd:2949`）
  - 解散勢力（`:2954`）
  - 離開勢力（`:2944`）
  - 屠村 `residents_massacre`
  - 殺傷兵 `aftermath_kill`
  - 放棄據點（`:3124-3127`，現有第二次按鍵）
- ★既有的「第二次按鍵」確認（放棄據點）**遷進這一層後刪掉**，不留第二份寫法。
- 不併進來的：
  - 「公庫徵用超過 50%」：有門檻、不是不可逆；
  - 休息確認：可撤。
  - 兩者照舊，交件信列出理由。
- 處決俘虜 `interaction_system.gd:1537` 沒有玩家動詞，不在本票。日後加動詞時，它的列必帶 `irreversible`。
- 鍵位：
  - 不可逆動作的鍵不准是游標移動字母（主畫面 WASD、戰鬥 QWEASD）、推進鍵（Space／X／G／L），也不准是 Y（確認鍵本身）。
  - 勢力面板的 D（背叛）、E（解散）改鍵，鍵由實作端選。
  - 面板文字（`:3080`、`:3083`）與 `MODE_KEYMAP`（`:1233`）跟著改。
- tap：`ui.confirm.shown.<action>`、`ui.confirm.cancel.<action>`。

---

## D 列的條件＝做的條件（★4 ★6 ★7 ★8 ★9 21）

### D1 收割與收編（★4）
- 現況：
  - `_mark_loot_done`（`player_command_system.gd:1350-1355`）在沒有其他待處置時把 `last_encounter_result` 整個清掉，連 `can_subjugate` 一起清。
  - 屠村／殺傷兵消滅敗者後，`subjugate_block_now`（`:637-643`）回 ""，於是照列可做。
- 改：
  - 收割只標 `loot_done`、清 `loot_pool`，**不清**敗者狀態（WHAT：收割不消滅敗者）。
  - `last_encounter_result` 只在收編完成、玩家明說「留下」（`leave_loot`），或下一場戰鬥覆蓋時才清。
  - `subjugate_block_now`：敗者不存在或人數 0，要回原因「敗者已不在」，不准回 ""。
  - ★列出的條件與執行時的條件是同一支 precheck（`_precheck_for`，`:925-944`）。床裡用「列為可做的每一項都去按，結果不准是『不行』」這一格鎖住。

### D2 攻擊對象排除自家子隊（★6）
- `faction_ai_system.gd:5181-5193` `directive_target_candidates` 加一條排除：`parent_team_id == pt.team_id`。
  - 用 kinship 謂詞那一族（`world_state.gd` `registered_or_parent_at` 旁）的現成謂詞，不手寫。
- 根因另記 known_issues：子隊只在派出那一刻抄母隊勢力（`subteam_system.gd:158`），之後母隊建立或換勢力不會傳下去。那是世界行為，不在本票。

### D3 同格說過話的隊進情報（★7）
- 現況：`_exchange_intel`（`message_system.gd:226-349`）把給方知道的別隊寫給玩家，**不寫給方本身**（`:293` 跳過自己）。
- 改：同格互動（打聽、求投靠、到場交換）時，對給方寫一筆親見 claim。
  - 走現成的 `VisionSystem.write_sighting`（`vision_system.gd:140-144`），不另寫一條寫 claim 的路。
- 感知：同格親見，合規。

### D4 同格親見的時間戳要更新（★8）
- 現況：`belief_system.gd:410/421/430` 只在 `source == 親見 且 source == observer` 時刷新 `last_tick`。
- 實作端先在床裡重現「同格、每小時視野一次、時間戳不動」，找出是哪一個條件沒成立，再修那一個條件。
- 判準：同格停留期間，J 頁那筆「親見」的分鐘數不超過 60。

### D5 「你看到」去重、不每小時重報（★9）
- 現況：
  - `belief_system.gd:305-309` 的 `_known_pos` 取**第一筆**有位置的 claim，不是最新的那一筆，也不是親見那一筆。
  - ⇒ 前面若有一筆舊的轉述，每次親見都會判成「位置變了」，然後發 `intel_arrived`。
  - 折句時（`world_events.gd:527-542`）同一個目標會重複附加。
- 改：
  - `_known_pos` 改讀情報頁顯示位置用的那一支「最佳 claim」（同一個來源）。
  - 折句時按目標去重。
- 判準：站著不動的同一隊，連續 24 小時同格或在視野內，「你看到它」最多 1 則。

### D6 拔掉「%s 收到了情報」（21）
- `world_events.gd:549` 的 fallback 刪除。
- `intel_arrived` 只在觀察者是玩家隊時進玩家事件；附庸／盟友的情報不洗版玩家事件區。
- grep `收到了情報` 在 `scripts/` 等於 0。

---

## E 畫面殘留（★10 ★13 顯示面 ★14 ★15 ★16 ★18 ★20 22）

### E1 結果行只印這一拍的回應（★10）
- 現況：戰鬥中結果區是 `encounter_view.key_reply()`（`text_ui_main.gd:1067`）。沒有本拍行動句時，它退回 `_feedback_line`，也就是開戰前那一句。
- 改：
  - 戰鬥中結果區只印本拍玩家行動的那一句。本拍沒有就印「（這一拍你沒有行動）」，不退回舊句。
  - `{uN}` 代換失敗時，走 E2 的隊名／人名函式，不准印「?」（`encounter_view.gd:209-222`）。
  - 地圖攻擊回句（`player_command_system.gd:1250-1259`）改成「向 <隊名> 發起攻擊」。

### E2 顯示名（★14 22）
- 唯一表＝`data/text/names.tsv`（檔頭自稱唯一，維持這個主張）。
- 加列：
  - 據點類型（civilian／military）
  - 猛獸種類（boar、bear…）
  - 品級（grade）
  - 任務名
- `text_bank.gd` 加讀取函式。
- 收掉重複表，改讀 tsv：
  - `OUTPOST_NAMES`（`outpost_system.gd:3-6`）
  - `BEAST_LABEL`（`player_api_mapper.gd:979`）
  - 情報頁 inline dict（`text_ui_main.gd:2003`）
  - `TASK_DISPLAY`（`text_ui_main.gd:1828-1838`）
- 隊名一支：`TextBank.team_name(state, tid)`。猛獸 id（負數）回猛獸名，其他回「Team%d」。
  - 換掉的位置：`world_events.gd:636-644`、`encounter_view.gd:925`、`text_ui_main.gd:1118`／`2809`／`2812`、`player_api_mapper.gd:146`／`257`／`683`。
- 洩漏點逐一改：
  - 物品面板 `text_ui_main.gd:2338`、`team_ui_helper.gd:86`／`148`
  - 存取買賣回句 `player_command_api.gd:263-265`
  - 據點類型 `text_ui_main.gd:3199-3201`、`player_api_mapper.gd:710`
  - 獵 `player_command_system.gd:1019`／`1022`
  - 設施選單 `text_ui_main.gd:3179`
  - 子隊任務 `text_ui_main.gd:3527-3533`
  - 角色欄 `team_ui_helper.gd:170`
- `res_name()` 查不到時照舊回原字串，但要 `Probe.bump("ui.display_name.miss.<key>")`，讓漏網的看得見。

### E3 成員面板與 Tick（★15）
- 「總人數」改讀 `population`（`team_data.gd:120-122`）。另印「記名 N」一格，兩個數不再同名不同義。
- 成員面板標題拿掉「Tick:%d」（`team_ui_helper.gd:109`、`text_ui_main.gd:2312`）。
- 鍵列「[G]跳Tick」改成玩家語言（例：「[G]跳到…」，由實作端照 G 的實際行為寫）。

### E4 鍵列補 R／H（★16）
- `MODE_KEYMAP["main"]`（`text_ui_main.gd:1229`）加「[R]武裝比例」「[H]回自己」。`MODE_KEYMAP["member"]`（`:1231`）加「[Y]調薪」。
- 判準格：
  - 主畫面 `_input` 實際處理的字母鍵集合 ⊆ 鍵列字母集合；
  - 由床列舉主畫面處理的鍵，與 `MODE_KEYMAP` 比對。

### E5 打聽題數（★18）
- `text_ui_main.gd:3885` 與 `:1240` 的「1~5」改成實際選項數 N（`inquiry_system` 當下回的那一份）。

### E6 離開工地要有一句（★20）
- 玩家隊離開自己正在施工的工地格那一拍，發玩家事件：「工地留著：沒人施工就暫停，<N> 天沒動工會取消（退一半材料）」。
  - N 讀 `outpost_system.gd:75-86` 那一支逾時函式的值，不手抄常數。
- `check_construction_timeout`（`:980-1023`）取消玩家工地時，也發玩家事件（今天只有 print）。
- tap：`ui.worksite.left`、`ui.worksite.timeout_cancel`。

### E7 糧撐變動要有一句原因（★13 顯示面）
- 每小時比一次 `food_days`（`player_api_mapper.gd:235-237`）。變動超過 X 天（TEST VALUE 2.0）時發玩家事件：
  「糧撐 7.7→4.0 天：存糧 −N、人口 +M」
- 拆成**分子（存糧）與分母（人口×日耗）各自的變化**；兩項都由 snapshot 算，不另建帳。
- 根因歸量測員票三①；量完若有更細的來源（狩獵入帳、被搶），再接進這一句。
- tap：`ui.food_days.jump`。

---

## 驗收

- 新床 `scripts/debug/tail_fixes_2_bed.gd`，註冊閘列 `tail-fixes-2`，expect `=== tail_fixes_2 DONE === errors: 0`。
- 各格：

| 格 | 內容 |
|---|---|
| A1 | 戰鬥結束那一幀，事件區就有結算句（不推進） |
| A2 | 結算頁上按 Space ⇒ 回「面板開著」、頁還在、world tick 不動、待處置選項還在；按 Esc 關頁後推進 ⇒「你沒有處置」 |
| A3 | 雙方五欄都有數字；人數恆等式每一方成立；記名重傷算進「傷」；人為製造一個離隊 ⇒「其他離隊 1」 |
| A3b | 收割回句含資源名與數量 |
| A4 | 事件與結果每一則，畫面列串起來＝原句全文（拿一則超長句測） |
| A5 | 有傷兵時頂列與生存頁都有數；0 時頂列沒有這格 |
| B1 | 玩家轉入重傷那拍推進停、句子「你重傷」；同一個重傷不重發 |
| B2 | 玩家死亡那拍推進停、主詞「你」；玩家隊不發「領袖死了」 |
| B3 | 本隊無記名、子隊有 ⇒ 進選繼承人，選後附身在子隊；兩邊都無 ⇒ 故事結束句 |
| C | 六個不可逆動作：按鍵 ⇒ 確認句、按非 Y ⇒ 世界不變；按 Y ⇒ 生效。不可逆鍵 ∩ 移動／推進／Y ＝ 空。放棄據點舊的第二次按鍵路徑 grep ＝ 0 |
| D1 | 勝仗後先收割再收編 ⇒ 成功；屠村後收編 ⇒ 不列可做；「列為可做的每一項都去按，不准回『不行』」 |
| D2 | 攻擊對象沒有自家子隊（含玩家獨立時派出、後來建勢力的那種） |
| D3 | 同格求投靠的隊在 J 頁出現、在攻擊對象裡 |
| D4 | 同格 6 小時，親見分鐘數 ≤ 60 |
| D5 | 同格不動 24 小時，「你看到它」≤ 1；一句內同隊不重複 |
| D6 | 附庸收到情報 ⇒ 玩家事件區沒有那句；grep ＝ 0 |
| E1 | 戰鬥中沒行動的一拍，結果區不是開戰前的句子；沒有「?」 |
| E2 | 腳本探索床＋E2E 全部畫面幀 grep：`civilian\|military\|boar\|bear\|weapon_\|Team-[0-9]` ＝ 0；`ui.display_name.miss` 計數印出 |
| E3 | 成員面板總人數＝頂列人口；畫面無「Tick」 |
| E4 | 主畫面處理的字母鍵 ⊆ 鍵列 |
| E5 | 打聽提示的 N＝列出的題數 |
| E6 | 離開工地那拍有句、N 與逾時函式相等；逾時取消有句 |
| E7 | 人為讓存糧掉一半 ⇒ 一句、兩項拆分加總等於變化 |

- **負對照**（各拿掉一刀，該格要紅）：
  - n1：A1 只留 `_process` 那個呼叫者 ⇒ A1 紅
  - n2：A2 推進鍵照舊關頁 ⇒ A2 紅
  - n3：A3 拿掉其他離隊欄 ⇒ 恆等式格紅
  - n4：A4 換回 `clip_to` ⇒ A4 紅
  - n5：C 拿掉 `irreversible` 檢查 ⇒ C 紅
  - n6：D1 `_mark_loot_done` 恢復清空 ⇒ D1 紅
  - n7：D5 `_known_pos` 改回第一筆 ⇒ D5 紅
  - n8：E2 拿掉猛獸分支 ⇒ E2 紅
- **舊床遷移**（預期會動的，交件信逐一列修前／修後）：
  - `terminal_e2e_bed.gd:216`（「[8]收編敗者（不可）」那個 fixture）
  - `ui_flow_test.gd` 快照
  - `possessed_famine_stop_bed`
  - `scripted_exploration_bed`（畫面行數變了；探索記錄檔照舊用 `git checkout` 還原）
- world-fp：B3／D1 對 NPC 世界不應有影響（玩家才走這兩條）。fp 若變，要歸因到第一個分歧 tick，不准直接換值。
- 全量電池：跑前先問 QA、量測員有沒有 Godot 在跑。
- 驗收後 QA 真玩複驗：同一 seed 第一局那場仗＋第二局第二場勝仗，看結算頁與死亡停點。

## 誠實限
- A3 的「其他離隊」是在原因查清前的守門欄：它保證數字不消失，不保證說得出原因。原因等量測員票三④。
- E7 只拆分子分母，不知道存糧為什麼變。來源等票三①。
- B3 以藍圖票的 WHAT 為準；若票三③量出判定其實對，以量測為準改。
- E2 的 grep 只看得到床走過的畫面；漏網的靠 `ui.display_name.miss` 計數。
