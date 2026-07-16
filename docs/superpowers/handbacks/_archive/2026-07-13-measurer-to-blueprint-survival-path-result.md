---
from: measurer
to: blueprint
status: consumed
topic: survival-path驗收——★spurious FLEE確實根治(survival winner次數907→0,candidates末段survival=0.00符合threat gate設計)；★但發現新問題：食足轉餓過程中隊伍鎖死在「生產」(util 0.58)而非util更高的「覓食」(0.95)，疑似COMMITMENT_BONUS over-stick，仍餓死(pop10→5)但死法不同——需implementer查commitment邏輯；determinism CLEAN+0新增SCRIPT ERROR
---

# 量測回報：survival-path（latch重選+FLEE威脅gate）驗收

工單：`2026-07-13-implementer-to-measurer-survival-path.md`。`.worktrees/survival-path`（feat/survival-path @2c414e0）。同款Team7（本session已用兩輪作為對照基準的代表隊）。

## ①headless/determinism——CLEAN
0新增SCRIPT ERROR（3個pre-existing同baseline）。`sp_det1.json`/`sp_det2.json` **byte-identical**。

## ②★spurious FLEE——確實根治
| | 前輪(cadence修後，FLEE gate修前) | 本輪(survival-path修後) |
|---|---|---|
| decision_count | 2023 | 1957 |
| winner=survival | **1907（94.3%）** | **0（0%）** |
| winner=生產 | （未見此option出現） | 1790（91.5%） |
| winner=覓食 | 115（5.7%） | 166（8.5%） |

末段candidates顯示`survival=0.00`（`覓食=0.95 生產=0.58 買糧=0.30 駐守=0.27 建設=0.19 survival=0.00`）——**threat gate（threat<=0→0）確實生效**，食足/無威脅時survival完全不再是候選威脅。implementer信§②目標「食足隊不spurious FLEE」**本輪驗收通過**。

## ③★新發現：隊伍改鎖死在「生產」而非「覓食」，仍餓死
Team7最終population**10→5**（前輪10→4，同量級縮編，只是不再是FLEE死法而是別種死法）：

```
tick=21600（月3尾）: winner=生產(0.58) task=製造
  candidates: 覓食=0.95 生產=0.58 買糧=0.30 駐守=0.27 建設=0.19 survival=0.00
  狀態: pop=5 food(priv=0.0/gran=0.0/eff=0.0) ...
```

**`覓食`util（0.95）明顯高於`生產`util（0.58）,argmax理論上該選覓食,但winner卻是生產**——這強烈疑似implementer信§①提到的`previous_task`防抖機制（COMMITMENT_BONUS）過度鎖定：隊伍在食物尚可時選了「生產」，之後即使食物耗盡、覓食util飆到0.95，commitment bonus仍讓「生產」贏過理論上更高分的「覓食」，**導致餓死死法從「無謂FLEE」換成「鎖死在生產不換糧」**——implementer信§驗收①「餓隊換策略（forage失效→換買糧/掠奪/併入）」**本輪未驗證通過**（隊伍根本沒換到覓食/買糧，一路生產到死）。

## ④churn連貫性——技術上「連貫」但連貫錯方向
task確實不再鋸齒亂跳（91.5%集中在生產，非前輪94%集中survival的死循環）——防抖本身生效，但**防抖過頭犧牲了「該換就換」的靈活性**，跟implementer信§④「驗previous_task防抖真生效」字面上算通過，但精神上（該換沒換）是另一種失敗模式。

## 產物
`sp_det1.json`/`sp_det2.json`（determinism），`sp_stable_trace.txt`（Team7完整trace）。

## 待你
- FLEE gate（②）驗收通過，可視為獨立進度。
- **餓隊換策略（①）未驗證通過**——COMMITMENT_BONUS疑似壓過急迫的覓食需求，需implementer查`_evaluate_survival`/`rank_survival`裡commitment加成是否也該對「明顯util差距」設逃逸閥（如util差距超過某門檻時忽略commitment），非我代判修法，回你/systems裁。
- 9-zero organic本輪未跑（先報核心發現，你若仍要9-zero告知我續跑）。
