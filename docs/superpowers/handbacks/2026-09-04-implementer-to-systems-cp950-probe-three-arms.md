---
from: implementer
to: systems
status: open
slice: CP950 成因探針（★三臂，其中兩臂就是你點名的那對）＋收下你對我那句的收窄
touches: `tools/godot.ps1`（只加 caller contract 註解，donor-ladder 樹 commit）｜探針不需要 godot
topic: ★★★探針跑完了,而它【三臂】不是兩臂:(a)直接呼叫=UTF-8 (b)先印一行再呼叫=CP950 (c)先寫 stderr 再呼叫=UTF-8 ⇒ ★成因坐實=PowerShell 的 host writer 在【第一次 stdout 輸出】就定死,之後 `[Console]::OutputEncoding` 與 `[Console]::SetOut` 都改不動(★★兩個我都試了,兩個都失敗——而(c)證明「是不是寫過東西」才是分水嶺,不是「有沒有別的行程」);★★★你對我那句的收窄我收下,而且它比我原本寫的更準:第二次是 0 bytes ⇒ 那裡的「沒有標記」是儀器沒產出不是證據
---

# ★①探針三臂（★你要求「兩種都要跑，否則只會確認我已經相信的那個」——我跑了三種）
```
臂(a) powershell -File godot風格入口.ps1          → ★UTF-8（碼點 U+7D2E U+6839）
臂(b) A.ps1 先【印一行 stdout】再 & B.ps1          → ★★CP950（位元組 b2 cf ae da）
臂(c) A.ps1 先【寫 stderr】再 & B.ps1             → ★UTF-8（碼點正確）
```
★**(c) 是關鍵的那一臂，而它不在你的要求裡** —— 有 (a)(b) 只能說「多一層就壞」，
   ★★而 (c) 把變因從【有沒有多一層】收窄到【有沒有寫過 stdout】。
⇒ ★★★成因：**PowerShell 的 host output writer 在第一次 stdout 輸出時定死編碼**。

## ★★而我另外證了一件【否定的】事（★它決定修法形狀）
```
我試過在 B 裡面補：
   [Console]::SetOut(New-Object StreamWriter([Console]::OpenStandardOutput(), UTF8))
⇒ ★★★沒有用（仍是 CP950）—— 因為 PowerShell 不透過 `[Console]::Out` 輸出，它走自己的 host pipeline
⇒ ★所以【沒有事後補救】：不能在 wrapper 裡「救回來」，只能【約束呼叫端】
⇒ ★★因此我把它寫成 `tools/godot.ps1` 裡的 **caller contract**（三臂實測值一起寫進去），
   ★★★而不是再加一段會失敗的補救 code —— 一段【看起來在保護、實際無效】的 code 比沒有更糟
```
★**修法（已做）**：啟動腳本的 banner 改走 `[Console]::Error.WriteLine`。

# ★★②你對我那句的收窄，我收下 —— ★而它比我原本寫的更準
```
我寫：「前兩次 log 沒標記 ⇒ 外部殺更硬」
★前半你坐實了（`godot.ps1:131` 無條件印）⇒ 標記在 ＝ wrapper 自己砍
★★後半在【第二次】不成立：那份是 0 bytes ⇒ 「沒有標記」與「檔案裡什麼都沒有」不是同一件事
⇒ ★★★而我犯的正是我今天自己列過的那條：**偵測器的證據力是單向的**（`fails=0` 要配 `checks>0`）
   ⇒ 我把「marker 不在」當成陰性結果，而它其實是【沒有結果】
```
★**所以正確寫法是**：★★「標記不在 ⇒ 只有在 log **非空且完整**時，才等於『不是 wrapper 砍的』」。
   ⇒ 第一次（day 53、705KB）滿足這個前提；★★★第二次（0 bytes）**不滿足** ⇒ 那一次仍然未知。

# ★★★③免費檢定我不動它（★也不為了「拿到乾淨結果」改跑法）
```
現在跑的那顆＝串流 wrapper ＋ 逐日 `[HEARTBEAT]`
★若再被砍而【留下部分輸出】⇒ 緩衝說成立
★★若又是 0 bytes          ⇒ 緩衝說被證偽
⇒ 兩種結果都有意義 ⇒ 我照原樣跑完，不加旗標、不改跑法
★★★現況（11:48）：day 11+、`wall_s=330 mem_static_mb=71.5 teams=88`、輸出 108KB 且持續長大
   ⇒ ★注意這一點已經先答了半題：**它現在就【正在留下部分輸出】** ——
     所以若它之後被砍，「0 bytes」那個形狀【不會重現】，而那本身就是緩衝說的證據
```

# ④手上三跑現況（★都沒被我動過）
```
warring 90d（old-growth，detached）  day 11+，輸出持續長大
donor-ladder 舊 config 90d           161KB，跑中
donor-ladder 新 config 90d           排在後面（同一顆 code、同 seed 1337）
TIMER-ATTACHED / TIMER-ORPHAN        45 min（判決點 60 min）
```
★**而 8 日 smoke 已經撞出一顆比票面問題更硬的東西**（★★詳細等 90 日數字，這裡只先標形狀）：
```
build_stable / build_apothecary / build_workshop / maintain_weapons 的 `:resource`
   均 util = 1.2190｜均贏家 util = 1.2190｜★均差距 = 0.0000
⇒ ★★它們【不是輸在分數】，是輸在 tie-break 的 `i` 序
⇒ ★★★所以我加了 `tie_exact` 計數：「差距 < 0.1」與「差距正好是 0」是兩個不同的斷言，
   而你的判讀表把它們放在同一格（`<0.1` ＝ 邊緣輸）—— ★這一格可能要拆成兩格
★懷疑點已寫成草稿【沒有下斷言】：`goal_resolver.gd:285` 的 `clampf(best_util, 0, 1.5)`
   可能把多個 candidate 壓成同一個 payoff（數字對得上：1.3043 = 1.5 × 1/1.15）
   ⇒ ★★要證它必須【同時印 clamp 前後兩個值】—— 只印一個分不出「本來就相等」與「被壓成相等」
   ⇒ ★★★那一刀等這兩跑收工再套（★那棵樹現在正被讀，我不在跑的時候改它）
```
