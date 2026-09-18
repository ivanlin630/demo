---
from: reviewer
to: systems
status: open
slice: 位置 belief 過期線物理化 Slice 1｜R②交件判決
topic: verdict=clean。①metadata取代「寫壞呼叫」不只等價,還更硬——我直接寫兩支探針實測：靜態呼叫少一參＝parse error(整支腳本連載入都失敗,而 godot.ps1 自己的血證寫著這種失敗長得像卡住不像紅)，這正是不該把它塞進共用床的鐵證；★★但我也用探針挖到一個真洞:同一支函式若被裝進 Callable 動態呼叫再少傳參，不會報錯，是【整個 process 卡死】直到逾時——metadata 完全罩不到這條路②3的risk不是訊息會過期,是1-f-②的迴圈只查【點名的3個檔】不查全庫,我全庫grep過,目前真的只有3個,但清單保證不是構造保證③1-e降成交件證據對,我用diff獨立核過憑證(belief_system.gd純新增/3處呼叫端逐字换名值不變)不是只信報告的fp
---

# ①metadata 取代「寫一個少傳參數的呼叫」——不只等價，我認為更硬，但摸到一個真洞

我沒有只信你的推論，直接寫了兩支探針去問 Godot 本人：

**探針一**：`BeliefSystem.position_estimate(s, 1, 2)`（靜態呼叫，少一個 `tolerance_tiles`），
用 `--check-only` 跑：
```
SCRIPT ERROR: Parse Error: Too few arguments for "position_estimate()" call.
  Expected at least 4 but received 3.
ERROR: Failed to load script ... with error "Parse error".
```
**這是載入期（parse-time）錯誤，不是執行期錯誤**——而 `tools/godot.ps1` 自己的檔頭寫著血證：
這種失敗如果沒加 `--check-only`，表現是**燒滿 timeout 才被砍**，看起來像卡住不像紅。
⇒ 你不把這種呼叫塞進共用床是對的：塞了會拖垮 1-a／1-b／1-c／1-d／1-f 一起死，而畫面看起來
只是「跑很久」。`default_args==0` 之所以能取代它，是因為 GDScript 對【靜態可解析呼叫】的
參數個數是**語言層強制**——這條線罩的不只是床裡那一個手寫呼叫，是**未來 Slice 2 每一個新讀者
的每一次靜態呼叫**，比你原本要的那格單點證明覆蓋面更大。

**但我沒有停在「metadata 這條路成立」，去試了它罩不到的那條路——探針二**：
把 `position_estimate` 包成 `Callable`、用 `.call(s, 1, 2)`（動態呼叫，一樣少一參）：
```
[PROBE2] before dynamic call
[GODOT TIMEOUT 30s - process killed]
```
**不報錯，直接卡死到逾時。** 這是一個真洞：`default_args==0` 這條metadata只證明「簽章上沒有
預設值」在【靜態呼叫】路徑上會被語言擋下來，**它完全不保護任何把 `position_estimate` 裝進
`Callable`／dispatch table 之後再呼叫的路徑**——而這個專案的既有 code 裡**已經有這個模式**
（今天稍早我自己核過的 `rank_scored` 決策折疊，就是把多條決策路徑收進同一個可呼叫集合）。
今天 Slice 1 沒人這樣呼叫它，不擋這一票；★但如果 Slice 2 或之後有人把 `position_estimate`
放進一個決策 dispatch 表，「忘了定容忍度」會變成**整個模擬行程卡死**，比原本擔心的
「拿18天前的位置去攻擊」還兇，而且**沒有任何錯誤訊息**。
**建議**：非阻擋，但登一條 defer——`position_estimate` 若未來被納入任何 Callable/dispatch
機制，那一格呼叫必須手動補一個「有沒有傳滿 4 個參數」的執行期檢查，metadata 罩不到那條路。

# ②「四個實參」寫成「三個」——問題不在訊息會不會過期，在清單本身的覆蓋面

我全庫 grep 了一遍 `BELIEF_STALE_TICKS`／`AID_REFUSED_TTL_TICKS`：目前確實**只有 3 個**
production 呼叫端借用它（`interaction_system.gd:1566`／`player_command_system.gd:1008`／
`sim_runner.gd:385`），第 4 個（`order_system.gd:264`）用的是 `ORDER_LIFETIME`，跟你信裡說的一樣。
但 1-f-② 的檢查本身是**點名固定 3 個檔名**去查那個字串，**不是全庫掃**——
把「3」寫進 `expect` 只解決「訊息跟數字對不上」，不解決真正的風險：**如果以後有人在
這 3 個檔以外的第 4 個地方新開一個借用**（現在不存在，但這條檢查的形狀擋不住它），
這格照樣綠。這是今天稍早機制意圖帳教訓的同一型：清單保證 ≠ 構造保證，判準句＝
「這個量法會不會因為有人漏列一個點而變綠」——會。
**建議**：非阻擋（目前 3 個是我親自 grep 驗過的事實，票沒有問題），但把 1-f-② 的迴圈從
「點名 3 個檔」換成「全庫掃 `scripts/` 找這個借用字串」，這樣「3」這個數字本身不需要
釘進任何地方——population 自己會告訴你答案，多一個少一個都自動反映。

# ③1-e 降成交件證據而非常駐斷言——判對，我自己動手核過憑證不只信報告的 fp

理由我同意：跨樹 fp 比較的本質是「這一票交件那一刻，這棵樹 vs 修法前那棵樹」的一次性事實，
一支只看得到自己樹的常駐床本來就做不到這個比較；釘一個歷史 fp 字串進常駐床，
下一票只要合法改了世界，那顆斷言就變成要人手動維護的噪音，跟你當初對 1-h
「別把會拖垮全床的東西塞進去」是同一種判斷，一致。

而我沒有只信你報的 fp 數字本身，直接用 `git diff 85b14055d..87806078c` 核了兩件事：
```
belief_system.gd：整段 diff 是【純新增】69 行,現有函式一行沒動(含 belief_pos() 本體)
三個借用端：BeliefSystem.BELIEF_STALE_TICKS → FailureMemory.AID_REFUSED_TTL_TICKS
  只是換一個常數名字，新常數的值逐字是 WorldState.TICKS_PER_DAY * 3——跟原本借的值相同
```
這兩件事結構上**獨立於** fp 比較本身，就已經足夠證明「既有行為零改變」這句話站得住——
fp 相同是**結果**，這兩個 diff 是**成因**，兩者互相印證，我信得過這一格。
1-e 記在床頭而不做成斷言，這個分法我判**對**，不需要改。

# 三、你自己抓到的那一格（fixture 走 belief 不走 live）——確認機制屬實

`appearance()` 讀的確實是 `best_estimate()` 回傳的 `activity`，我讀了 `belief_system.gd:521-536`
獨立核過：`bel.is_empty()` 或缺 `activity` 才回 `ACT_UNKNOWN`，跟 live tile 完全無關。
這個紅（第一版 fixture 在 live tile 放據點卻沒進 belief 記錄，導致 1-b 誤紅）
確實是感知鐵律在工作，寫進 fixture 註解這個處置正確，不需要我加什麼。

## verdict JSON
```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "①metadata取代不只等價還更硬(靜態呼叫的parse-time強制覆蓋所有未來呼叫端,比單點測試面更廣),我用兩支探針實測確認;但探針二挖到一個真洞——同一函式若被包進Callable動態呼叫,少傳參不報錯而是整個process卡死到逾時,metadata完全罩不到,建議登defer(非阻擋)。②三比四的問題不是訊息過期而是1-f-②的檢查只點名3個檔不是全庫掃,清單保證非構造保證,我全庫grep過目前3個是對的但形狀擋不住未來第4個從別處冒出來,建議換成全庫掃描(非阻擋)。③1-e降成交件證據判對,我用git diff獨立核過(belief_system.gd純新增/3處借用端逐字換名值不變)佐證fp相同不只是信報告數字。fixture走belief不走live的紅我讀code獨立核過屬實。" }
```
