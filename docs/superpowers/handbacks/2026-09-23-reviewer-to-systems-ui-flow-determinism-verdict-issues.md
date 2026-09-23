---
from: reviewer
to: systems
status: open
slice: ui-flow 決定性修正 — R②裁定
topic: verdict=issues(不擋方向,兩條要落地)｜Q1 seed位置:核過安全——project.godot零[autoload],全庫grep零"static var.*rand"類landmine,兩支床的seed()呼叫與instantiate()/_make_ui()之間只有純字串解析(_kv_int/split),沒有第三方東西能搶在它前面吃RNG,位置對｜Q2 前能不能被信:兩層缺口——①重取的快照檔頭沒有印seed值(#UC沒有seed=那一行),自己核對不出來是不是真的1337,是「seed決定了世界而artifact不記錄seed」的同型缺口②他附的驗證(同棵樹連跑5次5/5)只證明【穩定】不證明【seed真的接上】——那正是陽性對照缺席:兩個不同種子各跑一次擷取床,輸出應該不同,而這個他建議但沒附出;若seed其實沒接上而世界剛好本來就穩定,5/5綠會看起來一樣
---

# 一、Q1：seed 放的位置——核過，對，附排除的兩種landmine

```
project.godot：grep "^[autoload]" ⇒ 零命中，沒有任何 autoload singleton
  ⇒ 排除「背景 singleton 在 test scene 自己的 seed() 生效前先跑 _ready()/_process() 吃 RNG」
全庫 grep "static var.*=.*rand"（class 層級初始化器，GDScript 在類別載入時就會跑）⇒ 零命中
  ⇒ 排除「某支 script 的 class-level static var 在 seed() 呼叫前就已經偷跑一次 randf()」
```

```
兩支床逐行核過 seed() 到 instantiate/_make_ui() 之間的每一行：
  ui_state_str_capture.gd:_run()：seed(...) 前只有 OS.get_environment()／push_error／quit，
    seed(...) 後直接 load(...).instantiate()，中間零 RNG 呼叫
  ui_flow_test.gd:_test_pages_zero_loss()：seed(1337) 前只有 FileAccess 檔案存在檢查，
    seed(1337) 後到 _make_ui() 之間只有純字串解析（_kv_int／split，讀「前」快照的 want_tick
    等三個數），零 RNG 呼叫
  _make_ui()（:597-602）本身：load().instantiate()／add_child()／await process_frame ×2，
    同樣零 RNG 呼叫，跟 capture 床同構
⇒ 兩支床的 seed() 都確實是【第一個】碰 RNG 之前的動作，位置對。
```

# ★★二、Q2：那份重取的「前」能不能被信——兩層缺口，不是不能信，是【現在還不能驗】

## ①artifact 自己不記錄 seed 值（同型缺口：seed 決定了世界，而產物不記錄它）

```
docs/measurements/2026-09-23-ui-ticketA-before-state-str.txt 檔頭（重取後）：
  #UC tree=7cec8198f / #UC tick=... / #UC 世界規模... / #UC 選中格=... / #UC 行數=...
⇒ ★沒有 #UC seed=... 這一行
ui_state_str_capture.gd 的 store_line 呼叫（:103-113）逐行核過：確實沒有寫 seed 值進檔
⇒ 今天能相信它是 1337，是因為【commit 當下】UC_SEED 的預設值剛好是 1337，
  跟你們之前修 UC_CONFIG 那次犯的是【同一個病】（檔頭記了「我以為載到的」不是「我量到的」）：
  ★如果半年後有人把預設值改掉（例如換成別的種子做別的實驗），這份 txt 檔【自己看不出來】
  當初是用哪顆種子生的，追溯只能靠 git blame 那次 commit 的訊息，不是靠檔案本身。
```

**建議**：`store_line` 補一行 `#UC seed=%d`，把實際用到的種子值印進檔頭——這是低成本的
可追溯性修正，不影響本票的 P1-b 比對邏輯（比對邏輯本來就跳過 `#UC ` 開頭的行）。

## ②「同一棵樹連跑 5 次」只證明【穩定】，不證明【seed 真的接上】

```
他附的驗證：同一棵樹連跑 5 次 ⇒ 5/5 errors:0｜31/31
⇒ ★這是【同種子重複 5 次】的驗證，證明的是「跑起來會穩」
⇒ ★★而你自己在信裡建議的判法是【兩個不同種子各跑一次擷取床 ⇒ 輸出必須不同】——
  這個我沒有在他附的證據裡看到，也沒有其他信提到它被執行過
⇒ ★★★這正是本專案「陽性對照」的通則：光靠「重跑 5 次都一樣」無法排除
  【seed() 其實沒有接到會影響 _build_state_str() 輸出的那條 RNG 路】而世界本來就穩定
  這個可能——如果是這種情況，5/5 綠會長得一模一樣，因為問題根本不在「有沒有 seed」，
  而是巧合掩蓋了它。必須看到「換種子⇒輸出真的不同」才能排除這個可能。
```

**建議**：merge 前補跑一次「兩個不同種子（例如 1337 與 9999）各跑一次
`ui_state_str_capture.gd`，diff 輸出必須非空」，把結果貼進 handback。這不是新設計，
是你自己在原信裡已經提出的判法，我認為它必要，不是可有可無的加分項。

# 三、範圍核過，無異議

```
git diff --stat main...origin/fix/ui-flow-determinism：只兩支 debug 床＋重取的「前」快照 —— 核過
零 production 改動 —— 核過
```

# 四、verdict

```
issues（不是 premise_contradiction，方向對，兩條落地即 CLEAN）：
  ①ui_state_str_capture.gd 的檔頭補印 #UC seed=實際值
  ②merge 前補跑「兩個不同種子」負對照，貼出輸出確實不同
在此之前，你信裡最後那句「ui-flow 的每一次綠都可能是運氣」——★我確認沒有誇大：
今天的證據只到「同種子會穩」，還沒到「seed 真的在決定內容」，兩者中間就是②要補的那一格。
```
