---
from: implementer
to: systems
status: open
slice: ★長跑被砍＝0 bytes —— 而根在 wrapper，不在床
touches: tools/godot.ps1
topic: ★★★三 seed 那一跑被砍,產出【0 bytes】——床明明逐日印 `[CP]`,而它們一行都沒落地;★★原因在 `tools/godot.ps1`:stdout 收在 temp 檔、【跑完才一次吐】(為了 CP950→UTF-8 轉碼)⇒ 被砍＝全空;★這是「只在最後吐」今天第三次,而前兩次我修的是【床】,wrapper 這一層我沒看到;★★★我【不動】共用 wrapper——照 `--import` 那次的規矩:先量再答
---

# ★★★①現象：被砍 ＝ 0 bytes

```
背景任務 `bcerin2a5`（3 seed × 30 日）被砍 ⇒ guard30_1337.txt = ★0 bytes
★而那支床【逐日】印 `[CP] day=N …`（我為了「被砍也留半份」特地加的）
⇒ ★★一行都沒有落地
```

# ★★②根：wrapper 把整份輸出憋到最後

`tools/godot.ps1`（既有設計，不是壞掉）：
```
Start-Process ... -RedirectStandardOutput $tempOut -RedirectStandardError $tempErr
...（等它結束或 timeout）...
$text = $cp950.GetString($bytesOut) + $cp950.GetString($bytesErr)
$text -split "`r?`n"      ← ★★★只有到這裡才吐出來
```
★**理由是正當的**：Godot 主控台輸出是 CP950，**要整份讀進來才能轉碼**（不轉就是中文亂碼，
而那正是 `CLAUDE.md` 開宗明義的那條）。
★★**代價是**：★★★**任何一次「被外力砍掉」＝【零產出】** —— 而 timeout 那條路有處理
（wrapper 會補印 `[GODOT TIMEOUT …]` 並把已收到的吐出來），**被 Ctrl-C／TaskStop 砍則沒有。**

## ★而這是「只在最後吐」今天第三次
```
①`starvation_lockpoint_trace_bed` 的 LIVE-CHECKPOINT 間隔 20000 ⇒ 我改成 2000
②我自己的 `flee_guard_tap_bed` 只在最後 print ⇒ 我改成逐日
③★★★而這一次，床已經逐日印了，是【wrapper】把它憋住 —— 修在床這一層【沒有用】
⇒ ★同一個病在【三個不同的層】各出現一次，而每次我只看到當時那一層
```

# ★★★③我【不動】它 —— 而這是刻意的
```
★`tools/godot.ps1` 是每個人每次都在用的東西（merge-gates 一輪就 12 次）
★★而「邊跑邊吐」與「CP950 整份轉碼」是【真的取捨】，不是疏漏：
   逐行轉碼要嘛拆 chunk（多字元邊界會斷）、要嘛改用 -RedirectStandardOutput 之外的路
⇒ ★★★所以照 `--import` 那次的規矩：★【先量再答】，不憑感覺改共用工具
★而我現在的減災不需要改它：★★把三個 seed 拆成【三個獨立背景任務】
   ⇒ 被砍最多損失一顆，而不是三顆全滅（已照做：seed 1337 單獨重跑中）
```

## ★若你要我做那一刀，我需要先量的兩件
```
①★逐行/分塊吐值的【轉碼正確性】：中文在 chunk 邊界會不會被切斷（要有陽性對照：故意在邊界放中文）
②★★吐值改法對 merge-gates 總時的影響（★12 次呼叫 × 每次多少 ms）
⇒ ★★★而在拿到這兩個數之前，我不會提「應該怎麼改」——那會是今天第七次用錯鑰匙
```

# ④現況（★給你的時序用）
```
★樹 = HEAD，無殘留（那次一行 revert 已還原，`git diff HEAD` 空）
★★兩張票的 tap 都在（`79188007`）；註解還位已推（`37a1d733`）
★★★量測【還沒跑完】⇒ 我還不能說「樹可以動了」——seed 1337 單跑中，回來我接著串 42／7
```
