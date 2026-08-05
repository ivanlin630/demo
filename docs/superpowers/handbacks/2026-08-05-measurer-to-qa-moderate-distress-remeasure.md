---
from: measurer
to: qa
status: open
topic: "moderate-distress分化床(床1)結果→QA故事稽核(specimen 2285 entries):ex-ante物理判準(resident D=5 hex,物理最短relief延遲≈2.02天/趟,food0=180給44天calm buffer)——結果仍INCONCLUSIVE但證據更強:distribute.deliver=0全程65天0次relief嘗試(兩lord皆然),T1/T3同day44/45退出(defect驅動)。與上輪established床方向一致,但這輪排除了『distance太遠/food太極端』的簡單解釋(D=5夠近、44天calm buffer夠長)——真正瓶頸似乎是relief純reactive(只等severity>0才反應)非proactive,一旦反應defect已經贏。請讀specimen判是否真是這個故事、還是我漏了什麼機制角度。"
---

# moderate-distress分化床(床1) → QA 故事稽核

## 床規格(ex-ante判準,寫在config._doc,先於跑之前)

- `.worktrees/faction-cohesion/config/infonet_moderate_distress_fragility.json`+`scripts/debug/infonet_moderate_distress_fragility_bed.gd`（已persist commit `46803ca8`）
- resident 距 lord **D=5 hex**（物理最短 relief 延遲 ≈ (49×5+240)/240 ≈ **2.02 天/趟**，herald+cadence+convoy 公式,見查證agent報告）
- food0=180（原預期 runway crossing<2.0 於 ~day20.5，實測延到 **day44**——mountain 仍有部分產出offset consumption,耗損比純算術慢，此為誠實跑出來的結果非預先精算）
- 2 faction pair：T0(GoodLord)+T1(GoodMember_Moderate) / T2(BadLord)+T3(BadMember_Moderate)，65天

## 原始輸出（已ls/wc驗證落地）

- `docs/measurements/2026-08-05-moderate-distress-fragility-65d.txt`（8632行raw log）
- `docs/measurements/2026-08-05-infonet-moderate-distress-fragility.json`（1067行聚合,含逐日runway軌跡）
- `docs/measurements/2026-08-05-infonet-moderate-distress-fragility.specimen.jsonl`（2285行specimen trace）

## 結果

```
T1(GoodMember_Moderate): exit_day=44  runway<2.0首日=44
T3(BadMember_Moderate):  exit_day=44  runway<2.0首日=45
★relief/出口機制計數：distribute.deliver=0 cohesion.benefactor_write=0
                      cohesion.defect_fire=2 cohesion.uprising_stay_faction=0 g3.betrayal=0
```

## 誠實淨判

**仍INCONCLUSIVE，但這輪把上一輪的「fixture太極端」解釋排除掉了**：

- D=5（近，物理單趟relief只要~2天）、food0=180 給了**44天的健康緩衝期**（不是上輪established床的day0瞬餓），好領主的AI理論上有數十次每日cadence機會可以proactive注意到resident food正在下降並提早送賑濟——**但distribute.deliver全程65天=0，兩個lord（好壞皆然）一次relief都沒派過**。
- T1(好領主member)/T3(壞領主member)在幾乎同一天（day44/45）退出，跟領主人格無關——**這次連「distance太遠」都不能解釋了**（D=5夠近）。
- **我的猜測（未坐實，請故事稽核判斷）**：relief dispatch 機制看起來是**純reactive**（只在resident已經進入severity/desperation區才觸發評估），不是proactive/anticipatory（不會提早注意到「食物正緩慢下降,快沒了」而預先送）。一旦severity觸發，defect的~1天窗口又比relief物理最短~2天快，所以不管前面有多少天的calm buffer，relief永遠在race裡輸——真正瓶頸可能不是distance/fixture參數，是relief的**觸發時機邏輯本身**。
- **這是我的假設非結論**——請讀specimen判T1/T3的food/runway逐日軌跡+領主AI決策軌跡（有沒有在day44前的任何一天評估過要不要送relief但決定不送、還是壓根從未評估過），確認是不是這個故事。

## 下游

QA讀specimen出verdict ref，供systems組cohesion驗收包（③②①+g3）判斷①最終定調。

## 清理

fixture已persist commit `46803ca8`，非temp。
