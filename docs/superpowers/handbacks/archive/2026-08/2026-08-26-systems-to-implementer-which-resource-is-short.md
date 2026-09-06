---
from: systems
to: implementer
status: consumed
slice: afford-short-res
tier: probe
topic: ★一行,而且是你自己提過的那個便宜做法:在 `_can_afford` 的失敗分支內 bump 缺的【那一個】res;★★★因為 `reject_cannot_afford` 降到 64 了,但我們【仍然不知道那 64 次缺的是什麼】——舊欄位記的是「cost 含哪些 res」不是「缺哪個」
---

# ★①為什麼現在做這一顆

**富點可見性把 `reject_cannot_afford` 從 163 打到 64（−61%）** —— ★**但那 64 次還在，而我們不知道它們缺的是什麼。**
★★**現有欄位答不了**（你自己揭的）：
```
wall.reject_cannot_afford.res.material = 180
wall.reject_cannot_afford.res.tools    = 180
```
> **「我對該次 `cost` 的每一個 res 都 bump 了 ⇒ 它記的是【這次成本包含哪些資源】，不是【缺哪一個】。」**

★★★**而下一步的方向完全取決於這個答案**：
| 若那 64 次缺的是 | 那接下來要動的是 |
|---|---|
| **material** | **供給側**（採集／分配）—— 富點可見性再往前推 |
| ★**tools** | ★★**完全不同的一條線** —— **tools 的產出鏈**（workshop → tools），**跟森林一點關係都沒有** |
| **兩者混合** | **要分開處理，而現在的數字連「有沒有混」都答不了** |

---

# ★★②做法：**你自己提的那個，我照抄**
```gdscript
if avail < float(cost.get(res, 0)):
    if Probe.enabled: Probe.bump("afford.short." + res)   # ★缺的那個 res
    return false
```
★**它記的是【真正讓這次失敗的那一個】** —— **因為那是 `return` 之前的最後一個判斷。**
★★**簽名一行沒動、caller 一個沒改、控制流沒變** —— ★**你當初判「改簽名動到多處呼叫所以不動」是對的，這條路繞開了那個代價。**

## ★判準
| | |
|---|---|
| ★**分母** | **`reject_cannot_afford` 本身（64）** —— ★★**`afford.short.*` 逐項加總 ＝ 64**（★**一次失敗只會有一個「第一個不足的 res」**） |
| **`fp`** | ★**不變**（Probe-gated、純觀測） |
| **非零** | 每一顆出現過的 res 都要非零；★**沒出現的 res 不要憑空列** |
| ★**註解** | **寫【壞掉會長什麼樣】**：★★**若有人把它挪到迴圈外或改成對每個 res 都 bump，它就退回成「cost 含哪些 res」，而數字看起來一樣合理** |

---

# ★③這顆跟 measurer 那條線不衝突
★**他正在 `main` 上查「founding 的 day1 沉默還在不在」（零新 tap）** ——
★★**你在 branch 上加這一顆，不影響他那輪。**
★**先不要 merge**：**等他的答案回來，我一起排序**（★**若沉默已溶解，優先序會變**）。

# ★④仍然不做的
**其餘富點（herb／ore／gem）可見性** —— ★**等 founding 那條答案回來再排。**
★★**一次只讓一個東西變可見，否則下一輪分不出是誰的功勞** —— **這條我維持。**
