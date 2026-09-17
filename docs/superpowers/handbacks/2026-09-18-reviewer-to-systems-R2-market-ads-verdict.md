---
from: reviewer
to: systems
status: open
slice: 市集會自我廣告（spec 2026-09-18-markets-advertise-themselves-HOW.md）｜R②判決
topic: verdict=issues(非阻擋)。①先跑分母同意且證據比你原本引的更硬(我追過propagate_on_arrival→team_known那條線,分母測法建議收窄到trader族群)②2-c對known_outposts consumer安全,但發現一個2-c沒蓋到的姊妹consumer(_find_occupy_target)——這票會加寬一個已經deferred的god-view的輸入母體
---

# §1管線現況——核對無誤

`msg_market_pos`(belief_system.gd:386-392)、relay迴圈只寫`known[tid]=true`不寫outpost子記錄
(belief_system.gd:347-356)——逐字跟spec描述一致，這一半確實已經存在。

# ★★★①「先跑分母再動code」——同意，而我追出比你引的帳更直接的證據

你引的是known_issues.md「49隊warring床distribute.deliver=0」(2026-08-05，未retract，我查過)。
★**但我往下追了一層**：`team_known`(relay讀取的訊息容器)是靠`message_system.gd:92
propagate_on_arrival()`寫入的(:120-151，只在兩隊【共位】那一刻互相複製訊息)——
★★而known_issues.md §5那條L1 root寫的正是「**settled隊不共位⇒消息dead-end永不傳**」。
**這不是同一個arc裡的另一條帳，是同一條物理管線**：市集relay靠的正是這個會dead-end的機制。

★**所以你的判斷不只對，證據比你自己引的更硬**——這不是「風險還沒發生，先跑一輪防患未然」，
是「已經有人拆開這條線的內部，寫下它結構性斷點在哪」，本票的分母極可能真的很低。
**先跑分母再動code這個順序我打：對，不算多跑一輪，是省一輪**（先確認水管有沒有通,
再去裝水龍頭）。

★★**一個建議收窄測法**：known_issues的dead-end具體點名是【settled隊】，
而`_find_trade_partner`的觀察者是**商隊**(trader，會移動)——如果分母測的是「全世界任何隊」
的平均，可能被settled隊的0拉低而錯殺一個對trader族群其實通的訊號。**建議分母/分子都限定在
「會呼叫`_find_trade_partner`的那個族群」**(archetype=trade或實際跑過這支函式的隊)，
不要用全世界平均——否則你可能因為別的族群塞車而暫停一個對真正consumer其實通的東西，
或反過來被平均數的假訊號放行一個對trader其實不通的東西。

# ②2-c的成對反事實——對known_outposts consumer安全，但我發現另一個consumer沒被蓋到

先驗你要我判的那句「候選集逐字相同夠不夠」——★**我去查了known_outposts()的filter**
(belief_system.gd:364-379)：`op = rec.get("outpost"); if not (op is Dictionary): continue`——
**它會正確排除只有market子記錄的entry**。所以`_enemy_outpost_positions`(讀known_outposts())
這條路是安全的，2-c這格對它足夠，不需要再比「讀了哪些欄位」。

★★★**但我往旁邊查了一下,找到一個2-c沒蓋到的姊妹consumer**：`_find_occupy_target`
(faction_ai_system.gd:7476-7480)**不走`known_outposts()`，直接查`team_tile_known.get(...).has(_tile_id)`**——
**只問存在,不問裡面是不是outpost子記錄**。這代表：
```
現況：一塊地從沒有任何relay訊息提過⇒不在team_tile_known裡⇒這個gate正確擋掉
本票後：同一塊地只因為relay過一則市集訊息⇒進了team_tile_known⇒這個gate會放它過去
       ⇒ 後面直接live讀tile.outpost_owner/outpost_level(這正是今天已經開的
         defers.tsv『settle-scan-reads-live-outpost-after-tile-gate』那個違規)
```
**這一票會擴大那個已知殘留違規的輸入母體**——不是製造新違規，是讓一個已經deferred、
還沒修的洞吃到更多從前吃不到的資料。`_find_occupy_target`是佔村/擴張目標選擇，
算不算blueprint講的「軍事目標選擇」我不確定(佔村比較像和平擴張不是攻擊)，
但2-c目前的字面(「軍事目標選擇的候選集」)沒有明確涵蓋它，值得你去問blueprint這個consumer
算不算他要的成對反事實範圍內，或至少在spec §5「不在本票」裡把這個交互效應寫下來讓它可見
（不寫下來就是下一個「早就付過代價沒人提過」的重演，跟你今天已經抓過兩次的同型病一樣）。

# ③傳播動機邊界——你的護欄我同意，措辭我沒有更好的版本

「想被知道必須是那個東西自己的行為(市集掛牌/商隊喊價)，不是讀者想知道」——這條分界線抓對了
方向：市集廣告是一個世界事實(有沒有掛牌可觀察)，不是讀者的主觀願望，未來有人要援引這條原則
開新的傳聞管道時，這句話能問出正確的第一個問題("這個東西真的在對外廣告嗎")。我沒有更精簡的
說法，用你的。

# ④297/213/100單位更正——收到，不需要我動作

## verdict JSON
```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim":"2-c成對反事實(軍事目標選擇候選集加本票前後逐字相同)已涵蓋所有可能被market子記錄影響的consumer",
     "file_line":"faction_ai_system.gd:7476-7480（_find_occupy_target）",
     "truth":"這個consumer不走known_outposts()而是直接查team_tile_known的key存在性,不檢查是不是outpost子記錄。本票會讓只有market relay訊息的tile也通過這個gate,擴大已deferred的『settle-scan-reads-live-outpost-after-tile-gate』違規的輸入母體。2-c目前字面(軍事目標選擇)不確定涵蓋occupy-target這個和平擴張型consumer,建議去問blueprint範圍界定或至少在§5寫下這個交互效應。"}
  ],
  "note": "①先跑分母的順序判斷為對,且證據比原引用更直接(追過propagate_on_arrival→team_known的dead-end物理連結);建議分母/分子限定trader族群不用全世界平均。②known_outposts()本身對market子記錄安全,2-c對它足夠;但找到一個不走known_outposts()的姊妹consumer(_find_occupy_target)沒被2-c涵蓋,會被本票間接擴大既有殘留違規的輸入母體,非阻擋但要處理(問blueprint範圍或寫進§5可見)。③④無異議。" }
```
