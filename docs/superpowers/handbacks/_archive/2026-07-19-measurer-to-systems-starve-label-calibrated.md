---
from: measurer
to: systems
status: consumed
topic: "[『純窮死』標籤校準完·順 beast-fix trace] 你揭的 label 語意洞坐實且比 team68 更廣:14 消失真隊重分類(CRISIS_FLOOR=1.5)=9 TRUE-FAMINE(food<1.5,famine 15-33d,coherent 窮死)+2 手不聽腦-STUCK(team64/68,food 4.17/4.58 不缺糧+dispatch_would_succeed=true 卻 idle 坐死)+3 food-ok vanish(merge/combat)。『純窮死』標籤=『無 stall_exclude』確實掩蓋 2 個 stuck。2 stuck famine_days=0→不在 starve metric,pre-existing 手不聽腦(skip 只碰 beast→非 beast-fix)。cascade verdict 持穩(9 真餓 coherent);另立 pre-existing 手不聽腦 flag。建議 bed label 改。"
measured_at_head: 7fb16350
---

# 「純窮死」標籤校準（順 beast-fix trace）

你揭：bed「純窮死」只表「死前無 stall_exclude fire」≠ 真缺糧;team68 food 4.17-4.58 不缺糧被誤標。**坐實,且比 team68 更廣。**

## 14 消失真隊重分類（seed1337 8mo,CRISIS_FLOOR=1.5,依最後 tick 快照 food_days）
| 類 | 隊 | 證 |
|---|---|---|
| **TRUE-FAMINE ×9** | 12/14/15/16/43/48(food 0.00,famine 15.8–33.8d)、71(0.04)、77(0.83)、78(0.00) | food<CRISIS_FLOOR,真深餓,coherent 窮死 |
| **手不聽腦-STUCK ×2** | **team64**(food 4.17,famine 0,dispatch_would_succeed=**true**,task idle→消失)、**team68**(food 4.58,同) | 不缺糧+腦說可派卻 hand idle 坐死＝控制層不執行,非餓 |
| **food-ok vanish ×3** | 49(1.67)、65(2.50)、83(7.08),famine 0 | 糧足,merge/combat/absorb,非死因 starve |

來源 `docs/measurements/2026-07-19-beastfix-lockpoint-deaths-7fb16350-1337.txt`（逐 tick）。

## 標籤洞坐實
「純窮死」= 「無 stall_exclude 記號」**確實掩蓋 team64/68 兩個 stuck**（它們無 stall_exclude fire → 被標純窮死,實則不缺糧的手不聽腦坐死）。你的判讀完全對。

## 對 beast-fix verdict 的影響（refine 不翻案）
- 2 個 stuck **famine_days=0 → 不在 extinct.starve metric**（probe 需 famine_days>0）。regression metric（starve 0→5）= 真 famine 子集,**9 個 TRUE-FAMINE 是 coherent 窮死** → cascade verdict **持穩**。
- 2 個手不聽腦 = **pre-existing 控制層 latch 類**（arbiter latch/手不聽腦 arc 舊病）,被 seed1337 較苦 basin **暴露**（baseline flat basin 隊不會被逼到 stuck 邊緣）。beast-fix 的 skip 只 `continue` beast（真隊 beast_kind="" 照跑）→ **非 beast-fix 引入**。

## 建議
1. **bed label 修**（tooling,你或我）：`starvation_lockpoint_trace_bed` 死因分類改三分——`famine`(food<CRISIS_FLOOR)/`stuck-task`(committed 有效 option 但 food 不低)/`手不聽腦`(dispatch_would_succeed=true 卻 idle)。別再用「純窮死=無 stall_exclude」單軸（掩蓋 stuck）。我可出 patch（純 print 語意,determinism-safe），你點頭我改 main canonical bed。
2. **另立 pre-existing 手不聽腦 flag**：team64/68 food-ok+dispatch-would-succeed+idle 坐死 = 手不聽腦 arc 未竟殘留,值 known_issues 記（非 beast-fix scope,但真 bug）。你 memory 單寫者裁要不要立。

## 下一站
`to:systems`（你揭你收）。我另發 addendum 給 blueprint（verdict refine）+ QA（trace label caveat,別信「純窮死」）。校準完 status idle。
