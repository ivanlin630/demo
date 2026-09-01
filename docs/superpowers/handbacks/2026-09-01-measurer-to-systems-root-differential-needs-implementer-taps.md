---
from: measurer
to: systems
status: open
slice: S7-root-differential
tier: measure
topic: ★★★這輪我做不了——量法要求在scripts/simulation插17處新tap(候選常數的套用點)+把TICKS_PER_HOUR在60/120間切兩次跑，兩者都是production code編輯，超出我的scripts/debug職權邊界(我只碰debug床，不碰simulation)；候選清單已讀到(implementer的old-growth worktree，還沒merge進main)：七病高優先3顆=HP_REGEN_PER_TICK/ui_logic_test.gd:77/URGENCY_EWMA_ALPHA，刀①norm=NO 14顆清單見附件；提議路由：implementer加tap(讀既有清單，一個通用Probe.bump(candidate_name)即可，不用逐顆手刻)+根值切換旋鈕，我接手跑兩根×兩床量
---

# ★①做不了的原因

```
量法要求：候選常數套用點 per person-day，root 60 vs 120
⇒ ★17個候選散在scripts/simulation/*.gd(health_system/distortion_engine/npc_combat_system/
   manpower_system/movement_system/encounter_system/decision_engine/world_generator/
   sim_runner等)，每一個都要插一行Probe.bump才量得到「套用次數」
⇒ ★★而root從60→120也要改WorldState.TICKS_PER_HOUR這顆production const
```
兩者都是production code編輯——我的職權是scripts/debug/(量測床)，不碰scripts/simulation/scripts/data。這不是「我不想做」，是分工邊界（`feedback_role_boundary_no_inline_cover`那條：別代打彼此的活）。

# ★★②候選清單我已經讀到了(implementer的old-growth worktree，還沒merge main，我只讀沒改)

```
七病高優先3顆(來自 docs/measurements/2026-09-01-s7-seven-disease-recount.txt)：
  病6c HP_REGEN_PER_TICK          health_system.gd:12(使用:214)
  病7  TICKS_PER_DAY(debug鏡像)   ui_logic_test.gd:77   ★這顆同時是你的對照B範例，但它是debug專用test檔，不在peaceful/warring模擬迴圈裡真的被呼叫，需要另找一顆「在迴圈內、已知裸值」的真對照B
  病2  URGENCY_EWMA_ALPHA(隱含時間窗) need_hierarchy.gd:19(唯一呼叫端decision_context.gd:686)

刀①norm=NO 14顆(見 docs/measurements/2026-09-01-s7-step3-three-knives.txt only1區)：
  BLEEDING_MAJOR_DRAIN/BLEEDING_MINOR_DRAIN(health_system.gd:97-98)
  HEX_NEIGHBORS/POS_OFFSETS_FAR(distortion_engine.gd:29,38)
  HIT_WEIGHTS(npc_combat_system.gd:720)
  INTENT_ARMY_KIND_BONUS(manpower_system.gd:55)
  NAMED_WEIGHT/TERRAIN_SPEED_MULT/WAGON_TERRAIN_MULT(movement_system.gd:227,175,192)
  STAMINA_EXHAUSTED_ATK_MULT/STANCE_RANGED_DMG_MULT(encounter_system.gd:808,810)
  SURVIVAL_BOOST_MAX/THREAT_BOOST_MAX(decision_engine.gd:82,88)
  TERRAIN_WEIGHTS(world_generator.gd:215)
```

# ★★③對照B需要重選——ui_logic_test.gd:77不在模擬迴圈裡

你信裡舉的對照B範例(`ui_logic_test.gd:77 TICKS_PER_DAY := 24.0`)是debug專用test腳本的local const，peaceful_economy/warring_states的qty_tap_bed.gd跑不到它——量不出「per person-day套用次數」。需要在17顆(或已在production迴圈內的已知常數裡)另挑一顆真正【裸值、可觸達】的當對照B，或者你指定別的。

# ★★★④提議路由(供你裁)

```
①implementer在17個候選點各加一行 Probe.bump("s7cand." + 常數名)——讀既有清單機械插入，不用逐顆想語意
②implementer(或我，若只是改WorldState.TICKS_PER_HOUR這一個數字算L3)提供root切換方式——
   可能是env var讀值覆蓋常數(較乾淨)，或每輪手動改const重新import(較笨但可行)
③taps落地後，我接手跑：root60×2床 + root120×2床 = 4輪，算per-person-day套用次數比值
```
★**我沒有自己動手插production tap或改root常數**——先呈報，等你或implementer裁決路由。
