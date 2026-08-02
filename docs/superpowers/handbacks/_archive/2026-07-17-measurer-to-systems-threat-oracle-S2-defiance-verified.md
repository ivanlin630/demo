---
from: measurer
to: systems
status: consumed
topic: "[量測完·threat-oracle S2 defiance中性複核·非乾淨三齊綠+3個新疑點] branch feat/threat-oracle-s2@eac603d2。單元層(char bed 12/12含defiance非對稱精確吻合1.006vs0.063/gate 65-removed0/threat_dissolution ALL PASS/headless殘3同名同行)皆CONFIRMED。organic三齊：②trade仍升CONFIRMED(兩seed皆升)③cautious仍避戰CONFIRMED(迎戰持續遠低於備戰)①狂徒→迎戰UNCONFIRMED(2seed僅各1個proud-doomed candidate,皆被飢荒/低severity confound蓋過,非機制否證)。★但發現3個未明確被問但材料性的新現象：備戰/求和/survival大幅萎縮至近乎消失(threat repertoire多樣性塌縮,只剩迎戰獨大)、economy指標(build_outpost/farm_pos)較上一輪已收斂的calibrate版惡化、迎戰率seed間方向不一致(1337較calibrate再升3倍到9.78%/42反降到2.98%)。非乾淨『三齊綠』，建議review非直接merge"
---

# threat-oracle S2 defiance refine：中性複核（非乾淨三齊，3 個新疑點）

依 `2026-07-17-implementer-to-measurer-threat-oracle-S2-defiance-done.md`。沿用既有 worktree（`.worktrees/threat-oracle-s2` 已推進到 `eac603d2`）。

## 單元層：全部 CONFIRMED

- **char bed**：12/12 ALL PASS，**defiance 非對稱數字精確吻合**：狂徒不可勝迎戰=1.006 vs cautious 不可勝迎戰=0.063。
- **threat_dissolution_check**：ALL PASS。
- **constitution_gate**：`PASS sites=65 removed=0`。
- **headless_test**：殘 3 assertion 同名同行號（15540/7078/13990）。

## organic 三齊：2/3 CONFIRMED，1 UNCONFIRMED（非否證）

**②trade 仍升 CONFIRMED**：seed 1337 main 0.72%→defiance 0.98%（+0.26pp）；seed 42 main 0.69%→defiance 1.55%（+0.86pp）。兩 seed 皆升。

**③cautious 仍避戰 CONFIRMED**：specimen trace（重用我上輪建的 bed）seed 1337 cautious-hawk（team1）迎戰 util 持續 0.062-0.067，遠低於備戰 0.298-0.307，respect-winnable 故事仍成立。

**①狂徒→迎戰 UNCONFIRMED（非機制否證，樣本被 confound）**：2 seed（1337/4201）各只找到 1 個 proud-doomed candidate（這archetype本來就稀有）：
- seed 1337 team12：severity=0.9，winnable=0.000（全無勝算，最該死戰的情境）——但**覓食=3.469/紮營=2.970**（急性飢荒級 need_urgency）遠蓋過迎戰=0.829，最終選覓食非迎戰。
- seed 4201 team10：severity=0.2，**低於 threat repertoire 有意義門檻**——備戰/迎戰/求和根本不在 applicable list，最終選囤貨。

兩次都被其他極端壓力（飢荒/低 severity）蓋過。char bed 已證明公式方向對（1.006>>0.063），**不是defiance 錯，是這 2 個具體 seed 的這 1 個 specimen 剛好都撞到 confound 情境**。若你要更確定性的「狂徒真的迎戰」organic 證據，需要更多 seed 撈乾淨樣本（我判斷邊際價值 vs 時間成本，本輪先報這個誠實缺口，未繼續撈）。

## ★發現 3 個未被明確要求但材料性的新疑點

**① 備戰/求和/survival 大幅萎縮**（vs main）：
```
              備戰                求和               survival
seed 1337:  1.73%→0.25%(-1.48pp)  0.20%→0.02%(-0.18pp)  15.39%→3.48%(-11.91pp)
seed 42  :  0.42%→0.22%(-0.20pp)  0.98%→0.28%(-0.70pp)  6.09%→2.29%(-3.80pp)
```
廢全域 boost 後，備戰/求和/survival 失去先前（calibrate 版）靠全域 boost 撐的量——defiance 只加在迎戰 term，未鏡射到其他 3 個 threat option → **threat repertoire 內部多樣性萎縮成近乎只剩迎戰**，非四象限均衡分流。

**② economy 較上一輪已收斂的 calibrate 版惡化**：
```
              build_outpost(main→calibrate→defiance)   farm_pos_teams(同上)
seed 1337:    35→39→25（較calibrate降36%）              8→10→5（較calibrate降50%）
seed 42  :    22→18→15（續降）                          10→6→8（較calibrate回升但仍低main）
```

**③ 迎戰率 seed 間方向不一致**：
```
seed 1337: main 0.21%→calibrate 3.01%→defiance 9.78%（較calibrate再升3倍！）
seed 42  : main 0.17%→calibrate 5.05%→defiance 2.98%（較calibrate反降）
```
同為 defiance 版，兩 seed 相對 calibrate 的方向**不同**（1337 升/42 降）——變異大，非單一方向收斂。附帶：seed 42 population 421→418→399（較 calibrate 多降近 5%，本輪最大單步降幅，非崩潰級但值得注意）。

## 判定

**非乾淨「三齊綠」**——② ③ CONFIRMED，① UNCONFIRMED（非否證）+ **3 個新發現的疑點**（threat repertoire 多樣性塌縮、economy 較 calibrate 步驟惡化、迎戰率 seed 間方向不一致）。我判斷這值得你 review 而非直接判 merge——是否要調 `K_DEFIANCE`/是否要讓 defiance 概念也鏡射到其他非-迎戰 threat option（避免多樣性塌縮）、或這是可接受的過渡態，是你的裁量。

## 供你參考
若要更確定「狂徒→迎戰」的乾淨 organic 案例，我可以再撈 2-3 個 seed 專門找 proud-doomed 且非飢荒情境的樣本；也可以視需要重跑更多 seed 讓迎戰率變異縮小。

---
measured_at_head: `eac603d2`（`.worktrees/threat-oracle-s2`）
raw_logs: `docs/measurements/2026-07-17-threatoracle-s2defiance-*.log`（charbed/threatdissolution/constitution/headless/specimen×2seed）、`...defiance-1337-eac603d2.json`、`...defiance-42-eac603d2.json`
measure.json: `docs/process/verdicts/threat-oracle-S2-defiance.measure.json`
