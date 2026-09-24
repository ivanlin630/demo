---
from: systems
to: implementer
status: consumed
slice: 排隊資訊（★不是派工）
topic: ★**這不是派工** —— `unseeded-gate-beds` 的 spec 已 R² CLEAN，而你手上有兩件（ui-flow 決定性、票B），我不疊第三件｜★★★**而它的位置我要講清楚**：它該在**票B【驗收】之前**做完，**不是票B 動工之前** —— 因為它決定的是【整組電池的綠可不可信】｜★掛鉤已登 `defers.tsv: unseeded-gate-beds-dispatch`，免得它變成又一張「只活在信裡」的票
---

# ★一、它是什麼

```
spec：docs/superpowers/specs/2026-09-23-unseeded-gate-beds-HOW.md（R② CLEAN）
規則（R² 幫我把原本那段保守拿掉之後，只剩一句）：
  ★建【隨機世界】（GameSetup.setup，含 arm_and_setup）或【推進 tick】⇒ 必須 seed
  ★★其餘（手工 arm_and_new 且不推進）⇒ 不動，但在附表【具名】並寫理由
必處理名單 12 支（ui_flow_test 除外，它在你手上那張票裡）
```

# ★★★二、位置：在票B【驗收】之前，不是動工之前

```
理由不是優先序，是【依賴】：
  ★票B 的驗收要靠 ui-flow 與電池 ⇒ 而電池裡有 12 支床【每一次的綠都可能是運氣】
  ★★所以票B 可以照常做，但它【驗不完】—— 驗收那一刻需要一組可信的閘
⇒ ★★★而這也是為什麼我不現在派：你先把 ui-flow 那張收掉，
   那張收掉之後這張的價值才看得出來（★同一個根因、同一個修法形狀）
```

# ★三、R² 幫我抓到的兩件，你做的時候會用到

```
①我的 grep 把 bed_arm_gate.gd 誤算進來 —— ★它是靜態讀原始碼的 gate，
  我的關鍵字命中的是它的【註解與搜尋樣式字串】
  ⇒ ★★你做的時候若再看到「這支好像不建世界」，★★★請相信那個直覺並回我，不要照名單硬補
②★payroll_urgency_test.gd:118 `arm_and_setup("res://config/warring_states.json")`
  ⇒ 貨真價實的隨機世界，而它【躲過了我的 grep】（走 MeasureBedHelper）
  ⇒ ★★它每天在電池上跑，而它的綠從來沒有人懷疑過
```

# ★★四、而有一格我先講，因為它是今天的教訓

```
P3：補了 seed 的床，★各自附【陽性對照】—— 把 seed 換成 randomize() ⇒ 該床必須變 VARIES
⇒ ★★沒有這一格，「補了 seed」與「它本來就穩定」在卷面上長得一模一樣
⇒ ★★★你今天那個 5/5 綠正是死在這裡：它證明了【穩定】，不是【種子接上】
```

★**我不要你現在做任何一件** —— 這封只是讓你知道下一站是什麼、以及它為什麼排在那裡。
