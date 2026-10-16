---
from: reviewer
to: systems
status: consumed
slice: 結構輪探針 §三之三 新點缺料進同一本需求帳（main 718014047）
topic: R② 第四輪（只審該節）＝ **ISSUES（中，五處必補）**｜前提大致成立但「在路上」的判別會誤抓兩群隊；採段中迫切讀不到進度；讀者清單漏五個；N5 的賣盤半格恆綠
---

# 核對
```
✓ 先答第 1 點「四條入口選定即出發」：成立，附兩條修正。
  · 擴點 options.gd:373-380 ＝ delegate，注釋 :365-366 寫明唯一世界寫入在 _dispatch_builder 最後一行；harvest 委派 goal_resolver.gd:1168-1175 同走 _mk_delegate_candidate；
    infra (3) faction_ai_system.gd:6441 直呼 _dispatch_builder。三條的「在路上」承諾者是【子隊】（派出的 SubteamSystem.dispatch，faction_ai_system.gd:5847-5849），不是母隊。
  · 紮根 _commit_settle_site（faction_ai_system.gd:7277-7316）分三支：resume（:7289-7295）、走回自己營地（:7300-7307，設 move_target，多 tick）、就地開工（:7316）。
    母隊真正「在路上」的只有走回營地那一支（要求 tile.camp_team_id==本隊、camp_level==1、outpost_level==0、construction_team_id==-1）。
  · goal_state：goal_registry.gd:16-21 MAINTAIN_GOAL_RES 只有 food/material/tools/weapons，沒有建點類。✓（但它有 maintain_material——見 M11）
✓ 第 2 點 ①整筆/②gather_left 互斥：不重複扣。②的 gather_left 是開工時已抵掉帶來的料之後的剩餘；讀者再減 effective_holding 時，隊上 material 已搬進 site_stock，不會減兩次。✓
✓ 第 4 點：§二 V3 不用改寫；但 N4 要走真的守恆稽核，不要自己加總（見 M12 下）。
✓ 第 5 點：見末段「上限」。
✓ 第 6 點：誠實限的說法對。
```

# 必補五處

## M9 ① 的判別條件會誤抓兩群隊，而且「目標格」是哪個欄位沒寫
```
spec :184 ①＝TASK_BUILD、目標格 outpost_level==0、task_extra_data 沒有 facility_type、目標格沒有這支隊的工地。
  但 task_extra_data 只有【子隊】才有（team_data.gd:559 注釋「子隊任務附加數據」）；母隊沒有 build_type/level，spec 說「紮根沒帶的就用 §一 那一組」，母隊的「目標格」沒欄位可讀。
  TeamData 沒有 target 欄；只有 move_target（team_data.gd:249）。TaskArbiter.try_set 在目標＝腳下時也會把 move_target 設成腳下（task_arbiter.gd:98-99、:260、:277）。

誤抓群 A：選項「建設」（options.gd:70-77）與「自救建田」（:89-99）。
  to_task 都是 {task: TASK_BUILD, target: team.tile_pos}，沒有 settle_site、沒有任何工地寫入；:75 注釋寫「bootstrap(無據點建新)+升級」皆候選。
  這群隊的腳下格若 outpost_level==0 ⇒ 完全符合 ①（TASK_BUILD、空地、沒有本隊工地、task_extra_data 空）⇒ 被算成「承諾要蓋新點」，need_keep(material) 加 80，守料、發買單。
  量測員自己的床 a1_build_never_started.gd:7 就把這群分成 (iii)「選了建設、腳下沒工地」——這一群今天就存在，不是假想。

誤抓群 B：復工的工人。
  faction_ai_system.gd:5777-5779 把【另一支】隊 TaskArbiter.transition 成 TASK_BUILD、move_target 設成別人的工地；outpost_system.gd:376-381 的接手機制也是「同格任何 TASK_BUILD 的隊」都算施工隊。
  這支工人的目標格 outpost_level==0（L0→L1 的工地）、「沒有這支隊的工地」（construction_team_id 是別人）、task_extra_data 空 ⇒ 也符合 ①，被算成整筆 L1 成本。

改法（判別條件收緊成「這格現在完全沒有工地，而這支隊正走向它」）：
  ① ＝ TASK_BUILD ∧ move_target ≠ (-1,-1) ∧ move_target ≠ tile_pos（真的在路上，與 _tick_player_subteam 的 move_target 守門同語意）
       ∧ 目標格 outpost_level==0 ∧ construction_team_id == -1（任何隊都沒有工地——這一條排掉 B）
       ∧ （子隊）task_extra_data 有 build_type ／（母隊）目標格是本隊自己的營地（camp_team_id==本隊，與 _commit_settle_site :7300 同判準）。
  type／level：子隊讀 task_extra_data；母隊走營地那一支讀 §一 紮根開工用的那一組。請在 spec 寫明各讀哪一欄。
驗收補
  N2b：三種「不是 ①」的 TASK_BUILD ⇒ 新點那一支＝0：①建設選項在 outpost_level==0 的腳下 ②復工工人（目標格有別人的工地）③升級設施（目標格 outpost_level>0）。
  n23：①不看 move_target／construction_team_id ⇒ N2b 紅。（n19 只蓋「不看承諾」，抓不到這群。）
```

## M10 ② 的新點迫切讀不到進度，採段中恆接近 1
```
spec :199：迫切＝採段天數÷總天數，用 build_eta_total_days 的兩半，carried 讀隊自己的 material。
  §三 簽名（spec :123）＝ build_eta_total_days(type, level, pop, carried_material, site)——沒有 site_stock 也沒有 gather_left。
  ② 的狀態：開工時 carried 已經搬進 site_stock（§二），隊上 material≈0。估算器只看到「成本全額、帶 0」⇒ 採段天數＝全額的採料天數，
  不管 gather_left 是 70 還是 5 ⇒ 迫切恆為高值，快採完了還在拚命買料。這正是 persist_strength 的反面（它只隨進度增加，這個恆高）。
  N6 只驗 ①（剛承諾）與平原，看不出來。
改法：② 的迫切改用 gather_left 當作要採的量（等價於 carried＝cost − gather_left − 已入 site_stock 的部分；最簡單是估算器多收一個「待採量」參數，①傳 cost−carried、②傳 gather_left），
  兩邊同一支函式、不另寫一份。
驗收補
  N6b：同一個森林工地，gather_left＝70 與 5 ⇒ 後者迫切嚴格較小、且 ≥0。
  n24：② 傳 cost 不傳 gather_left ⇒ N6b 紅。
```

## M11 讀者清單漏了五個：need_keep(material) 不只進買單與買料效用
```
spec 現況段列的讀者是買單（order_system.gd:327-338）、reserve、buymaterial_drive。我把全庫（非 debug）need_keep( 的呼叫點逐個掃了（grep 共 24 處）：
  會被這次改動影響（material 的 need_keep 變大）：
   · goal_resolver.gd:44      maintain_material goal 的 active/satisfied 判定（holding < need_keep ⇒ active）
   · goal_resolver.gd:1007    資源前置解（_rp_sat）⇒ 買／採／製造候選；harvest 的遠端 founding 委派（:1168-1175）也在這條鏈上
   · labor_system.gd:174      gather:material 的勞力權重 ＝ Σ 全勢力各隊 need_keep（【不扣持有】）
   · decision_context.gd:1032 material_shortfall／material_need_total（買料效用的分子分母，spec 已提）
   · trade_valuation.gd:138／141 reserve（spec 已提）
  不受影響（有證據）：goal_resolver.gd:155／204、faction_ai_system.gd:6852／6865、decision_context.gd:593／1571、manufacturing_system.gd:265、
   labor_system.gd:181／191 讀的是設施【產出】資源或 food；FACILITY_DEFICIT_DEF 的 outputs（faction_ai_system.gd:6813-6817）沒有 material，
   且 material 是純中間品（need_oracle.gd:227 PURE_INTERMEDIATE，自用 0）。⇒ 沒有「新點需求 → 設施缺口 → 設施需求」的回饋環。
意義
  · goal_resolver:44 讓在路上的隊多一個 active 的 maintain_material goal，:1007 會為它產生買／採候選，進同一個 argmax。這與設施那一支今天的行為同形，
    我不反對（藍圖裁「同一本帳」就是這個意思），但 spec 要承認它，並確認不和已承諾的 TASK_BUILD 打架（persist 守住與否）。
  · labor_system:174 不扣持有 ⇒ 每支在路上、【已被撥滿料】的子隊也讓全勢力的 gather:material 權重加整筆成本，一整趟路。設施那一支同語意，但設施是長期慾望，這個是每次派工都來一次。
補
  spec 現況段補上這五個讀者與預期效果；交件信印：有新點承諾的隊日數 × maintain_material active 的隊日數、labor gather:material 權重修前修後（同種子）。
  N8（新）：在路上的母隊（走回營地）⇒ goal_resolver 的 maintain_material 變 active，且不因此把 TASK_BUILD 換掉（persist.hold 計數或 task 不變）。
  不另加門；這是把一個已存在的讀取面寫進帳。
```

## M12 ② 的子隊讀法是全圖掃描；而且「施工隊」是誰沒寫死
```
spec :188：子隊讀「construction_team_id == team.team_id 那格」。TeamData 沒有「我的工地」指標（只有母隊的 corvee_site，team_data.gd:298）；
  這句話字面做法是掃全 tile。need_keep 是熱路徑（碼表 nk_*，need_oracle.gd:98-142 有逐呼叫計時；並且被 goal、labor、order 各自重複呼叫），O(tiles) 放進去會長出新尖峰。
改法：子隊站在工地上採料（不離格），讀 tile_pos 那格，檢查 construction_team_id == 自己即可，O(1)。母隊讀 corvee_site 那格，已經是 O(1)。

另：誰吃料、誰被讀？
  outpost_system.gd:376-381 的 _tick_construction 把「同格任何 TASK_BUILD 的隊」當作施工隊（接手機制），復工工人（faction_ai_system.gd:5779）就是這樣接手別人的工地。
  spec §二「施工隊把 material 抵進 gather_left」與 ② 的「construction_team_id」可能是不同的兩支隊。請寫明：吃料的是 _tick_construction 找到的 active_team；
  需求（②）讀的是同一支。接手的工人帶的料也進工地，且它的需求在它自己身上算。
驗收補
  N4b：復工工人（不是 construction_team_id）帶 20 料站上別隊的採段工地 ⇒ 抵進該工地、隊上 −20；N4 與 N4b 都走真的守恆稽核（InvariantAudit），不是手算加總。
  n25：吃料改成只認 construction_team_id ⇒ N4b 紅。
```

## M13 N5 的「賣盤不賣這 60」那半格今天就恆綠
```
spec :205「在路上的隊走 reserve」不成立：order_system.gd:311 的 is_constructing 已包含 TASK_BUILD，:317 對施工隊的賣盤整段 continue，根本不呼叫 reserve。
  ⇒ N5 的「賣盤不賣這 60」在修前修後都綠；n21（trade_valuation 照舊只看設施那一支）若只靠這一半就抓不到。
  reserve 改動真正有感的地方：①買單缺口 reserve − holding（order_system.gd:334）；②隊暫時離開 TASK_BUILD（例如走去市集買料，current_task 變成交易類，is_constructing 為假）時的賣盤。
改法
  N5 拆兩格：(a) 直接斷言 reserve(material) 在【有新點承諾】時等於 need_keep × 只看糧急的係數（對 coin 焦慮免疫），與【沒承諾】時不同（斷言值，不是斷言賣不賣）；
             (b) ②狀態（corvee_site 工地 gather_left>0）且 current_task 為交易類、持料 60、coin 急而糧不急 ⇒ 賣盤不發 material。
  n21 對準 (a)+(b)。
```

# 小項（不擋）
```
· 上限：兩支加總後才夾 100。實務上兩支不重疊——設施那一支要求自家據點 outpost_level>0（need_oracle.gd:165-169），
  子隊沒有自己的據點、紮根隊也還沒有；所以「誰被吃掉」目前母體為空。但規則仍請寫下來並加一格強造重疊的斷言（例：設施 80＋新點 80 ⇒ need 100，且 ① 這一筆不得被削成 0）；
  建議寫成「已承諾的新點優先、設施吃剩餘額」，免得日後有人造出重疊時，一座沒開工的設施把已經上路的新點削掉。這是你的設計決定，我只指出空白。
· coin_treasury.gd:54 存幣門檻讀 _construction_facility_need（不是 _construction_need）：在路上要買料的隊不會替買料留幣。這是否刻意，請在 spec 一句話交代（我不裁）。
· 子隊那一支的買單：訂單 dict 加 "for" 欄，請確認 order board 同步（order_system.gd:302 _sync_board）與存檔序列化不對多出的鍵敏感。
· Probe need.new_outpost.walk／.gather 進場計數請在 N1／N3 斷言非零（避免「全綠但計數為 0」）。
```

# 判決
```
verdict: issues（中）
必補：M9（判別條件）、M10（②迫切讀 gather_left）、M11（讀者清單與 N8）、M12（O(1) 讀法＋吃料者身分）、M13（N5 拆格）
M9／M10 會改變程式語意，請補完後讓我再看 §三之三 的 diff 一次（只看該節）；其餘為文字與驗收格。
```
