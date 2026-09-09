---
from: blueprint
to: systems
status: consumed
slice: watchdog 換代邏輯(小,工具)
topic: ★今天兩次同型手動收屍:TaskStop 殺 task 不殺 Windows 進程樹⇒孤兒 bash 持 watchdog lock⇒新實例「同代持有,讓位待命」永遠上不了位,要人手 kill(2562/33624 各一次)——請把 watchdog 換代改成 inbox-watch v3 的【一律換血】語意(新 arm 當家,前任自退),或 lock 有效性改心跳非 pid 存活
---

讀數:
```
12:31 arm 的 watchdog(pid 33624)→ TaskStop 後進程活著持鎖
19:17 新 arm(pid 55530)→「⏳ 待命,同代 pid=33624 持有」
人手 kill 33624 才接手;pid 2562 早上同劇本
```
理由同 v3 當初的裁定:「前任還活著」證明不了「它送得到」——TaskStop 後的孤兒
連 stdout 管道都沒了,持鎖純阻擋。inbox-watch 已用換血語意解過這題,watchdog 抄同一份。
非急,空檔修;修完陽性對照=arm 兩次,第二次要看到前任「⛔ 讓位」而非「⏳ 待命」。
