# HOW spec：註冊表上【沒播種】的床 —— 先量，再逐支處置

owner: systems ｜ 2026-09-23 ｜ player_reachable: no
起點：`ui-flow` 被實測為 **9 跑紅 4（~44%）**，根因＝**Godot 每個行程開機時全域 RNG 是隨機的**
（implementer 實測：四個未 seed 行程 `randf` ＝ 0.336／0.970／0.761／0.207）。

---

## ★§1 範圍（★R② 2026-09-23 訂正過兩處，不是我原本 grep 出來的那一份）

```
起點：ui-flow 9 跑紅 4（~44%），根因＝Godot 每行程開機隨機播種
      （implementer 實測四個未 seed 行程 randf ＝ 0.336／0.970／0.761／0.207）
```

**R② 訂正①：`bed_arm_gate.gd` 被我【誤算】進來**

```
★它是【靜態讀原始碼】的 gate，不是世界建構者 —— 我的 grep 命中的是它的註解與搜尋樣式字串
⇒ ★★我的判準（grep 關鍵字）把【討論那件事的文字】當成【做那件事的程式】
   —— 那正是今天在簡體 lint／merge-gates 普查上出現過的同一個病
⇒ 移出名單
```

**R② 訂正②：grep 漏掉【經由 helper 建世界】的（★這是真缺口，不是假設）**

```
reviewer 用 MeasureBedHelper.arm_and_* 反查註冊表 45 支 ⇒ 找到 9 支躲過我的 grep
  ★其中 8 支只用 arm_and_new（手工組世界）⇒ 風險低，但【要具名】不是忽略
  ★★★而 payroll_urgency_test.gd:118 呼叫 arm_and_setup("res://config/warring_states.json")
     ＝ 貨真價實的 GameSetup.setup() 隨機世界 ⇒ 跟 ui-flow 同一個病
     ⇒ ★而它【完全不在我原本那份名單裡】
```

**修訂後的名單**：

```
必處理（建隨機世界 或 推進 tick）：
  agent_verbs_c1_bed.gd（建1 推3）｜ui_flow_test.gd（建1 推6，★已在自己的票上）
  merchant_turnover_test.gd（推1）｜phase_root_conservation_bed.gd（推1）
  crisis_override_test.gd（建3）｜team_ui_test.gd（建2）
  grudge_ledger_bed.gd／material_buy_test.gd／plan_speed_move_cost_test.gd
  ／ui_logic_test.gd／unified_commerce_test.gd（各建1）
  ★★payroll_urgency_test.gd（arm_and_setup ⇒ 隨機世界）★R② 新增
具名低風險（手工組世界，不建隨機世界、不推進）：★那 8 支 arm_and_new ——
  ⇒ ★★寫進本 spec 的附表即可，不動它們；★★★理由要寫「手工組世界」，不是「看起來沒事」
```

## ★★§2 規則（★R② 裁掉我原本的「先量再說」）

```
★我原本的理由②「有些床本來就該跨多個世界驗 ⇒ 釘死種子會縮小涵蓋率」
  ⇒ ★★R② 逐一查完 12 支：【一個實例都沒有】⇒ 我那段是【想像出來的保守】
  ⇒ ★★★整段拿掉。而我要記住的是：**我拿一個推論當成了設計約束，而它沒有母體。**
```

**★★★規則（2026-09-23 第二次訂正 —— 我上一版把它寫寬了）**：

```
★只有【推進 tick】的床需要 seed。★★【建世界】本身不需要。
```

**為什麼（★結構理由，reviewer 在另一張票上挖出來、我獨立核過）**：

```
game_setup.gd:57-58  var rng := RandomNumberGenerator.new(); rng.seed = int(config.get("seed", 42))
★world-gen 全部吃【這顆局部 rng】——我實測：
   game_setup.gd        bare rand ＝ 0 ｜ rng. ＝ 16
   world_generator.gd   bare rand ＝ 0 ｜ rng. ＝ 45
   person_generator.gd  bare rand ＝ 0 ｜ rng. ＝ 18
⇒ ★★建世界【結構上就是決定性的】（它只吃 config 的 seed:42）
⇒ ★★★腳本呼叫的 seed(1337) 餵的是【另一條流】：tick 推進時模擬系統用的那 72 處 bare randf/randi
   —— 兩條 RNG 流從頭到尾不相交
```

⇒ **所以我上一版那條「建隨機世界 ⇒ 必須 seed」是【錯的】**，而它的代價很具體：
★**會讓 7 支不推進的床各補一個不會有任何作用的 seed**，
★★**而那 7 個裝飾會讓下一個人以為「這些床已經被處理過了」。**

**修訂後的名單（★必處理只剩 3 支，ui_flow_test 在自己的票上）**：

```
必處理（推進 tick）：
  agent_verbs_c1_bed.gd（推3）｜merchant_turnover_test.gd（推1）｜phase_root_conservation_bed.gd（推1）
  ＋ ui_flow_test.gd（推6）★已在 fix/ui-flow-determinism
不處理（推進 0 ⇒ 只建世界 ⇒ 已由 config seed 決定）：★而要【具名並寫理由】，不是靜默略過
  payroll_urgency_test.gd（arm_and_setup 但推進 0）｜crisis_override_test.gd｜team_ui_test.gd
  ｜grudge_ledger_bed.gd｜material_buy_test.gd｜plan_speed_move_cost_test.gd
  ｜ui_logic_test.gd｜unified_commerce_test.gd
  ＋ R② 反查到的 8 支 arm_and_new
```

## ★★★§2b 判準【不能只靠靜態】—— R② 第三次戳破我的範圍（2026-09-23）

```
我的範圍判準演化了三次，而【每一次都是別人戳破的】：
  v1「有沒有 seed(」            ⇒ 漏掉經由 MeasureBedHelper.arm_and_* 建世界的（R② 抓）
  v2「建世界 或 推進 tick」      ⇒ 把 bed_arm_gate 誤算進來（它是靜態讀原始碼的 gate）（R② 抓）
  v3「只看推進 tick」            ⇒ ★★★漏掉【不建世界、不推進，但【直接呼叫模擬函式】】的床
```

**v3 的漏網（R② 找到）**：

```
zhagen_controlled_bed.gd ⇒ 呼叫 `_decide_unified`（faction_ai_system.gd:3486，510 行的統一決策 dispatcher）
★它本體逐行 grep ＝ 0 命中 randf/randi
★★但它是 dispatcher：往下呼叫一批評分／人格加權 helper，
   而 docs/invariants.md:63 明寫「人格加權機率決策＝…seeded」
⇒ ★★★那條 RNG 路徑在不在 510 行以外的 call graph 裡，R② 沒有窮盡追完 —— 而我也不要求他追
```

**⇒ 所以本票的判準改成兩層（★這是本節的結論）**：

```
①靜態層（便宜，用來【縮小】範圍）：推進 tick ⇒ 必補
②★★★經驗層（用來【兜底】）：凡是【執行任何模擬 code】的床，都跑 5 次逐位元比對
   ⇒ VARIES ⇒ 補 seed；STABLE ⇒ 在檔頭寫「5 跑逐位元相同（日期）」
   ⇒ ★而 zhagen_controlled_bed 歸這一層，【不預先判它零風險】
★★為什麼不追那個 call graph：追得完也只是「今天沒有」，
   ★★★而【有人日後在那 510 行底下加一個 randf】不會有任何東西叫紅 —— 經驗層才會。
```

## §3 形狀

```
seed 的寫法抄 warring_harness.gd:120／observer_main.gd:51（同一個前例）
★放在【建世界之前】；★★種子值寫成常數並印出來（★★★印【變數】不是印字面值
  —— 今天已經有三次「拿字面值當目標」的血證）
```

## ★§4 這張票【不宣稱】的

```
★補了 seed ＝【每次同一個世界】，不等於【那個世界是對的】
⇒ ★★它換來的是【可重現】：紅了能重現、綠了不是運氣
⇒ ★★★而「它驗的那件事對不對」不歸本票 —— 本票只讓答案穩定下來
```

## §5 驗收

```
P1 ★那 3 支推進 tick 的床補 seed；★★zhagen_controlled_bed.gd 走經驗層（5 跑）再定案；
   ★★★其餘【逐支具名】並寫「推進 0、且呼叫的具體函式零 bare RNG（R² 逐支核過）」
P2 每一支的 seed 值【印在它自己的輸出裡】（★下一個人看得到它跑的是哪個世界）
P3 補了 seed 的那幾支：★各自附【陽性對照】—— 把 seed 換成 randomize() ⇒ 該床必須變 VARIES
   ⇒ ★★沒有這一格，「補了 seed」與「它本來就穩定」在卷面上長得一樣
P4 全電池綠（★本票只動 scripts/debug/，零 production）
```

## ★§6 不在本票

```
✘ ui_flow_test（它有自己的分支 fix/ui-flow-determinism）
✘ 那 224 支【不在註冊表上】的床 —— ★它們沒有人在看，補了也沒有消費者
  ⇒ ★★真要處理它們，門票是「它被註冊進電池的那一天」，不是現在
✘ 幫 Godot 的隨機播種行為加任何全域設定（★那會改變所有床的既有行為，代價不明）
```
