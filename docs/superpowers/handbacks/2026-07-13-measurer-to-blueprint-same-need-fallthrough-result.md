---
from: measurer
to: blueprint
status: consumed
topic: same-need-fallthrough驗收——★正面結果：winner分布從生產91.5%(前輪)轉為買糧90.2%(本輪)，覓食失敗確實fallthrough落到食物類(PASSIVE_SURVIVAL_SET)而非生產；pop縮編幅度也緩和(10→5→10→6)；determinism CLEAN+0新增SCRIPT ERROR
---

# 量測回報：dispatch 同需求 fallthrough（PASSIVE_SURVIVAL_SET）驗收

工單：`2026-07-13-implementer-to-measurer-same-need-fallthrough.md`。`.worktrees/same-need-fallthrough`（feat/same-need-fallthrough @48284d4）。同款Team7。

## ①headless/determinism——CLEAN
0新增SCRIPT ERROR（3個pre-existing）。`snf_det1.json`/`snf_det2.json` **byte-identical**。

## ②★餓隊fallthrough——確認修正生效
| | survival-path輪(修前) | 本輪(fallthrough修後) |
|---|---|---|
| winner=生產 | 1790（91.5%） | 26（1.3%） |
| winner=買糧 | 0 | **1764（90.2%）** |
| winner=覓食 | 166（8.5%） | 166（8.5%） |
| 最終pop | 10→5 | 10→6 |

末段candidates：`覓食=0.95 買糧=0.60 生產=0.28 ...`——**覓食(rank[0])仍不可dispatch，但fallthrough正確落到買糧（食物類，PASSIVE_SURVIVAL_SET成員）而非生產**。與implementer信§驗收①目標「餓隊覓食失敗→試買糧/紮營/併入」**完全吻合**。

## ③縮編幅度緩和
pop最終10→6（前兩輪分別是10→5、10→4），雖仍未完全止血（隊伍仍在縮編，覓食target本身的問題——前輪`forage-dispatch-classify`分析的候選C仍未修——但食物策略切換確實work），縮編幅度呈現逐輪改善趨勢。

## 判讀
A（fallthrough落點）修正**驗收通過**。隊伍仍縮編非「完全解」，但這是預期內——C（覓食target-fail，wild_game枯竭）尚未修，隊伍靠買糧撐著但買糧本身可能也有其限制（如金錢/距離），非本slice範圍。

## 產物
`snf_det1.json`/`snf_det2.json`（determinism），`snf_stable_trace.txt`（Team7完整trace）。

## 待你
本slice（A修正）驗收通過。若要進一步解縮編（C：覓食target-fail），需下一輪處理。
