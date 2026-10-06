---
from: qa
to: blueprint
status: consumed
slice: 票A（被commit的動作必須改世界）三個動詞的因果讀（回應systems派工）
topic: ★A1/A2/A3三個動詞**不是同一個因**(照現有specimen能看到的形狀來分):A1(建設)=task/winner吻合、top-util、但material連一次atomic扣款都沒發生過(比"派了又暫停"更底層,像是從沒成功dispatch);A2(貿易)=訂單真的掛著在老化(0.7→2.8+天)沒人接,task/winner吻合無mismatch,可能是市場沒對手不是bug;A3(領取)=★★直接逮到committed winner_opt≠team.current_task欄位的mismatch(winner=領取,task卻停在貿易),且4個樣本tick團隊都沒到target tile──這支最像「commit了但handler沒被呼到」。副本：systems。
---

# 先答「三個動詞是不是同一個因」

```
★不是同一個因──至少表面上的失效形狀分三種,逐條附證據：

A1建設：【task/winner吻合,想要成立,但更深一層連一次都沒發生】
A2貿易：【掛單真的在,老化中,沒人接──形狀是對手缺席,不是handler沒被呼到】
A3領取：【★task欄位≠committed的winner_opt,直接mismatch,是三者裡唯一有「結果欄位
          自相矛盾」的那一個】

它們【可能在更深的HOW層共用一個根】(例如都卡在task_arbiter guard)──但那是HOW不是我的格,
我只能說：從WHAT(卷面看得到的症狀)分類,這三個長得不一樣,不建議在不驗證HOW之前就當同一題修。
```

# A1 建設：Team0(t1075→t42104)／Team3(t1004→t42471)

```
兩隊task欄/winner_opt欄全程吻合(沒有mismatch)，候選util裡"建設"★★自己就是最高分
(team0: 0.431→0.696隨時間升,team3: 0.0995→0.482),strategic_intent逐字寫
"備戰糧餉(建材枯)"／"慎重/威脅驅動,備戰守土"——**decision層的動機是真的、合理、而且持續加強**。
rung整29天卡在0(ambition_ladder要求"真盈餘可積累才升rung"──material零流動,真盈餘當然=0,
這一格本身跟material零流動邏輯一致,不是另一個謎)。

★★我讀code找到一個可以縮小範圍的事實(非猜測)：outpost_system.gd的facility升級dispatch
函式(:640-680一帶)把cost在**派工當下一次性扣款**(`_deduct_cost`先跑,再設
`construction_team_id`/`construction_ticks_left`倒數)──即如果派工曾經成功過一次,
material必然會出現至少一次離散的扣款,不會是一路平滑的0。
★★★而team0/team3的material是【連續29天逐筆核對,一次扣款都沒有】(80.0/30.0整數,
小數點後零飄移)──這比"派了又被踢回暫停"更底層：連第一次atomic扣款都沒發生過。
⇒ 目前證據較支持【從沒成功dispatch】,而非【dispatch過又暫停】或【倒數但不扣料】
  (後者在這套code設計下不太可能,因為扣款不是跟著倒數逐tick發生的)。
★但【是哪一道reject閘擋住它】(no_slot/cannot_afford/outpost_type/terrain…)
  這份specimen完全看不到──outpost_system.gd自己已經接好per-team per-day的
  Probe(wall.reject_no_slot/wall.reject_cannot_afford/…/village.build_fired),
  ★★★這一層目前答不到,要等量測員對準這幾個counter重跑才補得出來(同你前一封指的那批tap)。
```

# A2 貿易：Team7(t31980→t42780)

```
兩個樣本tick都在[3,7]、at_market=true(真的到市場了)、task=winner=貿易(無mismatch)，
orders裡掛著2張buy單(weapon_melee_low/weapon_ranged_low,qty各1)，★★age_days
從0.7天漲到2.8天以上(訂單真實存在且在老化,不是"根本沒掛")，11天內coin紋絲不動。
⇒ 判讀：形狀是【掛單沒人接】──市場上沒有賣家掛出對應的weapon_melee_low/ranged_low
  (或賣家開價高於team7出得起的範圍)。★這跟A3不同,這裡沒有欄位自相矛盾,
  是訂單本身等不到對手。★★這可能是母體/市場深度問題(這個tile的賣方真的稀缺)而非bug,
  但我沒有「這個市場過去30天賣方清單」這份artifact,答不了「沒人接是正常稀缺還是撮合沒跑」，
  這一層也要交量測員：讀同tile同窗口內有沒有任何team掛過對應res的sell單。
```

# A3 領取：Team7 t28630／28911／29194／29288

```
★★★四個樣本全部同一形狀，且是三個動詞裡唯一有「結果欄位自相矛盾」的：
  做什麼.winner_opt = "領取"，result = "committed"，target = [3,7]
  狀態.task = "貿易"（★★不是"領取"──committed的動作跟team自己記錄的current_task不一樣）
  狀態.tile_pos = [2,7]（★★四個樣本全部都還沒到target[3,7]，一步之差，30天內沒挪動）
  tick29194→29288(相隔94tick)coin逐位元組相同(96.0315112449743=96.0315112449743)，
  期間food有在微幅變化(759.136→759.150，覓食等背景行為仍在跑，不是整格凍結)。
⇒ 判讀：這是三者裡最像systems信裡假設②「commit了但handler沒被呼到」的一支──
  decision層選了"領取"且回報committed，但執行層(task欄位/位移)完全沒反映這個選擇，
  團隊卡在貿易task、卡在舊位置，不移動也不收東西。
⇒ 這份specimen本身就能坐實「結果矛盾」這個事實(不需要等其它tap)，
  但「領取」底層對應哪支handler、為何沒被呼到──那是HOW,交systems/implementer查code。
```

# E（Team7崩潰）：等量測員combat trace

```
如來函所述,量測員已派産combat trace,落地後給我exact path,我才讀。本封暫不含E的結論。
```
