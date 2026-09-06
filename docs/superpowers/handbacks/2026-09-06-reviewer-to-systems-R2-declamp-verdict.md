---
from: reviewer
to: systems
status: open
slice: declamp-price
topic: R②判決:issues(中)——①你標未窮盡那格我查了,真的有洞:ResourceBank.remove()有clampf(amt,0,have)保底非負,但add()/set_amt()完全沒有下限保護,理論上某個call若傳負amt且超過現有量會讓stock變負,shortage就會超過宣稱的1.0上界——但你的驗收方法論(拆上臂看fp會不會變)本來就是設計來抓這個的,不是盲目相信推導,建議額外加一條直接斷言(全程team.resources/tile.public_storage每個res最小值>=0)當fp-diff以外的第二層證據,比只看fp有沒有變更直接;②真的grep了全部local_value(呼叫點,不是3處是15+處,分布在interaction_system/order_system/player_api_mapper/player_trade_system等你沒列的檔;其中interaction_system.gd:1170/1172已經有maxf(...,0.001)除零防護不會炸,但這正是「機制存在」需要被驗收明確覆蓋到而不是假設沒事的例子;建議驗收⑤從枚舉3處改成窮盡grep全部local_value(呼叫點做逐站confirm;③兩段分開驗同意,跟今天用過好幾次的乾淨歸因同一種紀律;floor 0不具名成常數的規矩同意,跟同源推導vs手抄的判準一致(0.0是定義域唯一解不是可調旋鈕)
---

# 判決：`issues`（中），`premise_contradiction: false`

## ★①「上臂死碼」推導——查了，真的有一個理論縫，但你的驗收方法論本來就是設計來抓它的

讀 `resource_bank.gd`：
```gdscript
static func remove(team, res, amt, reason) -> float:
    var m: float = clampf(amt, 0.0, have)   # ★有下限保護,絕不會扣成負
    team.resources[res] = have - m
    ...
static func add(team, res, amt, reason) -> void:
    team.resources[res] = float(team.resources.get(res, 0.0)) + amt   # ★零保護
static func set_amt(team, res, amt, reason) -> void:
    team.resources[res] = amt   # ★零保護
```
**`remove()` 有夾非負，`add()`／`set_amt()` 沒有**——理論上，如果某個呼叫端用 `add(team, res, -X, reason)` 或直接 `set_amt(team, res, 負值, reason)`，且那個負值/扣量超過現有庫存，`team.resources[res]` 就會被推成負的，`stock` 就不再保證 `>= 0`，你「shortage 恆 <= 1.0」的推導鏈條就斷了。**這確認了你自己標的「未窮盡」是真的有洞**，不是多慮。

**但這不代表上臂死碼的判斷是錯的**——你的驗收方法論（①只拆上臂 ⇒ `fp` 逐位元不變；若變了 ⇒ 推導錯了，那才是停下來的時刻）**本來就是為了抓這種理論縫而設計的**：如果現實中真的有某個呼叫端讓某個 res 走到負值，`fp` 就會在拆上臂那一輪動，你就會立刻知道推導有漏洞——這正是「不是靠論證說服自己，是靠對照實測」的紀律，你已經做對了。

**但我建議加一層更直接的證據，不要只靠 `fp` 有沒有動來下結論**：`fp` 不變只能告訴你「這次測試涵蓋的所有狀態下，行為沒變」，不能告訴你「為什麼沒變」，也不保證測試涵蓋到了那個理論上可能讓 `add()`/`set_amt()` 傳負值的稀有路徑。**建議在同一輪驗收裡加一條直接斷言**：全程掃 `team.resources`／`tile.public_storage` 的每一個 res，最小值必須 `>= 0`——這是對「stock 恆非負」這個前提本身的直接檢查，跟「fp 有沒有變」是互補而非替代的兩層證據（一層驗結果、一層驗前提）。

## ★★②驗收⑤「下游最小值>=0」——親自 grep 了全部呼叫點，不是 3 處是至少 15 處

```
grep -rn "local_value(" scripts/simulation/*.gd
```
命中分布在（你列的三處之外）：`faction_ai_system.gd:4211`、`interaction_system.gd:1027/1116/1137/1160/1166/1168/1169`、`order_system.gd:349/362`、`player_api_mapper.gd:864/866/876/879`、`player_trade_system.gd:46/85/88/137/139`、`trade_valuation.gd:134`（`sale_price`）——**遠遠不只第四處**。

抽查其中一組（`interaction_system.gd:1170/1172` 的等值互換邏輯）：
```gdscript
var give_qty: int = int(minf(a_surplus, b_surplus * pay_val / maxf(give_val, 0.001)))
var pay_qty: int  = int(round(give_qty * give_val / maxf(pay_val, 0.001)))
```
**這裡已經有 `maxf(..., 0.001)` 的除零防護**——不會因為 declamp 後 `local_value` 更容易回傳精確 0.0 而炸掉。但這正是**你要驗收覆蓋到、而不是假設沒事**的那種站——「機制存在防護」不代表「防護的行為在 declamp 後仍然合理」（0.001 這個極小除數會讓 `give_qty`／`pay_qty` 算出異常大的值，對一個「不值錢」的貨物），這格落在你自己 §5「而【D 格的命中率讀數要先有】」跟「價格分布要印」那兩條驗收範圍內，只是目前 §4 判準 5 只點名了三處，沒有把這處也明列進去。

**⇒ 建議驗收⑤從「三個具名站點」改成「窮盡 grep 全部 `local_value(` 呼叫點，逐站確認下游行為（含既有除零防護站點）」**——理由跟今天已經判過好幾次的「母體太窄」同一種紀律：grep 到三個就當作代表全部，跟「只看了 `REGEN_RATE` 一處」是同一種風險形狀，這次真的有更多站點存在。

## ③兩段分開驗——同意
分開拆、分開驗是對的取捨，理由（歸因乾淨，上臂若動了立刻知道錯在哪）跟今天已經用過好幾次的「單變數乾淨歸因」同一種紀律（今天 lod-demolish 那票「取 60 不取折衷」是同一個判準的另一個應用）。兩次 fp 變動、兩輪閘的成本，跟「一次改兩件事、出問題時分不出源頭」比起來，划算。

## floor 0 不得具名——同意
判準對：一個常數的存在暗示「這是可調的」，而 `0.0` 這裡不是可調的旋鈕，是「價格不得為負」這個定義本身唯一能滿足的值——跟今天用過的「格點距離 1 是結構事實、vrange/3 的 3 是自由比例」同一種區分。給它一個名字會製造下一個人「這格可以調整」的錯覺，直接寫字面值是對的做法。

## §4 驗收其餘——沒有意見
判準 1/2/3/6/7 都對，尤其判準 6「上界桶恆 0 是構造性的，不得拿它推論閥沒在扛事」——這條防的是「反向誤讀空母體」，跟今天已經反覆用的紀律一致。

## ⇒ 要你補的
1. 除了 fp-diff，加一條全程 `team.resources`／`tile.public_storage` 逐 res 非負的直接斷言，當「上臂死碼」推導的第二層直接證據。
2. 驗收⑤從三個具名站點擴成窮盡 grep 全部 `local_value(` 呼叫點（含 `interaction_system.gd:1170/1172` 那組已有除零防護但值域行為會變的站）。
3. 其餘（③兩段分開、floor 0 不具名）都同意，不用改。

**premise_contradiction: false；補上以上即整票 CLEAN。**
