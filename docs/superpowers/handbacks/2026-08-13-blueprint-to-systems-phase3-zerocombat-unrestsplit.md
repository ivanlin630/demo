---
from: blueprint
to: systems
status: consumed
topic: "[QA完整故事揪新大洞→派兩診斷(measure-first無fork)+更新famine圖·★#新A[最大新沒道理]戰國情境兩月零戰死(death.combat_pop=0)但月1 intent CONQUER×4/DEFEND×8=有征服意圖卻零實戰死=征服意圖不轉致命戰鬥=興衰動力死(該打→贏家壯大→立國→有大有小的第一環斷)·診斷why(禁預設genuine-vs-bug):①combat根本不initiate(conquer intent→無encounter?)②encounter有但被force-draw(★候選:bed phase3_longterm_story_audit_bed:76 `encounter_tick>800→resolve draw`watchdog=可能床artifact把慢戰全判和局→零死、須先排除是不是床的鍋非世界的鍋)③combat有initiate有resolve但非致命(pop不掉)·pin哪段斷→這可能是『世界不興衰只餓死』上游真根(比#3①立國門檻更上游:沒戰爭就沒強者就沒立國候選)·★#新B[cheap tap-gap同#2型態]49→130隊暴增最可能event_unrest_split(高unrest真分裂)但zero Probe tap不可測→補tap(event_unrest_split.gd create_team後bump spawn.unrest_split、同已merged clear_team_faction tap-gap修法)證實/證偽碎裂主因+量碎片是否餓死主體·★famine圖更新(QA佐證):combat_pop=0→死亡全餓死、8抽樣6餓死弧2存活(T42復甦10→15、T6 defect時food0.7回彈=defect解資源負擔genuine)、T24 food平台段未明→併入measurer在飛的famine genuine-vs-bug中性診斷一起看·★(a)established=0=刻意設計(既有勢力也套立國gate、8領主cmd≤0.335無一近0.4)非測量錯、(b)領袖帶隊誤讀撤回(member_n=faction隊數非領袖隊人數)·序:零戰死pin(先排除床watchdog artifact)+unrest-split tap→回我;famine診斷續;#3①待用戶(現reframe:零戰死可能更上游)·地基KEEP·禁預設"
---

# QA 完整故事揪新大洞 → 派兩診斷 + 更新 famine 圖

## ★#新A[最大新沒道理]戰國兩月零戰死
`death.combat_pop=0`（兩月）但月1 intent `CONQUER×4 / DEFEND×8` = **有征服意圖、卻零實戰死** = 征服意圖不轉致命戰鬥。→ **興衰動力死**（該打→贏家壯大→立國→有大有小的第一環就斷了）。
診斷 why（禁預設 genuine-vs-bug）：
1. combat 根本不 initiate（conquer intent → 無 encounter?）
2. encounter 有、但被 **force-draw**（★候選:bed `phase3_longterm_story_audit_bed.gd:76` `encounter_tick>800 → resolve draw` watchdog = **可能床 artifact 把慢戰全判和局 → 零死**、★須先排除是床的鍋非世界的鍋）
3. combat 有 initiate 有 resolve、但非致命（pop 不掉）
→ pin 哪段斷。★這可能是「世界不興衰只餓死」的**上游真根**（比 #3① 立國門檻更上游:沒戰爭 → 沒強者 → 沒立國候選）。

## ★#新B[cheap tap-gap、同 #2 型態]49→130 暴增
最可能 = `event_unrest_split`（高 unrest 真分裂）但 zero Probe tap 不可測 → **補 tap**（`event_unrest_split.gd` create_team 後 bump `spawn.unrest_split`、同已 merged 的 clear_team_faction tap-gap 修法）證實/證偽碎裂主因 + 量碎片是否餓死主體。

## famine 圖更新（QA 佐證、併入 measurer 在飛的 famine genuine-vs-bug）
combat_pop=0 → 死亡全餓死;8 抽樣 6 餓死弧、2 存活（T42 復甦 10→15、T6 defect 時 food 0.7 回彈 = defect 解資源負擔 genuine);T24 food 平台段未明。→ 併入 measurer 中性診斷一起看。

## QA 澄清（收）
(a) established=0 = 刻意設計（既有勢力也套立國 gate、8 領主 cmd≤0.335 無一近 0.4）非測量錯。(b) 領袖帶隊「矛盾」= 我誤讀撤回（member_n=faction 隊數非領袖隊人數）。

序:零戰死 pin（先排除床 watchdog artifact）+ unrest-split tap → 回我;famine 診斷續;#3① 待用戶（reframe:零戰死可能更上游）。地基 KEEP。禁預設。
