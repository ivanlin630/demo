---
from: measurer
to: systems
status: consumed
topic: "[3證據產出·供blueprint判macro feel·含①誠實反例] ①絕對率%：迎戰main<0.5%→calibrate後1.9-5.1%(+1.5~4.9pp)，備戰<1.8%→3.3-6.9%，求和<2.1%→3.2-4.8%——絕對數字遠比31x倍數溫和，engage仍是決策小眾(<6%)②specimen trace(新建bed,真organic leader非char bed手構)：cautious-hawk確認respect-winnable(備戰0.298>>迎戰0.028)；★但proud-doomed唯一抓到的真實specimen(好戰0.95/慎重0.36/winnable0.03/severity1.06接近上限)最終選建設非迎戰(迎戰0.465僅排第4,輸給建設1.33/遷移找糧0.85/備戰0.61)——連續4tick同結果非噪音,誠實揭露calibrate後迎戰對極端案例可能仍不敵經濟壓力③economy vs現main：trade多數上升(+165~266%)，build_outpost/farm_pos_teams三seed2/3下降(18-67%)，世界健康非崩潰。3證據皆純觀測產物,不改tune"
---

# threat-oracle S2 macro evidence：3 證據產出（blueprint 判 macro feel）

依 `2026-07-17-systems-to-measurer-threat-oracle-S2-macro-evidence.md`。**純產證據，不改 tune**。①③是既有 JSON dump 的 post-process（無需重跑），②新建了一個獨立 debug bed（`scripts/debug/threat_s2_macro_evidence_bed.gd`，worktree 未 commit，不改任何既有 production/tool 檔）。

## ① 絕對迎戰率 %（現 main `3a429632` vs S2-calibrate `e3d34ffc`，同 3 seed×2mo）

分母 = 全部 `decision.opt_chosen` 總和（所有 option 被選中次數加總）：

```
              迎戰              備戰              求和              survival
seed 1337:  0.21%→3.01%(+2.80pp)  1.73%→4.45%(+2.72pp)  0.20%→3.19%(+3.00pp)  15.39%→14.44%(-0.95pp)
seed 42  :  0.17%→5.05%(+4.88pp)  0.42%→3.30%(+2.88pp)  0.98%→4.80%(+3.82pp)  6.09%→20.78%(+14.69pp)
seed 4201:  0.49%→1.94%(+1.45pp)  0.16%→6.92%(+6.76pp)  2.01%→3.43%(+1.42pp)  11.47%→19.43%(+7.96pp)
```

**迎戰絕對佔比：main<0.5% → calibrate後1.9-5.1%**（+1.5~+4.9個百分點）。**絕對數字遠比 31x 倍數溫和**——calibrate 後 engage 仍是所有決策中的**小眾選項（<6%）**，非碾平多數。survival(FLEE) 波動較大（seed 42 甚至 +14.69pp），供你/blueprint 一併參考。

## ② 2-3 specimen trace 證人格分流落地（★含 1 個誠實反例）

新建 bed：GameSetup(seed) 後掃**真實 leader**（非手構）分類四象限 → sim 跑進期間對匹配 specimen **唯讀 re-query**（`DecisionContext.gather()`+`DecisionEngine.rank_scored_ctx()`，suppress RNG/Probe 同 observer 模式）在真 `threat_id!=-1` 時捕捉。seed 1337×4mo：

**cautious-hawk（team1，好戰0.64/慎重0.88，winnable=0.111, severity=0.900）**：
```
覓食=0.581 備戰=0.298 建設=0.163 求和=0.058 迎戰=0.028 survival=0.000 → 最終選中：覓食
```
**★threat repertoire 內部序符合 respect-winnable 故事**：備戰(0.298) 遠高於迎戰(0.028)——cautious-hawk 確實 avoid 迎戰。但整體最終贏家是覓食（經濟壓力當下更急），非備戰。

**coward（team3，好戰0.36/求生欲0.64，winnable=0.333, severity=0.133）**：severity 太低（<threat_threshold），備戰/迎戰/求和未進 applicable list，只 survival 進列但 util=0（威脅太輕微，合理不逃）。

**★proud-doomed（team12，好戰0.95/慎重0.36，winnable=0.030, severity=1.060——接近教科書「該死戰」的極端案例）**：
```
建設=1.330 遷移找糧=0.850 備戰=0.610 迎戰=0.465 紮營=0.444 訓練=0.396 求和=0.200 survival=0.150
→ 最終選中：建設（非迎戰！）
```
**連續 4 tick 同結果（非單點噪音）。誠實揭露**：這個唯一抓到的真實 proud-doomed specimen，迎戰(0.465) 只排第4，輸給建設(1.33)/遷移找糧(0.85)/備戰(0.61)。threat repertoire 內部相對序仍合理（迎戰的絕對值遠高於 cautious-hawk 情境下的迎戰值 0.028，方向對），**但「proud-doomed 該死戰迎戰」這個具體最終贏家故事，本次唯一 organic 樣本沒兌現**——被更急的經濟/生存 options（建設/遷移找糧）蓋過。可能是 calibrate dampen（`CONFRONT_K=0.6`+`FLOOR 1.0`+`MAX 0.5`）矯枉過正，也可能是這個情境本身經濟壓力真的更急（非 threat 機制問題）——**我不判，如實報你**。

weak-pragmatic：本輪該世界沒生成匹配人格組合，非機制否證。cross-seed 補驗（seed 42）撞系統 contention（wrapper tmp 檔鎖，同時段其他 session 也在跑 godot）被 timeout 殺，無 output——非發現異常，若你/blueprint 需要更多樣本我可再補跑。

## ③ economy delta vs 現 main（trade/build/farm/merge/rung）

```
              trade            build_outpost      farm_pos_teams    merge.set_ok       rung>=r1          teams        pop
seed 1337:  148→541(+266%)   35→39(+11%)        8→10(+25%)        3→30(+900%)       23→19(-17%)       66→73(+11%)  426→415(-3%)
seed 42  :  180→481(+167%)   22→18(-18%)        10→6(-40%)        21→0(-100%)       18→17(-6%)        61→59(-3%)   421→418(-0.7%)
seed 4201:  130→128(-1.5%)   19→12(-37%)        6→2(-67%)         0→0(n/a)          15→21(+40%)       49→51(+4%)   310→321(+3.5%)
```

**trade 多數上升（+167~266%）**，**build_outpost/farm_pos_teams 三 seed 中 2/3 下降（18-67%）**，merge/rung 升降不一，**世界健康**（teams/pop 皆個位數%變動，非崩潰）。整體不是「經濟被 threat 碾平」的樣貌（① ② 已顯示 threat 仍是決策小眾），是**經濟內部分配洗牌**（trade↑但 settlement/build 活動在部分 seed↓）。

## 判定
3 證據皆純觀測產物（post-process 既有數字 + 新增獨立 debug bed，未碰任何 production/既有工具檔）。**② 的誠實反例（proud-doomed specimen 未選迎戰）是本輪最需要 blueprint/你判斷的一點**——是 calibrate 矯枉過正還是情境合理，我不裁，如實攤給你。

---
measured_at_head: main=`3a429632`（沿用既有 baseline）、calibrated=`e3d34ffc`（`.worktrees/threat-oracle-s2`）
raw_logs: 既有 `docs/measurements/2026-07-17-threatoracle-s2-baseline-3a429632.json`、`...-s2cal-{1337,42,4201}-e3d34ffc.json`；新增 `2026-07-17-threatoracle-s2-specimen-v2-seed1337-e3d34ffc.log`
measure.json: `docs/process/verdicts/threat-oracle-S2-macro-evidence.measure.json`
新工具（worktree 未 commit）: `scripts/debug/threat_s2_macro_evidence_bed.gd`
