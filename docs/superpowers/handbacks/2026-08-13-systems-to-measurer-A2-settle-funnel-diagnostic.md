---
from: systems
to: measurer
status: open
topic: "[A2 diagnostic-first:pin settle-into-existing convert=0 斷在哪 gate(blueprint 裁 A2=佔據率主槓桿、diagnostic-first 禁猜)·systems code-read narrow 出 funnel(faction_ai:541-571):_evaluate_outpost_residency 只掃自家 outpost(outpost_owner==team+not has_resident+not inflight)→_try_dispatch_or_invite(dispatch_score 野心0.5+好戰0.3 vs invite_score 商業0.4+慎重0.3、pop≥8 派子隊_dispatch_subteam_settle:574 else 邀流亡_try_invite_nearby_exile:597)→TASK_SETTLE→travel→_convert_to_resident:1963·★instrument per-gate funnel counter(temp Probe tap 用完 revert)pin dominant drop:①top:有幾團進 _evaluate 迴圈(擁自家空 outpost 的團數;若≈0=root=沒團擁空 outpost 可填、wanderer 擁 0 據點根本不進此路)②pop≥8 pass/fail(小團 pop1-7 被擋?panel 顯示 resident pop 多 1-3)③dispatch vs invite split④dispatch 路:_dispatch_subteam_settle pop-after-settler gate(:576 MIN_PARENT_POP_AFTER_DISPATCH)pass?⑤invite 路:鄰近流亡 in belief INVITE_RANGE8 found?/accept?/try_set success?⑥funnel:TASK_SETTLE set count→arrive outpost count→_convert count(哪段掉)·★fold founding-path 線索(blueprint 令 A2 內加 instrument 量完再評是否第三槓桿):establish_crude_camp fire count+desperation 門檻 context(空地 founding 走這條非 argmax)·★關鍵假設待驗(禁預設):settle-into-existing 要求先擁空 outpost=wanderer(91%無據點)結構上不進此路→真 lever 可能是『wanderer 如何取得/被邀進 outpost』非 owner-dispatch·量完 pin dominant→systems spec fix·官方 helper 勿手設 team_ids、先讀既有 dump·evidence-only 禁預設·地基 KEEP"
---

# A2 diagnostic-first — pin settle-into-existing convert=0 斷在哪 gate

blueprint 裁 A2=佔據率主槓桿、**diagnostic-first 禁猜**（同 gather-yield 手法）。systems code-read narrow 出 funnel、measurer instrument pin。evidence-only、禁預設。

## funnel（faction_ai:541-571、systems code-read）
`_evaluate_outpost_residency`（:541、只掃**自家** outpost `outpost_owner==team` + not has_resident + not inflight）→ `_try_dispatch_or_invite`（:554）→ dispatch(`pop≥8`→`_dispatch_subteam_settle`:574) / invite(`_try_invite_nearby_exile`:597) → TASK_SETTLE → travel → `_convert_to_resident`:1963。

## ★instrument per-gate funnel（temp Probe tap 用完 revert、pin dominant drop）
1. **★top**：幾團進 `_evaluate` 迴圈（擁**自家空 outpost** 的團數）？**若 ≈0 = root**（沒團擁空 outpost 可填；wanderer 擁 0 據點**結構上不進此路**）。
2. **pop≥8** pass/fail（小團 pop1-7 被擋？panel 顯示 resident pop 多 1-3）。
3. **dispatch vs invite** split（personality 分流）。
4. **dispatch 路**：`_dispatch_subteam_settle` pop-after-settler gate（:576 `MIN_PARENT_POP_AFTER_DISPATCH`）pass？
5. **invite 路**：鄰近流亡 in belief `INVITE_RANGE`=8 found？/ accept？/ `try_set` success？
6. **funnel 尾**：`TASK_SETTLE` set count → arrive outpost count → `_convert` count（哪段掉）。

## ★fold founding-path 線索（blueprint 令、量完再評是否第三槓桿）
`establish_crude_camp` fire count + desperation 門檻 context（空地 founding 走這條、非 argmax option）。

## ★關鍵假設待驗（禁預設）
settle-into-existing **要求先擁空 outpost** → wanderer（91% 無據點）**結構上不進此路** → 真 lever 可能是「**wanderer 如何取得/被邀進 outpost**」（=invite 路 or 別的）非 owner-dispatch。量完 pin dominant drop。

量完 → systems spec fix（打 dominant gate）。官方 helper 勿手設 `specimen_team_ids`、先讀既有 dump。地基 KEEP。
