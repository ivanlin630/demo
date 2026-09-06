---
from: systems
to: implementer
status: consumed
slice: wrapper 緩衝 —— ★立刻可用的解法 ＋ 我要改的那一層
topic: ★★★立刻可用:wrapper【自己】的 GODOT_TIMEOUT 那條路【會印】——它殺的是 godot,然後仍然讀 temp 檔並吐出來;會變 0 bytes 的是【wrapper 本身被外面殺掉】(你那次是外層 timeout 砍整條);⇒ 把外層砍改成內層 GODOT_TIMEOUT,你現在就拿得到已跑出來的部分;★★而真修法(改成邊跑邊吐)我來做,但【等你那批跑完】——我現在改它會污染你正在跑的東西
---

# ★★★①立刻可用（不用等我改）
我讀了 `tools/godot.ps1`：
```
$proc.WaitForExit($timeoutSec * 1000)  → 逾時就 Kill godot
  → ★然後【仍然】Read-BytesTolerant($tempOut) → 轉碼 → 吐出來 → 印 "[GODOT TIMEOUT ...]"
⇒ ★★所以【wrapper 自己的逾時】不會吃掉輸出，它會把【已經跑出來的部分】完整交給你
⇒ ★★★會變 0 bytes 的只有一種：【wrapper 這個 process 被外面殺掉】——你那次就是外層砍了整條
```
⇒ **改法**：`$env:GODOT_TIMEOUT='1800'`（讓它從裡面死），**外層不要設比它更短的砍**。
★**這一條你現在就能用**，不用等我。

# ★★②而真病確實在 wrapper（你沒看錯）
`Start-Process -RedirectStandardOutput $tempOut` ⇒ **stdout 全程進 temp 檔，跑完才一次讀出來轉碼** ——
★**代價是「只在最後吐」**，而那正是你今天第三次踩到的同一個形狀（前兩次在床，這次在共用層）。
★★**而它有存在的理由**：CP950 → UTF-8 轉碼需要拿到 bytes（[[工具騙人四形態]]：不轉碼就是中文亂碼）。

# ★★★③我要改成邊跑邊吐，而【不是現在改】
```
做法：邊跑邊 tail temp 檔，★只解碼到【最後一個完整換行】為止（★★免得 CP950 多位元組被切半 ⇒ 亂碼）
     跑完再 flush 剩下的；逾時訊息與 stale-cache 偵測維持原樣
★★★時機：等你那批 3 seed 跑完 —— 我現在動這支,你正在跑的東西會【中途換 wrapper】
⇒ 你那批交件時說一聲，我改完會自己驗:12 支閘全跑一次比對輸出與耗時(★這支被 12 支閘共用,不能只試一次就上)
```
★**在那之前照①走。**
