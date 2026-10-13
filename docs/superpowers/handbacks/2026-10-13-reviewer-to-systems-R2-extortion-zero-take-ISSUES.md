---
from: reviewer
to: systems
status: open
slice: R² 勒索零／近零所得（3314ff226）
topic: R② ＝ **小 ISSUES（五處,同版補,不需再審）**｜①『accepted 之後把它當成功的讀者』母體是【空的】（全 scripts 只有 _action_extort:938 讀它,且只在【拒絕】時用）⇒ X3 沒東西可紅;判準留在訊息層,別在 sim 造『得手』欄;②改法 3『接受路徑要寫 _record_extorted』已成立（interaction_system.gd:508,接受/拒絕共呼）,且嚴重度恆 0.25（taken/before≡TRIBUTE_RATE）⇒ X4『量與實際轉移一致』是恆真;③X6 的『接受機率』錯字面——tribute_eval 是確定性 score>threshold,且怨在第 2 筆就會成形;④『一分鐘內勒索兩次』造不出近 0（每次只拿剩餘的 25%）⇒ X1 的佈置必須直接設庫存;⑤顯示精度的單位:玩家對帳用的是整數資源面板,0.1 的 snapped 不是『玩家看得到』的精度;另有一格鄰近缺口:玩家是被勒索方時結果句被丟掉
---

# 0 審了哪棵樹
main 3314ff226。核對 interaction_system.gd:440-462,491-546,1506-1534;player_command_system.gd:934-945,1934-1940;player_api_mapper.gd:1319;
diplomatic_ai_system.gd:49-120;npc_ai_system.gd:108-140;全 scripts 對 `accepted`／`resolve_extortion_direct`／`_resolve_extortion` 的呼叫端。

# 1 你問的第 1、2 點:判準與讀者
```
格式器核實:interaction_system.gd:1527-1533,amt>0 才進 parts;amt<1.0 用 "%.1f" ⇒ 0<amt<0.05 印『食+0.0』;0.95~0.99 印『1.0』而 ≥1 印『1』（兩種寫法）;parts 空 ⇒『少量資源』。✓ 與你的推斷一致,不是另一支格式器。
讀者普查（全 scripts 排除 debug,grep `accepted`／resolve_extortion_direct）:
   ·player_command_system.gd:938  `if not extort_result.get("accepted", true)` —— 只在【拒絕】時加 unrest（UnrestBank +1）;接受時不讀它做任何『成功』計數
   ·player_command_system.gd:~944  把 accepted 原樣放進指令結果（handler 契約,給 UI 的 payload;player_command_api.gd:78-79 轉進 payload）
   ·player_command_system.gd:1937  _pay_extortion:呼叫 resolve_extortion_direct 但【丟掉回傳值】（見 §6）
   ·player_api_mapper.gd:1319 的 `accepted` 是 PlayerTradeSystem.evaluate_offer 的另一件事（交易預覽）,與勒索無關
   ⇒ 沒有任何『成功勒索計數／聲望／記憶 寫得手』的讀者。X3『近 0 那次不計入得手讀者（列出的每一個）』的母體是空集:它不可能修前紅,也不可能修後紅。
   ⇒ X3 刪掉,或改成『grep 證實無讀者』的一格說明；【不要】為了讓它有東西可測而在 sim 新增一個『得手』欄——那會把顯示精度的門檻（0.05／0.1）變成世界狀態,
      是呈現層回灌 sim 的方向（跟 02_reviewer『守衛掛在一定會發生的事上』同族）。判準只活在訊息組句那一處。
判準站得住嗎:『所有項在顯示精度下為 0 ⇒ 不宣稱得手』作為【訊息】規則站得住;作為 sim 語意不該存在（世界有轉移、怨有記）。你寫的『物理照轉、只是不宣稱』方向對,保持純顯示。
```

# 2 你問的第 3 點:接受路徑有沒有寫 _record_extorted
```
有。_resolve_extortion（interaction_system.gd:491-513）在 :508 `_record_extorted(state, def, atk, taken_ratio)`,接受支與同格互動（:448,:459）、玩家直接勒索（resolve_extortion_direct :1523）都經它;
   拒絕支另在 :1519 與 :453/:464 以 _record_extorted(…, 0.0)／_record_extorted_on_contact 寫。⇒ 改法 3 的前提『先查現況接受路徑有沒有寫』= 已寫,該條【刪掉】（留著會讓實作端去『補』一條已存在的寫入而重複計怨）。
X4『接受路徑對方的怨有記,量與實際轉移一致』:
   taken_ratio = gained.coin / coin_before = (coin×TRIBUTE_RATE)/coin ≡ 0.25（coin_before>0）;coin_before=0 ⇒ 0 ⇒ _record_extorted 用 TRIBUTE_RATE(0.25)（:528）。
   ⇒ 嚴重度恆為 0.25,與轉移量大小無關（拿 0.1 與拿 100 同一筆）。『量與實際轉移一致』是恆真斷言。
   X4 改成真能紅的:(a) 接受一次 ⇒ victim.leader.memory 多恰好一筆 "tributed"（subject＝勒索方領袖）;(b) 一季內第二筆使 sum≥FEUD_MIN 時 feud 邊形成（npc_ai_system.gd:117-135）——這是怨『累積』的真載體;(c) 反向:拿掉 :508 ⇒ (a) 紅。
   另:嚴重度與量無關是設計（兩層關係帳,npc_ai_system.gd:140 註解）,不是本票要改的;但 X4 不能再宣稱它跟量對帳。
```

# 3 X6 煞車:字面與佈置
```
tribute_accept／tribute_eval（diplomatic_ai_system.gd:49-120）是【確定性】:`accept = score > TRIBUTE_ACCEPT_THRESHOLD`,沒有 RNG ⇒ 沒有『接受機率』。
   X6 改成:連續 N 次勒索後 `tribute_eval(...).score` 單調下降（或 N 內翻成 accept=false）,並印 {score, affinity, feud, threshold} 分解（該函式已交出這些欄）;你寫的『讀真實 util 或其輸入分數』方向對,字面改掉『機率』。
怨的載體:好感列（affinity,relations 由 `_update_relations` 'tributed' 那一列）與 feud 邊（sum≥FEUD_MIN,上面 §2）。『一分鐘』間隔是否足以讓 affinity 更新取決於 _update_relations 的更新時機——我沒讀它的 cadence;
   若它是日界/季界才更新,『相隔一分鐘』的連續勒索在第 N 次前 score 不會動,你的『不低 ⇒ 停手』分支會被誤觸發。請在床裡先量 affinity／feud 在每次勒索後的變化,再下結論;要嘛間隔改到足以讓它更新,要嘛直接斷言 memory 與 feud 邊（§2 (a)(b)）。
```

# 4 X1 的佈置:『同一目標一分鐘內勒索兩次』造不出近 0
```
_resolve_extortion:tribute = 庫存 × TRIBUTE_RATE(0.25)（:497）每項各取 25%（剩餘的）⇒ 幾何衰減。
   近 0 正值（<0.05）需要【庫存 < 0.2】（0.25×庫存<0.05）。一個正常目標被勒索兩次只是庫存×0.56;要到 <0.2 得靠目標本來就近乎赤貧或被勒索十幾次。
   ⇒ 用戶看到的『食+0.0,幣+0.0』最可能是赤貧目標（庫存<0.2）,不是『剛被勒索兩次』。
   ⇒ X1/X2 的佈置：直接把目標 food/coin（和 material/goods）設成指定小值（0.1／0 / 0.3 / 整數 5）,不要靠『連按兩次』;先量那個目標的庫存印出來（你改法 1 已寫『先量』,補:量的是庫存不是 gained）。
   另需覆蓋 gained 的四種形態:全空（庫存全 0）、全近零、混合（一項可顯示一項近零——近零那項不印、可顯示項照印）、全可顯示;現在 spec 只有前後兩端。
```

# 5 顯示精度的單位
```
玩家對帳的資源面板顯示整數（卷面『糧 151』）。0.1 的 snapped 讓『食+0.4』可以顯示,但玩家對帳不到（面板整數看不出差 0.4）;同時 0.95~0.99 現在印『1.0』。
建議:門檻與格式都用【資源面板用的同一個取整函式】（單一來源）;每項取整後為 0 的略過,全為 0 ⇒『對方已經沒有東西可給』;不再出現小數寫法（也就沒有 %.1f 與 %d 兩種）。
   這樣『玩家看不到的轉移不宣稱』的語意與面板一致;若藍圖要看到零星量（例如 0.4）,那是 WHAT,請藍圖定。
```

# 6 鄰近缺口:玩家是被勒索方時,結果句被丟掉
```
player_command_system.gd:1937 `_interaction.resolve_extortion_direct(state, from_id, pt_id)`（玩家付款）——回傳值（含『勒索完成（食+3,幣+1）』）被丟掉,指令回『支付勒索』固定句（:1938）。
   玩家被勒索時看不到自己被拿走多少。這與本票同病（結果句與世界不符的反面:世界變了而句子不說）,且改法 2 的新句子組好之後白白沒人用。
   建議本票順手:_pay_extortion 回傳句帶實際被拿走的量（用同一支組句）；若不想擴範圍,至少列 known_issues。事件行（改法 4）對『玩家為被勒索方』要成立（『Team6 勒索了你：拿走 食 3』）。
```

# 7 判決
```
verdict: issues（小）;①~⑥ 同版補,不需再審
①X3 刪／改 ②刪改法 3、改 X4 ③X6 改字面並先量 affinity 更新時機 ④X1 佈置直接設庫存、補四形態 ⑤單一取整函式 ⑥_pay_extortion 回傳句
```
