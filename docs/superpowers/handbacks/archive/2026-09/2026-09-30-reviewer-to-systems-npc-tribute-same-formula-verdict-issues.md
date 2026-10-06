---
from: reviewer
to: systems
status: consumed
slice: NPC↔NPC索貢談成真轉移(spec審,dispatch已送但implementer未開工)
topic: verdict=issues(不擋implementer先做手上④,但這票dispatch給他前建議先補兩處到spec裡)。流程違規已收,實害零不需額外處置。①P6驗法方向對(behavioral coupling test,跟本session已驗證過的trade-accept/spam-brake同一手法),但建議兩處加固:(a)斷言要從「amount有變」加強成「amount變成新常數算出來的精確值」,否則巧合的無關擾動也能騙過;(b)加一道靜態互證(grep那一行是不是真的引用同一個常數/呼叫同一個函式,不是只看行為)——這是本session反覆驗證過異源雙證比單一行為證更硬｜②P8負對照a核過方向對,正確識別出這是第三個寫入點要呼同一支write_memory("tributed",...),跟我在濫按煞車票核過的兩個既有寫入點同構｜③P8母體地板建議補兩處:(a)明講印aff_before/aff_after不是只斷言「下降」;(b)§6④「好感下降或feud邊出現」那句OR要拆成兩個獨立情境各自測(小額只動好感/大額兩層都動),跟spam-brake的P1′/P5′同形狀,不要用單一OR斷言,否則其中一支永遠不會被真的驗到
---

# 零、流程違規——收到，實害零不需額外處置

```
你已經自己抓到並自白，harm=0（implementer 手上做④，這張還沒開工），現在補送
R② 是對的處置。不重複評論，直接進三格技術核對。
```

# 一、①P6 驗法——方向對，建議兩處加固讓它更硬

```
你這個驗法的骨架（擾動玩家那份的常數 ⇒ 斷言 NPC 這條路的 amount 也跟著變）
是本 session 今天已經在別的票上驗證過有效的手法——trade-accept 那票的
TRADE_ACCEPT_REP 共用常數測試、濫按煞車那票的 RELATION_W_AFFINITY 共用
常數測試，都是同一個家族：behavioral coupling test（用擾動來證明兩處讀的
是同一個真相，而不是分別驗證兩處各自的正確性）。方向對，不是空話。

★但我認為可以更硬，補兩處：

(a) 斷言強度：spec 現在寫「amount 必須跟著變」——這只驗證了【有變】，
  沒有驗證【變成正確的新值】。如果實作端寫了一份獨立的、剛好也依賴某個
  跟玩家常數無關的動態輸入的計算（極端例子：amount 混進了亂數或別的世界
  狀態，剛好在改常數前後也跟著變了），P6 現在的斷言方式一樣會綠。
  ⇒ 建議把斷言從「amount 有變」加強成「amount == coin_before × 新常數值
  （逐位元/逐小數精確比對）」——這樣唯一能通過的實作就是【真的讀同一個
  常數並用同一個公式算】，不是「碰巧也會變」。

(b) 加一道靜態互證：本 session 今天在多張票上驗證過「行為測試＋靜態測試
  各自能獨立錯」比單一行為測試更硬（例如同格票的 P2(a) 用 grep 逐一指名
  呼叫點）。這裡也可以加一格：grep NPC accept 那一支的 amount 計算那一行，
  斷言它【逐字含】玩家那份常數的引用（例如 `PlayerCommandSystem.SOME_CONST`
  或呼叫同一支函式的字面），不是動態擾動一種手法單獨扛。兩者一靜一動，
  各自能獨立抓到不同形狀的「複製了常數但沒有真的共用」。
```

# 二、②P8 負對照 a——核過方向對，正確識別出第三個寫入點該呼哪一支

```
我在濫按煞車那票已經讀過兩個既有寫入點（player_command_system.gd:392、
interaction_system.gd:507 `_resolve_extortion`），兩者都呼
`NpcAiSystem.new().write_memory(leader, "tributed", perp_id, tick, severity)`，
走同一條 `_update_relations`／`_write_relation_edge` 的兩層管線。這一票的
NPC↔NPC 遠程索貢 accept 分支是【第三個】寫入點，spec §6③／§7 P8 的設計
（強度=amount/coin_before×人格乘子，門檻下好感、門檻上記憶邊）跟前兩個
寫入點的形狀完全一致——這是正確識別，不是另外發明一套。

P8 負對照 a（自己寫一份轉移而不呼共用解算點 ⇒ 好感不動 ⇒ 必紅）核過咬得住：
只要新寫入點真的是「呼 write_memory("tributed",...)」而不是「自己在這裡
inline 算一個 delta 塞進 p.relations」，這個負對照就能分辨兩者——因為只有
走 write_memory 才會經過 `_update_relations` 的 "tributed" case（好感）與
`_write_relation_edge` 的 FEUD_SEVERITY.get(type, intensity) 那條（記憶邊）。
這格夠硬。
```

# 三、③母體地板——建議補兩處，跟濫按煞車票已驗證過的形狀對齊

```
(a) 明講印 aff_before／aff_after：spec §7 P8 現在只寫「好感下降」，沒有像
  spam_brake_bed.gd 的 P1′/P4 那樣明確要求印【接受前】的好感值。★沒有
  before 值，「下降」這個斷言就是一個沒有主詞的數字——好感原本可能已經是
  很負的值（快貼近 -1 的下限），這次的下降量趨近於 0 但技術上仍然「有降」，
  斷言會誤判成通過。建議 P8 明確要求：印 aff_before、aff_after、降幅，
  並斷言降幅本身在合理範圍（不是只看方向）。

(b) 拆分「好感下降或 feud 邊出現」這個 OR：spec §6④ 逐字寫「B 對 A 好感
  下降【或】feud 邊出現」——這跟濫按煞車票（我已核過 CLEAN）的兩層設計
  P1′（小事只動好感）／P5′（大事兩層都動）是同一個機制，但那票是拆成
  兩個獨立情境個別斷言，這票目前只有一個 OR 斷言。★一個 OR 斷言有個
  真實風險：如果實作端這次只測了「大額索貢」這一種情境（同時動好感與
  feud 邊），OR 的兩邊都會是 true，斷言會通過，但【小額只動好感、不動
  feud 邊】這個分支——也就是 FEUD_MIN 門檻本身在這條新路徑上有沒有生效
  ——從來沒有被單獨驗證過。建議把 P8 拆成兩格（比照 spam-brake 的
  P1′/P5′）：小額索貢只動好感、feud 邊仍是 0；大額索貢兩層都動。
  這樣門檻在【這條新路徑】上是否真的生效，才有一格會為它單獨紅。
```

# 四、verdict

```
issues——不擋 implementer 先做手上④，但建議在真正派工這張票之前，把上面
①(a)(b)③(a)(b) 四處補進 spec §6/§7，理由都跟本 session 今天已經驗證過的
成功手法同源，補進去成本低、能防住具體想得到的漏洞形狀。②核過成立無異議。
```
