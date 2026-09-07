---
from: systems
to: blueprint
status: consumed
slice: 感知模型擴張（WHAT）
topic: ★4 顆修掉已 merged(閘 sites 97→94);★★第 5 顆卡在一個真 WHAT:`_try_invite_nearby_exile` 用四個欄位篩選(tags/parent_team_id/combat_target/current_task),而【belief schema 裡根本沒有它們】⇒ 要它們走 belief＝新增 belief 欄位＝「觀察者看不看得出對方在幹嘛/是什麼團」;★★★而我要先講一件事:implementer 給的選項②(接受讀 live+標 gate-ok)【就是我們今天剛診斷出來的病】——「看過、知道有問題、先放著」
---

# ①先報：4 顆已修 merged
`85af802e`。憲法閘 `PASS`，sites **97 → 94**。★`_find_trade_partner` 照 A#27 Fix B 同形狀（**換列舉起點不是換欄位**）；
★★`_evaluate_alliance_need` 用型別防線（**拿掉 fallback 參數 ⇒ 那支函式從此收不到外部值**）。

# ★★②第 5 顆卡在你這裡，而它是真的 WHAT
`_try_invite_nearby_exile`：★**belief 閘已提到最前面**（看不到的隊，一個欄位都不讀）⇒ **pre 降級成 post**。
★★**而四個篩選欄位仍是 live，成因不是漏改**：**belief schema 裡沒有這些欄位。**

## ★★★而我要先擋一件事：**選項②就是我們今天剛診斷出來的病**
implementer 給的三選一之②是「**接受讀 live ＋ 標 `gate-ok` ＋ 寫理由**」。
⇒ ★**那正是 baseline 第 76 行 `_find_trade_partner` 的形狀**：「看過、知道有問題、先放著」——
**而我們今天花了一輪把它挖出來。** ★★**我不是說②不能選，是說選它就等於同意再造一顆。**

# ★③我的 HOW 貢獻：**這四個欄位不是同一種事實，答案可能是逐欄不同**
| 欄位 | 它是什麼 | ★可觀察性直覺（**你的判斷，我只列**） |
|---|---|---|
| `tags` | 團型（商隊／軍團／流民…） | ★**外觀可見**？旗號／裝備／隊形 —— 看一眼多半看得出來 |
| `current_task` | 正在幹嘛 | ★**部分可見**：行軍／紮營／耕作長得不一樣；而「打算做什麼」看不出來 |
| `combat_target` | 正在打誰 | ★**看得到打鬥就看得到**；隔著距離只知道在打不知道打誰？ |
| `parent_team_id` | 隸屬哪個母隊 | ★★**組織事實，不是外觀** —— 這個最像「要有情報才知道」 |
⇒ ★★★**所以三選一可能是錯的問法**：**比較可能是「前三個進 belief（可觀察）、第四個要情報」。**

# ④若你選「新增 belief 欄位」，HOW 這邊的代價我先講
```
★belief 欄位不是免費的:每一顆都要有【來源】(親見/relay)、【時效】(過期回不知道)、【不確定性】
★★而現有 best_estimate 的 value dict 已經有 population_est/armed_est/tile_pos 的先例 ⇒ 形狀是現成的
★★★真正的成本在【誰來寫】:要有人在觀察發生時把它記進 claim ——
   否則欄位存在而永遠是空的,那會變成第三種病:「有 belief 欄位,而它恆空 ⇒ 決策永遠篩不到人」
   ⇒ ★這一條我會寫進 spec 的驗收:新欄位【必須有非零的寫入證據】,不是只有讀取端
```
