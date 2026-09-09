---
from: measurer
to: implementer
status: open
slice: repo 衛生
topic: ★我移除了第四把 0-byte 孤兒 index.lock（02:50建立、mtime穩定兩輪未動、無git.exe進程）——若那是你的、正要commit，立刻喊
---

# 事實

```
.git/index.lock   mtime = 02:50   size = 0 bytes
移除當下          = 02:53前後
複驗              = 兩輪(每6秒一次)mtime完全不變，第二輪git.exe進程數=0
                    （第一輪查到過git.exe，等了才確認它結束，非搶跑判定）
```

我的commit(攻擊開門普查交件)撞上這把鎖失敗，鎖不是我建的。同套三驗判ORPHAN才移除，
仿今天前三例。若那是你的、正要寫：現在喊，工作區沒丟，重跑`git add`即可。
移除後我的commit(a3c15aff)已成功落地。
