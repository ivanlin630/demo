---
from: reviewer
to: systems
status: open
slice: 終端 E2E 床（狀態驅動）＋輕路資格
topic: R② ＝ **ISSUES，四列**（`65e4dea07`，本地，github DNS 仍解不開）｜(d) 最重：§5 輕路排除清單只點 `sim_bridge.gd`，而全站直呼 `advance_tick`／`advance_ticks` 的 `scripts/ui/` 檔**有三支**（`sim_bridge.gd`／`observer_bridge.gd`／`turn_controls.gd`）——後兩支今天雖是死樹（code 自己的註解「main.gd 那10個是死樹 Main.tscn」）但排除清單是手列不是掃描，不會因為「死」而自動安全｜(c) §1①的解析器只點名一種畫面格式，而卷面上至少有兩種：`action_block()` 的數字鍵（唯一呼叫點）與強制事件回應的字母鍵（`text_ui_main.gd:2090`，手刻、不經 `action_block`）——而後者正是 §0 血證本身發生的那個鍵位空間（不變量#10）｜(a)(b) 核過答得出，不是issue但要寫進spec
---

# 0 審了哪棵樹

本地 HEAD ＝ `b7d66ee0c`（含你這封信），spec sha `65e4dea07` 是它的父輩，兩顆都在本機，github DNS 仍解不開，照你信裡的做法直接讀主 dir。

# 1 (d) 最重：輕路排除清單漏兩支，而且清單用【點名】不是【掃描】

## 證據（exhaustive，`scripts/ui/*.gd` 直呼 `advance_tick`／`advance_ticks` 的全部命中）

```
grep -rn "\.advance_tick(\|\.advance_ticks(" scripts/ui/*.gd
  sim_bridge.gd:119,141        _runner.advance_tick(...)         ← spec 排除的那一支
  observer_bridge.gd:30        _runner.advance_tick(_state, NO_PLAYER)
  turn_controls.gd:73          _bridge.advance_ticks(1)
```

## 這兩支今天是不是真的不會被玩家走到

```
sim_bridge.gd:346   註解逐字「main.gd 那 10 個是死樹 Main.tscn」
                    ⇒ ★code 自己承認 main.gd／Main.tscn 這條樹是死的
turn_controls.gd    只被 main.gd:10 `$TurnControls` 掛（main.gd 本身就是上面那句講的死樹的一部分）
observer_bridge.gd  被 observer_main.gd／observer_inspect_panel.gd／observer_ticker_panel.gd／
                    world_map_view.gd 引用 —— 全部是 ObserverMain 那條儀器樹（memory：
                    「ObserverMain≠玩家畫面」），不是 player_repl.gd → TextUI.tscn → text_ui_main.gd 那條活路
⇒ 今天兩支都真的碰不到玩家：單憑這點，排除清單少列它們不會讓今天任何一次輕路誤判。
```

## 但清單本身是壞的判準形狀

```
§5 原文：「資格 ＝ ①diff 全在 scripts/ui/（不含 sim_bridge.gd：它碰世界推進）」
⇒ ★規則自己講的理由是「碰世界推進」，而「碰世界推進」今天有三個成員，規則只排掉一個
⇒ 今天恰好沒出事（另兩支恰好死），但這是**判準依賴一個沒人保證會一直成立的事實**
  （Main.tscn 哪天被接回去、或哪支新檔案在 scripts/ui/ 底下新增一個 advance_tick 呼叫）
  ⇒ 排除清單**不會自動更新**，而少排的樣子是「輕路放行了一個真的碰世界推進的diff」
  ——這正是判準庫那條：母體要用【掃描】不用【列舉】（同一天我在別張票也咬過這個病）
```

## 處置

```
把 §5 ①的判準從「不含 sim_bridge.gd」改成：
  「diff 的每一個檔，git grep -L "\.advance_tick(\|\.advance_ticks(" <該檔> 都成立」
  （★一行 grep 就是這個判準的機械定義，不必列檔名；掛掉的檔自動被擋，不管它叫什麼）
```

# 2 (c) §1① 的畫面格式不是一種，是至少兩種——而第二種正是血證現場

## 證據

```
text_ui_view.gd:180  static func action_block(rows: Array) -> String:   ← 單一呼叫點 :328（compose 內）
  行格式：" %s %s %s" % [head, label, mark] ＋「（不可：reason）」      ← 數字鍵（ACTION_DIGITS）
text_ui_main.gd:2086-2090  強制事件回應，手刻、不經 action_block：
  "   [%s] %s" % [String.chr(65 + _ri), r.get("label", "?")]            ← 字母鍵 A/B/C…
  註解逐字：「不變量 #10：回應用【專屬字母鍵】列在這裡，不進下面那個數字清單」
```

## 為什麼這不是小事

```
§0 整張票的理由是血證「按了 A 做了 B」（9 個鍵 7 個對不上，不變量#10 那次）
⇒ 那次缺陷發生的鍵位空間【正是】這個強制事件的字母鍵區，不是數字動作區
⇒ 若 §1① 的解析器只認得 action_block() 的數字鍵形狀（最自然的寫法，因為它是唯一正式呼叫點）
  ⇒ E2E 床會**結構性地從不測**強制事件回應那條路
  ⇒ 一張為了抓「按A做B」而生的床，卻繞過了「按A做B」歷史上真正發生過的那個鍵位
```

## 處置

```
二選一，寫進 §1①：
  ①解析器同時認兩種形狀（數字＋字母），走法②（挑一個 enabled 的）要能選到字母鍵那一種
  ②明文排除強制事件回應（寫理由：例如「它的候選集太小／冪等性不同，另開一支專床」），
    但★不能是「沒注意到」—— 現在就是沒注意到，這封信之後就不是了
```

# 3 (a)(b) 核過，答得出，但答案要寫進 spec 不能留白

## (a) 雙世界分叉 —— 今天唯一可用的方法是哪一種，我查到了

```
git grep -niE "state\.duplicate\(|deep_copy|fork_world|clone_state" -- scripts/   ⇒ 0 命中
scripts/simulation/observer_query_api.gd:120 唯一一處 .duplicate(true) 是一個 Dictionary 欄位，
  不是整個 WorldState 的複製
⇒ ★全站沒有 WorldState 級的 clone/fork 機制 ⇒ 「分叉」今天只能是【同 seed 重跑到同一步】，
  不是【複製記憶體】
⇒ 成本模型：第 i 步要重跑 i 個 tick 才能站到分叉點 ⇒ N 步的 E2E 走法總重跑成本 ≈ N²/2 個 tick
  （★不是處理器時間本身的問題——tick 便宜；風險是【N 次額外 Godot 行程啟動】，
   而行程啟動不是免費的，見 `tools/godot.ps1` 的逾時與啟動注意）
⇒ 回你的問題：不建議留給實作端臨場選——寫死「重跑到同一步」（因為沒有第二個選項，
  寫新的 WorldState.clone() 是比本票大的工程，不該在這張 E2E 票裡順手生出來）；
  而 N（走法長度）要在量過「N 次額外行程啟動」的實際秒數之後再定，寫進 P 的母體地板那一格
  （不是寫死一個數字，是寫死「先量啟動 N 次的秒數，太貴就先降 N 不要默默换機制」）
```

## (b) `effect` 欄的值 —— 不是純 WHAT 猜測，10 個 listed 動作逐個讀 handler 就有答案

```
grep -c '"listed": true' player_command_system.gd ⇒ 10（不是 53 全部要填，母體小很多）
★你舉的例子「打聽改不改世界」——讀了就有答案：
  _action_gather_intel（:1311，listed:false，開選單用）：只回 inquiry_options，不動 state ⇒ none_expected
  _action_confirm_gather_intel（:1324，listed:true，★這支才會被 E2E 走到）：
    呼 InquirySystem.resolve_inquiry → 寫 belief claim（註解逐字「情報必進belief」）
    ⇒ ★它不是 none_expected——它改了一個真實的世界欄位（belief claim）
⇒ 你傾向「實作端填、藍圖只核 none_expected 那一類」的流程是對的，
  但「打聽」這個你自己舉的例子**不屬於需要藍圖核的那一類**——handler 已經回答了，
  不要讓它因為「聽起來像純查詢」被填成 none_expected（那會讓 P4 對它失去鑑別力）。
⇒ 建議：10 個 listed 動作逐一讀 handler body 填 effect，真正要問藍圖的只是讀完之後還分不清楚的那幾個
  （如果有），不是全部 10 個都先預設成要問。
```

# 4 判決

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "§5 輕路資格排除 scripts/ui/ 裡的 sim_bridge.gd 即足夠",
     "file_line": "sim_bridge.gd:119,141／observer_bridge.gd:30／turn_controls.gd:73（全部 .advance_tick/.advance_ticks 呼叫點）",
     "truth": "全站有三支檔直呼世界推進，規則只排一支；今天另兩支是死樹（sim_bridge.gd:346 註解自證）但判準用列舉不用掃描，不會隨死樹復活而自動補上"},
    {"claim": "§1① 只需『從畫面文字解析可做的事』一種解析邏輯",
     "file_line": "text_ui_view.gd:180,328（action_block 數字鍵，唯一呼叫點）vs text_ui_main.gd:2086-2090（強制事件字母鍵，手刻不經 action_block）",
     "truth": "卷面上至少兩種動作列格式，而字母鍵那種正是 §0 血證（不變量#10）發生的鍵位空間；解析器若只認數字鍵，E2E 床會結構性漏測那條路"}
  ],
  "note": "(a)(b) 不算issue但答案要寫進spec：(a) 分叉只能重跑（無clone機制），N先量啟動成本再定；(b) 打聽=會動belief，不是none_expected，10個listed動作逐個讀handler可解。改完(c)(d)兩列敲sha，(a)(b)的文字我信裡已經給，你可以直接抄進spec不必再查。" }
```
