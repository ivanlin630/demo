---
from: measurer
to: systems
status: open
slice: 可慢不可卡——重測交件
topic: ★交件:ON趟(可信,跑滿90天)max從舊卷26.65秒降到11.86秒(2.25倍改善,問題還在),週期性不變(每小時一次),兇手位移——舊卷loop2.solo已不是頭號,新頭號是loop3.misc(佔spike樣本86.3%第一名,自佔比中位29.6%)｜★★★界限45要求的開/關對照未完成:OFF趟被contention嚴重污染(day83 max=68秒!被timeout砍在day84/90)不可信,需要重跑
---

# 交件

```
.measure.json：docs/process/verdicts/frame-time-remeasure.measure.json
raw log：
  docs/measurements/2026-09-10-frame-time-remeasure-phaseON.txt(完整跑滿90天，可信)
  docs/measurements/2026-09-10-frame-time-remeasure-phaseOFF.txt(★污染，只到day84/93%被砍，不採用)
床：scripts/debug/frame_time_who_freezes_bed.gd(已加BED_PHASE_TIMING開關)
窗：warring_states/seed=1337/90天(同舊卷參數，可比)
```

# 一句話——問題還在，但變輕了；兇手换人了

```
①全窗max：26.65秒(舊,慢十倍世界) → 11.86秒(新,ON趟) —— 2.25倍改善，仍遠超5秒門檻
②全窗中位數(母體=全部129600 ticks，非只spike樣本)：p50=447us、p95=2591us
③週期性不變：仍每60-tick(1小時)一次，從tick=60起，貫穿全窗，spike比例1.817%
④★★★新頭號兇手=loop3.misc(取代舊卷的loop2.solo)：
   spike樣本裡86.3%(2032/2355)它是self最大葉節點，自佔total比例中位29.6%(9.8%-99.7%)
   範圍=faction_ai_system.gd:1381-1408，含_update_mobilization/_update_equip_order/
   _update_armor_config/_update_guard_ratio/_auto_withdraw_mounts，加上對TASK_IDLE隊
   的DecisionContext.gather+DecisionEngine.rank_ambient呼叫——這段內部沒有再細分，
   若要精確定位是哪一段，需要implementer加更細phase tag
```

# ★★★界限45要求的開/關對照——未完成，OFF趟被contention污染

```
OFF趟(對照組)被砍在day84/90(93%)，且day80-84的avg飆到334-452ms、max飆到37.5-68.1秒
——遠高於ON趟全窗max(11.86秒)。teams數(167-171)比ON趟最終值(115-137)更高，顯示OFF
趟world evolution走得更遠但wall-clock效率遠低於ON趟——同時段有其他worktree(如
.worktrees/converge2)在跑重活，這是外部contention造成的，不是phase_timing旗標
本身的污染信號。

⇒ ★本輪未能完成乾淨的開/關對比，OFF趟數字不採用。需要在contention更乾淨的時段
重跑OFF(或兩趟都重跑)才能真正回答「phase_timing本身有沒有污染量測」。跑法你裁，
我不會自己找『安靜時段』去賭。
```

誠實限完整版見.measure.json（含舊卷母體定義不同不可直接相減、loop3.misc未細分等）。

