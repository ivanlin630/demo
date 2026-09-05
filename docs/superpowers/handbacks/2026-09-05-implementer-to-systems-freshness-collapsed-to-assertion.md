---
from: implementer
to: systems
status: open
slice: ★③已收束（`feat/belief-freshness-tile-pos` @ `b7a57ba6`）—— 機制拆掉，等式焊住
touches: `belief_system.gd`（14 insertions／34 deletions）＋ 新測 `belief_freshness_invariant_test.gd`
topic: ★★★反向斷言【三層都綠】:陽性對照 0→1(★故意寫一筆不帶 `tile_pos` 的親見 claim)／production 路 1→1(★★不上升)／母體 24(★★★否則「不得上升」是空過);★機制乾淨移除:`tile_pos_tick` 兩處寫入 ＋ `_pos_stale` 整支;★★而四個讀取點改寫【實測到的事實】而不是原本要寫的那四行推測;★★★過程踩了兩個坑,都記在 commit 裡:①新 worktree 的 class 快取【`--import` 也建不起來】(wrapper 只列了兩種成因,而這是第三種)②我用行號做多段刪除【而行號會位移】⇒ 自己把 production 檔改壞
---

# ★★★①反向斷言：三層都綠（★而三層缺一不可）
```
★陽性對照：故意寫一筆【親見但不帶 `tile_pos`】的 claim ⇒ 計數 **0 → 1**
   ⇒ ★★若它【不動】，那是【計數器壞了】—— 而它的 0 就不能當證據
★★真正的斷言：跑 production 的 vision／共位互動路 ⇒ 計數 **1 → 1（不上升）**
   ⇒ ★★★「等式仍成立：每一次親見都帶 `tile_pos`」
★母體：本段實際發生的親見寫入相關計數 ＝ **24**
   ⇒ ★★★若是 0，上面那個「不得上升」是【空過】—— 而空過與通過在輸出上長得一樣
`總計 FAIL = 0`｜`[TEST-SUITE-COMPLETE]`｜★閘型床兩要件齊（結尾標記 ＋ `push_error`）
```

# ★②機制乾淨移除，而註記改成【實測事實】
```
拆：`tile_pos_tick` 寫入兩處 ＋ `_pos_stale` 整支 ⇒ `belief_pos` 兩條通道還原
   （`git diff --numstat` ＝ **14 insertions / 34 deletions**）
★而四個讀取點【不是】寫原本 spec §4 要的那四行（「此處 `last_tick` 不管 `tile_pos`」）——
   ★★因為那句話在【機制被拆掉之後就不成立了】：現在 `last_tick` **就是**管 `tile_pos`
   ⇒ ★★★改寫成實測事實：「三個 firsthand 寫入點全部同時寫 `tile_pos` ⇒ 沒有借；
     而若未來新增只寫部分欄位的親見寫入端，這個等式會斷」
```

# ★★★③兩個坑（★都不是 code 的問題，是我的工具與工具的提示）
```
①★新 worktree 的 class 快取是【空的】（8 bytes vs 主 dir 17003），
   ★★而我照 wrapper 提示跑了 `--import` —— **仍然是空的**
   ⇒ ★★★wrapper 只列兩種成因（快取 stale／型別不存在），而這是【第三種：`--import` 沒生效】
     —— 而我是在【照建議做了卻還是紅】的時候才該懷疑清單本身不完整
   ⇒ 處置：本 branch 未新增任何 `class_name` ⇒ 驗過等價後複製主 dir 的快取（★不是碰運氣）
②★★我用【行號】做多段刪除 —— ★★★而每刪一段，後面的行號就全錯
   ⇒ 誤刪 `cs.append(...)` 那行、留下孤兒 `if` 與半截 dict literal
   ⇒ ★而 Godot 只報「Could not resolve class BeliefSystem, because of a parser error」
     —— **不指出真正壞的那一行** ⇒ 第一層看起來像【測試檔】壞掉
   ⇒ ★★通則：多段刪除用 **anchor** 不用行號；而我前面幾十次都用 anchor，
     ★★★這次 anchor 沒對上就退回行號，**而退回的那一步沒有補上驗證**
```

# ④現況（★序：④✅ ③✅ → ⑤／① 前置量測 → ②）
```
★④ `feat/arbiter-deny-by-option` @ `181dfd33`
★★③ `feat/belief-freshness-tile-pos` @ `b7a57ba6`（★本封）
★★★①前置量測：工單已收（六載體＋一條靜態軸），**我接著開**
★而 warring seed 42 真 detach 補跑仍在飛
```
