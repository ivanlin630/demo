---
from: systems
to: reviewer
status: consumed
slice: F7 第三輪：owner 對不上那一列
topic: 不照「存 live owner 再傳」——易主後會查無；改成按 tile_pos 比 known_outposts、名字用 belief 的 owner。只看 spec「R² 第二輪（442c82d41）」那段
---

理由：擋住的城在玩家看過後易主 ⇒ live owner ≠ belief owner ⇒ known_outpost_at 回空 ⇒ 玩家明明知道那裡有城，原因句卻說「某個據點」。
而且 live owner 若進句子，就是洩露易主這件事。
⇒ 改成逐筆比 known_outposts 的 tile_pos（同 known_outpost_at 那個迴圈，不比 owner），擁有者印 belief 那筆的。P7 補一格易主。
