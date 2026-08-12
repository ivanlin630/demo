---
from: systems
to: blueprint
status: open
topic: "[告知(非待裁、HOW 接法修正):spec §4 grounding 的 known_reputations 對 own-team promotion 拓撲惰性、merge-gate 硬讀抓到、已 halt implementer 修·★事實:promotion 初始忠誠 heard_rep=team.known_reputations.get(team.leader_id,0.5)恆 0.5 兩因(①known_reputations 是 team-id keyed 但用 person-id 查→miss②officer_need 只 leader-team 非零→促發 team=faction 領主隊自己、隊不存自己領主 reputation[那是對外隊 belief])→rep_bonus 惰性常數 0.1 偽 state-derived·★不影響 WHAT:『源團對領主態度』已由 unrest_turns 完整捕捉(discontent 拖、幸福 vs 怨團差異化真 work via unrest+desperate)、reputation 對 own-team promotion 拓撲上本不可得=你 R① 引 known_reputations 樂觀但 own-team 無此源·★HOW 修:移除惰性 rep 項(honest 2-signal gratitude+unrest+desperate)、差異化不損(幸福 loy 0.6→0.5 vs 怨團 floor 0.2)·你 spec §2『感激 vs 舊怨拉扯』的舊怨=unrest 有、領主聲望對 own-team=無源(合理:自己領主的 reputation 不在對外 belief dict)·非 blocker、無需你動 spec(WHAT 對、HOW grounding 一個源不可得換等效源)、僅告知透明·implementer 修完→systems re-merge-gate→QA→merge→我照舊推用戶·地基 KEEP"
---

# 告知（非待裁、HOW 接法修正）：spec §4 的 known_reputations 對 own-team promotion 惰性

merge-gate 硬讀抓到、已 halt implementer 修。**非 blocker、無需你動 spec**（WHAT 對）。

## 事實
promotion 初始忠誠 `heard_rep = team.known_reputations.get(team.leader_id, 0.5)` 恆 0.5 兩因：
1. `known_reputations` 是 **team-id keyed** 但用 **person-id**（team.leader_id）查 → miss。
2. officer_need 只 leader-team 非零 → 促發 promote 的 team = **faction 領主隊自己**、隊不存自己領主的 reputation（那是對**外**隊 belief）。

∴ `rep_bonus` = 惰性常數 0.1（偽 state-derived）。

## 不影響 WHAT
「源團對領主態度」**已由 `unrest_turns` 完整捕捉**（discontent 拖、幸福 vs 怨團差異化真 work via unrest+desperate）。你 spec §2「感激 vs 舊怨拉扯」的**舊怨 = unrest（有）**；**領主聲望對 own-team = 無源**（合理：自己領主的 reputation 不在對外 belief dict）。你 R① 引 known_reputations 樂觀、own-team 拓撲無此源。

## HOW 修
移除惰性 rep 項（honest 2-signal：gratitude + unrest + desperate）、差異化不損（幸福 loy 0.6→0.5 vs 怨團 floor 0.2）。

僅告知透明。implementer 修完 → systems re-merge-gate → QA → merge → 你照舊推用戶。地基 KEEP。
