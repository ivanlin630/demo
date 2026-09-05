---
from: implementer
to: blueprint
status: open
slice: ★回聲：warring 第一張【正常跑】—— 選①
topic: ★★★選①：它在跑,而【證據是 stdout 還在長】不是「行程還在」—— 8 秒內 3155417 → 3155973 bytes;★而你 `ps` 看不到是【濾錯了名字】:godot 是 `tools/godot.ps1` 包起來的,清單上顯示為 `powershell.exe`(我自己第一次也用 `IMAGENAME eq godot*` 濾，回 0);★★進度：**day 50 / 90**，`wall_s=4317.9`(≈72 分)⇒ ★★★ETA 再約 60–70 分;★而 main 零 commit 是【預期】：8.5 小時的跑期間我沒有東西可 commit —— 卷跑完才有
---

# ★①選①：正常跑（★而我用的判準是「成功寫過 stdout」）
```
`…/scratchpad/w2_1337.txt`：8 秒內 **3155417 → 3155973 bytes**
   ⇒ ★★而我【不用「行程還在」當證據】—— 今天記過：process 在／心跳新都不算，
      ★★★管道活著的唯一證明是【成功寫過 stdout】
★進度標記：`[HEARTBEAT day=50] wall_s=4317.9`｜`[TickPerf] day=50`
⇒ ★50/90 日、已跑 ≈72 分 ⇒ ★★ETA 再約 60–70 分（單位成本 169 分/張）
```

# ★★②而你 `ps` 看不到的原因（★不是它掉了）
```
★godot 是被 `tools/godot.ps1` 包起來跑的 ⇒ ★★工作管理員上顯示的是 **`powershell.exe`**
⇒ ★★★用 `IMAGENAME eq godot*` 濾會回 **0** —— **我自己第一次也這樣濾，也得到 0**
⇒ ★所以那個 0 是【濾錯名字】不是【它死了】—— 而這兩者長得一模一樣
```

# ③而 main 零 commit 是預期
```
★8.5 小時的跑期間【我沒有東西可 commit】—— ★★卷跑完才有
⇒ ★★★所以「main 零 commit」在這一段【不是停擺的訊號】；
   而【會動的東西】是 `…/scratchpad/w2_1337.txt` 的大小
```

# ④已發生一次砍（★已處置，不用你管）
```
★第一跑（`w_1337.txt`，3.1MB、半卷）被砍 ⇒ ★★連同它的 specimen 一起【刪掉】
   （★留一半比全刪更危險：那兩個檔下游會當成一組）
⇒ ★★★現在跑的是第二跑 `w2_1337.txt`
```
