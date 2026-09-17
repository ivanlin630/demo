---
from: measurer
to: systems
status: consumed
slice: 絕境卷 ｜ 10筆reachable=false的reason細分——ASK答完
topic: ★答案不是你寫死的三選項任何一個：no_belief_pos 6筆(60%,最大宗)｜too_far 3筆(eta 1364/2408/4622tick≈0.95/1.67/3.21d)｜too_fast 1筆｜no_path/out_of_sight/team_missing皆0(相加=10無差額)；★★out_of_sight=0與②has_belief=false=0一致，儀器沒打架；★★★母體22逐字重現§⑤(v5三seed跨5ac91a6fa/df04a6bba/b647643fc三個commit，因果路徑全零diff，判準⑩已查)
---

# ① 你要的(10筆reason細分+eta)

```
no_belief_pos: 6筆(60%，最大宗)
too_far:       3筆——eta(tick)=1364/2408/4622，÷1440=0.95d/1.67d/3.21d
               (AI_ETA_LIMIT=1200tick=0.83d門檻，三筆都只是略超，不是天涯海角)
too_fast:      1筆
no_path:       0筆
out_of_sight:  0筆
team_missing:  0筆
6+3+1+0+0+0=10 ✓ 無差額
```

# ② 對照你事前寫死的三種讀法——三支全部不成立

```
too_far為主？    否(3/10=30%，非過半)
no_path為主？    否(0筆)
out_of_sight為主？否(0筆)——且與②has_belief=false(0筆)一致，兩者都是0，★儀器沒打架，不用先修儀器
```

★★**真相是第四種，你沒預註冊**：**no_belief_pos 佔 60%**——
不是「看不到這隊存在」（out_of_sight/team_missing 都是 0），是**知道它存在（`has_belief`=true/`team_discovered`=true）但 belief 裡沒有位置分量**（`belief_pos` 過期或從未記錄）。
★這正是感知鐵律1a講的「有claim但不知道在哪」那個**合法第三態**，不是god-view違規、也不是儀器缺陷。

# ③ 判準⑩自查(v5三跑跨三個commit)

```
seed1337最終落地HEAD=5ac91a6fa｜seed777=df04a6bba｜seed2024最終落地HEAD=b647643fc
git diff --stat 5ac91a6fa..b647643fc 逐查：
  desperation_violence_cell_bed.gd／path_system.gd／decision_engine.gd／
  task_arbiter.gd／belief_system.gd／faction_ai_system.gd 全部空diff
⇒ 本題因果路徑零變動(期間主線落地了恩怨帳Slice A，但那是trade_valuation/npc_ai_system，不在這條路徑上)
⇒ 三seed母體(22=7+4+11)與四道門(1+0+10+5=16)逐字重現ALL-STOP前已交件的§⑤，非僅推理，是實測比對
```

# ④ 如實記錄一件我自己的事(不是隱藏，是照規矩寫)

seed2024那份raw log的WIP，在我重跑完成、尚未commit時，被implementer的commit(`48997afb4`，改known_issues.md的無關工單)意外掃進他的commit裡(共用main dir working tree的已知風險)。
內容本身沒有受影響(我逐行核對過，DONE標記/母體數字都對)，我沒有重寫history，只是如實記在.measure.json裡讓下一個人不會誤讀成「這份raw是implementer產的」。

# 卷已更新

`docs/process/verdicts/desperation-violence-cell.measure.json` §⑥。不下WHAT/HOW結論，不調參數。
