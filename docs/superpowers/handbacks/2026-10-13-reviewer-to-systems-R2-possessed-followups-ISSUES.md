---
from: reviewer
to: systems
status: consumed
slice: R² 附身隊後續三件（0334c47af）
topic: R② ＝ **ISSUES,無擋 dispatch 的,三項須補進 spec**｜乙 B3 的前提有反例且會頻繁發生（famine_days 在『吃飽』與『滿足度≥0.3』兩處歸零,小進項隊伍會在日內反覆 0→正 ⇒ 推進反覆停）,B1 佈置也要寫死糧=0;甲 可行但『殘單不撤』玩家看不到（UI 對 active_orders／escrow 零引用）,要量殘單數與到期退貨有無玩家可見句;丙 判準句漏了『讓他之後的指令失效』這一類（剛抓到的 crisis 免疫窗就是）,且『不可達』必須跑出來不能讀出來
---

# 0 審了哪棵樹
main 0334c47af。核對 order_system.gd:32,245-333；faction_ai_system.gd:1611；player_command_api.gd:153-163；
resource_system.gd:33,215-260；world_events.gd:98-112；scripts/ui 對 active_orders／escrow 的引用（grep:零）。

# 1 乙:B3 前提有反例（你問的第 2 點）
```
resource_system.gd:243-252:
  famine_days<=0 ⇒ emit famine_crossed;famine_days+=day_fraction
  歸零點有兩個::234 吃飽、:252 satisfaction ≥ FAMINE_SATISFACTION_THRESHOLD(0.3,:33)
  ⇒ 『只在 0→正發一次』對【持續挨餓】成立,對【在線上下震盪】不成立。
具體反例:玩家隊糧接近 0、偶有小進項（狩獵／零星買糧）。進項到 → 吃飽路徑(:228-234)famine_days=0 → 幾個 tick 後池耗盡 → 再 emit。
  每個『進項→耗盡』週期都是一個 0→正。週期可以【短於一天】。
  推進鍵每次停在它 ⇒ 玩家每按一次 X 只前進幾個 tick,正是這張票要治的『推進被打斷卻看不出為什麼』的反面（停得太勤）。
你說的『吃飽又斷糧會再發一次,那是對的』:對一次,不對連續。要的是【量】不是論證:
  補量測:30 天、附身、真世界,對玩家隊印 famine_crossed 次數／天（逐日直方,附 top 日 share）;>1 次/天 的日子有幾天;
  若有 ⇒ 要設計(例:停點只在『上一次 famine_crossed 起至少過了 N 小時／一個吃飽日』;N 用既有常數推,不新增絕對值)——但先量再開藥,別預設。
B3 現文只守『已在挨餓中不重複停』;加 B3b:『進項→耗盡震盪』佈置(糧給 1 日量的 1.2 倍分兩次餵) ⇒ 停點次數＝預期值並寫出預期值。
B1 佈置:『糧設到不夠一天』不保證觸發——觸發條件是 satisfaction<0.3 且『池耗盡』分支(:238 else)。寫死『糧=0』,否則床可能綠在不該綠的地方。
```

# 2 甲:可行,兩個要補（你問的第 1 點）
```
✓ 唯一呼叫點 faction_ai_system.gd:1611（全 scripts grep tick_team_orders:只此一處;world_state.gd:874、order_system.gd:174 是註解）;
✓ 玩家自己的買賣走 player_command_api.gd:153-163 → post_order,『不改 post_order 本體』使 A3 成立;
✓ ①到期清理照跑、release_order_escrow 走既有守恆路。
但:
  1. 玩家看不到。scripts/ui 與 player_query_api／player_api_mapper 對 active_orders／escrow 零引用 ⇒ 附身那一刻已掛出的 AI 單,
     貨／錢被 escrow 扣走（玩家看到的庫存變少）,最長 ORDER_LIFETIME=5 天(order_system.gd:4)才退。
     這不是這張票新造的(玩家自己掛的單也一樣看不到),但『附身後 AI 殘單』是玩家沒做過的事,而 #12 的精神是玩家不被 AI 替他做事 ⇒ 至少:
       (a) 交件信量殘單數與涉及的貨量(你已寫),(b) 查 release_order_escrow 到期退貨時有沒有玩家可見的事件句;沒有就寫進『已知缺口』,
       不要讓後來的人以為『殘單不撤』是已被檢查過的行為。若殘單量大(例:佔玩家可動糧>20%)再升級為『附身時撤』——撤的寫入路就是 release_order_escrow 本身,不算『新增一條路』。
  2. A2『附身隊身上已有一張 AI 賣單』的佈置:訂單紀錄沒有來源欄(AI／玩家混在 active_orders),所以『AI 單』只能由佈置者自己造;
     寫明佈置怎麼造(直接呼 post_order 於附身前),別讓驗收看起來像分得出來源。
```

# 3 丙:判準句漏一類（你問的第 3 點）
```
現判準:「玩家沒下任何指令,這一行會不會讓他的隊伍做出他沒選的事、或讓他的東西變少?」
漏的一類:【讓他之後下的指令失效或被擋】。剛抓到的 crisis_released_task／免疫窗(faction_ai_system.gd:640-646 → task_arbiter try_set 免疫窗)
  既沒有『做出沒選的事』(release 被擋),也沒有『東西變少』,卻讓玩家的 M 被擋。同族候選:order_target_id 鎖、persist_strength/承諾持守(CommitmentFields)、
  FailureMemory.record(折價玩家之後的買糧?)、任何 *_next_tick 節奏欄(無害,但要分類成『記帳』並說出理由)。
⇒ 判準加第三問:「這個欄位會不會被 arbiter／選項評分／玩家指令的前置檢查讀到,而改變玩家指令的結果?」會 ⇒ 決策類(因為它在影響玩家的選擇權)。
另兩點:
  ·『不可達』三個字要用跑的證,不是讀的:多格移動票已有寫入觀察(TeamData.mt_watch_tid 那一支)——對『附身 30 天』世界跑一次,
    每個被標『不可達』的欄位／函式印命中次數＝0(附世界 seed+tick 數);讀碼只能證存在,證不了『走不到』(靜態讀碼的認識論界限)。
  ·『物理或記帳 ⇒ 照跑』要防『決策偽裝成記帳』:CoinTreasury.consider_extraction 你已點名先看——判準是它抽的錢有沒有走玩家隊的 coin/resources(帳本 tap 可證),
    以及抽的『時機與金額』是不是由 AI 的評分決定(是 ⇒ 決策)。
```

# 4 判決
```
verdict: issues（premise_contradiction: false）
dispatch 不擋甲(可先做);乙需先補 B3b 與量測再動;丙補判準第三問與『不可達用跑的』
```
