---
from: implementer
to: systems
status: open
slice: 哨兵（player_* 進 fp）
topic: ★交件 3fc3f52d8：哨兵裝上，無玩家 300 tick 裡 player_* ＝ setup 後的基準線（tick 期間零人碰）｜★★而【哨兵的第一份報告是假陽性，而且是我自己造的】：我拿 `WorldState.new()` 當基準線 ⇒ 它「抓到」的差異其實是 **setup 自己寫的 `player_state{coin=50}`** —— ★★★假陽性跟真陽性在輸出上長得一模一樣，所以基準線改成【setup 完、跑 tick 之前那一刻】並把理由釘在 code 旁｜★真 code 層的對照做了：注入一行偷寫 ⇒ 當場紅（alerts 0→16）、還原回綠，而 RNG 位移那半分開量到（fp 260371df… → dd381ae1…）
---

# ① 落地（3fc3f52d8）

```
state_fingerprint.gd  ＋_emit_player（頂層 10 欄進 canon）＋player_section()（給床單獨比那一段）
scripts/debug/player_fp_sentinel_bed.gd （acceptance）5/5 段 0 fail
```

★**哨兵看到哪一層**（spec 要求寫明，兩個粒度都說）：

```
頂層 10 欄：player_id／possess_prev／forced_event_id／hostile_teams／pending_targets／
           alerts(size)／state／forced_event／pending_orders／pre_encounter
Dictionary：鍵排序後的【鍵＋值】⇒ ★player_state 這種 dict 的【內部鍵值】改動看得到
巢狀第二層以下：只走 str() ⇒ ★★形狀變看得到，浮點細節不保證
```

# ② ★★我自己造的假陽性（★這件比綠燈值得記）

```
第一版基準線＝WorldState.new() ⇒ 床第一次跑就「抓到」差異：
  跑完   P|state{coin=50,inventory=[]}
  基準線 P|state{}
★而那不是 tick 裡有人偷碰，是【setup 自己寫的】（玩家錢包初始化；我們是 setup 之後才 strip player_id）。
⇒ ★★假陽性與真陽性在輸出上【長得一模一樣】：同一行字、同一個 FAIL、同樣「哨兵抓到東西」。
⇒ 改法：基準線＝【setup 完、跑 tick 之前】那一刻，並把這段理由寫在 code 旁邊
   ★★★否則下一個人會重蹈：他會看到一個紅燈，然後去找一個不存在的偷碰。
```

# ③ 驗收逐格

```
①無玩家 300 tick：兩跑 fp 同／player 段同／＝ setup 基準線 ⇒ ★tick 期間【零人碰】
②★真 code 層對照（不是床內模擬）：在 try_proactive_diplomacy 注入
   `state.player_alerts.append({..., "id": str(randi())})`
   ⇒ ①當場紅：alerts 0 → 16；還原後回綠。
   ★床內另有三格：偷寫⇒段變＋fp 變／加一支隊⇒段不動（不亂紅）／dict 內部鍵值看得到
③★RNG 位移【分開量】（你標未驗那格，我順手驗了兩層）：
   (a) seed 相同下「先 randi 再 randf」≠「直接 randf」⇒ randi() 走同一條全域流
       ★對照：不插 randi 時兩次 randf 相同（證明差來自 randi 不是雜訊）
   (b) ★★同 300 tick：乾淨 fp=260371df1ef789f0890a22f0d50fdc26
       注入偷寫後 fp=dd381ae16ba8b16f8b2c6326671e81fb
       ⇒ ★★★不只多寫一欄，它讓【整條世界位移】—— 這正是你說「嚴重一個量級」的那一半
④有玩家的跑仍可重現；玩家操作 ⇒ fp 不同（★這是哨兵的定義，不是漂移）
⑤硬寫 fp 基準：裸掃 scripts/ 的 32-hex 字串常數 ⇒ ★【零處】，與 R² 一致 ⇒ 無需更新
⑥導出的排除清單裡不再有任何 player_*（總排除 38 → 28 欄）★零手動維護
```

# ④ 兩件我沒做、但你會想知道的

```
①★沒有修任何 sim 對玩家的通知行為（spec §④）。而 300 tick 的無玩家跑裡【沒有抓到違規】
  ⇒ ★★注意這個 0 的讀法：它是【這個窗、這個 config】沒有踩到，
     不是「所有寫入點都 gate 好了」——★★★真正的守衛是這個哨兵【從現在起一直掛著】。
②★我查 gate 時發現一件形狀上的事：你列的兩處（diplomatic_ai:167／:346）都是
  【雙重守衛】——外層 `if state.player_id != -1`，內層還有 `player_person != null`。
  ⇒ ★★所以「拿掉那個 if」的對照【咬不動】（內層會擋下來）——這就是我改用注入寫入的原因。
  ⇒ ★★★而這也是好消息的一半：這兩處就算 gate 被誤刪，還有第二道。
```
