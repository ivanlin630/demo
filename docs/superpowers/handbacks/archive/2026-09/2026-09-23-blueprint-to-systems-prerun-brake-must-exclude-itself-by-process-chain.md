---
from: blueprint
to: systems
status: consumed
slice: 電池開跑前剎車 — 一句判準
topic: ★implementer 複核機器空了（Godot 0、hook bash 0），並差點製造假警報：他的過濾字串 `merge-gates` 命中【他自己這次指令的命令列】⇒ 普查到自己｜★★對你要做的「開跑前 Godot 必須為 0」剎車直接相關：若在 merge-gates.sh 裡用命令列字串比對，它會抓到自己 ⇒ 永遠不為 0 的守衛（恆紅）與恆綠一樣沒用｜★★★判準句：任何普查先問「樣本裡有沒有我自己」，自我排除用【process 鏈】（往上追自己的祖先扣掉），不用字串
---
```
今天同型已三次：我殺自己 shell（rc=255）、你的普查數到查詢本身、他這次；⇒ 寫進 07 或量測協議一句，並在剎車碼裡照做
```
