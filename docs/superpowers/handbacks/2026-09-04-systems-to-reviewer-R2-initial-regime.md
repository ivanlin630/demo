---
from: systems
to: reviewer
status: consumed
slice: initial-regime-in-worldgen（R²）
topic: ★★★我查完發現【機制已存在】(game_setup:313 創世就 create_faction),缺的是參數:27/36 個 config 沒有 `factions` 區塊 ⇒ 政權數 0——所以我沒有寫「新增機制」,寫的是「補預設」;★三案我傾向 C(預設有政權＋既有床顯式寫 0),要你打:①案 C 的 27 個 config 各加一行,有沒有更小的形狀?②`fcfg` 的預設值該取什麼(★而我不想手抄一個數)③驗收③(peaceful 上徵收/歸建 applicable 母體>0)會不會其實需要別的前置
---

spec：`docs/superpowers/specs/2026-09-04-initial-regime-in-worldgen-HOW.md`

# ★①要你先確認的前提（★我查了，但這是負斷言）
```
`_generate_factions` 讀 `config.get("factions", {})` ⇒ ★沒有該欄 ⇒ 不產生任何政權
⇒ ★★而我斷言「創世政權機制已存在、只缺參數」——**請你確認沒有第二條建政權的創世路**
   （★★★我只查了 `game_setup`／`create_faction` 呼叫點，沒有窮盡搜索別的入口）
```

# ★★②三案與我的傾向
```
A：給 `fcfg` 預設值（一處改，27 世界同時有政權）—— ★但【所有既有 baseline 失效】
B：只補新卷的 config —— ★★但「創世帶初始政權」變成某些卷才有，與用戶 WHAT 不符
★C（我傾向）：預設有政權 ＋ 既有床【顯式】寫 `factions: {count: 0}`
   ⇒ ★★★「沒有政權」變成【明寫的選擇】而不是【沒人填的欄位】
```
★**要你打**：**案 C 要動 27 個 config 各一行 —— 有沒有更小的形狀？**（★★而「更小」不能以「回到沒人填」為代價）

# ★★★③我不想自己決定的那一格
```
`fcfg` 的預設值（`count` 與 `teams_per_faction_range`）該取什麼？
⇒ ★我【不想手抄一個數】——而現有的 `warring_states` 是 `count=8／[2,5]／independent_ratio=0.35`
⇒ ★★那是為【戰國卷】調的，直接當預設可能不對
⇒ ★★★你的建議？（或：這一格該不該回去問 blueprint／用戶，而不是我們選）
```

# ④第三問
驗收③（peaceful 床上 `徵收／歸建` 的 applicable 母體 > 0）——★**會不會其實還需要別的前置**（例：directive 產生路徑另有 gate）？
