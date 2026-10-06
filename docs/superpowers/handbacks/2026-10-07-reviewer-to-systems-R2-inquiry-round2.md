---
from: reviewer
to: systems
status: open
slice: 打聽：說了什麼就記下什麼，記下幾筆就說幾筆
topic: R② 第二輪（`e67c0b72d`）＝ **ISSUES，一列**｜I1＝CLEAN（搬共用的裁對）｜I2 停票報藍圖的方向對,但「灰掉帶原因」的落點沒人提——`_intel_options`(ask_food_source這層子選單)走的是跟外層action list完全不同的另一套,今天零一行支援enabled/disabled_reason,「顯示為不可選」字面上沒有地方可以落地
---

# 0 審了哪棵樹

`origin/main` ＝ `e67c0b72d`。

# 1 I1——CLEAN

```
逐字核對：「搬到message_data.gd當共用函式,3處都呼它,不寫第二套」
⇒ 跟我上輪要求的逐字對上(既有入口message_system.gd:325 _copy_message,搬遷+共讀)
```

# 2 I2——方向對（停票報藍圖），但「灰掉」這個動作本身沒有落點

## 證據：外層 action list 跟內層 inquiry 子選單是兩套完全不同的機制

```
外層（attack/trade/recruit/gather_intel這些頂層動作）：走available_actions那套,
  dict形狀含enabled/disabled_reason(available_actions_bed.gd/text_ui_layout_bed.gd示範)
  ⇒ gather_intel本身就是這套的SUBMENU_OPENERS成員(available_actions_controls.py:52),
    所以「要不要讓玩家打聽」這個頂層閘有enabled/disabled_reason機制可用
內層（進了打聽子選單之後,問哪一題：ask_food_source／ask_team_location／...）：
  走InquirySystem.get_options()——inquiry_system.gd:21-39回的dict只有
  {id,label,desc,relevance}四個鍵,★零enabled／disabled_reason
  text_ui_main.gd:127 `_intel_options`的宣告註解本身就只寫{"label":String}
  text_ui_main.gd:3118-3119渲染：`for i in range(_intel_options.size()): lines.append("[%d] %s"...)`
  ⇒ 均勻印每一項的label,沒有任何if分支去檢查「這項是不是disabled」
  選取：:3100-3101 `idx<_intel_options.size()`直接取`_intel_options[idx].get("id","")`送進
  _action_confirm_gather_intel,一樣沒有enabled檢查
```

## 這代表什麼

```
spec現在寫「ask_food_source在選題清單上顯示為不可選並帶原因」——這句話要成立,
  需要①get_options()替這個選項多塞enabled/disabled_reason②text_ui_main.gd的渲染迴圈
  學會讀這兩個鍵、印出不一樣的樣子③（可選）選取時再擋一次
現在的文字只提到「引擎的disabled_reason」這個欄位名,沒提這兩段要改——
  如果implementer只做「get_options()塞個欄位」,画面會長得跟今天一模一樣(渲染迴圈不讀它),
  P4驗「顯示為不可選」那一半會紅,但紅的理由不會是implementer的錯,是spec沒點出要改哪裡
```

## 處置

```
不是否決停票報藍圖那個決定（I2那半我同意,已經是WHAT層的事),是「灰掉」這個HOW動作本身
  缺一句明確指令——補一句：
  「text_ui_main.gd:3118-3119的渲染迴圈要新增disabled分支（印法仿available_actions那套既有
   label後綴/樣式的做法,不要另發明第三種「灰掉」的畫法）；_action_confirm_gather_intel要在
   resolve_inquiry/_exchange_intel之前先擋掉這個choice（仿既有ask_faction_status那個
   if choice_gi==...的特例分支,不是通用enabled機制也能做,比硬接available_actions那套簡單)」
不建議implementer自己猜要不要搬去用外層那套完整的enabled/disabled_reason機制——
  那是把一個簡單子選單升級成跟頂層同構,範圍比這張小票大,留HOW細節給你裁,我只標出
  「字面要求」跟「現有程式碼能不能做到」之間的落差
```

# 3 判決

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "ask_food_source灰掉帶原因,顯示為不可選",
     "file_line": "inquiry_system.gd:21-39(get_options回傳dict零enabled/disabled_reason鍵)；text_ui_main.gd:127,3118-3119(_intel_options渲染迴圈均勻印label,零disabled分支)",
     "truth": "『顯示為不可選』這句話今天在程式碼裡沒有地方可以落地——內層inquiry子選單跟外層action list(有enabled/disabled_reason機制)是兩套不同的渲染路徑,spec沒點名要改哪個檔哪個函式,implementer照字面做完P4驗收那一半(顯示)會紅"}
  ],
  "note": "I1 CLEAN。I2停票報藍圖的方向我同意,只差『灰掉』落點那一句話,補完就能派。" }
```
