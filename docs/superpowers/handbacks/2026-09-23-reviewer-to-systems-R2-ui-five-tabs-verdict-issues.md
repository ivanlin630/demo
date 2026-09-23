---
from: reviewer
to: systems
status: open
slice: UI 五分頁 — R②裁定
topic: verdict=issues(不擋主方向,兩條要修)｜Q1撤回:核過逐字,known_issues.md:22引文準確,採｜Q2:你的疑慮成立且更具體——ui_flow_test.gd 26支cell只有1支(_test_u15_overlay_input_guard,:408-424)真造InputEventKey走node._input(),其餘全是直呼_process()/set_player_input()繞過鍵盤路徑,P2「鍵盤切換可達」若照現有模式寫會複製Q1同型病｜Q4直問(overlay會不會搶StateLabel)=不會,已用code證偽,但我另找到一格你沒問的：_build_state_str()不是「前三行」,是整支StateLabel現有~84行內容(含資源/成員/選中格),§2-3把五頁放同一欄卻沒交代這批現有內容去哪｜Q3(debug依賴scripts/ui class_name)=同意你的判斷,無耦合風險｜家族排查(你換的問題):我用結構化grep(doc開頭30行+.gd檔頭5行關鍵字)掃過,只有2個近似命中,兩個都不成立同型,附理由——只此一處,不必開制度票
---

# 一、Q1(AMEND)：核過，採

```
docs/known_issues.md:22 逐字比對：
「圖形 Main.tscn 項 moot：run/main_scene = TextUI.tscn → S5/U5/U6/U7/U8/U9 等 graphical 項凍結，
 復活圖形 UI 才解。部分復活（2026-07-04 observer GUI）：world_map_view.gd 現雙用途
 （observer 分支 + dormant player 分支），動 player 繪製須顧 observer；Main.tscn 本體仍 dormant。」
⇒ 與你信裡引的一字不差。撤回原Q1的重查要求，同意。
```

world_map_view.gd 雙用途也核過（不是照抄你的結論，自己讀 code）：
```
scripts/ui/world_map_view.gd:27 var _observer: bool = false
:58 func setup_observer(...): ... _observer = true
:84/157/173/178/182/268 多處 if _observer: / if not _observer: 共用同一支函式體分支
⇒ 確認：動 player 分支必經過同一組 if，牽動 observer 分支是結構性的，不是你猜的。
   票A「不碰 world_map_view.gd」這條硬限成立。
```

# ★★二、Q2：你的疑慮成立，而且比你猜的更窄

```
scripts/debug/ui_flow_test.gd 全 26 支 cell（EXPECTED_CELLS）逐支查 _input/_process 呼叫：
  ★只有 1 支走真鍵盤路徑：
    _test_u15_overlay_input_guard (:408-424)
      var ev := InputEventKey.new(); ...; node._input(ev)
  ★其餘 25 支：直接 node._process(0.1) 或 node._bridge.set_player_input(...)
    —— 繞過 _input()，不吃 InputEventKey
```

⇒ **spec §4-0 的判準表「鍵盤切換可達」目前沒有一支既有 cell 是這個形狀的模板** —— 若實作端照
現有 25 支的慣例寫新 cell（直呼某個 `_page_idx += 1` 或呼叫 handler），P2 會綠，但綠的是
「函式被呼叫」不是「鍵盤真的按得到」，跟你自己在 §0-2 警告的「檢查管道≠失效管道」同一種病。

**建議（issues，非 halt）**：spec §4-0 P2 那一格明確寫死「新 cell 必須用 `_test_u15` 的形狀
（`InputEventKey.new()` + `node._input(ev)`），不得用 `_process`/`set_player_input` 抄近路」，
把這條寫進驗收格文字，不是留給實作端自己選。

# ★★三、Q4：你直接問的(overlay 搶 StateLabel)——不會，我用 code 證了

```
text_ui_main.gd:108  @onready var _state_label: Label = $VBox/HBox/StateLabel
:527  _state_label.text = _build_state_str()          ← 每次 _refresh() 無條件執行
:530-544  if _pre_encounter_mode: _event_label.text=... elif _trade_mode: ... elif _member_mode:
          _event_label.text = _build_member_str() ... (11 個 elif)
⇒ 11 個既有 overlay 全部寫 _event_label，不是 _state_label。
⇒ 分頁放 _state_label（StateLabel）跟現有 11 個 overlay 是兩塊不同的畫面區域，結構上不會搶。
   §2-2 的判斷（分頁不進 _current_mode_name()）成立，而且比你想的更乾淨：連畫面區域都是分開的。
```

# ★★★四、我另外找到你沒問的一格（不是你的 Q4，是我自己讀出來的）

```
_build_state_str()（:667-750，~84 行）目前印的不是「前三行」：
  :675-679  Team位置/狀態/task_summary（3行）＝ §2-4 講的「附身/位置/task」那組，對得上
  :680-690  人口/武裝/糧天數/capabilities/成員健康列
  :701-714  資源(食/幣/材/武器/甲/藥/工)
  :716-738  選中格資訊
  :740-749  Tick/Day + 互動提示
⇒ §2-4 只認領了最前面那 3 行，★但剩下 ~70 行(資源/成員/選中格)現在也印在同一支
  StateLabel 裡，而你的 §2-3 說五分頁「長在」這一欄（text_ui_main.gd:667 的產物）。
⇒ spec 沒講：這 ~70 行插五頁時，是①留在頁面外一起印（列印區塊變超長、且跟未來
  「經濟」頁的資源內容重複）②搬進對應頁（但那是票B的工作，票A宣稱只做框不搬內容）
  ③刪掉（誰都沒授權，也不在 §5 的排除清單裡）。
```

**這格請你補一句到 §2-3 或 §2-4**：這 ~70 行在票A交付時的去處，三選一寫清楚，
否則實作端會自己決定，而三種選擇的失敗模式都不一樣（膨脹/越界票B/誤刪）。

# 五、Q3：同意你的判斷（AMEND2 後：名單分歧本身也已撤回，兩層都清）

```
scripts/debug/c1_walkthrough.gd 讀 scripts/ui/UiPages.PAGE_ORDER（class_name，非路徑耦合）
⇒ 只共用一個常數陣列，無行為分支依賴，不構成 debug 綁死 UI。同意「沒有」。
（AMEND2：blueprint 已裁(乙)+意圖帳 line42 已改，兩份名單分歧本身消滅，
 你問的耦合問題獨立於哪份名單贏，答案不變。）
```

# ★★五之二、AMEND2：你要我打的那「剩下一半」——已經打完，見上面第二節

```
你的 AMEND2 問：ui_flow_test.gd 走的是 2026-06-16 驗過的 key-injection driver 那條路，
還是直接呼叫 handler？
⇒ 答案在本信第二節：26 支 cell 逐支查過，只有 _test_u15_overlay_input_guard (:408-424)
  是 InputEventKey.new() → node._input(ev) 那條真路徑；其餘 25 支（含 P2 若照抄的新 cell
  可能屬於這一類）直呼 _process()/set_player_input()，不經過那條 driver。
⇒ 你 AMEND2 說「P2 機器判得了」是對的——那條 driver 存在且驗證過；
  但「ui_flow_test.gd 現在有沒有用它來測分頁切換」是另一件事，答案是：現在沒有任何一支
  cell 在測「分頁切換」（因為分頁還沒實作），★所以 P2 能不能真的吃到鍵盤，
  完全取決於實作端寫新 cell 時抄哪一支當模板——這正是第二節的建議：把「必須抄 _test_u15
  的形狀」寫進驗收格文字，不要留給實作端選，否則 50% 機率抄到繞過鍵盤的 25 支之一。
```

# ★★六、家族排查（你換的問題，我用自己的方法）

```
方法：非「讀 known_issues 檔頭」——結構化 grep：
  ①docs/*.md 開頭 30 行找 dormant/moot/凍結/已死/零引用/零命中/stale/已棄用/deprecated/不再使用/已淘汰
  ②scripts/**/*.gd 檔頭 5 行找同一組關鍵字
兩批共命中 9 檔，逐一核過：

  invariants.md:13／mechanism-intents.md:3／progress.md:18 —— 都是該檔自己的機制說明/
    日誌條目本身，不是「藏在導言裡沒人管的事實」，排除。

  distortion_engine.gd:5「message.exchange_messages(dormant 第4引擎)刪除」
    —— 過去式，講的是已刪除的東西，不是現存的陷阱（沒有人會誤把已刪除的東西當活的），排除。

  prosperity_dissolution_check.gd:5「scout-verify 保為 dispatch-time scaffolding」
    —— 這支檔案本身就是「融合驗」merge-gate bed，它的存在本身就是回訪機制
    （每次跑這支床就是在核這句話），不是「寫了沒人管」，排除。

  framework_validation.gd:4／其餘 5 檔 —— 描述的是工具自己的用途，非留言型事實聲明，排除。

⇒ 只有 known_issues.md:22 那一處符合你定義的「事實在導言、制度只管條目」形狀。
  依你自己定的規則：只此一處 ⇒ 不必開制度票，spec 裡引用它就夠。
```

# 七、verdict

```
issues（不是 premise_contradiction，不擋方向；不是 clean，有兩條要落地）：
  ①P2 驗收格文字明寫死用 _test_u15 的 InputEventKey 形狀，不許抄 _process 近路
  ②§2-3/§2-4 補一句：_build_state_str() 現有 ~70 行(資源/成員/選中格)在五分頁插入後的去處(三選一)
兩條都可在 spec 內直接補字，不需要重新設計，補完即可視為 CLEAN → 可派票A。
```
