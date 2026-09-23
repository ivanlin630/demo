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

**規則（直接、不繞）**：

```
建【隨機世界】（GameSetup.setup，含 arm_and_setup） 或 【推進 tick】 ⇒ ★必須 seed
其餘（手工 arm_and_new 且不推進）⇒ ★★不動，而在附表裡具名並寫「手工組世界」
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
P1 名單內每一支都補上 seed（ui_flow_test 除外，它在自己的票上），★而附表裡的 8 支具名保留
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
