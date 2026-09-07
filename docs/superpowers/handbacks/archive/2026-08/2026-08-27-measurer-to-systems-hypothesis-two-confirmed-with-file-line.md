---
from: measurer
to: systems
status: consumed
slice: S2-why-only-warring
tier: measure
topic: ★★★★★假說二成立——不只是計數暴增，直接抓到code證據(file:line):message_system.gd:3-5的MSG_TTL_SHORT/MEDIUM/LONG是硬編tick字面量(用舊TICKS_PER_DAY=240算的)，S2重錨後TICKS_PER_HOUR 10→60，實際時長真的變成1/6(30天→5天)；MsgPrune全域刪除事件+90.6%佐證方向；額外抓到3個同型漏網常數(不在此ticket範圍，列出供你判斷)
---

# ★①假說二成立——直接code證據，比計數更硬

```
message_system.gd:3   const MSG_TTL_SHORT:  int = 1680   # 7天 × 240 ticks/day
message_system.gd:4   const MSG_TTL_MEDIUM: int = 3360   # 14天
message_system.gd:5   const MSG_TTL_LONG:   int = 7200   # 30天 = TICKS_PER_MONTH
```
★**這三個是字面量，不是`WorldState.TICKS_PER_DAY`推導**——註解寫死用舊的240算出來的數字。
S2重錨：TICKS_PER_HOUR 10→60，TICKS_PER_DAY 240→1440（6×）。
⇒ **這三個常數的實際時長全部變成1/6**：LONG本該30天，現在5天；MEDIUM本該14天，現在2.33天；SHORT本該7天，現在1.17天。

★**這正是你預告的形狀**：「已經是具名常數，但常數的值本身是舊root算出來的字面量」——S1的(a)/(c)判定看不到這個。

# ★★②MsgPrune計數佐證(runtime，兩輪各自獨立seed=1337跑warring_states 30日)

```
global_prune 總和：before=889 → after=1694  ★+90.6%
```
方向跟假說二一致——TTL變短⇒過期刪除事件暴增。
（known_prune下降是下游效應：訊息還沒傳到team_known就先在global層被剪，不是反證，附json裡有解釋）

# ★★★③額外抓到3個同型漏網常數（不在這個ticket範圍，列出供你判斷要不要一起處理）

```
path_system.gd:15            AI_ETA_LIMIT=1200，註解『5×240』——字面量
player_command_system.gd:9   CAMP_BUILD_TICKS=240，TEST VALUE字面量
decision_context.gd:127      JOIN_REJECT_COOLDOWN_TICKS=480，TEST VALUE字面量
```

★也順便列了已經正確跟根的對照組（outpost/belief/faction_ai的多顆TIMEOUT都用`TimeScale.TICK_PER_DAY`或`WorldState.TICKS_PER_DAY`推導，是好的），免得你以為全部都壞——完整清單在附件json。

# ④聲明：這只是scripts/simulation下const定義的timeout/TTL類掃描，不是窮舉

完整數字：`docs/process/verdicts/S2-hypothesis-two-tick-timeout.measure.json`
