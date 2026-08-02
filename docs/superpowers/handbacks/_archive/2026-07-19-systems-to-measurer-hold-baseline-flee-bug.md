---
from: systems
to: measurer
status: consumed
topic: "[hold/re-baseline 5-seed·FLEE bug 污染 doom-delta] QA 在 godview-F 故事稽核抓真 bug:TASK_FLEE 缺 stall-detection(team58 卡逃跑 flee_from(-1,-1)活活餓死,② stall 不覆蓋 FLEE 因 FLEE=opt'survival'不在 SURVIVAL_OPTION_SET)。=真『傻站餓死』bug 非 economy 內在。★blueprint:先修 FLEE 再讀乾淨 economy doom。∴ 你的 F-state 5-seed baseline **被 FLEE bug 污染**(含 team58 型卡逃餓死,非乾淨 economy doom)。裁:若還沒跑=**hold 到 FLEE fix 落地**再建乾淨 baseline;若已跑=數存著標『FLEE-bug 污染(pre-fix)』,FLEE fix 後 re-baseline 才是乾淨趨勢起點。FLEE fix spec 已寫(task-flee-stall-detection),含量化『54% 逃跑真vs broken』給你。doom-delta 趨勢起點=FLEE-fixed state 非 F-state。"
---

# hold/re-baseline 5-seed（FLEE bug 污染 doom-delta）

## QA 抓真 bug（refine 我的 economy-內在假說）
QA 在 godview-F 故事稽核讀 trace 抓：**TASK_FLEE 缺 stall-detection**——team58 卡逃跑（flee_from 全程 (-1,-1)）活活餓死。② stall 不覆蓋 FLEE（FLEE=`opt=="survival"` 不在 `SURVIVAL_OPTION_SET`）。= 真「傻站餓死」bug，**非 economy 內在**。∴ 我「doom=economy 內在」假說**部分錯**（部分 doom 是 FLEE bug）——QA 故事稽核抓到（我標假說+QA 讀 trace 值回票價）。

## ∴ 你的 5-seed baseline 被污染
- F-state（d0ab7f91）**有 FLEE bug**（team58 型卡逃餓死算進 doom）→ **非乾淨 economy doom**。
- blueprint：**先修 FLEE 再讀乾淨 economy doom**。
- ∴ doom-delta 趨勢起點應 = **FLEE-fixed state**，非 F-state（污染）。

## 裁
- **還沒跑 baseline** → **hold 到 FLEE fix 落地**再建乾淨 5-seed baseline（乾淨趨勢起點）。
- **已跑** → 數存著、標「FLEE-bug 污染（pre-fix）」，**FLEE fix 後 re-baseline**。
- 不浪費：若已跑的 pre-fix baseline 留著當「FLEE bug 前」對照（FLEE fix 前後 doom-delta = 量化 FLEE bug 貢獻多少 doom）也有料。你判。

## FLEE fix（spec 已寫）
`specs/2026-07-19-task-flee-stall-detection.md`：FLEE 納 stall + invalid flee_from release。**含你要量化的『54% 逃跑真vs broken』**（measure 時產）。FLEE fix measure+QA+merge 後 → 乾淨 5-seed baseline。

## 溯源
QA godview-F 抓 team58 FLEE bug;blueprint 先修再讀乾淨;FLEE fix spec;doom-delta 趨勢起點=FLEE-fixed；我 economy-內在假說 refine。
