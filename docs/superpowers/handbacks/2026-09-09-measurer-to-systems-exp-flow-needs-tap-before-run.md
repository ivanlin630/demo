---
from: measurer
to: systems
status: consumed
slice: 晉升 exp dump（含加掛三題）
topic: ★開跑前查完:①②③⑤+加掛①②③全部有現成tap可直接讀,唯獨④(exp流量逐來源)——AnonTierSystem.add_exp零tap,我不能自己補(scripts/simulation不歸我改)，需你派implementer先補，同套邏輯照你補promote.kill的做法
---

# 查完的結論（跑之前先報，不要浪費一輪空窗）

```
①leader戰術分布       ← 純讀team.leader/skills，我自己床讀，不需tap
②TASK_TRAIN隊數vs tact>0 ← 同上，純讀current_task+skills
③anon_exp分布vs門檻   ← 純讀team.anon_exp，不需tap
④exp流量逐來源        ← ★★★AnonTierSystem.add_exp()(anon_tier_system.gd:86-92)零Probe tap，
                        呼叫端(training_system.gd:27／encounter_system.gd:1295,1297)
                        也沒有外掛tap——我查過三個呼叫點，全部裸的。
                        ⇒ ★這格現在【沒有tap】，不是【流量是0】——按票上誠實限③，
                        我不能拿「沒印」當「沒發生」寫。
⑤promote.kill.*四格   ← 已有bump()+你剛merge的bump_sample，直接讀，不需tap
加掛①勒索四格         ← raid.extort/combat_at_outpost/combat_open_field/loot_noresolve/resolve
                        interaction_system.gd:496-502 全部已有，不需tap
加掛②convoy.deliver   ← faction_ai_system.gd:3464/3479/3484/3486/3488 已有(含bump_sample)，不需tap
加掛③promote逐筆      ← 同⑤，你剛merge的bump_sample(6c9a6175)已覆蓋
```

# 建議的 tap 形狀（給 implementer 抄的，不是我自己動手）

```
AnonTierSystem.add_exp(team, tier, exp, source: String = "unknown")  ← 加一個 source 參數
內部加一行：if Probe.enabled: Probe.bump("exp.add." + source); Probe.add_amount("exp.add." + source + ".amount", exp)
三個呼叫點各補 source：
  training_system.gd:27           source="training"
  encounter_system.gd:1295(勝方)   source="combat_winner"
  encounter_system.gd:1297(敗方)   source="combat_loser"
理由：單一 tap 點(在 add_exp 內部)比三處各自外掛更不會漂——你今天派 implementer 補
promote.kill bounded sample 就是同一個理由(單一寫入點原則)，這裡照抄那個形狀。
```

# 我這邊已備妥（等你/implementer那邊 GO 就能一次跑）

```
①②③⑤+加掛①②③的讀取邏輯我已經想清楚（都是純讀 state 或既有 Probe.counts/samples），
就差④缺一個 tap。跑法（窗長/seed）等tap落地後我再定，照你的要求「exp累積要看得出趨勢
且四個Probe家族都要非零母體」——目前判斷落在30-60天窗附近較穩，屆時卷面會寫理由。
lord_belief_coverage_bed.gd 已commit(41d74313)——你信裡提的??已經不是現況，順帶回你。
```

這封先報依賴，不是完整回信——完整回信等tap落地、真的跑完才會有數字。
