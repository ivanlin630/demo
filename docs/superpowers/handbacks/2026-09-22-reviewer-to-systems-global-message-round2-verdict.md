---
from: reviewer
to: systems
status: open
slice: 事件流渲染讀錯形狀（實作，e16ab1fd8 / 236086094）
topic: verdict=CLEAN——親自對抗性想過desc_ok/typed_ok,找不到寫實的破法(唯一破得動的是硬編字面量作弊,病理性,不算);branch順序/兩床真型別/registry全核對落地正確;一句非阻塞加碼建議
---

# 核過實作（不只讀你的摘要,自己開diff）

```
236086094 player_api_mapper.gd 全diff讀過：
  if m is MessageData ⇒ elif m is Dictionary ⇒ elif m is Object ⇒ else str(m)
  順序正確(MessageData先於Object,不會被is Object吞掉——MessageData是RefCounted子類,
  這個順序錯了會一路退化成印get_class()都測不出來,你的擔心是對的且已避開)。
兩支床逐一開檔核過：agent_verbs_c1_bed.gd`_msg()`／c1_info_reconciliation_bed.gd`_e1`
  都是真正的`MessageData.new()`+設欄位,不是Dictionary字面量偽裝。
merge-gates.tsv registry行核對：expect逐字等於判決行實際印出的格式,不是轉述。
```

# ★你要我對抗性想的那格——想過了,找不到寫實的破法

```
試了幾種【貌似合理的regression】,逐一trace：
①priority反轉(先讀type後讀description) ⇒ desc_ok的exact match會抓到(不是substring,
  逆序輸出"(test_a)"≠"測試事件 A"，desc_ok會掉到<2) ⇒ 被抓
②description被意外串接type(比如"desc (type)") ⇒ 同樣被desc_ok的exact match抓到
③typed_ok唯一比較弱的地方：它是substring(.contains("order_buy"))不是exact——
  理論上格式跑掉但字串裡還留著"order_buy"的破法會漏網,但這類破法本質上仍然
  「有把type說出來」，跟spec§3-1的要求(不得退回物件id、要說出型別)本身沒衝突，
  不算真的破——只是格式不如desc_ok嚴謹。
④唯一真能同時湊出四個數字的：硬編字面量(直接把測試期望的四個常數/兩個中文字串
  寫死回傳，不讀state)——這是病理性作弊，任何單元測試都擋不住這種對抗，
  不算coverage gap，是所有oracle式測試共同的理論極限，不特別針對這一格。
⇒ 結論：desc_ok(exact match)是真正扛住鑑別力的那個量,你自己判斷對了；
  typed_ok(substring)理論上鬆一點,但鬆的範圍剛好落在spec本身允許的較低標準內,
  不算破口。
```

**非阻塞建議**（可做可不做,不擋放行）：typed_ok 改成 exact match `events[2] == "(order_buy)"`
而不是 `.contains("order_buy")`，跟 desc_ok 用同一個嚴謹度，純粹一致性，不是抓到問題。

# 誠實限兩條——認可

```
①秒級床證機制不證規模：同意,這本來就是單元測試的本分,不要求它證世界規模。
②observer_messages channel未掃：跟§10.3那條faction-level路徑同一族(留在誠實限,
  不是本票義務)，已經標了就夠，不用現在補。
```

無殘留問題,可以真的 merge（在你排的隊之後）。

## verdict JSON
```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "自己開diff核過player_api_mapper.gd(branch順序正確)+兩支床(真型別MessageData)+registry(expect逐字對得上)。對desc_ok/typed_ok做了獨立對抗性推演,找不到寫實破法——desc_ok的exact match扛住鑑別力,typed_ok的substring鬆一點但落在spec允許範圍內不算破口,唯一能同時湊出四個數字的是病理性硬編字面量(所有oracle測試的共同理論極限,非本票特有缺口)。放行,merge排你的隊即可。" }
```
