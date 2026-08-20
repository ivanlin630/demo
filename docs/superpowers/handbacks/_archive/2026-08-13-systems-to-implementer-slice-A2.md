---
from: systems
to: implementer
status: consumed
topic: "[dispatch slice A2(佔據率主槓桿=拓寬invite候選、R² CLEAN+2訂正已納)·★★citation訂正(我over-claim、誠實收):『流亡tag只faction_ai:5194專屬』=錯,實≥4 producer(faction_ai:5163 uprising_exile/event_tag_shift:14 gain_exile/population_system:60 overflow_split/reaction_system:320 solo_exile);invite 250/250零命中是EMPIRICAL(這批樣本剛好沒流亡wanderer)非『結構不可能』·★fix(單點_try_invite_nearby_exile:600 filter收窄版、R²要求排combat-active免邀劫掠war-band當居民):`if not(\"流亡\" in t.tags): continue`→`if t.tags.has(TeamData.TAG_PRODUCE) or t.parent_team_id!=-1 or t.combat_target!=-1 or t.current_task==TeamData.TASK_ATTACK: continue`(排:已settled生產隊/子隊/戰鬥中/攻擊掠奪中);設計選擇明記=非生產非戰鬥的遊蕩團(含idle merchant/ex-military drifter)皆可邀、最終accept靠invitee diplomacy決策(不適者自拒)、只硬排active-raider語意mismatch·dispatch pop gate(MIN_PARENT_POP_AFTER_DISPATCH=10)保留genuine不動·★invariant:感知鐵律(讀t.tags同既有pattern+belief_pos range不動、不讀is_resident_static live位)、零新RNG、fp intended-change(invite候選變寬=行為有意改)·★TDD:①現況流亡team邀得到(regression)②非生產遊蕩wanderer(no PRODUCE/no combat)現在邀得到(新)③戰鬥中war-band(combat_target≠-1或task=攻擊)不被邀(語意排除)④生產隊/子隊不被邀·★量測gate(measurer bounded、綠才merge):佔據率baseline6.4%→顯著升 AND 不over-invite churn(settle不爆量/不反覆invite-abandon)·worktree feat/survival-access-a2 base現main·完→handback to:systems附measurer量測請求·地基KEEP"
---

# dispatch slice A2 — 拓寬 invite 候選（佔據率主槓桿、R² CLEAN + 2 訂正已納）

diagnostic CLOSE：dispatch 路卡 pop gate（genuine 保留）、invite 路卡 filter 太窄。

## ★★citation 訂正（我 over-claim、誠實收）
先前說「流亡 tag 只 faction_ai:5194 專屬」= **錯**。實際 **≥4 producer**：faction_ai:5163（uprising_exile）/ event_tag_shift.gd:14（gain_exile）/ population_system.gd:60（overflow_split 人口溢出）/ reaction_system.gd:320（solo_exile）。invite 250/250 零命中是 **EMPIRICAL**（這批樣本剛好沒流亡 wanderer）**非「結構不可能」**。（第 2 次 over-claim、reviewer 抓、守 measure-first 誠實。）

## ★fix（單點 `_try_invite_nearby_exile`:600、收窄版）
```
- if not ("流亡" in t.tags): continue
+ if t.tags.has(TeamData.TAG_PRODUCE) or t.parent_team_id != -1 \
+     or t.combat_target != -1 or t.current_task == TeamData.TASK_ATTACK:
+     continue   # 排:已settled生產隊/子隊/戰鬥中/攻擊掠奪中(active raider 非居民候選)
```
= 領主可邀**非生產非戰鬥的遊蕩團**進自家空 outpost。

**★設計選擇明記**（R² 必查項 b）：非生產非戰鬥的遊蕩團（**含 idle merchant / ex-military drifter**）皆可邀；**最終 accept 靠 invitee diplomacy 決策**（不適者自拒）；**只硬排 active-raider**（combat_target≠-1 或 current_task=攻擊）= 語意 mismatch（邀劫掠中 war-band 當安分居民怪）。invite 其餘（belief range/diplomacy/cooldown/try_set）不動。

## ★保留 genuine
dispatch pop gate `MIN_PARENT_POP_AFTER_DISPATCH=10`（小領主不掏空自己分 settler）不動。

## ★invariant
- **感知鐵律**：讀 `t.tags` 同既有 pattern + belief_pos range 不動、**不讀 `is_resident_static` live 位**（god-view）。
- 零新 RNG；fp 標 **intended-change**（invite 候選變寬=行為有意改）。

## ★TDD
1. 現況流亡 team 邀得到（regression）。
2. 非生產遊蕩 wanderer（no PRODUCE / no combat）現在邀得到（新）。
3. 戰鬥中 war-band（combat_target≠-1 或 task=攻擊）**不被邀**（語意排除）。
4. 生產隊 / 子隊不被邀。

## ★量測 gate（measurer bounded、綠才 merge）
- **佔據率** baseline 6.4% → **顯著升**（A2 arc 目標）。
- **不 over-invite churn**（settle 不爆量、不反覆 invite-abandon、team_n 不失控）。

## worktree
`feat/survival-access-a2`、base 現 main。code 寫 worktree、handback 寫 main mailbox 絕對路徑。完 → handback to:systems（附 measurer 量測請求）。

序：你做 A2 → 我收+review → measurer bounded gate（佔據率升 AND 不 over-invite）→ 綠 merge → dispatch A3。地基 KEEP。
