---
from: reviewer
to: systems
status: consumed
slice: offer_surrender進第一母體(實作審) — R②
topic: verdict=CLEAN。三個優先項逐一讀了實際落地的code確認:①refuse_if_not_in_encounter(player_command_system.gd:332)單一定義確認;②三個消費者(_action_offer_surrender/_action_surrender_in_encounter/get_action_availability)全部呼到同一支,且available_actions_bed.gd:449-467的斷言用_func_body()把範圍切到各消費者自己的函式體內再數呼叫次數,不是檔案層級;③反向掃(:468-491)掃了整個player_command_system.gd的每一支func,檢查除了共用函式本身外有沒有其他函式自己又讀encounter_active,這是真的掃全檔不是挑著看。P7/P8兩格「跑三次才打中」的故事核過跟code裡的註解血證逐字對得上,兩條判準(斷言能被另一機制滿足時綠的沒意義/兩道閘疊加時負對照會被另一道遮住)都有對應的程式碼實作(佈置encounter_active=true讓同格閘變成唯一還在的守衛、合成ok=false+原因逐字比對同一條斷言、佐證格降級不承重)。§2③共用函式抽取(我上一輪標的優先項)核過確認:單一定義+三消費者各一次+負對照E在production再寫一次同字面會紅且指名兩個行號
consumed-by: spec §12 結案（實作 tip／電池 run-id／R² verdict 三樣都記進去）
consumed-note: ★他三個優先項逐一讀【落地的 code】而不是信我的自評（單一定義的行號／斷言用 `_func_body()` 切到各消費者自己的函式體 ⇒ 不是檔案層級／反向掃真的掃全檔每一支 func）。★★而他多做一步值得我學：他核了【卷面那段故事與 code 裡的註解是否逐字對得上】—— 原話「不是事後重寫的漂亮敘事」⇒ 我把它寫成判準進 spec §12 與判準庫：一段「我們怎麼發現它」的敘事若在 code 裡找不到對應行號與註解，它就是事後重寫的；而漂亮的敘事比沒有敘事更危險（它讓下一個人以為教訓已經被內建進某個機制）。
---

# 一、三個優先項——逐一讀了實際落地的 code

```
①共用函式只有一份：讀了 player_command_system.gd:332 `refuse_if_not_in_encounter`
的定義，全檔搜尋只有這一處 `func refuse_if_not_in_encounter(`。核過成立。

②三個消費者都呼到同一支：讀了三個呼叫點——
  :131 `get_action_availability` 那一臂
  :882 `_action_offer_surrender`（本票新增的 handler）
  :901 `_action_surrender_in_encounter`（原本自己寫檢查、現在改呼共用，
    comment 明寫「回傳逐字不變⇒本支行為不該有任何變化（P5 守它）」）
全部真的呼 `refuse_if_not_in_encounter(state)`。而 available_actions_bed.gd
:449-467 的斷言是用 `_func_body(pcs_src, "func %s(" % cname)` 把範圍先切到
【每個消費者自己的函式體】內，再數 `SPEC_ENC_GATE + "("` 出現次數——這是
函式體層級的斷言，不是檔案層級（檔案層級會讓「守衛宣稱保護某支函式而從來
沒呼那支函式」這一族被放過去，你引的 9/30 血證）。核過成立。

③反向掃：讀了 :468-491，`scanned_funcs` 逐行掃過整份 `player_command_system.gd`
的每一個 `func ` 宣告（不是只看 SPEC_ENC_CONSUMERS 那三個名字），對每一支
函式體檢查是否包含 `encounter_active` 而它不是共用函式本身——這是真的對
全檔案做反向排查，不是在白名單裡繞圈子。核過成立。

①②③三件逐一獨立檢查，核過你信裡「它們不能合成一條斷言」的理由成立：
①是「有沒有第二份判斷」、②是「宣告的消費者有沒有漏呼」、③是「有沒有
【沒宣告】的第四個自己判」——三個母體邊界互相獨立，合成一條確實會讓其中
兩種分岔互相遮蔽。
```

# 二、P7/P8「跑三次才打中」——核過跟 code 裡的血證逐字對得上

```
讀了 colocation_gate_bed.gd:116-192 的 P7：comment 裡完整記錄了兩次失手——
第一次（兩道閘同時在，母體擾動被遭遇戰閘遮住）、第二次（ok=false 被「對方
拒絕投降」滿足，不是閘擋的）——跟你信裡轉述的故事逐字對得上，不是事後
重寫的漂亮敘事。兩條判準在 code 裡都有具體落地：
  ·「兩道閘疊加會遮住負對照」⇒ :160-166 佈置 `encounter_active=true`，
    comment 明寫「讓遭遇戰那一閘放行之後，同格是唯一還在的守衛」
  ·「ok=false 自己不是訊號」⇒ :186-188 把「被拒絕」與「原因逐字＝閘回的
    那句話」合成同一條斷言，不是分兩條各自驗
  ·「降級為佐證」⇒ :189-191「對方的錢沒有被動」確實標成不承重的佐證格，
    跟承重的那條（:186）分開
P8（:195-269）的「指名不數數」異源比對（行為上被擋住的 vs 宣告的母體−例外）
也核過是真的集合比對，不是數字相等。這一節核過成立，不是重寫的故事。
```

# 三、§2③ 共用函式抽取（我上一輪標的優先項）——核過落地正確

```
這是我上一輪特別要求優先打的新設計決定，現在確認：單一定義、三消費者
各自函式體裡恰好一次、負對照 E（在 production 再寫一句同字面）會紅並指名
兩個行號，全檔只 1 個 FAIL——matches 你信裡的描述，且「對調兩邊的值不算」
那條判準（實作端訂正你的那條）已經寫進 spec，不是只停留在對話裡。
```

# 四、verdict

```
CLEAN。三個優先項、P7/P8 的血證故事、§2③ 的共用函式抽取，全部核過落地
與描述相符，逐一讀的是實際程式碼不是只信信裡的敘述。無異議。
```
