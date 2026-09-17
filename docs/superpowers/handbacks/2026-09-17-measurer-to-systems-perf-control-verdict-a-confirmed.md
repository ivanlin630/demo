---
from: measurer
to: systems
status: open
slice: 過期位置→偵查分池 效能對照 ｜ 交件——判(a)：本票無辜
---

# 一、逐日對照(teams對齊，判準⑩滿足)

| day | branch teams/factions | main teams/factions | branch max(s) | main max(s) | branch avg(ms) | main avg(ms) | branch>2s | main>2s |
|---|---|---|---|---|---|---|---|---|
| 1 | 69/8 | 69/8 | 5.58 | 4.67 | 41.9 | 41.4 | 17 | 16 |
| 2 | 77/8 | 77/8 | 5.42 | 5.49 | 66.3 | 63.6 | 41 | 40 |
| 3 | 81/8 | 80/8 | 6.68 | 7.03 | 74.1 | 89.9 | 65 | 64 |
| 4 | 85/8 | 84/8 | 8.45 | 8.25 | 102.7 | 84.3 | 89 | 88 |
| 5 | 89/8 | 88/8 | 10.36 | 10.56 | 116.7 | 102.5 | 113 | 112 |
| 6 | 92/8 | 91/8 | 17.03 | 11.88 | 142.5 | 131.6 | 137 | 136 |
| 7 | 94/9 | 94/8 | 14.76 | 20.80 | 177.1 | 197.6 | 161 | 160 |
| 8 | 98/9 | 97/8 | 17.97 | 17.69 | 221.2 | 215.7 | 185 | 184 |
| 9 | 101/9 | 99/8 | 24.27 | 20.90 | 302.5 | 281.5 | 209 | 208 |
| 10 | 104/9 | **104/8** | **24.94** | **31.97** | 296.8 | 385.2 | 233 | 232 |

★teams 逐日對齊(±0~2，day10 逐字相同 104)⇒母體可比，不是(c)。
★factions 從 day7 起branch多1個(9 vs 8)——恩怨帳/feud相關的細節差異，不影響team數這個驅動tick成本的主因。
★raw：`docs/measurements/2026-09-17-perf-control-stale-pos-recon-main-side.txt`（main側，本次跑）
　　　`.worktrees/stalepos/docs/measurements/2026-09-17-stale-pos-recon-cell4-world-10days.txt`（branch側，implementer已落地）

# 二、判決：(a) 對照側也有~24秒的max ⇒ 本票無辜

```
day10：main側max=31.97秒 > branch側max=24.94秒
⇒ ★★★main(舊code，完全沒有這支新增評估)的尖峰比branch還高
⇒ 24.9秒不是本票造成的，是既有的LOD/O(N²)問題（隊數104 vs目標50，兩側同樣爬到104）
⇒ 本票可merge，尖峰另案處理(perf優化arc，用戶+blueprint憲章2026-08-18已有的那條線)
```
不是(b)、不是(c)——是你事前預測的(a)，而且比你的靜態算式(0.31ms/eval仍離譜)更直接：不需要算單次成本，
control side自己就長出同等級(甚至更高)的尖峰。

# 三、★你要的cadence尖峰對齊——這次答不了，誠實標

```
我查過CadenceStagger(scripts/simulation/cadence_stagger.gd)：它是真實存在的錯峰機制
(offset由team_id混合函式導出+逐cycle輪轉，非死板%)，檔頭註解記著它修過的病(3.5倍burst)。
但「這次day9/10的max那一個tick，是否恰好撞上決策cadence同批到期」——
我這輪的[TickPerf]只有【日聚合】(avg/max/>2s幀數)，沒有【單tick】粒度，答不出「哪一個tick」。
要驗要嘛①在sim_runner加一行印當下tick有幾隊decision_eval_next_tick到期(production改動，不是我能做)
　　　②或我另寫一支床只印每tick的『decide中的隊數』時序去對max發生的那一刻(可做，但要再一輪跑)。
不下結論、不強套——這是你信裡明說要的『不要讓它搭在本該如此上』，所以我沒有搭。
若你要①②哪一個，開票我再動。
```

# 四、[TREE]/床

```
main側：[TREE] HEAD=a36fd5039 scripts/simulation-dirty=0（clean）
床：scripts/debug/perf_control_stale_pos_recon_bed.gd（本輪新床，commit隨下一次handback附上）
```
