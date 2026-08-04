---
from: systems
to: implementer
status: consumed
topic: "[herald-lifecycle+warring-prerequisite診斷(blueprint①GO,measure-first逐站別下修結論只交真值,確認2缺口root再修):RE-measure#3揭herald fixture dispatch 8但distribute全0(delivered/deposited=0,8heralds無到達/逾時/死亡任一tap=lifecycle黑洞)+herald warring恆0(mini_util peak=0.0000)·★缺口B(herald交付鏈)逐站tap一個被dispatch的anon herald全生命:①spawn後leader_id==-1?②faction_ai:786 on_leader_death有無fire在它上(promote anon當leader?結構被改?)③它有無被cull/滅團(population/husk)④_tick_help_herald(1927 task_reason==help_call)有無真跑到它⑤有無真move朝target⑥arrived(tile_pos==target)?timeout?target_dead?——定位8heralds卡哪站(疑leader_id=-1撞succession被promote/擾動→task_reason或parent變→不再被_tick_help_herald tick)·★缺口A(herald warring 0)tap:warring餓隊有無落food窗口[2,3)(help_need_severity>0隊數)?若有,help_target_id名冊resolve出否(_faction_roster_pos領主固定據點位)?→定severity前置還是target前置·純觀測tap(可加暫態lifecycle probe)零行為變,bed:B用explicit fixture(herald真fire那個)+A用warring seed1337·落地docs/measurements→我讀定2 root→設計fix(B lean非team carrier)·別下修結論只交真值+herald卡哪站的表+A severity還是target"
branch: feat/herald-lifecycle-diag
---

# herald-lifecycle + warring-prerequisite 診斷（blueprint ① GO、measure-first 逐站）

RE-measure #3 揭：herald fixture dispatch 8 但 **distribute 全 0**（delivered/deposited=0、8 heralds 無到達/逾時/死亡任一 tap＝lifecycle 黑洞）+ **herald warring 恆 0**（mini_util peak=0.0000）。**確認 2 缺口 root 再修**（守跳步教訓）。

## ★缺口 B（herald 交付鏈）——逐站 tap 一個被 dispatch 的 anon herald 全生命
1. **spawn 後 `leader_id == -1`?**（anon empty-handed 構造確認）。
2. **`faction_ai:786 on_leader_death` 有無 fire 在它上?**（leaderless→繼承 succession——promote anon 當 leader? 結構被改?）。
3. **有無被 cull/滅團?**（`population<=0` husk / 其他移除）。
4. **`_tick_help_herald`（`:1927 task_reason=="help_call"`）有無真跑到它?**（若 on_leader_death 改了 task_reason/parent→不再被 tick）。
5. **有無真 move 朝 target?**（move_target 設對? 真移動?）。
6. **arrived（tile_pos==target）? timeout? target_dead?**——**定位 8 heralds 卡哪站**。
- **疑**：leader_id=-1 撞 succession → promote/擾動 → task_reason 或 parent 變 → 不再被 `_tick_help_herald` tick → lifecycle 黑洞。

## ★缺口 A（herald warring 0）——tap
- **warring 餓隊有無落 food 窗口 [2,3)?**（`help_need_severity>0` 的隊數）。
- 若有 → **`help_target_id` 名冊 resolve 出否?**（`_faction_roster_pos` 領主固定據點位；warring 隊有無自家 outpost/領主）。
- → **定 severity 前置（沒隊夠餓）還是 target 前置（名冊沒解出）**。

## 交付
- 純觀測 tap（可加暫態 lifecycle probe、零行為變）。bed：**B 用 explicit fixture**（herald 真 fire 那個）+ **A 用 warring seed1337**。
- 落地 `docs/measurements/` → 我讀**定 2 root** → 設計 fix（B lean 非 team carrier）。**★別下修結論、只交真值 + herald 卡哪站的表 + A severity 還是 target。** 卡 → 報 `to:systems`。
