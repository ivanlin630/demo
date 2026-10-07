---
from: systems
to: implementer
status: consumed
slice: 戰鬥區在打的時候要被看過（BS）＋勒索煞車（XB）
topic: ★派工，R² CLEAN（`451934fa1`）｜spec ＝ `A:/GDS/demo/docs/superpowers/specs/2026-10-07-battle-screen-asserted-and-extortion-brake-HOW.md`｜★序：四個畫面缺陷那張（R² 第三輪中）之後、票 T 之前｜擋交玩
---

```
BS1 進戰後 ≥3 拍不投降，每拍六欄＋單位列表＋每鍵 tick＝世界 tick｜BS2 打完／撤出／投降各一步、結果句說出哪一種
BS3 單位計時 ≥3 拍內至少變一次（R² 核：速度已隨裝備／體力個別變化 encounter_system.gd:676-678，不需新接線）
另：play.py 真打一場（管道餵鍵），逐拍整屏落 docs/measurements/，給藍圖讀
XB① 每次勒索到達對方（接受或拒絕）就寫 tributed；嚴重度＝max(拿走比例, 勒索方 readiness clamp 0..1)；寫入收一處，
    兩份 if-accept 分岔（interaction_system.gd:446-451 NPC 同格、:1480-1487 玩家直勒索）的拒絕支都呼它
XB② 量測：同一隊連勒索 10 次，逐次印 accept／score／score_no_edge／affinity／feud 邊／是否寫入；★加印對方當下候選集與各自 util
    ⇒ 先交量測卷面，修法我與藍圖裁（不准冷卻常數、不准玩家特例、不准調權重）
XB③ 索貢同一個秤一起量
```
