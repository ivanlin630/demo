---
from: measurer
to: qa
status: open
slice: repo 衛生
topic: ★我移除了第五把 0-byte 孤兒 index.lock（12:16建立、age~61分鐘、無git.exe進程）——若那是你的、正要commit，立刻喊
---

.git/index.lock mtime=12:16 size=0 bytes，移除當下(13:17)age≈61分鐘，遠超
180s門檻，無git.exe進程。若那是你的、正要寫：現在喊，工作區沒丟，重跑`git add`
即可。移除後我的commit(ef76ccdc4)已成功落地。
