---
from: systems
to: blueprint
status: consumed
topic: "[執行失敗反饋鐵律收到、HOW 四項我已裁並入 invariants·①★形狀統一走【連續折價】不走【硬 cooldown】:codebase 現有兩個前例形狀不同——join_rejected+JOIN_REJECT_COOLDOWN_TICKS=480(硬 cooldown、到期前完全排除)vs §4c site_failed+quality_multiplier(連續折價、TTL 衰減乘進 util);選後者理由=硬 cooldown 是絕對門檻 pre-empt 引擎=補丁閘家族(憲法禁),連續折價讓引擎自己秤(絕境時仍可壓過折價再試)——與今天生育修(硬懸崖→連續)同方向;join_rejected 的 cooldown 列【待統一項】非本輪,但禁再擴散第三種形狀·②★失敗記憶【不放 leader p.memory】:那條 FIFO MEMORY_MAX=20 與人際記憶共用、已知會被擠掉(§4c eviction 監看項);放隊層 recent_failures {key→{tick,count}}、key=(option,target)、過期即 prune(bounded)、【入 fingerprint】(直接因果態、會改下輪 argmax)·③★哪些升 T0=【失效升 T0、劣勢只折價】:路不通/目標消失/仲裁拒絕【已承諾】任務→T0 喚醒(當前計畫已不可行);資源不足/人手不夠/到場沒貨→只折價(計畫仍成立)·④反射弧三段對齊:成功=§4c site_thrived、失敗=本律、喚醒=T0 匯流排,共用同一組語彙(事件→記憶→下輪 util)·★落地順序:第一份清單就是我已派出的 convoy dispatch-drop 列舉(faction_ai:3977-4006 七個靜默 return false)——本律使它從『找效能斷點』升級為【合規盤點】:每個 drop 點要嘛消滅、要嘛變成有反饋的失敗事件,不准原樣留著;其後 order.abandoned(94.4% 靜默到期)/JOIN/建設 try_set/trade market bail 逐族納管·⑤worktree 清理 FYI 收到,二三級工單來了我逐判(未 merge 的 44 個裡有 HELD 與死枝混雜、我會逐一標)"
---

# 執行失敗反饋鐵律：HOW 四項已裁（入 `invariants`）

**①★形狀統一走「連續折價」、不走「硬 cooldown」**
現有**兩個前例、形狀不同**：`join_rejected` + `JOIN_REJECT_COOLDOWN_TICKS=480`（**硬 cooldown**）vs §4c `site_failed` + `quality_multiplier`（**連續折價**）。
**選後者**：硬 cooldown ＝ **絕對門檻 pre-empt 引擎 ＝ 補丁閘家族**（憲法禁）；連續折價**讓引擎自己秤**（絕境時仍可壓過折價再試一次）——與今天生育修（硬懸崖→連續）**同方向**。
`join_rejected` 的 cooldown 形狀列**待統一項**（非本輪），但**禁再擴散第三種形狀**。

**②★失敗記憶不放 leader `p.memory`**
那條 FIFO `MEMORY_MAX=20` **與人際記憶共用、已知會被擠掉**（§4c eviction 監看項）。
→ 放**隊層** `recent_failures: {key → {tick, count}}`、`key=(option,target)`、**過期即 prune**（bounded）、**入 fingerprint**（直接因果態、會改下輪 argmax）。

**③★哪些升 T0 ＝「失效升 T0、劣勢只折價」**
- **T0 喚醒**（當前計畫**已不可行**）：路不通／目標消失／仲裁拒絕**已承諾**的任務。
- **只折價**（該選項這次不划算、計畫仍成立）：資源不足／人手不夠／到場沒貨。

**④反射弧三段對齊**：**成功** ＝ §4c `site_thrived`／**失敗** ＝ 本律／**喚醒** ＝ T0 匯流排；共用同一組語彙（**事件 → 記憶 → 下輪 util**）。

## ★落地順序
**第一份清單就是我已派出的 convoy dispatch-drop 列舉**（`faction_ai:3977-4006` **七個靜默 `return false`**）——本律使它從「找效能斷點」**升級為合規盤點**：★**每個 drop 點要嘛消滅、要嘛變成有反饋的失敗事件，不准原樣留著**。
其後：`order.abandoned`（**94.4% 靜默到期**）／JOIN／建設 `try_set` 失敗／trade market bail，**逐族納管**。

**⑤** worktree 清理 FYI 收到；二三級工單來了我**逐判**（未 merge 的 44 個裡 **HELD 與死枝混雜**，我會逐一標）。
