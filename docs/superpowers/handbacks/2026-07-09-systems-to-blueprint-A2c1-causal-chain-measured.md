---
from: systems
to: blueprint
status: open
topic: A2c1 因果診斷——多信號 measured 支持用戶假設(merge=生存被弱化);缺直接 merge-count(bed quiet);提標準全探針床
---

# A2c-1 因果診斷：用戶假設「merge=生存手段被弱化」——measured 多信號支持

用戶要診斷別瞎調。**手上 JSON 已含多個 measured 信號，方向一致支持用戶假設。**缺一個直接數（merge count，bed 跑 quiet 沒印）→ 提探針補。

## measured 信號（seed 1337，全來自 JSON，非理論）
| 信號 | 740 | 520 | 讀 |
|---|---|---|---|
| **avg team size** (pop/teams) | 218/31=**7.0** | 203/36=**5.6** | **−20%：fold 隊更小 = 少 consolidation** |
| final.teams | 31 | 36 | +5：更多小隊各自存在（沒併） |
| **join.resolve**(投靠成功=絕境併大隊) | 24 | **13** | **−46%：生存 consolidation 腰斬** |
| join.dispatch | 48 | 36 | −25% |
| member_atk_eligible(能攻擊=夠強) | 416 | 309 | **−26%：小隊弱、打不動** |
| 餓死 anon | 122 | 133 | +9% |
| 餓滅隊 extinct.starve | 16 | 19 | +19% |
| 征服宣告 | 740 | 520 | −30%（下游） |
| 掠奪派 | 32 | 10 | −69%（下游） |

## 因果鏈（多信號一致 → 支持用戶假設）
**fold → 少 consolidation（隊更小 5.6 vs 7.0 + 投靠腰斬）→ 隊弱（attack-eligible −26%）+ 撐不住（餓死/餓滅升）→ 衝突全面降（下游）**

- **答 A（因果方向）**：非「純粹死隊多拉低總量」——**存活隊本身更小更弱**（avg 5.6、eligible −26%）。衝突降主因是**隊弱**（沒 consolidate 成能打的大隊），死隊多是同因的並發。→ **支持用戶「下游」框架**（衝突降是 consolidation 弱化的下游，非可調侵略度）。
- **答 B（merge=生存？）**：**join.resolve 腰斬**（投靠=絕境小隊併大隊求生）+ avg size 縮 = 直接證**生存 consolidation 機制弱化**。舊 forced-merge 把弱隊併成能活的大隊；fold 讓它競秤 → 弱隊沒被併 → 小、弱、餓。
- **答 C（食物經濟）**：餓滅 +19% 且隊更小 → 小隊食物撐不住（未 consolidate 攤不了 overhead）。方向成立；per-team food deficit 需探針細追。

## ★診斷限制 + 提標準全探針床（用戶流程修）
- **缺直接數**：seeded_warring_bed 跑 quiet（WarringHarness 無 per-event print）→ **數不到實際 consolidate-merge 次數 + merge-applicable 隊的實際去向**（B 的鐵證）。現靠 join.resolve/avg-size 間接證（強但非直證）。
- **這正是用戶流程修要的**：bed 缺 consolidation/option-choice/team-size-dist 維度 → 反應式補量。
- **我提**：立 `full_probe` 模式加三探針——①consolidate-merge dispatch count ②merge-applicable 隊 option 選擇分布（選整併 vs 別的）③team-size 直方圖 + food-flow 分布。一 run 產齊 baseline/fold 對照 → B 鐵證 + 因果一眼。

## 願景含意（你重框已料中）
若鐵證坐實（我判**大機率坐實**，多信號已一致）：
- A2c-1 fold **弱化 merge-as-survival = shipping regression**，非中性 artifact 移除。
- 「治」非 tune conquest，是**引擎正確 value 求生整併**——弱/餓隊該併時引擎得選併（可能是「整併 option 對小/弱/餓隊 drive 要夠高壓過別的」——但這次不是瞎調，是**針對 survival-consolidation 的估值缺口**定點補）。
- 你先前把「duress 下整併」劃 A2d = 其**求生版本 load-bearing 不可延**（你已自我修正，坐實）。

## 請你定
1. **要不要我先立 full_probe 三探針 + 重跑拿 B 鐵證**（~20min：探針 code + baseline/fold 兩跑）→ 再定 A2c-1 定性？
2. 還是**多信號已足**（avg-size/join 腰斬/eligible 一致）→ 你逕判「merge-as-survival 弱化坐實」→ 我進「引擎正確 value 求生整併」的修（另 spec，A2c-1 從純 fold 升級為 fold+survival-value）？

**暫緩 A2c-1 收尾/merge（你已令），不在錯因上鎖。** 用戶在線，重大轉折你同步他。等你定 1/2。
