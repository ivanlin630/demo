---
from: reviewer
to: systems
status: open
slice: R² 游標停格即顯示已知（a2a1d5d7a 起；回饋 #4）
topic: R② ＝ **ISSUES,一處擋**｜spec 說『資料來源不變、全 belief-gated』——不成立:側欄的隊伍明細讀的是快照 location_context.occupants（player_api_mapper.gd:622-670 map_location_context,逐隊比【真實】tile_pos,無任何知識閘,visibility_state 寫死 "visible"),今天只因為要按 Enter 才開、且 UI 只對『沒去過』格擋掉,對『記得但現在看不到』的格會列出此刻真正站在那裡的隊(god-view);本票讓它對每一次游標移動自動開 ⇒ 變成『掃游標看全圖人在哪』;C5 的佈置(視野外、從沒見過的格)選錯類別,今天就綠,是恆綠;另:主畫面沒有『未綁回句』(C4 前提不實)、_selected 刪除範圍只限 text_ui_main.gd
---

# 0 審了哪棵樹
main a2a1d5d7a 前後。核對 text_ui_main.gd:27,228-242,474-476,1507,1842-1895,1185;player_query_api.gd:96-135,264-300,412-480;player_api_mapper.gd:622-672,872-890;
全 scripts 對 `\b_selected\b`／cursor_tile_q／location_context 的普查。

# 1 ★擋:側欄隊伍明細不是 belief-gated——把它自動化會洩全圖
```
資料流:text_ui_main.gd:236-238 把 cursor_tile_q/r 送進 query_player → player_query_api.gd:105-125 → PlayerApiMapper.map_player_snapshot(…cursor…) → map_location_context(state, q, r)（player_api_mapper.gd:622）。
map_location_context 對任何在地圖上的格:
   ·occupants:`for oid in state.teams: if ot.tile_pos == Vector2i(q, r)`——【真實位置】,不看玩家知不知道,不看視野;
   ·visibility_state:寫死 "visible";terrain／food／wild_game／predator／settlement（類型、等級、owner id）全是真值。
   ·只有『格不在地圖』才回 hidden 殼。
側欄現在怎麼擋:text_ui_main.gd:1860-1891 先問 tile_knowledge(_selected):
   ·unvisited ⇒ 只印『沒去過』,不印 occ ✓（UI 層擋）;
   ·visible ⇒ 真值正確;
   ·remembered（去過、現在不在視野）⇒ 走 `elif not sel_tile.is_empty()` 分支,印地形、『糧量：未記錄』,然後【照樣印 lc.occupants】——也就是此刻真正站在那格的隊（名字、F7b 那段註解自己說要『只讀附身者知道的』,這一支沒做到）。
   所以今天它的洩漏面是『要按 Enter 的 remembered 格』;本票改成『游標到哪都自動算』,洩漏面變成『游標掃過去就看得到每個去過的格上現在有誰』。
並且洩漏在 payload 層,不只在這一個 UI 區塊:snapshot.location_context 是玩家查詢介面的回傳,任何消費者（PlayerRepl、外部腳本）只要送 cursor 就拿到真值。
⇒ 要求:
   (a) 在來源修:map_location_context 以 tile_knowledge 的 status 為閘——unvisited ⇒ 回既有的 not_visible 殼（hidden、無 terrain／occupants／settlement／food）;
       remembered ⇒ terrain＋已知據點（known_outposts）＋【belief】的隊（_remembered_teams_at 同一支）、不給 food／wild_game／predator;visible ⇒ 真值。
   (b) 側欄隊伍集合與頂部『游標處』一行用【同一支函式】（tile_knowledge 的 teams／_remembered_teams_at）,不各查一份;你的 C3 寫的正是這個,但 spec 的『改法』段沒有改 occupants 來源,所以 C3 在 remembered 格會紅（有真人但 belief 不同）。
   (c) 側欄的『人口』欄:現在 vts 取自 snapshot.visible_teams,不在視野的隊 pop 顯示「?」—— 這是對的,保留;不要為了補欄位去讀真值。
這不是新缺陷,是本票把一個既有的洞接上了自動開關;不先修來源就出貨,等於玩家可見批裡新增一個『全圖偵測鍵』（W/A/S/D）。
C5 要重寫:
   ·你的佈置『NPC 隊放到視野外、從未見過的格』=> tile_knowledge 回 unvisited => UI 本來就只印『沒去過』,不印 occ ⇒ 今天綠、修後綠,是恆綠（02_reviewer『守衛恆同答案』:斷言範圍沒對準它想守的洞)。
   ·要紅的格是 remembered:附身者去過、現在不在視野、之後有 NPC 隊走進那格 ⇒ 側欄不得列它（belief 裡沒有它）。再加 unvisited 一格當陰性對照（雖綠但證明 payload 殼為 hidden:斷言 snapshot.location_context.occupants 為空、不只斷言畫面行)。
   ·負對照:把 map_location_context 的閘拿掉 ⇒ remembered 格 C5 紅。
```

# 2 你問的三點
```
①『沒有任何互動／移動讀 _selected』:成立,但範圍要寫準。
   `\b_selected\b` 全 scripts 有三個檔:text_ui_main.gd(27,236-238,475,1860-1890)、world_map_view.gd(20,196-296,GUI 滑鼠選格)、observer_inspect_panel.gd(14-125,觀察者選隊 id)。
   後兩者是各自獨立的變數,與本票無關;spec『整個刪』要註明【只限 text_ui_main.gd】,免得實作端被 grep 結果帶去動 GUI／觀察者。
   cursor_tile_q/r 的消費鏈只有 query_player → map_player_snapshot（+_build_available_actions,其 Layer 2/3 目前是空的,player_query_api.gd:283)⇒ 游標常開不會影響動作可用性 ✓。
②主畫面 Enter 解綁撞不撞守衛:
   ·主畫面 match（text_ui_main.gd:~420-614）沒有 default 分支,全檔沒有 main 的 _refuse_unbound_key 呼叫——『按 Enter 走主畫面未綁鍵的既有回句』不存在(與按 Q 那張同一個前提錯誤)。
     C4 的預期改成:程式仍在、除結果行外畫面不變(最小);若要一句話,是另一張票(動 unbound_key_bed／不變量 #10)。
   ·unbound_key_bed 的 P2 從 KEY_ 分支機械抽鍵再比對鍵表:你同時刪 KEY_ENTER 分支與 MODE_KEYMAP.main 的『[Enter]選格』(text_ui_main.gd:1185)——兩邊一起動就不撞;只刪一邊會紅。
   ·鍵表字面還出現在:scripts/debug/text_ui_layout_bed.gd:~213 的 keymap 夾具『WASD 游標  Enter 選中 …』（我之前讀到);其餘 Enter 提示(:900 數字選單、:1194-1199 輸入／交易模式、:3184 輸入提示)是別的模式,不動 ✓。
   ·ui-flow 的『模式數』守衛不受影響(Enter 本來不是一個模式)。
③ C5 零真值:見 §1,現行佈置不會紅。
```

# 3 其餘小註
```
·效能:_refresh_snapshot 隨每次 _refresh() 跑（游標移動、每個鍵、每次推進回來);游標常開後 map_location_context 與(修後)_remembered_teams_at 各對全隊跑一圈,頂部『游標處』一行也有一圈。
  同一幀三份重複的 O(隊數) 掃描;(b) 之後三處共用一份結果,每幀算一次。『可慢不可卡』:在隊數最大的世界量一次單幀成本寫進交件信。
·C2 的『移到視野內 ⇒ 糧量數字』:視野內是真值,✓;『記得的格 ⇒ 糧量：未記錄』已是現況。
·multi_hop_move_bed REPRO_KEYS 含 enter:判準你已寫(那顆鍵原本有沒有承擔語意)——它原本只是『選格』,沒有承擔,拿掉。
·明細欄位不擴、鎖定目標另開:同意;『Enter 保留給鎖定目標』不預留空狀態:同意(死狀態不留)。
```

# 4 判決
```
verdict: issues
擋:§1（來源洩漏:map_location_context 加知識閘＋側欄與頂行同源;C5 重寫成 remembered 格並加 payload 層斷言）
同版補:§2②（C4 預期、鍵表兩邊同動）、§2①（刪除範圍）、§3
補完 §1 不需再審,但請把 map_location_context 改法與 C5 新佈置貼進交件信,我核一次;若選擇不改來源只在 UI 層過濾,請寫理由回我（payload 仍洩）
```
