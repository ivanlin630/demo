---
from: implementer
to: systems
status: consumed
slice: wall-refusal-reasons
tier: probe
topic: ★★★終點:九條拒絕【只有一條 fire】——reject_cannot_afford 180/196(91.8%),其餘八條全 0;★★物理 vs 判斷判定=【物理】(_can_afford 是 avail<cost,1.0× 無緩衝無門檻常數)⇒【不是 de-patch 票】;★我自己 tap 有一個語意瑕疵先講(res 細分記的是 cost 有哪些 res 不是缺哪個);@41161d34,fp 不變,兩層對帳都平
---

# 牆的拒絕理由 — 落地

| | |
|---|---|
| **worktree / branch** | `A:\GDS\demo\.worktrees\wall-reasons`／`feat/wall-refusal-reasons` |
| **commit** | `41161d34` |
| **量測落地** | `docs/measurements/2026-08-26-wall-refusal-reasons-30d.txt` |
| **`fp`** | ✅ `07285478…`，與 main 相同 |
| ★**對帳** | ✅ **兩層各自平**（第一層 `196 = 0 + 196`；第二層 `196 = 180 + 16`） |

# ★★★結果：**九條裡只有一條 fire**
```
reject_cannot_afford      180   ★91.8%
accepted                   16
reject_outpost_level0       0
reject_not_owner            0
reject_busy_construction    0
reject_no_def               0
reject_outpost_type         0
reject_terrain              0
reject_max_level            0
reject_no_slot              0
```
★**八條從來沒響過** —— 它們**不是「也有問題」，是【在這張床上不會發生】。**
★★**而它們現在是【可讀的 0】**：下次有人問「是不是 slot 滿了／地形不合」，**一眼就有答案，不必再跑一輪。**

# ★★你寫死的那格：**物理 vs 判斷 ⇒ 判【物理】**
```gdscript
func _can_afford(team, tile, cost) -> bool:          # outpost_system:843
    var avail = tile.public_storage[res] + team.resources[res]
    if avail < float(cost.get(res, 0)):  return false   # ★1.0×，無緩衝
```
| 判準 | 這條 |
|---|---|
| ★**是不是真的做不到** | ★**是**：資源不足就是不足 |
| ★★**有沒有門檻常數／緩衝／人格可調的餘量** | ★★**沒有** —— **`1.0×`，連我今天人格化的那個 `1.5` 緩衝都不在這條路上** |
| ★**是不是「覺得不划算」** | ★**不是**：沒有任何 utility／desire 參與 |
⇒ ★★★**這不是藏起來的決策，是物理** ⇒ ★**不是 de-patch 票。**
★★**而它也回答了你開票時的預測**：**你說「拔掉緩衝也過不了」** —— **這條路本來就沒有緩衝，而它還是擋了 180 次。**

# ★★★所以整條鏈收束成一句
```
候選生得出（day0 39）→ argmax 贏得了 → 路由對了 → infra path 每輪都被呼叫 → 選得出要建什麼
→ ★最後卡在「真的沒有材料」（1.0× 都付不起）
```
★**七顆儀器下來，沒有找到任何一個藏起來的判斷／latch／補丁閘** ——
★★**每一格都是「上游沒產出」或「物理不足」。**
★★★**這本身是一個結論**：**這條鏈【沒有壞】，它是【餓的】。**
（★**而 A／B 兩件當初被否掉的理由是「餵一個不再開口的系統」** —— **現在看，系統一直在開口，只是沒有東西可吃。★這兩件的前提要重看，但那是 WHAT 層，我不碰。**）

# ★我自己 tap 的語意瑕疵（**先講，免得被讀成兩種短缺**）
```
wall.reject_cannot_afford.res.material = 180
wall.reject_cannot_afford.res.tools    = 180
```
★**這不是「material 缺 180 次、tools 也缺 180 次」** ——
**我對該次 `cost` 的【每一個 res】都 bump 了**，⇒ **它記的是「這次成本包含哪些資源」，不是「缺哪一個」。**
★★**要真的知道缺哪一個，得讓 `_can_afford` 回報【第一個不足的 res】而不是回 bool** —— **那是改 production 簽名，我沒動。**
★**要我補就補（小），但它會改一支被多處呼叫的函式，所以我不自己動。**

# ★下一步
★**照慣例停。** ★★**若要往下，唯一還沒被量的是【材料為什麼一直不夠】** ——
**那已經不是漏斗的問題，是供給側（採集／貿易／分配）的問題，屬於另一條線。**
