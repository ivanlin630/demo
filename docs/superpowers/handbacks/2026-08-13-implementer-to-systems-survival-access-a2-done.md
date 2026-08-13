---
from: implementer
to: systems
status: consumed
topic: "[slice A2 DONE·feat/survival-access-a2 commit 628b9894]拓寬 invite 候選(佔據率主槓桿、行為變 slice)·單點 _try_invite_nearby_exile:600 filter:if not(流亡 in tags):continue → if tags.has(PRODUCE) or parent≠-1 or combat_target≠-1 or task==攻擊:continue(排 已settled/子隊/戰鬥/active raider、含 idle merchant/ex-mil drifter 可邀、accept 靠 invitee diplomacy)·pop gate MIN_PARENT_POP_AFTER_DISPATCH 保留·★驗:invite_widen_test ALL PASS(①流亡 regression②非生產遊蕩+merchant 新拓寬③戰鬥/攻擊 war-band 排除④生產隊/子隊排除)+headless 0-new+constitution 75+determinism 3-run byte-identical(warring 678b3ee3)·感知鐵律(讀 tags+belief_pos 不動、不讀 live god-view)、零新 RNG、fp intended-change·★measurer 量測請求:佔據率 baseline 6.4%→顯著升 AND 不 over-invite churn(settle 不爆量/team_n 不失控)·請 merge-gate 硬讀→measurer→綠 merge→dispatch A3"
branch: feat/survival-access-a2
commit: 628b9894
---

# slice A2 DONE — 拓寬 invite 候選（佔據率主槓桿）

feat/survival-access-a2 commit `628b9894`（off main HEAD d9a05cff；已 push）。diagnostic CLOSE：invite 路 filter 太窄、dispatch 路 pop gate（genuine 保留）。

## ★citation 訂正納入
流亡 tag **≥4 producer**（faction_ai:5163 / event_tag_shift:14 / population_system:60 / reaction_system:320）；invite 250/250 零命中 = EMPIRICAL 樣本無流亡 wanderer（**非結構不可能**）。

## fix（單點 `_try_invite_nearby_exile`:600 filter 收窄版）
```
- if not ("流亡" in t.tags): continue
+ if t.tags.has(TeamData.TAG_PRODUCE) or t.parent_team_id != -1 \
+     or t.combat_target != -1 or t.current_task == TeamData.TASK_ATTACK:
+     continue
```
領主可邀**非生產非戰鬥遊蕩團**（含 idle merchant / ex-military drifter）進自家空 outpost；排 已 settled 生產隊 / 子隊 / 戰鬥中 / 攻擊掠奪中（active raider 語意 mismatch）。**最終 accept 靠 invitee diplomacy 決策**（不適者自拒）。dispatch pop gate `MIN_PARENT_POP_AFTER_DISPATCH=10` + invite belief range/diplomacy/cooldown 不動。

## 命門守
感知鐵律（讀 `t.tags` 同既有 pattern + belief_pos range 不動、**不讀 `is_resident_static` live god-view**）、零新 RNG。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `invite_widen_test` | **ALL PASS**：①流亡 wanderer 邀得到（regression）②非生產非戰鬥遊蕩團 + idle merchant 邀得到（★新拓寬）③戰鬥中(combat_target≠-1)/攻擊 war-band 不被邀（語意排除）④生產隊/子隊(parent≠-1)不被邀 |
| headless | **0-new** |
| constitution_gate | **PASS sites=75** |
| determinism | **3-run byte-identical**（warring seed1337 1000t FP `678b3ee3`；讀 tags 無 RNG） |

fp **intended-change**（invite 候選變寬）；warring 1000t invite 路徑 dormant（無 wanderer settle）→ whole-sim 分化在 vagrant-rich 床。

## ★measurer 量測請求（bounded、綠才 merge）
- **佔據率** baseline **6.4% → 顯著升**（A2 arc 目標）。
- **不 over-invite churn**（settle 不爆量、不反覆 invite-abandon、team_n 不失控）。realistic vagrant-rich 床。
- determinism/regression/constitution 綠（已達）。

## 路
1. **你 merge-gate 硬讀**（filter 收窄版排 active-raider + 保 pop gate + 感知鐵律不讀 live + 設計選擇[遊蕩皆可邀、accept 靠 diplomacy]）。
2. → measurer bounded（佔據率升 AND 不 over-invite）→ 綠 merge → dispatch A3。地基 KEEP。

（perf/F2 disk flag 續。）
