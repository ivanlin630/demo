---
from: systems
to: implementer
status: consumed
topic: "[dispatch settlement S1(死亡釋放+目標池擴充=解鎖300鬼城靠既有timer、R² delta CLEAN、★硬禁2 code點)·spec=settlement-lifecycle-agriculture-HOW.md·★S1a 死亡釋放:erase_teams(world_state:286-349、謹慎chokepoint清一堆欄唯漏outpost_owner)加清dead tid owned tile outpost_owner=-1;★R²效率:單pass over state.world.tiles配既有dead:Dictionary(同:315 for otid in teams: if dead.has pattern)、非每dead team各掃全圖O(dead×tiles);fp intended(解鎖認領行為變)·★S1b 目標池擴充(一code點、非新認領動詞、settle-convert不碰):home-seeking靶(camp _find_unowned_farmable_tile:4643現只掃邻7格空農地)擴=納belief-known owner=-1既有outpost tile為候選(撿现成、修缮<<新建工期優先);★感知鐵律touch-point分責:目標選擇(決定走去遠方-1據點=旅行前)=須belief(team_discovered/tile belief);抵達後timer讀腳下=live合法(既有:5119 team.tile_pos自站處);團travel到-1 outpost→站滿既有timer(_evaluate_outpost_takeover:5117 owner==-1滿OUTPOST_TAKEOVER_DAYS=3天)→set_owner認領·★★硬禁(用戶訂正④):code只准這兩處(erase清-1/目標池納-1)、禁新增任何搶城類action、禁碰_tick_solo_settle convert分支(timer已認領避平行造)、occupy不碰、需新action=停下呈報;timer 3天太慢=呈報再議非自加·fp intended-change(S1a+S1b行為變)·★TDD:①S1a erase後死團owned tile owner=-1②目標池含-1 outpost候選③團travel到-1 outpost站3天→既有timer set_owner認領(端到端撿现成)④占村/settle-convert不動(regression)·★量測gate(measurer bounded、綠才merge):鬼城owner死id→-1、認領真fire(撿现成>蓋新於home-seeking)、撿现成端到端(團到-1 outpost timer認領)、不over(先到先得無雙認領)·worktree feat/settlement-s1 base現main·完→handback to:systems附measurer量測·地基KEEP"
---

# dispatch settlement S1 — 死亡釋放 + 目標池擴充（解鎖 300 鬼城靠既有 timer）

R² delta CLEAN。★**硬禁 2 code 點**（用戶訂正④）。design/HOW=`specs/2026-08-14-settlement-lifecycle-agriculture-*`。

## ★S1a 死亡釋放（機械修）
`erase_teams`（world_state:286-349、謹慎 chokepoint 清一堆欄**唯漏 outpost_owner**）→ 加清 dead tid owned tile `outpost_owner=-1`。
- **★R² 效率**：**單 pass over `state.world.tiles` 配既有 `dead:Dictionary`**（同 :315 `for otid in teams: if dead.has(...)` pattern）、非每 dead team 各掃全圖（避 O(dead×tiles)）。
- **fp intended-change**（解鎖認領=行為變）。

## ★S1b 目標池擴充（一 code 點、非新認領動詞、settle-convert 不碰）
home-seeking 靶（camp `_find_unowned_farmable_tile`:4643 現只掃邻 7 格空農地）**擴=納 belief-known `owner=-1` 既有 outpost tile 為候選**（撿现成、修缮 << 新建工期→優先）。
- **★感知鐵律 touch-point 分責**：**目標選擇**（決定走去遠方 -1 據點=旅行前）=**須 belief**（team_discovered/tile belief）；**抵達後 timer 讀腳下**=live 合法（既有 :5119 `team.tile_pos` 自站處）。
- 團 travel 到 -1 outpost → 站滿**既有 timer**（`_evaluate_outpost_takeover`:5117 `owner==-1` 滿 `OUTPOST_TAKEOVER_DAYS=3` 天）→ `set_owner` 認領。

## ★★硬禁（用戶訂正④）
- **code 只准這兩處**（erase 清 -1 / 目標池納 -1）。
- **禁新增任何搶城類 action**；**禁碰 `_tick_solo_settle` convert 分支**（timer 已認領、避平行造）；**occupy 不碰**；**需新 action=停下呈報**。
- timer 3 天太慢=**呈報再議非自加**。

## ★TDD
1. S1a erase 後死團 owned tile `owner=-1`。
2. 目標池含 `-1` outpost 候選。
3. 團 travel 到 -1 outpost 站 3 天 → 既有 timer `set_owner` 認領（端到端撿现成）。
4. 占村 / settle-convert 不動（regression）。

## ★量測 gate（measurer bounded、綠才 merge）
鬼城 owner 死id→-1；認領真 fire（撿现成 > 蓋新於 home-seeking）；撿现成端到端（團到 -1 outpost timer 認領）；不 over（先到先得無雙認領、check-and-set 既有 :5127-5131 同步）。fp intended-change 標。

## worktree
`feat/settlement-s1`、base 現 main。完 → handback to:systems（附 measurer 量測）。

序：你做 S1（2 code 點）→ 我 review → measurer bounded gate → 綠 merge → S2（L0 階梯）。地基 KEEP。
