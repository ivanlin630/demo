---
from: implementer
to: systems
status: consumed
slice: 第二母體（自家隊動作全列＋原因）＋兩屏鍵空間 —— 交件
topic: ★★★你要我補的那條母體地板【上一顆就已經加了】，逐字貼在 §3（不加重複的）｜★第二母體＋兩屏這一批全綠：ui_flow 76／76・available_actions 17／17・colocation 8／8・layout 10／10・press 5／5・unbound_key 8／8・headless HARD-FAILS 3＝baseline 3｜★★P33（宣告 vs 畫面）的負對照紅且指名「宣告 11／畫面 10」
---

# 一、遠端 tip ＝ `84c356ac5`（已推）

這一批（第二母體 §3①②③＋P6＋兩屏鍵空間＋P33）共 17 顆，全部在 `feat/text-ui-layout-v2` 上。

# 二、★★★你要我補的那條母體地板，上一顆就已經加了

```
scripts/debug/ui_flow_test.gd:2808 逐字：
	_check("★母體地板：第一頁裡至少有一列可做（0 ⇒ 本格測不到「做了一個動作」）", first_ok >= 0)
⇒ 它守的正是你點名的那個口：「全都不可做」時 `first_ok == -1` ⇒ 本格不可判而不是綠。
⇒ ★所以我**沒有再加一條**（不要一直加閘；而重複的地板會讓下一個人以為它們守不同的事）。
```

# 三、`cancel_move` 的 `listed` ⇒ `false`（照裁定）

```
·就地寫了理由（含「★不要改回 true」＋為什麼「畫面跟上宣告」被否決：它已經有專鍵）
·★併核 `move_to` 的 `listed` **本來就是 false** ⇒ 不是同一個病的第二處
·母體 11 → 10（實測，從床的輸出抄）
```

# 四、★★P33（新）＝ 你指出的結構缺口：那兩個數今天沒有任何一格在比

```
宣告側：`ACTION_SHAPE` 裡 `target=="none" and listed`           ⇒ 實測 10
畫面側：**從 `_screen_label.text` 數 `[n]` 那些列，並翻完所有頁** ⇒ 實測 10
  ★不用 `_interact_action_split()` 的回傳（同一條路上的中間值 ＝ 同源比較恆真，今天已栽過一次）
畫面側數到的十個 label（逐一印在卷面）：
  紮營（不可）／確認打聽（不可）／建立勢力／狩獵（不可）／獵猛獸（不可）／
  放棄戰利品（不可）／拔擢匿名→記名／收編敗者（不可）／收割戰利品（不可）／訓練（-30 coin）
負對照：`listed` 改回 `true` ⇒ 紅「宣告 11／畫面 10」，★全檔只這 1 個 FAIL（無連帶）
★誠實限就地寫：畫面側比的是**列數**不是逐名（畫面印 label、宣告存 id）
  ⇒ 失效方向「數字相同而成員不同」⇒ 指名那一半由 P16／P18 的反向掃守
```

# 五、數字（全綠）

```
ui_flow            76／76 errors 0（expect 75／75 → 76／76）｜ui_flow_test.gd 34（地板 34）
available_actions  17／17 errors 0（P18 三桶 28 ＋ 2 ＋ 1 ＝ 31；WHAT 殘餘物仍只有 confirm_trade）
colocation_gate     8／8  errors 0
text_ui_layout     10／10 errors 0
press_is_one_tick   5／5  errors 0
unbound_key         8／8  errors 0（異源比對 0 處不一致）
headless           HARD-FAILS 3 ＝ baseline 3（無回歸）
bed_parse_gate     494／494
```

# 六、下一站

退場票（`docs/superpowers/specs/2026-10-01-direct-trade-shortcut-retires-HOW.md`）。
★先 `git show origin/main:<spec>` 讀真本對帳；床的常數（54→53／51→50／30→29／第三桶 1→0／expect）**先跑再逐字抄**。
★★而那封 DISPATCH 我**留著 `open`** —— consumed 要等它真的做完。
