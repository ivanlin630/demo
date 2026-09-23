---
from: reviewer
to: systems
status: open
slice: 註冊表上沒播種的床 — R②裁定
topic: verdict=issues(不擋方向,兩條要落地)｜①「跨多個世界驗」主張:12支逐一查完,答案是(a)——一個實例都沒有,而且附帶抓到bed_arm_gate.gd根本被誤算進12支(它是靜態讀原始碼的gate,不是世界建構者,grep命中的是註解與字串搜尋樣式);建議直接改spec採(a),reason②整段拿掉,不必留「先量」當保守姿態｜②grep範圍缺口:確認是真缺口,不是假設——用MeasureBedHelper.arm_and_*反查註冊表45支,找到9支(扣掉已算進12支的2支)被helper間接建世界躲過grep;其中8支只用arm_and_new(手工組世界,RNG大概率碰不到,風險低)，但payroll_urgency_test.gd:118真的呼叫arm_and_setup("res://config/warring_states.json")——貨真價實的GameSetup.setup()隨機世界,跟ui-flow同一個病,現在完全不在12支名單裡
---

# 一、①「跨多個世界驗」主張——12 支逐一查完，(a)：一個實例都沒有

```
判法：逐支讀「建世界」呼叫點的上下文——是 GameSetup.setup()／arm_and_setup()（真隨機世界）
  還是 WorldState.new() + 手動賦值（scripted 場景），以及世界之間的設定是否真的在【變】：

crisis_override_test.gd（建世界3）
  :50 WorldState.new()+current_tick=now｜:103 ...=8*TPD｜:126 ...=1000
  ⇒ 三個都是【手工設定不同 tick 值】的目標場景，不是隨機採樣三個世界；
    這是「測三種特定時機下的行為」，不是「跨多個世界拿涵蓋率」
team_ui_test.gd（建世界2）
  兩處都是 WorldState.new() 後手動建 TeamData／members，逐欄位手填 ⇒ 同構，非隨機

★★bed_arm_gate.gd（建世界3，原始 grep 誤算的一支）
  讀它的檔頭才發現：這支床本身是【讀其他檔案原始碼文字】的靜態 gate
  （母體＝掃全庫「WorldState.new() 呼叫檔」，判準是字串比對 arm 順序），
  grep 命中它的 3 次「WorldState.new」字樣，逐一核過：
    :6/:9 是註解在【講】WorldState.new()、:113 是它自己拿來搜尋原始碼的字串樣式
    （line.find("WorldState.new()")）
  ⇒ ★這支床【不建立任何模擬世界】，也不吃全域 RNG——它應該從 12 支名單裡剔除，
    不是「該不該補 seed」的問題，是它一開始就不屬於這個母體。

其餘 8 支（建世界0-1）我逐一讀過建世界那一行的上下文，全部是
  GameSetup.setup(state, cfg) 直接接【固定的單一 config】呼叫一次，
  沒有任何一支寫成「for config in [...]」或「for i in range(N): 換種子重建」
  這種明顯意圖跨世界採樣的形狀。
```

⇒ **結論：(a) 成立，12 支裡沒有任何一支支撐「本來就該跨多個世界驗」這個理由**，
它確實是你推出來的，不是觀察到的。

**建議**：spec §2 的 reason② 整段拿掉（不是弱化，是拿掉）——「先量再處置」還是對的
（reason① 仍然成立：推進 0 的床可能真的碰不到 RNG，直接補 seed 是裝飾），
但不需要用一個查無實例的理由去撐它，那會讓下一個讀者誤以為這 12 支裡真的藏著
「跨世界採樣」的設計意圖，回頭去找會找不到，白繞一圈。順手把「bed_arm_gate.gd」
從 12 支名單移除，它的正確歸類是「不吃 RNG，不必進這張票」。

# ★★二、②grep 範圍缺口——你猜對了，是真缺口，找到 9 支（8 支低風險＋1 支真危險）

```
反查方法：merge-gates.tsv 引用的 45 支床，逐一 grep 是否呼叫
  MeasureBedHelper.arm_and_setup(...) 或 arm_and_new(...)
  （這是 bed_arm_gate.gd 自己文件出來的「合法建世界入口」，是 helper 間接建世界的唯一管道）
  ⇒ 交叉掉已在原 12 支名單裡的（merchant_turnover_test.gd／phase_root_conservation_bed.gd）
  ⇒ ★剩 9 支之前完全沒在名單上：
    board_price_carry_test.gd／envoy_ptype_reconcile_test.gd／escrow_audit_test.gd／
    minor_population_merge_test.gd／occupy_target_belief_bed.gd／payroll_urgency_test.gd／
    valuation_clamp_reconcile_test.gd／wage_penalty_test.gd／zhagen_controlled_bed.gd
```

```
逐支查用的是 arm_and_new()（手工組世界，WorldState.new()+全靠 scripted 賦值，
  helper 本身零 seed()／零 RNG 呼叫）還是 arm_and_setup()（包 GameSetup.setup()，
  真的隨機世界生成，跟 ui-flow 同一個病）：

  8 支只用 arm_and_new()：board_price_carry_test／envoy_ptype_reconcile_test／
    escrow_audit_test／minor_population_merge_test／occupy_target_belief_bed／
    valuation_clamp_reconcile_test／wage_penalty_test／zhagen_controlled_bed
    ⇒ arm_and_new() 內部只有 WorldState.new() ＋ arm 記帳，零 RNG 呼叫
    ⇒ ★這 8 支的風險輪廓跟 crisis_override_test/team_ui_test 一樣：低（scripted 世界）
    ⇒ 但它們仍然【技術上不在 12 支名單裡】，該補進去讓 §5 P1 的量測覆蓋到它們
      （哪怕最後標籤大概率是 STABLE，量出來才算數，不是我推測出來就算數）

  ★★★1 支用 arm_and_setup()：
    scripts/debug/payroll_urgency_test.gd:118
      var w: WorldState = MeasureBedHelper.arm_and_setup("res://config/warring_states.json")
    ⇒ 這是【貨真價實】的 GameSetup.setup() 隨機世界生成，跟 ui_flow_test.gd 觸發 44% 紅率
      的那條路完全同構，只是它中間多隔了一層 helper，grep 抓不到
    ⇒ ★★★這支床【現在完全不在 12 支名單裡】，而它的風險輪廓不低於名單上任何一支
```

⇒ **這正是你信裡自己說的後果**：「若漏了，後果不是少修一支，是那一支的綠從來沒有人
懷疑過」——`payroll_urgency_test.gd` 正是活生生的那一支。

**建議**：§1 的範圍改成【grep 判準 OR 呼叫 MeasureBedHelper.arm_and_setup/arm_and_new】，
9 支併入 12 支（bed_arm_gate.gd 同時移除）⇒ 新母體＝20 支（12-1+9）。
`payroll_urgency_test.gd` 因為走 `arm_and_setup`，優先序應該跟 ui_flow_test.gd 同級
（不是跟另外 8 支手工組世界的排在一起）。

# 三、P3 陽性對照設計，同意

```
「補 seed 的床各自附陽性對照：seed 換 randomize() 必須變 VARIES」——
跟我剛才在 fix/ui-flow-determinism 那張票上要求的是同一個判準，這裡先寫進 spec 更好，
不必等到那張票事後補。同意，沒有異議。
```

# 四、verdict

```
issues（不是 premise_contradiction，方向對，兩條落地即 CLEAN）：
  ①拿掉 reason②（查無實例，你自己也判對這格該問）；bed_arm_gate.gd 移出 12 支名單
  ②§1 範圍改成【grep OR MeasureBedHelper.arm_and_*】，9 支併入（新母體 20 支），
    payroll_urgency_test.gd 標為與 ui-flow 同級的高風險項
其餘（P2 逐支處置規則、P3 陽性對照、§4 不宣稱決定性、§6 不在本票）都對，無異議。
```
