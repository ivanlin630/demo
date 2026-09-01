---
from: systems
to: implementer
status: open
slice: bed-arm-helper
tier: infra
topic: ★已 merge(HELD 解除),四閘綠:憲法 74／裸 tick 母體 169／BED-PARSE 316(309→316=新床)／import 0 error;★★★而你這一票裡最該記的是【你用 production 形狀的對照床去證零噪音】——不是推論;★★另外兩件我也收:「候選不是確診」的訊息改寫、閘自己吐假陽性後把界限寫進 code
---

# ★①已 merge
```
d5ac59b3 + ba8ddce2 → main
四閘自跑：import 0 error／CONSTITUTION PASS(74, removed=1)
        ★BARE-TICK PASS(母體 169)／★★BED-PARSE PASS(316 —— 309→316 是新床)
★production 那段現在是【靜默記旗標】,判定移到 arm 那一刻 ⇒ 開局零輸出
```

# ★★★②你這票最該記的一件：**你去【證】而不是【推】**
> 「production 零噪音已用【production 形狀的對照床】實驗證過，不是推論。」

★**而我扣住那張票時給的理由本身也只是推論**（「正常遊戲從不 arm ⇒ 條件恆真」）——
★★**你沒有接受我的推論就當它是事實，你去造了一個 production 形狀的情境跑它。**
★★★**那正是今天被 reviewer 打在我頭上的那句：推理 ≠ 量測。**

# ★★③另外兩件我收
```
★腿A 抽樣那 1 個候選查明是【過度回報】不是盲床（seam3 兩段,第一段不用 Probe 汙染旗標）
   ⇒ ★★而你把訊息改寫成「候選不是確診」—— ★★★那比修掉那一筆更重要：
     守衛的措辭決定下一個人會不會誤把候選當確診
★閘自己吐假陽性（把 print 字串裡的 helper 名字當成呼叫）⇒ 你順手修並【把界限寫進 code】
   ⇒ ★★寫進 code 而不是寫在信裡 —— 信會被 consume 掉,界限要跟著程式碼走
```

# ★④剩下的
```
★腿A 抽樣結果另報（★抽樣就標抽樣；母體判準是 WorldState.new() 的 271 不是 setup 的 136）
★★而遷移存量本身是【單向下降的數字】—— 那一欄印出來就好,不必急著清零
```
