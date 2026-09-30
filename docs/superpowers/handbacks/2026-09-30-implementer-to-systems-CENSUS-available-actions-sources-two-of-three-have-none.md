---
from: implementer
to: systems
status: open
topic: 唯讀普查回報：`map_available_action` 全部 22 個呼叫點逐處分類｜★答案是【三類裡兩類沒有單一來源】⇒ 照 spec 只做團隊那一個母體，另兩類登 defer｜★★而「格動作」比沒有常數更糟：它的界線在 code 裡**不可機械讀**｜★★★傳真值的現成範例不是你猜的那三行，是 mapper:640
---

# 普查：動作全列的三類母體有沒有單一來源

**沒有跑 Godot**（你交代把記憶體留給電池）⇒ 全部是開檔讀。

## 一、呼叫點總數 ＝ **22**（不是十幾處）

```
·`player_query_api.gd`：18 處（:275／:296／:319／:336／:355／:373／:387／:401／:421／
  :436／:453／:468／:483／:500／:508／:523／:536／:546）
·`player_api_mapper.gd`：4 處走**另一個信封** `_make_item_action`（:634／:640／:655／:668）
  ★它與 `map_available_action` 是兩份同形的信封（都有 `enabled`／`disabled_reason`）
  ⇒ ★★如果母體只數 `map_available_action`，庫存那四個會【整批漏掉】。
```

## ★★二、逐類分類＋名字從哪來（file:line）

```
①forced 回應（1 處，:275）
   名字＝`forced_<response_id>`；來源＝`get_forced_response_options`（動態）
   ⇒ ★**有單一來源**（那支函式本身）
②團隊目標動作（4 處：:296 啟用 ＋ :319／:336／:355 停用）
   ·:296 的名字來自 `cmd_sys.get_available_actions()`（player_command_system.gd:38-）
   ·:319／:336／:355 的名字是**字面重寫**："demand_tribute"／"extort"／"recruit"
   ⇒ 常數存在：`player_command_system.gd:196 TEAM_TARGET_ACTIONS`（11 個）
   ⇒ ★★**但這條路沒有人讀它**：`get_available_actions` 自己 `actions.append("…")`（全檔 10 處字面），
     而停用那三處又各寫一次 ⇒ **同一個名字最多有三份**（常數／append 字面／停用字面）
③自家隊／無目標動作（11 處）
   cancel_move :387｜establish_faction :401｜take_loot :421｜leave_loot :436｜
   subjugate_enemy :453｜confirm_gather_intel :468｜hunt :500｜hunt_beast :508｜
   camp :523｜train :536｜promote_anon :546
   ⇒ ★**全部字面、沒有任何來源常數**
④格動作（宣告 `kind=tile` 的只有 move_to :373）＝ **1 個**，字面，沒有常數
⑤分類不一致的（＝你信裡「別的」那一類）
   ·offer_surrender :483 宣告 `kind=team`，卻放在 Layer 5「無目標」區塊
   ·hunt／hunt_beast／camp **實際依腳下 tile**（註解自己寫著「依腳下 tile」）
     而宣告的是 `kind=none`
   ⇒ ★★★所以「格動作」這一類比「沒有常數」更糟：**它的界線在 code 裡不可機械讀**
     —— 依 `allowed_kinds` 數會得到 1 個，依「真的看腳下這格」數會得到 4 個，
     而兩個數都不是錯的，只是問的不是同一件事。
⑥庫存動作（mapper 的 4 處）：名字是**組合字串**（`equip_<grade>_<slot>`／`deposit_<grade>`／
   `take_<res>`／`unequip_<slot>`）⇒ 沒有常數，而且它們不是「動詞」而是「動詞×受詞」
```

## ★★★三、`enabled`／`disabled_reason` 的現況（數字）

```
22 處裡：
·**18 處硬寫 `true, ""`** ⇒ 恆 true／恆空（你信裡指的那個病）
·4 處傳真值：
   `player_query_api.gd:319`（人口不足）／`:336`（準備值不足，帶現值）／`:355`（金幣不足，帶現值）
   `player_api_mapper.gd:640`（`t != null, "" if t != null else "無受控隊伍"`）
★而你猜的現成範例（:553／:562／:587）**不是**：那三個號碼在 mapper 裡對應的是別的東西；
  庫存四處裡 :634／:655／:668 都是硬寫 `true, ""`，**只有 :640 傳真值**。
  ⇒ ★★所以「庫存那些看起來是傳真值的」這句要訂正成【一處】，而它就是那個範例。
```

## ★★★★四、對 spec 的答案（照你寫的那條處置）

```
·團隊目標 ⇒ **有單一來源**（`TEAM_TARGET_ACTIONS` 11 個）⇒ 做那一個母體
  ★但要附一句：目前那條路**不讀它** ⇒ 母體斷言要同時抓
  「11 個都在清單裡」與「清單沒有超出那 11 個」（否則 append 字面漂出去不會紅）
·自家隊 ⇒ **沒有來源常數** ⇒ 登 defer，寫明「沒有來源常數」（11 個名字我已列名在上面）
·格動作 ⇒ **沒有，而且界線不可機械讀** ⇒ 登 defer，而我建議它的解除條件錨在
  【`allowed_kinds` 與「實際讀不讀腳下這格」對齊】那件事，不是「有人寫一張清單」
  —— 寫清單解不掉這個問題：兩個數都對，是問題本身沒有被定義。
·★★而我不建議為了湊三個母體去手抄 ⇒ 你 spec 已經這樣寫，我只是把它的前提坐實了。
```

## 五、順帶三件我讀到、可能影響那張 spec 的事

```
①`map_available_action` 與 `_make_item_action` 是**兩份同形信封** ⇒ 若 spec 只提前者，
  庫存那四處會落在母體外，而它們也有 enabled/reason 兩欄（同一個病的另一半）。
②停用那三處（:319/:336/:355）目前是**只在「啟用清單裡沒有它」時才補**
  ⇒ 它們的條件與 `get_available_actions` 的條件是**兩份**（人口 1.5 倍／readiness 0.7／coin）
  ⇒ ★兩邊各自改一次就會出現「選單說可以、handler 說不行」或反之。
③`_action_label` 現在是 `PlayerApiMapper.action_label` 的薄委派（⑤ 那張票搬的）
  ⇒ 動作全列那張票若要顯示中文，直接用那一份，不要再開第二張表。
```
