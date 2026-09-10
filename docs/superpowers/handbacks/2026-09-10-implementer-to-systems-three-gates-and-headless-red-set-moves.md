---
from: implementer
to: systems
status: consumed
slice: 三支小閘（①headless 床值 ③bare-tick ②bed-arm）
topic: ★①③做完（commit **3ec6a43b3**，落點 main）：`current_tick = 1500` ⇒ 由 `TRADE_TIMEOUT` 導出、bare-tick **PASS（母體 186／NEEDS_HUMAN=0）**｜★★★而②的根因【不在床】：`bed_arm_gate.gd` 本來就 `quit(1)`，是 **`tools/godot.ps1` 從不把子行程 exit code 往外傳**（我實測 wrapper rc=0）⇒ 這是【所有經 wrapper 的閘】共用的形狀，我不擅自改共用工具｜★★而 headless 我要回報一件比「綠沒綠」更重要的事：**它的紅集合在同一個 commit 上【每次跑都不一樣】**（今天量到 3／5／6／7 條）
---

# ① 做完的兩支（commit 3ec6a43b3）

```
①headless 床值：`state.world.current_tick = 1500` ⇒ `FactionAISystem.TRADE_TIMEOUT + 1`
  ⇒ ★TRADE 那條斷言在【兩次複跑裡都消失了】（改前它必紅：1500 < 8640 ⇒ 超時本來就不該 fire）
  ★★同族掃描（你要求的）：床裡其餘 `current_tick = 字面值` 共 9 處 ——
     801／802／810-812 是「唯一 tick 避免 path cache 跨測試污染」（已有註解）、
     0 是起點、240 是 trace dump（不與任何門檻比較）、31×／3× TICKS_PER_DAY 已導出
  ⇒ ★★★只有這一顆是【凍結的門檻】，其餘不是同一個病。
③bare-tick 最後一顆：`goal_resolver._tiles_per_day` 加 `# bare-tick-ok: 單位換算分子`
  ★放在【同一行】—— triage 是逐行比對 `src`，寫在上一行的註解它看不到（我第一次就是這樣沒命中）
  ＋規則表加一條並附 `sample` 自檢 ⇒ **bare-tick-gate PASS：母體 186、NEEDS_HUMAN=0**
```

# ② ★★★②的根因不在床 —— 而它的 blast radius 跨所有角色

```
`bed_arm_gate.gd` 結尾**已經是** `quit(1)`。
★我實測：`powershell -File ./tools/godot.ps1 --headless --script .../bed_arm_gate.gd` ⇒ **wrapper rc=0**
⇒ ★★`tools/godot.ps1` 拿到 `$proc`（Start-Process -PassThru）卻【從不 `exit $proc.ExitCode`】
  ⇒ **所有**經 wrapper 的床／閘，rc 一律 0 ——
  ★★★而它被 merge-gates 的 `expect` 機制遮住了（runner 判輸出不判 rc），
    所以這個洞在「有 expect」的閘上看不出來，只在【靠 rc 的消費者】上現形。
⇒ ★我沒有改它：那是共用工具，五個角色的長跑都經過它，
  ★★而「開始傳 exit code」會讓一批原本看起來 rc=0 的呼叫變成非零（那是對的，但要有人決定何時吃這一下）。
⇒ 交你裁：要我改就改（一行），要另開票也行。
★另：bed-arm 的 `expect` 我查過是好的（`BED-ARM-GATE] PASS`）——
  我先前用 `cut` 讀 tsv 把它截成 `PAS` 而誤以為壞了，★已還原、無淨改動。
```

# ③ ★★而 headless 有一件比「綠沒綠」更該先解的事

```
同一個 commit、同一支床，我今天跑到的紅集合：
  跑 A（改前）：紮營／FORCE／rung／g1a ＋ TRADE                    ＝ 5 條
  跑 B（改前）：上列 ＋ fixture B                                   ＝ 6 條
  跑 C（改後）：戰鬥中197／fixture B／紮營／FORCE／rung／g1a         ＝ 6 條（★TRADE 消失）
  跑 D（改後）：跑 C ＋ [p2a] join weight 太低                       ＝ 7 條（★TRADE 仍消失）
⇒ ★**紅集合在同一個 commit 上會漂** ⇒ ★★「headless 回綠」在這個狀態下【不是一個可達的驗收】，
   而更糟的是：**任何人拿它的紅去歸因，都會歸到錯的地方**（我自己差點就把「戰鬥中197」算到我頭上）。
⇒ ★★★而 TRADE 那一條在【四次跑裡的兩次改後跑】都不見了 ⇒ ①的效果是可判的，
   其餘的紅【與本票無關且不可歸因】。
⇒ 建議：另開一張【headless 床決定性】的票（我可以做，但它不該混進這三支小閘）。
  ★我的第一個懷疑（未驗）：這支床把很多子測試跑在同一個 process 裡，
    而 Probe counters／static cache／全域 RNG 都是跨子測試共享的。
```
