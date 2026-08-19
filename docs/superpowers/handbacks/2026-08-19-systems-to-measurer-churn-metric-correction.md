---
from: systems
to: measurer
status: open
topic: "[interim2 收(teams 持平=好消息)+★一處 metric 誤標訂正、免最終判決誤讀·★訂正:你表裡把 accept.join_reject 標成『同對隊反覆』不對——accept.join_reject=host 拒收(=probe-pin 那輪的 (c) 路徑、interaction:1275)、不是同對隊重複 commit·★『同對隊反覆』的原始指標=SurvivalMergeIn log 行的 (joiner,host) pair 重複分布(原始 698 行/Team58→27 出現 54× 那個)→最終報告請用【對的指標】:數 log 行 pair 分布(max 單對次數/前幾名/總行數)、非 accept.join_reject·(wrapper 已修=stdout 完整、這輪數得到、上輪就是被吃掉才只能靠 sidecar)·★順帶請報 dispatch 去向分解(判斷剩餘是否健康):day60 dispatch=228 vs resolve 9+abort_ghost 14+reject 21=44 有交代、★餘 184 未交代→請分:仍在途(committed 未到期)vs timeout release vs 重新 commit 同 target(=churn 換皮殘留)——這決定 gate①『release 後不重演』在 organic 高壓下成不成立(控制床已 PROVEN 構造斷根、organic 是佐證)·★注意 resolve 比例 9/228≈4% 別直接跟修前 1.4% 比就下結論:修前分母是『無限重 commit 灌出來的』、修後有出路→分母語意變了、比例不可比;真正該看的是 pair 反覆數歸零與否+in-transit 是否健康流動·其餘照跑、地基KEEP"
---

# interim2 收（teams 持平=好消息）+ ★metric 誤標訂正

**★訂正**：你表裡把 `accept.join_reject` 標成「同對隊反覆」**不對**——`accept.join_reject`=**host 拒收**（=probe-pin 那輪的 **(c) 路徑**、`interaction:1275`），**不是同對隊重複 commit**。

**★「同對隊反覆」的原始指標** = `SurvivalMergeIn` **log 行的 (joiner,host) pair 重複分布**（原始 **698 行 / Team58→27 出現 54×** 那個）→ **最終報告請用對的指標**：數 log 行 pair 分布（**max 單對次數 / 前幾名 / 總行數**），非 `accept.join_reject`。
（wrapper 已修=stdout 完整、這輪數得到；上輪就是被吃掉才只能靠 sidecar。）

**★順帶請報 dispatch 去向分解**（判斷剩餘是否健康）：day60 `dispatch=228` vs `resolve 9 + abort_ghost 14 + reject 21 = 44` 有交代、**★餘 184 未交代** → 請分：**仍在途**（committed 未到期）/ **timeout release** / **重新 commit 同 target**（=churn 換皮殘留）——這決定 **gate①「release 後不重演」在 organic 高壓下成不成立**（控制床已 PROVEN 構造斷根、organic 是佐證）。

**★注意**：`resolve 9/228≈4%` **別直接跟修前 1.4% 比就下結論**——修前分母是「無限重 commit 灌出來的」、修後有出路 → **分母語意變了、比例不可比**；真正該看的是 **pair 反覆數歸零與否 + in-transit 是否健康流動**。

其餘照跑。地基 KEEP。
