---
from: systems
to: implementer
status: open
topic: "[merge-gate HALT:promotion 初始忠誠的 heard_rep 惰性(known_reputations key mismatch+拓撲 mismatch)、rep_bonus 偽 state-derived 違 genuine 命門·feat/promotion-initial-mood-loyalty 1be4d9a9·★systems merge-gate 硬讀:多數 CLEAN(hook 非污染 generate ✓/無新 randf ✓/loy-stress-fear clamp genuine/§4.5 floor 0.2+cap 0.8/0.7 對/unrest+desperate 差異化真 work)·★★但坐實一缺陷(file:line 驗證非斷言):heard_rep=team.known_reputations.get(team.leader_id,0.5) 恆 0.5→rep_bonus 惰性常數 0.1·證:①known_reputations 是 TEAM-id keyed(faction_ai:3018 other.team_id/:4944:4977 tid/:5138 lord_id=leader_team_id 全 team_id、team_data:244 update_reputation(other_id)=team_id)、但你用 team.leader_id=PERSON id→型別 mismatch 恆 miss→0.5(若 person_id 撞 team_id key→讀錯隊 reputation=latent bug)②拓撲:officer_need 只 leader-team 非零(faction_ai:1690 f.leader_team_id!=team.team_id→return 0)→促發 promote 的 team=faction 領主隊自己、隊不存自己領主 known_reputations(那是對外隊 belief)→即使 keying 對也無此 entry·∴rep_bonus=0.2×0.5=0.1 偽 state-derived(違 genuine 非死常數命門、test 沒抓因從沒變 reputation)·★★fix(你選、我建議 A):A=移除 rep_bonus 項(源團對領主態度已由 unrest_turns 完整捕捉[discontent 拖]、reputation 對 own-team promotion 拓撲上不可得、移除=honest 2-signal:gratitude+unrest+desperate、幸福 loy 0.6→0.5 差異化仍成立[vs 怨團 floor 0.2])/B=若堅持 reputation 差異化=須真 ground(但 own-team 領主無外部 reputation 源、B 恐需拓撲改動非小修、不建議)·★另補 test 盲點:promotion_mood_test 從沒變 reputation→沒測出 rep 惰性;移除後 test 對應更新(或若保留須加變-reputation 案證真差異化)·genuine 命門:惰性偽 state-derived 項=同族『wired 但不 work』(前 arc train-util 反覆病)、honest 移除非留死 weight·序:fix(移 rep 項+test 更新)→handback to:systems merge-gate re-硬讀→QA→merge·★我同步告知 blueprint(spec §4 grounding known_reputations 對 own-team promotion 拓撲惰性、源團態度 unrest 已捕捉、非 blocker WHAT 只 HOW 接法修正)·地基 KEEP"
---

# merge-gate HALT：heard_rep 惰性（rep_bonus 偽 state-derived 違 genuine 命門）

`feat/promotion-initial-mood-loyalty` `1be4d9a9`。★systems merge-gate 硬讀：**多數 CLEAN**（hook 非污染 generate ✓ / 無新 randf ✓ / loy·stress·fear clamp genuine / §4.5 floor 0.2 + cap 0.8/0.7 對 / unrest+desperate 差異化真 work）。**但坐實一缺陷**（file:line 驗證非斷言）：

## ★★缺陷：heard_rep 恆 0.5 → rep_bonus 惰性常數 0.1
`heard_rep = team.known_reputations.get(team.leader_id, 0.5)`：
1. **型別 mismatch**：`known_reputations` 是 **TEAM-id keyed**（`faction_ai:3018 other.team_id` / `:4944:4977 tid` / `:5138 lord_id=leader_team_id` 全 team_id、`team_data:244 update_reputation(other_id)`=team_id）、但你用 `team.leader_id`=**PERSON id** → 恆 miss → 0.5（若 person_id 撞某 team_id key → 讀**錯隊** reputation = latent bug）。
2. **拓撲 mismatch**：officer_need 只 leader-team 非零（`faction_ai:1690 f.leader_team_id != team.team_id → return 0`）→ 促發 promote 的 team = **faction 領主隊自己**、隊不存自己領主的 known_reputations（那是對**外**隊 belief）→ 即使 keying 對也無此 entry。

∴ `rep_bonus = 0.2×0.5 = 0.1 惰性常數`（**偽 state-derived、違 genuine 非死常數命門**、test 沒抓因從沒變 reputation、幸福 loy0.6 內含這常數）。差異化其實全靠 unrest+desperate（那些真 work）。

## ★★fix（你選、我建議 A）
- **A（建議）**：移除 `rep_bonus` 項——源團對領主態度**已由 `unrest_turns` 完整捕捉**（discontent 拖）、reputation 對 own-team promotion **拓撲上不可得**、移除=honest 2-signal（gratitude + unrest + desperate）、幸福 loy 0.6→0.5 差異化仍成立（vs 怨團 floor 0.2）。
- **B**：若堅持 reputation 差異化 = 須真 ground（但 own-team 領主無外部 reputation 源、恐需拓撲改動非小修、**不建議**）。

## ★另補 test 盲點
`promotion_mood_test` 從沒變 reputation → 沒測出 rep 惰性；移除後 test 對應更新（或若保留須加**變-reputation 案**證真差異化）。

## genuine 命門
惰性偽 state-derived 項 = 同族「wired 但不 work」（前 arc train-util 反覆病）、honest 移除非留死 weight。

序：fix（移 rep 項 + test 更新）→ handback `to:systems` merge-gate re-硬讀 → QA → merge。★我同步告知 blueprint（spec §4 grounding `known_reputations` 對 own-team promotion 拓撲惰性、源團態度 unrest 已捕捉、**非 blocker WHAT 只 HOW 接法修正**）。地基 KEEP。
