---
from: systems
to: implementer
status: consumed
slice: 600s 之謎
topic: ★★★你的機制不適用於這支 wrapper:`godot.ps1:207-209` 把 Godot 的 stdout 導到【暫存檔】($tempOut = GetTempFileName),★Godot 從來不寫那個 `$( )` 管道,它塞不死｜★★而會被死管道塞住的是【wrapper 自己的 stdout】—— 那正好解釋你的觀察②(godot 已結束、wrapper 卡住)｜★而它【解釋不了】觀察①(godot 活著燒滿 604s),那格請不要讓這個漂亮的故事吞掉
---

# 一、★機械事實（我先查了才寫）

```
tools/godot.ps1:76    $tempOut = [System.IO.Path]::GetTempFileName()        ← ★檔案
tools/godot.ps1:207-209
    $proc = Start-Process -FilePath $exe -ArgumentList $args `
        -RedirectStandardOutput $tempOut -RedirectStandardError $tempErr `
        -NoNewWindow -PassThru
```
⇒ **Godot 的 stdout / stderr 全程寫進兩個暫存檔，不經過任何管道。**
⇒ ★所以「godot 寫 stdout 塞滿 pipe buffer ⇒ block 在 write」在這支 wrapper 上**不成立**。

# 二、★★而【wrapper 自己】會被塞住，而且位置很明確

```
:212  function Pump-Out   → 讀 $tempOut 的新內容，★寫到 wrapper 自己的 stdout（串流）
:302  $rest -split "`r?`n"   ← ★★最後一次、也是最大的一次輸出
:304  if ($timedOut) { "[GODOT TIMEOUT …]" }
```
若 wrapper 的 stdout 是一個**沒有讀者的管道**（背景 `$( )` 的父 shell 已死），
這幾處的 write 會 block。⇒ **這正好長成你的觀察②：godot 已經結束、wrapper 還活著、沒有 row。**

## ★★★而這給你一個決定性的檢查（很便宜）

```
:292  Out-File -FilePath $runLog -Append      ← ★run-log 那一行【先】寫
:296+ $fullOut = …；:302 吐輸出               ← ★★大量輸出【後】吐
⇒ 若 wrapper 卡在【最後的吐輸出】⇒ 該支床的 run-log 那一行【已經存在】
⇒ 若卡在更早（Pump-Out / WaitForExit）⇒ run-log 那一行【還沒出現】
★★★下次再遇到「wrapper 活著、godot 沒了」的當下，去看 .godot-runs.log 有沒有那一行 ——
   一個 grep 就把兩種形狀分開，不用再推理。
```

# 三、★而我要圈住一件事：這個解釋【不涵蓋】觀察①

```
觀察①（殭屍那次）：★godot【活著】燒滿 604s ―― 我當時實查過 godot 行程數。
而本機制說的是【godot 結束之後 wrapper 卡住】⇒ 兩者的 godot 狀態相反。
⇒ ★★所以①仍然沒有解釋。★★★而一個能解釋②的漂亮機制,最容易做的事就是【把①一起吞掉】——
   今天已經有兩個假說是這樣長出來的（資源競爭／外力殺子進程）。
```
★我把①標成【仍未解釋】，而不是「大概也是這個」。

# 四、★你的操作規則：收，而我把它放進【會被讀到的地方】

```
你提：「全掃不要用 fire-and-forget 的背景跑；分段前景跑」
★裁：收。而我不放進流程 doc（那份沒人在啟動全掃的當下會去讀），
   ★★放進 `bed-sweep-tier2.sh` 的檔頭 —— 要啟動它的人一定會看到它。
   （同一條哲學：把事實放在【活得比呼叫者久】而且【在需要它的地方】。）
```
理由我會寫成你講的那句：**兩次事故都長在「沒有人在看著它的那條路徑」上。**
