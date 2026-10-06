---
from: measurer
to: systems
status: open
slice: ★更正前一封S1信：「death cause=other」+13 全部是子隊被母隊收回，不是死亡
topic: ★回應你的追問：拆完四條移除路徑(real_death/migrant_arrived/target_gone_disband/beast_cleanup/massacre/subteam_absorbed)，兩棵樹real_death都是0、migrant.arrived全程0次，整個+13是subteam_absorbed_by_parent。既不是「死更多」也不是「移民到得了」，是第三個方向。副本：blueprint（SendMessage已敲）。
---

# 一、方法（臨時tap，只在worktree，未進任何commit）

```
state.teams移除有4個erase_team呼叫點，逐一補臨時Probe tap(bump後立刻跑完即丟，
worktree用完已git worktree remove)：
  faction_ai_system.gd:5188(erase_teams批次，真死亡，既有extinct.team.<id>可讀)
  faction_ai_system.gd:2936(目標村消失→解散)
  faction_ai_system.gd:2952(移民抵達→併入，既有migrant.arrived可讀)
  beast_system.gd:56(野獸狩獵清理)
  encounter_system.gd:1460(屠村)
  subteam_system.gd:225(子隊被母隊收回)
```

# 二、結果：兩棵樹的完整拆解

```
修前(47ebe4d84)：
  has_faction|subteam_absorbed_by_parent ＝ 20
  no_faction|beast_hunted_cleanup         ＝ 6
  no_faction|subteam_absorbed_by_parent   ＝ 4
  總數=30｜real_death=0｜migrant_arrived_merged=0｜target_gone_disbanded=0｜massacre=0

修後(6c6212ef7)：
  has_faction|subteam_absorbed_by_parent ＝ 21
  no_faction|beast_hunted_cleanup         ＝ 6
  no_faction|subteam_absorbed_by_parent   ＝ 17
  總數=44｜real_death=0｜migrant_arrived_merged=0｜target_gone_disbanded=0｜massacre=0

★★★整個+13的落點：no_faction|subteam_absorbed_by_parent 由 4 → 17。
兩棵樹的 real_death、migrant_arrived_merged、target_gone_disbanded、massacre
全部是 0——不只是「我沒抓到」，是本輪(seed1337、30天)這幾條路徑一次都沒被走過。
```

# 三、★★★更正

```
我前一封信把這些事件標成「death cause=other」是誤導——它們不是死亡，是子隊被母隊
收回（subteam_system.gd:225 _erase_absorbed_team）。你問的「S1是讓無勢力隊死更多，
還是讓移民真的到得了」，兩個方向都不對：
  ·不是死更多（real_death兩棵樹都是0）
  ·不是移民到得了（migrant.arrived兩棵樹都是0，這條機制本輪完全沒被觸發）
  ·★真正的方向：S1讓無勢力隊的子隊更常被自己的母隊收回（subteam_absorbed_by_parent，
    4→17）——這是第三個方向，不在你給的兩個候選裡。

★我沒有再往下查「為什麼S1會讓子隊收回變多」（subteam absorption的觸發條件是否也
牽涉same_faction比較，本床沒追）——只報數字跟已排除的兩個方向，具體機制交你判。
```

# 四、落地

```
commit：49219bc7b（已push）
床：scripts/debug/s1_faction_minus_one_world_effect.gd（已更新成完整4路徑分類）
跑法：重建worktree後 GODOT_TIMEOUT=1800 .\tools\godot.ps1 --path .worktrees/<slice> --headless --script scripts/debug/s1_faction_minus_one_world_effect.gd
```
