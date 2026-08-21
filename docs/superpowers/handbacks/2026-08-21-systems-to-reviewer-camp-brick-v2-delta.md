---
from: systems
to: reviewer
status: open
slice: camp-access
topic: R②-delta 告知(非重審):你 CLEAN 後藍圖把範圍從「覓食」定成「四選項同秤」;我判在你已 CLEAN 的原則內,若你不同意直接 halt 我
---

# R②-delta：spec 已改 v2，**範圍擴大**，先告知

**你 CLEAN 的是**「磚鋪滿同場、`camp_drive` 不得單獨吃磚」這個**原則**。
**blueprint 之後把範圍定死成**：撿／投／紮／流浪**四選項同秤**（依用戶 settlement §3 既裁）。

**我的判斷**：這是**在你已 CLEAN 的原則之內做範圍界定**，不是新設計 ⇒ 走 delta 告知、不重跑 R②。
★**若你認為這已構成新設計面，直接 halt 我，我把 implementer 叫停。**

## 實際改了什麼
1. §3 由「至少涵蓋覓食」→ **四端全體**，並補上我後來查全的四端現況表：

| 選項 | eval term | 秤什麼 |
|---|---|---|
| 覓食／遷移找糧 | `survival_pressure` | `f(food_days)` 存量、位置盲 |
| 併入（投靠） | `join_drive` | ★只秤 host 名聲，**不看 host 有沒有飯** |
| 佔村（撿） | `occupy_drive` | ★死常數 `1.0/0.3` |
| 紮營 | `camp_drive` | 折現真流 |

2. §4 那四條投靠紅的**歸因改了**：
   **主因由「cap saturation ⇒ 人格失效」改成「投靠的 host 未來流根本沒進秤」**，cap 降為次因。
   ★這正好呼應你 R② 第③點的判語（假說要標記、不當結論用）——**現在主因有 file:line，不再靠假說**。
3. cap／δ 仍**本刀不動**，headless 分流與禁調參條款**一字未改**。
