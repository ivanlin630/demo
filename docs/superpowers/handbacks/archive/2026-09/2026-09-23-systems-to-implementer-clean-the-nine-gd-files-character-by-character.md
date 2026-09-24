---
from: systems
to: implementer
status: consumed
topic: ★派工：9 支 .gd 的簡體形近字清掃（不是 6 支——我加了字表又撈出 3 支）｜★★用戶硬規：禁盲目全替換，多義字逐字看｜★★★這是純文字，但它會改變 grep 命中，所以有真風險
---

# 清單（9 支，我剛用閘自己的過濾量的）

```
scripts/data/world_state.gd
scripts/debug/interrupt_premeasure_bed.gd
scripts/debug/resource_shape_falsifier.gd
scripts/debug/scout_on_the_scale_bed.gd
scripts/debug/settlement_s1_test.gd
scripts/simulation/decision/decision_engine.gd     ← ★新撈出
scripts/simulation/order_system.gd                 ← ★新撈出
scripts/simulation/task_arbiter.gd                 ← ★新撈出
scripts/simulation/faction_ai_system.gd
```

★後三支是**我稍早把 `两/颗/种` 加進字表**才撈出來的 —— 不是它們今天變壞，是**偵測器今天才看得見它們**。

# ★★硬規：逐字看，禁盲替

```
用戶立規：清掃【禁盲目全替換】—— 多義字（里／后／干／面／发…）在正體中文裡本來就有合法用法
⇒ 請逐處判斷語意，不要 sed 全域取代。
```

# ★★★而這不是「純排版」——它有真風險

```
這些字若出現在【字串字面量】裡（print／Probe 鍵名／expect 比對），
改掉它會改變【grep 會不會命中】⇒ 可能讓某個閘從綠變紅、或從紅變綠。
⇒ ★改完請跑一次相關的閘，不要只看 bash -n／parse。
⇒ ★★特別注意 Probe 鍵名與判決行字串：那是判準通道。
```

# 誠實限（我先講）

```
★我只量了【閘的字表認得的字】。字表 54 字，它不是簡體字的全集
⇒ 「清完＝這 9 支再無簡體字」這句話【不成立】，正確說法是
  「清完＝這 9 支再無【字表認得的】簡體字」。
★★而字表不完整這件事今天已經咬過一次（B3 卷面那三字當時抓不到）。
```
