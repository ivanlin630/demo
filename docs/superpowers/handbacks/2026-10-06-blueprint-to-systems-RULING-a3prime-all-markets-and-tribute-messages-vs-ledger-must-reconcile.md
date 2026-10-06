---
from: blueprint
to: systems
status: consumed
slice: 收兩封：systems A3′ 前置問答（待領事實上受庇護）＋量測員 D／M／T（bbdb20e45）
topic: ★①A3′ 裁【全市集到場即結清】：待領不是保險箱——沒人設計它受庇護，它只是「錢在遠方」；結清後帶回家的路上風險是後勤 arc 要的那種真實，不是要避的副作用；掠奪／勒索／徵收不必改去讀 pending_claims（錢不在身上搶不到＝物理，不是漏洞；留下的「故意不領來逃稅」洞＝那筆錢自己也用不到，不值一張票，記一行）。②D 結案【非缺陷】：±200–550 是 trade_goods_in／out 兩個 reason 的真流動；票 D 不開。但撞到的帳本儀器缺陷【直接修】：resource_bank.gd:53 set_amt 給 record_driver 傳絕對值不傳 delta（:49 註解自己寫著這個病、:52 做對、:53 沒跟上）⇒ 走 set_amt 的 reason（eat_team／raid_out…）delta 全不可信；修法清楚無設計選擇（amt−prev），不等票；床：每隊每資源「帳本 delta 總和＝state 差」的對帳格。③M 結案（QA 已撤回）。④★T 把 E 翻回【待對帳】：Team7 的 16 筆徵收訊息只有早期 Team4 的 5 筆在帳本有真轉移；Team5 那 8 筆（含 QA 時間軸裡 t25260／25320 那兩刀）帳本零條目——而 QA 讀 state 說 coin 300→181。兩者只能有一個對：要嘛那段 coin 的下跌另有 reason（QA 歸因錯）、要嘛徵收走了一條不經 ResourceBank／不記 reason 的寫入（儀器盲區＝違反全量暫態可觀測性）。⇒ 一問定案：對 t25260–25339 Team7 coin／food 的 state 逐 tick 差 vs 同 tick 帳本全部 reason 的和。對上＝QA 歸因錯、E 故事要重寫；對不上＝盲區，修寫入點。⑤C′ 擴一句：訊息＝發生的事；三種資源 amount 全 ≤0 的徵收不得發「徵收 rate=0.45」，改發「徵收無所得」或不發。
---

# 一、A3′：全市集

```
systems 的兩層答案：宣告無、事實有（掠奪 npc_combat_system.gd:590-599／勒索 interaction_system.gd:487-496／徵收 :755-771 只讀 team.resources，不讀 pending_claims）。
裁：這不算「第二身分」—— 沒有任何意圖說待領該受保護；它只是錢在別處。
  ·到場即結清適用全市集。結清後帶回家的路上風險＝後勤統一 arc 的「供給跨距離移動」要的真實；不是副作用。
  ·掠奪／勒索／徵收不改去讀 pending_claims：錢不在身上搶不到是物理；徵收是對隊的現貨抽成，遠方的待領不在現貨裡也合理。
  ·留下的洞「故意不領來逃徵收」：那筆錢自己也用不到，等於沒有；記進意圖帳一行，不開票。
床照前信；序由你排。
```

# 二、D：非缺陷＋儀器直接修

```
鏡像數字＝trade_goods_in（+27 筆 +5746）／trade_goods_out（−25 筆 −5220）兩個 reason，各自單邊 ⇒ 真買賣。票 D 不開；「思考不改世界」那條意圖留著（它是原則，這次沒被違反）。
儀器缺陷：set_amt 的 record_driver 傳 amt 不傳 amt−prev。修法唯一、無設計選擇 ⇒ 直接修（obvious bug，不等票不等 R² 設計審，過 R² code 審即可），並加對帳床：每隊每資源 Σ(ledger delta) ＝ state(t1)−state(t0)，用 Team7 窗 t28630–29340 的 eat_team 當陽性對照（修前必紅：+4251 對不上）。
★修完 D／T 的數字要重跑：eat_team 那組不可信代表本輪「food 帳本」的任何總和都不可信。
```

# 三、M：結案（QA 已撤回 material≈45% 的接法；窗內只一筆 claim_goods +15）。

# 四、T：E 翻回待對帳（一問定案）

```
事實：Team7 相關徵收訊息 16 筆；帳本真轉移配對 5 筆，全是早期 Team4（rate 0.01／0.00）；Team5×8、Team39、Team36（rate 0.45）零條目。
矛盾：QA 的 E 時間軸（f9b08071d）寫 t25260／25320 Team5 徵收後 coin 300.65→180.58、food 215→162.5 —— 那是 state 讀數。
⇒ 若帳本沒有那兩刀的條目而 state 掉了，只有兩種：
  (a) coin 的下跌是別的 reason（買貨 trade_goods_out？），QA 把同 tick 的徵收訊息當因 ⇒ E 的故事「被徵收榨乾」要重寫；量測員 §四 的推論（amount≤0 全 continue）成立。
  (b) 徵收走了一條不記 reason／不經 ResourceBank 的寫入 ⇒ 儀器盲區，違反全量暫態可觀測性，修寫入點。
一問：量測員對 t25200–25400 Team7 coin／food 逐 tick state 差 vs 同 tick 帳本所有 reason 之和，列出每個 tick 的差額與 reason 清單。對上⇒(a)；對不上⇒(b)。
在這一問答完前，E 的結案狀態＝【待對帳】，QA 的故事與我的意圖帳那列（徵收節律）都先不當前提。
★「訊息節律」與「真實抽血節律」分開看：採。T 原題（同收者→同附庸最短間隔）要用帳本配對後的真轉移算，不用訊息算。
```

# 五、C′ 擴

訊息＝發生的事。徵收三種資源 amount 全 ≤0 ⇒ 不得發「徵收 rate=0.45」；發「徵收無所得」或不發（HOW 定）。否則玩家事件流會看到 11 次「被徵收」而一毛沒少 —— 跟 forced_event「未知提案」是同一種對讀者說謊。

# 六、消費

systems→blueprint a3prime-precheck：consumed。measurer→blueprint team7-ledger-D-M-T：consumed。
